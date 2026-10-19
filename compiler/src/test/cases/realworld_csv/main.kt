import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sqrt

// A small sales report: parse CSV with quoted fields, validate rows, then group, aggregate,
// sort with multi-key comparators and print aligned tables.

enum class Region(val label: String, val taxRate: Double) {
    NORTH("North", 0.07), SOUTH("South", 0.05), EAST("East", 0.0825), WEST("West", 0.06);

    companion object {
        private val byLabel = entries.associateBy { it.label.lowercase() }
        fun parse(s: String): Region = byLabel[s.trim().lowercase()] ?: throw IllegalArgumentException("unknown region '$s'")
    }
}

data class Sale(
    val id: Int,
    val date: String,
    val rep: String,
    val region: Region,
    val product: String,
    val units: Int,
    val unitPrice: Double,
) {
    val revenue get() = units * unitPrice
    val month get() = date.substring(0, 7)
}

const val RAW = """id,date,rep,region,product,units,unit_price
1,2024-01-05,"Smith, Anna",North,Widget,12,2.50
2,2024-01-09,Bob Jones,South,Gadget,3,19.99
3,2024-01-17,"Smith, Anna",North,Gizmo,7,7.25
4,2024-02-02,Carla Diaz,East,Widget,40,2.45
5,2024-02-11,Bob Jones,South,Widget,15,2.50
6,2024-02-14,"O""Brien, Pat",West,Gadget,2,21.00
7,2024-02-28,Carla Diaz,East,Gizmo,9,7.00
8,2024-03-03,"Smith, Anna",North,Gadget,5,19.50
9,2024-03-15,Dev Patel,West,Widget,-4,2.50
10,2024-03-19,Dev Patel,Weast,Gizmo,4,7.10
11,2024-03-21,Bob Jones,South,Gizmo,11,6.95
12,2024-03-30,"O""Brien, Pat",West,Widget,25,2.40
13,2024-03-31,Carla Diaz,East,Gadget,6,
"""

fun parseCsvLine(line: String): List<String> {
    val fields = mutableListOf<String>()
    val current = StringBuilder()
    var inQuotes = false
    var i = 0
    while (i < line.length) {
        val c = line[i]
        when {
            inQuotes && c == '"' && i + 1 < line.length && line[i + 1] == '"' -> {
                current.append('"')
                i++
            }
            c == '"' -> inQuotes = !inQuotes
            c == ',' && !inQuotes -> {
                fields += current.toString()
                current.setLength(0)
            }
            else -> current.append(c)
        }
        i++
    }
    fields += current.toString()
    return fields
}

sealed class RowResult {
    data class Ok(val sale: Sale) : RowResult()
    data class Bad(val line: Int, val reason: String) : RowResult()
}

fun parseRow(lineNo: Int, header: List<String>, line: String): RowResult = try {
    val cols = header.zip(parseCsvLine(line)).toMap()
    fun col(name: String) = cols[name]?.takeIf { it.isNotBlank() } ?: throw IllegalArgumentException("missing $name")
    val units = col("units").toInt()
    require(units > 0) { "units must be positive, was $units" }
    RowResult.Ok(
        Sale(
            id = col("id").toInt(),
            date = col("date"),
            rep = col("rep"),
            region = Region.parse(col("region")),
            product = col("product"),
            units = units,
            unitPrice = col("unit_price").toDouble(),
        ),
    )
} catch (e: IllegalArgumentException) {
    RowResult.Bad(lineNo, e.message ?: e.toString())
}

data class Stats(val count: Int, val mean: Double, val median: Double, val stdDev: Double, val min: Double, val max: Double)

fun List<Double>.stats(): Stats {
    require(isNotEmpty()) { "no data" }
    val sorted = sorted()
    val mean = average()
    val median = if (size % 2 == 1) sorted[size / 2] else (sorted[size / 2 - 1] + sorted[size / 2]) / 2
    val variance = sumOf { (it - mean).pow(2) } / size
    return Stats(size, mean, median, sqrt(variance), sorted.first(), sorted.last())
}

fun money(x: Double) = "$" + String.format("%,.2f", x)

