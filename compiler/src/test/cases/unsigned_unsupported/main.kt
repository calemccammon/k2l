// The unsigned types are not supported: each outermost expression of one is reported once.
fun half(x: UInt): UInt = x / 2u

fun main() {
    val a = 3u + 4u
    println(half(10u))
    println("ff".toUByte(16))
    val bytes = ubyteArrayOf(1u, 2u)
    println(bytes.size)
    println((1u..3u).toList())
    println(5.toULong().toString())
}
