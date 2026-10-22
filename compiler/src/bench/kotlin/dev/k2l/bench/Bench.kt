package dev.k2l.bench

import dev.k2l.CompilerOptions
import dev.k2l.K2lCompiler
import dev.k2l.LuaOutput
import dev.k2l.LuaTarget
import dev.k2l.caseOptions
import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import dev.k2l.luaVersionBanner
import dev.k2l.recordStdout
import dev.k2l.stdoutFile
import java.io.File
import java.util.concurrent.TimeUnit
import kotlin.system.exitProcess

/**
 * The benchmark harness behind `./gradlew :compiler:bench` (see the README, "Benchmarks"): transpiles every program
 * in `src/bench/programs` with the current compiler, runs it on every Lua interpreter found, checks its output against
 * what the program prints on that target (`stdout.txt`, from Lua 5.4, or `stdout.<target>.txt`, as for test cases) and
 * reports wall times, or with `-PbenchProfile` a sampling profile. With `-PupdateGolden` it rewrites those files instead
 * (run it with `-PbenchRuns=1`).
 */
fun main() {
    val config = BenchConfig.fromSystemProperties()
    val programs = BenchProgram.discover(config.programsDir).filter { config.only == null || it.name in config.only }
    require(programs.isNotEmpty()) { "no benchmark programs selected (-PbenchOnly=${config.only})" }
    // 5.4 first: with -PupdateGolden its output is the one the other targets' outputs are compared with
    val targets = BenchTarget.discover().filter { config.targets == null || it.target.id in config.targets }
        .sortedBy { it.target != LuaTarget.Lua54 }
    require(targets.isNotEmpty()) { "no Lua interpreters found for ${config.targets ?: "any target"}" }
    println("k2l bench: ${programs.size} programs on ${targets.joinToString { "${it.target.id} (${it.version})" }}")
    val failed = SourceSession.create(programs.map { it.module }).use { session ->
        if (config.profile) {
            BenchProfiler(config, session).run(programs, targets)
        } else {
            val results = runTimings(config, session, programs, targets)
            BenchReport(config, targets).report(results)
            results.count { !it.ok }
        }
    }
    // The Analysis API leaves non-daemon threads behind.
    exitProcess(if (failed == 0) 0 else 1)
}

/** Settings from Gradle properties (`-PbenchRuns=3`), which the `bench` task passes as `k2l.<name>` system properties. */
class BenchConfig(
    val programsDir: File,
    val outDir: File,
    val lualibDir: File,
    val baseline: File,
    val runs: Int,
    val only: Set<String>?,
    val targets: Set<String>?,
    val save: File?,
    val compare: File?,
    val profile: Boolean,
    val interval: Int,
    val profileRepeat: Int?,
    val top: Int,
    /** `-PupdateGolden`: record the programs' outputs instead of checking them. */
    val updateGolden: Boolean,
) {
    companion object {
        private const val DEFAULT_RUNS = 5
        private const val DEFAULT_INTERVAL = 1000
        private const val DEFAULT_TOP = 25

        fun fromSystemProperties(): BenchConfig {
            val p = Properties()
            val baseline = p.file(p.value("bench.baseline") ?: "src/bench/baseline.json")
            return BenchConfig(
                programsDir = p.file(p.value("bench.programs") ?: "src/bench/programs"),
                outDir = p.file(p.value("bench.out") ?: "build/bench"),
                lualibDir = p.file(p.value("bench.lualib") ?: "src/main/resources/dev/k2l/lualib"),
                baseline = baseline,
                runs = p.int("benchRuns") ?: DEFAULT_RUNS,
                only = p.list("benchOnly"),
                targets = p.list("benchTargets")?.map { LuaTarget.parse(it).id }?.toSet()
                    ?: if (p.flag("benchProfile")) setOf(LuaTarget.Lua54.id, LuaTarget.LuaJIT.id) else null,
                save = if (p.flag("benchSave")) p.value("benchSave")?.takeIf { it != "true" }?.let(p::file) ?: baseline else null,
                compare = p.value("benchCompare").let {
                    if (it ==
                        null
                    ) {
                        baseline.takeIf(File::isFile)
                    } else {
                        it.takeIf { it != "none" }?.let(p::file)
                    }
                },
                profile = p.flag("benchProfile"),
                interval = p.int("benchInterval") ?: DEFAULT_INTERVAL,
                profileRepeat = p.int("benchProfileRepeat"),
                top = p.int("benchTop") ?: DEFAULT_TOP,
                updateGolden = p.value("updateGolden").toBoolean(),
            )
        }
    }

    /** The `k2l.*` system properties; relative paths are relative to the compiler project. */
    private class Properties {
        private val projectDir = File(value("bench.projectDir") ?: ".")

        /** Set, even to an empty value (`-PbenchProfile`). */
        fun flag(name: String) = System.getProperty("k2l.$name") != null

        fun value(name: String): String? = System.getProperty("k2l.$name")?.takeIf { it.isNotBlank() }

        fun int(name: String) = value(name)?.toInt()

        fun list(name: String) = value(name)?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }?.toSet()

        fun file(path: String) = File(path).let { if (it.isAbsolute) it else File(projectDir, path) }
    }
}

/** A directory of `src/bench/programs`: `main.kt`, `stdout.txt` and optionally `stdout.<target>.txt` and `options.txt` (as for test cases). */
class BenchProgram(val name: String, val dir: File, val options: CompilerOptions) {
    /** What the program prints on [target], empty when it has no stdout file. */
    fun expected(target: LuaTarget): String = stdoutFile(dir, target).takeIf(File::isFile)?.readText().orEmpty()

    val module = SourceModule(name, listOf(dir.toPath().toAbsolutePath()))

