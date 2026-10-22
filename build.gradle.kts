allprojects {
    group = "dev.k2l"
    // gradle.properties, or -Pversion=... for a release
    version = providers.gradleProperty("version").get()
}

plugins {
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.detekt) apply false
    alias(libs.plugins.spotless) apply false
    alias(libs.plugins.maven.publish) apply false
    alias(libs.plugins.plugin.publish) apply false
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

    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        val ktlintVersion = rootProject.libs.versions.ktlint.get()
        kotlin {
            target("src/**/*.kt")
            targetExclude("src/test/cases/**", "src/bench/programs/**") // transpiler inputs, kept as written
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
        source.setFrom(
            "src/main/kotlin",
            "src/test/kotlin",
            "src/testShared/kotlin",
            "src/functionalTest/kotlin",
            "src/bench/kotlin",
        )
    }
}

// ---- Publishing: Maven Central (Central Portal) for every project, see RELEASING.md ----

val publishedDescriptions = mapOf(
    "lua-api" to "Kotlin declarations (annotations) for calling Lua from Kotlin code transpiled by k2l.",
    "compiler" to "k2l: a Kotlin to Lua transpiler built on the Kotlin Analysis API.",
    "gradle-plugin" to "Gradle plugin dev.k2l: transpiles Kotlin sources to Lua with k2l.",
)

subprojects {
    apply(plugin = "com.vanniktech.maven.publish")

    configure<com.vanniktech.maven.publish.MavenPublishBaseExtension> {
        // Uploads to the Central Portal when publishToMavenCentral runs; credentials come from the
        // ORG_GRADLE_PROJECT_mavenCentralUsername / mavenCentralPassword environment variables.
        publishToMavenCentral()
        // Signing keys come from ORG_GRADLE_PROJECT_signingInMemoryKey (and ...KeyId / ...KeyPassword).
        // Without them nothing is signed, so `check` and `publishToMavenLocal` never need a key.
        if (providers.gradleProperty("signingInMemoryKey").isPresent) signAllPublications()

        coordinates(group.toString(), project.name, version.toString())
        pom {
            name.set("k2l ${project.name}")
            description.set(publishedDescriptions.getValue(project.name))
            inceptionYear.set("2026")
            url.set("https://github.com/calemccammon/k2l")
            // TODO(license): no LICENSE file exists in the repository yet. Choose a license, add the LICENSE file
            // and fill in the matching <licenses> entry here before the first publication (Maven Central requires one).
            licenses {
                license {
                    name.set("TODO: license name")
                    url.set("TODO: license url")
                }
            }
            developers {
                developer {
                    id.set("calemccammon")
                    name.set("Cale McCammon")
                    url.set("https://github.com/calemccammon")
                }
            }
            scm {
                url.set("https://github.com/calemccammon/k2l")
                connection.set("scm:git:https://github.com/calemccammon/k2l.git")
                developerConnection.set("scm:git:ssh://git@github.com/calemccammon/k2l.git")
            }
        }
    }
}
