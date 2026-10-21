import kotlin.time.Duration
import kotlin.time.Duration.Companion.days
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.microseconds
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.nanoseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit
import kotlin.time.times
import kotlin.time.toDuration

// kotlin.time.Duration: construction, arithmetic, comparison, conversion and formatting
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

data class Lap(val name: String, val time: Duration)

fun main() {
    // construction from Int, Long and Double
    t("units") { listOf(1.nanoseconds, 2.microseconds, 3.milliseconds, 4.seconds, 5.minutes, 6.hours, 7.days) }
    t("long") { listOf(10_000_000_000L.nanoseconds, 90L.seconds, 36L.hours) }
    t("double") { listOf(1.5.seconds, 0.25.milliseconds, 2.75.hours, 0.000001.seconds, 1.234567.seconds) }
    t("toDuration") { listOf(3.toDuration(DurationUnit.MINUTES), 2L.toDuration(DurationUnit.DAYS), 0.5.toDuration(DurationUnit.SECONDS)) }
    t("constants") { listOf(Duration.ZERO, Duration.INFINITE, -Duration.INFINITE) }

    // toString: mixed components, sub-second units, negatives
    t("mixed") { listOf(90.minutes, 1.days + 1.seconds, 25.hours + 30.seconds, 61.seconds + 500.milliseconds) }
    t("small") { listOf(1500.microseconds, 1001.nanoseconds, 999.nanoseconds, 1.milliseconds + 1.nanoseconds) }
    t("negative") { listOf(-5.seconds, -(90.minutes), -(1.5.seconds)) }
    t("fractions") { listOf(1.1.seconds, 1.01.seconds, 1.001.seconds, 1.0001.seconds, 2.5.milliseconds) }

    // arithmetic
    val a = 2.minutes
    val b = 45.seconds
    t("plus/minus") { listOf(a + b, a - b, b - a) }
    t("times") { listOf(a * 3, b * 1.5, 2 * b, 0.5 * a) }
    t("div") { listOf(a / 4, a / 2.5, a / b, b / a) }
    t("abs") { listOf((b - a).absoluteValue, a.absoluteValue) }
    t("infinite sum") { Duration.INFINITE + 5.days }
    t("infinite minus infinite") { Duration.INFINITE - Duration.INFINITE }
    t("zero by zero") { Duration.ZERO / 0 }

    // comparison and equality
    t("compare") { listOf(a > b, a < b, a == 120.seconds, a != b, a.compareTo(b), b.compareTo(b)) }
    t("sorted") { listOf(3.seconds, 1.minutes, 500.milliseconds, 2.seconds).sorted() }
    t("maxOf") { maxOf(1.seconds, 2.seconds) }
    t("set") { setOf(1.seconds, 1000.milliseconds, 2.seconds).size }
    t("hash") { listOf(1.seconds.hashCode(), 0.seconds.hashCode(), (-3).milliseconds.hashCode()) }
    t("predicates") { listOf(b.isPositive(), (-b).isNegative(), Duration.ZERO.isPositive(), Duration.INFINITE.isInfinite(), a.isFinite()) }

    // conversions
    val d = 1.days + 2.hours + 3.minutes + 4.seconds + 5.milliseconds
    t("inWhole") { listOf(d.inWholeDays, d.inWholeHours, d.inWholeMinutes, d.inWholeSeconds, d.inWholeMilliseconds) }
    t("inWholeSmall") { listOf(1.5.seconds.inWholeMicroseconds, 1.5.seconds.inWholeNanoseconds, (-1.5).seconds.inWholeSeconds) }
    t("toLong/toInt") { listOf(d.toLong(DurationUnit.HOURS), d.toInt(DurationUnit.MINUTES), Duration.INFINITE.toInt(DurationUnit.SECONDS)) }
    t("toDouble") { listOf(90.seconds.toDouble(DurationUnit.MINUTES), 1500.milliseconds.toDouble(DurationUnit.SECONDS)) }
    t("components") {
        d.toComponents { days, hours, minutes, seconds, nanoseconds -> "$days $hours $minutes $seconds $nanoseconds" }
    }
    t("components4") { 26.hours.toComponents { hours, minutes, seconds, nanoseconds -> listOf(hours, minutes, seconds, nanoseconds) } }
    t("components2") { 2.5.seconds.toComponents { seconds, nanoseconds -> seconds * 10 + nanoseconds / 100_000_000 } }
    t("unitString") { listOf(d.toString(DurationUnit.HOURS, 2), 1500.milliseconds.toString(DurationUnit.SECONDS), 2.5.seconds.toString(DurationUnit.SECONDS)) }
    t("iso") { listOf(d.toIsoString(), 0.seconds.toIsoString(), (-90).minutes.toIsoString(), 1.5.seconds.toIsoString()) }

    // DurationUnit
    t("unit") { listOf(DurationUnit.SECONDS, DurationUnit.SECONDS.name, DurationUnit.HOURS.ordinal) }
    t("unit order") { DurationUnit.MINUTES > DurationUnit.SECONDS }
    t("unit entries") { DurationUnit.entries.joinToString() }
    t("unit valueOf") { DurationUnit.valueOf("DAYS") }

    // durations in data classes, string templates and accumulation
    val laps = listOf(Lap("a", 61.seconds), Lap("b", 59.5.seconds), Lap("c", 1.minutes + 2.seconds))
    t("laps") { laps.sortedBy { it.time } }
    var total = Duration.ZERO
    for (lap in laps) total += lap.time
    t("total") { "total: $total, average: ${total / laps.size}" }
    t("sumOf") { laps.map { it.time }.fold(Duration.ZERO) { acc, x -> acc + x } }
    t("when") {
        when {
            total > 3.minutes -> "slow"
            total > 2.minutes -> "ok"
            else -> "fast"
        }
    }
}
