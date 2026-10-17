data class Key(val x: Int, val y: Int)

fun main() {
    val ages = mapOf("ann" to 31, "bob" to 25)
    println(ages)
    println(ages["ann"])
    println(ages["zed"])
    println(ages.size)
    println(ages.containsKey("bob"))
    println("ann" in ages)
    println(ages.keys)
    println(ages.values)
    println(ages.getOrDefault("zed", 0))
    for ((name, age) in ages) println("$name is $age")
    ages.forEach { (k, v) -> print("$k=$v ") }
    println()
    ages.forEach { k, v -> print("$k:$v ") }
    println()
    println(ages.map { (k, v) -> "$k$v" })
    println(ages.filter { it.value > 30 })
    println(ages.mapValues { it.value + 1 })
    println(ages.entries.map { it.key })

    val counts = mutableMapOf<Char, Int>()
    for (c in "mississippi") counts[c] = (counts[c] ?: 0) + 1
    println(counts)
    val m = HashMap<String, Int>()
    m["a"] = 1
    m.put("b", 2)
    m.remove("a")
    println(m)
    println(m.getOrPut("c") { 3 })
    println(m)

    val grid = mutableMapOf<Key, String>()
    grid[Key(1, 2)] = "treasure"
    println(grid[Key(1, 2)])
    println(Key(1, 2) in grid)
    println(Key(1, 2).hashCode() == Key(1, 2).hashCode())

    val s = mutableSetOf(3, 1, 3, 2)
    println(s)
    println(s.size)
    s.add(1)
    s.add(4)
    s.remove(3)
    println(s)
    println(2 in s)
    val t = setOf(2, 4, 6)
    println(s intersect t)
    println(s union t)
    println(s subtract t)
    println(setOf(1, 2) == setOf(2, 1))
    println(listOf(3, 3, 1).toSet())
    var sum = 0
    for (x in s) sum += x
    println(sum)
    println(listOf("apple", "avocado", "banana").groupBy { it.first() })
    println(listOf("a", "bb", "ccc").associateWith { it.length })
}
