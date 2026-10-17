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

    testImplementation(platform(libs.junit.bom))
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly(libs.junit.launcher)
}

application {
    mainClass.set("dev.k2l.SpikeKt")
}

tasks.named<JavaExec>("run") {
    workingDir = rootDir
}

tasks.test {
    useJUnitPlatform()
}

tasks.register("printClasspath") {
    val cp = configurations.runtimeClasspath
    doLast { cp.get().files.forEach { println(it) } }
}
