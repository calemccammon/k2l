import java.time.Duration

plugins {
    alias(libs.plugins.kotlin.jvm)
    `java-gradle-plugin`
}

kotlin {
    jvmToolchain(21)
}

// With maven-publish (applied to every project), `publishToMavenLocal` installs the plugin and its marker artifact.
gradlePlugin {
    plugins {
        create("k2l") {
            id = "dev.k2l"
            implementationClass = "dev.k2l.gradle.K2lPlugin"
            displayName = "k2l: Kotlin to Lua"
            description = "Transpiles Kotlin sources to Lua with the k2l compiler."
        }
    }
}

// The plugin never loads the compiler: it runs it in a separate JVM from a directory of jars, see K2lPlugin.
// The plugin only needs to know its own version, which is also the version of the compiler it runs.
tasks.processResources {
    val pluginVersion = project.version.toString()
    inputs.property("version", pluginVersion)
    filesMatching("k2l-plugin.properties") { expand("version" to pluginVersion) }
}

// ---- Functional tests: real Gradle builds through TestKit ----

val functionalTest by sourceSets.creating

gradlePlugin.testSourceSets(functionalTest)

// The compiler's runtime-libs zip, injected into the sample projects so the tests don't depend on a published compiler.
val compilerLibs by configurations.creating {
    isCanBeConsumed = false
    attributes.attribute(Usage.USAGE_ATTRIBUTE, objects.named("k2l-compiler-runtime"))
}

dependencies {
    compilerLibs(project(":compiler"))
    "functionalTestImplementation"(gradleTestKit())
    "functionalTestImplementation"(platform(libs.junit.bom))
    "functionalTestImplementation"(libs.junit.jupiter)
    "functionalTestRuntimeOnly"(libs.junit.launcher)
}

val functionalTestTask = tasks.register<Test>("functionalTest") {
    description = "Runs the plugin in sample projects with Gradle TestKit."
    group = "verification"
    testClassesDirs = functionalTest.output.classesDirs
    classpath = functionalTest.runtimeClasspath
    useJUnitPlatform()
    // A stuck nested build must fail CI rather than hang it.
    timeout.set(Duration.ofMinutes(15))
    testLogging {
        showStandardStreams = true
        events("started", "passed", "failed")
    }
    inputs.files(compilerLibs)
    systemProperty("k2l.compilerLibs", compilerLibs.incoming.files.asPath)
    systemProperty("k2l.repoRoot", rootDir.absolutePath)
}

tasks.check {
    dependsOn(functionalTestTask)
}
