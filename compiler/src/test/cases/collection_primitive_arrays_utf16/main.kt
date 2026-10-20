// Collections of UTF-16 chars to CharArray and back (--strings utf16).
fun main() {
    val chars: List<Char> = "a😀é".toList()
    println(chars.size)
    val ca = chars.toCharArray()
    println("${ca.size} ${ca.concatToString()} ${String(ca)}")
    println(ca.toList() == chars)
    println(setOf('é', 'ß').toCharArray().concatToString())
    println(arrayOf('ä', 'ö').toCharArray().concatToString())
    println("héllo".toList().sortedDescending().toCharArray().concatToString())
    println(ca.map { it.code })
    println(ca.toTypedArray().toCharArray().concatToString().length)
    println(ArrayDeque("ü€".toList()).toCharArray().joinToString("|"))
}
