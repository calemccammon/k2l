package draw.text

// Same file name, same class name, same top-level names as draw.geometry, in another package.

class Point(val line: Int, val column: Int) : Comparable<Point> {
    override fun compareTo(other: Point) = compareValuesBy(this, other, { it.line }, { it.column })

    override fun toString() = "$line:$column"
}

var count = 100

fun format(p: Point): String {
    count++
    return "text@$p"
}

fun Point.describe(): String = "line $line, column $column"

object Registry {
    val names = mutableListOf<String>()

    fun register(name: String): Int {
        names += "text:$name"
        count += 10
        return names.size
    }
}