    /** Compiles for [target] into [outDir], failing on any diagnostic. */
    fun compile(session: SourceSession, target: LuaTarget, outDir: File, sourceMap: Boolean = false): List<LuaOutput> {
        val result = K2lCompiler(options.copy(luaTarget = target, sourceMap = sourceMap)).compile(session, module)
        check(result.diagnostics.isEmpty()) { "$name on ${target.id}:\n${result.diagnostics.joinToString("\n")}" }
        outDir.deleteRecursively()
        result.outputs.forEach { File(outDir, it.path).apply { parentFile.mkdirs() }.writeText(it.code) }
        return result.outputs
    }

    companion object {
        fun discover(dir: File): List<BenchProgram> = dir.listFiles().orEmpty()
            .filter { File(it, "main.kt").isFile }.sortedBy { it.name }
            .map { BenchProgram(it.name, it, caseOptions(it)) }
    }
}

/** A Lua interpreter found on the PATH (or given with `-Plua54=/path/to/lua`), confirmed by its version banner. */
class BenchTarget(val target: LuaTarget, val interpreter: String, val version: String) {
    companion object {
        /** Target, system property (`-Plua54=/path/to/lua`), names to look up on the PATH, version banner. */
        private val candidates = listOf(
            Candidate(LuaTarget.Lua51, "lua51", listOf("lua5.1", "lua51", "lua"), "Lua 5.1"),
            Candidate(LuaTarget.Lua52, "lua52", listOf("lua5.2", "lua52", "lua"), "Lua 5.2"),
            Candidate(LuaTarget.Lua53, "lua53", listOf("lua5.3", "lua53", "lua"), "Lua 5.3"),
            Candidate(LuaTarget.Lua54, "lua54", listOf("lua5.4", "lua54", "lua"), "Lua 5.4"),
            Candidate(LuaTarget.LuaJIT, "luajit", listOf("luajit"), "LuaJIT"),
        )

        private class Candidate(val target: LuaTarget, val property: String, val names: List<String>, val banner: String)

        fun discover(): List<BenchTarget> = candidates.mapNotNull { c ->
            (listOfNotNull(System.getProperty("k2l.${c.property}")) + c.names).firstNotNullOfOrNull { name ->
                luaVersionBanner(name)?.takeIf {
                    c.banner in it
                }?.let { BenchTarget(c.target, name, it.substringBefore("  ").substringBefore(" --").trim()) }
            }
        }
    }
}

/** The wall times of one program on one target, in milliseconds; [error] when it failed or printed the wrong output. */
class BenchResult(val program: String, val target: String, val timesMs: List<Double>, val error: String? = null) {
    val ok get() = error == null && timesMs.isNotEmpty()
    val medianMs: Double get() = timesMs.sorted().let { if (it.isEmpty()) Double.NaN else it[(it.size - 1) / 2] }
    val minMs: Double get() = timesMs.minOrNull() ?: Double.NaN
}

private const val TIMEOUT_SECONDS = 300L
private const val NANOS_PER_MS = 1e6
private const val TEXT_LIMIT = 1000

/** Runs `interpreter args` in [dir] with stdout to a file; returns wall milliseconds and the output, or throws. */
fun runLua(interpreter: String, dir: File, vararg args: String): Pair<Double, String> {
    val stdout = File(dir, ".stdout")
    val stderr = File(dir, ".stderr")
    val start = System.nanoTime()
    val process = ProcessBuilder(listOf(interpreter) + args).directory(dir)
        .redirectOutput(stdout).redirectError(stderr).start()
    check(process.waitFor(TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
        process.destroyForcibly()
        "timed out after $TIMEOUT_SECONDS s"
    }
    val ms = (System.nanoTime() - start) / NANOS_PER_MS
    check(process.exitValue() == 0) { "exited with ${process.exitValue()}: ${stderr.readText().take(TEXT_LIMIT)}" }
    return ms to stdout.readText()
}

/** Checks a run's output on [target] against the program's stdout file, or with [update] records it there. */
fun BenchProgram.verify(target: LuaTarget, output: String, update: Boolean, repeat: Int = 1) {
    if (update) {
        recordStdout(dir, target, output)
        return
    }
    val expected = expected(target)
    check(expected.isNotEmpty()) { "$name has no stdout.txt (run ./gradlew :compiler:bench -PupdateGolden -PbenchRuns=1)" }
    check(output == expected.repeat(repeat)) { "wrong output:\n${output.take(TEXT_LIMIT)}\nexpected:\n${expected.take(TEXT_LIMIT)}" }
}

private fun runTimings(
    config: BenchConfig,
    session: SourceSession,
    programs: List<BenchProgram>,
    targets: List<BenchTarget>,
): List<BenchResult> {
    val results = mutableListOf<BenchResult>()
    for (program in programs) {
        for (t in targets) {
            val dir = File(config.outDir, "lua/${t.target.id}/${program.name}")
            val result = try {
                program.compile(session, t.target, dir)
                val times = (1..config.runs).map {
                    val (ms, output) = runLua(t.interpreter, dir, "main.lua")
                    program.verify(t.target, output, config.updateGolden)
                    ms
                }
                BenchResult(program.name, t.target.id, times)
            } catch (e: IllegalStateException) {
                BenchResult(program.name, t.target.id, emptyList(), e.message ?: e.toString())
            }
            val line = if (result.ok) {
                "median %8.1f ms  min %8.1f ms".format(result.medianMs, result.minMs)
            } else {
                "FAILED: ${result.error?.lineSequence()?.first()}"
            }
            println("  %-22s %-4s %s".format(program.name, t.target.id, line))
            results += result
        }
    }
    return results
}
