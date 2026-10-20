package dev.k2l.bench

import dev.k2l.LuaTarget
import dev.k2l.frontend.SourceSession
import java.io.File

/** The records `profiler.lua` writes (see its header). */
@Suppress("MagicNumber") // field positions of the records
class Samples(file: File) {
    var mode = ""
    var total = 0L
    val vm = mutableMapOf<String, Long>()
    val selfLines = mutableMapOf<Pair<FnKey, Int>, Long>()
    val inclusive = mutableMapOf<FnKey, Long>()

    /** Samples of a lualib or C function by the program line nearest to it on the stack. */
    val sites = mutableMapOf<Pair<FnKey, Int>, Long>()

    val selfFunctions: Map<FnKey, Long> get() = selfLines.entries.groupBy({ it.key.first }) { it.value }.mapValues { it.value.sum() }

    init {
        for (line in file.readLines()) {
            val f = line.split('\t')
            when (f[0]) {
                "mode" -> mode = f[1]
                "total" -> total = f[1].toLong()
                "vm" -> vm[f[1]] = f[2].toLong()
                "self" -> selfLines.merge(FnKey(f[1], f[3].toInt()) to f[2].toInt(), f[4].toLong(), Long::plus)
                "incl" -> inclusive.merge(FnKey(f[1], f[2].toInt()), f[3].toLong(), Long::plus)
                "site" -> sites.merge(FnKey(f[1], f[2].toInt()) to f[4].toInt(), f[5].toLong(), Long::plus)
            }
        }
    }
}

/** One profiled program: the samples and how to name their positions. */
class ProgramProfile(val program: String, val samples: Samples, val names: Attribution) {
    fun percent(n: Long) = if (samples.total == 0L) 0.0 else PERCENT * n / samples.total

    /** Share of the samples by `program`, lualib feature or `C`. */
    val categories: Map<String, Double> by lazy {
        samples.selfLines.entries.groupBy({ names.category(it.key.first.source, it.key.second) }) { it.value }
            .mapValues { percent(it.value.sum()) }.entries.sortedByDescending { it.value }.associate { it.key to it.value }
    }

    /** Self share by function name (as [Attribution.function] prints it). */
    val functions: Map<String, Double> by lazy {
        samples.selfFunctions.entries.groupBy({ names.function(it.key) }) { it.value }.mapValues { percent(it.value.sum()) }
    }

    companion object {
        const val PERCENT = 100.0
    }
}

/**
 * `-PbenchProfile`: runs each program once under `profiler.lua` and writes a report per program and target to
 * `build/bench/profile/<target>/<program>.txt`, plus `summary.txt` per target (the hottest lualib functions and generated
 * lines across all programs).
 */
class BenchProfiler(private val config: BenchConfig, private val session: SourceSession) {
    fun run(programs: List<BenchProgram>, targets: List<BenchTarget>): Int {
        var failed = 0
        val driver = BenchProfiler::class.java.getResource("/dev/k2l/bench/profiler.lua")!!.readText()
        for (t in targets) {
            val profiles = mutableListOf<ProgramProfile>()
            for (program in programs) {
                val dir = File(config.outDir, "profile/${t.target.id}/${program.name}")
                try {
                    // The source-mapped build: the same code, plus a line table that maps it back to Kotlin.
                    val outputs = program.compile(session, t.target, dir, sourceMap = true)
                    File(dir, "k2l_profiler.lua").writeText(driver)
                    // LuaJIT samples once a millisecond: run the program several times for enough samples.
                    val repeat = config.profileRepeat ?: if (t.target == LuaTarget.LuaJIT) JIT_REPEAT else 1
                    val args = arrayOf("k2l_profiler.lua", "main.lua", "samples.tsv", config.interval.toString(), repeat.toString())
                    val (ms, output) = runLua(t.interpreter, dir, *args)
                    program.verify(output, repeat)
                    val emulate = program.options.copy(luaTarget = t.target).emulatesLong64
                    val names = Attribution(outputs, File(program.dir, "main.kt"), config.lualibDir, t.target, emulate)
                    val profile = ProgramProfile(program.name, Samples(File(dir, "samples.tsv")), names)
                    val text = ProfileText(config.top).program(profile, t.target, ms, repeat)
                    File(config.outDir, "profile/${t.target.id}/${program.name}.txt").writeText(text)
                    println(text)
                    profiles += profile
                } catch (e: IllegalStateException) {
                    println("FAILED ${program.name} on ${t.target.id}: ${e.message}")
                    failed++
                }
            }
            val summary = ProfileText(config.top).summary(profiles, t.target)
            File(config.outDir, "profile/${t.target.id}/summary.txt").writeText(summary)
            println(summary)
            println("Wrote the profiles to ${File(config.outDir, "profile/${t.target.id}")}")
        }
        return failed
    }

