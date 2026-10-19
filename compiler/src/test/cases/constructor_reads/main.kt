// A base constructor that reads an open property sees the subclass's field before it is initialized.
open class Base {
    open val size: Int = 1
    open val label: String = "base"
    open val enabled: Boolean = true
    open val ratio: Double = 0.5
    open val note: String? = "n"

    init {
        println("Base sees size=$size label=$label enabled=$enabled ratio=$ratio note=$note")
        report()
    }

    fun report() {
        println("report: size=${size + 1}")
    }
}

class Child : Base() {
    override val size: Int = 10
    override val label: String = "child"
    override val enabled: Boolean = false
    override val ratio: Double = 2.5
    override val note: String? = "c"

    init {
        println("Child sees size=$size label=$label enabled=$enabled ratio=$ratio note=$note")
    }
}

class GrandChild : Base() {
    override val size: Int = 20
}

// Constructor parameters that override: the parameter is stored after the super constructor ran
open class Shape(open val sides: Int) {
    val description = "shape with $sides sides"
}

class Triangle(override val sides: Int) : Shape(3)

// Overrides with custom getters keep calling the getter
open class Counter {
    open val start: Int = 1
    val first = start
}

class Offset : Counter() {
    override val start: Int get() = 100
}

// A property read only after construction keeps one shared field
open class Calm {
    open val v: Int = 1
    fun show() = "v=$v"
}

class Calmer : Calm() {
    override val v: Int = 2
}

fun main() {
    val c = Child()
    println("after: ${c.size} ${c.label} ${c.enabled} ${c.ratio} ${c.note}")
    val g = GrandChild()
    println("after: ${g.size}")
    println(Triangle(5).description)
    println(Triangle(5).sides)
    println(Offset().first)
    println(Calmer().show())
}
