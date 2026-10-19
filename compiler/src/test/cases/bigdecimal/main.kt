import java.math.BigDecimal
import java.math.BigInteger
import java.math.MathContext
import java.math.RoundingMode

val MODES = listOf(
    RoundingMode.UP, RoundingMode.DOWN, RoundingMode.CEILING, RoundingMode.FLOOR,
    RoundingMode.HALF_UP, RoundingMode.HALF_DOWN, RoundingMode.HALF_EVEN,
)

fun construction() {
    println("-- construction")
    println(BigDecimal("1.10"))
    println(BigDecimal("-0.000001"))
    println(BigDecimal("-0.0000001"))
    println(BigDecimal("1E+3"))
    println(BigDecimal("1.5e-10"))
    println(BigDecimal("123.456E5"))
    println(BigDecimal("0.00"))
    println(BigDecimal("0E-10"))
    println(BigDecimal("0E+10"))
    println(BigDecimal(".5"))
    println(BigDecimal("5."))
    println(BigDecimal("+7.0"))
    println(BigDecimal(42))
    println(BigDecimal(123456789012L))
    println(BigDecimal(0.5))
    println(BigDecimal(0.1))
    println(BigDecimal(-2.75))
    println(BigDecimal(1e20))
    println(BigDecimal(3.0))
    println(BigDecimal(BigInteger("12345678901234567890")))
    println(BigDecimal(BigInteger("12345"), 3))
    println(BigDecimal(BigInteger("12345"), -3))
    println(BigDecimal.valueOf(2.5))
    println(BigDecimal.valueOf(0.1))
    println(BigDecimal.valueOf(100.0))
    println(BigDecimal.valueOf(1.0E-5))
    println(BigDecimal.valueOf(1.0E10))
    println(BigDecimal.valueOf(12345L))
    println(BigDecimal.valueOf(12345L, 2))
    println(BigDecimal.valueOf(-5L, -2))
    println(7.toBigDecimal())
    println(7L.toBigDecimal())
    println(1.5.toBigDecimal())
    println(0.1.toBigDecimal())
    println("3.14159".toBigDecimal())
    println("abc".toBigDecimalOrNull())
    println("1.5".toBigDecimalOrNull())
    println(BigInteger.TEN.toBigDecimal())
    println(BigInteger("1234").toBigDecimal(2))
    println(BigDecimal.ZERO)
    println(BigDecimal.ONE)
    println(BigDecimal.TEN)
}

fun arithmetic() {
    println("-- arithmetic")
    val a = BigDecimal("1.10")
    val b = BigDecimal("2.505")
    println(a + b)
    println(a - b)
    println(a * b)
    println(-a)
    println(a.negate().abs())
    println(a.add(b).scale())
    println(a.multiply(b).scale())
    println(a.multiply(b).precision())
    println(a.pow(3))
    println(BigDecimal("0.5").pow(10))
    println(a.unscaledValue())
    println(a.signum())
    println(BigDecimal("-3.00").signum())
    println(BigDecimal("0.000").signum())
    println(a.remainder(BigDecimal("0.3")))
    println(BigDecimal("7").remainder(BigDecimal("-3")))
    println(BigDecimal("-7.5").remainder(BigDecimal("2")))
    println(BigDecimal("100").divideToIntegralValue(BigDecimal("7")))
    println(BigDecimal("100.0").divideToIntegralValue(BigDecimal("0.7")))
    println(BigDecimal("1").divideToIntegralValue(BigDecimal("3")))
    println(a.min(b))
    println(a.max(b))
    println(BigDecimal("123456789.123456789") * BigDecimal("987654321.987654321"))
    var total = BigDecimal.ZERO
    for (price in listOf("19.99", "5.01", "0.10", "100")) total += BigDecimal(price)
    total *= BigDecimal("1.0825")
    println(total)
    println(total.setScale(2, RoundingMode.HALF_UP))
    var counter = BigDecimal("9.9")
    counter++
    println(counter)
    counter--
    counter--
    println(counter)
    println(a.movePointLeft(3))
    println(a.movePointRight(3))
    println(a.movePointRight(1))
    println(a.scaleByPowerOfTen(5))
    println(BigDecimal("1234.5678").toBigInteger())
    println(BigDecimal("-1234.5678").toBigInteger())
    println(BigDecimal("1E+5").toBigInteger())
}

