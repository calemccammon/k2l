import kotlin.time.Clock
import kotlin.time.Duration
import kotlin.time.Duration.Companion.days
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.nanoseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.Instant
import kotlin.time.isDistantFuture
import kotlin.time.isDistantPast

// kotlin.time.Instant and Clock: construction, arithmetic, comparison, ISO-8601 formatting and parsing
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

class FixedClock(private val at: Instant) : Clock {
    override fun now(): Instant = at
}

data class Event(val name: String, val at: Instant)

fun describe(i: Instant) = "${i.epochSeconds}s+${i.nanosecondsOfSecond}ns"

fun main() {
    // construction
    val epoch = Instant.fromEpochSeconds(0)
    t("epoch") { epoch }
    t("seconds") { listOf(Instant.fromEpochSeconds(1_700_000_000), Instant.fromEpochSeconds(86_399), Instant.fromEpochSeconds(-1)) }
    t("with nanos") {
        listOf(Instant.fromEpochSeconds(10, 500_000_000), Instant.fromEpochSeconds(10, 1_500_000_000L), Instant.fromEpochSeconds(10, -1))
    }
    t("millis") {
        listOf(Instant.fromEpochMilliseconds(1_234), Instant.fromEpochMilliseconds(-1), Instant.fromEpochMilliseconds(1_700_000_000_123))
    }
    t("parts") { listOf(describe(Instant.fromEpochMilliseconds(-1)), describe(Instant.fromEpochSeconds(5, 1))) }
    t("toEpochMilliseconds") {
        listOf(Instant.fromEpochSeconds(3, 999_999_999).toEpochMilliseconds(), Instant.fromEpochSeconds(-3, 1).toEpochMilliseconds())
    }

    // toString: fractions in groups of three digits, years before 1000 and after 9999
    t("fractions") {
        listOf(1, 10, 100, 1_000, 1_000_000, 123_456_789, 120_000_000).map { Instant.fromEpochSeconds(0, it).toString() }
    }
    t("leap day") { Instant.fromEpochSeconds(951_782_400) }
    t("old") {
        listOf(Instant.fromEpochSeconds(-62_135_596_800), Instant.fromEpochSeconds(-62_135_596_801), Instant.fromEpochSeconds(-70_000_000_000))
    }
    t("far") { listOf(Instant.fromEpochSeconds(253_402_300_800), Instant.fromEpochSeconds(4_000_000_000_000)) }
    t("distant") { listOf(Instant.DISTANT_PAST, Instant.DISTANT_FUTURE) }
    t("distant parts") { listOf(describe(Instant.DISTANT_PAST), describe(Instant.DISTANT_FUTURE)) }
    t("is distant") {
        listOf(Instant.DISTANT_PAST.isDistantPast, Instant.DISTANT_FUTURE.isDistantFuture, epoch.isDistantPast, epoch.isDistantFuture)
    }

    // arithmetic with Durations
    val start = Instant.fromEpochSeconds(1_000, 750_000_000)
    t("plus") { listOf(start + 1.seconds, start + 300.milliseconds, start + 2.days, start + 1.nanoseconds) }
    t("minus") { listOf(start - 1.seconds, start - 800.milliseconds, start - 1_000.seconds - 750.milliseconds) }
    t("difference") { listOf(start - epoch, epoch - start, (start + 90.hours) - start) }
    t("plus zero") { start + Duration.ZERO == start }
    t("plus infinite") { listOf((start + Duration.INFINITE).isDistantFuture, (start - Duration.INFINITE).isDistantPast) }

    // comparison and equality
    val later = start + 1.nanoseconds
    t("compare") { listOf((start < later), (start > later), (start <= start), start.compareTo(later), later.compareTo(start)) }
    t("equals") { listOf(start == Instant.fromEpochMilliseconds(1_000_750), start == later, start.equals("x")) }
    t("hashCode") { listOf(epoch.hashCode(), start.hashCode(), Instant.fromEpochSeconds(-5, 7).hashCode()) }
    t("sorted") { listOf(later, epoch, start).sorted() }
    t("max") { maxOf(start, later) }
    t("data") { Event("launch", start) }
    t("set") { setOf(start, Instant.fromEpochMilliseconds(1_000_750), later).size }

    // parsing
    t("parse") { Instant.parse("2023-11-14T22:13:20Z") }
    t("parse epoch") { Instant.parse("1970-01-01T00:00:00Z").epochSeconds }
    t("parse fraction") { listOf(Instant.parse("2020-02-29T12:34:56.5Z"), Instant.parse("2020-02-29T12:34:56.123456789z")) }
    t("parse offset") {
        listOf(
            Instant.parse("2020-01-01T00:00:00+01:00"),
            Instant.parse("2020-01-01T00:00:00-05:30"),
            Instant.parse("2020-01-01t00:00:00+02"),
        )
    }
    t("parse years") {
        listOf(Instant.parse("+12345-01-01T00:00:00Z"), Instant.parse("-0001-12-31T23:59:59Z"), Instant.parse("0000-01-01T00:00:00Z"))
    }
    t("round trip") { Instant.parse(start.toString()) == start }
    t("parse bad month") { Instant.parse("2020-13-01T00:00:00Z") }
    t("parse bad day") { Instant.parse("2021-02-29T00:00:00Z") }
    t("parse bad hour") { Instant.parse("2021-02-28T24:00:00Z") }
    t("parse no offset") { Instant.parse("2020-01-01T00:00:00") }
    t("parse short") { Instant.parse("2020-01-01") }
    t("parse no seconds") { Instant.parse("2020-01-01T00:00Z") }
    t("parse bad separator") { Instant.parse("2020-01-01 00:00:00Z") }
    t("parse year digits") { Instant.parse("20201-01-01T00:00:00Z") }
    t("parse empty") { Instant.parse("") }
    t("parseOrNull") { listOf(Instant.parseOrNull("2020-01-01T00:00:00Z"), Instant.parseOrNull("nope")) }

    // clocks
    val now = Clock.System.now()
    t("now after 2020") { now > Instant.parse("2020-01-01T00:00:00Z") }
    t("now before 2200") { now < Instant.parse("2200-01-01T00:00:00Z") }
    t("now nanos in range") { now.nanosecondsOfSecond in 0..999_999_999 }
    val clock: Clock = FixedClock(start)
    t("fixed clock") { clock.now() }
    val system: Clock = Clock.System
    t("system clock") { system.now() >= now }
}
