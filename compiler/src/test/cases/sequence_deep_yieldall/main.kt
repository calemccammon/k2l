// yieldAll of another sequence { } or iterator { }: recursive builders thousands of levels deep, in the same order and as
// lazily as the JVM. As on the JVM, an exception an inner builder throws before its first element comes out of the yieldAll
// that started it; one thrown later reaches the consumer without passing through the try blocks around the yieldAll calls.

class Node(val id: Int, val children: List<Node>)

fun chain(n: Int): Node {
    var node = Node(n, emptyList())
    for (i in n - 1 downTo 0) node = Node(i, listOf(node))
    return node
}

fun tree(depth: Int, id: Int = 1): Node =
    Node(id, if (depth == 0) emptyList() else listOf(tree(depth - 1, id * 2), tree(depth - 1, id * 2 + 1)))

fun walk(n: Node): Sequence<Int> = sequence {
    yield(n.id)
    for (c in n.children) yieldAll(walk(c))
}

fun walkIt(n: Node): Iterator<Int> = iterator {
    yield(n.id)
    for (c in n.children) yieldAll(walkIt(c))
}

val log = mutableListOf<String>()

fun countdown(n: Int): Sequence<Int> = sequence {
    log += "start $n"
    if (n > 0) {
        yield(n)
        yieldAll(countdown(n - 1))
        log += "after $n"
    }
}

class Boom(message: String) : Exception(message)

fun failing(n: Int, at: Int): Sequence<Int> = sequence {
    if (n == at) throw Boom("at $n")
    yield(n)
    yieldAll(failing(n + 1, at))
}

fun catching(n: Int, at: Int, catchAt: Int): Sequence<Int> = sequence {
    if (n == at) throw Boom("thrown at $n")
    yield(n)
    try {
        yieldAll(catching(n + 1, at, catchAt))
    } catch (e: Boom) {
        if (n != catchAt) throw e
        yield(-n)
    } finally {
        if (n % 1000 == 0) log += "finally $n"
    }
}

fun dive(n: Int): Sequence<Int> = sequence {
    if (n == 0) throw Boom("bottom")
    yieldAll(dive(n - 1))
}

fun guarded(n: Int, until: Int): Sequence<Int> = sequence {
    try {
        yield(n)
        if (n < until) yieldAll(guarded(n + 1, until))
    } finally {
        if (n % 1000 == 0) log += "finally $n"
    }
}

class Countdown(val from: Int) : Sequence<Int> {
    override fun iterator(): Iterator<Int> = iterator {
        if (from > 0) {
            yield(from)
            yieldAll(Countdown(from - 1))
        }
    }
}

fun main() {
    val root = chain(5000)
    println("sequence: ${walk(root).count()} elements, last ${walk(root).last()}")
    var sum = 0L
    for (x in walkIt(root)) sum += x
    println("iterator: sum $sum")
    println("first 5: ${walk(root).take(5).toList()}")
    println("tree: ${walk(tree(3)).toList()}")
    println("tree iterator: ${walkIt(tree(2)).asSequence().toList()}")
    println("class: ${Countdown(3000).count()} ${Countdown(4).toList()}")

    // laziness and order of side effects
    val it = countdown(3).iterator()
    println("${it.next()} $log")
    println("${it.next()} $log")
    println("${it.asSequence().toList()} $log")
    log.clear()

    // a partly read iterator, one whose hasNext() pulled an element, and an exhausted one
    val partial = walkIt(chain(3))
    partial.next()
    val ahead = walkIt(chain(3))
    ahead.next()
    ahead.hasNext()
    val done = walkIt(chain(0))
    done.next()
    println(sequence { yieldAll(partial); yield(-1); yieldAll(ahead); yieldAll(done); yield(-2) }.toList())
    println("${partial.hasNext()} ${ahead.hasNext()} ${done.hasNext()}")

    // mixed with other sources
    val mixed = sequence {
        yieldAll(listOf(1, 2))
        yieldAll(walk(chain(2)).map { it * 10 })
        yieldAll(sequenceOf(7))
        yieldAll(walk(tree(1)))
    }
    println(mixed.toList())

    // exceptions
    try {
        failing(0, 4000).count()
    } catch (e: Boom) {
        println("caught ${e.message}")
    }
    try {
        catching(0, 3000, 1000).count()
    } catch (e: Boom) {
        println("caught ${e.message}")
    }
    println(guarded(0, 2500).count())
    val caughtInside = sequence {
        try {
            yieldAll(failing(0, 3))
        } catch (e: Boom) {
            yield(-1)
        }
    }
    try {
        println(caughtInside.toList())
    } catch (e: Boom) {
        println("not caught inside: ${e.message}")
    }
    fun attempt(label: String, s: Sequence<Int>) {
        val got = mutableListOf<Int>()
        try {
            for (x in s) got += x
            println("$label: $got")
        } catch (e: Boom) {
            println("$label: $got, then ${e.message}")
        }
    }
    attempt("before the first element", sequence {
        try {
            yieldAll(failing(3, 3))
        } catch (e: Boom) {
            yield(-1)
        }
    })
    attempt("nested before the first element", sequence {
        try {
            yieldAll(sequence { yieldAll(sequence<Int> { throw Boom("deep") }) })
        } catch (e: Boom) {
            yield(-2)
        }
    })
    attempt("after some elements", sequence {
        yield(1)
        try {
            yieldAll(failing(5, 5))
        } catch (e: Boom) {
            yield(-3)
        }
        yield(2)
    })
    val started = iterator {
        yield(1)
        throw Boom("started")
    }
    started.next()
    attempt("partly read iterator", sequence {
        try {
            yieldAll(started)
        } catch (e: Boom) {
            yield(-4)
        }
    })
    val buffered = iterator {
        yield(1)
        yield(2)
        throw Boom("buffered")
    }
    buffered.next()
    buffered.hasNext()
    attempt("iterator with a pulled element", sequence {
        try {
            yieldAll(buffered)
        } catch (e: Boom) {
            yield(-5)
        }
    })
    attempt("deep before the first element", sequence {
        try {
            yieldAll(dive(300))
        } catch (e: Boom) {
            yield(-7)
        }
    })
    attempt("deep after the elements", sequence {
        try {
            yieldAll(catching(0, 3000, 0))
        } catch (e: Boom) {
            yield(-6)
        }
    }.drop(2999))
    println(log)
    val again = walk(chain(10))
    println("${again.sum()} ${again.sum()}")
}
