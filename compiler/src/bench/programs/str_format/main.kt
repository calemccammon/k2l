// Adapted from realworld_timesheet and realworld_text_numbers: invoices and timesheets formatted with String.format
// (widths, precision, flags, %s/%d/%f/%x/%e), "%.2f".format, toString(radix) and number parsing.

const val SIZE = 12_000 // invoice lines

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

data class Entry(val project: String, val person: String, val minutes: Int, val rate: Double)

fun hash(s: String): Int {
    var h = 0
    for (c in s) h = (h * 31 + c.code) % 1_000_003
    return h
}

fun duration(minutes: Int) = String.format("%d:%02d", minutes / 60, minutes % 60)

fun main() {
    val rng = Lcg(77)
    val projects = listOf("apollo", "gemini", "mercury", "vostok", "soyuz")
    val people = listOf("ada", "grace", "linus", "barbara", "ken", "dennis")
    val entries = List(SIZE) { Entry(projects[rng.next(5)], people[rng.next(6)], 15 + rng.next(480), 40.0 + rng.next(8000) / 100.0) }
    var checksum = 0L
    var chars = 0L
    for ((i, e) in entries.withIndex()) {
        val amount = e.minutes / 60.0 * e.rate
        val line = String.format("%-8s %-8s %6s %8.2f %10.2f %5.1f%%", e.project, e.person, duration(e.minutes), e.rate, amount, e.minutes / 4.8)
        val code = String.format("#%06d-%04x-%s", i, e.minutes * 37, e.person.uppercase())
        val sci = "%.3e".format(amount * 1000) + " " + "%+d".format(e.minutes - 240) + " " + "%,d".format(e.minutes * 12345)
        chars += line.length + code.length + sci.length
        checksum = (checksum * 3 + hash(line) + hash(code) + hash(sci)) % 1_000_000_007
    }
    println("formatted $chars chars, checksum $checksum")

    val totals = entries.groupBy { it.project }.toSortedMap().map { (project, list) ->
        val minutes = list.sumOf { it.minutes }
        val money = list.sumOf { it.minutes / 60.0 * it.rate }
        String.format("%-10s %8s %12.2f", project, duration(minutes), money)
    }
    totals.forEach(::println)

    var parsed = 0L
    for (i in 0 until SIZE) {
        val n = rng.next(65536)
        val hex = n.toString(16)
        val bin = n.toString(2)
        val dec = "%.4f".format(n / 7.0)
        parsed += hex.toInt(16) + bin.length + dec.toDouble().toLong() + Integer.toHexString(n).length + "$n".padStart(6, '0').length
    }
    println("parsed $parsed")
}
