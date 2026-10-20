// CharSequence values with --strings utf16: loops, length and s[i] count UTF-16 units, also of a StringBuilder and of a
// class of the program whose chars are surrogate halves.

class Pairs(private val pairs: Int) : CharSequence {
    override val length: Int get() = pairs * 2

    override fun get(index: Int): Char = "😀"[index % 2]

    override fun subSequence(startIndex: Int, endIndex: Int): CharSequence = Pairs((endIndex - startIndex) / 2)

    override fun toString(): String = "Pairs($pairs)"
}

fun units(s: CharSequence): String {
    val out = StringBuilder()
    for (c in s) out.append(c.code.toString(16)).append(' ')
    return out.toString().trim()
}

fun main() {
    val texts: List<CharSequence> = listOf("héllo", StringBuilder("ünï😀"), Pairs(2))
    for (t in texts) {
        println("${t.length} ${t.lastIndex} ${t[1]} ${t[t.lastIndex].code} [${units(t)}]")
        var n = 0
        for (i in t.indices) if (t[i].isSurrogate()) n++
        println("surrogates=$n text=$t upper=${t.toString().uppercase()} has=${t.contains("😀")}")
    }
    val sb = StringBuilder("añb")
    val cs: CharSequence = sb
    for ((i, c) in cs.withIndex()) print("$i=$c ")
    println()
}
