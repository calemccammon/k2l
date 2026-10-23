package app

var made = 0

fun fresh(): Int {
    made++
    println("fresh $made")
    return made
}

data class Options(val size: Int = 10, val label: String = "x$size", val id: Int = fresh())

data class Maybe(val name: String? = "anon", val alias: String? = null, val tags: List<String> = emptyList())

class Plain(val a: Int, val b: Int = a * 2)

open class Base(val level: Int = 1, val name: String? = "base")

class Derived(level: Int) : Base(level)

class Twice(val n: Int = 1) {
    constructor(s: String) : this(s.length)
}

fun main() {
    println(Options())
    println(Options(size = 3))
    println(Options(label = "given", id = 0))
    println(made)

    println(Maybe())
    println(Maybe(null))
    println(Maybe(name = null, alias = "a"))
    val nothing: String? = null
    println(Maybe(nothing, nothing))
    val m = Maybe("n", "a", listOf("t"))
    println(m.copy(name = null))
    println(m.copy(alias = nothing))

    val p = Plain(4)
    println("${p.a} ${p.b}")
    println(Plain(1, 1).b)

    val base = Base(name = null)
    println("${base.level} ${base.name}")
    val d = Derived(5)
    println("${d.level} ${d.name}")
    println(Twice("four").n)
    println(Twice().n)
}
