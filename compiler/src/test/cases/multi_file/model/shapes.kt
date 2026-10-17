package app.model

open class Shape(val name: String) {
    open fun area() = 0.0
    fun describe() = "<$name>"
}

class Square(val side: Double) : Shape("square") {
    override fun area() = side * side
}

object Registry {
    private val shapes = mutableListOf<Shape>()
    fun add(s: Shape) {
        shapes.add(s)
    }

    fun count() = shapes.size
}

enum class Color { RED, GREEN }

data class Point(val x: Int, val y: Int)