    private companion object {
        const val JIT_REPEAT = 10
    }
}

/** The text of the profile reports. */
class ProfileText(private val top: Int) {
    fun program(p: ProgramProfile, target: LuaTarget, ms: Double, repeat: Int): String = buildString {
        val s = p.samples
        val how = if (s.mode == "hook") "count hook (time inside C functions is not sampled)" else "jit.profile every 1 ms (JIT on)"
        val runs = if (repeat > 1) "$repeat runs" else "1 run"
        appendLine("== ${p.program} on ${target.id}: ${s.total} samples, $how, $runs, %.0f ms under the profiler ==".format(ms))
        appendLine("where: " + p.categories.entries.joinToString(", ") { "${it.key} %.1f%%".format(it.value) })
        if (s.vm.isNotEmpty()) {
            appendLine(
                "vm states: " +
                    s.vm.entries.sortedByDescending {
                        it.value
                    }.joinToString(", ") { "${VM_STATES[it.key] ?: it.key} %.1f%%".format(p.percent(it.value)) },
            )
        }
        appendLine("-- functions by self samples (self %, inclusive %) --")
        for ((fn, n) in s.selfFunctions.entries.sortedByDescending { it.value }.take(top)) {
            appendLine("%6.1f%% %6.1f%%  %s".format(p.percent(n), p.percent(s.inclusive[fn] ?: n), p.names.function(fn)))
        }
        appendLine("-- functions by inclusive samples --")
        for ((fn, n) in s.inclusive.entries.filter { it.key.lineDefined > 0 }.sortedByDescending { it.value }.take(top)) {
            appendLine("%6.1f%%  %s".format(p.percent(n), p.names.function(fn)))
        }
        appendLine("-- lines by self samples --")
        for ((key, n) in s.selfLines.entries.sortedByDescending { it.value }.take(top)) {
            appendLine("%6.1f%%  %s".format(p.percent(n), p.names.line(key.first.source, key.second)))
        }
        appendLine("-- lualib and C functions by the Kotlin line calling them --")
        for ((key, n) in s.sites.entries.sortedByDescending { it.value }.take(top)) {
            appendLine("%6.1f%%  %s  <-  %s".format(p.percent(n), p.names.function(key.first), p.names.kotlinLine(key.second)))
        }
    }

    fun summary(profiles: List<ProgramProfile>, target: LuaTarget): String = buildString {
        appendLine("== profile summary on ${target.id}: ${profiles.size} programs ==")
        appendLine("-- share of samples: program code, lualib, C --")
        for (p in profiles) {
            val lualib = p.categories.filterKeys { it != "program" && it != "C" }
            appendLine(
                "%-22s program %5.1f%%  lualib %5.1f%%  C %5.1f%%   %s".format(
                    p.program,
                    p.categories["program"] ?: 0.0,
                    lualib.values.sum(),
                    p.categories["C"] ?: 0.0,
                    lualib.entries.take(TOP_FEATURES).joinToString(", ") { "${it.key} %.1f%%".format(it.value) },
                ),
            )
        }
        appendLine("-- hottest functions across programs: sum of self % (the programs where it is at least 1%) --")
        val byFunction = profiles.flatMap { p -> p.functions.entries.map { Triple(it.key, p.program, it.value) } }.groupBy { it.first }
        for ((fn, rows) in byFunction.entries.sortedByDescending { e -> e.value.sumOf { it.third } }.take(top * 2)) {
            val where = rows.filter {
                it.third >= 1.0
            }.sortedByDescending { it.third }.joinToString(", ") { "${it.second} %.0f".format(it.third) }
            appendLine("%7.1f  %s   [%s]".format(rows.sumOf { it.third }, fn, where))
        }
    }

    private companion object {
        const val TOP_FEATURES = 4
        val VM_STATES = mapOf("N" to "compiled", "I" to "interpreted", "C" to "C code", "G" to "GC", "J" to "JIT compiler")
    }
}
