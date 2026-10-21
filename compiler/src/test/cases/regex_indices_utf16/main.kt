// Match indices count UTF-16 units: many matches in a long text with 2-, 3- and 4-byte characters (each index is a
// lookup, not a scan of the text), and the edge cases of the conversion
fun checksum(text: String, pattern: String): String {
    var sum = 0L
    var count = 0
    for (m in Regex(pattern).findAll(text)) {
        sum = (sum * 31 + m.range.first * 7 + m.range.last) % 1_000_000_007
        for (g in m.groups.drop(1)) {
            if (g != null) sum = (sum * 31 + g.range.first + g.range.last * 3) % 1_000_000_007
        }
        count++
    }
    return "$count $sum"
}

fun main() {
    val sb = StringBuilder()
    for (i in 0 until 6000) {
        sb.append(listOf("é", "😀", "中", "a")[i % 4]).append("w").append(i % 10)
        if (i % 7 == 0) sb.append("ß😀")
        sb.append(' ')
    }
    val text = sb.toString()
    println(text.length)
    println(checksum(text, "w(\\d)"))
    println(checksum(text, "(😀)|(中)w(\\d)"))
    println(checksum(text, "\\s"))

    // find from an index, matchAt and the ranges they give, walking the text
    var at = 0
    var steps = 0
    var last = -1
    while (true) {
        val m = Regex("\\d+").find(text, at) ?: break
        if (Regex("\\d").matchAt(text, m.range.first) == null) println("no matchAt at ${m.range.first}")
        last = m.range.last
        at = m.range.last + 1
        steps++
    }
    println("$steps $last")

    // empty matches, including between the halves of a pair, and lone surrogates
    for (s in listOf("😀é😀", "\uD83Dx\uDE00", "a\uDE00\uD83Db", "")) {
        println(Regex("").findAll(s).map { it.range.first }.toList())
        println(Regex(".").findAll(s).map { "${it.range}" }.toList())
    }
    for (i in 0..5) {
        val m = Regex("[a-z😀]").find("é😀ab😀", i)
        println("$i -> ${m?.range} ${m?.value}")
    }
}
