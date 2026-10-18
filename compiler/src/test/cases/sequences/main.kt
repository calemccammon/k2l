data class Item(val name: String, val price: Int)

fun naturals(): Sequence<Int> = generateSequence(1) { it + 1 }

fun fibonacci(): Sequence<Long> = generateSequence(Pair(0L, 1L)) { (a, b) -> Pair(b, a + b) }.map { it.first }

fun laziness() {
    println("-- laziness")
    val result = listOf(1, 2, 3, 4).asSequence()
        .map {
            println("map $it")
            it * 10
        }
        .filter {
            println("filter $it")
            it > 15
        }
        .first()
    println("first = $result")

    val pipeline = sequenceOf("a", "bb", "ccc").onEach { println("saw $it") }.map { it.length }
    println("nothing evaluated yet")
    for (n in pipeline) println("got $n")
    pipeline.forEach { println("again $it") }

    val folded = (1..4).asSequence()
        .map {
            println("m$it")
            it
        }
        .fold(0) { acc, x ->
            println("f$x")
            acc + x
        }
    println("folded $folded")
}

fun infinite() {
    println("-- infinite")
    println(naturals().take(5).toList())
    println(naturals().filter { it % 3 == 0 }.map { it * it }.take(4).toList())
    println(naturals().first { it * it > 50 })
    println(naturals().takeWhile { it < 6 }.joinToString("-"))
    println(naturals().drop(3).take(2).toList())
    println(naturals().dropWhile { it < 10 }.firstOrNull())
    println(naturals().any { it > 100 })
    println(naturals().elementAt(9))
    println(naturals().indexOf(7))
    println(naturals().contains(12))
    println(fibonacci().take(10).toList())
    println(naturals().joinToString(limit = 3))
    println(naturals().zip(naturals().map { it * it }).take(3).toList())
    var calls = 0
    val counted = generateSequence(1) {
        calls++
        it * 2
    }
    println(counted.take(4).toList())
    println("next called $calls times")
    var n = 3
    val countdown = generateSequence { if (n > 0) n-- else null }
    println(countdown.toList())
    try {
        countdown.toList()
    } catch (e: IllegalStateException) {
        println("once: ${e.message}")
    }
    println(generateSequence({ 10 }) { if (it > 7) it - 1 else null }.toList())
    val nothing: Int? = null
    println(generateSequence(nothing) { it + 1 }.count())
}

fun operations() {
    println("-- operations")
    val items = listOf(Item("apple", 3), Item("pear", 5), Item("fig", 2), Item("kiwi", 5))
    val seq = items.asSequence()
    println(seq.map { it.name }.toList())
    println(seq.filterNot { it.price > 3 }.map { it.name }.toSet())
    println(seq.mapNotNull { if (it.price > 2) it.name.uppercase() else null }.toList())
    println(seq.mapIndexed { i, item -> "$i:${item.name}" }.toList())
    println(seq.flatMap { it.name.asSequence() }.distinct().count())
    println(seq.flatMap { listOf(it.price, -it.price) }.toList())
    println(seq.map { it.price }.distinct().toList())
    println(seq.distinctBy { it.price }.map { it.name }.toList())
    println(seq.withIndex().map { (i, item) -> i * item.price }.sum())
    println(seq.sumOf { it.price })
    println(seq.map { it.price.toDouble() }.sum())
    println(seq.map { it.price }.average())
    println(seq.count { it.price == 5 })
    println(seq.all { it.price > 1 })
    println(seq.none { it.name.isEmpty() })
    println(seq.maxBy { it.price }.name)
    println(seq.minByOrNull { it.price }?.name)
    println(seq.map { it.price }.maxOrNull())
    println(seq.map { it.name }.min())
    println(seq.maxOf { it.name.length })
    println(seq.sortedBy { it.price }.map { it.name }.toList())
    println(seq.sortedByDescending { it.name }.first().name)
    println(seq.map { it.price }.sorted().toList())
    println(seq.map { it.price }.sortedDescending().toList())
    println(seq.sortedWith(compareBy({ it.price }, { it.name })).map { it.name }.toList())
    println(seq.associate { it.name to it.price })
    println(seq.associateBy { it.name.first() }.keys)
    println(seq.groupBy { it.price }.mapValues { (_, v) -> v.size })
    println(seq.map { it.name to it.price }.toMap())
    println(seq.partition { it.price > 3 }.first.map { it.name })
    println(seq.map { it.price }.reduce { a, b -> a * b })
    println(seq.find { it.price == 2 })
    println(seq.findLast { it.price == 5 })
    println(seq.last().name)
    println(seq.lastOrNull { it.price > 100 })
    println(seq.single { it.name == "fig" })
    println(seq.singleOrNull { it.price == 5 })
    println(seq.map { it.name }.chunked(3).toList())
    println((1..7).asSequence().windowed(3, 2).toList())
    println((1..7).asSequence().windowed(3, 3, partialWindows = true).map { it.sum() }.toList())
    println(sequenceOf(1, 2, 3).plus(4).plus(listOf(5, 6)).plus(sequenceOf(7)).toList())
    println(sequenceOf(1, 2, 3, 2).minus(2).toList())
    println(sequenceOf(3, 1, 2).zip(sequenceOf("c", "a")) { n, s -> "$s$n" }.toList())
    println(sequenceOf(1, 2, 3).zipWithNext().toList())
    println(sequenceOf(1, 2, 3, 4).runningFold(0) { acc, x -> acc + x }.toList())
    println(sequenceOf(1, 2, 3, 4).scan(1) { acc, x -> acc * x }.toList())
    println(sequenceOf(1, 2, 3, 4).runningReduce { acc, x -> acc + x }.toList())
    println(sequenceOf(1, null, 2, null).filterNotNull().toList())
    println(sequenceOf("x", "y").filterIndexed { i, _ -> i == 1 }.toList())
    println(sequenceOf(1, 2, 3).foldIndexed(0) { i, acc, x -> acc + i * x })
    sequenceOf("p", "q").forEachIndexed { i, s -> println("$i=$s") }
    println(emptySequence<Int>().firstOrNull())
    println(emptySequence<String>().joinToString(prefix = "[", postfix = "]"))
    println(sequenceOf(1, 2).toMutableList().also { it.add(3) })
    println(listOf(3, 4).asSequence().ifEmpty { sequenceOf(0) }.toList())
    println(emptySequence<Int>().ifEmpty { sequenceOf(0) }.toList())
}

