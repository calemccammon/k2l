class CountdownIterator(var current: Int) : Iterator<Int> {
    override fun hasNext() = current > 0

    override fun next(): Int = current--
}

class Countdown(private val from: Int) : Sequence<Int> {
    override fun iterator(): Iterator<Int> = CountdownIterator(from)
}

class Words(private val text: String) : Sequence<String> {
    override fun iterator(): Iterator<String> = text.split(" ").iterator()
}

class Fibonacci : Sequence<Long> {
    override fun iterator(): Iterator<Long> = iterator {
        var a = 0L
        var b = 1L
        while (true) {
            yield(a)
            val next = a + b
            a = b
            b = next
        }
    }
}

open class Base : Sequence<Int> {
    override fun iterator(): Iterator<Int> = listOf(7, 8, 9).iterator()
}

class Derived : Base() {
    fun total() = sum()
}

fun describe(items: Sequence<Int>): String = items.map { it * 2 }.toList().toString()

fun main() {
    val c = Countdown(5)
    println(c.toList())
    println(c.map { it * it }.filter { it % 2 == 1 }.toList())
    println(c.sum())
    println(c.first())
    println(c.take(2).toList())
    println(c.count { it > 2 })
    for (x in c) print("$x ")
    println()
    println(describe(c))
    println(Words("the quick brown fox").map { it.length }.toList())
    println(Words("a b c").joinToString("-"))
    println(Fibonacci().take(10).toList())
    println(Fibonacci().filter { it % 2 == 0L }.take(4).toList())
    println(Derived().total())
    println(Derived().map { it + 1 }.toList())
    val seq: Sequence<Int> = Countdown(3)
    println(seq.zip(Countdown(2)).toList())
    println((seq + Countdown(2)).toList())
    println(Countdown(4).windowed(2).toList())
    println(Countdown(3).iterator().next())
    println(Countdown(3).asSequence().toList())
    println(Countdown(3).any { it == 2 })
    val it = Countdown(2).iterator()
    while (it.hasNext()) println(it.next())
}
