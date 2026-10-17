fun main() {
    val a = 0b1100
    val b = 0b1010
    println(a and b)
    println(a or b)
    println(a xor b)
    println(a.inv())
    println(1 shl 4)
    println(-16 shr 2)
    println(-16 ushr 28)
    println(-1 and 255)
    println(0x7FFFFFFF shl 1)
    val flags = listOf(1, 2, 4, 8)
    println(flags.fold(0) { acc, f -> acc or f })
    println((5 and 1) == 1)
}
