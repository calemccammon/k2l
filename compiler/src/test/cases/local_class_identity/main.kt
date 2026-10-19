package app

// Objects made by one object expression (or local class) in different runs of its declaration share one class.

interface Shape {
    fun area(): Double
}

fun square(side: Double): Shape = object : Shape {
    override fun area() = side * side
}

fun circle(r: Double): Shape = object : Shape {
    override fun area() = 3.0 * r * r
}

fun makeLocal(n: Int): Any {
    open class Base(val n: Int)
    class Derived(n: Int) : Base(n)
    return if (n % 2 == 0) Base(n) else Derived(n)
}

fun main() {
    val squares = (1..3).map { square(it.toDouble()) }
    val c = circle(1.0)
    println(squares.map { it.javaClass }.distinct().size)
    println(squares[0]::class == squares[2]::class)
    println(squares[0].javaClass == c.javaClass)
    println(squares[1].javaClass.name + " " + c.javaClass.name)
    println(squares[2]::class.isInstance(squares[0]))
    println(squares[2]::class.isInstance(c))
    val byClass = (squares + c).groupBy { it::class }
    println(byClass.values.joinToString { group -> "%.1f".format(group.sumOf { it.area() }) })
    val counters = List(3) {
        object {
            var hits = it
        }
    }
    println(counters.map { it.javaClass }.toSet().size)
    val locals = (1..4).map(::makeLocal)
    println(locals.map { it.javaClass.name })
    println(locals[0]::class == locals[2]::class)
    println(locals[1]::class.isInstance(locals[3]))
    println(locals[0]::class.isInstance(locals[1]))
    println(locals[1]::class.isInstance(locals[0]))
}
