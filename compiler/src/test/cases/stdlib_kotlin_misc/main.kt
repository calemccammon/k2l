// More of the kotlin package: Double/Float inc and dec,
// array clone, Byte/Short/Char/Long ranges, takeHighestOneBit/takeLowestOneBit, library enums' entries
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    // Double and Float inc/dec
    var d = 1.5
    d++
    var f = 2.5f
    f--
    t("inc/dec") { listOf(d, f, d.inc(), f.dec()) }

    // array clone
    val ints = intArrayOf(1, 2, 3)
    val copy = ints.clone()
    copy[0] = 99
    t("clone") { listOf(ints.toList(), copy.toList(), arrayOf("a", "b").clone().toList()) }
    val doubles: List<Double> = doubleArrayOf(1.0, 2.5).clone().toList()
    println("clone doubles = $doubles")
    t("clone others") {
        listOf(booleanArrayOf(true).clone().toList(), charArrayOf('x').clone().toList(), longArrayOf(5L).clone().toList())
    }

    // ranges of Byte, Short, Char and Long
    val b1: Byte = 1
    val b2: Byte = 4
    val s1: Short = 10
    val s2: Short = 12
    t("byte range") { listOf((b1..b2).toList(), (b1..<b2).toList()) }
    t("short range") { listOf((s1..s2).toList(), (s1..<s2).last) }
    t("char rangeUntil") { ('a'..<'e').joinToString("") }
    t("long rangeUntil") { (1L..<4L).toList() }

    // takeHighestOneBit and takeLowestOneBit of the small types
    t("Byte bits") { listOf((-12).toByte().takeHighestOneBit(), (12).toByte().takeHighestOneBit(), (12).toByte().takeLowestOneBit()) }
    t("Short bits") { listOf((-1).toShort().takeHighestOneBit(), (40).toShort().takeLowestOneBit()) }

    // library enums
    t("LazyThreadSafetyMode") { listOf(LazyThreadSafetyMode.entries, LazyThreadSafetyMode.valueOf("NONE"), LazyThreadSafetyMode.values().size) }
    t("DeprecationLevel") { listOf(DeprecationLevel.entries, DeprecationLevel.valueOf("ERROR").ordinal) }
}
