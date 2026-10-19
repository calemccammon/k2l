// Regex.matchAt/matchesAt (a match starting exactly at an index, as a tokenizer uses them), class intersection
// ([a-z&&[^aeiou]]) and the ASCII parts of \p{Z} and \p{IsWhite_Space}.

fun tokens(src: String): List<String> {
    val rules = listOf("num" to Regex("\\d+(\\.\\d+)?"), "id" to Regex("[A-Za-z_]\\w*"), "op" to Regex("[-+*/=()]"), "ws" to Regex("\\s+"))
    val out = mutableListOf<String>()
    var i = 0
    while (i < src.length) {
        val (kind, m) = rules.firstNotNullOfOrNull { (k, r) -> r.matchAt(src, i)?.let { k to it } }
            ?: run {
                out += "error@$i"
                i++
                null
            } ?: continue
        if (kind != "ws") out += "$kind:${m.value}@${m.range.first}"
        i = m.range.last + 1
    }
    return out
}

fun main() {
    println(tokens("x1 = 3.25*(y+42) / z_9 ? 7"))
    val word = Regex("\\w+")
    val text = "hello world"
    println(listOf(0, 1, 5, 6, 11).map { word.matchAt(text, it)?.value })
    println(listOf(0, 5, 6, 11).map { word.matchesAt(text, it) })
    println(Regex("(?<=o)r").matchAt("world", 2)?.range.toString() + " " + Regex("^w").matchAt("a world", 2) + " " + Regex("\\bw").matchesAt("a world", 2))
    for (bad in listOf(-1, 12)) {
        try {
            word.matchAt(text, bad)
        } catch (e: IndexOutOfBoundsException) {
            println("matchAt($bad): ${e::class.simpleName}")
        }
    }

    println(Regex("[a-z&&[^aeiou]]+").findAll("programming language").map { it.value }.toList())
    println(Regex("[\\w&&\\D]+").findAll("abc123def_45").map { it.value }.toList())
    println(Regex("[a-m&&h-z]").findAll("abcdefghijklmnopqrstuvwxyz").joinToString("") { it.value })
    println("Hello World".replace(Regex("[A-Z&&[^H]]"), "#") + " " + Regex("[0-9&&[^5]]{2}").findAll("12345567").map { it.value }.toList())
    println(Regex("\\p{Z}").findAll("a b\tc").count().toString() + " " + Regex("\\p{IsWhite_Space}").findAll("a b\tc\nd").count() + " " +
        Regex("\\p{javaWhitespace}+").split("a \t b\u001Fc"))
}
