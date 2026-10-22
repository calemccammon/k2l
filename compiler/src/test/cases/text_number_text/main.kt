import kotlin.math.roundToInt
import kotlin.math.roundToLong

// Numbers to and from text found by the realworld_* programs: the literal -2147483648, "-0.0".toDouble(), nullable
// Doubles printed by their static type on every target, Char.equals(ignoreCase) and println of a platform-typed null
// Int (println(Int) unboxes it and throws NullPointerException).

fun same(a: Char, b: Char, ignoreCase: Boolean) = a.equals(b, ignoreCase)

fun main() {
    println(listOf(-2147483648, Int.MIN_VALUE, -2147483647 - 1, -(2147483647)).joinToString())
    val min = -2147483648
    println("$min ${min.toString(16)} ${min == Int.MIN_VALUE}")
    println(listOf("-0.0", "-0", "0.0", "-0e5", "+0").map { it.toDouble() }.joinToString { it.toString() })
    println("-0.0".toDouble().let { 1 / it })
    val maybe: Double? = "2".toDoubleOrNull()
    val none: Double? = "x".toDoubleOrNull()
    println(maybe)
    println(none)
    println("$maybe $none ${maybe.toString()} ${none.toString()}")
    val f: Float? = 1.5f
    println("$f ${listOf(maybe, none, 3.0).map { it.toString() }}")

    println(listOf('a' to 'A', 'b' to 'b', 'c' to 'D', '1' to '1').map { (x, y) -> "${x.equals(y, true)}/${x.equals(y, false)}/${same(x, y, true)}" })


    // hexadecimal floats, -0.0 truncated or rounded to integers, two significant digits of Double.MIN_VALUE, Boolean.xor
    println(listOf("0x1p3", "0x1.8P-1", "-0X10p0d", "0x.8p1", "0x1", "0xp1").joinToString { it.toDoubleOrNull().toString() })
    println("${(-0.5).toLong()} ${(-0.4).toInt()} ${(-0.0).roundToLong()} ${(-0.2).roundToInt()} ${Math.round(-0.3)}")
    println("%.3e %.1e %e %g".format(Double.MIN_VALUE, Double.MIN_VALUE, 2 * Double.MIN_VALUE, Double.MIN_VALUE))
    println(listOf(true to true, true to false, false to true).map { (a, b) -> "${a xor b}/${a.not()}" })
}
