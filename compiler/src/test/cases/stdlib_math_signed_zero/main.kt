// Rounding and sign functions keep the sign of zero and pass NaN and the infinities through, as on the JVM.
import kotlin.math.abs
import kotlin.math.absoluteValue
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.round
import kotlin.math.roundToInt
import kotlin.math.roundToLong
import kotlin.math.sign
import kotlin.math.truncate
import kotlin.math.withSign

// the sign of a zero shows in 1 / x
fun show(label: String, x: Double) = println("$label $x ${1.0 / x}")

class Holder(val value: Double)

fun main() {
    val inputs = listOf(0.0, -0.0, -0.4, -0.5, -0.6, 0.4, 0.5, -1.5, 2.5, Double.NaN, Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY)
    for (x in inputs) {
        println("x=$x")
        show("  floor", floor(x))
        show("  ceil", ceil(x))
        show("  round", round(x))
        show("  truncate", truncate(x))
        show("  abs", abs(x))
        show("  absoluteValue", x.absoluteValue)
        show("  sign", sign(x))
        show("  .sign", x.sign)
        show("  withSign(-1)", x.withSign(-1.0))
        show("  withSign(-0.0)", x.withSign(-0.0))
        show("  withSign(0.0)", x.withSign(0.0))
        show("  Math.floor", Math.floor(x))
        show("  Math.ceil", Math.ceil(x))
        show("  Math.rint", Math.rint(x))
        show("  Math.abs", Math.abs(x))
        show("  Math.signum", Math.signum(x))
        show("  Math.copySign", Math.copySign(1.0, x))
        if (!x.isNaN() && !x.isInfinite()) {
            println("  roundToInt ${x.roundToInt()} roundToLong ${x.roundToLong()} Math.round ${Math.round(x)} toInt ${x.toInt()}")
        }
    }
    // a non-simple argument (a field read through a call)
    val h = Holder(-0.0)
    show("floor of field", floor(h.value))
    show("floor of expression", floor(h.value * 1.0))
    show("floor of -0.25", floor(listOf(-0.25)[0]))
    println("floor in a list: ${listOf(floor(-0.0), ceil(-0.5)).map { 1.0 / it }}")
}
