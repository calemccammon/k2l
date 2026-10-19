import java.io.Closeable

// Lambdas passed to inline library functions that k2l does not expand stay Lua functions; a jump out of one raises a token
// that the call catches.

fun trimOut(s: String): String {
    val t = s.trim { c -> if (c == '!') return "bang" else c == ' ' }
    return "[$t]"
}

fun maxOrStop(xs: List<Int>): Int {
    val m = xs.asSequence().maxOf { if (it < 0) return -1 else it * 2 }
    return m
}

fun firstSquareOver(limit: Int): Int {
    generateSequence(1) { it + 1 }.forEach { if (it * it > limit) return it }
    return -1
}

fun sequenceTerminals(): List<String> {
    val out = mutableListOf<String>()
    fun any(): Int {
        sequenceOf(1, 2, 3).any { if (it == 2) return 20; false }
        return 0
    }
    fun first(): Int {
        val v = sequenceOf(1, 2, 3).first { if (it == 2) return 30; it > 2 }
        return v
    }
    fun fold(): Int = sequenceOf(1, 2, 3).fold(0) { acc, x -> if (x == 3) return -acc; acc + x }
    fun count(): Int {
        val n = sequenceOf(1, 2, 3, 4).count { if (it > 3) return -1; it % 2 == 0 }
        return n
    }
    fun sum(): Int = sequenceOf(1, 2, 3).sumOf { if (it == 2) return 99; it }
    fun none(): Boolean {
        sequenceOf("a", "b").none { if (it == "b") return true; false }
        return false
    }
    out += "any=${any()} first=${first()} fold=${fold()} count=${count()} sum=${sum()} none=${none()}"
    return out
}

fun mapCatchingOut(r: Result<Int>): String {
    val m = r.mapCatching { if (it == 1) return "returned" else it * 10 }
    val rec = m.recoverCatching { if (it is IllegalStateException) return "recovered-returned" else -1 }
    return rec.toString()
}

fun breaksAndContinues(): String {
    val seen = mutableListOf<String>()
    outer@ for (i in 0 until 4) {
        sequenceOf("a", "b", "c").forEach { s ->
            if (s == "b" && i == 1) continue@outer
            if (s == "c" && i == 2) break@outer
            "xyz".trim { c -> if (c == 'y' && i == 3) break; c == 'x' }
            seen += "$i$s"
        }
    }
    return seen.joinToString(" ")
}

fun jumpsFromOneLambda(n: Int): String {
    var log = ""
    for (i in 0..n) {
        "  x ".trim { c ->
            when {
                i == 1 -> continue
                i == 3 -> break
                i == n -> return "returned at $i, log=$log"
                else -> c == ' '
            }
        }
        log += i
    }
    return "loop done, log=$log"
}

fun labeledToLambda(): List<Int> {
    val results = mutableListOf<Int>()
    val f: (Int) -> Int = f@{ x ->
        "bc".trim { c -> if (c == 'b' && x > 1) return@f x * 100; false }
        x
    }
    results += f(1)
    results += f(2)
    repeat(3) { r ->
        " q ".trim { if (r == 1) return@repeat; it == ' ' }
        results += r
    }
    val viaRun = run outer@{
        sequenceOf(5, 6).maxOf { if (it == 6) return@outer -6; it }
        0
    }
    results += viaRun
    return results
}

fun nested(): Int {
    "ab".trim { a ->
        "cd".trim { b -> if (a == 'b' && b == 'd') return 42; false }
        false
    }
    return 0
}

fun nestedThroughTry(): String {
    val log = mutableListOf<String>()
    "ab".trim { a ->
        try {
            "cd".trim { b -> if (a == 'a' && b == 'c') return "returned through two lambdas and a try, log=$log"; false }
        } catch (e: Throwable) {
            log.add("caught $e")
        } finally {
            println("finally of the outer lambda")
        }
        false
    }
    return "not reached"
}

fun nestedFunction(): Int {
    fun inner(s: String): Int {
        s.trim { if (it == '!') return 1; false }
        return 2
    }
    return inner("a!") * 10 + inner("a")
}

fun tailValue(xs: List<Int>): Int {
    val v = xs.asSequence().sumOf { if (it > 10) return it else it }
    return v
}

fun unitFunction(log: MutableList<String>) {
    "bac".trim {
        if (it == 'b') {
            log.add("leaving")
            return
        }
        false
    }
    log.add("not reached")
}

fun throughTryCatch(): String {
    val log = mutableListOf<String>()
    "abc".trim { c ->
        try {
            if (c == 'c') return "returned through try, log=$log"
            log += "try $c"
        } catch (e: Throwable) {
            log += "caught $e"
        } finally {
            log += "finally $c"
        }
        false
    }
    return "not reached"
}

fun tryAroundCall(): String {
    val log = mutableListOf<String>()
    try {
        "abc".trim { if (it == 'c') return "returned, log=$log"; log += "lambda $it"; false }
    } catch (e: Throwable) {
        log += "caught"
    } finally {
        println("finally runs, log=$log")
    }
    return "not reached"
}

class Resource(val name: String, val log: MutableList<String>) : Closeable {
    override fun close() {
        log += "close $name"
    }
}

fun throughUse(log: MutableList<String>): Int {
    "abc".trim { c ->
        Resource("r$c", log).use { if (c == 'c') return 7 }
        false
    }
    return 0
}

fun throughRunCatching(): String {
    val r = runCatching {
        "abc".trim { if (it == 'c') return "returned out of runCatching"; false }
        "done"
    }
    return r.toString()
}

fun failureStillCaught(): String {
    val r = runCatching { "abc".trim { if (it == 'c') error("boom"); false } }
    return r.exceptionOrNull()?.message ?: "?"
}

fun inSequenceBuilder(): List<Int> = sequence {
    for (i in 1..5) {
        sequenceOf(i).maxOf { if (i == 4) return@sequence; it }
        yield(i)
    }
}.toList()

fun yieldsInsideClosure(): List<Int> = sequence {
    for (i in 1..3) {
        "ab".trim { c ->
            yield(i * 10 + c.code - 'a'.code)
            if (i == 2) return@sequence
            false
        }
    }
}.toList()

fun main() {
    println(trimOut("  a! "))
    println(trimOut("  a "))
    println(maxOrStop(listOf(1, 5, 3)))
    println(maxOrStop(listOf(1, -5, 3)))
    println(firstSquareOver(50))
    println(sequenceTerminals())
    println(mapCatchingOut(Result.success(1)))
    println(mapCatchingOut(Result.success(2)))
    println(mapCatchingOut(Result.failure(IllegalStateException("x"))))
    println(breaksAndContinues())
    println(jumpsFromOneLambda(5))
    println(jumpsFromOneLambda(2))
    println(labeledToLambda())
    println(nested())
    println(nestedThroughTry())
    println(nestedFunction())
    println(tailValue(listOf(1, 2)))
    println(tailValue(listOf(1, 20)))
    val log = mutableListOf<String>()
    unitFunction(log)
    println(log)
    println(throughTryCatch())
    println(tryAroundCall())
    val useLog = mutableListOf<String>()
    println(throughUse(useLog))
    println(useLog)
    println(throughRunCatching())
    println(failureStillCaught())
    println(inSequenceBuilder())
    println(yieldsInsideClosure())
}
