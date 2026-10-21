// java.lang.StrictMath gives fdlibm's results, bit for bit (Double.toString prints every bit): sin, cos and tan with the
// argument reduction of huge arguments, exp, log, log10 and pow, over sampled arguments and the edge cases; the members
// that are Math's (floor, rint, abs, ...) as well.
import kotlin.math.pow

val edges = listOf(
    0.0, -0.0, Double.MIN_VALUE, -Double.MIN_VALUE, 1e-310, 2.2250738585072014E-308, 1e-300, 1e-20, 3.7e-9, 1e-5, 0.1, 0.25,
    0.5, 0.6744, 0.7, 0.785, 0.7853981633974483, 0.9, 1.0, -1.0, 1.5, 1.5707963267948966, 2.0, 2.356194490192345, 3.0,
    3.141592653589793, 4.71238898038469, 6.283185307179586, 10.0, 22.0, 100.0, 709.0, 709.78, 710.0, -745.0, -746.0, 1e5,
    411774.8, 823549.6, 1e6, 1e10, 1e15, 1e22, 1e100, 1e300, 1.7976931348623157E308, -1e300, -0.3, -2.5, -40.0,
    Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY, Double.NaN,
)

fun line(name: String, values: List<Double>) = println("$name: ${values.joinToString(" ")}")

fun samples(count: Int, scale: Double, seed: Double = 0.5): List<Double> {
    var x = seed
    return List(count) {
        x = (x * 9301.0 + 49297.0) % 233280.0
        (x / 233280.0 - 0.5) * scale
    }
}

// magnitudes from 2^-1070 to 2^1023, both signs
fun spread(count: Int): List<Double> = samples(count, 2.0, 0.25).mapIndexed { i, x -> x * 2.0.pow(i * 2093 / count - 1070) }

fun main() {
    val unary = listOf<Pair<String, (Double) -> Double>>(
        "sin" to StrictMath::sin, "cos" to StrictMath::cos, "tan" to StrictMath::tan, "exp" to StrictMath::exp,
        "log" to StrictMath::log, "log10" to StrictMath::log10, "asin" to StrictMath::asin, "acos" to StrictMath::acos,
        "atan" to StrictMath::atan, "sqrt" to StrictMath::sqrt, "cbrt" to StrictMath::cbrt, "sinh" to StrictMath::sinh,
        "cosh" to StrictMath::cosh, "tanh" to StrictMath::tanh, "expm1" to StrictMath::expm1, "log1p" to StrictMath::log1p,
    )
    for ((name, f) in unary) line(name, edges.map(f))
    for ((name, f) in listOf(unary[0], unary[1], unary[2])) {
        line("$name~1", samples(50, 2.0).map(f))
        line("$name~100", samples(50, 200.0).map(f))
        line("$name~1e6", samples(50, 2e6).map(f))
        line("$name huge", spread(80).map(f))
        // near the multiples of pi/2, where the reduction cancels the most
        line("$name k pi/2", (1..40).map { k -> f(k * k * 1.5707963267948966) } + (1..20).map { k -> f(k * 1e5 * 3.141592653589793) })
    }
    line("exp~", samples(60, 1400.0).map { StrictMath.exp(it) })
    line("log~", samples(60, 2.0).map { StrictMath.log(it + 1.0) } + spread(80).map { StrictMath.log(Math.abs(it)) })
    line("log10~", samples(60, 2.0).map { StrictMath.log10(it + 1.0) } + spread(80).map { StrictMath.log10(Math.abs(it)) } +
        (0..22).runningFold(1.0) { p, _ -> p * 10.0 }.map { StrictMath.log10(it) })
    val xs = samples(60, 6.0)
    val ys = samples(61, 40.0).drop(1)
    line("pow~", xs.zip(ys) { a, b -> StrictMath.pow(Math.abs(a), b) })
    line("pow neg", xs.map { StrictMath.pow(-it - 3.0, 3.0) } + xs.map { StrictMath.pow(it, -2.0) } + xs.map { StrictMath.pow(it, 0.5) })
    line("pow big", xs.map { StrictMath.pow(1.0 + it * 1e-7, 3e9) } + xs.map { StrictMath.pow(Math.abs(it) * 1e-160, 1.9) } +
        xs.map { StrictMath.pow(Math.abs(it) + 1.0, 400.0) } + xs.map { StrictMath.pow(2.0, it * 180.0 - 1000.0) })
    line(
        "pow",
        edges.flatMap { x ->
            listOf(
                StrictMath.pow(x, 2.0), StrictMath.pow(x, 0.5), StrictMath.pow(x, -1.0), StrictMath.pow(x, 3.0), StrictMath.pow(x, -0.5),
                StrictMath.pow(2.5, x), StrictMath.pow(-2.0, x), StrictMath.pow(x, Double.POSITIVE_INFINITY), StrictMath.pow(x, 1e300),
                StrictMath.pow(x, -1e300), StrictMath.pow(x, 0.0), StrictMath.pow(x, Double.NaN),
            )
        },
    )
    line("atan2", edges.flatMap { y -> listOf(StrictMath.atan2(y, 1.0), StrictMath.atan2(y, -2.0), StrictMath.atan2(1.0, y)) })
    line("hypot", edges.map { StrictMath.hypot(it, 3.0) })
    line("IEEEremainder", edges.map { StrictMath.IEEEremainder(it, 3.0) } + edges.map { StrictMath.IEEEremainder(1e300, it) })
    // powers of two print their shortest digits (2^710 is 5.386379163185535E213), subnormals at least two (9.9E-324)
    line("2^k", (-1074..1023 step 13).map { 2.0.pow(it) } + listOf(2.0.pow(710), 2.0.pow(-1073), 2.0.pow(-1060)))
    // members that are Math's
    val plain = listOf(1.5, 2.5, -3.7, 1e17, 0.49999999999999994, 123.456, -1e-5, 7.0)
    line("floor ceil rint", plain.flatMap { listOf(StrictMath.floor(it), StrictMath.ceil(it), StrictMath.rint(it)) })
    line(
        "abs signum ulp",
        plain.flatMap { listOf(StrictMath.abs(it), StrictMath.signum(it), StrictMath.ulp(it), StrictMath.toRadians(it), StrictMath.toDegrees(it)) },
    )
    line("max min", plain.flatMap { listOf(StrictMath.max(it, 2.0), StrictMath.min(it, 2.0)) })
    println(
        "ints: ${StrictMath.abs(-7)} ${StrictMath.max(3, 9)} ${StrictMath.min(3L, -9L)} ${StrictMath.floorMod(-7, 3)} " +
            "${StrictMath.floorDiv(-7, 3)} ${StrictMath.round(2.5)} ${StrictMath.round(-2.5)} ${StrictMath.addExact(2, 3)}",
    )
}
