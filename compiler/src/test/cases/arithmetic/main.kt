fun main() {
    val a = 17
    val b = 5
    println(a + b)
    println(a - b)
    println(a * b)
    println(a / b)
    println(a % b)
    println(-a / b)
    println(-a % b)
    println(a / -b)
    println(a % -b)

    val x = 7.5
    val y = 2.0
    println(x + y)
    println(x / y)
    println(x % y)
    println(x * a)
    println(a / y)
    println(1.0 / 3)
    println(1e10)
    println(0.0001)
    println(1.0 / 0.0)
    println(-(1.0 / 0.0))
    println(0.0 / 0.0)

    println(a > b && b > 0)
    println(a < b || !(b == 5))
    println(a != b)
    println(2 - -3)
    println(-(-a))

    println(maxOf(3, 9))
    println(minOf(2.5, 1.5))
    println(kotlin.math.sqrt(16.0))
    println(kotlin.math.abs(-4))
    println(kotlin.math.floor(2.7))

    println(x.toInt())
    println((-x).toInt())
    println(a.toDouble())
    println(3000000000L.toInt())
    println(Int.MAX_VALUE)
}
