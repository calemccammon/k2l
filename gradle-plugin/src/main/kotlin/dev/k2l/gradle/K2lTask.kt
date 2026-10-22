package dev.k2l.gradle

import org.gradle.api.DefaultTask
import org.gradle.api.file.ConfigurableFileCollection
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Classpath
import org.gradle.api.tasks.IgnoreEmptyDirectories
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFiles
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.PathSensitive
import org.gradle.api.tasks.PathSensitivity
import org.gradle.jvm.toolchain.JavaLauncher
import org.gradle.process.ExecOperations
import org.gradle.work.DisableCachingByDefault
import java.io.ByteArrayOutputStream
import java.io.File

/**
 * What the k2l tasks share: the sources, the options that change what the compiler accepts, and running the compiler in a
 * separate JVM whose classpath is [compilerClasspath], so the compiler's (large) Analysis API dependencies never reach the
 * build's own classpath.
 */
@DisableCachingByDefault(because = "Each concrete k2l task says whether it is cacheable")
abstract class K2lTask(private val exec: ExecOperations) : DefaultTask() {
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

    /** A JDK 21 to run the compiler with; unset means the JVM running Gradle (which then must be 21 or newer). */
    @get:Internal
    abstract val javaLauncher: Property<JavaLauncher>

    /** The source directories that exist. */
    protected fun existingSources(): List<File> = sourceDirs.files.filter { it.isDirectory }

    /** The options every run passes, then [extra], then the sources. */
    protected fun compilerArgs(sources: List<File>, extra: List<String>): List<String> {
        val args =
            mutableListOf(
                "-t",
                luaTarget.get(),
                "--lualib",
                luaLibImport.get(),
            )
        args += extra
        val libraries = classpath.files.filter { it.exists() }
        if (libraries.isNotEmpty()) args += listOf("--classpath", libraries.joinToString(File.pathSeparator))
        args += sources.map { it.absolutePath }
        return args
    }

    /** Runs the compiler with [args]; returns its exit status and everything it printed. */
    protected fun runCompiler(args: List<String>): Pair<Int, String> {
        val output = ByteArrayOutputStream()
        val result = exec.javaexec { spec ->
            if (javaLauncher.isPresent) spec.executable = javaLauncher.get().executablePath.asFile.absolutePath
            // The unshrunk IntelliJ core must precede kotlin-compiler's copy of it; the rest is sorted so the
            // order (which files.order does not guarantee) is the same on every machine.
            spec.classpath(compilerClasspath.files.sortedWith(compareBy({ !it.name.startsWith("core-") }, { it.name })))
            spec.mainClass.set("dev.k2l.MainKt")
            // The same flags as the `k2l` start script: deep recursion in the analysis, throughput GC.
            spec.jvmArgs("-Xss8m", "-XX:+UseParallelGC")
            spec.args(args)
            spec.standardOutput = output
            spec.errorOutput = output
            spec.isIgnoreExitValue = true
        }
        return result.exitValue to output.toString(Charsets.UTF_8).trim()
    }
}