fun scaling() {
    println("-- setScale table")
    val values = listOf("5.5", "2.5", "1.6", "1.1", "1.0", "0.5", "-0.5", "-1.1", "-1.6", "-2.5", "-5.5", "0.05", "99.995")
    for (v in values) {
        val x = BigDecimal(v)
        val row = MODES.joinToString(" ") { m -> "${m.name}=${x.setScale(0, m)}" }
        println("$v: $row")
        val row2 = MODES.joinToString(" ") { m -> x.setScale(1, m).toString() }
        println("  scale 1: $row2")
    }
    println(BigDecimal("2.5").setScale(3))
    println(BigDecimal("2.500").setScale(1))
    println(BigDecimal("1E+3").setScale(0))
    println(BigDecimal("12345").setScale(-2, RoundingMode.HALF_UP))
    println(BigDecimal("12355").setScale(-1, RoundingMode.HALF_EVEN))
    try {
        println(BigDecimal("2.55").setScale(1, RoundingMode.UNNECESSARY))
    } catch (e: ArithmeticException) {
        println("ArithmeticException: ${e.message}")
    }
    println(RoundingMode.HALF_EVEN)
    println(RoundingMode.valueOf("CEILING"))
    println(RoundingMode.HALF_UP == RoundingMode.HALF_UP)
    println(RoundingMode.DOWN.ordinal)
}

fun division() {
    println("-- division")
    val pairs = listOf("1" to "3", "2" to "3", "10" to "4", "-10" to "4", "1" to "7", "22" to "7", "100" to "-8", "0.5" to "3", "1.00" to "3", "123456.789" to "0.001")
    for ((n, d) in pairs) {
        val x = BigDecimal(n)
        val y = BigDecimal(d)
        println("$n / $d: ${x / y} | ${x.divide(y, 5, RoundingMode.HALF_UP)} | ${x.divide(y, 0, RoundingMode.FLOOR)} | ${x.divide(y, 3, RoundingMode.HALF_EVEN)} | ${x.divide(y, MathContext.DECIMAL32)}")
        println("  ${x.divide(y, MathContext(3))} ${x.divide(y, MathContext(10, RoundingMode.DOWN))} ${x.divide(y, MathContext(1, RoundingMode.UP))} ${x.divide(y, RoundingMode.CEILING)}")
    }
    println(BigDecimal("1").divide(BigDecimal("8")))
    println(BigDecimal("1.00").divide(BigDecimal("8")))
    println(BigDecimal("100").divide(BigDecimal("4")))
    println(BigDecimal("1").divide(BigDecimal("0.25")))
    println(BigDecimal("3").divide(BigDecimal("1.5")))
    println(BigDecimal("1E+3").divide(BigDecimal("4")))
    println(BigDecimal("12.5").divide(BigDecimal("0.05")))
    println(BigDecimal("1").divide(BigDecimal("3"), MathContext.UNLIMITED.let { MathContext(20) }))
    println(BigDecimal("2").divide(BigDecimal("3"), MathContext.DECIMAL64))
    println(BigDecimal("2").divide(BigDecimal("3"), MathContext.DECIMAL128))
    println(BigDecimal("10").divide(BigDecimal("3"), MathContext(3, RoundingMode.HALF_UP)))
    println(BigDecimal("999.9").divide(BigDecimal("1"), MathContext(3, RoundingMode.HALF_UP)))
    println(BigDecimal("0").divide(BigDecimal("3.5"), MathContext(5)))
    println(BigDecimal("100000000000").divide(BigDecimal("1"), MathContext(4)))
    println(BigDecimal("3.14159265358979").round(MathContext(5)))
    println(BigDecimal("3.14159265358979").round(MathContext(1, RoundingMode.UP)))
    println(BigDecimal("999.99").round(MathContext(3, RoundingMode.HALF_UP)))
    println(BigDecimal("1.23456").add(BigDecimal("9.87654"), MathContext(4)))
    println(BigDecimal("1.23456").multiply(BigDecimal("9.87654"), MathContext(4)))
    println(MathContext.DECIMAL32)
    println(MathContext(5, RoundingMode.FLOOR))
    println(MathContext.DECIMAL64.precision)
    println(MathContext.DECIMAL64.roundingMode)
}

