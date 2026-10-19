fun results(r: Result<Int>, which: Int): String {
    val a = r.getOrElse { if (which == 0) return "getOrElse returned ${it.message}" else -1 }
    r.onFailure { if (which == 1) return "onFailure returned ${it.message}" }
    r.onSuccess { if (which == 2) return "onSuccess returned $it" }
    val b = r.fold({ if (which == 3) return "fold success returned" else it * 2 }, { if (which == 4) return "fold failure returned" else -2 })
    val c = r.map { if (which == 5) return "map returned" else it + 1 }
    val d = r.recover { if (which == 6) return "recover returned ${it.message}" else 0 }
    return "$a $b ${c.getOrNull()} ${d.getOrNull()} ${c.isFailure}"
}

fun notNull(xs: List<Int>, which: Int): String {
    val a = xs.firstNotNullOf { if (which == 0 && it == 3) return "firstNotNullOf returned" else if (it > 4) it * 10 else null }
    val b = xs.firstNotNullOfOrNull { if (which == 1 && it == 3) return "firstNotNullOfOrNull returned" else if (it > 100) it else null }
    return "$a $b"
}

fun folds(xs: List<Int>, arr: IntArray, which: Int): String {
    val seen = mutableListOf<Int>()
    xs.onEachIndexed { i, x -> if (which == 0 && x == 3) return "onEachIndexed returned at $i"; seen.add(i * x) }
    val a = xs.foldRight("") { x, acc -> if (which == 1 && x == 3) return "foldRight returned acc=$acc" else acc + x }
    val b = xs.reduceRight { x, acc -> if (which == 2 && x == 3) return "reduceRight returned acc=$acc" else x - acc }
    val c = arr.foldRight(0) { x, acc -> if (which == 3 && x == 3) return "array foldRight returned acc=$acc" else acc * 10 + x }
    val d = arr.reduceRight { x, acc -> if (which == 4 && x == 2) return "array reduceRight returned acc=$acc" else x + acc }
    return "$seen $a $b $c $d"
}

fun emptyFolds(which: Int): String {
    try {
        if (which == 0) emptyList<Int>().reduceRight { x, acc -> if (x > 100) return "never" else x + acc }
        if (which == 1) intArrayOf().reduceRight { x, acc -> if (x > 100) return "never" else x + acc }
        if (which == 2) emptyList<Int>().reduceIndexed { i, acc, x -> if (x > 100) return "never" else x + acc + i }
        if (which == 3) intArrayOf().reduceIndexed { i, acc, x -> if (x > 100) return "never" else x + acc + i }
        if (which == 4) emptyList<Int>().firstNotNullOf { if (it > 100) return "never" else null }
        if (which == 5) emptyList<Int>().reduceRight { x, acc -> if (x > 100) return "never" else x + acc }
    } catch (e: Exception) {
        return "${e::class.simpleName}: ${e.message}"
    }
    return "no error"
}

fun maps(m: Map<String, Int>, which: Int): String {
    val values = linkedMapOf<String, Int>()
    m.mapValuesTo(values) { if (which == 0 && it.value == 2) return "mapValuesTo returned, kept $values" else it.value * 10 }
    val keys = linkedMapOf<String, Int>()
    m.mapKeysTo(keys) { if (which == 1 && it.value == 2) return "mapKeysTo returned, kept $keys" else it.key + it.key }
    val kept = linkedMapOf<String, Int>()
    m.filterTo(kept) { if (which == 2 && it.value == 2) return "filterTo returned, kept $kept" else it.value % 2 == 1 }
    val list = mutableListOf<String>()
    m.mapTo(list) { if (which == 3 && it.value == 2) return "mapTo returned, kept $list" else it.key }
    return "$values $keys $kept $list"
}

fun main() {
    val ok = Result.success(5)
    val bad = Result.failure<Int>(IllegalStateException("broken"))
    println(results(ok, 99))
    println(results(bad, 99))
    for (which in 0..6) {
        println(results(ok, which))
        println(results(bad, which))
    }
    val xs = listOf(1, 2, 3, 4, 5, 6)
    println(notNull(xs, 99))
    println(notNull(xs, 0))
    println(notNull(xs, 1))
    for (which in 0..4) println(folds(xs, intArrayOf(1, 2, 3), which))
    println(folds(xs, intArrayOf(1, 2, 3), 99))
    for (which in 0..4) println(emptyFolds(which))
    println(emptyFolds(9))
    val m = linkedMapOf("a" to 1, "b" to 2, "c" to 3)
    println(maps(m, 99))
    for (which in 0..3) println(maps(m, which))
}
