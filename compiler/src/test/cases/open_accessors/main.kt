interface Shape {
    val area: Double
    val name: String get() = "shape"
}

open class Rect(val w: Double, val h: Double) : Shape {
    override val area get() = w * h
    open val label: String = "rect"
    open var count = 0
        set(value) {
            field = value
            println("set $value")
        }

    fun describe() = "$name $label $area $count"
}

class Square(s: Double) : Rect(s, s) {
    override val name get() = "square"
    override val label: String get() = "sq " + super.label
}

abstract class Base {
    abstract val id: Int
    val desc get() = "id=$id"
}

class Impl(override val id: Int) : Base()

class Fixed : Base() {
    override val id get() = 7
}

// both levels have a backing field
open class Counter {
    open var n: Int = 1
        get() = field * 10
}

class Doubler : Counter() {
    override var n: Int = 5
        set(value) {
            field = value * 2
        }

    fun both() = "${super.n} $n"
}

// no custom accessors anywhere: plain fields
open class Plain(open val a: Int) {
    open var b = 1
}

class PlainSub(a: Int) : Plain(a) {
    override val a = 5
}

fun main() {
    val shapes: List<Shape> = listOf(Rect(2.0, 3.0), Square(4.0))
    for (s in shapes) println("${s.name} ${s.area}")
    val r: Rect = Square(2.0)
    println(r.label)
    println(r.describe())
    r.count = 3
    r.count++
    r.count += 10
    println(r.count)
    val q = Rect(1.0, 1.0)
    q.count += 2
    println(q.describe())

    val bases: List<Base> = listOf(Impl(3), Fixed())
    for (b in bases) println("${b.id} ${b.desc}")

    val c: Counter = Doubler()
    println(c.n)
    c.n = 4
    println(c.n)
    println(Doubler().both())
    println(Counter().n)

    val p: Plain = PlainSub(2)
    p.b += 4
    println("${p.a} ${p.b}")
}
