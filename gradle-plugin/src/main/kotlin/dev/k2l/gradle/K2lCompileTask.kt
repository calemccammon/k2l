package dev.k2l.gradle

import org.gradle.api.DefaultTask
import org.gradle.api.GradleException
import org.gradle.api.file.ConfigurableFileCollection
import org.gradle.api.file.DirectoryProperty
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Classpath
import org.gradle.api.tasks.IgnoreEmptyDirectories
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFiles
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.OutputDirectory
import org.gradle.api.tasks.PathSensitive
import org.gradle.api.tasks.PathSensitivity
import org.gradle.api.tasks.TaskAction
import org.gradle.jvm.toolchain.JavaLauncher
import org.gradle.process.ExecOperations
import org.gradle.work.DisableCachingByDefault
import java.io.ByteArrayOutputStream
import java.io.File
import javax.inject.Inject

/**
 * Runs the k2l compiler on [sourceDirs] in a separate JVM whose classpath is [compilerClasspath], so the compiler's
 * (large) Analysis API dependencies never reach the build's own classpath. The task is up to date while neither the
 * sources, the options nor the compiler change, and the build fails with the compiler's diagnostics on a Kotlin error.
 */
@DisableCachingByDefault(because = "Generated Lua embeds absolute paths in diagnostics and source maps; not worth sharing")
abstract class K2lCompileTask @Inject constructor(private val exec: ExecOperations) : DefaultTask() {
    @get:InputFiles
    @get:IgnoreEmptyDirectories
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val sourceDirs: ConfigurableFileCollection

    /** The compiler and everything it needs at run time. */
    @get:Classpath
    abstract val compilerClasspath: ConfigurableFileCollection

    /** Extra jars or class directories for the Kotlin sources to compile against. */
    @get:Classpath
    abstract val classpath: ConfigurableFileCollection

    @get:Input
    abstract val luaTarget: Property<String>

    @get:Input
    abstract val luaLibImport: Property<String>

    @get:Input
    abstract val intOverflow: Property<String>

    @get:Input
    abstract val strings: Property<String>

    @get:Input
    abstract val long64: Property<String>

    @get:Input
    abstract val sourceMap: Property<Boolean>

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty

    /** A JDK 21 to run the compiler with; unset means the JVM running Gradle (which then must be 21 or newer). */
    @get:Internal
    abstract val javaLauncher: Property<JavaLauncher>

    @TaskAction
    fun compile() {
        val sources = sourceDirs.files.filter { it.isDirectory }
        val out = outputDir.get().asFile
        // The output directory belongs to this task: drop files of Kotlin sources that no longer exist.
        out.deleteRecursively()
        out.mkdirs()
        if (sources.isEmpty()) {
            logger.lifecycle("k2l: no Kotlin source directories found, nothing to compile")
            return
        }

        val args =
            mutableListOf(
                "-o",
                out.absolutePath,
                "-t",
                luaTarget.get(),
                "--lualib",
                luaLibImport.get(),
                "--int-overflow",
                intOverflow.get(),
                "--strings",
                strings.get(),
                "--long64",
                long64.get(),
            )
        if (sourceMap.get()) args += "--source-map"
        val extra = classpath.files.filter { it.exists() }
        if (extra.isNotEmpty()) args += listOf("--classpath", extra.joinToString(File.pathSeparator))
        args += sources.map { it.absolutePath }

        val diagnostics = ByteArrayOutputStream()
        val result = exec.javaexec { spec ->
            if (javaLauncher.isPresent) spec.executable = javaLauncher.get().executablePath.asFile.absolutePath
            // The unshrunk IntelliJ core must precede kotlin-compiler's copy of it; the rest is sorted so the
            // order (which files.order does not guarantee) is the same on every machine.
            spec.classpath(compilerClasspath.files.sortedWith(compareBy({ !it.name.startsWith("core-") }, { it.name })))
            spec.mainClass.set("dev.k2l.MainKt")
            // The same flags as the `k2l` start script: deep recursion in the analysis, throughput GC.
            spec.jvmArgs("-Xss8m", "-XX:+UseParallelGC")
            spec.args(args)
            spec.standardOutput = diagnostics
            spec.errorOutput = diagnostics
            spec.isIgnoreExitValue = true
        }
        val output = diagnostics.toString(Charsets.UTF_8).trim()
        if (result.exitValue != 0) {
            throw GradleException("k2l failed (exit code ${result.exitValue}):\n$output")
        }
        if (output.isNotEmpty()) logger.lifecycle(output)
    }
}
