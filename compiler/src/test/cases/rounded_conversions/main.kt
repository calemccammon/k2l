import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.round
import kotlin.math.truncate

// floor, ceil, round and truncate already truncate: their toInt() and toLong() need no further call.
fun scaled(x: Double, r: Double) = floor(x * r).toInt()

fun main() {
    for (v in listOf(2.5, -2.5, 3.5, -0.4, 0.0, -0.0, 7.0)) {
        println("$v: ${floor(v).toInt()} ${ceil(v).toInt()} ${round(v).toInt()} ${truncate(v).toInt()} ${v.toInt()}")
        println(floor(v).toInt() + 1)
    }
    for (v in listOf(1.0e15 + 0.75, -1.0e15 - 0.75, 4.5)) {
        println("${floor(v).toLong()} ${ceil(v).toLong()} ${round(v).toLong()} ${truncate(v).toLong()} ${v.toLong()}")
    }
    println(scaled(1.75, 4.0))
    println(scaled(-1.75, 3.0))
    val n: Number = floor(-2.25)
    println(n.toInt())
    println((floor(9.5) * 2).toInt())
}
