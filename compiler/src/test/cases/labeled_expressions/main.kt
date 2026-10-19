// Labels on expressions other than loops: they only matter to `return@label` in a lambda, otherwise the expression is
// evaluated as if the label were not there.
fun <T> twice(f: () -> T): List<T> = listOf(f(), f())

fun sign(x: Int): String {
    val described = check@ when {
        x < 0 -> "negative"
        x == 0 -> "zero"
        else -> "positive"
    }
    return described
}

fun main() {
    lbl@ println("a labeled call")
    val five = five@ 5
    println(five + (six@ 6))
    val y = if (five > 3) big@ "big" else small@ "small"
    println(y)

    // a labeled lambda held in a value, leaving through its label
    val half = half@{ x: Int ->
        if (x % 2 != 0) return@half -1
        x / 2
    }
    println(listOf(4, 5, 6).map(half))

    // the label of a lambda passed to a function
    println(listOf(1, 2, 3).map each@{ if (it == 2) return@each 0 else it * 10 })
    var n = 0
    println(twice next@{ n++; if (n == 1) return@next "first"; "then $n" })

    // labeled statements and blocks
    var total = 0
    add@ total += 3
    step@ total++
    cond@ if (total > 3) println("total $total") else println("small")
    run block@{
        if (total == 4) return@block
        println("not reached")
    }
    println(sign(-2) + " " + sign(0) + " " + sign(9))

    // a labeled lambda and a labeled loop inside it
    val pairs = twice pairs@{
        val found = mutableListOf<String>()
        rows@ for (i in 0..3) {
            for (j in 0..3) {
                if (j > i) continue@rows
                if (i == 3) break@rows
                if (found.size > 4) return@pairs found.joinToString()
                found += "$i$j"
            }
        }
        found.joinToString()
    }
    println(pairs)
}
