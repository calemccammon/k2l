import java.math.BigInteger

fun main() {
    val longs = listOf("9223372036854775807", "-9223372036854775808", "9223372036854775808", "12345678901234567890", "-9007199254740993")
    for (a in longs) println("$a: long=${BigInteger(a).toLong()} hash=${BigInteger(a).hashCode()}")
    println(BigInteger.valueOf(-9007199254740993L))
    println(BigInteger.valueOf(Long.MAX_VALUE))
    println(BigInteger.valueOf(Long.MIN_VALUE))
    println(BigInteger.valueOf(Long.MAX_VALUE).toLong())
    println(BigInteger.valueOf(Long.MIN_VALUE).toLong() == Long.MIN_VALUE)
    println(BigInteger.valueOf(Long.MAX_VALUE) * BigInteger.valueOf(Long.MAX_VALUE))
    println(BigInteger("123456789012345678").toLong() * 10)
    println(BigInteger.valueOf(Long.MAX_VALUE).add(BigInteger.ONE).longValueExactOrNull())
}

fun BigInteger.longValueExactOrNull(): Long? = try {
    longValueExact()
} catch (e: ArithmeticException) {
    null
}