fun table(headers: List<String>, rows: List<List<String>>, rightAlign: Set<Int> = emptySet()): String {
    val widths = headers.indices.map { c -> maxOf(headers[c].length, rows.maxOfOrNull { it[c].length } ?: 0) }
    fun fmt(cells: List<String>) = cells.mapIndexed { c, s -> if (c in rightAlign) s.padStart(widths[c]) else s.padEnd(widths[c]) }
        .joinToString(" | ", "| ", " |")
    val sep = widths.joinToString("-+-", "+-", "-+") { "-".repeat(it) }
    return (listOf(sep, fmt(headers), sep) + rows.map(::fmt) + sep).joinToString("\n")
}

fun main() {
    val lines = RAW.lines().filter { it.isNotBlank() }
    val header = parseCsvLine(lines.first())
    val results = lines.drop(1).mapIndexed { i, line -> parseRow(i + 2, header, line) }
    val (good, bad) = results.partition { it is RowResult.Ok }
    val sales = good.map { (it as RowResult.Ok).sale }
    println("parsed ${sales.size} sales, ${bad.size} rejected")
    bad.filterIsInstance<RowResult.Bad>().forEach { println("  line ${it.line}: ${it.reason}") }

    println("\nBy rep:")
    val byRep = sales.groupBy { it.rep }
    val repRows = byRep.map { (rep, list) ->
        Triple(rep, list.sumOf { it.units }, list.sumOf { it.revenue })
    }.sortedWith(compareByDescending<Triple<String, Int, Double>> { it.third }.thenBy { it.first })
    println(
        table(
            listOf("Rep", "Units", "Revenue"),
            repRows.map { (rep, units, rev) -> listOf(rep, units.toString(), money(rev)) },
            rightAlign = setOf(1, 2),
        ),
    )

    println("\nMonthly revenue by region:")
    val months = sales.map { it.month }.distinct().sorted()
    val pivot: Map<Region, Map<String, Double>> = sales.groupingBy { it.region }
        .fold(emptyMap()) { acc, s -> acc + (s.month to (acc[s.month] ?: 0.0) + s.revenue) }
    val pivotRows = Region.entries.filter { it in pivot }.map { r ->
        listOf(r.label) + months.map { m -> pivot.getValue(r)[m]?.let { String.format("%.2f", it) } ?: "-" }
    }
    println(table(listOf("Region") + months, pivotRows, rightAlign = (1..months.size).toSet()))

    println("\nTax owed:")
    sales.groupBy(Sale::region)
        .mapValues { (region, list) -> list.sumOf { it.revenue } * region.taxRate }
        .entries
        .sortedByDescending { it.value }
        .forEach { (region, tax) -> println("  ${region.name.padEnd(6, '.')}${money(tax).padStart(9)} (${"%.2f".format(region.taxRate * 100)}%)") }

    val prices = sales.map { it.unitPrice }
    val st = prices.stats()
    println("\nUnit price stats: n=${st.count} mean=${"%.3f".format(st.mean)} median=${st.median} sd=${"%.4f".format(st.stdDev)} range=${st.min}..${st.max}")
    val revenues = sales.map(Sale::revenue)
    println("Revenue stats: ${revenues.stats().let { "mean=%.2f median=%.2f max=%.2f".format(it.mean, it.median, it.max) }}")

    val best = sales.maxBy { it.revenue }
    val (id, date, rep) = best
    println("\nBest sale: #$id on $date by $rep (${money(best.revenue)})")
    val productShare = sales.groupBy { it.product }.mapValues { (_, v) -> v.sumOf { it.revenue } }
    val totalRevenue = productShare.values.sum()
    productShare.toList().sortedBy { it.first }.forEach { (product, rev) ->
        val pct = rev / totalRevenue * 100
        val bar = "#".repeat((pct / 4).roundToInt())
        println("  %-7s %6.1f%% %s".format(product, pct, bar))
    }
    val repsByRegion = sales.associate { it.rep to it.region }.entries.groupBy({ it.value }, { it.key })
    println("reps by region: $repsByRegion")
    val firstSaleOfMonth = sales.associateBy { it.month }.mapValues { it.value.id }
    println("last sale id per month: $firstSaleOfMonth")
    println("running units: ${sales.sortedBy { it.date }.runningFold(0) { acc, s -> acc + s.units }.drop(1)}")
    val discounted = sales.first().copy(unitPrice = 2.0, units = 100)
    println("copy: $discounted revenue=${discounted.revenue}")
    println("big orders: ${sales.filter { it.units >= 10 }.map { "${it.id}:${it.units}" }}")
}
