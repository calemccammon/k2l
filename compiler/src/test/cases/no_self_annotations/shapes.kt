@file:NoSelfInFile

package shapes

import dev.k2l.lua.NoSelfInFile

interface Shape {
    fun area(): Int

    fun describe() = "${name()} of area ${area()}"

    fun name(): String
}

abstract class Base(private val kind: String) : Shape {
    override fun name() = kind

    open fun scaled(k: Int) = area() * k
}

class Square(val side: Int) : Base("square") {
    override fun area() = side * side
}

class Rect(val w: Int, val h: Int) : Base("rect") {
    override fun area() = w * h

    override fun scaled(k: Int) = super.scaled(k) + 1

    override fun describe() = "wide " + super.describe()
}

// Implements Shape as an object.
object Unit1 : Shape {
    override fun area() = 1

    override fun name() = "unit"
}

// Its toString, equals and hashCode keep self: the runtime calls them with `:`.
class Money(val cents: Int) {
    fun plus(other: Money) = Money(cents + other.cents)

    override fun toString() = "$" + (cents / 100) + "." + (cents % 100)

    override fun equals(other: Any?) = other is Money && other.cents == cents

    override fun hashCode() = cents

    companion object {
        val ZERO = Money(0)

        fun of(dollars: Int) = Money(dollars * 100)
    }
}
