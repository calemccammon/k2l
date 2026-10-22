allprojects {
    group = "dev.k2l"
    version = providers.gradleProperty("version").get() // gradle.properties
}

plugins {
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.detekt) apply false
    alias(libs.plugins.spotless) apply false
}

/** ktlint settings; Spotless doesn't pick these up from .editorconfig. */
val ktlintRules = mapOf(
    "ktlint_code_style" to "intellij_idea",
    "max_line_length" to "140",
    // The Lua syntax tree (dev.k2l.codegen) and the Kotlin PSI are used dozens of types at a time.
    "ij_kotlin_packages_to_use_import_on_demand" to "dev.k2l.codegen.*,org.jetbrains.kotlin.psi.*",
)

subprojects {
    apply(plugin = "dev.detekt")
    apply(plugin = "com.diffplug.spotless")
    // `./gradlew publishToMavenLocal` installs every project into ~/.m2; nothing is published anywhere else.
    apply(plugin = "maven-publish")

    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        val ktlintVersion = rootProject.libs.versions.ktlint.get()
        kotlin {
            target("src/**/*.kt")
            targetExclude("src/test/cases/**") // transpiler inputs, kept as written
            ktlint(ktlintVersion).editorConfigOverride(ktlintRules)
        }
        kotlinGradle {
            ktlint(ktlintVersion).editorConfigOverride(ktlintRules)
        }
    }

    plugins.withId("org.jetbrains.kotlin.jvm") {
        configure<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension> {
            compilerOptions.allWarningsAsErrors.set(true)
        }
    }

    configure<dev.detekt.gradle.extensions.DetektExtension> {
        buildUponDefaultConfig.set(true)
        config.setFrom(rootProject.file("config/detekt.yml"))
        source.setFrom("src/main/kotlin", "src/test/kotlin", "src/functionalTest/kotlin")
    }
}
