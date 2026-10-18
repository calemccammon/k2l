package app

import app.model.Circle
import app.model.Color
import app.model.Op
import app.model.Outer
import app.model.Registry
import app.model.Shape
import app.model.Square
import kotlin.reflect.KClass

class Plain

data class Point(val x: Int, val y: Int)

open class Animal {
    override fun toString() = "I am a ${this::class.simpleName}"
}

class Dog : Animal()

class Cat : Animal()

fun describe(x: Any?): String = when (x) {
    null -> "null"
    else -> "${x::class.simpleName}"
}

inline fun <reified T : Any> nameOf(): String? = T::class.simpleName

inline fun <reified T : Any> qualifiedOf(): String? = T::class.qualifiedName

fun localClasses() {
    class Local
    val l = Local()
    println(l::class.simpleName)
    println(Local::class.qualifiedName)
}

val handlers: Map<KClass<*>, (Any) -> String> = mapOf(
    Plain::class to { _ -> "plain handler" },
    Point::class to { p -> "point handler for $p" },
)

fun kindOf(x: Any): String = when (x::class) {
    Dog::class -> "dog"
    Cat::class -> "cat"
    String::class -> "string"
    Int::class -> "int"
    else -> "unknown"
}

fun main() {
    // source classes
    println(Plain::class.simpleName)
    println(Plain::class.qualifiedName)
    println(Plain()::class.simpleName)
    println(Point(1, 2)::class.simpleName)
    println(Point::class.qualifiedName)
    println(Animal())
    println(Dog())
    println(Cat())
    println(describe(Dog()))
    println(describe(null))
    println(describe("hello"))
    println(describe(42))

    // equality
    val a: Animal = Dog()
    val b: Animal = Cat()
    println(a::class == Dog::class)
    println(a::class == Animal::class)
    println(a::class != b::class)
    println(a::class == b::class)
    println(Dog()::class == Dog()::class)

    // packages, nesting, objects, companions, enums
    println(Circle(1.0)::class.simpleName)
    println(Circle::class.qualifiedName)
    println(Square(2.0)::class.qualifiedName)
    println(Registry::class.simpleName)
    println(Registry::class.qualifiedName)
    println(Outer.Nested::class.simpleName)
    println(Outer.Nested::class.qualifiedName)
    println(Outer.Companion::class.simpleName)
    println(Outer.Companion::class.qualifiedName)
    println(Outer().Inner()::class.qualifiedName)
    println(Color.RED::class.simpleName)
    println(Color::class.qualifiedName)
    println(Color.GREEN::class == Color::class)
    println(Color.GREEN::class.simpleName)
    println(Color.GREEN::class.qualifiedName)
    println(Color.GREEN.javaClass.name)
    println(Color.RED.javaClass.name)
    println(Color.GREEN::class.isInstance(Color.RED))
    println(Color::class.isInstance(Color.GREEN))
    println(Op.PLUS::class == Op::class)
    println(Op.valueOf("MINUS")::class.simpleName)
    println(Op.PLUS.javaClass.simpleName)
    println(Outer.Nested().javaClass.name)
    println(Shape::class.simpleName)
    println(Shape::class.qualifiedName)
    localClasses()

    // reified type parameters
    println(nameOf<Plain>())
    println(nameOf<Point>())
    println(nameOf<String>())
    println(nameOf<Int>())
    println(qualifiedOf<Circle>())
    println(qualifiedOf<Double>())

    // javaClass
    println(Plain().javaClass.simpleName)
    println(Point(0, 0).javaClass.simpleName)
    println(Dog().javaClass.name)
    println(Circle(1.0).javaClass.name)

    // library values
    println("text"::class.simpleName)
    println(1::class.simpleName)
    println(1L::class.simpleName)
    println(1.5::class.simpleName)
    println(true::class.simpleName)
    println('c'::class.simpleName)
    println("text"::class.qualifiedName)
    println(1::class.qualifiedName)
    println(mutableListOf(1)::class.simpleName)
    println(ArrayList<Int>()::class.simpleName)
    println(mutableMapOf(1 to 2)::class.simpleName)
    println(mutableSetOf(1)::class.simpleName)
    println(HashMap<Int, Int>()::class.simpleName)
    println((1 to 2)::class.simpleName)
    println(Exception("x")::class.simpleName)
    println(IllegalStateException("x")::class.qualifiedName)
    println(RuntimeException("x").javaClass.simpleName)
    println(StringBuilder()::class.simpleName)
    println(String::class == "x"::class)
    println(Int::class == 1::class)
    println(Int::class == 1L::class)

    // KClass as a value
    println(handlers[Plain::class]?.invoke(Plain()))
    println(handlers[Point::class]?.invoke(Point(1, 2)))
    println(handlers[Dog::class])
    println(kindOf(Dog()))
    println(kindOf(Cat()))
    println(kindOf("s"))
    println(kindOf(3))
    println(kindOf(3.5))
    val classes: List<KClass<*>> = listOf(Dog::class, Cat::class, Dog::class)
    println(classes.map { it.simpleName })
    println(classes.distinct().size)
    println(classes.toSet().size)
    println(Dog::class in classes)
    val k: KClass<out Animal> = Dog()::class
    println(k.simpleName)
    println(k == Dog::class)

    // isInstance
    println(Animal::class.isInstance(Dog()))
    println(Dog::class.isInstance(Cat()))
    println(Dog::class.isInstance(Dog()))
    println(String::class.isInstance("s"))
    println(String::class.isInstance(1))
    println(Int::class.isInstance(1))
    println(Shape::class.isInstance(Square(1.0)))
    println(Any::class.isInstance(Plain()))
}
