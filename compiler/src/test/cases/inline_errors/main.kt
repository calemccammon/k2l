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

inline fun total(vararg xs: Int, f: (Int) -> Int): Int {
    var sum = 0
    for (x in xs) sum += f(x)
    return sum
}

// a spread that is not the last `vararg` argument of an expanded call, and a `vararg` parameter that is not last
fun spreadFirst(xs: IntArray): Int = total(*xs, 1) { if (it < 0) return -1 else it }

fun main() {
    println(inTry() + spreadFirst(intArrayOf(1)))
}
