// More kotlin.collections, kotlin.sequences and kotlin.text: Grouping's *To operations, isSorted*, onEachIndexed,
// Map.mapTo/filterNotTo, Iterator.withIndex, IndexedValue, Sequence.unzip and CharSequence extras
data class Sale(val region: String, val amount: Int)

fun main() {
    val words = listOf("apple", "avocado", "banana", "blueberry", "cherry", "apricot")

    // Grouping: the *To variants add to (and return) a given map
    val counts = mutableMapOf("z" to 100)
    val returned = words.groupingBy { it.take(1) }.eachCountTo(counts)
    println("eachCountTo: $counts, same=${returned === counts}")
    println("foldTo: ${words.groupingBy { it.length }.foldTo(sortedMapOf(), 0) { acc, w -> acc + w.length }}")
    println("foldTo init: ${words.groupingBy { it[0] }.foldTo(mutableMapOf(), { k, _ -> "$k:" }) { _, acc, w -> acc + w.length }}")
    println("reduceTo: ${words.groupingBy { it[0] }.reduceTo(mutableMapOf()) { _, acc, w -> if (w.length > acc.length) w else acc }}")
    val agg = words.groupingBy { it.first() }.aggregateTo(mutableMapOf<Char, String>()) { key, acc, w, first ->
        if (first) "$key=$w" else "$acc,$w"
    }
    println("aggregateTo: $agg")
    val sales = listOf(Sale("north", 10), Sale("south", 5), Sale("north", 7))
    val totals = HashMap<String, Int>()
    sales.groupingBy { it.region }.foldTo(totals, 0) { acc, s -> acc + s.amount }
    println("totals: ${totals.toSortedMap()}")
    val grouping = "mississippi".asIterable().groupingBy { it }
    println("keyOf: ${grouping.keyOf('s')}, ${grouping.sourceIterator().asSequence().count()}")

    // isSorted and friends
    println("isSorted: ${listOf(1, 2, 2, 5).isSorted()} ${listOf(3, 1).isSorted()} ${emptyList<Int>().isSorted()}")
    println("isSortedDescending: ${listOf(5, 3, 3, 1).isSortedDescending()} ${listOf(1, 2).isSortedDescending()}")
    println("isSortedBy: ${words.isSortedBy { it.length }} ${listOf("a", "bb", "ccc").isSortedBy { it.length }}")
    println("isSortedByDescending: ${listOf("ccc", "bb", "a").isSortedByDescending { it.length }}")
    println("isSortedWith: ${listOf("B", "a", "C").isSortedWith(String.CASE_INSENSITIVE_ORDER)} ${words.isSortedWith(naturalOrder())}")
    println("arrays: ${intArrayOf(1, 2, 3).isSorted()} ${arrayOf("b", "a").isSorted()} ${doubleArrayOf(3.0, 1.0).isSortedDescending()}")
    println("array by: ${arrayOf("x", "yy").isSortedBy { it.length }} ${charArrayOf('c', 'a').isSortedWith(reverseOrder())}")
    println("sequence: ${generateSequence(1) { it * 2 }.take(10).isSorted()} ${sequenceOf(2, 1).isSortedBy { it }}")

    // onEachIndexed on maps and strings
    val seen = mutableListOf<String>()
    val map = linkedMapOf("a" to 1, "b" to 2)
    val same = map.onEachIndexed { i, (k, v) -> seen += "$i:$k=$v" }
    println("map onEachIndexed: $seen ${same === map}")
    val chars = StringBuilder()
    println("string onEachIndexed: ${"hey".onEachIndexed { i, c -> chars.append(c).append(i) }} $chars")

    // Map.mapTo and filterNotTo
    println("mapTo: ${map.mapTo(mutableListOf("start")) { (k, v) -> "$k$v" }}")
    println("filterNotTo: ${map.filterNotTo(mutableMapOf("z" to 0)) { it.value == 1 }}")

    // Iterator.withIndex and IndexedValue
    val indexed = listOf("x", "y").iterator().withIndex()
    for ((i, v) in indexed) println("withIndex $i $v")
    val iv = IndexedValue(3, "three")
    println("IndexedValue: $iv ${iv.copy(index = 4)} ${iv == IndexedValue(3, "three")} ${iv.hashCode() == IndexedValue(3, "three").hashCode()}")

    // Sequence.unzip
    val (letters, numbers) = sequenceOf("a" to 1, "b" to 2).unzip()
    println("unzip: $letters $numbers")

    // CharSequence extras
    val text = "one two three two one"
    println("findAnyOf: ${text.findAnyOf(listOf("two", "three"))} ${text.findAnyOf(listOf("TWO"), ignoreCase = true)} ${text.findAnyOf(listOf("x"))}")
    println("findLastAnyOf: ${text.findLastAnyOf(listOf("one", "two"))} ${text.findLastAnyOf(listOf("two"), 10)}")
    println("lastIndexOfAny: ${text.lastIndexOfAny(listOf("two", "one"))} ${text.lastIndexOfAny(charArrayOf('t', 'w'))} ${text.lastIndexOfAny(listOf("z"))}")
    println("filterTo: ${"a1b2c3".filterTo(StringBuilder("#")) { it.isDigit() }}")
    println("reduceRightOrNull: ${"abc".reduceRightOrNull { c, acc -> if (c > acc) c else acc }} ${"".reduceRightOrNull { c, _ -> c }}")
    println("reduceRightIndexed: ${"abc".reduceRightIndexed { i, c, acc -> if (i == 0) c else acc }}")
    println("reduceRightIndexedOrNull: ${"xyz".reduceRightIndexedOrNull { i, c, acc -> if (i == 1) c else acc }}")
    println("replaceIndent: [${"    a\n      b\n".replaceIndent("> ")}]")
    println("replaceIndentByMargin: [${"  |x\n  |  y".replaceIndentByMargin("- ")}]")
}
