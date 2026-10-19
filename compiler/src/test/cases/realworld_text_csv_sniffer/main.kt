// A CSV dialect sniffer and reader: guesses the delimiter, quote character and header row from a sample,
// parses quoted fields with embedded delimiters, doubled quotes and newlines, infers column types, and
// writes the data back out in a normalized dialect.

data class Dialect(val delimiter: Char, val quote: Char, val hasHeader: Boolean) {
    override fun toString() = "Dialect(delimiter=${printable(delimiter)}, quote=${printable(quote)}, header=$hasHeader)"
}

fun printable(c: Char) = when (c) {
    '\t' -> "\\t"
    ' ' -> "' '"
    else -> "'$c'"
}

fun splitRecords(text: String, d: Char, q: Char): List<List<String>> {
    val records = mutableListOf<List<String>>()
    var fields = mutableListOf<String>()
    val field = StringBuilder()
    var inQuotes = false
    var i = 0
    while (i < text.length) {
        val c = text[i]
        if (inQuotes) {
            if (c == q) {
                if (i + 1 < text.length && text[i + 1] == q) {
                    field.append(q)
                    i++
                } else {
                    inQuotes = false
                }
            } else {
                field.append(c)
            }
        } else {
            when (c) {
                q -> inQuotes = true
                d -> { fields.add(field.toString()); field.clear() }
                '\r' -> {}
                '\n' -> {
                    fields.add(field.toString()); field.clear()
                    records += fields
                    fields = mutableListOf()
                }
                else -> field.append(c)
            }
        }
        i++
    }
    if (field.isNotEmpty() || fields.isNotEmpty()) {
        fields.add(field.toString())
        records += fields
    }
    return records
}

fun sniff(sample: String): Dialect {
    val candidates = listOf(',', ';', '\t', '|', ':')
    val quote = listOf('"', '\'').maxBy { q -> Regex("${Regex.escape(q.toString())}[^\\n]*?${Regex.escape(q.toString())}").findAll(sample).count() }
    // the delimiter giving the most consistent, non-trivial field counts wins
    val best = candidates.map { d ->
        val counts = splitRecords(sample, d, quote).filter { it.any(String::isNotBlank) }.map { it.size }
        val mode = counts.groupingBy { it }.eachCount().maxByOrNull { it.value }
        val score = if (mode == null || mode.key < 2) 0.0 else mode.value.toDouble() / counts.size * mode.key.coerceAtMost(10)
        d to score
    }.maxBy { it.second }.first
    val rows = splitRecords(sample, best, quote).filter { it.size > 1 }
    val header = rows.firstOrNull().orEmpty()
    val body = rows.drop(1)
    // a header has no numeric cells where the body has mostly numeric ones
    val hasHeader = header.indices.any { col ->
        val numericBody = body.count { r -> r.getOrNull(col)?.trim()?.toDoubleOrNull() != null }
        header[col].trim().toDoubleOrNull() == null && numericBody * 2 > body.size
    } || (header.isNotEmpty() && header.distinct().size == header.size && header.all { h -> h.isNotBlank() && h.first().isLetter() } &&
        body.any { r -> r.zip(header).any { (cell, h) -> cell.length > h.length * 2 } })
    return Dialect(best, quote, hasHeader)
}

enum class ColType { INT, DECIMAL, BOOL, DATE, TEXT, EMPTY }

private val DATE = Regex("""\d{4}-\d{2}-\d{2}""")

fun typeOf(cell: String): ColType {
    val t = cell.trim()
    return when {
        t.isEmpty() -> ColType.EMPTY
        t.toLongOrNull() != null -> ColType.INT
        t.replace(",", "").toDoubleOrNull() != null && t.any { it == '.' || it == 'e' } -> ColType.DECIMAL
        t.lowercase() in setOf("true", "false", "yes", "no") -> ColType.BOOL
        DATE.matches(t) -> ColType.DATE
        else -> ColType.TEXT
    }
}

fun columnType(cells: List<String>): ColType {
    val types = cells.map(::typeOf).filter { it != ColType.EMPTY }.toSet()
    return when {
        types.isEmpty() -> ColType.EMPTY
        types.size == 1 -> types.single()
        types == setOf(ColType.INT, ColType.DECIMAL) -> ColType.DECIMAL
        else -> ColType.TEXT
    }
}

fun writeCsv(rows: List<List<String>>, d: Char = ',', q: Char = '"'): String = rows.joinToString("\n") { row ->
    row.joinToString(d.toString()) { f ->
        if (f.any { it == d || it == q || it == '\n' } || f != f.trim()) q + f.replace(q.toString(), "$q$q") + q else f
    }
}

val SAMPLES = mapOf(
    "semicolon" to """
        name;city;amount;paid;since
        "Müller; Hans";Zürich;1.234,50;yes;2019-03-01
        Smith;"New
        York";99.5;no;2020-11-30
        "O""Brien";Dublin;7;yes;
    """.trimIndent(),
    "tabs" to "id\tscore\tcomment\n1\t3.5\tgood\n2\t4\t\"tab\tinside\"\n3\t\t\n10\t2.25e1\tmeh",
    "pipes-noheader" to "1|2.5|x\n2|3.5|y\n3|4.5|z\n4|5.5|w",
    "single-quotes" to "'a,b',c,d\n'e',f,'g''h'\n'i','j',k",
    "comma" to """
        product,qty,price,discontinued,released
        "Widget, large",10,4.99,false,2021-01-15
        Gadget,3,12,true,2018-07-04
        "Gizmo ""Pro"" XL",,199.00,false,2023-12-24
        Thing,1,0.5,FALSE,2000-02-29
    """.trimIndent(),
)

fun main() {
    for ((name, text) in SAMPLES) {
        val dialect = sniff(text)
        val rows = splitRecords(text, dialect.delimiter, dialect.quote)
        println("== $name: $dialect, ${rows.size} rows")
        val header = if (dialect.hasHeader) rows.first() else rows.first().indices.map { "col${it + 1}" }
        val body = if (dialect.hasHeader) rows.drop(1) else rows
        val types = header.indices.map { c -> columnType(body.map { it.getOrElse(c) { "" } }) }
        println(header.zip(types).joinToString(" | ") { (h, t) -> "$h:${t.name.lowercase()}" })
        val widths = header.indices.map { c -> (body.map { it.getOrElse(c) { "" }.replace("\n", "⏎") } + header[c]).maxOf { it.length } }
        for (r in body) {
            println(header.indices.joinToString(" | ") { c ->
                val cell = r.getOrElse(c) { "" }.replace("\n", "⏎")
                if (types[c] == ColType.INT || types[c] == ColType.DECIMAL) cell.padStart(widths[c]) else cell.padEnd(widths[c])
            }.trimEnd())
        }
        val numeric = header.indices.filter { types[it] == ColType.INT || types[it] == ColType.DECIMAL }
        for (c in numeric) {
            val values = body.mapNotNull { it.getOrNull(c)?.trim()?.toDoubleOrNull() }
            println("  ${header[c]}: n=${values.size} sum=${"%.2f".format(values.sum())} min=${values.minOrNull()} max=${values.maxOrNull()}")
        }
        println(writeCsv(listOf(header) + body).lines().joinToString("\n") { "  > $it" })
    }
}
