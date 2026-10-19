// `::member` without a receiver inside a class or object is bound to `this`; `var (a, b)` locals can be reassigned.

open class Filter(private val limit: Int) {
    private fun small(x: Int) = x < limit
    open fun label(x: Int) = "n$x"
    val count = 3

    fun apply(xs: List<Int>): List<String> = xs.filter(::small).map(::label)

    fun deferred(): () -> List<Int> = { listOf(1, 5, 9).filter(::small) }

    fun countRef() = ::count

    inner class Report {
        fun lines(xs: List<Int>) = xs.map(::label)
    }
}

class Loud(limit: Int) : Filter(limit) {
    override fun label(x: Int) = "N$x!"
    fun shout(xs: List<Int>) = xs.map(::label)
}

object Registry {
    private val names = mutableListOf<String>()
    private fun register(name: String) {
        names += name
    }

    fun registerAll(xs: List<String>): List<String> {
        xs.forEach(::register)
        return names
    }
}

fun fib(n: Int): List<Int> {
    val out = mutableListOf<Int>()
    var (a, b) = 0 to 1
    repeat(n) {
        out += a
        val next = a + b
        a = b
        b = next
    }
    var (x, _) = Pair("p", 1)
    x += "q"
    return out + x.length
}

fun main() {
    val f = Filter(6)
    println(f.apply(listOf(3, 8, 5)))
    println(f.deferred()())
    println(f.countRef()())
    println(f.Report().lines(listOf(1, 2)))
    println(Loud(2).shout(listOf(1)))
    println(Loud(4).apply(listOf(1, 7)))
    println(Registry.registerAll(listOf("a", "b")))
    println(fib(8))
}
