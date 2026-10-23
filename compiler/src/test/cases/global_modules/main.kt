package app

import core.*
import model.*
import screens.*

class Circle(val r: Double) : Shape("circle"), Named {
    override fun area() = 3.0 * r * r

    override val label get() = "circle $r"
}

fun main() {
    println(width(5))
    println(width(1000))
    println(shrink(9))
    println(formatHp(10))
    bump()
    bump()
    println(counter)
    counter = 10
    println(bump())
    println(greeting)
    volume = 50
    println(volume)
    println(computed)
    println(sizes)
    println(7.doubled)
    println(describe())
    Registry.add(Square(2.0))
    Registry.add(Circle(1.0))
    println(Registry.count())
    println(Announcer.announce("hi"))
    println(Color.GREEN.ordinal)
    println(Point(1, 2))
    Counter.make()
    println(Counter.made)
    println(Circle(2.0).label)
}
