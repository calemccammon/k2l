package app.model

interface Shape

open class Circle(val r: Double) : Shape

class Square(val side: Double) : Shape

object Registry

class Outer {
    class Nested

    inner class Inner

    companion object
}

enum class Color {
    RED,
    GREEN {
        override fun toString() = "green"
    },
}

enum class Op(val symbol: String) {
    PLUS("+"),
    MINUS("-"),
}
