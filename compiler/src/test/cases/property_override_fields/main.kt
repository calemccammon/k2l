// An overriding property with its own initializer has its own backing field, as on the JVM.
open class A {
    open val x = 1
    open var y = "a"
    fun fromA() = "A sees $x $y"
}

open class B : A() {
    override val x = 2
    override var y = "b"
    open fun both() = "${super.x} $x ${super.y} $y"
}

class C : B() {
    override var y = "c"
    override fun both() = "${super.both()} | ${super.y} $y"
}

// Overrides without their own value keep sharing the base field.
open class Plain(open val name: String)

class Named(override val name: String) : Plain("base") {
    fun show() = "${super.name} $name"
}

fun main() {
    val b = B()
    println(b.both())
    println(b.fromA())
    b.y = "changed"
    println(b.both())
    val a: A = b
    println(a.x)
    println(a.y)
    val c = C()
    println(c.both())
    c.y = "z"
    println(c.both())
    println(Named("n").show())
}
