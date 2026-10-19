import kotlin.math.abs
import kotlin.math.absoluteValue

fun divide(a: Int, b: Int) = a / b

fun firstBig(xs: List<Int>): Int {
    val total = xs.sumOf { if (it < 0) return -1 else it }
    return total
}

fun main() {
    val min = Int.MIN_VALUE
    val minusOne = -1
    println(min / minusOne)
    println(divide(Int.MIN_VALUE, -1))
    println(divide(7, -2))
    println(min % minusOne)
    println(min.rem(minusOne))
    println(min.div(minusOne))
    println(abs(min))
    println(min.absoluteValue)
    println(Math.abs(min))
    println(abs(-5))
    println(Int.MAX_VALUE.inc())
    println(Int.MIN_VALUE.dec())
    var n = Int.MAX_VALUE
    n = n.inc()
    println(n)
    val big = listOf(Int.MAX_VALUE, 1, Int.MAX_VALUE, 5)
    println(big.sum())
    println(big.sumOf { it })
    println(big.sumOf { it * 2 })
    println(big.asSequence().sum())
    println(arrayOf(Int.MAX_VALUE, Int.MAX_VALUE).sum())
    println(intArrayOf(Int.MAX_VALUE, 2).sum())
    println(firstBig(big))
    println(big.sumOf { it.toLong() })
    println(listOf(1, 2, 3).sum())
    println(listOf(1.5, 2.5).sum())
    var h = 0
    for (c in "hello world, this is a long string") h = 31 * h + c.code
    println(h)
    println(-min)
    println(min - 1)
}

