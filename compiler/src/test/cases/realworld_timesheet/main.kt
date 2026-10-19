import java.util.TreeMap

// Timesheets and payroll: a civil Date with day arithmetic and its own range/iterator,
// time-of-day parsing, overtime rules, tax brackets via TreeMap.floorEntry and a payslip.

data class Date(val year: Int, val month: Int, val day: Int) : Comparable<Date> {
    init {
        require(month in 1..12) { "bad month $month" }
        require(day in 1..daysIn(year, month)) { "bad day $year-$month-$day" }
    }

    // days since 1970-01-01 (Howard Hinnant's algorithm)
    val epochDay: Int
        get() {
            val y = if (month <= 2) year - 1 else year
            val era = (if (y >= 0) y else y - 399) / 400
            val yoe = y - era * 400
            val doy = (153 * (month + (if (month > 2) -3 else 9)) + 2) / 5 + day - 1
            val doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
            return era * 146097 + doe - 719468
        }

    val dayOfWeek: Weekday get() = Weekday.entries[(epochDay + 3).mod(7)]

    operator fun plus(days: Int) = ofEpochDay(epochDay + days)
    operator fun minus(other: Date) = epochDay - other.epochDay
    operator fun rangeTo(other: Date) = DateRange(this, other)
    override fun compareTo(other: Date) = epochDay.compareTo(other.epochDay)
    override fun toString() = "%04d-%02d-%02d".format(year, month, day)

    companion object {
        fun isLeap(y: Int) = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)
        fun daysIn(y: Int, m: Int) = when (m) {
            2 -> if (isLeap(y)) 29 else 28
            4, 6, 9, 11 -> 30
            else -> 31
        }

        fun ofEpochDay(n: Int): Date {
            val z = n + 719468
            val era = (if (z >= 0) z else z - 146096) / 146097
            val doe = z - era * 146097
            val yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
            val doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
            val mp = (5 * doy + 2) / 153
            val d = doy - (153 * mp + 2) / 5 + 1
            val m = if (mp < 10) mp + 3 else mp - 9
            return Date(yoe + era * 400 + if (m <= 2) 1 else 0, m, d)
        }

        fun parse(s: String): Date = s.split('-').map(String::toInt).let { (y, m, d) -> Date(y, m, d) }
    }
}

class DateRange(override val start: Date, override val endInclusive: Date) : ClosedRange<Date>, Iterable<Date> {
    override fun iterator(): Iterator<Date> = object : Iterator<Date> {
        private var next = start
        override fun hasNext() = next <= endInclusive
        override fun next(): Date {
            if (!hasNext()) throw NoSuchElementException()
            return next.also { next += 1 }
        }
    }
}

enum class Weekday(val short: String) {
    MONDAY("Mon"), TUESDAY("Tue"), WEDNESDAY("Wed"), THURSDAY("Thu"), FRIDAY("Fri"), SATURDAY("Sat"), SUNDAY("Sun");

    val isWeekend get() = this == SATURDAY || this == SUNDAY
}

@JvmInline
value class Minutes(val total: Int) : Comparable<Minutes> {
    operator fun plus(o: Minutes) = Minutes(total + o.total)
    operator fun minus(o: Minutes) = Minutes(total - o.total)
    override fun compareTo(other: Minutes) = total.compareTo(other.total)
    val hours: Double get() = total / 60.0
    override fun toString() = "${total / 60}h%02d".format(total % 60)

    companion object {
        val ZERO = Minutes(0)
        fun parseClock(s: String): Minutes {
            val (h, m) = s.split(':').map { it.toInt() }
            require(h in 0..24 && m in 0..59) { "bad time $s" }
            return Minutes(h * 60 + m)
        }
    }
}

data class Shift(val date: Date, val start: Minutes, val end: Minutes, val breakMinutes: Int = 0) {
    val worked: Minutes get() = (end - start) - Minutes(breakMinutes)
}

fun parseShifts(text: String): List<Shift> = text.trimIndent().lines().filterNot { it.isBlank() || it.startsWith("#") }.map { line ->
    val parts = line.trim().split(Regex("\\s+"))
    val (from, to) = parts[1].split('-').map(Minutes::parseClock)
    val br = parts.getOrNull(2)?.removeSuffix("m")?.toInt() ?: 0
    Shift(Date.parse(parts[0]), from, to, br)
}

object Payroll {
    const val HOURLY_CENTS = 2850
    private val brackets = TreeMap(mapOf(0 to 0.10, 1_000_00 to 0.15, 2_500_00 to 0.25, 6_000_00 to 0.32))

