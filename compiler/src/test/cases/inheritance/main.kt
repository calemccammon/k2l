interface Shape {
    val name: String
    fun area(): Double
    fun describe(): String = "$name with area ${area()}"
}

interface Named {
    fun label(): String = "named"
}

abstract class Polygon(override val name: String, val sides: Int) : Shape, Named {
    open fun perimeterHint(): String = "$sides sides"
    override fun label(): String = "polygon " + super.label()
}

open class Rect(val w: Double, val h: Double) : Polygon("rect", 4) {
    override fun area() = w * h
    override fun perimeterHint(): String = "rectangle with " + super.perimeterHint()
}

class Square(side: Double) : Rect(side, side) {
    override fun describe(): String = "square! " + super.describe()
}

class Circle(val r: Double) : Shape {
    override val name = "circle"
    override fun area() = 3.0 * r * r
}

open class Animal(val sound: String) {
    open fun speak() = "The animal says $sound"
}

class Dog : Animal {
    constructor() : super("woof")
    override fun speak() = super.speak() + "!"
}

fun kind(s: Shape): String = when (s) {
    is Square -> "square"
    is Rect -> "rect ${s.w}x${s.h}"
    is Circle -> "circle r=${s.r}"
    else -> "unknown"
}

fun main() {
    val shapes = arrayOfShapes()
    println(shapes.describe())
    val r = Rect(2.0, 3.0)
    println(r.describe())
    println(r.perimeterHint())
    println(r.label())
    val sq = Square(2.0)
    println(sq.describe())
    println(Circle(1.0).describe())
    println(kind(sq))
    println(kind(r))
    println(kind(Circle(2.0)))
    println(sq is Polygon)
    println(sq is Named)
    val shape: Shape = Circle(1.0)
    println(shape is Polygon)
    val asRect = shape as? Rect
    println(asRect == null)
    println(Dog().speak())
}

fun arrayOfShapes(): Shape = Rect(1.0, 1.0)
