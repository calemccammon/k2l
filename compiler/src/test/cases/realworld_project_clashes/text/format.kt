package draw.text

// A file named like a function it declares, and a factory function named like a class of its package.

fun format(text: String, width: Int): String = text.padEnd(width, '.') + "|"

fun Point(spec: String): Point {
    val (l, c) = spec.split(':').map { it.toInt() }
    return Point(l, c)
}

val type = "text-format"

fun print(msg: String) {
    kotlin.io.println("text.print: $msg")
}

fun select(points: List<Point>, line: Int): List<Point> = points.filter { it.line == line }
