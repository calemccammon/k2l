// Adapted from realworld_text_formatter and realworld_text_markdown: rendering tables, word-wrapped paragraphs and
// a small markdown-to-HTML converter with StringBuilder, string templates, padStart/padEnd, repeat and joinToString.

const val SIZE = 1600 // documents

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

val WORDS = listOf(
    "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do", "eiusmod", "tempor",
    "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim", "ad", "minim", "veniam", "quis",
)

fun hash(s: String): Int {
    var h = 0
    for (c in s) h = (h * 31 + c.code) % 1_000_003
    return h
}

fun table(header: List<String>, rows: List<List<String>>): String {
    val widths = header.indices.map { i -> maxOf(header[i].length, rows.maxOf { it[i].length }) }
    val sb = StringBuilder()
    fun line(cells: List<String>) {
        sb.append('|')
        for (i in cells.indices) {
            val cell = cells[i]
            sb.append(' ').append(if (i == 0) cell.padEnd(widths[i]) else cell.padStart(widths[i])).append(" |")
        }
        sb.append('\n')
    }
    line(header)
    sb.append('|').append(widths.joinToString("|") { "-".repeat(it + 2) }).append("|\n")
    rows.forEach(::line)
    return sb.toString()
}

fun wrap(words: List<String>, width: Int): String {
    val out = StringBuilder()
    var lineLength = 0
    for (w in words) {
        if (lineLength > 0 && lineLength + 1 + w.length > width) {
            out.append('\n')
            lineLength = 0
        }
        if (lineLength > 0) {
            out.append(' ')
            lineLength++
        }
        out.append(w)
        lineLength += w.length
    }
    return out.toString()
}

fun inline(text: String): String {
    val sb = StringBuilder()
    var bold = false
    var code = false
    var i = 0
    while (i < text.length) {
        val c = text[i]
        when {
            c == '*' && i + 1 < text.length && text[i + 1] == '*' -> {
                sb.append(if (bold) "</b>" else "<b>")
                bold = !bold
                i++
            }
            c == '`' -> {
                sb.append(if (code) "</code>" else "<code>")
                code = !code
            }
            c == '<' -> sb.append("&lt;")
            c == '&' -> sb.append("&amp;")
            else -> sb.append(c)
        }
        i++
    }
    return sb.toString()
}

fun markdown(lines: List<String>): String = buildString {
    var inList = false
    for (line in lines) {
        if (line.startsWith("- ")) {
            if (!inList) append("<ul>\n")
            inList = true
            append("  <li>").append(inline(line.substring(2))).append("</li>\n")
            continue
        }
        if (inList) append("</ul>\n")
        inList = false
        when {
            line.startsWith("## ") -> append("<h2>${inline(line.removePrefix("## "))}</h2>\n")
            line.startsWith("# ") -> append("<h1>${inline(line.removePrefix("# "))}</h1>\n")
            line.isBlank() -> append('\n')
            else -> append("<p>").append(inline(line)).append("</p>\n")
        }
    }
    if (inList) append("</ul>\n")
}

fun main() {
    val rng = Lcg(5)
    var total = 0L
    var checksum = 0L
    for (doc in 0 until SIZE) {
        val words = List(60 + rng.next(60)) { WORDS[rng.next(WORDS.size)] }
        val rows = List(8) { r -> listOf("item-$doc-$r", "${rng.next(1000)}", "${rng.next(100)}.${rng.next(10)}", WORDS[rng.next(WORDS.size)]) }
        val md = mutableListOf("# Report $doc", "")
        md += words.chunked(12).map { chunk -> chunk.mapIndexed { i, w -> if (i % 5 == 0) "**$w**" else if (i % 7 == 0) "`$w<$i>`" else w }.joinToString(" ") }
        md += "## Items"
        md += rows.map { "- ${it[0]} costs ${it[1]} & weighs ${it[2]}" }
        val text = table(listOf("name", "price", "weight", "tag"), rows) + wrap(words, 40) + markdown(md)
        total += text.length
        checksum = (checksum * 7 + hash(text)) % 1_000_000_007
    }
    println("rendered $total chars, checksum $checksum")
}
