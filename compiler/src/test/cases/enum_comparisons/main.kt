
// Enums are Comparable by ordinal: operators, compareTo, sorting, max/min and sorted collections.

enum class E { A, B, C }

enum class Level {
    LOW {
        override fun label() = "low"
    },
    HIGH {
        override fun label() = "high"
    },
    ;

    abstract fun label(): String
}

data class Task(val name: String, val level: Level)

fun main() {
    println(E.A < E.B)
    println(E.C.compareTo(E.A))
    println(listOf(E.C, E.A, E.B).sorted())
    println(listOf(E.C, E.A, E.B).max())
    println(mapOf(E.C to 1, E.A to 2).entries.sortedBy { it.key })
    val c: Comparable<E> = E.B
    println(c.compareTo(E.A))
    println(maxOf(E.A, E.C))
    println(E.B.coerceIn(E.C, E.C))
    println(listOf(E.B, E.C, E.A, E.B).toSortedSet())
    println(listOf(Level.HIGH, Level.LOW).sorted().map { it.label() })
    println(Level.HIGH > Level.LOW)
    val tasks = listOf(Task("x", Level.HIGH), Task("y", Level.LOW), Task("z", Level.HIGH))
    println(tasks.sortedWith(compareByDescending<Task> { it.level }.thenBy { it.name }))
    println(tasks.maxBy { it.level }.name)
    companions()
}

enum class Size(val letter: Char) {
    SMALL('s'), LARGE('l');

    companion object {
        // `entries`, `values()` and `valueOf` through the companion's implicit receiver
        fun parse(c: Char) = entries.firstOrNull { it.letter == c }
        fun count() = values().size
        fun named(n: String) = valueOf(n.uppercase())
    }
}

fun companions() {
    println("${Size.parse('l')} ${Size.parse('x')} ${Size.count()} ${Size.named("small")}")
}
