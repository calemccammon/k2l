// Classes of the program implementing ClosedRange: contains/isEmpty come from the interface (also next to Iterable),
// and start/endInclusive read through the interface type reach the class's properties as well as the library ranges'.

data class Day(val n: Int) : Comparable<Day> {
    override fun compareTo(other: Day) = n.compareTo(other.n)
    operator fun rangeTo(other: Day) = Week(this, other)
}

class Span(override val start: Double, override val endInclusive: Double) : ClosedRange<Double> {
    override fun toString() = "Span($start, $endInclusive)"
}

// Iterates every other day, but contains() is ClosedRange's: any day between the bounds
class Week(override val start: Day, override val endInclusive: Day) : ClosedRange<Day>, Iterable<Day> {
    override fun iterator() = generateSequence(start) { Day(it.n + 2) }.takeWhile { it <= endInclusive }.iterator()
}

class Grades(lo: Char, hi: Char) : ClosedRange<Char> {
    override val start = lo
    override val endInclusive = hi
    override fun contains(value: Char) = value.uppercaseChar() in start..endInclusive
}

fun <T : Comparable<T>> describe(r: ClosedRange<T>) = "${r.start}..${r.endInclusive} empty=${r.isEmpty()}"

fun main() {
    val span = Span(1.5, 4.25)
    println("${2.0 in span} ${4.5 in span} ${span.isEmpty()} ${Span(3.0, 1.0).isEmpty()}")
    val week = Day(1)..Day(6)
    println("${week.map { it.n }} ${Day(2) in week} ${Day(7) in week} ${week.isEmpty()}")
    val grades = Grades('A', 'C')
    println("${'b' in grades} ${'d' in grades} ${grades.isEmpty()}")
    println(describe(span))
    println(describe(week))
    println(describe(grades))
    println(describe(0.5..2.5))
    println(describe(3..1))
    println(describe("a".."f"))
    val ranges: List<ClosedRange<Double>> = listOf(span, 0.25..1.5)
    println(ranges.map { it.endInclusive - it.start })
}
