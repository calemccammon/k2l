package model

interface Named {
    val label: String
}

open class Shape(val name: String) {
    open fun area() = 0.0
}

class Square(val side: Double) : Shape("square") {
    override fun area() = side * side
}

object Registry {
    private val items = mutableListOf<Shape>()

    fun add(s: Shape) {
        items.add(s)
    }

    fun count() = items.size
}

object Announcer {
    init {
        println("Announcer ready")
    }

    fun announce(what: String) = "** $what **"
}

enum class Color { RED, GREEN }

data class Point(val x: Int, val y: Int)

class Counter {
    companion object {
        var made = 0

        fun make(): Counter {
            made++
            return Counter()
        }
    }
}
