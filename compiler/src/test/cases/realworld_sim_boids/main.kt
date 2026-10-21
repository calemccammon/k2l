import kotlin.math.E
import kotlin.math.IEEErem
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.absoluteValue
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.ln
import kotlin.math.log10
import kotlin.math.nextDown
import kotlin.math.nextUp
import kotlin.math.pow
import kotlin.math.round
import kotlin.math.roundToInt
import kotlin.math.roundToLong
import kotlin.math.sign
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.truncate
import kotlin.math.ulp
import kotlin.math.withSign
import kotlin.random.Random

// A boids flock (separation, alignment, cohesion) steered with angles, followed by a tour of
// kotlin.math on the values such a simulation produces, including its edge cases.

class Boid(var x: Double, var y: Double, var heading: Double, var speed: Double)

class Flock(count: Int, seed: Int, private val size: Double) {
    val boids: List<Boid>

    init {
        val rng = Random(seed)
        boids = List(count) { Boid(rng.nextDouble(size), rng.nextDouble(size), rng.nextDouble(-PI, PI), rng.nextDouble(0.5, 1.5)) }
    }

    private fun wrap(v: Double) = v - floor(v / size) * size

    private fun angleDiff(a: Double, b: Double): Double = (b - a).IEEErem(2 * PI)

    fun step() {
        val turns = DoubleArray(boids.size)
        for ((i, b) in boids.withIndex()) {
            var cx = 0.0
            var cy = 0.0
            var sx = 0.0
            var sy = 0.0
            var align = 0.0
            var n = 0
            for (o in boids) {
                if (o === b) continue
                val d = hypot(o.x - b.x, o.y - b.y)
                if (d > 10.0) continue
                n++
                cx += o.x
                cy += o.y
                align += angleDiff(b.heading, o.heading)
                if (d < 3.0) {
                    sx -= (o.x - b.x) / (d * d + 1e-9)
                    sy -= (o.y - b.y) / (d * d + 1e-9)
                }
            }
            if (n == 0) continue
            val toCenter = atan2(cy / n - b.y, cx / n - b.x)
            val away = if (sx == 0.0 && sy == 0.0) b.heading else atan2(sy, sx)
            val turn = 0.05 * angleDiff(b.heading, toCenter) + 0.1 * (align / n) + 0.15 * angleDiff(b.heading, away)
            turns[i] = turn.coerceIn(-0.3, 0.3)
        }
        for ((i, b) in boids.withIndex()) {
            b.heading = (b.heading + turns[i]).IEEErem(2 * PI)
            b.x = wrap(b.x + cos(b.heading) * b.speed)
            b.y = wrap(b.y + sin(b.heading) * b.speed)
        }
    }

    fun order(): Double {
        val sx = boids.sumOf { cos(it.heading) }
        val sy = boids.sumOf { sin(it.heading) }
        return hypot(sx, sy) / boids.size
    }
}

fun flock() {
    println("-- flock")
    val f = Flock(24, 7, 40.0)
    println("order at start ${"%.6f".format(f.order())}")
    for (round in 1..4) {
        repeat(25) { f.step() }
        println("after ${round * 25} steps order ${"%.6f".format(f.order())}")
    }
    val b = f.boids[0]
    println("boid 0 at (${"%.4f".format(b.x)}, ${"%.4f".format(b.y)}) heading ${"%.4f".format(b.heading)}")
    val grid = Array(4) { IntArray(4) }
    for (boid in f.boids) grid[(boid.y / 10).toInt().coerceIn(0, 3)][(boid.x / 10).toInt().coerceIn(0, 3)]++
    grid.forEach { println(it.joinToString(" ")) }
}

fun show(label: String, values: List<Double>) = println("$label: ${values.joinToString(", ")}")

