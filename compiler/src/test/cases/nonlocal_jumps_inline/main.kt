// `break` and `continue` out of lambdas that are expanded in place, and lambdas of inline functions passed on.

fun forEachJumps(): String {
    var log = ""
    for (i in 0 until 5) {
        listOf(1, 2, 3).forEach {
            if (it == 2 && i == 3) break
            if (it == 3) continue
            log += "$i$it "
        }
    }
    return log
}

fun mapJumps(stopAt: Int): String {
    val rows = mutableListOf<List<Int>>()
    for (i in 0..4) {
        val row = listOf(1, 2, 3).map {
            if (i == 1) continue
            if (i == stopAt) break
            if (i == 4 && it == 2) return "returned with $rows"
            it * i
        }
        rows.add(row)
    }
    return "$rows"
}

fun labeled(): String {
    var log = ""
    outer@ for (i in 0..3) {
        inner@ for (j in 0..3) {
            listOf("a", "b").forEachIndexed { k, s ->
                if (j == 1) continue@inner
                if (j == 2 && i == 1) continue@outer
                if (j == 2 && k == 1) break@inner
                if (i == 3) break@outer
                log += "$i$j$s "
            }
        }
    }
    return log
}

fun scopeFunctions(): String {
    var log = ""
    var n = 0
    while (n < 6) {
        n++
        n.let { if (it == 2) continue }
        run { if (n == 5) break }
        log += n
    }
    var m = 0
    do {
        m++
        m.also { if (it % 2 == 0) continue }
        log += "-$m"
    } while (m < 5)
    return log
}

fun stringAndSequence(): String {
    var log = ""
    for (w in listOf("abc", "xyz", "stop", "end")) {
        val upper = w.filter {
            if (it == 'y') continue
            if (w == "stop") break
            it != 'b'
        }
        log += "$upper "
        sequenceOf(1, 2).forEach { if (it == 2) continue; log += "$it " }
    }
    return log
}

inline fun twice(body: (Int) -> Unit) {
    for (i in 0..1) body(i)
}

fun userInline(): String {
    var log = ""
    for (k in 0..3) {
        twice { i ->
            if (k == 1) continue
            if (k == 3) break
            log += "$k$i "
        }
    }
    return log
}

inline fun trimWith(s: String, pred: (Char) -> Boolean): String = s.trim(pred)

inline fun trimVia(s: String, pred: (Char) -> Boolean): String = s.trim { pred(it) }

fun passedOn(s: String): String {
    val a = trimWith(s) { if (it == '!') return "returned via trimWith" else it == ' ' }
    val b = trimVia(s) { if (it == '?') return "returned via trimVia" else it == ' ' }
    return "[$a][$b]"
}

fun passedOnJumps(): String {
    var log = ""
    for (k in 0..3) {
        trimVia("ab") { if (k == 1) continue; if (k == 3) break; false }
        log += "$k "
    }
    return log
}

inline fun capped(n: Int, f: (Int) -> Unit) {
    for (i in 0 until 3) f(n + i)
}

fun viaTrim(s: String): List<Int> {
    capped(1) { s.trim { c -> if (c.code > it) return emptyList() else true } }
    return listOf(s.length)
}

fun nestedInlineReturns(a: Boolean, b: Boolean): String {
    var log = ""
    val r = run outer@{
        run inner@{
            if (a) return@inner
            if (b) return@outer "outer"
            log += "x"
        }
        "end"
    }
    return "$r $log"
}

fun returnFromLoopInRun(n: Int): String = run outer@{
    for (i in 0..5) {
        if (i == 1) continue
        if (i == n) return@outer "at $i"
    }
    "none"
}

fun main() {
    println(forEachJumps())
    println(mapJumps(3))
    println(mapJumps(9))
    println(labeled())
    println(scopeFunctions())
    println(stringAndSequence())
    println(userInline())
    println(passedOn("  a  "))
    println(passedOn(" a! "))
    println(passedOn(" a? "))
    println(passedOnJumps())
    println(viaTrim("a"))
    println(viaTrim("\u0001"))
    println(nestedInlineReturns(true, false))
    println(nestedInlineReturns(false, true))
    println(nestedInlineReturns(false, false))
    println(returnFromLoopInRun(3))
    println(returnFromLoopInRun(9))
}
