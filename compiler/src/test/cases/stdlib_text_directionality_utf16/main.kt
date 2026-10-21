// Char.directionality of Unicode characters (--strings utf16)
fun main() {
    for (c in "aא١٣̀‎‪‮‬  €￿") {
        println("U+${c.code.toString(16).padStart(4, '0')} ${c.directionality} ${c.directionality.value}")
    }
    println((0x590 until 0x700).map { it.toChar() }.groupingBy { it.directionality }.eachCount())
}
