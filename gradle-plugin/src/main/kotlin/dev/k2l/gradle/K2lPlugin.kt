package dev.k2l.gradle

import org.gradle.api.JavaVersion
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.artifacts.type.ArtifactTypeDefinition.ARTIFACT_TYPE_ATTRIBUTE
import org.gradle.api.attributes.Usage
import org.gradle.api.plugins.BasePlugin
import org.gradle.jvm.toolchain.JavaLanguageVersion
import org.gradle.jvm.toolchain.JavaToolchainService
import java.util.Properties

/**
 * Plugin `dev.k2l`: adds the `k2l { }` extension and the `compileKotlinToLua` task (wired into `assemble`).
 *
 * The compiler comes from the `k2lCompiler` configuration, which defaults to `dev.k2l:compiler:<plugin version>`;
 * that dependency resolves to a directory with the compiler's complete runtime classpath (see `k2lCompilerRuntime`
 * in the compiler project) and is only ever passed to the task as a file collection for a forked JVM.
 */
class K2lPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        project.pluginManager.apply(BasePlugin::class.java)
        val version = pluginVersion()

        val extension = project.extensions.create("k2l", K2lExtension::class.java)
        extension.sourceDirs.from(project.layout.projectDirectory.dir("src/main/kotlin"))
        extension.outputDir.convention(project.layout.buildDirectory.dir("lua"))
        extension.luaTarget.convention("5.4")
        extension.luaLibImport.convention("require")
        extension.intOverflow.convention("unchecked")
        extension.strings.convention("bytes")
        extension.long64.convention("double")
        extension.sourceMap.convention(false)

        project.dependencies.registerTransform(UnzipTransform::class.java) {
            it.from.attribute(ARTIFACT_TYPE_ATTRIBUTE, "zip")
            it.to.attribute(ARTIFACT_TYPE_ATTRIBUTE, "directory")
        }
        project.dependencies.attributesSchema.attribute(Usage.USAGE_ATTRIBUTE) {
            it.compatibilityRules.add(ZipUsageCompatibility::class.java)
            it.disambiguationRules.add(PreferDirectoryUsage::class.java)
        }
        val compiler = project.configurations.create(COMPILER_CONFIGURATION) { cfg ->
            cfg.description = "The k2l compiler and its runtime classpath."
            cfg.isCanBeConsumed = false
            cfg.isCanBeResolved = true
            cfg.attributes.attribute(Usage.USAGE_ATTRIBUTE, project.objects.named(Usage::class.java, COMPILER_USAGE))
            cfg.defaultDependencies { deps -> deps.add(project.dependencies.create("dev.k2l:compiler:$version")) }
        }

        val compile = project.tasks.register("compileKotlinToLua", K2lCompileTask::class.java) { task ->
            task.description = "Transpiles the Kotlin sources to Lua with k2l."
            task.group = "build"
            task.sourceDirs.from(extension.sourceDirs)
            task.classpath.from(extension.classpath)
            // A published compiler is a zip of jars (unpacked by UnzipTransform); in a composite build it is a directory;
            // a hand-made dependency (files(...)) is used as it is.
            val unpacked = compiler.incoming.artifactView { it.attributes.attribute(ARTIFACT_TYPE_ATTRIBUTE, "directory") }.files
            task.compilerClasspath.from((unpacked + compiler.incoming.files).asFileTree.matching { it.include("**/*.jar") })
            task.luaTarget.set(extension.luaTarget)
            task.luaLibImport.set(extension.luaLibImport)
            task.intOverflow.set(extension.intOverflow)
            task.strings.set(extension.strings)
            task.long64.set(extension.long64)
            task.sourceMap.set(extension.sourceMap)
            task.outputDir.set(extension.outputDir)
            // The Analysis API needs JDK 21+; fall back to a toolchain when Gradle itself runs on something older.
            if (!JavaVersion.current().isCompatibleWith(JavaVersion.VERSION_21)) {
                task.javaLauncher.set(
                    project.extensions.getByType(JavaToolchainService::class.java)
                        .launcherFor { it.languageVersion.set(JavaLanguageVersion.of(MIN_JAVA)) },
                )
            }
        }
        project.tasks.named(BasePlugin.ASSEMBLE_TASK_NAME).configure { it.dependsOn(compile) }

        // With the Kotlin plugin, @LuaExternal and friends should also resolve in the IDE and in compileKotlin.
        project.pluginManager.withPlugin("org.jetbrains.kotlin.jvm") {
            project.dependencies.add("compileOnly", "dev.k2l:lua-api:$version")
        }
    }

    private fun pluginVersion(): String {
        val properties = Properties()
        K2lPlugin::class.java.getResourceAsStream("/k2l-plugin.properties")?.use(properties::load)
        return properties.getProperty("version") ?: error("k2l-plugin.properties is missing from the plugin jar")
    }

    companion object {
        const val COMPILER_CONFIGURATION = "k2lCompiler"
        const val COMPILER_USAGE = "k2l-compiler-runtime"
        const val COMPILER_ZIP_USAGE = "k2l-compiler-runtime-zip"
        private const val MIN_JAVA = 21
    }
}
