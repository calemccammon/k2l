data class Item(val name: String, val price: Int)

fun firstBig(xs: List<Int>): String {
    val doubled = xs.map {
        if (it > 100) return "too big: $it"
        it * 2
    }
    return "ok $doubled"
}

fun mapNotNullStop(xs: List<String>): List<Int> {
    return xs.mapNotNull {
        if (it == "stop") return emptyList()
        it.toIntOrNull()
    }
}

fun filtered(xs: List<Int>): List<Int> {
    val kept = xs.filter {
        if (it < 0) return listOf(-1)
        it % 2 == 0
    }
    val dropped = xs.filterNot {
        if (it == 7) return listOf(7)
        it % 2 == 0
    }
    return kept + dropped
}

fun anyAllNone(xs: List<Int>): String {
    val a = xs.any { if (it == 99) return "found 99 in any"; it > 5 }
    val b = xs.all { if (it == 98) return "found 98 in all"; it > 0 }
    val c = xs.none { if (it == 97) return "found 97 in none"; it > 50 }
    return "$a $b $c"
}

fun firsts(xs: List<Int>): String {
    val f = xs.first { if (it == 13) return "unlucky"; it > 2 }
    val g = xs.firstOrNull { if (it == 14) return "unlucky 14"; it > 100 }
    val h = xs.find { if (it == 15) return "unlucky 15"; it > 3 }
    return "$f $g $h"
}

fun noMatch(xs: List<Int>): Int {
    return xs.first { if (it == 0) return -1; it > 1000 }
}

fun counting(xs: List<Int>): Int {
    val n = xs.count { if (it == 0) return -1; it > 1 }
    return n
}

fun summing(xs: List<Int>): Int {
    val total = xs.sumOf { if (it < 0) return -1; it * 10 }
    val half = xs.sumOf { if (it < 0) return -1; it / 2.0 }
    println(half)
    return total
}

fun indexed(xs: List<String>): String {
    xs.forEachIndexed { i, s -> if (s == "x") return "x at $i" }
    return "no x"
}

fun each(xs: List<Int>): List<Int> {
    val seen = mutableListOf<Int>()
    val back = xs.onEach {
        if (it == 3) return seen
        seen.add(it)
    }
    return back
}

fun takeWhileOrReturn(xs: List<Int>): List<Int> =
    xs.takeWhile {
        if (it == 100) return listOf(100)
        it < 4
    }

fun associating(items: List<Item>): String {
    val byName = items.associateBy { if (it.price < 0) return "negative ${it.name}"; it.name }
    val byLen = items.associateBy({ if (it.price < 0) return "neg"; it.name.length }, { it.price })
    val prices = items.associateWith { if (it.price < 0) return "negative price"; it.price }
    val pairs = items.associate { if (it.name.isEmpty()) return "empty name"; it.name to it.price * 2 }
    return "$byName | $byLen | $prices | $pairs"
}

fun grouping(xs: List<Int>): String {
    val g = xs.groupBy { if (it == 0) return "zero"; it % 3 }
    val h = xs.groupBy({ if (it == 0) return "zero"; it % 2 }, { "v$it" })
    return "$g $h"
}

fun folding(xs: List<Int>): Int = xs.fold(0) { acc, x ->
    if (x < 0) return acc
    acc + x
}

fun labeled(xs: List<Int>): List<Int> {
    val r = xs.map {
        if (it == 0) return@map -1
        if (it == 99) return emptyList()
        it
    }
    return r
}

fun nested(xss: List<List<Int>>): String {
    val r = xss.map { xs -> xs.map { if (it < 0) return "negative inside"; it + 1 } }
    return "$r"
}

fun nullable(xs: List<Int?>): List<Int> = xs.map { if (it == 0) return emptyList(); it ?: -1 }

fun overSet(s: Set<Int>): Int {
    for (x in s.filter { if (it == 4) return 4; it > 1 }) println("set $x")
    return 0
}

fun overMap(m: Map<String, Int>): String {
    val keys = m.map { (k, v) -> if (v < 0) return "negative $k"; k + v }
    val any = m.any { if (it.value == 99) return "99!"; it.value > 1 }
    return "$keys $any"
}

