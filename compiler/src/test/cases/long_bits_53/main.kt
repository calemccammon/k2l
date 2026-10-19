// Long bitwise operations stay exact for values below 2^53 on every target (where a Long is a double they work on
// 32-bit halves), and println writes strings with NUL characters whole (Lua 5.1's print stops at them).

fun unsigned(x: Int): Long = x.toLong() and 0xFFFFFFFFL

fun main() {
    println("${unsigned(-1)} ${unsigned(-2)} ${unsigned(123)} ${unsigned(Int.MIN_VALUE)}")
    val big = (1L shl 40) or (1L shl 3)
    println("$big ${big and (1L shl 40)} ${big xor 8L} ${big.inv()} ${(-big).inv()}")
    println("${-1L and 0xFF_FFFF_FFFFL} ${-256L or 0xFFL} ${0x1234_5678_9ABCL xor 0xFFFF_FFFF_FFFFL}")
    println("${(1L shl 52) shr 50} ${-(1L shl 45) shr 40} ${-1L ushr 12} ${-4096L ushr 40} ${(1L shl 35) ushr 3} ${-8L ushr 0}")
    val masks = (30..36).map { (1L shl it) - 1 }
    println(masks.map { it.countOneBits() })
    var h = 0L
    for (c in "hash me") h = (h * 31 + c.code) and 0xFFFF_FFFFL
    println("hash $h ${h.toString(16)}")
    val bitboard = (0 until 48 step 5).fold(0L) { acc, i -> acc or (1L shl i) }
    println("board $bitboard set=${(0 until 48).filter { bitboard shr it and 1L == 1L }}")
    println("nul:\u0000:end ${'\u0000'.code}")
    println("${"a\u0000b".length} [${"x\u0000y"}]")
}
