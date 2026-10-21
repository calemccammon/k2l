// Boxed Doubles (in collections, Any, generics, data classes) compare with Double.equals: NaN equals NaN, 0.0 and -0.0
// differ. Primitive Doubles (static type Double or Double?) keep IEEE `==`.
import java.util.TreeMap
import java.util.TreeSet

data class Point(val x: Double, val y: Double)

data class Reading(val name: String, val value: Double?)

data class Ratio(val f: Float)

data class Grid(val x: Int, val y: Int)

class Box<T>(val value: T) {
    fun same(other: T): Boolean = value == other
}

fun <T> generic(a: T, b: T): Boolean = a == b

fun anyEquals(a: Any?, b: Any?): Boolean = a == b

fun describe(x: Any): String = when (x) {
    Double.NaN -> "nan"
    -0.0 -> "negative zero"
    0.0 -> "zero"
    else -> "other"
}

fun lists() {
    val nan = Double.NaN
    val nz = -0.0
    val xs = listOf(1.0, nan, 0.0, 2.0, nan)
    println("contains NaN: ${xs.contains(nan)} ${nan in xs}")
    println("indexOf NaN: ${xs.indexOf(nan)} lastIndexOf: ${xs.lastIndexOf(nan)}")
    println("contains -0.0: ${xs.contains(nz)} indexOf -0.0: ${xs.indexOf(nz)} indexOf 0.0: ${xs.indexOf(0.0)}")
    val ys = mutableListOf(nz, 0.0, nan, 1.0)
    println("remove 0.0: ${ys.remove(0.0)} -> ${ys.size} ${1.0 / ys[0]}")
    println("remove NaN: ${ys.remove(nan)} -> ${ys.size}")
    println("remove NaN again: ${ys.remove(nan)}")
    println("list == list: ${listOf(nan) == listOf(nan)} ${listOf(0.0) == listOf(nz)} ${listOf(1.0, nan) == listOf(1.0, nan)}")
    println("list hash: ${listOf(nan).hashCode() == listOf(nan).hashCode()} ${listOf(0.0).hashCode()} ${listOf(nz).hashCode()}")
    println("array: ${arrayOf(nan, 1.0).indexOf(nan)} ${arrayOf(nz).contains(0.0)} ${arrayOf(1.0, nz).indexOf(nz)}")
    println("distinct: ${listOf(nan, nan, 0.0, nz, 0.0, 1.0).distinct().size}")
    println("toSet: ${listOf(nan, nz, 0.0, nan).toSet().size}")
    println("minus: ${listOf(nan, 1.0, nz, 0.0).minus(nan).size} ${listOf(nz, 0.0).minus(0.0).size}")
    println("containsAll: ${listOf(nan, 1.0).containsAll(listOf(nan))}")
    println("intersect: ${listOf(nan, 0.0, 1.0).intersect(listOf(nan, nz)).size}")
    println("union: ${listOf(nan, 0.0).union(listOf(nan, nz)).size}")
    println("count: ${xs.count { it == nan }} ${xs.count { it.isNaN() }}")
    println("ints: ${listOf(0, 1, 2).contains(0)} ${listOf(1, 2).indexOf(2)} ${hashSetOf(0, 1).contains(0)}")
}

fun sets() {
    val nan = Double.NaN
    val nz = -0.0
    val s = hashSetOf(0.0, nz, nan)
    println("set size: ${s.size}")
    println("set add NaN again: ${s.add(nan)} ${s.size}")
    println("set contains: ${s.contains(nan)} ${s.contains(nz)} ${s.contains(0.0)} ${s.contains(1.0)}")
    println("set remove -0.0: ${s.remove(nz)} ${s.size} ${s.contains(nz)} ${s.contains(0.0)}")
    println("set remove NaN: ${s.remove(nan)} ${s.size} ${s.contains(nan)}")
    val linked = linkedSetOf(1.0, nz, nan, 0.0, 2.0)
    linked.remove(nz)
    println("linked after remove: ${linked.size} ${linked.contains(nan)} ${linked.contains(0.0)} ${linked.contains(2.0)}")
    linked.remove(1.0)
    println("linked after remove 1.0: ${linked.contains(nan)} ${linked.contains(0.0)} ${linked.contains(2.0)}")
    println("set equals: ${setOf(nan, nz) == setOf(nz, nan)} ${setOf(0.0) == setOf(nz)}")
    println("set hash: ${setOf(nan).hashCode()} ${setOf(nz).hashCode()} ${setOf(0.0).hashCode()}")
    val ints = hashSetOf(1, 2, 3)
    ints.remove(2)
    println("int set: ${ints.contains(1)} ${ints.contains(3)} ${ints.size}")
}

