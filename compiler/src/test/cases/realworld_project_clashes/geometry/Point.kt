package draw.geometry

// A file named after the class it declares, with top-level functions next to it.

data class Point(val x: Double, val y: Double) {
    operator fun plus(o: Point) = Point(x + o.x, y + o.y)

    override fun toString() = "($x, $y)"
}

var count = 0

fun format(p: Point): String {
    count++
    return "geo${p}"
}

fun Point.describe(): String = "point at x=$x y=$y"

fun origin() = Point(0.0, 0.0)

object Registry {
    val names = mutableListOf<String>()

    fun register(name: String): Int {
        names += "geo:$name"
        count++
        return names.size
    }
}
