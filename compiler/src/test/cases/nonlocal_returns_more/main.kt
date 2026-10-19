import java.io.Closeable
import kotlin.system.measureTimeMillis

class Res(val name: String) : Closeable {
    override fun close() {
        println("closed $name")
    }
}

class Fussy : AutoCloseable {
    override fun close() {
        println("closing fussy")
        throw IllegalStateException("close failed")
    }
}

// *To functions: the destination is filled up to the element that returns
fun toVariants(xs: List<Int>, which: Int): String {
    val mapped = mutableListOf<Int>()
    xs.mapTo(mapped) { if (which == 0 && it == 3) return "mapTo stopped, kept $mapped" else it * 2 }
    val kept = mutableSetOf<Int>()
    xs.filterTo(kept) { if (which == 1 && it == 3) return "filterTo stopped, kept $kept" else it % 2 == 0 }
    val dropped = mutableListOf<Int>()
    xs.filterNotTo(dropped) { if (which == 2 && it == 3) return "filterNotTo stopped, kept $dropped" else it % 2 == 0 }
    val nn = mutableListOf<String>()
    xs.mapNotNullTo(nn) { if (which == 3 && it == 3) return "mapNotNullTo stopped, kept $nn" else if (it % 2 == 0) "e$it" else null }
    val flat = mutableListOf<Int>()
    xs.flatMapTo(flat) { if (which == 4 && it == 3) return "flatMapTo stopped, kept $flat" else listOf(it, it) }
    val assoc = linkedMapOf<Int, String>()
    xs.associateTo(assoc) { if (which == 5 && it == 3) return "associateTo stopped, kept $assoc" else it to "v$it" }
    val by = linkedMapOf<Int, Int>()
    xs.associateByTo(by) { if (which == 6 && it == 3) return "associateByTo stopped, kept $by" else it * 10 }
    val with = linkedMapOf<Int, Int>()
    xs.associateWithTo(with) { if (which == 7 && it == 3) return "associateWithTo stopped, kept $with" else it * it }
    val groups = linkedMapOf<Int, MutableList<Int>>()
    xs.groupByTo(groups) { if (which == 8 && it == 3) return "groupByTo stopped, kept $groups" else it % 3 }
    val idx = mutableListOf<Int>()
    xs.filterIndexedTo(idx) { i, x -> if (which == 9 && x == 3) return "filterIndexedTo stopped, kept $idx" else i % 2 == 0 }
    val idx2 = mutableListOf<String>()
    xs.mapIndexedTo(idx2) { i, x -> if (which == 10 && x == 3) return "mapIndexedTo stopped, kept $idx2" else "$i:$x" }
    return "finished $mapped $kept $dropped $nn $flat $assoc $by $with $groups $idx $idx2"
}

fun indexedAndRunning(xs: List<Int>, which: Int): String {
    val a = xs.mapIndexedNotNull { i, x -> if (which == 0 && x == 3) return "mapIndexedNotNull stopped at $i" else if (i % 2 == 0) x else null }
    val b = xs.flatMapIndexed { i, x -> if (which == 1 && x == 3) return "flatMapIndexed stopped at $i" else listOf(i, x) }
    val c = xs.reduceIndexed { i, acc, x -> if (which == 2 && x == 3) return "reduceIndexed stopped at $i acc $acc" else acc + x * i }
    val d = xs.foldIndexed(100) { i, acc, x -> if (which == 3 && x == 3) return "foldIndexed stopped at $i acc $acc" else acc + x * i }
    val e = xs.runningFold(0) { acc, x -> if (which == 4 && x == 3) return "runningFold stopped acc $acc" else acc + x }
    val f = xs.runningReduce { acc, x -> if (which == 5 && x == 3) return "runningReduce stopped acc $acc" else acc + x }
    val g = xs.scan("s") { acc, x -> if (which == 6 && x == 3) return "scan stopped acc $acc" else acc + x }
    val h = xs.sumOf { if (which == 7 && it == 3) return "sumOf stopped" else it.toLong() }
    return "finished $a $b $c $d $e $f $g $h"
}

