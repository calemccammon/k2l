// A spread that is not the last vararg argument of an inline function expanded at the call site (reified type parameter,
// non-local return).
inline fun <reified T> countOf(vararg items: Any?): Int = items.count { it is T }

inline fun <reified T> joinTyped(separator: String, vararg items: Any?, last: String = "."): String =
    items.filterIsInstance<T>().joinToString(separator) + last

inline fun firstOver(limit: Int, vararg values: Int, onMiss: () -> Int): Int {
    for (v in values) if (v > limit) return v
    return onMiss()
}

fun search(xs: IntArray): String {
    val found = firstOver(10, 1, *xs, 3, *xs) { return "none in ${xs.size * 2 + 2}" }
    return "found $found"
}

fun main() {
    val extra = arrayOf<Any?>(4, "five", null, 6)
    println(countOf<Int>(1, "x", *extra, 2))
    println(countOf<String>(*extra, "y", *extra))
    println(countOf<Any>(*extra, *extra))
    println(joinTyped<String>(", ", "a", 1, *extra, "z", last = "!"))
    println(joinTyped<Int>("+", *extra, 10))
    println(search(intArrayOf(5, 20)))
    println(search(intArrayOf(5, 2)))
}
