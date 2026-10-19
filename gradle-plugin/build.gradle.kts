import java.time.Duration

plugins {
    alias(libs.plugins.kotlin.jvm)
    `java-gradle-plugin`
    alias(libs.plugins.plugin.publish)
}

kotlin {
    jvmToolchain(21)
}

gradlePlugin {
    // Gradle Plugin Portal metadata; the API key comes from -Pgradle.publish.key/secret or
    // ORG_GRADLE_PROJECT_gradle.publish.key / ...secret (see RELEASING.md).
    website.set("https://github.com/calemccammon/k2l")
    vcsUrl.set("https://github.com/calemccammon/k2l.git")
    plugins {
        create("k2l") {
            id = "dev.k2l"
            implementationClass = "dev.k2l.gradle.K2lPlugin"
            displayName = "k2l: Kotlin to Lua"
            description = "Transpiles Kotlin sources to Lua with the k2l compiler."
            tags.set(listOf("kotlin", "lua", "transpiler", "k2l"))
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

// The compiler's jars, injected into the sample projects so the tests don't depend on a published compiler.
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