fun lookups(m: MutableMap<String, Int>, xs: List<Int>, key: String, i: Int): String {
    val a = m.getOrPut(key) { if (key == "boom") return "getOrPut returned" else key.length }
    val b = m.getOrElse(key + "?") { if (key == "bang") return "getOrElse returned" else -1 }
    val c = xs.getOrElse(i) { if (it > 100) return "list getOrElse returned $it" else it * -1 }
    val d = xs.ifEmpty { return "empty list" }
    val e = emptyMap<String, Int>().ifEmpty { mapOf("fallback" to 1) }
    return "a=$a b=$b c=$c d=$d e=$e m=$m"
}

fun texts(s: String, which: Int): String {
    val upper = s.map { if (which == 0 && it == 'c') return "map stopped" else it.uppercaseChar() }
    val letters = s.filter { if (which == 1 && it == 'c') return "filter stopped" else it != 'a' }
    val n = s.count { if (which == 2 && it == 'c') return "count stopped" else it == 'a' }
    val any = s.any { if (which == 3 && it == 'c') return "any stopped" else it == 'z' }
    val all = s.all { if (which == 4 && it == 'c') return "all stopped" else it != 'z' }
    val first = s.indexOfFirst { if (which == 5 && it == 'c') return "indexOfFirst stopped" else it == 'c' }
    val taken = s.takeWhile { if (which == 6 && it == 'c') return "takeWhile stopped" else it != 'c' }
    val dropped = s.dropWhile { if (which == 7 && it == 'c') return "dropWhile stopped" else it != 'c' }
    val sum = s.sumOf { if (which == 8 && it == 'c') return "sumOf stopped" else it.code }
    s.forEachIndexed { i, c -> if (which == 9 && c == 'c') return "forEachIndexed stopped at $i" }
    val blank = "  ".ifBlank { return "blank" }
    return "$upper $letters $n $any $all $first $taken $dropped $sum $blank"
}

fun resources(fail: Boolean, early: Boolean): String {
    val value = Res("a").use { res ->
        if (early) return "early from ${res.name}"
        if (fail) throw IllegalArgumentException("body failed")
        res.name.length
    }
    return "value $value"
}

fun nested(early: Boolean): String {
    Res("outer").use { outer ->
        Res("inner").use { inner ->
            if (early) return "early from ${inner.name} in ${outer.name}"
        }
    }
    return "ran to the end"
}

fun fussy(): String {
    try {
        Fussy().use { throw IllegalArgumentException("body failed") }
    } catch (e: IllegalArgumentException) {
        return "caught ${e.message}"
    }
    return "not reached"
}

fun locked(lock: Any, early: Boolean): String {
    val v = synchronized(lock) { if (early) return "left the lock" else 42 }
    return "got $v"
}

fun caught(early: Int): String {
    val r = runCatching {
        when (early) {
            0 -> return "returned from runCatching"
            1 -> error("failed inside")
            else -> early * 10
        }
    }
    return "result ${r.isSuccess} ${r.getOrNull()} ${r.exceptionOrNull()?.message}"
}

fun timed(early: Boolean): String {
    val ms = measureTimeMillis { if (early) return "timed block left" }
    return "took ${ms >= 0}"
}

fun main() {
    val xs = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
    println(toVariants(xs, 99))
    for (which in 0..10) println(toVariants(xs, which))
    println(toVariants(emptyList(), 0))
    println(indexedAndRunning(xs, 99))
    for (which in 0..7) println(indexedAndRunning(xs, which))
    val m = mutableMapOf("x" to 1)
    println(lookups(m, listOf(5, 6), "abc", 1))
    println(lookups(m, listOf(5, 6), "abc", 7))
    println(lookups(m, listOf(500, 600), "abc", -1))
    println(lookups(m, listOf(500, 600), "abc", 5))
    println(lookups(m, emptyList(), "abc", 0))
    println(lookups(m, listOf(1), "boom", 0))
    println(lookups(m, listOf(1), "bang", 0))
    println(m)
    println(texts("bcad", 99))
    for (which in 0..9) println(texts("bcad", which))
    println(resources(fail = false, early = false))
    println(resources(fail = false, early = true))
    try {
        resources(fail = true, early = false)
    } catch (e: IllegalArgumentException) {
        println("caught ${e.message}")
    }
    println(nested(early = true))
    println(nested(early = false))
    println(fussy())
    println(locked("lock", early = true))
    println(locked("lock", early = false))
    println(caught(0))
    println(caught(1))
    println(caught(3))
    println(timed(early = true))
    println(timed(early = false))
}
