import java.math.BigDecimal
import java.math.BigInteger
import java.math.MathContext
import java.math.RoundingMode

var seed = 123457

fun next(bound: Int): Int {
    seed = (seed * 1103 + 12345) % 1000003
    return (seed / 7) % bound
}

fun digits(length: Int): String {
    val sb = StringBuilder()
    sb.append('1' + next(9))
    repeat(length - 1) { sb.append('0' + next(10)) }
    return sb.toString()
}

fun randomInteger(): BigInteger {
    val kind = next(10)
    val length = if (kind == 0) 1 + next(3) else 1 + next(70)
    val text = if (kind == 1) "9".repeat(length) else if (kind == 2) "1" + "0".repeat(length) else digits(length)
    return BigInteger((if (next(3) == 0) "-" else "") + text)
}

fun integers() {
    println("-- integers")
    for (i in 1..150) {
        val a = randomInteger()
        val b = randomInteger()
        val sum = a + b
        val diff = a - b
        val product = a * b
        val q = a / b
        val r = a % b
        val check = q * b + r == a && r.abs() < b.abs()
        val shift = next(80)
        println(
            "$i ${sum.hashCode()} ${diff.hashCode()} ${product.hashCode()} ${q.hashCode()} ${r.hashCode()} $check " +
                "${a.gcd(b).hashCode()} ${(a shl shift).hashCode()} ${(a shr shift).hashCode()} " +
                "${(a and b).hashCode()} ${(a or b).hashCode()} ${(a xor b).hashCode()} ${a.compareTo(b)} ${a.bitLength()} " +
                "${a.mod(b.abs()).hashCode()}",
        )
        val text = a.toString(16)
        if (BigInteger(text, 16) != a || BigInteger(a.toString(7), 7) != a) println("radix round trip failed for $a")
        if (a.abs().sqrt().pow(2) > a.abs()) println("sqrt too big for $a")
    }
    val a = randomInteger()
    val b = randomInteger()
    println("${a * b} ${a / b} ${a % b}")
}

fun decimals() {
    println("-- decimals")
    val modes = listOf(
        RoundingMode.UP, RoundingMode.DOWN, RoundingMode.CEILING, RoundingMode.FLOOR,
        RoundingMode.HALF_UP, RoundingMode.HALF_DOWN, RoundingMode.HALF_EVEN,
    )
    for (i in 1..120) {
        val a = BigDecimal(randomInteger(), next(12) - 3)
        val b = BigDecimal(randomInteger(), next(12) - 3)
        val scale = next(8)
        val mode = modes[next(modes.size)]
        val precision = 1 + next(20)
        println("$i $a | $b | ${a + b} | ${a - b} | ${a * b}")
        println("  ${a.divide(b, scale, mode)} ${a.divide(b, MathContext(precision, mode))} ${a.setScale(scale, mode)} ${a.round(MathContext(precision, mode))}")
        println("  ${a.compareTo(b)} ${a == b} ${a.hashCode()} ${a.stripTrailingZeros()} ${a.toPlainString()} ${a.precision()} ${a.negate().scale()}")
        println("  ${a.remainder(b)} ${a.divideToIntegralValue(b)} ${a.toDouble()} ${a.toBigInteger()}")
    }
}

fun main() {
    integers()
    decimals()
}
