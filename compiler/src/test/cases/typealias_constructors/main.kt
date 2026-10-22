// Constructor calls through a typealias of a class of the program (kotlinx.collections.immutable's
// `typealias IntWrapper = ObjectWrapper<Int>`, constructed as `IntWrapper(1, 0)`).
class Wrapper<K : Comparable<K>>(val obj: K, val hash: Int) {
    constructor(obj: K) : this(obj, -1)

    override fun toString() = "Wrapper($obj, $hash)"
}

typealias IntWrapper = Wrapper<Int>
typealias Boxed<T> = Wrapper<T>
typealias IntBox = Boxed<Int>

open class Base(val label: String)

typealias BaseAlias = Base

class Derived : BaseAlias("derived")

class Outer {
    inner class Inner(val n: Int)
}

typealias InnerAlias = Outer.Inner

fun main() {
    println(IntWrapper(1, 0))
    println(IntWrapper(2))
    println(Boxed("s", 3))
    println(IntBox(4, 5))
    println(BaseAlias("base").label)
    println(Derived().label)
    val make: (Int, Int) -> IntWrapper = ::IntWrapper
    println(make(6, 7))
    println(listOf(1, 2).map(::IntWrapper))
    println(Outer().InnerAlias(8).n)
}
