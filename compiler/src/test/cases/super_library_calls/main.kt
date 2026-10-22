// Any.toString() is "Name@hash", whose hash may differ from run to run, so only its shape is printed.
fun shape(s: String): String {
    val at = s.indexOf('@')
    val hex = s.substring(at + 1)
    var isHex = hex.isNotEmpty()
    for (c in hex) {
        if (!(c in '0'..'9' || c in 'a'..'f')) isHex = false
    }
    return s.substring(0, at) + "@" + (if (isHex) "<hex>" else hex)
}

open class Plain {
    override fun toString(): String = "Plain:" + shape(super.toString())
}

class Derived : Plain() {
    override fun toString(): String = "Derived>" + super.toString()
}

class Identity(val id: Int) {
    override fun equals(other: Any?): Boolean = super.equals(other)

    override fun hashCode(): Int = super.hashCode()
}

class Mixed(val id: Int) {
    // equal when the same object, or when the ids match
    override fun equals(other: Any?): Boolean = super.equals(other) || (other is Mixed && other.id == id)

    override fun hashCode(): Int = id
}

class Hashed(val id: Int) {
    override fun hashCode(): Int = super.hashCode()

    // toString() of Any prints the hash code, whatever hashCode() is
    override fun toString(): String = shape(super.toString())
}

class MyException(val code: Int) : Exception("boom") {
    override fun toString(): String = "MyException[" + super.toString() + "] message=" + super.message + " cause=" + super.cause
}

class Wrapping(cause: Throwable) : RuntimeException("wrapped", cause) {
    fun describe(): String = "${super.message} <- ${super.cause?.message}"
}

open class Base(message: String) : IllegalStateException(message)

class Leaf : Base("leaf") {
    override fun toString(): String = "Leaf!" + super.toString()
}

enum class Color {
    RED,
    GREEN {
        override fun toString(): String = "green(" + super.toString() + ")"
    },
    ;

    fun plain(): String = super.toString()
}

object Singleton {
    override fun toString(): String = "Singleton:" + shape(super.toString())
}

fun main() {
    println(Plain())
    println(Derived())

    val a = Identity(1)
    val b = Identity(1)
    println(a == a)
    println(a == b)
    println(a.equals(b))
    println(a.hashCode() == a.hashCode())
    println(a.hashCode() == b.hashCode())
    val set = mutableSetOf(a, a, b)
    println(set.size)
    val map = mutableMapOf(a to "a", b to "b")
    println(map[a])
    println(map[Identity(1)])

    val m1 = Mixed(5)
    val m2 = Mixed(5)
    val m3 = Mixed(6)
    println(m1 == m1)
    println(m1 == m2)
    println(m1 == m3)
    println(setOf(m1, m2, m3).size)

    val h = Hashed(1)
    println(h)
    println(h.hashCode() == h.hashCode())

    val e = MyException(7)
    println(e)
    println(e.message)
    println(e.code)
    try {
        throw MyException(1)
    } catch (ex: MyException) {
        println("caught $ex")
    }

    val w = Wrapping(IllegalArgumentException("inner"))
    println(w.describe())
    println(w)

    println(Leaf())
    println(Leaf().message)

    println(Color.RED.plain())
    println(Color.GREEN)
    println(Color.GREEN.plain())
    println(Singleton)
}
