// `vararg` parameters of primary and secondary constructors (classes, subclasses, enums, inner classes).

open class Polygon(val name: String, vararg val points: Pair<Int, Int>) {
    constructor(vararg coords: Int) : this("poly", *coords.toList().chunked(2).map { it[0] to it[1] }.toTypedArray())

    val size get() = points.size
    override fun toString() = "$name${points.toList()}"
}

class Triangle(a: Pair<Int, Int>, b: Pair<Int, Int>, c: Pair<Int, Int>) : Polygon("tri", a, b, c)

class Path(vararg steps: String) : Polygon("path") {
    val steps = steps.joinToString(">")
}

enum class Chord(vararg val notes: String) {
    C("c", "e", "g"),
    D7("d", "f#", "a", "c"),
    REST,
}

class Outer(val tag: String) {
    inner class Tagged(vararg val items: Int) {
        override fun toString() = "$tag${items.toList()}"
    }
}

class Bag<T>(vararg initial: T) {
    private val items = initial.toMutableList()
    fun add(vararg more: T) = apply { items += more }
    override fun toString() = items.toString()
}

fun main() {
    println(Polygon("square", 0 to 0, 1 to 0, 1 to 1, 0 to 1))
    println(Polygon(1, 2, 3, 4))
    println(Polygon("empty").size)
    println(Triangle(0 to 0, 2 to 0, 1 to 1).size)
    val path = Path("a", "b", "c")
    println("${path.steps} ${path.size}")
    println(Chord.entries.map { "${it.name}:${it.notes.size}:${it.notes.joinToString("")}" })
    println(Outer("#").Tagged(1, 2, 3))
    val arr = arrayOf("x", "y")
    println(Bag(*arr).add("z", *arr))
    println(Bag<Int>().add())
}
