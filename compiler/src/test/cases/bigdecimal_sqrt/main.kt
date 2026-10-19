import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode
import java.util.Random

fun root(value: String, mc: MathContext): String = try {
    BigDecimal(value).sqrt(mc).toString()
} catch (e: ArithmeticException) {
    "ArithmeticException: ${e.message}"
}

fun main() {
    val values = listOf(
        "2", "3", "4", "5", "7", "10", "16", "99", "0.5", "0.1", "0.01", "0.25", "0.0016", "100", "1E+4", "1E-4", "1E+3", "1E+2",
        "2.000", "2.25000000", "6.25", "25.00", "1.00", "9.999999", "123456789", "0.000123", "1.5E-7", "1234.5678", "4E+2",
        "12345678901234567890123.456", "1E+100", "1E-99", "0", "0.00", "0E+4", "15241578750190521", "1.4142135623730950488",
        "0.0000000001", "1000000", "999999999999999999999999",
    )
    val precisions = listOf(1, 2, 3, 7, 15, 16, 20, 34)
    for (mode in listOf(RoundingMode.HALF_UP, RoundingMode.HALF_EVEN, RoundingMode.DOWN, RoundingMode.UP)) {
        println("== $mode")
        for (value in values) {
            println("$value: " + precisions.joinToString(" | ") { root(value, MathContext(it, mode)) })
        }
    }
    println("== other modes")
    for (value in listOf("2", "3", "0.5", "1E+3", "25.00", "10")) {
        for (mode in listOf(RoundingMode.HALF_DOWN, RoundingMode.FLOOR, RoundingMode.CEILING)) {
            println("$value $mode: " + listOf(1, 5, 12).joinToString(" | ") { root(value, MathContext(it, mode)) })
        }
    }
    println("== exact")
    for (value in values) {
        println("$value: " + root(value, MathContext.UNLIMITED) + " | " + root(value, MathContext(40, RoundingMode.UNNECESSARY)) +
            " | " + root(value, MathContext(2, RoundingMode.UNNECESSARY)))
    }
    println("== defaults")
    println(BigDecimal("2").sqrt(MathContext.DECIMAL128))
    println(BigDecimal("2").sqrt(MathContext.DECIMAL64))
    println(BigDecimal("2").sqrt(MathContext.DECIMAL32))
    println(BigDecimal("144").sqrt(MathContext.DECIMAL32))
    println(BigDecimal("0.0002").sqrt(MathContext.DECIMAL64))
    println(BigDecimal(2.0).sqrt(MathContext(30)))
    println(root("-4", MathContext.DECIMAL64))
    println(root("-0.0001", MathContext.UNLIMITED))
    println("== random")
    val random = Random(20240607)
    val modes = RoundingMode.values().filter { it != RoundingMode.UNNECESSARY }
    repeat(250) {
        val digits = 1 + random.nextInt(30)
        val unscaled = StringBuilder()
        repeat(digits) { unscaled.append(random.nextInt(10)) }
        if (random.nextInt(4) == 0) unscaled.append("0".repeat(random.nextInt(6)))
        val value = BigDecimal(java.math.BigInteger(unscaled.toString()), random.nextInt(40) - 8)
        val mc = MathContext(random.nextInt(40), modes[random.nextInt(modes.size)])
        println("$value $mc: " + root(value.toString(), mc))
    }
}
