val greeting = "Hi"
var counter = 0

fun isEven(n: Int): Boolean = if (n == 0) true else isOdd(n - 1)

fun isOdd(n: Int): Boolean = if (n == 0) false else isEven(n - 1)

fun factorial(n: Int): Long {
    var result = 1L
    for (i in 2..n) result *= i
    return result
}

fun bump(): Int {
    counter += 1
    return counter
}

fun end(local: Int, nil: Int): Int = local + nil

private fun hidden() = println("hidden")

fun outer(x: Int): Int {
    fun square(y: Int) = y * y
    return square(x) + square(x + 1)
}

fun unit() {
    println("$greeting from unit")
}

fun main() {
    println(isEven(10))
    println(isOdd(7))
    println(factorial(10))
    println(factorial(20))
    bump()
    bump()
    println(counter)
    println(end(1, 2))
    hidden()
    println(outer(3))
    unit()
}