fun formatting() {
    println("-- formatting")
    val values = listOf(
        "0", "0.0", "0.00", "1", "-1", "1.0", "12345.6789", "-0.5", "0.000001", "0.0000001", "1E+3", "1.23E+10", "-1.5E-7", "100", "1E-10",
        "123456789012345678901234567890.123456789", "0E+3", "1.000E+3",
    )
    for (v in values) {
        val x = BigDecimal(v)
        println("$v: toString=$x plain=${x.toPlainString()} scale=${x.scale()} precision=${x.precision()} strip=${x.stripTrailingZeros()} strip.plain=${x.stripTrailingZeros().toPlainString()}")
    }
    println(BigDecimal("1000").stripTrailingZeros())
    println(BigDecimal("1000").stripTrailingZeros().scale())
    println(BigDecimal("10.50").stripTrailingZeros())
    println(BigDecimal("0.000").stripTrailingZeros())
    println("price: ${BigDecimal("9.99")}")
    println(listOf(BigDecimal("1.5"), BigDecimal("2.50")))
}

fun comparisons() {
    println("-- comparisons")
    val a = BigDecimal("1.0")
    val b = BigDecimal("1.00")
    val c = BigDecimal("2")
    println(a == b)
    println(a.equals(b))
    println(a.compareTo(b))
    println(a.compareTo(c))
    println(c.compareTo(a))
    println(a < c)
    println(a >= b)
    println(a.hashCode())
    println(b.hashCode())
    println(BigDecimal("123456789012345678901234567890.5").hashCode())
    println(BigDecimal("-3.25").hashCode())
    println(BigDecimal("0").hashCode())
    println(setOf(a, b, BigDecimal("1.0")).size)
    println(listOf(a, b).map { it.stripTrailingZeros() }.toSet().size)
    println(listOf(c, a, BigDecimal("-3"), BigDecimal("1.5")).sorted())
    println(listOf(c, a, BigDecimal("-3")).maxOrNull())
    println(listOf("1.1", "2.2", "3.3").map { it.toBigDecimal() }.fold(BigDecimal.ZERO) { acc, v -> acc + v })
    println(listOf("1.1", "2.2", "3.3").sumOf { it.toBigDecimal() })
}

fun conversions() {
    println("-- conversions")
    val values = listOf("0", "1.5", "-1.5", "123.999", "1E+3", "123456789012345678901.5", "1e-5", "-2147483649.5", "0.1", "3.14159265358979323846")
    for (v in values) {
        val x = BigDecimal(v)
        println("$v: int=${x.toInt()} double=${x.toDouble()}")
    }
    println(BigDecimal("12345678901.7").toLong())
    println(BigDecimal("0.1").toDouble() + BigDecimal("0.2").toDouble())
    println(BigDecimal("1e400").toDouble())
}

fun failures() {
    println("-- failures")
    fun attempt(label: String, block: () -> Any?) {
        try {
            println("$label: ${block()}")
        } catch (e: Exception) {
            println("$label: ${e::class.simpleName}: ${e.message}")
        }
    }
    attempt("div0") { BigDecimal.ONE / BigDecimal.ZERO }
    attempt("0div0") { BigDecimal.ZERO.divide(BigDecimal.ZERO) }
    attempt("exact1") { BigDecimal.ONE.divide(BigDecimal.ZERO) }
    attempt("exact2") { BigDecimal.ONE.divide(BigDecimal("3")) }
    attempt("scaled0") { BigDecimal.ONE.divide(BigDecimal.ZERO, 2, RoundingMode.HALF_UP) }
    attempt("mc0") { BigDecimal.ONE.divide(BigDecimal.ZERO, MathContext.DECIMAL32) }
    attempt("rem0") { BigDecimal.ONE.remainder(BigDecimal.ZERO) }
    attempt("big0") { BigDecimal(BigInteger.TEN.pow(30)).divide(BigDecimal.ZERO, 2, RoundingMode.UP) }
    attempt("pow") { BigDecimal.TEN.pow(-1) }
    attempt("empty") { BigDecimal("") }
    attempt("sign") { BigDecimal("-") }
    attempt("letters") { BigDecimal("abc") }
    attempt("twoDots") { BigDecimal("1.2.3") }
    attempt("exp") { BigDecimal("1e") }
    attempt("exp2") { BigDecimal("1e+") }
    attempt("exp3") { BigDecimal("1ex") }
    attempt("nan") { BigDecimal(Double.NaN) }
    attempt("inf") { BigDecimal(Double.POSITIVE_INFINITY) }
    attempt("valueOfNan") { BigDecimal.valueOf(Double.NaN) }
    attempt("enum") { RoundingMode.valueOf("SIDEWAYS") }
}

fun main() {
    construction()
    arithmetic()
    scaling()
    division()
    formatting()
    comparisons()
    conversions()
    failures()
}
