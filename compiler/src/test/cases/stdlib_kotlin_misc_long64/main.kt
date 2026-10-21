// More of the kotlin package: KotlinVersion, unsigned floorDiv/mod and UIntRange values, Double/Float inc and dec,
// array clone, Byte/Short/Char/Long ranges, takeHighestOneBit/takeLowestOneBit, library enums' entries
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    // KotlinVersion
    val current = KotlinVersion.CURRENT
    t("current at least 2.0") { current.isAtLeast(2, 0) }
    t("current parts") { current.major >= 2 && current.minor >= 0 && current.patch >= 0 }
    t("current string") { current.toString() == "${current.major}.${current.minor}.${current.patch}" }
    val v = KotlinVersion(1, 9, 22)
    t("version") { listOf(v, KotlinVersion(2, 1), v.major, v.minor, v.patch) }
    t("isAtLeast") { listOf(v.isAtLeast(1, 9), v.isAtLeast(1, 9, 23), v.isAtLeast(1, 10), v.isAtLeast(1, 8, 99)) }
    t("compare") { listOf(v < KotlinVersion(1, 10), v.compareTo(KotlinVersion(1, 9, 22)), maxOf(v, KotlinVersion(1, 9, 3))) }
    t("equals") { listOf(v == KotlinVersion(1, 9, 22), v == KotlinVersion(1, 9), v.hashCode() == KotlinVersion(1, 9, 22).hashCode()) }
    t("hashCode") { KotlinVersion(1, 2, 3).hashCode() }
    t("bad version") { KotlinVersion(1, 300) }
    t("sorted") { listOf(KotlinVersion(2, 0), KotlinVersion(1, 9, 22), KotlinVersion(1, 10)).sorted() }

    // unsigned floorDiv and mod: the same as / and % for unsigned operands
    t("UInt floorDiv/mod") { listOf(17u.floorDiv(5u), 17u.mod(5u), 4_000_000_000u.floorDiv(3u), 4_000_000_000u.mod(7u)) }
    t("UByte/UShort") { listOf(200.toUByte().floorDiv(7.toUByte()), 200.toUByte().mod(7.toUByte()), 60000.toUShort().mod(7.toUShort())) }
    t("ULong") { listOf(100uL.floorDiv(7uL), 100uL.mod(7uL)) }

    // unsigned ranges as values
    val r = 1u..5u
    t("UIntRange") { listOf(r, r.first, r.last, r.start, r.endInclusive, r.isEmpty(), 3u in r, 9u in r) }
    t("until") { (0u until 3u).toList() }
    t("rangeUntil") { (2u..<4u).toList() }
    t("UByte range") { (250.toUByte()..255.toUByte()).toList() }
    t("UShort range") { (1.toUShort()..<3.toUShort()).toList() }
    t("progression") { listOf((10u downTo 1u step 3).toList(), (1u..10u step 4).last, (5u downTo 1u).first) }
    t("reversed") { r.reversed().toList() }
    t("empty") { listOf(UIntRange.EMPTY.isEmpty(), (5u..1u).isEmpty(), (5u..1u).firstOrNull(), r.lastOrNull()) }
    t("sum") { r.sum() }
    t("iterate") { buildList { for (x in r step 2) add(x * 10u) } }

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

    // takeHighestOneBit and takeLowestOneBit of the small and unsigned types
    t("Byte bits") { listOf((-12).toByte().takeHighestOneBit(), (12).toByte().takeHighestOneBit(), (12).toByte().takeLowestOneBit()) }
    t("Short bits") { listOf((-1).toShort().takeHighestOneBit(), (40).toShort().takeLowestOneBit()) }
    t("UInt bits") { listOf(100u.takeHighestOneBit(), 100u.takeLowestOneBit(), 0u.takeHighestOneBit(), 4_000_000_000u.takeHighestOneBit()) }
    t("UByte/UShort bits") { listOf(200.toUByte().takeHighestOneBit(), 200.toUShort().takeLowestOneBit()) }

    // library enums
    t("LazyThreadSafetyMode") { listOf(LazyThreadSafetyMode.entries, LazyThreadSafetyMode.valueOf("NONE"), LazyThreadSafetyMode.values().size) }
    t("DeprecationLevel") { listOf(DeprecationLevel.entries, DeprecationLevel.valueOf("ERROR").ordinal) }
}