fun sources() {
    println("-- sources")
    println("hey".asSequence().map { it.uppercaseChar() }.joinToString(""))
    println(mapOf(1 to "one", 2 to "two").asSequence().map { "${it.key}=${it.value}" }.toList())
    println(arrayOf(5, 6, 7).asSequence().filter { it != 6 }.toList())
    println(setOf("s", "t").asSequence().toList())
    println((10 downTo 1 step 3).asSequence().toList())
    val custom = Sequence { listOf(1, 2, 3).iterator() }
    println(custom.map { it * 2 }.toList())
    println(custom.toList())
    val it = sequenceOf(4, 5, 6).iterator()
    while (it.hasNext()) print("${it.next()} ")
    println()
    val once = listOf(7, 8).iterator().asSequence()
    println(once.toList())
    try {
        once.toList()
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    val reusable = listOf(1, 2).asSequence().map { it + 1 }
    println(reusable.toList() + reusable.toList())
    val s: Any = reusable
    println(s is Sequence<*>)
    for ((i, v) in sequenceOf("a", "b").withIndex()) println("$i -> $v")
    println(listOf(0) + sequenceOf(1, 2))
    val target = mutableListOf(1)
    target.addAll(sequenceOf(2, 3))
    println(target)
    println(Sequence { Countdown(3) }.map { it * 10 }.toList())
    println(Countdown(2).asSequence().toList())
    val manual: Iterator<Int> = Countdown(2)
    for (x in manual) println("manual $x")
}

class Countdown(private var n: Int) : Iterator<Int> {
    override fun hasNext() = n > 0

    override fun next(): Int = n--
}

fun errors() {
    println("-- errors")
    try {
        emptySequence<Int>().first()
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
    try {
        sequenceOf(1, 2).single()
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        naturals().take(3).elementAt(5)
    } catch (e: IndexOutOfBoundsException) {
        println(e.message)
    }
    try {
        emptySequence<Int>().reduce { a, b -> a + b }
    } catch (e: UnsupportedOperationException) {
        println(e.message)
    }
    try {
        naturals().take(-1)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        sequenceOf(1, 2, 3).map { if (it == 2) throw IllegalStateException("bad $it") else it }.forEach { println("ok $it") }
    } catch (e: IllegalStateException) {
        println("caught ${e.message}")
    }
}

fun main() {
    laziness()
    infinite()
    operations()
    sources()
    errors()
}
