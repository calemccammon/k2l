import java.util.Random

fun ints() {
    println("-- nextInt")
    val r = Random(42)
    println((1..8).map { r.nextInt() })
    for (bound in listOf(2, 10, 16, 100, 1000, 1024, 65536, 1000000007, 1073741825, 2147483647)) {
        println("$bound: ${(1..6).map { r.nextInt(bound) }}")
    }
    val negative = Random(-12345)
    println((1..5).map { negative.nextInt(50) })
    val big = Random(1234567890123L)
    println((1..5).map { big.nextInt(1000) })
    println((1..5).map { big.nextInt() })
    val ranged = Random(99)
    println((1..8).map { ranged.nextInt(5, 15) })
    println((1..8).map { ranged.nextInt(-100, 100) })
    println((1..4).map { ranged.nextInt(0, 1 shl 20) })
    println((1..4).map { ranged.nextInt(10, 11) })
    println((1..4).map { ranged.nextInt(-1000000000, 1000000000) })
    println((1..4).map { ranged.nextInt(-2000000000, 2000000000) })
    try {
        ranged.nextInt(0)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        ranged.nextInt(5, 5)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
}

fun others() {
    println("-- others")
    val r = Random(2024)
    println((1..10).map { r.nextBoolean() })
    println((1..4).map { String.format("%.12f", r.nextDouble()) })
    println((1..4).map { String.format("%.7f", r.nextFloat().toDouble()) })
    println((1..6).map { String.format("%.9f", r.nextGaussian()) })
    println((1..3).map { String.format("%.9f", r.nextDouble(10.0)) })
    println((1..3).map { String.format("%.9f", r.nextDouble(-5.0, 5.0)) })
    val a = Random(7)
    val b = Random(7)
    println(a.nextInt() == b.nextInt())
    a.setSeed(100)
    b.setSeed(100)
    println((1..3).map { a.nextInt(1000) } == (1..3).map { b.nextInt(1000) })
    a.setSeed(100)
    println(a.nextInt(1000))
    val unseeded = Random()
    val value = unseeded.nextInt(10)
    println(value in 0..9)
}

fun main() {
    ints()
    others()
}
