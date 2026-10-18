package tools

val prefix = "tools"

fun decorate(s: String) = "$prefix:$s"

inline fun <R : Any> attempt(times: Int, block: (Int) -> R?): R? {
    for (i in 0 until times) {
        val r = block(i)
        if (r != null) return r
    }
    return null
}

inline fun fallback(default: String, compute: () -> String?): String {
    val v = compute()
    if (v == null) return decorate(default)
    return v
}

inline fun eachIndexedWhile(items: List<String>, step: (Int, String) -> Boolean) {
    var i = 0
    for (item in items) {
        if (!step(i, item)) break
        i++
    }
}

inline fun <K> tally(keys: List<K>, key: (K) -> K): Map<K, Int> {
    val counts = mutableMapOf<K, Int>()
    for (k in keys) {
        val mapped = key(k)
        counts[mapped] = (counts[mapped] ?: 0) + 1
    }
    return counts
}
