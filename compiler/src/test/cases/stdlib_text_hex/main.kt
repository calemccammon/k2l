// toHexString / hexToInt and friends with the default HexFormat, Kotlin's StringBuilder extensions (deleteAt,
// deleteRange, setRange), and startsWith/endsWith/contains with an ignoreCase that is not a literal
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}")
    }
}

fun matches(name: String, suffix: String, loose: Boolean) = name.endsWith(suffix, ignoreCase = loose)

fun main() {
    t("Int.toHexString") { listOf(255.toHexString(), (-1).toHexString(), 0.toHexString(), Int.MIN_VALUE.toHexString()) }
    t("Long.toHexString") { listOf(255L.toHexString(), (-2L).toHexString(), 0x1234_5678_9abcL.toHexString()) }
    t("Short/Byte") { listOf(10.toShort().toHexString(), (-1).toShort().toHexString(), 127.toByte().toHexString(), (-128).toByte().toHexString()) }
    val bytes = byteArrayOf(0, 15, 16, -1, 127, -128)
    t("ByteArray.toHexString") { bytes.toHexString() }
    t("hexToInt") { listOf("ff".hexToInt(), "ffffffff".hexToInt(), "7fffffff".hexToInt(), "0".hexToInt()) }
    t("hexToLong") { listOf("10".hexToLong(), "ffffffffffffffff".hexToLong(), "123456789abc".hexToLong()) }
    t("hexToShort/Byte") { listOf("ffff".hexToShort(), "7f".hexToByte(), "80".hexToByte()) }
    t("hexToInt bad") { "xyz".hexToInt() }
    t("hexToInt long") { "123456789".hexToInt() }
    t("hexToByteArray") { "000f10ff7f80".hexToByteArray().toList() }
    t("round trip") { bytes.toHexString().hexToByteArray().contentEquals(bytes) }

    val sb = StringBuilder("hello, world")
    sb.deleteAt(5)
    t("deleteAt") { sb.toString() }
    sb.deleteRange(0, 6)
    t("deleteRange") { sb.toString() }
    sb.setRange(0, 1, "W")
    t("setRange") { sb.toString() }
    t("deleteAt out of range") {
        try {
            StringBuilder("ab").deleteAt(5)
        } catch (e: IndexOutOfBoundsException) {
            "out of range"
        }
    }

    t("endsWith") { listOf(matches("Photo.JPG", ".jpg", true), matches("Photo.JPG", ".jpg", false), matches("a.jpg", ".jpg", false)) }
    val loose = true
    val strict = false
    val name = "Kotlin"
    val prefix = "kot"
    t("startsWith") { listOf(name.startsWith(prefix, ignoreCase = loose), name.startsWith(prefix, ignoreCase = strict)) }
    val part = "TLI"
    t("contains") { listOf(name.contains(part, ignoreCase = loose), name.contains(part, ignoreCase = strict)) }
}
