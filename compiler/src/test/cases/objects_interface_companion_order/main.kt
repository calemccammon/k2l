// An interface's companion is initialized on first access, not when a class or interface declared after it in the file
// extends the interface: its initializer can construct those later classes.

interface Shape {
    fun area(): Int

    companion object {
        init {
            println("Shape companion initialized")
        }

        val unit: Square = Square(1)
        val all: List<Shape> = listOf(unit, Circle(2))
    }
}

interface Polygon : Shape {
    val sides: Int
}

interface Regular : Polygon, Comparable<Regular> {
    override fun compareTo(other: Regular): Int = area().compareTo(other.area())
}

class Square(val side: Int) : Regular {
    override val sides = 4

    override fun area() = side * side
}

class Circle(val radius: Int) : Shape {
    override fun area() = 3 * radius * radius
}

fun main() {
    println("start")
    val square = Square(3)
    println(square.area())
    println(square is Shape)
    println(square.sides)
    println(square > Square(2))
    println(Shape.unit.area())
    println(Shape.all.map { it.area() })
}
