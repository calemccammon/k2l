// HashMap/HashSet iterate in the JVM's order for keys of the usual types: strings (also non-ASCII), data classes
// (with Double fields that hold integral values), pairs, lists, chars, doubles, longs and booleans.

data class Cell(val r: Int, val c: Int)
data class Key(val name: String, val tags: List<String>, val weight: Double, val on: Boolean)

fun main() {
    val words = "the quick brown fox jumps over the lazy dog while seven zebras quietly vex jumping kangaroos".split(" ")
    val counts = HashMap<String, Int>()
    for (w in words) counts[w] = (counts[w] ?: 0) + 1
    println(counts)
    println(counts.keys.take(5))
    val cells = HashSet<Cell>()
    for (r in 0 until 4) for (c in 0 until 4) if ((r * c) % 3 != 1) cells += Cell(r, c)
    println(cells)
    val pairs = hashSetOf<Pair<Int, Int>>()
    for (i in -3..3) pairs += i to i * i
    println(pairs)
    val lists = hashSetOf(listOf(1, 2), listOf(3), emptyList(), listOf(2, 1))
    println(lists)
    val keys = hashMapOf(Key("a", listOf("x"), 1.5, true) to 1, Key("b", emptyList(), -0.25, false) to 2, Key("c", listOf("y", "z"), 3.0, true) to 3)
    println(keys.values)
    println(keys.keys.map { it.hashCode() })
    val chars = HashMap<Char, Int>()
    "mississippi river".forEach { chars[it] = (chars[it] ?: 0) + 1 }
    println(chars)
    val doubles = hashSetOf(0.5, 1.25, -3.5, 100.125, 1e-3)
    println(doubles)
    val longs = hashMapOf(10_000_000_000L to "a", 3L to "b", 4_294_967_296L to "c")
    println(longs)
    val bools = hashMapOf(true to 1, false to 0)
    println(bools)
    println(words.toHashSet().take(6))
    println(words.groupBy { it.length }.keys)
    println(HashMap(mapOf("z" to 1, "a" to 2, "m" to 3, "Aa" to 4, "BB" to 5)))
    println("Aa".hashCode() == "BB".hashCode())
    println(listOf("hello", "world", "", "Kotlin", "été").map { it.hashCode() })
}
