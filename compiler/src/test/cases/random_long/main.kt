import kotlin.random.Random
import kotlin.random.nextUInt
import kotlin.random.nextULong

// Seeded sequences match the JVM; Long draws need 64-bit integers
fun main() {
    val r = Random(42)
    println(r.nextLong(100L))
    println(r.nextLong(1L shl 40))
    println(r.nextLong(1L shl 32))
    println(r.nextLong(1L shl 20))
    println(r.nextLong(1000000007L))
    println(r.nextLong(1L shl 50 or 12345L))
    println(r.nextLong(-50L, 50L))
    println(r.nextLong(10000000000L, 10000000100L))
    println(r.nextLong(Long.MIN_VALUE, Long.MAX_VALUE))
    println(r.nextLong())
    println(r.nextUInt())
    println(r.nextUInt(10u))
    println(r.nextUInt(4000000000u, 4000000100u))
    println(r.nextUInt(0u, 4294967295u))
    println(r.nextULong())
    println(r.nextULong(1000uL))
    println(r.nextULong(18446744073709551000uL, 18446744073709551615uL))
    val d = Random(7L)
    repeat(5) { print("${d.nextLong(1000L)} ") }
    println()
    try {
        r.nextLong(0L)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        r.nextUInt(5u, 5u)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    println(Random.nextLong(10L) in 0L until 10L)
}