fun overArray(arr: Array<Int>): Int {
    val ys = arr.map { if (it == 0) return -1; it * 3 }
    return ys.sum()
}

fun overRange(): Int {
    val ys = (1..5).map { if (it == 4) return 40; it * it }
    return ys.sum()
}

fun inLoop(xss: List<List<Int>>): String {
    val out = StringBuilder()
    for (xs in xss) {
        val r = xs.filter { if (it == 0) return out.append("!").toString(); it > 1 }
        out.append(r)
    }
    return out.toString()
}

fun inTry(xs: List<Int>): String {
    try {
        val r = xs.map { if (it == 0) return "zero"; if (it == 1) throw IllegalStateException("one"); it }
        return "ok $r"
    } catch (e: IllegalStateException) {
        return "caught ${e.message}"
    } finally {
        println("inTry finally")
    }
}

fun valueOfMapAsExpression(xs: List<Int>): Int = xs.map { if (it > 10) return 10; it }.sum()

fun main() {
    println(firstBig(listOf(1, 2, 3)))
    println(firstBig(listOf(1, 200, 3)))
    println(mapNotNullStop(listOf("1", "a", "3")))
    println(mapNotNullStop(listOf("1", "stop", "3")))
    println(filtered(listOf(1, 2, 3, 4)))
    println(filtered(listOf(1, -2, 3)))
    println(filtered(listOf(1, 7)))
    println(anyAllNone(listOf(1, 2, 3)))
    println(anyAllNone(listOf(1, 99)))
    println(anyAllNone(listOf(1, 98)))
    println(anyAllNone(listOf(1, 97)))
    println(firsts(listOf(1, 4, 5)))
    println(firsts(listOf(1, 13, 5)))
    println(firsts(listOf(1, 4, 14)))
    println(firsts(listOf(1, 4, 15)))
    println(noMatch(listOf(5, 0)))
    try {
        noMatch(listOf(5, 6))
    } catch (e: NoSuchElementException) {
        println("NoSuchElementException: ${e.message}")
    }
    println(counting(listOf(1, 2, 3)))
    println(counting(listOf(1, 0, 3)))
    println(summing(listOf(1, 2, 3)))
    println(summing(listOf(1, -2, 3)))
    println(indexed(listOf("a", "x")))
    println(indexed(listOf("a")))
    println(each(listOf(1, 2, 4)))
    println(each(listOf(1, 2, 3, 4)))
    println(takeWhileOrReturn(listOf(1, 2, 5, 1)))
    println(takeWhileOrReturn(listOf(1, 100)))
    val items = listOf(Item("a", 1), Item("bb", 2))
    println(associating(items))
    println(associating(items + Item("c", -1)))
    println(grouping(listOf(1, 2, 3, 4, 5)))
    println(grouping(listOf(1, 0)))
    println(folding(listOf(1, 2, 3)))
    println(folding(listOf(1, 2, -3, 4)))
    println(labeled(listOf(1, 0, 2)))
    println(labeled(listOf(1, 99, 2)))
    println(nested(listOf(listOf(1), listOf(2, 3))))
    println(nested(listOf(listOf(1), listOf(-2, 3))))
    println(nullable(listOf(1, null, 3)))
    println(nullable(listOf(1, 0)))
    println(overSet(setOf(1, 2, 3)))
    println(overSet(setOf(1, 4)))
    println(overMap(linkedMapOf("a" to 1, "b" to 2)))
    println(overMap(linkedMapOf("a" to 1, "b" to -2)))
    println(overMap(linkedMapOf("a" to 99)))
    println(overArray(arrayOf(1, 2, 3)))
    println(overArray(arrayOf(1, 0)))
    println(overRange())
    println(inLoop(listOf(listOf(1, 2, 3), listOf(4, 0))))
    println(inTry(listOf(2, 3)))
    println(inTry(listOf(2, 0)))
    println(inTry(listOf(1)))
    println(valueOfMapAsExpression(listOf(1, 2)))
    println(valueOfMapAsExpression(listOf(1, 20)))
}