fun mathTour() {
    println("-- rounding")
    val xs = listOf(2.5, -2.5, 3.5, -0.5, 0.49999999999999994, 1e16 + 1, -7.0001)
    show("floor", xs.map { floor(it) })
    show("ceil", xs.map { ceil(it) })
    show("round", xs.map { round(it) })
    show("truncate", xs.map { truncate(it) })
    println("roundToInt: ${xs.map { it.roundToInt() }}")
    println("roundToLong: ${listOf(2.5, -2.5, 1e15 + 0.5, -0.5).map { it.roundToLong() }}")
    println("saturating: ${listOf(1e10, -1e10, Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY).map { it.roundToInt() }}")
    println("toInt: ${listOf(3.99, -3.99, 1e10, -1e10, Double.NaN).map { it.toInt() }}")
    try {
        Double.NaN.roundToInt()
    } catch (e: IllegalArgumentException) {
        println("NaN.roundToInt: ${e.message}")
    }

    println("-- signs")
    val edges = listOf(0.0, -0.0, 1.5, -1.5, Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY, Double.NaN, Double.MIN_VALUE)
    show("sign", edges.map { sign(it) })
    show("abs", edges.map { abs(it) })
    show("withSign(-1)", edges.map { it.withSign(-1) })
    show("withSign(-0.0)", edges.map { 3.0.withSign(it) })
    show("absoluteValue", edges.map { it.absoluteValue })
    println("1/-0.0 = ${1.0 / -0.0}, -0.0 == 0.0: ${-0.0 == 0.0}, compare: ${(-0.0).compareTo(0.0)}")
    println("min/max with -0.0: ${minOf(0.0, -0.0)} ${maxOf(-0.0, 0.0)} ${kotlin.math.min(Double.NaN, 1.0)}")

    println("-- ulp and neighbours")
    show("ulp", listOf(1.0, 0.0, -2.0, 1e300, Double.MAX_VALUE, Double.MIN_VALUE).map { it.ulp })
    show("nextUp", listOf(1.0, 0.0, -0.0, -Double.MIN_VALUE, Double.MAX_VALUE).map { it.nextUp() })
    show("nextDown", listOf(1.0, 0.0, Double.MIN_VALUE, Double.NEGATIVE_INFINITY).map { it.nextDown() })
    println("ulp(NaN)=${Double.NaN.ulp} ulp(inf)=${Double.POSITIVE_INFINITY.ulp}")

    println("-- IEEErem vs %")
    val pairs = listOf(5.0 to 3.0, -5.0 to 3.0, 7.5 to 2.0, 6.5 to 2.0, 10.0 to -4.0, 1.0 to 0.0, Double.POSITIVE_INFINITY to 2.0, 3.0 to Double.POSITIVE_INFINITY)
    println(pairs.joinToString(" ") { (a, b) -> "${a.IEEErem(b)}|${a % b}" })

    println("-- powers and logs")
    show("pow", listOf(2.0.pow(10), 2.0.pow(-1074), 2.0.pow(0.5), (-8.0).pow(1.0 / 3), 0.0.pow(0), Double.NaN.pow(0), 1.0.pow(Double.NaN), (-2.0).pow(3), 10.0.pow(308)))
    show("int pow", listOf(3.0.pow(4), 1.5.pow(-2), (-1.0).pow(Int.MAX_VALUE)))
    show("ln", listOf(ln(E), ln(1.0), ln(0.0), ln(-1.0), ln(Double.POSITIVE_INFINITY)))
    show("log10", listOf(log10(1000.0), log10(2.0), log10(0.001), log10(Double.MIN_VALUE)))
    show("exp", listOf(exp(1.0), exp(-1.0), exp(710.0), exp(-750.0), exp(Double.NaN)))
    show("sqrt", listOf(sqrt(2.0), sqrt(-0.0), sqrt(-1.0), sqrt(Double.POSITIVE_INFINITY), sqrt(1e-320)))
    show("hypot", listOf(hypot(3.0, 4.0), hypot(1e300, 1e300), hypot(Double.NaN, Double.POSITIVE_INFINITY), hypot(-5.0, 12.0)))
    show("atan2", listOf(atan2(0.0, -1.0), atan2(-0.0, -1.0), atan2(1.0, 0.0), atan2(0.0, 0.0), atan2(-0.0, 0.0), atan2(1.0, Double.NEGATIVE_INFINITY)))
    show("trig", listOf(sin(PI), cos(PI), sin(-0.0), cos(Double.POSITIVE_INFINITY), sin(1e22)))

    println("-- limits")
    println("${Double.MIN_VALUE} ${Double.MAX_VALUE} ${-Double.MAX_VALUE} ${Double.MIN_VALUE / 2} ${Double.MAX_VALUE * 2}")
    println("${Int.MIN_VALUE.toDouble()} ${Long.MIN_VALUE.toDouble()} ${Float.MIN_VALUE} ${Float.MAX_VALUE}")
    println("${PI.toFloat()} ${E.toFloat()} ${(PI * 1e10).roundToLong()} ${(0.1f + 0.2f)} ${0.1 + 0.2}")
    println("NaN checks: ${Double.NaN.isNaN()} ${(0.0 / 0.0).isNaN()} ${Double.NaN != Double.NaN}")
    println("sorted: ${listOf(3.0, Double.NaN, -0.0, 0.0, Double.NEGATIVE_INFINITY, 1.0).sorted()}")
    println(doubleArrayOf(1.0, 2.5, -0.0).joinToString("|") + " " + doubleArrayOf(1.0, 2.5).joinToString(" ") { "%.1f".format(it) })
    println(listOf(1.0f, 0.1f, 1f / 3).joinToString() + " " + listOf(1.0, 0.5).joinToString(prefix = "<", postfix = ">"))
}

fun main() {
    flock()
    mathTour()
}
