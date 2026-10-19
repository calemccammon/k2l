data class Item(val name: String, val price: Int)

val items = listOf(Item("pen", 3), Item("book", 12), Item("cup", 7), Item("lamp", 12))

fun partitions(xs: List<Int>, stopAt: Int): String {
    val (small, big) = xs.partition { if (it == stopAt) return "stopped at $it"; it < 5 }
    return "$small $big"
}

fun maxBys(stopAt: Int): String {
    val a = items.maxByOrNull { if (it.price == stopAt) return "max stop ${it.name}"; it.price }
    val b = items.minByOrNull { it.price }
    val c = items.maxBy { it.price + if (it.name == "zzz") return "never" else 0 }
    val d = items.minBy { if (it.name == "x") return "never" else it.name }
    val e = emptyList<Item>().maxByOrNull { if (it.price == 0) return "no" else it.price }
    return "${a?.name} ${b?.name} ${c.name} ${d.name} $e"
}

fun extremes(stopAt: Int): String {
    val a = items.maxOf { if (it.price == stopAt) return "maxOf stop"; it.name }
    val b = items.minOf { if (it.price == -1) return "never"; it.price }
    val c = emptyList<Int>().maxOfOrNull { if (it == 0) return "no" else it }
    val d = items.maxOfOrNull { if (it.price == 99) return "never" else it.price * 2 }
    return "$a $b $c $d"
}

fun reduces(xs: List<Int>, stopAt: Int): String {
    val a = xs.reduce { acc, x -> if (x == stopAt) return "reduce stop"; acc + x }
    val b = xs.reduceOrNull { acc, x -> if (x == -7) return "never"; acc * x }
    val c = emptyList<Int>().reduceOrNull { acc, x -> if (x == 0) return "no" else acc + x }
    return "$a $b $c"
}

fun emptyReduce(): String {
    try {
        emptyList<Int>().reduce { a, b -> if (a == 0) return "no" else a + b }
    } catch (e: UnsupportedOperationException) {
        return "caught ${e.message}"
    }
    return "none"
}

fun distincts(xs: List<String>, stop: String): List<String> =
    xs.distinctBy { if (it == stop) return listOf("stopped"); it.length }

fun indexedOps(xs: List<Int>, stopAt: Int): String {
    val a = xs.filterIndexed { i, x -> if (x == stopAt) return "idx stop $i"; i % 2 == 0 && x > 0 }
    val b = xs.mapIndexed { i, x -> if (x == -100) return "never"; i * x }
    return "$a $b"
}

fun indexSearch(xs: List<Int>, stopAt: Int): String {
    val a = xs.indexOfFirst { if (it == stopAt) return "first stop"; it > 2 }
    val b = xs.indexOfLast { if (it == -1) return "never"; it > 2 }
    val c = xs.indexOfFirst { it > 1000 && if (it == -5) return "never" else true }
    return "$a $b $c"
}

fun lasts(xs: List<Int>, stopAt: Int): String {
    val a = xs.last { if (it == stopAt) return "last stop"; it % 2 == 1 }
    val b = xs.lastOrNull { if (it == -3) return "never"; it > 100 }
    val c = xs.findLast { if (it == -3) return "never"; it < 3 }
    return "$a $b $c"
}

fun lastNone(xs: List<Int>): String {
    try {
        xs.last { if (it == -3) return "never"; it > 100 }
    } catch (e: NoSuchElementException) {
        return "caught ${e.message}"
    }
    return "none"
}

fun singles(xs: List<Int>, stopAt: Int): String {
    val a = xs.single { if (it == stopAt) return "single stop"; it == 3 }
    val b = xs.singleOrNull { if (it == -3) return "never"; it > 0 }
    val c = xs.singleOrNull { it == 3 && if (it == -3) return "never" else true }
    return "$a $b $c"
}

fun singleErrors(xs: List<Int>): String {
    val r = StringBuilder()
    try {
        xs.single { if (it == -3) return "never"; it > 0 }
    } catch (e: IllegalArgumentException) {
        r.append("many: ${e.message}; ")
    }
    try {
        xs.single { if (it == -3) return "never"; it > 100 }
    } catch (e: NoSuchElementException) {
        r.append("none: ${e.message}")
    }
    return r.toString()
}

fun trims(xs: List<Int>, stopAt: Int): String {
    val a = xs.takeLastWhile { if (it == stopAt) return "tlw stop"; it > 2 }
    val b = xs.dropWhile { if (it == -3) return "never"; it < 3 }
    val c = xs.dropLastWhile { if (it == -3) return "never"; it > 4 }
    return "$a $b $c"
}

fun zips(xs: List<Int>, ys: List<String>, stopAt: Int): String {
    val a = xs.zip(ys) { x, y -> if (x == stopAt) return "zip stop $y"; "$x$y" }
    val b = xs.zip(ys.toTypedArray()) { x, y -> if (x == -3) return "never"; y + x }
    return "$a $b"
}