fun maps() {
    val nan = Double.NaN
    val nz = -0.0
    val m = HashMap<Double, String>()
    m[nan] = "nan"
    m[0.0] = "zero"
    m[nz] = "negative zero"
    m[nan] = "nan again"
    println("map size: ${m.size}")
    println("map get: ${m[nan]} ${m[0.0]} ${m[nz]} ${m[1.0]}")
    println("map containsKey: ${m.containsKey(nan)} ${m.containsKey(nz)}")
    println("map remove: ${m.remove(nz)} ${m.size} ${m[0.0]} ${m[nan]}")
    val values = mapOf("a" to nan, "b" to nz)
    println("containsValue: ${values.containsValue(nan)} ${values.containsValue(nz)} ${values.containsValue(0.0)}")
    println("map equals: ${mapOf(nan to 1) == mapOf(nan to 1)} ${mapOf(1 to nan) == mapOf(1 to nan)} ${mapOf(1 to 0.0) == mapOf(1 to nz)}")
    val groups = listOf(1.5, nan, -1.5, nan, 2.0).groupBy { if (it.isNaN()) it else if (it < 0) -0.0 else 0.0 }
    println("groupBy: ${groups.size} ${groups[nan]?.size} ${groups[0.0]?.size} ${groups[nz]?.size}")
    val counts = listOf(nan, nan, 0.0, nz).groupingBy { it }.eachCount()
    println("eachCount: ${counts.size} ${counts[nan]} ${counts[0.0]} ${counts[nz]}")
    val assoc = listOf(nan, nz, 0.0).associateWith { it.toString() }
    println("associateWith: ${assoc.size} ${assoc[nan]} ${assoc[nz]}")
    val linked = linkedMapOf(nz to "a", nan to "b", 1.0 to "c")
    linked.remove(nz)
    println("linked map: ${linked[nan]} ${linked[1.0]} ${linked.size}")
}

fun trees() {
    val nan = Double.NaN
    val nz = -0.0
    val t = TreeSet<Double>()
    t.addAll(listOf(nan, 1.0, 0.0, nz, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY, nan, -1.0))
    println("tree set: ${t.size} ${t.joinToString { it.toString() }}")
    println("tree first/last: ${t.first()} ${t.last()} ${t.contains(nan)} ${t.contains(nz)}")
    println("tree higher(-0.0): ${t.higher(nz)} lower(0.0): ${t.lower(0.0)}")
    val tm = TreeMap<Double, Int>()
    tm[nan] = 1
    tm[0.0] = 2
    tm[nz] = 3
    tm[nan] = 4
    println("tree map: ${tm.size} ${tm.keys.joinToString { it.toString() }} ${tm[nan]} ${tm[nz]}")
    println("sorted: ${listOf(nan, 1.0, 0.0, nz, -1.0).sorted().joinToString { it.toString() }}")
    println("sortedDescending: ${listOf(nan, 1.0, 0.0, nz).sortedDescending().joinToString { it.toString() }}")
    println("max/min: ${listOf(nz, 0.0).max()} ${listOf(0.0, nz).min()} ${listOf(1.0, nan).max()}")
    println("compareTo: ${nan.compareTo(nan)} ${nz.compareTo(0.0)} ${0.0.compareTo(nz)} ${nan.compareTo(Double.POSITIVE_INFINITY)}")
}

fun boxed() {
    val nan = Double.NaN
    val nz = -0.0
    val a: Any = nan
    val b: Any = nan
    val z: Any = 0.0
    val n: Any = nz
    println("Any ==: ${a == b} ${z == n} ${a == a}")
    println("Any equals(): ${a.equals(b)} ${z.equals(n)} ${nan.equals(nan)} ${nz.equals(0.0)}")
    println("anyEquals: ${anyEquals(nan, nan)} ${anyEquals(0.0, nz)} ${anyEquals(1.0, 1.0)} ${anyEquals(null, null)}")
    println("generic: ${generic(nan, nan)} ${generic(0.0, nz)} ${generic("a", "a")}")
    println("Box: ${Box(nan).same(nan)} ${Box(nz).same(0.0)} ${Box(2.0).same(2.0)}")
    println("hashCode: ${nan.hashCode()} ${nz.hashCode()} ${0.0.hashCode()} ${a.hashCode()} ${n.hashCode()}")
    println("Pair: ${Pair(nan, 1) == Pair(nan, 1)} ${Pair(0.0, 1) == Pair(nz, 1)} ${(nan to nz).hashCode() == (nan to nz).hashCode()}")
    println("Triple: ${Triple(1, nan, 2) == Triple(1, nan, 2)}")
    println("when Any: ${describe(nan)} ${describe(nz)} ${describe(0.0)} ${describe(1.0)}")
    println("Objects.equals: ${java.util.Objects.equals(nan, nan)} ${java.util.Objects.equals(0.0, nz)}")
}

