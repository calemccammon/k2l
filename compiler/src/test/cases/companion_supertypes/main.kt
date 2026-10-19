// Companion objects that implement interfaces or extend classes are values of those types (`Foo.Companion` in Lua).
package app

import app.model.Factory
import app.model.Token

interface Named {
    val label: String
}

abstract class Registry(val prefix: String) {
    private val items = mutableListOf<String>()

    fun register(s: String) {
        items += prefix + s
    }

    open fun describe() = "Registry$items"

    abstract fun size(): Int
}

class Foo(val n: Int) {
    companion object : Factory<Foo>, Named {
        var count = 0
        override fun create(): Foo = Foo(++count)
        override val label = "foo"
        const val MAX = 10

        fun reset() {
            count = 0
        }
    }

    // the companion is the implicit receiver
    fun next() = create()

    override fun toString() = "Foo($n)"
}

// a named companion extending a class, initialized on first use (its init block prints)
class Bar {
    companion object Maker : Registry("bar:") {
        init {
            println("Bar companion init")
        }

        override fun size() = 2

        override fun describe() = "Maker " + super.describe()
    }
}

// constructing the class initializes its companion too
class Baz {
    init {
        println("Baz instance")
    }

    companion object : Named {
        init {
            println("Baz companion init")
        }

        override val label get() = "baz"
    }
}

sealed class Shape {
    companion object : Factory<Shape> {
        override fun create(): Shape = Circle

        override val kind get() = "shapes"
    }
}

object Circle : Shape() {
    override fun toString() = "Circle"
}

interface Codec {
    fun encode(s: String): String

    companion object : Codec {
        override fun encode(s: String) = s.reversed()
    }
}

class Upper : Codec {
    override fun encode(s: String) = s.uppercase()
}

open class Labeled(override val label: String) : Named

class Tagged {
    // an open class with a constructor argument, through another class
    companion object : Labeled("tagged")
}

class Outer {
    class Inner(val tag: String) {
        companion object : Factory<Inner> {
            override fun create() = Inner("inner")
        }

        override fun toString() = "Inner($tag)"
    }
}

class Box<T>(val value: T) {
    companion object : Factory<Box<Int>> {
        override fun create() = Box(42)
    }

    override fun toString() = "Box($value)"
}

fun <T> make(f: Factory<T>) = f.create()

fun encodeAll(codecs: List<Codec>, s: String) = codecs.map { it.encode(s) }

fun main() {
    val f: Factory<Foo> = Foo
    println(f.create())
    println(make(Foo))
    println(Foo.twice())
    println(Foo is Factory<*>)
    val a: Any = Foo
    println(a is Named)
    println((a as Named).label)
    println(a as? Registry)
    println(Foo.MAX + Foo.count)
    println(Foo(0).next())
    Foo.reset()
    println(Foo.Companion.create())
    println(f === Foo.Companion)
    println(f.kind)

    println("before Bar")
    Bar.register("x")
    val r: Registry = Bar
    r.register("y")
    println(r.describe() + " " + r.size() + " " + Bar.prefix)
    println(Bar.Maker === r)

    println("before Baz")
    Baz()
    val n: Named = Baz
    println(n.label)

    val shapes = listOf<Factory<*>>(Foo, Shape, Outer.Inner, Box)
    for (s in shapes) println("${s.kind} ${s.create()}")
    when (val x: Any = Shape) {
        is Factory<*> -> println("factory ${x.create()}")
        else -> println("other")
    }

    println(encodeAll(listOf(Codec, Upper(), Codec.Companion), "abc"))
    println(Tagged.label + " " + (Tagged is Labeled))
    println(listOf<Named>(Foo, Tagged, Baz).map { it.label })
    println(Token.parse("id") + " " + make(Token).text)
    println(Foo.Companion::class.simpleName + " " + Bar.Maker::class.simpleName)
}