fun maps(m: Map<String, Int>, stopAt: Int): String {
    val a = m.filter { if (it.value == stopAt) return "filter stop ${it.key}"; it.value > 1 }
    val b = m.filterNot { (k, v) -> if (v == -3) return "never"; k == "a" }
    val c = m.mapValues { if (it.key == "zzz") return "never"; it.value * 10 }
    val d = m.mapKeys { (k, v) -> if (v == -3) return "never"; k.uppercase() + v }
    val e = m.filterKeys { if (it == "zzz") return "never"; it != "b" }
    val f = m.filterValues { if (it == -3) return "never"; it < 3 }
    val seen = mutableListOf<String>()
    val g = m.onEach { if (it.value == -3) return "never"; seen.add(it.key) }
    return "$a $b $c $d $e $f $seen ${g.size}"
}

fun mapExtremes(m: Map<String, Int>): String {
    val a = m.maxByOrNull { if (it.value == -3) return "never"; it.value }
    val b = m.minBy { if (it.value == -3) return "never"; it.value }
    val c = m.maxOf { if (it.value == -3) return "never"; it.value }
    return "$a $b $c"
}

fun flatMaps(xs: List<Int>, stopAt: Int): List<Int> =
    xs.flatMap { x -> if (x == stopAt) return listOf(-1); sequenceOf(x, x * 10) }

fun builders(stopAt: Int): String {
    val l = buildList {
        for (i in 1..5) {
            if (i == stopAt) return "buildList stop"
            add(i)
        }
    }
    val s = buildString {
        for (c in "abc") {
            if (c == 'z') return "buildString stop"
            append(c)
        }
    }
    val m = buildMap {
        put("k", 1)
        if (stopAt == 99) return "buildMap stop"
    }
    var n = 0
    repeat(3) {
        if (stopAt == 98) return "repeat stop"
        n += it
    }
    return "$l $s $m $n"
}

fun arrays(stopAt: Int): String {
    val arr = arrayOf(5, 3, 8)
    val a = arr.sortedBy { -it }
    val b = arr.last { if (it == -1) return "never"; it > 4 }
    val c = arr.reduce { acc, x -> if (x == -1) return "never"; acc + x }
    val d = arr.partition { if (it == -1) return "never"; it > 4 }
    return "$a $b $c $d"
}

fun sets(stopAt: Int): String {
    val s = setOf(4, 8, 15, 16)
    val a = s.last { if (it == stopAt) return "set stop"; it % 2 == 0 }
    val b = s.maxByOrNull { if (it == -1) return "never"; it % 5 }
    return "$a $b"
}

fun main() {
    println(partitions(listOf(1, 9, 3, 7), 100))
    println(partitions(listOf(1, 9, 3, 7), 3))
    println(maxBys(100))
    println(maxBys(7))
    println(extremes(100))
    println(extremes(7))
    println(reduces(listOf(1, 2, 3), 100))
    println(reduces(listOf(1, 2, 3), 3))
    println(emptyReduce())
    println(distincts(listOf("a", "bb", "c", "dd", "eee"), "zz"))
    println(distincts(listOf("a", "bb", "c", "dd", "eee"), "dd"))
    println(indexedOps(listOf(4, 5, 6, 7), 100))
    println(indexedOps(listOf(4, 5, 6, 7), 6))
    println(indexSearch(listOf(1, 3, 2, 5, 1), 100))
    println(indexSearch(listOf(1, 3, 2, 5, 1), 3))
    println(lasts(listOf(1, 2, 3, 4), 100))
    println(lasts(listOf(1, 2, 3, 4), 3))
    println(lastNone(listOf(1, 2)))
    println(singles(listOf(1, 3, 5), 100))
    println(singles(listOf(1, 3, 5), 3))
    println(singleErrors(listOf(1, 2)))
    println(trims(listOf(1, 5, 6, 3, 4), 100))
    println(trims(listOf(1, 5, 6, 3, 4), 6))
    println(zips(listOf(1, 2, 3), listOf("a", "b"), 100))
    println(zips(listOf(1, 2, 3), listOf("a", "b"), 2))
    println(maps(mapOf("a" to 1, "b" to 2, "c" to 3), 100))
    println(maps(mapOf("a" to 1, "b" to 2, "c" to 3), 2))
    println(mapExtremes(mapOf("a" to 1, "b" to 5, "c" to 5)))
    println(flatMaps(listOf(1, 2), 100))
    println(flatMaps(listOf(1, 2), 2))
    println(builders(100))
    println(builders(3))
    println(builders(99))
    println(builders(98))
    println(arrays(100))
    println(arrays(8))
    println(sets(100))
    println(sets(15))
}
