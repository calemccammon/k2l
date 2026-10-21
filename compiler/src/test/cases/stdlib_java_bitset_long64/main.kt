import java.util.BitSet

// java.util.BitSet's 64-bit words with --long64 emulate: toLongArray and valueOf with the high bits set
fun bits(vararg indexes: Int): BitSet {
    val set = BitSet()
    for (i in indexes) set.set(i)
    return set
}

fun main() {
    println(bits(0, 63, 64, 130).toLongArray().toList())
    println(bits(31, 32, 62, 63).toLongArray().toList())
    println(BitSet().apply { set(0, 128) }.toLongArray().toList())
    println(BitSet.valueOf(longArrayOf(-1L, Long.MIN_VALUE, 0L)).let { "${it.cardinality()} ${it.length()} ${it.size()} ${it.hashCode()}" })
    println(BitSet.valueOf(longArrayOf(Long.MAX_VALUE)).let { "${it.cardinality()} ${it.nextClearBit(0)} ${it.previousSetBit(100)}" })
    println(BitSet.valueOf(longArrayOf(0x123456789ABCDEFL, -0x123456789ABCDEFL)))
    val words = longArrayOf(-2L, 0x7FFF_0000_FFFF_0000L, 1L shl 63)
    println(BitSet.valueOf(words).toLongArray().contentEquals(words))
    println(BitSet.valueOf(words).toByteArray().toList())
}
