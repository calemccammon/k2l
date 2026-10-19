// Surrogate halves and regexes: empty matches stop at every UTF-16 unit boundary, even between the halves of a pair
fun mark(s: String): String = s.map {
    when {
        it.isHighSurrogate() -> "<H>"
        it.isLowSurrogate() -> "<L>"
        else -> it.toString()
    }
}.joinToString("")

fun show(pattern: String, s: String) {
    val regex = Regex(pattern)
    val ranges = regex.findAll(s).map { "[${it.range.first},${it.range.last + 1}]" }.joinToString("")
    println("'$pattern' on ${mark(s)} (${s.length}): $ranges replace=${mark(regex.replace(s, "-"))} split=${regex.split(s).map { mark(it) }}")
}

fun main() {
    val smile = "a😀b"
    show("", smile)
    show("x*", smile)
    show("a*", smile)
    show(".?", smile)
    show("\\b", smile)
    show("(?=b)", smile)
    show("^", smile)
    show("$", smile)
    show("", "😀")
    show("", "\uDE00\uD83D")
    show("", "\uD83Dx")
    show("x*", "😀😀")
    show("(?s).*?", "😀")
    show("\\x{1F600}*", smile)
    show("[\\x{1F600}]", smile)
    show(".", smile)
    show("(?<=a)", smile)
    show("(?<!a)", smile)
    show("", "")
    show("x*", "ab")

    // the String functions on the same text
    println("a,b".split("").map { mark(it) })
    println(smile.split("").map { mark(it) })
    println(mark(smile.replace("", "-")))
    println(smile.indexOf("") + smile.lastIndexOf("") + smile.indexOf("", 2))
}
