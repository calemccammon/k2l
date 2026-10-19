// `is Comparable` is exact for classes of the program: objects, enums, implementations through interfaces and subclasses
// are Comparable; a class that only declares an operator compareTo is not.
object Version : Comparable<Version> {
    override fun compareTo(other: Version) = 0
}

enum class Level { LOW, HIGH }

interface Ranked : Comparable<Ranked> {
    val rank: Int
    override fun compareTo(other: Ranked) = rank.compareTo(other.rank)
}

open class Card(override val rank: Int) : Ranked

class Ace : Card(14)

object Joker : Card(99)

class Money(val cents: Int) {
    operator fun compareTo(other: Money) = cents.compareTo(other.cents)
}

data class Point(val x: Int) : Comparable<Point> {
    override fun compareTo(other: Point) = x - other.x

    companion object {
        fun origin() = Point(0)
    }
}

fun describe(x: Any?) = if (x is Comparable<*>) "comparable" else "not comparable"

fun main() {
    val values = listOf<Any?>(Version, Level.HIGH, Card(3), Ace(), Joker, Money(5), Point(1), 1, "s", 2.5, true, null, listOf(1))
    values.forEach { println("${it?.let { v -> v::class.simpleName }}: ${describe(it)}") }
    println(values.filterIsInstance<Comparable<*>>().size)
    println(Money(1) < Money(2))
    val companions = listOf<Any>(Point, Point.origin())
    println(companions.map { describe(it) })
    println(listOf<Ranked>(Ace(), Card(2), Joker).sorted().map { it.rank })
}
