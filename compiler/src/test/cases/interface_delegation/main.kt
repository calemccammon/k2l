// `class C(impl: I) : I by impl`: members of I that C does not declare are forwarded to the delegate, default methods and
// properties included; toString/equals/hashCode are not (unless I declares them).
interface Named {
    val name: String
    var nickname: String

    fun greet(other: String): String

    fun shout() = greet("everyone").uppercase()

    fun describe(): String = "Named($name)"
}

class Person(override val name: String) : Named {
    override var nickname = name.take(2)

    override fun greet(other: String) = "$name greets $other"

    override fun describe() = "Person $name"

    override fun toString() = "Person($name)"
}

class Polite(impl: Named) : Named by impl {
    // overrides win over the delegate
    override fun greet(other: String) = "Dear $other, from $name"
}

interface Stack<T> {
    val size: Int

    fun push(x: T)

    fun pop(): T

    fun peek(): T = pop().also { push(it) }
}

class ListStack<T> : Stack<T> {
    private val items = mutableListOf<T>()
    override val size get() = items.size

    override fun push(x: T) {
        items.add(x)
    }

    override fun pop() = items.removeAt(items.lastIndex)
}

interface Counter {
    fun count(): Int
}

class Ticker : Counter {
    private var n = 0

    override fun count() = ++n
}

fun makeStack(): Stack<String> {
    println("makeStack")
    return ListStack()
}

// several interfaces, generic ones, delegates made by arbitrary expressions (evaluated once, at construction)
class Logged(val label: String) : Stack<String> by makeStack(), Counter by Ticker() {
    init {
        println("init $label")
    }

    override fun push(x: String) {
        println("$label push $x (${count()})")
    }
}

// the delegate is a property, and the class still has its own state
class Wrapper(val inner: Named) : Named by inner {
    var calls = 0

    override fun describe(): String {
        calls++
        return "Wrapper[${inner.describe()}]"
    }
}

interface Shape {
    val area: Double

    override fun toString(): String
}

class Square(val side: Double) : Shape {
    override val area get() = side * side

    override fun toString() = "Square($side)"
}

// toString is declared in Shape, so it is delegated
class Framed(s: Shape) : Shape by s

interface Base {
    fun id(): String
}

interface Derived : Base {
    fun full() = "derived " + id()
}

class Impl : Derived {
    override fun id() = "impl"
}

// members of superinterfaces are delegated too
class Via(d: Derived) : Derived by d

class IntStack : Stack<Int> by ListStack()

object Defaults : Counter {
    override fun count() = 42
}

fun makeTicker(): Counter {
    println("makeTicker")
    return Ticker()
}

// an object whose delegate is made on first use
object Shared : Counter by makeTicker()

data class Point(val x: Int, val y: Int)

interface Located {
    val point: Point
}

class Here : Located {
    override val point = Point(1, 2)
}

// a data class compares its own properties, not the delegate's
data class Pin(val tag: String, val at: Located) : Located by at

class Holder {
    companion object : Counter by Defaults
}

fun main() {
    val p = Person("Alice")
    val polite = Polite(p)
    println(polite.greet("Bob"))
    println(polite.shout())
    println(polite.describe())
    println(polite.name + " " + polite.nickname)
    polite.nickname = "Al"
    println(p.nickname + " " + polite.nickname)
    println(polite is Named)
    println(polite.toString() == p.toString())
    println(polite == Polite(p))
    println(polite.equals(polite))

    val logged = Logged("log")
    logged.push("a")
    logged.push("b")
    println("${logged.size} ${logged.count()} ${logged.count()}")
    val s: Stack<String> = Logged("second")
    println(s.size)
    val delegated = IntStack()
    delegated.push(1)
    delegated.push(2)
    println("${delegated.peek()} ${delegated.pop()} ${delegated.size}")

    val w = Wrapper(p)
    println(w.describe() + " " + w.calls + " " + w.greet("Carol"))

    val framed = Framed(Square(2.0))
    println("$framed ${framed.area}")

    val via = Via(Impl())
    println(via.full() + " " + via.id() + " " + (via is Base))

    println(Holder.count() + (Holder as Counter).count())
    println("before Shared")
    println(Shared.count() + Shared.count())
    val here = Here()
    println(Pin("a", here).point)
    println("${Pin("a", here) == Pin("a", here)} ${Pin("a", here) == Pin("a", Here())}")
}
