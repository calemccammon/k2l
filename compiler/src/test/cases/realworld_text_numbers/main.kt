import kotlin.math.abs
import kotlin.math.roundToInt
import kotlin.math.roundToLong

// Number formatting and parsing utilities as a reporting library would have them: human-readable sizes and
// durations, ordinals, grouping by hand, fixed and significant-digit rounding, percent bars, parsing user input
// with units, currency in cents, and Double/Float/Long toString round trips.

fun humanBytes(n: Long, si: Boolean = false): String {
    val unit = if (si) 1000 else 1024
    if (abs(n) < unit) return "$n B"
    val units = if (si) "kMGTPE" else "KMGTPE"
    var value = n.toDouble()
    var i = -1
    while (abs(value) >= unit && i < units.length - 1) {
        value /= unit
        i++
    }
    return "%.1f %s%sB".format(value, units[i], if (si) "" else "i")
}

fun duration(totalSeconds: Long): String {
    if (totalSeconds == 0L) return "0s"
    val parts = mutableListOf<String>()
    var rest = totalSeconds
    for ((name, size) in listOf("d" to 86_400L, "h" to 3_600L, "m" to 60L, "s" to 1L)) {
        val q = rest / size
        if (q > 0) parts += "$q$name"
        rest %= size
    }
    return parts.joinToString(" ")
}

fun ordinal(n: Int): String {
    val suffix = if (n % 100 in 11..13) "th" else when (n % 10) { 1 -> "st"; 2 -> "nd"; 3 -> "rd"; else -> "th" }
    return "$n$suffix"
}

fun group(n: Long, sep: Char = ','): String {
    val digits = abs(n).toString()
    val grouped = digits.reversed().chunked(3).joinToString(sep.toString()).reversed()
    return if (n < 0) "-$grouped" else grouped
}

fun roundTo(x: Double, places: Int): Double {
    val f = Math.pow(10.0, places.toDouble())
    return Math.round(x * f) / f
}

fun significant(x: Double, digits: Int): String = "%.${digits}g".format(x)

fun bar(fraction: Double, width: Int = 20): String {
    val filled = (fraction.coerceIn(0.0, 1.0) * width).roundToInt()
    return "[" + "#".repeat(filled) + ".".repeat(width - filled) + "] " + "%5.1f%%".format(fraction * 100)
}

class ParseError(msg: String) : Exception(msg)

fun parseSize(input: String): Long {
    // a number with an optional fraction: Lua patterns have no optional groups, so "1." is rejected after the match
    val m = Regex("""^\s*([+-]?\d+\.?\d*)\s*([kmgt]?)(i?)b?\s*$""", RegexOption.IGNORE_CASE).matchEntire(input)
        ?.takeUnless { it.groupValues[1].endsWith('.') }
        ?: throw ParseError("cannot parse size '$input'")
    val (num, prefix, binary) = m.destructured
    val base = if (binary.isNotEmpty()) 1024.0 else 1000.0
    val exp = "kmgt".indexOf(prefix.lowercase()) + 1
    return (num.toDouble() * Math.pow(base, exp.toDouble())).roundToLong()
}

fun parseDuration(input: String): Long {
    // the unit is checked after the match: Lua patterns have no alternation
    val re = Regex("(\\d+)\\s*([a-z]+)\\b")
    val units = setOf("d", "h", "m", "s", "ms")
    val matches = re.findAll(input.lowercase()).toList()
    if (matches.isEmpty() || matches.any { it.groupValues[2] !in units } || re.replace(input.lowercase(), "").isNotBlank()) throw ParseError("cannot parse duration '$input'")
    return matches.sumOf { m ->
        val n = m.groupValues[1].toLong()
        when (m.groupValues[2]) { "d" -> n * 86_400_000; "h" -> n * 3_600_000; "m" -> n * 60_000; "s" -> n * 1000; else -> n }
    }
}

data class Money(val cents: Long) {
    operator fun plus(o: Money) = Money(cents + o.cents)
    operator fun times(q: Int) = Money(cents * q)
    fun percent(p: Double) = Money((cents * p / 100).roundToLong())
    override fun toString(): String {
        val sign = if (cents < 0) "-" else ""
        return "$sign$" + group(abs(cents) / 100) + "." + (abs(cents) % 100).toString().padStart(2, '0')
    }

