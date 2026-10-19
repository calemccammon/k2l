// TreeMap.navigableKeySet/descendingKeySet/descendingMap (live views) and the EMPTY ranges.
import java.util.TreeMap
import java.util.TreeSet

fun main() {
    val t = TreeMap(mapOf(3 to "c", 1 to "a", 2 to "b"))
    val nk = t.navigableKeySet()
    println("$nk ${nk.javaClass.name}")
    val dk = t.descendingKeySet()
    println("$dk ${dk.javaClass.name}")
    val dm = t.descendingMap()
    println("$dm ${dm.javaClass.name}")
    println("${dm.firstKey()} ${dm.keys} ${dm.values} ${dm.entries}")
    t[4] = "d"
    println("$nk $dk $dm")
    nk.remove(1)
    println("$t")
    println(dk.first())
    println("${IntRange.EMPTY} ${CharRange.EMPTY} ${LongRange.EMPTY} ${IntRange.EMPTY.isEmpty()} ${IntRange.EMPTY.first} ${IntRange.EMPTY.last}")
    println("${IntRange.EMPTY == (1..0)} ${IntRange.EMPTY.javaClass.name} ${CharRange.EMPTY.first.code} ${LongRange.EMPTY.last}")
    for (i in IntRange.EMPTY) println(i)
    println(IntRange.EMPTY.toList())
    println(t.keys.javaClass.name)
    println(t.navigableKeySet() == t.keys)
    println(t.descendingKeySet().descendingSet())
    println(TreeSet(listOf(1, 2)).descendingSet().javaClass.name)
    // ranges of Doubles and Floats print their bounds as Doubles on every Lua version
    val r = 30.0..50.0
    println(r)
    println("${r.start} ${r.endInclusive} ${1.5..2.25} ${(1f..2.5f)} ${0.1..0.3} ${40.0 in r}")
    println(listOf(r, -1.0..1e10))
    println("a".."c")
}
