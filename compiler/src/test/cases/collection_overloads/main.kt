// `+`, `-`, `+=` and `-=` pick the element or the collection overload the way Kotlin resolves them, also when the
// elements are collections themselves; `+=` works on parameters; range members named like the range's properties.

fun nestedLists() {
    val rows = mutableListOf<List<Int>>()
    rows += listOf(1, 2)
    rows += listOf(listOf(3), listOf(4, 5))
    rows.add(listOf(6))
    println(rows)
    rows -= listOf(1, 2)
    println(rows)
    rows -= listOf(listOf(3))
    println(rows)
    val plusOne = rows + listOf(7)
    val plusMany = rows + listOf(listOf(8), listOf(9))
    println(plusOne)
    println(plusMany)
    println(plusMany - listOf(listOf(8)))
    println(plusMany - listOf(9))
    var readOnly: List<List<Int>> = listOf()
    readOnly += listOf(listOf(2))
    readOnly = readOnly.plusElement(listOf(3))
    println(readOnly)
}

fun nestedSets() {
    val sets = mutableSetOf<Set<String>>()
    sets += setOf("a")
    sets += listOf(setOf("b"), setOf("c"))
    println(sets)
    sets -= setOf("a")
    println(sets)
    println(sets + setOf("z"))
    println(sets + listOf(setOf("y")))
    val flat = mutableSetOf("q")
    flat += listOf("r", "s")
    flat -= "q"
    println(flat)
}

fun maps() {
    val m = mutableMapOf(1 to "a")
    m += 2 to "b"
    m += mapOf(3 to "c")
    m += listOf(4 to "d", 5 to "e")
    m -= 1
    m -= listOf(2, 3)
    println(m)
    val n = mutableMapOf(0 to "z")
    n += sequenceOf(8 to "h", 9 to "i")
    n += arrayOf(10 to "j")
    println(n)
    println(n + sequenceOf(11 to "k"))
    println(n - sequenceOf(8, 9))
    println(m + (6 to "f"))
    println(m + mapOf(7 to "g"))
    println(m - 4)
    println(m - listOf(4, 5))
    val pairs = mutableListOf<Pair<Int, Int>>()
    pairs += 1 to 2
    pairs += listOf(3 to 4)
    println(pairs)
}

fun sequences() {
    val nested = sequenceOf(listOf(1))
    println((nested + listOf(2)).toList())
    println((nested + sequenceOf(listOf(3))).toList())
    println((sequenceOf(1, 2) + listOf(3, 4)).toList())
    println((sequenceOf(1, 2, 3) - 2).toList())
}

fun addTo(target: MutableList<String>, extra: MutableSet<Int>, counts: MutableMap<String, Int>) {
    target += "x"
    target += listOf("y", "z")
    target -= "y"
    extra += 3
    extra -= 1
    counts += "k" to 1
    counts -= "old"
}

fun ranges() {
    val r = 1..10
    println(r.first)
    println(r.last)
    println(r.step)
    println(r.first { it > 3 })
    println(r.last { it % 3 == 0 })
    println(r.first())
    println(r.last())
    println((1..10 step 4).last())
    println(('a'..'f').first { it > 'b' })
    println(('a'..'f').last { it < 'e' })
    println((10 downTo 1).first { it < 8 })
    println(runCatching { (1..0).first() }.exceptionOrNull()?.let { it::class.simpleName })
    println((1..0).first)
    println((1L..5L).last { it < 4 })
}

fun main() {
    nestedLists()
    nestedSets()
    maps()
    sequences()
    val target = mutableListOf("w")
    val extra = mutableSetOf(1, 2)
    val counts = mutableMapOf("old" to 0)
    addTo(target, extra, counts)
    println("$target $extra $counts")
    ranges()
}
