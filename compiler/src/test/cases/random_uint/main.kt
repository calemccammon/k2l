import kotlin.random.Random
import kotlin.random.nextUInt

// Draws that fit 52 bits are the JVM's on every target
fun main() {
    val r = Random(2024)
    println(r.nextUInt())
    println(r.nextUInt(10u))
    println(r.nextUInt(4000000000u, 4000000100u))
    println(r.nextUInt(0u, 4294967295u))
    println(r.nextLong(100L))
    println(r.nextLong(1048576L))
    println(r.nextLong(4294967296L))
    println(r.nextLong(1099511627776L))
    println(r.nextLong(1000000007L))
    println(r.nextLong(77777L))
    println(r.nextLong(-50L, 50L))
    println(r.nextLong(5000000000L, 5000000100L))
    val d = Random(7L)
    repeat(5) { print("${d.nextLong(1000L)} ") }
    println()
    try {
        r.nextUInt(5u, 5u)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        r.nextLong(0L)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
}
