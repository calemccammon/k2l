package app

import app.model.Color
import app.model.Point
import app.model.Registry
import app.model.Shape
import app.model.Square
import app.parity.isEven
import app.util.GREETING
import app.util.calls
import app.util.counted
import app.util.shout
import app.util.twice

class Circle(val r: Double) : Shape("circle") {
    override fun area() = 3.0 * r * r
}

fun main() {
    println(shout(GREETING))
    counted()
    counted()
    println(calls)
    val shapes = listOf(Square(2.0), Circle(1.0))
    for (s in shapes) println("${s.name}: ${s.area()} ${s.describe()}")
    Registry.add(Square(3.0))
    println(Registry.count())
    println(Color.GREEN.ordinal)
    val p = Point(1, 2)
    println(p.copy(y = 5))
    println(5.twice())
    println(isEven(10))
    println(isEven(7))
}
