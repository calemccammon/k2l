fun breakInTry() {
    for (i in 1..5) {
        try {
            if (i == 3) break
            println("body $i")
        } catch (e: Exception) {
            println("never")
        }
    }
    println("after break")
}

fun continueInTry() {
    for (i in 1..5) {
        try {
            if (i % 2 == 0) continue
            println("odd $i")
        } finally {
            println("finally $i")
        }
    }
}

fun breakWithFinally() {
    var i = 0
    while (true) {
        i++
        try {
            if (i > 2) break
            println("tick $i")
        } finally {
            println("cleanup $i")
        }
    }
    println("done $i")
}

fun throwingThenContinue() {
    for (s in listOf("1", "x", "3", "stop", "5")) {
        try {
            val n = s.toInt()
            println("number $n")
        } catch (e: NumberFormatException) {
            if (s == "stop") break
            println("skipping $s")
            continue
        }
        println("end of iteration $s")
    }
}

fun catchBreaks() {
    for (i in 0 until 5) {
        try {
            if (i == 2) throw IllegalStateException("boom $i")
            println("fine $i")
        } catch (e: IllegalStateException) {
            println("caught ${e.message}")
            break
        } finally {
            println("finally $i")
        }
    }
}

fun labeled() {
    outer@ for (i in 1..3) {
        for (j in 1..3) {
            try {
                if (j == 2) continue@outer
                if (i == 3) break@outer
                println("$i,$j")
            } finally {
                println("f $i,$j")
            }
        }
    }
    println("labeled done")
}

fun nestedTry() {
    for (i in 1..4) {
        try {
            try {
                if (i == 2) continue
                if (i == 4) break
                println("inner $i")
            } finally {
                println("inner finally $i")
            }
            println("between $i")
        } finally {
            println("outer finally $i")
        }
    }
}

fun tryInLoopInTry(): Int {
    var total = 0
    try {
        for (i in 1..5) {
            try {
                if (i == 2) continue
                if (i == 4) return total
                total += i
            } finally {
                total += 100
            }
        }
    } finally {
        println("outer total $total")
    }
    return -1
}

fun jumpsAndReturn(limit: Int): String {
    for (i in 1..10) {
        try {
            if (i == 2) continue
            if (i == limit) return "returned at $i"
            if (i > 6) break
        } finally {
            print("[$i]")
        }
    }
    return "fell out"
}

fun finallyJumps() {
    for (i in 1..4) {
        try {
            if (i == 2) throw RuntimeException("swallowed")
            println("body $i")
        } finally {
            if (i == 2) continue
            if (i == 3) break
            println("finally $i")
        }
    }
    println("finallyJumps done")
}

fun tryAsValue(): List<Int> {
    val out = mutableListOf<Int>()
    for (i in 1..5) {
        val v = try {
            if (i == 2) continue
            if (i == 5) break
            i * 10
        } catch (e: Exception) {
            -1
        }
        out.add(v)
    }
    return out
}

fun doWhile() {
    var i = 0
    do {
        i++
        try {
            if (i == 2) continue
            if (i == 4) break
            println("do $i")
        } finally {
            println("do finally $i")
        }
    } while (i < 10)
}

inline fun firstEven(xs: List<Int>): Int {
    for (x in xs) {
        try {
            if (x % 2 == 0) return x
        } finally {
            println("checked $x")
        }
    }
    return -1
}

// expanded at the call site because of the non-local return in the lambda: the body's own `return` leaves a try
inline fun tryFirst(xs: List<Int>, f: (Int) -> Boolean): Int {
    try {
        for (x in xs) if (f(x)) return x
    } catch (e: Exception) {
        println("caught")
    } finally {
        println("tryFirst finally")
    }
    return -1
}

fun inTry(xs: List<Int>): Int {
    val found = tryFirst(xs) { if (it > 5) return 5 else it > 1 }
    return found * 100
}

fun main() {
    println(inTry(listOf(1, 2, 3)))
    println(inTry(listOf(1, 9)))
    println(inTry(listOf(1)))
    breakInTry()
    continueInTry()
    breakWithFinally()
    throwingThenContinue()
    catchBreaks()
    labeled()
    nestedTry()
    println(tryInLoopInTry())
    println(jumpsAndReturn(5))
    println(jumpsAndReturn(100))
    finallyJumps()
    println(tryAsValue())
    doWhile()
    println(firstEven(listOf(1, 3, 4, 6)))
}
