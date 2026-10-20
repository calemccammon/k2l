package dev.k2l.bench

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.add
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject
import java.io.File
import java.time.Instant
import java.time.temporal.ChronoUnit
import kotlin.math.exp
import kotlin.math.ln

/** The timing table on stdout, `results.json` and `results.csv` under the output directory, the baseline and the comparison. */
class BenchReport(private val config: BenchConfig, private val targets: List<BenchTarget>) {
    private val json = Json { prettyPrint = true }

    fun report(results: List<BenchResult>) {
        val columns = targets.map { it.target.id }
        println()
        println("Median wall time in ms (min in parentheses), ${config.runs} runs:")
        println(table(results, columns) { r -> if (r.ok) "%.0f (%.0f)".format(r.medianMs, r.minMs) else "FAILED" })
        config.outDir.mkdirs()
        val document = toJson(results)
        File(config.outDir, "results.json").writeText(json.encodeToString(JsonElement.serializer(), document) + "\n")
        File(config.outDir, "results.csv").writeText(
            "program,target,median_ms,min_ms,runs_ms,error\n" + results.joinToString("") { r ->
                val error = r.error?.lines()?.filter {
                    it.isNotBlank()
                }?.joinToString(" | ")?.take(ERROR_TEXT)?.replace('"', '\'').orEmpty()
                "${r.program},${r.target},%.1f,%.1f,%s,\"%s\"\n".format(
                    r.medianMs,
                    r.minMs,
                    r.timesMs.joinToString(" ") {
                        "%.1f".format(it)
                    },
                    error,
                )
            },
        )
        println("Wrote ${File(config.outDir, "results.json")} and results.csv")
        config.compare?.takeIf { it.isFile }?.let { compare(results, columns, it) }
        config.save?.let {
            it.parentFile?.mkdirs()
            it.writeText(json.encodeToString(JsonElement.serializer(), document) + "\n")
            println("Saved the baseline to $it")
        }
        results.filter { !it.ok }.forEach { println("FAILED ${it.program} on ${it.target}: ${it.error}") }
    }

    /** Per-cell ratio of the median to the baseline's median (below 1 is faster), and the geometric mean per target. */
    private fun compare(results: List<BenchResult>, columns: List<String>, file: File) {
        val baseline = readResults(file)
        println()
        println("Compared with $file (median / baseline median; < 1.00 is faster):")
        val ratios = results.filter { it.ok }.mapNotNull { r ->
            baseline[r.program to r.target]?.takeIf { it > 0 }?.let { (r.program to r.target) to r.medianMs / it }
        }.toMap()
        println(table(results, columns) { r -> ratios[r.program to r.target]?.let { "%.2f".format(it) } ?: "-" })
        val means = columns.map { target ->
            val values = ratios.filterKeys { it.second == target }.values
            if (values.isEmpty()) "-" else "%.3f".format(exp(values.sumOf { ln(it) } / values.size))
        }
        println(row(listOf("geomean") + means, widths(results, columns)))
    }

    private fun widths(results: List<BenchResult>, columns: List<String>): List<Int> =
        listOf(maxOf(PROGRAM_WIDTH, results.maxOfOrNull { it.program.length } ?: 0)) + columns.map { CELL_WIDTH }

    private fun table(results: List<BenchResult>, columns: List<String>, cell: (BenchResult) -> String): String {
        val widths = widths(results, columns)
        val byProgram = results.groupBy { it.program }
        return buildString {
            appendLine(row(listOf("program") + columns, widths))
            appendLine(widths.joinToString("  ") { "-".repeat(it) })
            for ((program, cells) in byProgram) {
                appendLine(row(listOf(program) + columns.map { c -> cells.firstOrNull { it.target == c }?.let(cell) ?: "-" }, widths))
            }
        }.trimEnd()
    }

    private fun row(cells: List<String>, widths: List<Int>) =
        cells.mapIndexed { i, c -> if (i == 0) c.padEnd(widths[i]) else c.padStart(widths[i]) }.joinToString("  ")

    private fun toJson(results: List<BenchResult>): JsonObject = buildJsonObject {
        put("created", Instant.now().truncatedTo(ChronoUnit.SECONDS).toString())
        put("runs", config.runs)
        putJsonObject("host") {
            put("os", "${System.getProperty("os.name")} ${System.getProperty("os.arch")}")
            put("cpus", Runtime.getRuntime().availableProcessors())
            putJsonObject("interpreters") { targets.forEach { put(it.target.id, it.version) } }
        }
        putJsonArray("results") {
            for (r in results) {
                add(
                    buildJsonObject {
                        put("program", r.program)
                        put("target", r.target)
                        if (r.ok) {
                            put("medianMs", round(r.medianMs))
                            put("minMs", round(r.minMs))
                            put("timesMs", buildJsonArray { r.timesMs.forEach { add(round(it)) } })
                        } else {
                            put("error", r.error)
                        }
                    },
                )
            }
        }
    }

    private fun round(ms: Double) = Math.round(ms * TENTHS) / TENTHS

    companion object {
        private const val PROGRAM_WIDTH = 7
        private const val CELL_WIDTH = 12
        private const val TENTHS = 10.0
        private const val ERROR_TEXT = 300

        /** The median of each (program, target) in a `results.json` or baseline file. */
        fun readResults(file: File): Map<Pair<String, String>, Double> =
            Json.parseToJsonElement(file.readText()).jsonObject["results"]!!.jsonArray.mapNotNull { element ->
                val o = element.jsonObject
                val median = (o["medianMs"] as? JsonPrimitive)?.double ?: return@mapNotNull null
                (o["program"]!!.jsonPrimitive.content to o["target"]!!.jsonPrimitive.content) to median
            }.toMap()
    }
}
