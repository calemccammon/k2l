fun greet(name: String): String = "Hello, $name!"

fun fib(n: Int): Int = if (n < 2) n else fib(n - 1) + fib(n - 2)

fun classify(n: Int): String = when {
    n < 0 -> "negative"
    n == 0 -> "zero"
    n in 1..9 -> "small"
    else -> "large"
}

fun main() {
    println(greet("Lua"))
    for (i in 0 until 10) {
        if (i % 2 == 1) continue
        println("fib($i) = ${fib(i)}")
    }
    var total = 0
    for (i in 10 downTo 1 step 3) total += i
    println("total: $total, average: ${total / 4.0}")
    println(classify(-3) + " " + classify(0) + " " + classify(5) + " " + classify(42))
    println(-7 / 2)
    println(-7 % 2)
}
