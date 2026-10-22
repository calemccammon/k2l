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

tasks.named<JavaExec>("run") {
    workingDir = rootDir
}

val testCases = layout.projectDirectory.dir("src/test/cases")

tasks.test {
    useJUnitPlatform()
    maxHeapSize = "2g"
    inputs.dir(testCases)
    systemProperty("k2l.casesDir", testCases.asFile.absolutePath)
    // -PupdateGolden: rewrites every case's expected.lua, stdout.txt and stdout.<target>.txt (see CasesTest)
    systemProperty("k2l.updateGolden", providers.gradleProperty("updateGolden").isPresent)
    // -Plua51=/path/to/lua5.1 (and lua52, lua53, lua54, luajit): the interpreter the run tests use for that target
    for (name in listOf("lua51", "lua52", "lua53", "lua54", "luajit")) {
        providers.gradleProperty(name).orNull?.let { systemProperty("k2l.$name", it) }
    }
    providers.gradleProperty("only").orNull?.let { systemProperty("k2l.only", it) } // -Ponly=casts,objects_enums
}

// ---- Version: `k2l --version` reads it from a resource generated from gradle.properties ----

tasks.processResources {
    val k2lVersion = project.version.toString()
    inputs.property("version", k2lVersion)
    filesMatching("k2l-version.properties") { expand("version" to k2lVersion) }
}

// ---- Distribution: k2l-<version>.zip/.tar with bin/k2l, bin/k2l.bat, lib/*.jar, the README and docs/ ----

distributions.main {
    contents {
        from(rootProject.file("README.md"))
        from(rootProject.file("docs")) { into("docs") }
    }
}

// ---- The compiler's runtime classpath as one zip, for the Gradle plugin (`dev.k2l`) ----

// The Analysis API jars come from JetBrains' repository without usable POMs, so a consumer can't resolve the compiler
// transitively. The Gradle plugin resolves this variant instead: one zip holding the exact set of jars `k2l` runs with
// (the compiler's own jar included), which it unpacks (UnzipTransform). It is published with the compiler and also
// serves included builds.
val k2lRuntimeLibsZip = tasks.register<Zip>("k2lRuntimeLibsZip") {
    from(tasks.jar)
    from(configurations.runtimeClasspath)
    archiveClassifier.set("runtime-libs")
    destinationDirectory.set(layout.buildDirectory.dir("runtime-libs"))
}

val k2lCompilerRuntime = configurations.consumable("k2lCompilerRuntime") {
    attributes.attribute(Usage.USAGE_ATTRIBUTE, objects.named("k2l-compiler-runtime"))
    outgoing.artifact(k2lRuntimeLibsZip)
}

(components["java"] as AdhocComponentWithVariants).addVariantsFromConfiguration(k2lCompilerRuntime.get()) {}

publishing {
    publications.create<MavenPublication>("maven") { from(components["java"]) }
}