    companion object {
        fun parse(s: String): Money {
            val clean = s.trim().removePrefix("$").replace(",", "")
            val (whole, frac) = if ('.' in clean) clean.substringBefore('.') to clean.substringAfter('.').padEnd(2, '0').take(2) else clean to "00"
            val neg = whole.startsWith("-")
            val c = whole.removePrefix("-").toLong() * 100 + frac.toLong()
            return Money(if (neg) -c else c)
        }
    }
}

fun main() {
    for (n in listOf(0L, 999L, 1023L, 1024L, 1536L, 1_000_000L, 1_048_576L, 123_456_789L, 9_876_543_210L, 1L shl 50, -2048L)) {
        println("%14s  %-10s %-10s".format(group(n), humanBytes(n), humanBytes(n, si = true)))
    }
    println(listOf(0L, 59L, 61L, 3_600L, 86_399L, 90_061L, 1_000_000L).joinToString(" | ") { duration(it) })
    println((1..25).map(::ordinal).joinToString(" ") + " " + listOf(101, 111, 112, 213, 1000, 1001).map(::ordinal))
    println(listOf(3.14159, 2.675, -1.005, 0.0001234, 123456.789).joinToString { "${roundTo(it, 2)}/${roundTo(it, 0)}" })
    println(listOf(3.14159, 2.675, 0.0001234, 123456.789, 9.99999).map { significant(it, 3) })
    for (f in listOf(0.0, 0.05, 0.333, 0.5, 0.875, 1.0, 1.2)) println(bar(f))

    for (s in listOf("512", "1.5k", "10 MB", "2GiB", "0.5 TiB", " 7 kib ", "12 parsecs", "-3k")) {
        try {
            println("$s -> ${parseSize(s)} (${humanBytes(parseSize(s))})")
        } catch (e: ParseError) {
            println(e.message)
        }
    }
    for (s in listOf("1h 30m", "2d4h", "45s 500ms", "90m", "soon", "3 h")) {
        try {
            val ms = parseDuration(s)
            println("$s -> ${ms}ms = ${duration(ms / 1000)}")
        } catch (e: ParseError) {
            println(e.message)
        }
    }

    val cart = listOf("$1,299.99" to 1, "4.5" to 3, "$0.99" to 12, "-5" to 1)
    var total = Money(0)
    for ((price, qty) in cart) {
        val line = Money.parse(price) * qty
        total += line
        println("%-12s x%-3d %12s".format(price, qty, line))
    }
    println("subtotal ${total}, tax ${total.percent(8.875)}, total ${total + total.percent(8.875)}")

    val doubles = listOf(0.1 + 0.2, 1.0 / 3, 2.0 / 3, 100.0, 1e7, 1.0e-3, 9.999e-4, 123456789.0, 1e21, 1e-7, Double.MAX_VALUE, Double.MIN_VALUE, -0.0, 4.35 * 100)
    // (Longs beyond 2^53 are inexact where Lua numbers are doubles)
    for (d in doubles) println("$d ${d.toString().toDouble() == d} ${d.toFloat()} ${if (abs(d) < 1e15) d.roundToLong() else "big"} ${"%.3e".format(d)}")
    val floats = listOf(0.1f, 1f / 3, 16777217f, 3.4028235e38f, 1.0e-10f, 100f, 0.5f + 0.25f)
    println(floats.joinToString { "$it" } + " | " + floats.map { it.toDouble() }.joinToString { "%.10f".format(it) })
    println(listOf("1e3", "0x1p3", "0x1.8P-1", "-0X10p0d", "1_000", "+.5", "-.5e-1", "Infinity", "1.7976931348623157E309", "4.9e-325")
        .joinToString { it.toDoubleOrNull().toString() })
    println(listOf("9007199254740991", "-9007199254740991", "9223372036854775808", "0777", "-0", "12L").map { it.toLongOrNull() })
    println("${12.5.roundToInt()} ${13.5.roundToInt()} ${(-12.5).roundToInt()} ${Math.round(-2.5)} ${Math.rint(2.5)} ${Math.rint(3.5)} ${(2.5).toInt()} ${(-2.5).toLong()}")
    println("${Int.MAX_VALUE.toString(2).length} ${(-255).toString(16)} ${255.toString(2).padStart(16, '0')} ${"11111111".toInt(2)} ${"zz".toLong(36)} ${"-7f".toInt(16)}")
}
