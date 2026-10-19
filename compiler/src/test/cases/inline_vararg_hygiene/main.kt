val limit = 3
val prefix = "p"

inline fun withVararg(f: (Int) -> Unit, vararg xs: Int) {
    for (x in xs) f(x)
}

inline fun sumAll(base: Int, f: (Int) -> Int, vararg xs: Int): Int {
    var total = base
    for (x in xs) total += f(x)
    return total + xs.size
}

inline fun label(vararg parts: String): String = parts.joinToString("-")

inline fun capped(n: Int, f: (Int) -> Unit) {
    for (i in 0 until limit) f(n + i)
}

inline fun tagged(n: Int, f: (String) -> Unit) {
    f(prefix + n)
}

inline fun outer(n: Int, f: (Int) -> Unit) {
    capped(n, f)
}

fun varargs(): Int {
    withVararg({ if (it == 2) return it }, 1, 2, 3)
    return 0
}

fun spreads(): Int {
    val extra = intArrayOf(10, 20, 30)
    val r = sumAll(1, { if (it > 25) return it; it * 2 }, 4, *extra)
    return r
}

fun emptyVarargs(): String {
    val a = label()
    val b = label("a", "b")
    return "$a|$b"
}

fun named(): Int {
    val r = sumAll(f = { if (it > 100) return -1; it }, base = 5, xs = *intArrayOf(1, 2))
    return r
}

// the body uses the top-level `limit`, which the caller's local would otherwise hide in the expansion
fun captured(): Int {
    val limit = 10
    capped(limit) { if (it > 100) return it }
    return limit
}

fun param(limit: Int): Int {
    capped(limit) { if (it > 100) return it }
    return limit * 2
}

fun hiddenInLoop(): Int {
    var seen = 0
    for (limit in 1..2) {
        capped(limit) { if (it > 100) return it; seen += it }
    }
    return seen
}

fun hiddenPrefix(): String {
    val prefix = "local"
    var r = prefix
    tagged(1) { if (it == "zzz") return "no"; r += it }
    return r
}

fun nested(): Int {
    val limit = 7
    var total = 0
    outer(limit) { if (it > 100) return it; total += it }
    return total + limit
}

fun main() {
    println(varargs())
    println(spreads())
    println(emptyVarargs())
    println(named())
    println(captured())
    println(param(4))
    println(hiddenInLoop())
    println(hiddenPrefix())
    println(nested())
}
