fun fibonacci() = sequence {
    var a = 0
    var b = 1
    while (true) {
        yield(a)
        val next = a + b
        a = b
        b = next
    }
}

fun primes(): Sequence<Int> = sequence {
    val found = mutableListOf<Int>()
    var n = 2
    while (true) {
        if (found.none { n % it == 0 }) {
            found.add(n)
            yield(n)
        }
        n++
    }
}

suspend fun SequenceScope<String>.emitPair(a: String, b: String) {
    yield(a)
    yield(b)
}

fun classify(xs: List<Int>): Sequence<String> = sequence {
    for (x in xs) {
        when {
            x < 0 -> yield("negative $x")
            x == 0 -> continue
            x % 2 == 0 -> emitPair("even", "$x")
            else -> yield("odd $x")
        }
    }
    yield("done")
}

class Tree(val value: Int, val left: Tree? = null, val right: Tree? = null) {
    fun inOrder(): Sequence<Int> = sequence {
        left?.let { yieldAll(it.inOrder()) }
        yield(value)
        if (right != null) yieldAll(right.inOrder())
    }
}

fun countdown(from: Int): Iterator<Int> = iterator {
    var i = from
    while (i > 0) {
        println("  producing $i")
        yield(i--)
    }
}

fun failing(): Sequence<Int> = sequence {
    yield(1)
    yield(2)
    throw IllegalStateException("generator broke")
}

fun guarded(): Sequence<String> = sequence {
    try {
        yield("inside try")
        throw IllegalArgumentException("oops")
    } catch (e: IllegalArgumentException) {
        yield("caught ${e.message}")
    } finally {
        println("  finally runs")
    }
    val label = try {
        yield("before")
        "value"
    } catch (e: Exception) {
        "never"
    }
    yield(label)
}

class Repeater(private val word: String, private val times: Int) {
    fun words(): Sequence<String> = sequence {
        repeat(times) { i -> yield("$word#$i") }
    }
}

fun main() {
    println(fibonacci().take(10).toList())
    println(primes().take(8).joinToString())
    println(classify(listOf(3, 0, -2, 4)).toList())

    val tree = Tree(4, Tree(2, Tree(1), Tree(3)), Tree(6, Tree(5)))
    println(tree.inOrder().toList())
    println(tree.inOrder().filter { it % 2 == 1 }.map { it * 10 }.toList())

    println("-- interleaving")
    val logged = sequence {
        for (i in 1..3) {
            println("  yield $i")
            yield(i)
        }
        println("  end")
    }
    for (x in logged.map { it * 2 }) println("consumed $x")
    println(logged.first())

    println("-- yieldAll")
    val all = sequence {
        yieldAll(listOf(1, 2))
        yieldAll(setOf(3))
        yieldAll(sequenceOf(4, 5))
        yieldAll(generateSequence(6) { if (it < 8) it + 1 else null })
        yieldAll(listOf(9, 10).iterator())
        yieldAll(emptyList())
    }
    println(all.toList())
    println(all.count())
    val nested = sequence {
        yield(0)
        yieldAll(sequence { for (c in "ab") yield(c.toString()) }.map { it.length })
        yield(-1)
    }
    println(nested.toList())

    println("-- iterator")
    val it = countdown(3)
    while (it.hasNext()) println("got ${it.next()}")
    try {
        it.next()
    } catch (e: NoSuchElementException) {
        println("exhausted")
    }
    for (n in countdown(2)) println("loop $n")

    println("-- exceptions")
    try {
        for (x in failing()) println("value $x")
    } catch (e: IllegalStateException) {
        println("caught: ${e.message}")
    }
    println(failing().take(2).toList())
    println(guarded().toList())
    println(guarded().first())

    println("-- members and helpers")
    println(Repeater("hi", 3).words().toList())
    val withNulls = sequence {
        yield(null)
        yield("x")
        yield(null)
    }
    println(withNulls.toList())
    println(withNulls.filterNotNull().toList())
    var evaluated = 0
    val lazyInfinite = sequence {
        var n = 0
        while (true) {
            evaluated++
            yield(n++)
        }
    }
    println(lazyInfinite.drop(2).take(3).toList())
    println("evaluated $evaluated")
    val early = sequence {
        yield(1)
        if (evaluated > 0) return@sequence
        yield(2)
    }
    println(early.toList())
}
