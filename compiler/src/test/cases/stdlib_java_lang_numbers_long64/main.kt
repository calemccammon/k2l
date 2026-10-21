import java.lang.Long as JLong

// The Long statics of java.lang.Long and Math with --long64 emulate: values beyond 2^53 and negative unsigned patterns
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    t("compareUnsigned") { listOf(JLong.compareUnsigned(-1L, 1L), JLong.compareUnsigned(Long.MIN_VALUE, Long.MAX_VALUE), JLong.compareUnsigned(1L, -2L)) }
    t("divideUnsigned") { listOf(JLong.divideUnsigned(-1L, 10L), JLong.divideUnsigned(-1L, -2L), JLong.remainderUnsigned(-1L, 10L)) }
    t("toUnsignedString") { listOf(JLong.toUnsignedString(-1L), JLong.toUnsignedString(Long.MIN_VALUE, 16), JLong.toUnsignedString(-2L, 2).length) }
    t("parseUnsignedLong") { listOf(JLong.parseUnsignedLong("18446744073709551615"), JLong.parseUnsignedLong("9223372036854775808"), JLong.parseUnsignedLong("ffffffffffffffff", 16)) }
    t("parseUnsignedLong range") { JLong.parseUnsignedLong("18446744073709551616") }
    t("parseUnsignedLong minus") { JLong.parseUnsignedLong("-1") }
    t("decode") { listOf(JLong.decode("0x7fffffffffffffff"), JLong.decode("-0x8000000000000000"), JLong.decode("-9223372036854775808"), JLong.decode("#123456789abcdef")) }
    t("decode range") { JLong.decode("0x8000000000000000") }
    t("reverse") { listOf(JLong.reverse(1L), JLong.reverse(-2L), JLong.reverse(0x123456789ABCDEFL)) }
    t("reverseBytes") { listOf(JLong.reverseBytes(1L), JLong.reverseBytes(0x123456789ABCDEFL), JLong.reverseBytes(-256L)) }
    t("compress") { listOf(JLong.compress(-1L, Long.MIN_VALUE or 1L), JLong.compress(0x123456789ABCDEFL, -0x100L), JLong.compress(Long.MIN_VALUE, Long.MIN_VALUE)) }
    t("expand") { listOf(JLong.expand(3L, Long.MIN_VALUE or 1L), JLong.expand(-1L, 0x00FF_0000_0000_FF00L), JLong.expand(0x5L, -0x10L)) }
    t("toUnsignedLong") { Integer.toUnsignedLong(-2) + 1L }

    t("ceilDiv") { listOf(Math.ceilDiv(Long.MAX_VALUE, 2L), Math.ceilDiv(Long.MIN_VALUE, 3L), Math.ceilDiv(Long.MIN_VALUE, -1L), Math.ceilDiv(-9007199254740993L, 2L)) }
    t("ceilMod") { listOf(Math.ceilMod(Long.MAX_VALUE, 10L), Math.ceilMod(Long.MIN_VALUE, 7L), Math.ceilMod(Long.MAX_VALUE, 7)) }
    t("divideExact") { listOf(Math.divideExact(Long.MAX_VALUE, -1L), Math.divideExact(Long.MIN_VALUE, 2L), Math.floorDivExact(Long.MIN_VALUE + 1, 2L), Math.ceilDivExact(Long.MAX_VALUE, 3L)) }
    t("divideExact overflow") { Math.divideExact(Long.MIN_VALUE, -1L) }
    t("ceilDivExact overflow") { Math.ceilDivExact(Long.MIN_VALUE, -1L) }
    t("clamp") { listOf(Math.clamp(Long.MAX_VALUE, Long.MIN_VALUE, 5L), Math.clamp(Long.MIN_VALUE, -1L, 1L), Math.clamp(Long.MAX_VALUE, 0, 9), Math.clamp(9007199254740993L, 0L, Long.MAX_VALUE)) }
    t("clamp reversed") { Math.clamp(0L, Long.MAX_VALUE, Long.MIN_VALUE) }
    t("multiplyFull") { listOf(Math.multiplyFull(Int.MAX_VALUE, Int.MAX_VALUE), Math.multiplyFull(Int.MIN_VALUE, Int.MIN_VALUE), Math.multiplyFull(Int.MIN_VALUE, Int.MAX_VALUE)) }
    t("multiplyHigh") { listOf(Math.multiplyHigh(Long.MAX_VALUE, Long.MAX_VALUE), Math.multiplyHigh(Long.MIN_VALUE, Long.MIN_VALUE), Math.multiplyHigh(Long.MIN_VALUE, Long.MAX_VALUE), Math.multiplyHigh(-1L, -1L), Math.multiplyHigh(-1L, 1L)) }
    t("unsignedMultiplyHigh") { listOf(Math.unsignedMultiplyHigh(-1L, -1L), Math.unsignedMultiplyHigh(Long.MIN_VALUE, 2L), Math.unsignedMultiplyHigh(0x123456789ABCDEFL, -0x123456789ABCDEFL)) }
}
