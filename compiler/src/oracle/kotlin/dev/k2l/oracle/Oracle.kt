package dev.k2l.oracle

import org.jetbrains.kotlin.cli.common.ExitCode
import org.jetbrains.kotlin.cli.jvm.K2JVMCompiler
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.PrintStream
import java.nio.file.Paths
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.system.exitProcess

/**
 * The Kotlin/JVM oracle behind the `kotlinOracle` and `benchOracle` tasks: compiles every case with the real Kotlin compiler,
 * runs it on the JVM and checks (or, with `k2l.oracle.update`, writes) its `stdout.txt`.
 *
 * All the compiles happen in this one JVM, so the compiler is loaded and warmed up once rather than once per case, and the
 * cases are spread over a thread pool (`k2l.oracle.threads`, default: one per processor). Each program still runs in a
 * JVM of its own, as `java -cp <classes>:<stdlib> MainKt`.
 */
fun main() {
    val casesDir = File(System.getProperty("k2l.oracle.cases"))
    val workDir = File(System.getProperty("k2l.oracle.work"))
    val update = System.getProperty("k2l.oracle.update").toBoolean()
    val only = System.getProperty("k2l.oracle.only").orEmpty().split(',').filter { it.isNotEmpty() }
    val threads = System.getProperty("k2l.oracle.threads")?.toIntOrNull() ?: Runtime.getRuntime().availableProcessors()
    val cases = casesDir.listFiles().orEmpty().filter {
        File(it, "main.kt").isFile && !File(it, "errors.txt").isFile && (only.isEmpty() || it.name in only)
    }.sortedBy { it.name }
    val oracle = Oracle(workDir, update)
    val pool = Executors.newFixedThreadPool(threads.coerceAtLeast(1))
    // jvm-skip: the case calls into hand-written Lua, so it can't run on the JVM
    val results = cases.filter { !File(it, "jvm-skip").isFile }.map { case -> case.name to pool.submit<Boolean> { oracle.matches(case) } }
    val mismatched = mutableListOf<String>()
    val failed = mutableListOf<String>()
    for ((name, result) in results) {
        try {
            if (!result.get()) mismatched += name
        } catch (e: ExecutionException) {
            System.err.println("$name: ${e.cause?.message ?: e.cause}")
            failed += name
        }
    }
    pool.shutdown()
    if (failed.isNotEmpty()) {
        System.err.println("Kotlin/JVM could not compile or run $failed")
        exitProcess(1)
    }
    if (mismatched.isNotEmpty()) {
        System.err.println("Kotlin/JVM output differs from stdout.txt for $mismatched (rerun with -PupdateOracle)")
        exitProcess(1)
    }
    println("Kotlin/JVM oracle matched stdout.txt for ${cases.size} cases")
}

private class Oracle(private val workDir: File, private val update: Boolean) {
    private val stdlib = Paths.get(KotlinVersion::class.java.protectionDomain.codeSource.location.toURI()).toString()
    private val java = File(System.getProperty("java.home"), "bin/java").path
    private val packageName = Regex("""^package\s+([\w.]+)""", RegexOption.MULTILINE)

    /** Compiles and runs [case]; false when its output differs from stdout.txt (always true when updating). */
    fun matches(case: File): Boolean {
        val classes = File(workDir, case.name).apply {
            deleteRecursively()
            mkdirs()
        }
        compile(case, classes)
        val pkg = packageName.find(File(case, "main.kt").readText())?.groupValues?.get(1)
        val actual = run(classes, if (pkg != null) "$pkg.MainKt" else "MainKt")
        val expected = File(case, "stdout.txt")
        if (update) {
            expected.writeText(actual)
            return true
        }
        return expected.isFile && expected.readText() == actual
    }

    private fun compile(case: File, classes: File) {
        val sources = case.walkTopDown().filter { it.extension == "kt" }.map { it.path }.toList()
        val args = listOf("-no-stdlib", "-no-reflect", "-nowarn", "-classpath", stdlib, "-d", classes.path) + sources
        val messages = ByteArrayOutputStream()
        val code = PrintStream(messages, true, Charsets.UTF_8).use { K2JVMCompiler().exec(it, *args.toTypedArray()) }
        check(code == ExitCode.OK) { "kotlinc failed with $code:\n${messages.toString(Charsets.UTF_8)}" }
    }

    private fun run(classes: File, mainClass: String): String {
        // Cases print non-ASCII text and Locale.getDefault(): do not depend on the locale of the machine
        // (k2l's default locale is en_US)
        val command = listOf(java, "-Dfile.encoding=UTF-8", "-Dstdout.encoding=UTF-8", "-Duser.language=en", "-Duser.country=US") +
            listOf("-cp", classes.path + File.pathSeparator + stdlib, mainClass)
        val process = ProcessBuilder(command).redirectError(ProcessBuilder.Redirect.INHERIT).start()
        val output = process.inputStream.readBytes().toString(Charsets.UTF_8)
        check(process.waitFor(RUN_TIMEOUT_MINUTES, TimeUnit.MINUTES)) { "timed out" }
        check(process.exitValue() == 0) { "exited with ${process.exitValue()}" }
        return output
    }

    private companion object {
        const val RUN_TIMEOUT_MINUTES = 5L
    }
}
