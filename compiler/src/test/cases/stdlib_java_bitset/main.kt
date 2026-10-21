import java.util.BitSet

// java.util.BitSet: single bits and ranges, searches, the set operations, size() and hashCode() as the JDK's
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun bits(vararg indexes: Int): BitSet {
    val set = BitSet()
    for (i in indexes) set.set(i)
    return set
}

/** The primes below [n] with a sieve, as ported Java code writes it. */
fun sieve(n: Int): BitSet {
    val composite = BitSet(n)
    composite.set(0, 2)
    var i = 2
    while (i * i < n) {
        if (!composite[i]) {
            var j = i * i
            while (j < n) {
                composite.set(j)
                j += i
            }
        }
        i++
    }
    composite.flip(0, n)
    return composite
}

fun main() {
    val a = BitSet()
    t("empty") { "$a ${a.isEmpty} ${a.length()} ${a.size()} ${a.cardinality()} ${a.hashCode()}" }
    a.set(1)
    a.set(5)
    a[31] = true
    a.set(32)
    a.set(63, true)
    a.set(64)
    t("set") { "$a len=${a.length()} size=${a.size()} card=${a.cardinality()}" }
    t("get") { listOf(a[0], a[1], a.get(31), a.get(32), a.get(63), a.get(64), a.get(1000)) }
    t("hash") { a.hashCode() }
    a.clear(64)
    a[5] = false
    t("clear") { "$a len=${a.length()} size=${a.size()} hash=${a.hashCode()}" }
    a.flip(2)
    a.flip(1)
    t("flip") { a }

    val r = BitSet()
    r.set(3, 70)
    t("set range") { "card=${r.cardinality()} len=${r.length()} size=${r.size()} first=${r.nextSetBit(0)}" }
    r.clear(10, 60)
    t("clear range") { r }
    r.flip(0, 12)
    t("flip range") { r }
    r.set(100, 103, true)
    r.set(101, 102, false)
    t("set value range") { "$r size=${r.size()}" }
    r.clear(0, 1000)
    t("clear all range") { "$r ${r.isEmpty} ${r.length()} ${r.size()}" }
    t("get range") { bits(1, 3, 40, 70, 130).get(2, 100) }
    t("get range size") { bits(1, 3, 40, 70, 130).get(2, 100).size() }
    t("get range past") { bits(1, 3).get(5, 10).let { "$it ${it.size()}" } }

    val s = bits(0, 2, 33, 64, 65, 200)
    t("nextSetBit") { generateSequence(s.nextSetBit(0)) { if (it < 0) null else s.nextSetBit(it + 1) }.toList() }
    t("nextClearBit") { listOf(s.nextClearBit(0), s.nextClearBit(1), s.nextClearBit(64), s.nextClearBit(201), s.nextClearBit(999)) }
    t("previousSetBit") { listOf(s.previousSetBit(500), s.previousSetBit(199), s.previousSetBit(64), s.previousSetBit(1), s.previousSetBit(-1)) }
    t("previousClearBit") { listOf(s.previousClearBit(500), s.previousClearBit(65), s.previousClearBit(0), s.previousClearBit(2), s.previousClearBit(-1)) }
    t("full") { BitSet().apply { set(0, 64) }.let { listOf(it.nextClearBit(0), it.previousClearBit(63), it.length(), it.cardinality()) } }

    val x = bits(1, 2, 3, 40, 100)
    val y = bits(2, 3, 4, 41, 300)
    t("and") { (x.clone() as BitSet).apply { and(y) } }
    t("or") { (x.clone() as BitSet).apply { or(y) }.let { "$it size=${it.size()}" } }
    t("xor") { (x.clone() as BitSet).apply { xor(y) } }
    t("andNot") { (x.clone() as BitSet).apply { andNot(y) } }
    t("self ops") { (x.clone() as BitSet).apply { xor(this) }.isEmpty }
    t("intersects") { listOf(x.intersects(y), x.intersects(bits(5, 6)), BitSet().intersects(x)) }
    t("equals") { listOf(x == bits(1, 2, 3, 40, 100), x == y, x.equals(bits(100, 40, 3, 2, 1)), x.equals("x"), BitSet() == BitSet(500)) }
    t("hashes") { listOf(x.hashCode(), y.hashCode(), BitSet(1000).hashCode(), bits(63).hashCode(), bits(0, 63, 64, 127, 128).hashCode()) }
    t("in set") { hashSetOf(bits(1, 2), bits(1, 2), bits(3)).size }

    t("sizes") { listOf(BitSet(0).size(), BitSet(1).size(), BitSet(64).size(), BitSet(65).size(), BitSet(1000).size()) }
    val g = BitSet()
    val sizes = mutableListOf<Int>()
    for (i in listOf(10, 70, 130, 200, 600, 5000)) {
        g.set(i)
        sizes += g.size()
    }
    t("growth") { sizes }
    t("clone size") { listOf((g.clone() as BitSet).size(), (BitSet(1000).apply { set(3) }.clone() as BitSet).size()) }
    t("negative size") { BitSet(-1) }

    t("toLongArray") { bits(0, 50, 64, 130).toLongArray().toList() }
    t("toLongArray low") { bits(0, 5, 31, 32, 40).toLongArray().toList() }
    t("toByteArray") { bits(0, 7, 8, 15, 33).toByteArray().toList() }
    t("valueOf longs") { BitSet.valueOf(longArrayOf(5L, 0L, 1L shl 40, 0L)).let { "$it ${it.size()}" } }
    t("valueOf bytes") { BitSet.valueOf(byteArrayOf(1, -128, 0, 3, 0)).let { "$it ${it.size()} ${it.length()}" } }
    t("valueOf empty") { BitSet.valueOf(longArrayOf(0L, 0L)).let { "$it ${it.size()} ${it.isEmpty}" } }
    t("round trip") { BitSet.valueOf(bits(3, 64, 99).toLongArray()) == bits(3, 64, 99) }
    t("stream") { bits(4, 2, 99).stream().toArray().toList() }
    t("stream sum") { bits(1, 2, 3, 10).stream().map { it * 2 }.sum() }

    t("get negative") { BitSet().get(-1) }
    t("set negative") { BitSet().set(-2) }
    t("clear negative") { BitSet().clear(-3) }
    t("flip negative") { BitSet().flip(-4) }
    t("range negative") { BitSet().set(-1, 3) }
    t("range toIndex") { BitSet().clear(1, -3) }
    t("range reversed") { BitSet().flip(5, 2) }
    t("nextSetBit negative") { BitSet().nextSetBit(-1) }
    t("nextClearBit negative") { BitSet().nextClearBit(-1) }
    t("previousSetBit -2") { BitSet().previousSetBit(-2) }
    t("previousClearBit -2") { BitSet().previousClearBit(-2) }

    val primes = sieve(100)
    t("primes") { primes }
    t("prime count") { sieve(10000).cardinality() }
    t("last prime") { sieve(10000).previousSetBit(9999) }
}
