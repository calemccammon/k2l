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

val testCases = layout.projectDirectory.dir("src/test/cases")
val benchPrograms = layout.projectDirectory.dir("src/bench/programs")

tasks.test {
    useJUnitPlatform()
    maxHeapSize = "2g"
    inputs.dir(testCases)
    inputs.dir(benchPrograms)
    systemProperty("k2l.casesDir", testCases.asFile.absolutePath)
    systemProperty("k2l.benchDir", benchPrograms.asFile.absolutePath)
    systemProperty("k2l.updateGolden", providers.gradleProperty("updateGolden").isPresent)
    providers.gradleProperty("lua").orNull?.let { systemProperty("k2l.lua", it) }
    providers.gradleProperty("only").orNull?.let { systemProperty("k2l.only", it) } // -Ponly=casts,objects_enums
}

// ---- Kotlin/JVM oracle: the expected stdout of every test case comes from running it on the JVM ----

// The oracle itself (src/oracle) compiles every case in one JVM: starting kotlinc once per case made it the slowest part of CI.
val oracle: SourceSet = sourceSets.create("oracle")

dependencies {
    "oracleImplementation"("org.jetbrains.kotlin:kotlin-compiler-embeddable:${libs.versions.kotlin.get()}")
}

/** Runs [dev.k2l.oracle] on the cases in [cases]; `-Ponly=floats,unsigned` (or [onlyProperty]) limits it to some cases. */
fun registerOracle(name: String, description: String, cases: Directory, work: String, onlyProperty: String) =
    tasks.register<JavaExec>(name) {
        this.description = description
        group = "verification"
        classpath = oracle.runtimeClasspath
        mainClass.set("dev.k2l.oracle.OracleKt")
        jvmArgs("-XX:+UseParallelGC")
        maxHeapSize = "3g"
        systemProperty("k2l.oracle.cases", cases.asFile.absolutePath)
        systemProperty("k2l.oracle.work", layout.buildDirectory.dir(work).get().asFile.absolutePath)
        systemProperty("k2l.oracle.update", providers.gradleProperty("updateOracle").isPresent)
        systemProperty("k2l.oracle.only", providers.gradleProperty(onlyProperty).orNull.orEmpty())
        // -PoracleThreads=N compiles and runs N cases at a time (default: the processors, at most 4).
        providers.gradleProperty("oracleThreads").orNull?.let { systemProperty("k2l.oracle.threads", it) }
        outputs.upToDateWhen { false }
    }

registerOracle(
    "kotlinOracle",
    "Runs every test case on Kotlin/JVM and checks (or with -PupdateOracle, writes) its stdout.txt.",
    testCases,
    "oracle",
    if (providers.gradleProperty("only").isPresent) "only" else "oracleCases",
)

registerOracle(
    "benchOracle",
    "Runs every benchmark program on Kotlin/JVM and checks (or with -PupdateOracle, writes) its stdout.txt.",
    benchPrograms,
    "bench-oracle",
    "benchOnly",
)

// ---- Benchmarks: ./gradlew :compiler:bench (local only, see "Benchmarks" in the README) ----

val bench: SourceSet = sourceSets.create("bench") {
    compileClasspath += sourceSets.main.get().output
    runtimeClasspath += sourceSets.main.get().output
}
configurations["benchImplementation"].extendsFrom(configurations.implementation.get())
configurations["benchRuntimeOnly"].extendsFrom(configurations.runtimeOnly.get())

// Keeps the harness compiling; the programs themselves are transpiled by BenchProgramsTest.
tasks.check { dependsOn(tasks.named("compileBenchKotlin")) }

tasks.register<JavaExec>("bench") {
    description = "Transpiles and times the programs in src/bench/programs on every Lua found (-PbenchRuns, -PbenchOnly, " +
        "-PbenchTargets, -PbenchSave, -PbenchCompare, -PbenchProfile)."
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
    outputs.upToDateWhen { false }
}

// ---- Standard library coverage: ./gradlew :compiler:stdlibCoverage writes docs/stdlib-coverage.md (see the README) ----

val coverage: SourceSet = sourceSets.create("coverage") {
    compileClasspath += sourceSets.main.get().output
    runtimeClasspath += sourceSets.main.get().output
}
configurations["coverageImplementation"].extendsFrom(configurations.implementation.get())
configurations["coverageRuntimeOnly"].extendsFrom(configurations.runtimeOnly.get())

// `check` only compiles the audit: running it takes a while, and its report is committed.
tasks.check { dependsOn(tasks.named("compileCoverageKotlin")) }

tasks.register<JavaExec>("stdlibCoverage") {
    description = "Probes which Kotlin stdlib and JDK APIs k2l translates and writes docs/stdlib-coverage.md."
    group = "documentation"
    classpath = coverage.runtimeClasspath
    mainClass.set("dev.k2l.coverage.CoverageKt")
    jvmArgs("-Xss8m", "-XX:+UseParallelGC")
    maxHeapSize = "3g"
    systemProperty("k2l.coverage.report", rootProject.file("docs/stdlib-coverage.md").absolutePath)
    systemProperty("k2l.coverage.work", layout.buildDirectory.dir("coverage").get().asFile.absolutePath)
    systemProperty("k2l.coverage.sources", layout.projectDirectory.dir("src/main/kotlin").asFile.absolutePath)
    // -PcoverageOnly=kotlin.time,java.lang.Math probes only those areas and prints the result instead of writing the report.
    providers.gradleProperty("coverageOnly").orNull?.let { systemProperty("k2l.coverage.only", it) }
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