    fun pay(shifts: List<Shift>): Map<String, Long> {
        var regular = 0L
        var overtime = 0L
        var weekend = 0L
        shifts.groupBy { (it.date.epochDay + 3) / 7 }.values.forEach { week ->
            var weekMinutes = 0
            for (s in week.sortedBy { it.date }) {
                val m = s.worked.total
                when {
                    s.date.dayOfWeek.isWeekend -> weekend += m
                    weekMinutes + m > 40 * 60 -> {
                        val reg = maxOf(0, 40 * 60 - weekMinutes)
                        regular += reg
                        overtime += m - reg
                    }
                    else -> regular += m
                }
                weekMinutes += m
            }
        }
        val gross = (regular * HOURLY_CENTS + overtime * HOURLY_CENTS * 3 / 2 + weekend * HOURLY_CENTS * 2) / 60
        return linkedMapOf("regularMin" to regular, "overtimeMin" to overtime, "weekendMin" to weekend, "gross" to gross, "tax" to tax(gross))
    }

    fun tax(cents: Long): Long {
        var remaining = cents
        var tax = 0.0
        while (remaining > 0) {
            val (floor, rate) = brackets.floorEntry(remaining.toInt())
            tax += (remaining - floor) * rate
            remaining = floor.toLong() - 1
        }
        return Math.round(tax)
    }
}

fun cents(c: Long) = "%d.%02d".format(c / 100, c % 100)

val SHIFTS = """
    # date       time         break
    2024-02-26  09:00-17:30  30m
    2024-02-27  08:30-18:00  45m
    2024-02-28  09:00-17:00
    2024-02-29  07:00-19:30  60m
    2024-03-01  09:00-16:00  30m
    2024-03-02  10:00-14:00
    2024-03-04  09:00-17:00  30m
    2024-03-05  09:15-12:45
"""

fun main() {
    val leap = Date(2024, 2, 29)
    println("$leap is a ${leap.dayOfWeek}, epoch day ${leap.epochDay}, +1 = ${leap + 1}, +366 = ${leap + 366}")
    println("1970-01-01 is ${Date(1970, 1, 1).dayOfWeek}; 2000-01-01 is ${Date(2000, 1, 1).dayOfWeek}; 1969-12-31 is ${Date.ofEpochDay(-1)}")
    println("days between: ${Date(2024, 12, 25) - Date(2024, 1, 1)} ${Date.parse("2023-03-01") - Date.parse("2023-02-01")}")
    println("leap years 1896..1912: ${(1896..1912).filter(Date::isLeap)}")
    println(runCatching { Date(2023, 2, 29) }.exceptionOrNull()?.message)
    println(runCatching { Date.parse("2024-13-01") }.exceptionOrNull()?.message)
    val week = Date(2024, 3, 1)..Date(2024, 3, 7)
    println("week: ${week.map { "${it.dayOfWeek.short} ${it.day}" }}")
    println("weekend days in March 2024: ${(Date(2024, 3, 1)..Date(2024, 3, 31)).count { it.dayOfWeek.isWeekend }}")
    println("contains: ${Date(2024, 3, 4) in week} ${Date(2024, 3, 8) in week} empty: ${week.start > week.endInclusive}")
    val roundTrip = (-1000..1000 step 37).all { Date.ofEpochDay(it).epochDay == it }
    println("round trip ok: $roundTrip, first Mondays: ${(1..6).map { m -> (Date(2024, m, 1)..Date(2024, m, 7)).first { it.dayOfWeek == Weekday.MONDAY }.day }}")

    val shifts = parseShifts(SHIFTS)
    println("${shifts.size} shifts")
    for (s in shifts) println("  ${s.date} ${s.date.dayOfWeek.short} ${s.start}-${s.end} worked ${s.worked} (${"%.2f".format(s.worked.hours)}h)")
    val total = shifts.map { it.worked }.fold(Minutes.ZERO, Minutes::plus)
    println("total ${total}, longest ${shifts.maxBy { it.worked }.date}, shortest ${shifts.minOf { it.worked }}")
    val byWeekday = shifts.groupBy({ it.date.dayOfWeek }, { it.worked.total }).toSortedMap().mapValues { Minutes(it.value.sum()) }
    println("by weekday: $byWeekday")
    val pay = Payroll.pay(shifts)
    println("pay: ${pay.mapValues { (k, v) -> if (k.endsWith("Min")) Minutes(v.toInt()).toString() else cents(v) }}")
    println("net: ${cents(pay.getValue("gross") - pay.getValue("tax"))}")
    for (g in listOf(50_00L, 1_000_00L, 3_000_00L, 10_000_00L)) println("  tax on ${cents(g).padStart(9)}: ${cents(Payroll.tax(g)).padStart(8)}")
    println(runCatching { Minutes.parseClock("25:00") }.exceptionOrNull())
    println("rate ${Payroll.HOURLY_CENTS} cents/h, sorted durations ${shifts.map { it.worked }.sorted().take(3)}")
}
