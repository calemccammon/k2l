// Enum entries compare by ordinal (operators, compareTo, sorting, max/min, coerceIn, sorted collections); `in a..b` over
// Comparable objects calls compareTo; a companion of an enum reaches entries/values()/valueOf without qualification.

enum class Level { LOW, MEDIUM, HIGH, CRITICAL }

enum class Shape(val corners: Int) {
    CIRCLE(0),
    TRIANGLE(3) {
        override fun toString() = "tri"
    },
    SQUARE(4);

    companion object {
        fun byCorners(n: Int): Shape? = entries.firstOrNull { it.corners == n }
        fun all(): List<Shape> = values().toList()
        fun named(s: String): Shape = valueOf(s.uppercase())
    }
}

data class Task(val name: String, val level: Level, val shape: Shape)

data class Version(val major: Int, val minor: Int) : Comparable<Version> {
    override fun compareTo(other: Version) = compareValuesBy(this, other, { it.major }, { it.minor })
}

fun <T : Comparable<T>> largest(xs: List<T>): T = xs.reduce { a, b -> if (a >= b) a else b }

fun main() {
    println("${Level.LOW < Level.HIGH} ${Level.CRITICAL <= Level.MEDIUM} ${Level.HIGH.compareTo(Level.LOW)} ${Level.LOW.compareTo(Level.LOW)}")
    println(listOf(Level.HIGH, Level.LOW, Level.CRITICAL, Level.MEDIUM).sorted())
    println(listOf(Level.HIGH, Level.LOW).sortedDescending())
    println("${listOf(Level.MEDIUM, Level.CRITICAL, Level.LOW).max()} ${maxOf(Level.LOW, Level.HIGH)} ${minOf(Shape.SQUARE, Shape.TRIANGLE)}")
    println(largest(listOf(Shape.TRIANGLE, Shape.SQUARE, Shape.CIRCLE)))
    val tasks = listOf(
        Task("b", Level.HIGH, Shape.SQUARE),
        Task("a", Level.LOW, Shape.TRIANGLE),
        Task("c", Level.HIGH, Shape.CIRCLE),
        Task("d", Level.MEDIUM, Shape.TRIANGLE),
    )
    println(tasks.sortedBy { it.level }.map { it.name })
    println(tasks.sortedWith(compareByDescending<Task> { it.level }.thenBy { it.shape }).map { it.name })
    println(tasks.sortedWith(compareBy({ it.shape }, { it.name })).map { it.name })
    println(tasks.maxBy { it.shape }.name + " " + tasks.minOf { it.level })
    val c: Comparable<Level> = Level.MEDIUM
    println("${c > Level.LOW} ${c.compareTo(Level.CRITICAL)}")
    println(listOf(Shape.SQUARE, Shape.TRIANGLE, Shape.CIRCLE).toSortedSet())
    println(sortedMapOf(Level.HIGH to 1, Level.LOW to 2))
    println(mapOf(Level.HIGH to 1, Level.LOW to 2).entries.sortedBy { it.key })
    println(Level.MEDIUM.coerceIn(Level.HIGH, Level.HIGH))

    for (level in Level.entries) {
        val band = when (level) {
            in Level.LOW..Level.MEDIUM -> "routine"
            in Level.HIGH..Level.CRITICAL -> "urgent"
            else -> "?"
        }
        println("$level $band ${level in Level.MEDIUM..Level.HIGH} ${level !in Level.LOW..Level.LOW}")
    }
    val v = Version(1, 4)
    println("${v in Version(1, 0)..Version(2, 0)} ${v in Version(1, 5)..Version(2, 0)} ${Version(2, 0) in Version(1, 0)..Version(2, 0)}")
    println("${"b" in "a".."c"} ${"d" in "a".."c"} ${2.5 in 1.0..3.0}")

    println("${Shape.byCorners(3)} ${Shape.byCorners(5)} ${Shape.all()} ${Shape.named("square")}")
    println(runCatching { Shape.named("hexagon") }.exceptionOrNull())
}
