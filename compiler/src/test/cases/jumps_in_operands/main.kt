// Branches that are annotated blocks (`thisIsNode -> @Suppress("UNCHECKED_CAST") { ... }`), and jumps as operands of ||
// and && (`thisCell == otherCell || return false`).
fun allEqual(a: List<Int>, b: List<Int>): Boolean {
    if (a.size != b.size) return false
    for (i in a.indices) {
        a[i] == b[i] || return false
    }
    return true
}

fun noneNegative(xs: List<Int>): Boolean {
    xs.forEach { x ->
        when {
            x > 100 -> @Suppress("UNUSED_VARIABLE") {
                val big = x
                big < 1000 || return false
            }
            else -> x >= 0 || return false
        }
    }
    return true
}

fun firstGap(xs: List<Int>): Int {
    var last = -1
    for (x in xs) {
        (x == last + 1) || break
        last = x
    }
    return last + 1
}

fun countEven(xs: List<Int>): Int {
    var n = 0
    for (x in xs) {
        x % 2 == 0 || continue
        n++
    }
    return n
}

fun guarded(x: Int?): String {
    try {
        (x != null && x > 0) || return "not positive"
        x!! < 10 && return "small"
    } finally {
        println("checked $x")
    }
    return "large"
}

fun describe(x: Any): String {
    val result: String
    if (x is String) @Suppress("USELESS_CAST") {
        val s = x as String
        result = "string of ${s.length}"
    } else {
        result = "other"
    }
    val label = when (x) {
        is Int -> @Suppress("USELESS_CAST") {
            val n = x as Int
            "int ${n + 1}"
        }
        else -> "?"
    }
    return "$result/$label"
}

fun main() {
    println(allEqual(listOf(1, 2, 3), listOf(1, 2, 3)))
    println(allEqual(listOf(1, 2, 3), listOf(1, 5, 3)))
    println(noneNegative(listOf(1, 200, 3)))
    println(noneNegative(listOf(1, 2000, 3)))
    println(noneNegative(listOf(1, -2, 3)))
    println(firstGap(listOf(0, 1, 2, 4, 5)))
    println(countEven(listOf(1, 2, 3, 4, 6)))
    println(guarded(null))
    println(guarded(5))
    println(guarded(50))
    println(describe("abc"))
    println(describe(41))
}
