// CharSequence operations over the characters (folds and reductions, indexed maps, *To variants, scans), the
// windowed/chunked sequences of a string, and the right-to-left reductions of lists and arrays
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    val word = "kotlin"
    t("foldRight") { word.foldRight("") { c, acc -> acc + c.uppercaseChar() } }
    t("foldRightIndexed") { word.foldRightIndexed(0) { i, c, acc -> acc + i * c.code } }
    t("reduceRight") { "abc".reduceRight { c, acc -> if (c > acc) c else acc } }
    t("reduceIndexed") { "abcd".reduceIndexed { i, acc, c -> if (i % 2 == 0) acc else c } }
    t("reduceIndexedOrNull") { listOf("".reduceIndexedOrNull { _, acc, _ -> acc }, "xy".reduceIndexedOrNull { _, _, c -> c }) }
    t("runningFold") { "abc".runningFold("") { acc, c -> acc + c } }
    t("scan") { "123".scan(0) { acc, c -> acc + c.digitToInt() } }
    t("runningFoldIndexed") { "ab".runningFoldIndexed(listOf<Int>()) { i, acc, c -> acc + (i + c.code) } }
    t("scanIndexed") { "xyz".scanIndexed("") { i, acc, c -> acc + i + c } }
    t("runningReduce") { "aZb".runningReduce { acc, c -> if (c < acc) c else acc } }
    t("runningReduceIndexed") { "abc".runningReduceIndexed { i, acc, c -> if (i == 1) c.uppercaseChar() else acc } }
    t("mapIndexedNotNull") { "a1b2".mapIndexedNotNull { i, c -> if (c.isDigit()) "$i:$c" else null } }
    t("mapIndexedTo") { "ab".mapIndexedTo(mutableListOf("start")) { i, c -> "$c$i" } }
    t("mapIndexedNotNullTo") { "a1".mapIndexedNotNullTo(mutableSetOf<Int>()) { i, c -> if (c.isLetter()) i else null } }
    t("mapTo") { "hello".mapTo(mutableSetOf()) { it.code } .size }
    t("flatMapIndexed") { "ab".flatMapIndexed { i, c -> List(i + 1) { c } } }
    t("flatMapIndexedTo") { "xy".flatMapIndexedTo(mutableListOf(0)) { i, c -> listOf(i, c.code) } }
    t("associateByTo") { "abc".associateByTo(mutableMapOf()) { it.uppercaseChar() } }
    t("associateWithTo") { "ab".associateWithTo(sortedMapOf()) { it.code } }
    t("toCollection") { "banana".toCollection(sortedSetOf()) }
    t("toHashSet") { "mississippi".toHashSet().sorted() }
    t("maxOfOrNull") { listOf("abc".maxOfOrNull { it.code }, "".minOfOrNull { it.code }) }
    t("firstNotNullOf") { "ab3c4".firstNotNullOf { it.digitToIntOrNull() } }
    t("firstNotNullOfOrNull") { "abc".firstNotNullOfOrNull { it.digitToIntOrNull() } }
    t("firstNotNullOf none") { "abc".firstNotNullOf { it.digitToIntOrNull() } }
    t("randomOrNull") { listOf("".randomOrNull(), "aaa".randomOrNull()) }

    t("windowedSequence") { "abcde".windowedSequence(3).toList() }
    t("windowedSequence step") { "abcdefg".windowedSequence(3, 2, partialWindows = true).map { it.reversed() }.toList() }
    t("chunkedSequence") { "abcdefgh".chunkedSequence(3).joinToString("|") }

    val numbers = listOf(1, 2, 3, 4)
    t("reduceRightOrNull") { listOf(numbers.reduceRightOrNull { x, acc -> x - acc }, emptyList<Int>().reduceRightOrNull { x, acc -> x + acc }) }
    t("reduceRightIndexed") { numbers.reduceRightIndexed { i, x, acc -> acc * 10 + x + i } }
    t("reduceRightIndexed empty") { emptyList<Int>().reduceRightIndexed { _, x, acc -> x + acc } }
    t("reduceRightIndexedOrNull") { listOf("a", "b", "c").reduceRightIndexedOrNull { i, s, acc -> "$acc$s$i" } }
    val array = arrayOf("x", "y", "z")
    t("array reduceRightOrNull") { array.reduceRightOrNull { s, acc -> acc + s } }
    t("array reduceRightIndexed") { intArrayOf(5, 6, 7).reduceRightIndexed { i, x, acc -> acc - x * i } }
    t("array empty") { emptyArray<String>().reduceRightIndexed { _, s, acc -> s + acc } }
}