fun dataClasses() {
    val nan = Double.NaN
    val nz = -0.0
    println("Point: ${Point(nan, 1.0) == Point(nan, 1.0)} ${Point(0.0, 1.0) == Point(nz, 1.0)} ${Point(1.0, 2.0) == Point(1.0, 2.0)}")
    println("Point hash: ${Point(nan, 0.0).hashCode() == Point(nan, 0.0).hashCode()} ${Point(0.0, 0.0).hashCode()} ${Point(nz, 0.0).hashCode()}")
    println("Reading: ${Reading("a", nan) == Reading("a", nan)} ${Reading("a", null) == Reading("a", null)} ${Reading("a", 0.0) == Reading("a", nz)}")
    println("Ratio: ${Ratio(Float.NaN) == Ratio(Float.NaN)} ${Ratio(0.0f) == Ratio(-0.0f)} ${Ratio(1.5f) == Ratio(1.5f)}")
    println("in set: ${hashSetOf(Point(nan, nan)).contains(Point(nan, nan))} ${hashSetOf(Point(0.0, 0.0)).contains(Point(nz, 0.0))}")
    val dz = 0
    val g = Grid(-dz, dz * -1)
    println("Grid: ${g == Grid(0, 0)} ${hashSetOf(Grid(0, 0)).contains(g)} $g")
}

fun primitives() {
    val nan = Double.NaN
    val nz = -0.0
    val x: Double = nan
    val y: Double? = nan
    val p: Double = nz
    println("primitive ==: ${x == x} ${x == nan} ${y == y} ${y == x} ${p == 0.0} ${x != x}")
    val list = listOf(nan)
    println("element ==: ${list[0] == list[0]} ${list[0] == nan} ${list.first() == x}")
    val f = Float.NaN
    println("float ==: ${f == f} ${listOf(f).contains(f)} ${hashSetOf(0.0f, -0.0f).size}")
    val any: Any = nan
    if (any is Double) {
        println("smart cast ==: ${any == any} ${any == nan}")
    }
    val zero = 0
    val negated = -zero
    val product = zero * -3
    val quotient = zero / -3
    var compound = 0
    compound *= -1
    val long = 0L
    val longNegated = -long
    println("ints: $negated $product $quotient $compound $longNegated ${Math.floorDiv(zero, -3)} ${zero.floorDiv(-3)}")
    println("exact: ${Math.negateExact(zero)} ${Math.multiplyExact(zero, -1)} ${Math.negateExact(long)} ${zero.unaryMinus()} ${-(zero * 5)}")
    println("int sets:${hashSetOf(0, negated, product, quotient, compound).size} ${listOf<Any>(0).contains(negated)}")
    println("int as Any: ${anyEquals(0, negated)} ${anyEquals(0L, longNegated)} ${TreeSet(listOf(0, negated, product)).size}")
}

fun others() {
    val nan = Double.NaN
    val nz = -0.0
    val seq = sequenceOf(1.0, nan, nz)
    println("sequence: ${seq.contains(nan)} ${seq.indexOf(nan)} ${seq.indexOf(0.0)} ${seq.distinct().count()} ${(seq + nan + 0.0).toSet().size}")
    val deque = ArrayDeque(listOf(nan, nz, 1.0))
    println("ArrayDeque: ${deque.contains(nan)} ${deque.indexOf(nz)} ${deque.contains(0.0)} ${deque.remove(nan)} ${deque.size}")
    val jdeque = java.util.ArrayDeque(listOf(nan, nz))
    println("java ArrayDeque: ${jdeque.contains(nan)} ${jdeque.contains(0.0)} ${jdeque.remove(nz)} ${jdeque.size}")
    val linked = java.util.LinkedList(listOf(nan, 1.0))
    println("LinkedList: ${linked.contains(nan)} ${linked.indexOf(nan)}")
    val ml = mutableListOf(nan, 1.0, nz, 0.0, nan)
    ml.removeAll(listOf(nan, 0.0))
    println("removeAll: ${ml.size} ${ml.contains(nz)}")
    val rl = mutableListOf(nan, 1.0, nz, 0.0)
    rl.retainAll(listOf(nan, nz))
    println("retainAll: ${rl.size} ${rl.contains(nan)} ${rl.contains(0.0)}")
    println("array contentEquals: ${arrayOf(nan).contentEquals(arrayOf(nan))} ${arrayOf(0.0).contentEquals(arrayOf(nz))}")
    println("sortedSetOf: ${sortedSetOf(nan, 0.0, nz, nan).size} ${sortedSetOf(nan, nz).first()}")
    println("stream distinct: ${listOf(nan, nan, nz, 0.0).stream().distinct().count()}")
    println("minus list: ${listOf(nan, nz, 0.0, 1.0).minus(listOf(nan, 0.0)).size}")
    println("indexOf in Any list: ${listOf<Any>("a", nan, 1).indexOf(nan)} ${listOf<Any?>(null, nz).indexOf(nz)}")
    val m = mutableMapOf<Any, Int>(0.0 to 1, "0" to 2)
    m[nz] = 3
    println("Any keys: ${m.size} ${m[nz]} ${m[0.0]}")
}

fun main() {
    others()
    lists()
    sets()
    maps()
    trees()
    boxed()
    dataClasses()
    primitives()
}
