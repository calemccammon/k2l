// java.lang.Character's surrogate and code point statics, which need UTF-16 code units (this case runs with --strings utf16),
// and StringBuilder.repeat of a code point beyond the BMP
fun main() {
    val text = "a😀b"
    val cp = 0x1F600
    println(listOf(Character.highSurrogate(cp).code, Character.lowSurrogate(cp).code))
    println(Character.toChars(cp).concatToString() == "😀")
    println(listOf(Character.isSurrogatePair('\uD83D', '\uDE00'), Character.isSurrogatePair('a', '\uDE00'), Character.isSurrogatePair('\uDE00', '\uD83D')))
    println(listOf(Character.codePointAt(text, 1), Character.codePointAt(text, 2), Character.codePointAt(text, 0)))
    println(listOf(Character.codePointBefore(text, 3), Character.codePointBefore(text, 1)))
    println(listOf(Character.codePointCount(text, 0, text.length), Character.offsetByCodePoints(text, 0, 2)))
    println(listOf(Character.reverseBytes('Ă').code, Character.reverseBytes('A').code))
    println(listOf(Character.isISOControl(0x85), Character.isISOControl(0x41), Character.isISOControl('\u0000')))
    val sb = StringBuilder("x")
    sb.repeat(cp, 2)
    sb.repeat("é", 2)
    println("$sb ${sb.length}")
}
