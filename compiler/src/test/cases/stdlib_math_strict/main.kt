import kotlin.math.*

// The JVM's hypot, atan, atan2, asin, acos, cbrt, sinh, cosh, tanh, expm1 and ln1p are fdlibm's (StrictMath), which C's libm
// does not match in the last bit; these print every bit (Double.toString), over many arguments and the edge cases.

val edges = listOf(
    0.0, -0.0, Double.MIN_VALUE, -Double.MIN_VALUE, 2.2250738585072014E-308, 1e-300, 1e-20, 3e-9, 1e-5, 0.1, 0.25, 0.4375, 0.5,
    0.7, 0.9, 0.975, 1.0, -1.0, 1.1875, 1.5, 2.0, 2.4375, 3.0, 10.0, 21.9, 22.0, 30.0, 100.0, 709.0, 709.8, 710.0, 711.0,
    1e10, 1e300, Double.MAX_VALUE, Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY, Double.NaN, -0.3, -2.5, -40.0, -800.0,
)

fun line(name: String, values: List<Double>) = println("$name: ${values.joinToString(" ")}")

fun samples(count: Int, scale: Double): List<Double> {
    var x = 0.5
    return List(count) {
        x = (x * 9301.0 + 49297.0) % 233280.0
        (x / 233280.0 - 0.5) * scale
    }
}

fun main() {
    val one = listOf<Pair<String, (Double) -> Double>>(
        "atan" to ::atan, "asin" to ::asin, "acos" to ::acos, "cbrt" to ::cbrt, "sinh" to ::sinh, "cosh" to ::cosh,
        "tanh" to ::tanh, "expm1" to ::expm1, "ln1p" to ::ln1p,
    )
    for ((name, f) in one) line(name, edges.map(f))
    for ((name, f) in one) {
        val scale = when (name) {
            "asin", "acos" -> 2.0
            "sinh", "cosh", "expm1" -> 60.0
            "ln1p" -> 4.0
            else -> 200.0
        }
        line("$name~", samples(60, scale).map { f(if (name == "ln1p") abs(it) - 0.9 else it) })
    }
    val xs = samples(80, 300.0)
    val ys = samples(81, 7.0).drop(1)
    line("hypot~", xs.zip(ys) { a, b -> hypot(a, b) })
    line("atan2~", xs.zip(ys) { a, b -> atan2(a, b) })
    line("hypot tiny~", xs.zip(ys) { a, b -> hypot(a * 1e-306, b * 1e-308) } + xs.zip(ys) { a, b -> hypot(a * 1e-160, b * 1e-162) })
    line("hypot huge~", xs.zip(ys) { a, b -> hypot(a * 1e303, b * 1e305) } + xs.zip(ys) { a, b -> hypot(a * 1e150, b * 1e152) })
    line("hypot", edges.map { hypot(it, 3.0) } + edges.map { hypot(1e-310, it) } + listOf(hypot(1e300, 1e300), hypot(1e-300, 3e-310), hypot(Double.NaN, Double.NEGATIVE_INFINITY)))
    line("atan2", edges.flatMap { y -> listOf(atan2(y, 1.0), atan2(y, -2.0), atan2(y, 0.0), atan2(y, Double.NEGATIVE_INFINITY), atan2(1.0, y)) })
    line("IEEErem", listOf(5.0.IEEErem(3.0), (-5.0).IEEErem(3.0), 7.5.IEEErem(2.0), 6.5.IEEErem(2.0), (-6.5).IEEErem(2.0), 1e300.IEEErem(3.0), 0.0.IEEErem(-1.0), (-0.0).IEEErem(5.0), 5e-324.IEEErem(1e-323), Double.MAX_VALUE.IEEErem(1.5), 3.0.IEEErem(Double.MAX_VALUE), Double.NaN.IEEErem(1.0), 1.0.IEEErem(0.0)))
    line("pow", listOf(1.0.pow(Double.NaN), (-1.0).pow(Double.POSITIVE_INFINITY), 1.0.pow(Double.NEGATIVE_INFINITY), 2.0.pow(Double.NaN), Double.NaN.pow(0.0), 0.5.pow(Double.POSITIVE_INFINITY), Math.pow(1.0, Double.NaN)))
    line("min/max", listOf(min(0.0, -0.0), min(-0.0, 0.0), max(0.0, -0.0), max(-0.0, 0.0), min(1.0, Double.NaN), max(Double.NaN, 1.0), minOf(3.0, 1.0, -0.0, 0.0), maxOf(-0.0, -1.0, 0.0), Math.min(-0.0, 0.0), Math.max(-0.0, 0.0)))
    line("truncate", listOf(truncate(-0.5), truncate(-0.0), truncate(0.7), truncate(-1e300), ceil(-0.5), round(-0.4)))
    println("float: ${hypot(3f, 4f)} ${atan2(1f, 2f)} ${cbrt(10f)} ${tanh(0.5f)} ${2f.pow(0.5f)} ${max(-0f, 0f)} ${1.5f.IEEErem(1f)}")
    println("java: ${Math.hypot(5.0, 12.0)} ${Math.atan(0.5)} ${Math.asin(0.3)} ${Math.acos(0.3)} ${Math.expm1(1e-3)} ${Math.log1p(1e-3)} ${Math.IEEEremainder(10.0, 3.0)}")
}
