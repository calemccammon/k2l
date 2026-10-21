// The less common statics of java.lang.Integer, Long, Character and Double: unsigned arithmetic, decode, bit permutations
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    t("compareUnsigned") { listOf(Integer.compareUnsigned(1, 2), Integer.compareUnsigned(-1, 2), Integer.compareUnsigned(5, 5), Integer.compareUnsigned(0, -2147483648)) }
    t("divideUnsigned") { listOf(Integer.divideUnsigned(-1, 2), Integer.divideUnsigned(-2, -1), Integer.divideUnsigned(7, 2), Integer.divideUnsigned(-7, 1000)) }
    t("remainderUnsigned") { listOf(Integer.remainderUnsigned(-1, 10), Integer.remainderUnsigned(7, 3), Integer.remainderUnsigned(-1, -2)) }
    t("divideUnsigned zero") { Integer.divideUnsigned(1, 0) }
    t("toUnsignedLong") { listOf(Integer.toUnsignedLong(-1), Integer.toUnsignedLong(5), Integer.toUnsignedLong(Int.MIN_VALUE)) }
    t("toUnsignedString") { listOf(Integer.toUnsignedString(-1), Integer.toUnsignedString(-16, 16), Integer.toUnsignedString(42)) }
    t("parseUnsignedInt") { listOf(Integer.parseUnsignedInt("4294967295"), Integer.parseUnsignedInt("+17"), Integer.parseUnsignedInt("ff", 16), Integer.parseUnsignedInt("2147483648")) }
    t("parseUnsignedInt minus") { Integer.parseUnsignedInt("-1") }
    t("parseUnsignedInt range") { Integer.parseUnsignedInt("4294967296") }
    t("parseUnsignedInt digits") { Integer.parseUnsignedInt("12x") }
    t("parseUnsignedInt radix") { Integer.parseUnsignedInt("zz", 16) }
    t("parseUnsignedInt empty") { Integer.parseUnsignedInt("") }
    t("decode") { listOf(Integer.decode("42"), Integer.decode("-0x1F"), Integer.decode("#ff"), Integer.decode("010"), Integer.decode("+0X10"), Integer.decode("0"), Integer.decode("-2147483648")) }
    t("decode empty") { Integer.decode("") }
    t("decode sign") { Integer.decode("0x-5") }
    t("decode digits") { Integer.decode("0xZZ") }
    t("decode octal") { Integer.decode("09") }
    t("decode range") { Integer.decode("2147483648") }
    t("decode minus") { Integer.decode("-") }
    t("reverseBytes") { listOf(Integer.reverseBytes(0x12345678), Integer.reverseBytes(1), Integer.reverseBytes(-1), Integer.reverseBytes(0xFF)) }
    t("reverse") { listOf(Integer.reverse(1), Integer.reverse(0x0F0F0F0F), Integer.reverse(-2)) }
    t("compress") { listOf(Integer.compress(0xCAFEBABE.toInt(), 0xFF00FFF0.toInt()), Integer.compress(0b1011, 0b0110), Integer.compress(-1, -1), Integer.compress(5, 0)) }
    t("expand") { listOf(Integer.expand(0xCAFEBABE.toInt(), 0xFF00FFF0.toInt()), Integer.expand(0b11, 0b0110), Integer.expand(-1, 0x7F)) }
    t("sum") { listOf(Integer.sum(3, 4), java.lang.Long.sum(5L, 6L)) }
    t("getInteger") { listOf(Integer.getInteger("k2l.none"), Integer.getInteger("k2l.none", 7), java.lang.Long.getLong("k2l.none"), java.lang.Long.getLong("k2l.none", 8L), java.lang.Boolean.getBoolean("k2l.none")) }

    t("Long compareUnsigned") { listOf(java.lang.Long.compareUnsigned(1L, 2L), java.lang.Long.compareUnsigned(-1L, 2L), java.lang.Long.compareUnsigned(3L, 3L)) }
    t("Long divideUnsigned") { listOf(java.lang.Long.divideUnsigned(100L, 7L), java.lang.Long.remainderUnsigned(100L, 7L)) }
    t("Long toUnsignedString") { listOf(java.lang.Long.toUnsignedString(12345L), java.lang.Long.toUnsignedString(255L, 2)) }
    t("parseUnsignedLong") { listOf(java.lang.Long.parseUnsignedLong("123456789012"), java.lang.Long.parseUnsignedLong("ff", 16)) }
    t("parseUnsignedLong minus") { java.lang.Long.parseUnsignedLong("-5") }
    t("parseUnsignedLong digits") { java.lang.Long.parseUnsignedLong("5q") }
    t("Long decode") { listOf(java.lang.Long.decode("0x7fffffff"), java.lang.Long.decode("-#10"), java.lang.Long.decode("0777"), java.lang.Long.decode("123456789012")) }
    t("Long decode digits") { java.lang.Long.decode("#g") }
    t("Long reverseBytes") { listOf(java.lang.Long.reverseBytes(0x100L), java.lang.Long.reverseBytes(0x0102030405L)) }
    t("Long reverse") { listOf(java.lang.Long.reverse(1L shl 20), java.lang.Long.reverse(1L shl 63)) }
    t("Long compress") { listOf(java.lang.Long.compress(0xF0F0L, 0xFF00L), java.lang.Long.compress(0x123456789L, 0xF0000000FL)) }
    t("Long expand") { listOf(java.lang.Long.expand(0xABL, 0xF0F0L), java.lang.Long.expand(0x3FL, 0x1_0000_0003L)) }

    t("Character.compare") { listOf(Character.compare('a', 'b'), Character.compare('z', 'a'), Character.compare('q', 'q')) }
    t("Character.isISOControl") { listOf(Character.isISOControl('\n'), Character.isISOControl('a'), Character.isISOControl('\u007f')) }

    t("Double.toHexString") {
        listOf(1.0, -2.5, 0.1, 0.0, -0.0, Double.MAX_VALUE, Double.MIN_VALUE, 3.0e-310, Double.NaN, Double.POSITIVE_INFINITY, 1e100)
            .map { java.lang.Double.toHexString(it) }
    }
}
