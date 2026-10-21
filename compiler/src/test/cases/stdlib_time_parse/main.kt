import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.seconds

// Duration.parse, parseOrNull, parseIsoString and parseIsoStringOrNull: the default format, ISO-8601 and their errors
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

data class Timeout(val name: String, val value: Duration)

fun main() {
    t("default") { listOf("1h 30m", "45s", "1.5s", "250ms", "2d 3h", "1d 2h 3m 4.005s", "0s", "12us", "7ns").map { Duration.parse(it) } }
    t("signs") { listOf("-5m", "+5m", "-(1h 30m)", "-1.25h").map { Duration.parse(it) } }
    t("infinity") { listOf("Infinity", "-Infinity", "INFINITY").map { Duration.parse(it) } }
    t("iso via parse") { listOf("PT1H30M", "P2DT3H", "PT0.5S", "-PT5M", "PT-5M", "P1D").map { Duration.parse(it) } }
    t("parseIsoString") { listOf("PT36H", "PT1.123456789S", "PT90M", "P1DT1S", "PT0S").map { Duration.parseIsoString(it) } }
    t("round trips") { listOf(90.minutes, 1.5.seconds, 26.hours + 3.milliseconds).all { Duration.parse(it.toString()) == it && Duration.parseIsoString(it.toIsoString()) == it } }
    t("bad default") { Duration.parse("1x") }
    t("bad order") { Duration.parse("1m 1h") }
    t("bad empty") { Duration.parse("") }
    t("bad fraction") { Duration.parse("1.5h 30m") }
    t("bad iso") { Duration.parseIsoString("1h") }
    t("bad iso unit") { Duration.parseIsoString("P1Y") }
    t("parseOrNull") { listOf(Duration.parseOrNull("10s"), Duration.parseOrNull("ten seconds"), Duration.parseOrNull("1h1m")) }
    t("parseIsoStringOrNull") { listOf(Duration.parseIsoStringOrNull("PT2M"), Duration.parseIsoStringOrNull("2m")) }

    // a small config reader
    val config = "connect=5s\nread=1m 30s\nidle=PT10M\nretry=oops"
    val timeouts = config.lines().map { line ->
        val (name, value) = line.split("=")
        Timeout(name, Duration.parseOrNull(value) ?: Duration.ZERO)
    }
    t("config") { timeouts }
    t("longest") { timeouts.maxBy { it.value }.name }
    t("total") { timeouts.fold(Duration.ZERO) { acc, x -> acc + x.value } }
}
