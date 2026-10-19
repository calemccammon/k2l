val limit = 3

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

// no error: the body's own `return` leaves the pcall of its try block through the pcall's result (see try_jumps)
fun inTry(): Int {
    tryFirst(listOf(1, 2)) { if (it > 5) return 5 else it > 1 }
    return 0
}

// the non-local return would have to leave the closure of `trim`, which is not inlined
fun viaTrim(s: String): List<Int> {
    capped(1) { s.trim { c -> if (c.code > it) return emptyList() else true } }
    return listOf(s.length)
}

fun main() {
    println(inTry() + viaTrim("a").size)
}
