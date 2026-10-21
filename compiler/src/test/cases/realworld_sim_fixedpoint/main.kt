// Fixed-point arithmetic as games and embedded code use it: Q16.16 in Int with 64-bit
// intermediates, money in Long cents with banker's rounding, saturating and wrapping overflow,
// and a deterministic fixed-point physics step that must give the same bits everywhere.

@JvmInline
value class Fx(val raw: Int) : Comparable<Fx> {
    operator fun plus(o: Fx) = Fx(raw + o.raw)

    operator fun minus(o: Fx) = Fx(raw - o.raw)

    operator fun times(o: Fx) = Fx(((raw.toLong() * o.raw) shr FRAC).toInt())

    operator fun div(o: Fx) = Fx(((raw.toLong() shl FRAC) / o.raw).toInt())

    operator fun unaryMinus() = Fx(-raw)

    override fun compareTo(other: Fx) = raw.compareTo(other.raw)

    fun toDouble() = raw / ONE_D

    fun floor() = raw shr FRAC

    fun round() = (raw + HALF) shr FRAC

    fun sqrt(): Fx {
        if (raw <= 0) return Fx(0)
        var x = Fx(if (raw > ONE) raw shr 1 else ONE)
        repeat(20) { x = Fx((x.raw + (this / x).raw) shr 1) }
        return x
    }

    override fun toString(): String {
        val sign = if (raw < 0) "-" else ""
        val a = kotlin.math.abs(raw.toLong())
        val whole = a shr FRAC
        val frac = ((a and 0xFFFF) * 10000 + 0x8000) shr FRAC
        return if (frac >= 10000) "$sign${whole + 1}.0000" else "$sign$whole.${frac.toString().padStart(4, '0')}"
    }

    companion object {
        const val FRAC = 16
        const val ONE = 1 shl FRAC
        const val HALF = ONE / 2
        const val ONE_D = 65536.0

        fun of(i: Int) = Fx(i shl FRAC)

        fun of(d: Double) = Fx(kotlin.math.round(d * ONE_D).toInt())
    }
}

object Money {
    fun parse(s: String): Long {
        val negative = s.startsWith("-")
        val body = s.removePrefix("-")
        val whole = body.substringBefore('.').toLong()
        val cents = body.substringAfter('.', "0").padEnd(2, '0').take(2).toLong()
        val v = whole * 100 + cents
        return if (negative) -v else v
    }

    fun format(cents: Long): String {
        val sign = if (cents < 0) "-" else ""
        val a = kotlin.math.abs(cents)
        val grouped = (a / 100).toString().reversed().chunked(3).joinToString(",").reversed()
        return "$sign$$grouped.${(a % 100).toString().padStart(2, '0')}"
    }

    // value * numerator / denominator, rounded half to even
    fun scale(value: Long, numerator: Long, denominator: Long): Long {
        val product = value * numerator
        val q = product / denominator
        val r = product % denominator
        val twice = kotlin.math.abs(r) * 2
        return when {
            twice > denominator -> q + Long.sign(product)
            twice < denominator -> q
            q % 2 == 0L -> q
            else -> q + Long.sign(product)
        }
    }

    private fun Long.Companion.sign(v: Long) = if (v < 0) -1L else 1L
}

fun saturatingAdd(a: Int, b: Int): Int {
    val r = a.toLong() + b
    return r.coerceIn(Int.MIN_VALUE.toLong(), Int.MAX_VALUE.toLong()).toInt()
}

fun overflow() {
    println("-- overflow")
    println(Int.MAX_VALUE + 1)
    println(Int.MIN_VALUE - 1)
    println(Int.MAX_VALUE * 2)
    println(65536 * 65536)
    println(46341 * 46341)
    println(-Int.MIN_VALUE)
    println(Int.MIN_VALUE / -1)
    println(Int.MIN_VALUE % -1)
    println(kotlin.math.abs(Int.MIN_VALUE))
    println(saturatingAdd(Int.MAX_VALUE, 5))
    println(saturatingAdd(Int.MIN_VALUE, -5))
    println((Int.MAX_VALUE.toLong() + 1).toInt())
    println(4_000_000_000L.toInt())
    println((-1L).toInt())
    println(0x1_0000_0001L.toInt())
    println(3_000_000_000L.toShort())
    println(200.toByte())
    println((-129).toByte())
    var h = 17
    for (c in "fixed point") h = 31 * h + c.code
    println("hash $h")
    var lcg = 12345
    repeat(5) { lcg = lcg * 1103515245 + 12345 }
    println("lcg $lcg ${lcg ushr 16} ${lcg shr 16}")
    try {
        Math.addExact(Int.MAX_VALUE, 1)
    } catch (e: ArithmeticException) {
        println("addExact: ${e.message}")
    }
    try {
        Math.multiplyExact(1L shl 40, 1L shl 30)
    } catch (e: ArithmeticException) {
        println("multiplyExact: ${e.message}")
    }
}

fun q16() {
    println("-- Q16.16")
    val a = Fx.of(3.25)
    val b = Fx.of(-1.5)
    println("$a $b ${a + b} ${a - b} ${a * b} ${a / b} ${-a}")
    println("raw ${a.raw} ${b.raw} ${(a * b).raw} ${(a / b).raw}")
    println("floor ${b.floor()} round ${b.round()} ${Fx.of(2.5).round()} ${Fx.of(-2.5).round()}")
    println("sqrt ${Fx.of(2).sqrt()} ${Fx.of(100).sqrt()} ${Fx.of(0.25).sqrt()}")
    println("toDouble ${Fx.of(1.0 / 3).toDouble()} ${Fx(1).toDouble()} ${Fx(-1).toDouble()}")
    println("max ${Fx(Int.MAX_VALUE)} min ${Fx(Int.MIN_VALUE)}")
    println("wrap ${Fx.of(30000) + Fx.of(30000)} ${Fx.of(200) * Fx.of(200)}")
    val values = listOf(Fx.of(1.75), Fx.of(-0.5), Fx.of(0.0), Fx.of(12.125))
    println("sorted ${values.sorted()} max ${values.max()}")

    // a falling body in fixed point: deterministic to the bit
    var y = Fx.of(100)
    var v = Fx.of(0)
    val g = Fx.of(-9.81)
    val dt = Fx.of(1.0 / 60)
    var frames = 0
    while (y > Fx.of(0)) {
        v += g * dt
        y += v * dt
        frames++
    }
    println("landed after $frames frames at y=$y v=$v raw=${y.raw},${v.raw}")
}

fun money() {
    println("-- money")
    val prices = listOf("19.99", "0.05", "1234567.8", "-42.10", "7")
    val cents = prices.map(Money::parse)
    println(cents)
    println(cents.map(Money::format))
    val total = cents.sum()
    println("total ${Money.format(total)}")
    for (rate in listOf(825L, 1000L, 1250L)) {
        val tax = cents.sumOf { Money.scale(it, rate, 10000) }
        println("tax at ${rate / 100.0}%: ${Money.format(tax)}")
    }
    println(listOf(5L, 15L, 25L, -5L, -15L, 1L, 3L).map { Money.scale(it, 1, 10) })
    val split = Money.scale(10000, 1, 3)
    println("split \$100 three ways: ${Money.format(split)} x3 + ${Money.format(10000 - split * 3)}")
    var balance = Money.parse("1000.00")
    repeat(12) { balance += Money.scale(balance, 5, 1200) }
    println("after a year at 5%: ${Money.format(balance)}")
    val big = 92_233_720_368_547L
    println("big ${Money.format(big)} ${Money.format(-big)}")
}

fun main() {
    overflow()
    q16()
    money()
}
