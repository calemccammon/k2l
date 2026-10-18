val limit = 3

inline fun withVararg(f: (Int) -> Unit, vararg xs: Int) {
    for (x in xs) f(x)
}

inline fun capped(n: Int, f: (Int) -> Unit) {
    for (i in 0 until limit) f(n + i)
}

inline fun tryFirst(xs: List<Int>, f: (Int) -> Boolean): Int {
    try {
        for (x in xs) if (f(x)) return x
    } catch (e: Exception) {
        println("caught")
    }
    return -1
}

fun varargs(): Int {
    withVararg({ if (it == 2) return it }, 1, 2, 3)
    return 0
}

// the body uses the top-level `limit`, which the caller's local would hide in the expansion
fun captured(): Int {
    val limit = 10
    capped(limit) { if (it > 100) return it }
    return limit
}

// no error: the body's own `return` leaves the pcall of its try block through the pcall's result (see try_jumps)
fun inTry(): Int {
    tryFirst(listOf(1, 2)) { if (it > 5) return 5 else it > 1 }
    return 0
}

// the non-local return would have to leave the closure of `map`, which is not inlined
fun viaMap(xs: List<Int>): List<Int> {
    capped(1) { xs.partition { x -> if (x > it) return emptyList() else x > 0 } }
    return xs
}

fun main() {
    println(varargs() + captured() + inTry() + viaMap(listOf(1)).size)
}
