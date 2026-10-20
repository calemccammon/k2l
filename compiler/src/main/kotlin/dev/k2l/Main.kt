package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import java.io.PrintStream
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import kotlin.io.path.extension
import kotlin.system.exitProcess

/** The build version, generated into `k2l-version.properties` from `gradle.properties`. */
val VERSION: String by lazy {
    val properties = java.util.Properties()
    object {}.javaClass.getResourceAsStream("/k2l-version.properties")?.use(properties::load)
    properties.getProperty("version") ?: "unknown"
}

/** Exit status for bad arguments or a bad k2l.json. */
internal const val USAGE_ERROR = 2

/** Exit status for a crash in k2l itself (`EX_SOFTWARE`), as opposed to errors in the Kotlin sources. */
private const val INTERNAL_ERROR = 70

private const val NANOS_PER_MILLI = 1_000_000

fun main(args: Array<String>) {
    // The IntelliJ core leaves non-daemon pool threads behind, so exit explicitly, also when the compiler crashes.
    val settings = try {
        parseArgs(args)
    } catch (e: CliExit) {
        println(e.output)
        exitProcess(0)
    } catch (e: IllegalArgumentException) {
        exitProcess(usageError(e, System.err))
    }
    if (settings.watch && settings.sources.isNotEmpty()) watch(args, settings)
    exitProcess(run(settings, System.err))
}

/** Runs k2l with [args] as the command line (without `--watch`), printing to [err]; returns the exit status. */
internal fun runCli(args: Array<String>, out: PrintStream, err: PrintStream): Int {
    val settings = try {
        parseArgs(args)
    } catch (e: CliExit) {
        out.println(e.output)
        return 0
    } catch (e: IllegalArgumentException) {
        return usageError(e, err)
    }
    return run(settings, err)
}

private fun usageError(e: IllegalArgumentException, err: PrintStream): Int {
    err.println("k2l: ${e.message}")
    err.println("Run 'k2l --help' for the options.")
    return USAGE_ERROR
}

private fun run(settings: Settings, err: PrintStream): Int {
    checkSources(settings, err)?.let { return it }
    return try {
        if (build(settings, err).hasErrors) 1 else 0
    } catch (@Suppress("TooGenericExceptionCaught") e: Throwable) {
        // A crash in k2l itself: the stack trace is the bug report.
        @Suppress("PrintStackTrace")
        e.printStackTrace(err)
        err.println("k2l: internal compiler error; please report it with the stack trace above")
        INTERNAL_ERROR
    }
}

/** The exit status when there are no source directories or one does not exist; null when there are sources to build. */
private fun checkSources(settings: Settings, err: PrintStream): Int? {
    val project = settings.projectFile
    val missing = settings.sources.firstOrNull { !Files.exists(it) }
    return when {
        settings.sources.isEmpty() && project != null ->
            usageError(IllegalArgumentException("$project lists no source directories (\"srcDirs\")"), err)

        settings.sources.isEmpty() -> {
            err.println("k2l: no source directories given, and there is no k2l.json in ${Paths.get("").toAbsolutePath()}\n")
            err.println(USAGE)
            USAGE_ERROR
        }

        missing != null -> usageError(IllegalArgumentException("source directory $missing not found"), err)

        else -> null
    }
}

/** Compiles the project once, printing diagnostics and writing the output unless there were errors (or it is a check). */
private fun build(settings: Settings, err: PrintStream): CompileResult {
    val sources = settings.sources.map { it.toAbsolutePath().normalize() }
    val module = SourceModule("main", sources)
    val result = SourceSession.create(listOf(module), settings.classpath).use { session ->
        K2lCompiler(settings.compilerOptions()).compile(session, module, emit = !settings.check)
    }
    // A hint shared by several diagnostics is printed under the first one only.
    val hinted = HashSet<String>()
    result.diagnostics.forEach { err.println(it.render(withHint = it.hint != null && hinted.add(it.hint))) }
    when {
        settings.check -> err.println("k2l: checked ${countFiles(sources)} file(s): ${summarize(result.diagnostics)}")

        result.hasErrors -> err.println("k2l: ${summarize(result.diagnostics)}; no files written")

        else -> {
            if (countFiles(sources) == 0) err.println("k2l: warning: no .kt files found in ${settings.sources.joinToString()}")
            result.writeTo(settings.out)
            val warnings = if (result.diagnostics.isEmpty()) "" else " (${summarize(result.diagnostics)})"
            err.println("k2l: wrote ${result.outputs.size} file(s) to ${settings.out}$warnings")
        }
    }
    return result
}

private fun countFiles(sources: List<Path>): Int = sources.sumOf { root ->
    if (Files.isDirectory(root)) Files.walk(root).use { s -> s.filter { it.extension == "kt" }.count().toInt() } else 1
}

/** Builds, then rebuilds on every change to the sources or the project file; never returns. */
private fun watch(args: Array<String>, initial: Settings): Nothing {
    // Settings are re-read each time, so edits to k2l.json (including its source directories) take effect.
    var current = initial
    WatchLoop(
        paths = { listOfNotNull(current.projectFile) + current.sources },
        rebuild = {
            try {
                current = parseArgs(args)
                val started = System.nanoTime()
                val result = build(current, System.err)
                val millis = (System.nanoTime() - started) / NANOS_PER_MILLI
                System.err.println("k2l: ${if (result.hasErrors) "failed" else "built"} in $millis ms, watching for changes")
            } catch (e: IllegalArgumentException) {
                System.err.println("k2l: ${e.message}")
            }
        },
    ).run()
}
