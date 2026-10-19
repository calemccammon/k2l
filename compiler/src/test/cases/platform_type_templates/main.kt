import java.util.TreeMap

// Values of platform types (`Int!` from a Java method such as TreeMap.higherKey) may be null in string templates
// and concatenations, which print "null" as on the JVM.

fun main() {
    val tm = TreeMap(mapOf(1 to "a", 5 to "e", 9 to "i"))
    println("floor(0)=${tm.floorKey(0)} ceiling(6)=${tm.ceilingKey(6)} higher(9)=${tm.higherKey(9)} lower(1)=${tm.lowerKey(1)}")
    println("entries: ${tm.floorEntry(0)} ${tm.ceilingEntry(2)} ${tm.higherEntry(9)?.value}")
    val keys = listOf(0, 4, 9, 12).map { "${tm.floorKey(it)}" }
    println(keys)
    println("first: " + tm.firstKey() + ", missing: " + tm.higherKey(100))
    val sb = StringBuilder("ab")
    println("sb=" + sb + " " + sb.toString().length)
}
