// A text formatter: word wrapping, full justification, centered titles, multi-column layout,
// aligned tables with padStart/padEnd, and a report full of String.format widths, precisions and flags.

fun wrap(text: String, width: Int): List<String> {
    val lines = mutableListOf<String>()
    val line = StringBuilder()
    for (word in text.split(Regex("\\s+")).filter { it.isNotBlank() }) {
        if (line.isNotEmpty() && line.length + 1 + word.length > width) {
            lines += line.toString()
            line.setLength(0)
        }
        if (line.isNotEmpty()) line.append(' ')
        line.append(word)
    }
    if (line.isNotEmpty()) lines += line.toString()
    return lines
}

fun justify(line: String, width: Int): String {
    val words = line.split(' ')
    if (words.size == 1) return line.padEnd(width)
    val gaps = words.size - 1
    val spaces = width - words.sumOf { it.length }
    val each = spaces / gaps
    val extra = spaces % gaps
    return buildString {
        words.forEachIndexed { i, w ->
            append(w)
            if (i < gaps) append(" ".repeat(each + if (i < extra) 1 else 0))
        }
    }
}

fun center(s: String, width: Int, fill: Char = ' '): String {
    if (s.length >= width) return s
    val left = (width - s.length) / 2
    return s.padStart(s.length + left, fill).padEnd(width, fill)
}

fun columns(items: List<String>, cols: Int, gutter: Int = 2): String {
    val rows = (items.size + cols - 1) / cols
    val widths = (0 until cols).map { c -> (0 until rows).mapNotNull { r -> items.getOrNull(c * rows + r) }.maxOfOrNull { it.length } ?: 0 }
    return (0 until rows).joinToString("\n") { r ->
        (0 until cols).mapNotNull { c -> items.getOrNull(c * rows + r)?.padEnd(widths[c]) }
            .joinToString(" ".repeat(gutter)).trimEnd()
    }
}

enum class Align { LEFT, RIGHT, CENTER }

class Table(private val headers: List<String>, private val aligns: List<Align>) {
    private val rows = mutableListOf<List<String>>()
    fun add(vararg cells: Any?) {
        rows += cells.map { it?.toString() ?: "-" }
    }

    fun render(): String {
        val widths = headers.indices.map { i -> (rows.map { it[i] } + headers[i]).maxOf { it.length } }
        fun cell(s: String, i: Int) = when (aligns[i]) {
            Align.LEFT -> s.padEnd(widths[i])
            Align.RIGHT -> s.padStart(widths[i])
            Align.CENTER -> center(s, widths[i])
        }
        val sep = widths.joinToString("+", "+", "+") { "-".repeat(it + 2) }
        val sb = StringBuilder(sep).append('\n')
        sb.append(headers.mapIndexed { i, h -> " " + center(h, widths[i]) + " " }.joinToString("|", "|", "|")).append('\n')
        sb.append(sep.replace('-', '=')).append('\n')
        for (r in rows) sb.append(r.mapIndexed { i, c -> " " + cell(c, i) + " " }.joinToString("|", "|", "|")).append('\n')
        sb.append(sep)
        return sb.toString()
    }
}

const val LOREM = """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
ullamco laboris nisi ut aliquip ex ea commodo consequat."""

fun formatSamples() {
    val ints = listOf(0, 7, -7, 42, 1234567, -98765, Int.MAX_VALUE, Int.MIN_VALUE)
    for (n in ints) {
        println(String.format("[%d] [%5d] [%-6d] [%05d] [%+d] [%,d] [% d] [%x] [%X] [%o] [%#x] [%#o]",
            n, n, n, n, n, n, n, n, n, n, n, n))
    }
    val longs = listOf(0L, 9_007_199_254_740_991L, -1L, -4_503_599_627_370_496L, Long.MIN_VALUE, 255L)
    for (n in longs) println("%d %,d %x %X %o %20d|%-20d|".format(n, n, n, n, n, n, n))

    val doubles = listOf(0.0, -0.0, 0.126, 2.675, 1.005, 3.14159265358979, -1234.5678, 1e-7, 6.02214076e23, 999.9999, 0.6, 1.6, 2.6)
    for (d in doubles) {
        println(String.format("%f|%.2f|%10.3f|%-10.1f|%+.0f|%e|%.3E|%g|%,.2f|%08.2f",
            d, d, d, d, d, d, d, d, d, d))
    }
    // values halfway between two outputs are avoided: LuaJIT builds round them differently
    println(String.format("%.0f %.0f %.0f %.0f %.1f %.1f", 0.4, 1.6, 2.7, -0.4, 0.06, 0.16))
    println(String.format("%s %S %10s %-10s| %.3s %10.2s|", "text", "text", "right", "left", "truncate", "ab"))
    println(String.format("%c %c %3c %-3c| %b %B %5b %b", 'x', 65, 'y', 'z', true, false, null, "nonnull"))
    println(String.format("%%d means decimal; 100%% done%nnext line"))
    println(String.format("[%10.4f] [%-12.6e] [%.10f]", Math.PI, Math.E, 1.0 / 3))
    println(String.format("%,d bytes = %,.1f KiB = %.2f MiB", 123456789, 123456789 / 1024.0, 123456789 / 1048576.0))
    println(String.format("%s", listOf(1, 2, 3)) + String.format(" %s", mapOf("k" to 1.5)) + String.format(" %s", null as String?))
    println(String.format("%x %x %o", -1, -255, -8))
    println(String.format("%08X %#010x %+,d", 0xBEEF, 0xBEEF, 1000000))
    println(String.format("%.3g %.3g %.3g %g %g", 0.0001234, 123456.0, 1.0, 0.0, 100000.0))
}

fun main() {
    val lines = wrap(LOREM, 40)
    println(center(" Wrapped (40) ", 44, '*'))
    lines.forEach { println("|" + it.padEnd(40) + "|") }
    println(center(" Justified ", 44, '~'))
    lines.dropLast(1).forEach { println("|" + justify(it, 40) + "|") }
    println("|" + lines.last().padEnd(40) + "|")
    println(center("x", 7, '.') + center("odd", 8, '_') + center("toolongforit", 4))

    val words = LOREM.split(Regex("[^A-Za-z]+")).filter { it.length > 3 }.map { it.lowercase() }.distinct().sorted()
    println(columns(words, 4))
    println()

    val t = Table(listOf("Item", "Qty", "Price", "Note"), listOf(Align.LEFT, Align.RIGHT, Align.RIGHT, Align.CENTER))
    t.add("Widget", 3, "%.2f".format(4.5), "ok")
    t.add("Gadget with a long name", 12, "%.2f".format(1234.5), null)
    t.add("Unicode", 1, "%.2f".format(0.1 + 0.2), "e")
    t.add("Nothing", 0, "%.2f".format(0.0), "")
    println(t.render())

    formatSamples()

    // a receipt with right-aligned money columns
    val items = listOf("coffee" to 3.5, "bagel" to 2.25, "orange juice" to 4.0, "tip" to 1.75)
    val total = items.sumOf { it.second }
    for ((name, price) in items) println(name.padEnd(20, '.') + "$%7.2f".format(price))
    println("-".repeat(28))
    println("TOTAL".padEnd(20) + "$%7.2f".format(total))
    println("tax 8.25%%: %.2f, grand total: %.2f".format(total * 0.0825, total * 1.0825))
}
