plugins {
    alias(libs.plugins.kotlin.jvm)
    application
}

kotlin {
    jvmToolchain(21)
}

dependencies {
    // kotlin-compiler bundles a shrunk IntelliJ core; the unshrunk API must come first on the classpath.
    implementation(libs.intellij.core) { isTransitive = false }
    // The Analysis API "-for-ide" jars have POMs pointing at unpublished modules, so add them
    // non-transitively next to the compiler (same approach as Dokka).
    implementation(libs.kotlin.compiler) { isTransitive = false }
    libs.bundles.analysis.api.get().forEach {
        implementation("${it.module}:${it.version}") { isTransitive = false }
    }
    implementation(libs.caffeine)
    implementation(libs.coroutines.core) { isTransitive = false }
    implementation(libs.serialization.json)
    // The interop annotations; also put on the classpath of every transpiled program.
    implementation(project(":lua-api"))

    testImplementation(platform(libs.junit.bom))
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly(libs.junit.launcher)
}

application {
    applicationName = "k2l"
    mainClass.set("dev.k2l.MainKt")
    // The Analysis API indexes the whole classpath at startup.
    applicationDefaultJvmArgs = listOf("-Xss8m", "-XX:+UseParallelGC")
}

// AppCDS (see k2l-cds.sh): loading the ~10k compiler classes dominates startup, and an archive halves it.
tasks.startScripts {
    val cds = layout.projectDirectory.file("k2l-cds.sh")
    inputs.file(cds)
    doLast {
        val snippet = cds.asFile.readText()
        unixScript.writeText(unixScript.readText().replace(Regex("(?m)^DEFAULT_JVM_OPTS=.*$")) { it.value + "\n" + snippet })
    }
}

tasks.named<JavaExec>("run") {
    workingDir = rootDir
}

// Reading options.txt and finding interpreters, shared by the tests and the benchmark harness (below).
val testShared = "src/testShared/kotlin"
kotlin.sourceSets.named("test") { kotlin.srcDir(testShared) }

val testCases = layout.projectDirectory.dir("src/test/cases")
val benchPrograms = layout.projectDirectory.dir("src/bench/programs")

tasks.test {
    useJUnitPlatform()
    maxHeapSize = "2g"
    inputs.dir(testCases)
    inputs.dir(benchPrograms)
    systemProperty("k2l.casesDir", testCases.asFile.absolutePath)
    systemProperty("k2l.benchDir", benchPrograms.asFile.absolutePath)
    // -PupdateGolden: rewrites every case's expected.lua, stdout.txt and stdout.<target>.txt (see CasesTest)
    systemProperty("k2l.updateGolden", providers.gradleProperty("updateGolden").isPresent)
    // -Plua51=/path/to/lua5.1 (and lua52, lua53, lua54, luajit): the interpreter the run tests use for that target
    for (name in listOf("lua51", "lua52", "lua53", "lua54", "luajit")) {
        providers.gradleProperty(name).orNull?.let { systemProperty("k2l.$name", it) }
    }
    providers.gradleProperty("only").orNull?.let { systemProperty("k2l.only", it) } // -Ponly=casts,objects_enums
    // -PluaTargets=5.1,JIT: only those targets' tests, each needing its interpreter; the rest go with 5.4 (CI splits on it)
    providers.gradleProperty("luaTargets").orNull?.let { systemProperty("k2l.luaTargets", it) }
}

// ---- Benchmarks: ./gradlew :compiler:bench (local only, see "Benchmarks" in the README) ----

val bench: SourceSet = sourceSets.create("bench") {
    compileClasspath += sourceSets.main.get().output
    runtimeClasspath += sourceSets.main.get().output
}
kotlin.sourceSets.named("bench") { kotlin.srcDir(testShared) }
configurations["benchImplementation"].extendsFrom(configurations.implementation.get())
configurations["benchRuntimeOnly"].extendsFrom(configurations.runtimeOnly.get())

// Keeps the harness compiling; the programs themselves are transpiled by BenchProgramsTest.
tasks.check { dependsOn(tasks.named("compileBenchKotlin")) }

