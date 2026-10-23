package shapes

data class Point(val x: Int, val y: Int)

data class Reading(val label: String, val value: Double)

data class Entry(val name: String?, val note: String? = null)

data class Grid(val cells: IntArray, val name: String)

data class Line(val from: Point, val to: Point)

data class Empty(val id: Int) {
    var hits = 0
}

data class Named(val first: String, val last: String) {
    override fun toString() = "$first $last"
}

data class Loose(val id: Int, val tag: String) {
    override fun equals(other: Any?) = other is Loose && other.id == id

    override fun hashCode() = id
}

interface HasFirst {
    operator fun component1(): Int
}

data class Pair3(val a: Int, val b: Int, val c: Int) : HasFirst

class Outer {
    data class Inner(val v: Int)
}

@JvmInline
value class Meters(val amount: Double)

var calls = 0

fun next(label: String): Int {
    calls++
    println("arg $label")
    return calls
}

data class Counter(var n: Int, val tag: String)

fun bump(c: Counter): String {
    c.n++
    return "b"
}

fun source(): Point {
    println("source")
    return Point(1, 2)
}

sealed interface Event {
    val source: String
}

data class Deleted(override val source: String, val user: String) : Event

fun main() {
    val p = Point(1, 2)
    println(p)
    println("template: $p")
    println(p == Point(1, 2))
    println(p.hashCode() == Point(1, 2).hashCode())
    println(p.equals("Point(x=1, y=2)"))
    val any: Any = p
    println(any.toString())
    println(any == Point(1, 2))

    val nan = Reading("nan", 0.0 / 0.0)
    println(nan.value.isNaN())
    println(nan == nan.copy())
    println(Reading("zero", 0.0) == Reading("zero", -0.0))
    println(Reading("half", 0.5).hashCode() == Reading("half", 0.5).hashCode())

    println(Entry(null))
    println(Entry("a", "b") == Entry("a", "b"))
    println(Entry(null).hashCode() == Entry(null, null).hashCode())

    val cells = intArrayOf(1, 2)
    val g = Grid(cells, "g")
    println(g)
    println(g == Grid(cells, "g"))
    println(g == Grid(intArrayOf(1, 2), "g"))

    val line = Line(Point(0, 0), Point(3, 4))
    println(line)
    println(line == Line(Point(0, 0), Point(3, 4)))
    println(line.hashCode() == Line(Point(0, 0), Point(3, 4)).hashCode())

    val e = Empty(7)
    e.hits = 3
    println(e)
    println(e == Empty(7))

    println(Named("Ada", "Lovelace"))
    println(Named("Ada", "Lovelace") == Named("Ada", "Lovelace"))
    println(Loose(1, "x") == Loose(1, "y"))
    println(Loose(1, "x"))
    println(Loose(5, "x").hashCode())

    val moved = source().copy(y = next("y"))
    println(moved)
    val both = p.copy(y = next("first y"), x = next("then x"))
    println(both)
    val counter = Counter(1, "a")
    println(counter.copy(tag = bump(counter)))
    val (a, b) = both
    println(a + b)
    val (_, onlyB) = line
    println(onlyB)
    val first: HasFirst = Pair3(9, 8, 7)
    println(first.component1())
    val (c1) = first
    println(c1)
    val component = Pair3::component3
    println(component(Pair3(1, 2, 3)))

    val counts = HashMap<Point, Int>()
    counts[Point(1, 1)] = 1
    counts[Point(1, 1)] = (counts[Point(1, 1)] ?: 0) + 1
    println(counts)
    val set = hashSetOf(Point(1, 1), Point(1, 1), Point(2, 2))
    println(set.size)
    println(Point(2, 2) in set)
    println(listOf(Point(3, 3), Point(1, 1)).sortedBy { it.x })

    println(Outer.Inner(5))
    println(Meters(2.5))
    println(Meters(2.5) == Meters(2.5))

    data class Local(val n: Int)
    println(Local(1))
    println(Local(1) == Local(1))

    // a property overriding an interface's is kept under another key
    val deleted = Deleted("web", "ann")
    println(deleted)
    println(deleted == Deleted("web", "ann"))
    println(deleted == Deleted("cli", "ann"))
    println(deleted.hashCode() == Deleted("web", "ann").hashCode())
}
