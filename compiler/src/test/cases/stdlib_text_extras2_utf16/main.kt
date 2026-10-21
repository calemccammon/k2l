// CharSequence extras on non-ASCII text with UTF-16 indices (--strings utf16)
fun main() {
    val text = "été 😀 naïve été"
    println(text.findAnyOf(listOf("naïve", "😀")))
    println(text.findLastAnyOf(listOf("été")))
    println(text.findAnyOf(listOf("ÉTÉ"), 1, ignoreCase = true))
    println(text.lastIndexOfAny(charArrayOf('é', 'ï')))
    println(text.lastIndexOfAny(listOf("😀")))
    println(text.map { it.code }.size)
    println(listOf(text.hasSurrogatePairAt(4), text.hasSurrogatePairAt(5), text.hasSurrogatePairAt(0)))
    println("äöü".filterTo(StringBuilder()) { it != 'ö' })
    println("äöü".reduceRightIndexed { i, c, acc -> if (i == 1) c else acc })
    val seen = StringBuilder()
    "日本".onEachIndexed { i, c -> seen.append(i).append(c) }
    println(seen)
    println("  ñ\n    ö".replaceIndent("» "))
    println("x|ñ\n |ö".replaceIndentByMargin("· "))
}