tasks.register<JavaExec>("bench") {
    description = "Transpiles and times the programs in src/bench/programs on every Lua found (-PbenchRuns, -PbenchOnly, " +
        "-PbenchTargets, -PbenchSave, -PbenchCompare, -PbenchProfile, " +
        "-PupdateGolden to rewrite the programs' stdout files)."
    group = "benchmark"
    classpath = bench.runtimeClasspath
    mainClass.set("dev.k2l.bench.BenchKt")
    jvmArgs("-Xss8m", "-XX:+UseParallelGC")
    maxHeapSize = "2g"
    systemProperty("k2l.bench.projectDir", layout.projectDirectory.asFile.absolutePath)
    systemProperty("k2l.bench.out", layout.buildDirectory.dir("bench").get().asFile.absolutePath)
    val names = listOf("benchRuns", "benchOnly", "benchTargets", "benchSave", "benchCompare", "benchProfile", "benchInterval", "benchTop") +
        listOf("benchProfileRepeat") +
        listOf("lua51", "lua52", "lua53", "lua54", "luajit")
    names.forEach { name -> providers.gradleProperty(name).orNull?.let { systemProperty("k2l.$name", it) } }
    systemProperty("k2l.updateGolden", providers.gradleProperty("updateGolden").isPresent)
    outputs.upToDateWhen { false }
}

// ---- The compiler's runtime classpath as one consumable directory, for the Gradle plugin (`dev.k2l`) ----

// The Analysis API jars are published without usable POMs, so a consumer can't resolve them transitively.
// This variant is the exact set of jars (the compiler's own jar included) that `k2l` runs with.
val k2lRuntimeLibs = tasks.register<Sync>("k2lRuntimeLibs") {
    from(tasks.jar)
    from(configurations.runtimeClasspath)
    into(layout.buildDirectory.dir("k2l-runtime"))
}

configurations.consumable("k2lCompilerRuntime") {
    attributes.attribute(Usage.USAGE_ATTRIBUTE, objects.named("k2l-compiler-runtime"))
    outgoing.artifact(layout.buildDirectory.dir("k2l-runtime")) { builtBy(k2lRuntimeLibs) }
}

// ---- Version: `k2l --version` reads it from a resource generated from gradle.properties ----

tasks.processResources {
    val k2lVersion = project.version.toString()
    inputs.property("version", k2lVersion)
    filesMatching("k2l-version.properties") { expand("version" to k2lVersion) }
}

// ---- Distribution: k2l-<version>.zip/.tar with bin/k2l, bin/k2l.bat, lib/*.jar, README and LICENSE ----

distributions.main {
    contents {
        from(rootProject.file("README.md"))
        // LICENSE is added as soon as the repository has one.
        from(rootProject.fileTree(rootProject.projectDir) { include("LICENSE*") }.files)
    }
}

// ---- Publishing: the runtime classpath as one zip, for the Gradle plugin ----

// The compiler's POM lists the Analysis API jars, which are not on Maven Central, so a consumer can't resolve
// the compiler transitively. The Gradle plugin therefore resolves this variant instead: one zip holding the
// complete set of jars `k2l` runs with. (In this build the plugin's tests use the directory variant above.)
val k2lRuntimeLibsZip = tasks.register<Zip>("k2lRuntimeLibsZip") {
    from(k2lRuntimeLibs)
    archiveClassifier.set("runtime-libs")
    archiveExtension.set("zip")
    destinationDirectory.set(layout.buildDirectory.dir("runtime-libs"))
}

val k2lCompilerRuntimeZip = configurations.consumable("k2lCompilerRuntimeZip") {
    // A usage of its own keeps it apart from the directory variant above; the Gradle plugin accepts it (UsageRules.kt).
    attributes.attribute(Usage.USAGE_ATTRIBUTE, objects.named("k2l-compiler-runtime-zip"))
    outgoing.artifact(k2lRuntimeLibsZip)
}

// Publish only the zip variant: the directory of the variant above can't be published.
(components["java"] as AdhocComponentWithVariants).addVariantsFromConfiguration(k2lCompilerRuntimeZip.get()) {}
