class CountdownIterator(var current: Int) : Iterator<Int> {
    override fun hasNext() = current > 0
    override fun next() = current--
}

class Countdown(val from: Int) : Sequence<Int> {
    override fun iterator(): Iterator<Int> = CountdownIterator(from)
}

fun main() {
    val s = sequenceOf(1, 2, 3, 4)
    val it: Iterable<Int> = s.asIterable()
    println(it.map { it * 2 })
    for (x in it) print(x)
    println()
    val back = listOf(5, 6, 7).asIterable().asSequence().map { it + 1 }.toList()
    println(back)
    val dest = mutableListOf(0)
    s.filter { it % 2 == 0 }.toCollection(dest)
    println(dest)
    val set = s.toCollection(mutableSetOf())
    println(set)
    val itr = s.iterator()
    while (itr.hasNext()) print(itr.next())
    println()
    val lazyIter = generateSequence(1) { it * 2 }.asIterable()
    println(lazyIter.take(4).toList())
    println(lazyIter.first())
    val ii = it.iterator()
    println(ii.next())
    println(it.count())
    println(it.joinToString("-"))
    println(s.asIterable().sum())
    println(s.asIterable().toList())
    val m = mapOf(1 to 2).asSequence().asIterable().toList()
    println(m)
    println("abc".asSequence().asIterable().toList())
    println(it.sortedDescending())
    println(it.contains(2))
    val bySeq = s.asIterable().toSet()
    println(bySeq)

    val once = sequenceOf(1, 2, 3).constrainOnce().asIterable()
    println(once.toList())
    try {
        println(once.toList())
    } catch (e: IllegalStateException) {
        println("second pass: ${e.message}")
    }
    val countdown = Countdown(3).asIterable()
    println(countdown.map { it * 10 })
    println(countdown.count { it > 1 })
    println(Countdown(2).toCollection(mutableListOf(9)))
    val naturals = generateSequence(1) { it + 1 }.asIterable()
    println(naturals.first { it > 41 })
    println(naturals.firstOrNull { it % 7 == 0 })
    println(naturals.any { it > 100 })
    println(naturals.take(3))
    println(naturals.contains(5))
    var seen = 0
    val counting = generateSequence(1) { it + 1 }.onEach { seen++ }.asIterable()
    counting.first { it == 4 }
    println("pulled $seen")
    try {
        sequenceOf<Int>().asIterable().first()
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
}
