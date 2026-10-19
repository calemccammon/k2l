package phys.units

import kotlin.math.roundToLong

/** Formats with a fixed number of decimals, without depending on locale formatting. */
internal fun Double.fixed(decimals: Int): String {
    var factor = 1L
    repeat(decimals) { factor *= 10 }
    val scaled = (this * factor).roundToLong()
    val sign = if (scaled < 0) "-" else ""
    val abs = if (scaled < 0) -scaled else scaled
    val whole = abs / factor
    if (decimals == 0) return "$sign$whole"
    val frac = (abs % factor).toString().padStart(decimals, '0')
    return "$sign$whole.$frac"
}

/** Common behavior of the quantities; each one is a value class over SI units. */
interface Quantity<Q : Quantity<Q>> : Comparable<Q> {
    val si: Double
    fun make(si: Double): Q
    val symbol: String

    operator fun plus(other: Q): Q = make(si + other.si)
    operator fun minus(other: Q): Q = make(si - other.si)
    operator fun times(k: Double): Q = make(si * k)
    operator fun div(k: Double): Q = make(si / k)
    operator fun div(other: Q): Double = si / other.si
    operator fun unaryMinus(): Q = make(-si)
    override fun compareTo(other: Q): Int = si.compareTo(other.si)

    fun format(decimals: Int = 2) = "${si.fixed(decimals)} $symbol"
}

@JvmInline
value class Meters(override val si: Double) : Quantity<Meters> {
    override fun make(si: Double) = Meters(si)
    override val symbol get() = "m"
    val km get() = si / 1000
    override fun toString() = format()
}

@JvmInline
value class Seconds(override val si: Double) : Quantity<Seconds> {
    override fun make(si: Double) = Seconds(si)
    override val symbol get() = "s"
    val hours get() = si / 3600
    override fun toString(): String {
        val total = si.roundToLong()
        val h = total / 3600
        val m = total % 3600 / 60
        val s = total % 60
        return if (h > 0) "${h}h${m.toString().padStart(2, '0')}m" else "${m}m${s.toString().padStart(2, '0')}s"
    }
}

@JvmInline
value class Speed(override val si: Double) : Quantity<Speed> {
    override fun make(si: Double) = Speed(si)
    override val symbol get() = "m/s"
    val kmh get() = si * 3.6
    override fun toString() = "${kmh.fixed(1)} km/h"
}

@JvmInline
value class Kilograms(override val si: Double) : Quantity<Kilograms> {
    override fun make(si: Double) = Kilograms(si)
    override val symbol get() = "kg"
    override fun toString() = format(1)
}

operator fun Meters.div(t: Seconds): Speed = Speed(si / t.si)
operator fun Speed.times(t: Seconds): Meters = Meters(si * t.si)
operator fun Double.times(m: Meters): Meters = Meters(this * m.si)
operator fun Int.times(m: Meters): Meters = Meters(this * m.si)

val Int.m get() = Meters(toDouble())
val Double.km get() = Meters(this * 1000)
val Int.km get() = Meters(this * 1000.0)
val Int.min get() = Seconds(this * 60.0)
val Int.h get() = Seconds(this * 3600.0)
val Int.s get() = Seconds(toDouble())
val Int.kg get() = Kilograms(toDouble())

/** Sums any list of one quantity, starting from its zero. */
fun <Q : Quantity<Q>> Iterable<Q>.total(zero: Q): Q = fold(zero) { acc, q -> acc + q }

fun <Q : Quantity<Q>> Iterable<Q>.average(zero: Q): Q {
    var n = 0
    val sum = fold(zero) { acc, q -> n++; acc + q }
    require(n > 0) { "average of no ${zero.symbol} values" }
    return sum / n.toDouble()
}

fun <Q : Quantity<Q>> max(a: Q, b: Q): Q = if (a >= b) a else b
