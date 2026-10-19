// `vararg` parameters that are not the last one (functions, constructors, methods, inline functions), and references to
// functions with a `vararg` parameter, taking the Array or adapted to separate arguments.
fun sum(vararg xs: Int) = xs.sum()

fun tagged(tag: String, vararg xs: Int, sep: String = ",") = tag + xs.joinToString(sep)

fun <T> build(vararg parts: T, combine: (List<T>) -> String) = combine(parts.toList())

class Row(vararg val cells: String, val width: Int = 5) {
    override fun toString() = cells.joinToString("|") { it.padEnd(width) }
}

open class Base(val name: String, vararg val tags: String, val n: Int)

class Sub : Base("s", "a", "b", n = 2)

class Table(private val name: String) {
    fun row(vararg cells: Any?, separator: String = " | ") = name + ": " + cells.joinToString(separator)
}

inline fun total(vararg xs: Int, f: (Int) -> Int): Int {
    var sum = 0
    for (x in xs) sum += f(x)
    return sum
}

fun spreadFirst(xs: IntArray): Int = total(*xs, 1) { if (it < 0) return -1 else it }

fun main() {
    println(tagged("t", 1, 2, sep = ";") + " " + tagged("u") + " " + tagged("v", *intArrayOf(4, 5), 6))
    println(build("a", "b") { it.joinToString("+") } + " " + build<Int> { "empty $it" })
    println(Row("a", "b", width = 3))
    println(Row("c"))
    val s = Sub()
    println("${s.name} ${s.tags.toList()} ${s.n}")
    val t = Table("t")
    println(t.row(1, "x", null) + " / " + t.row(separator = ",") + " / " + t.row(*arrayOf(1, 2), 3, separator = "-"))
    println("${spreadFirst(intArrayOf(1, 2))} ${spreadFirst(intArrayOf(3, -4))}")

    val f: (IntArray) -> Int = ::sum
    val g: (String, IntArray, String) -> String = ::tagged
    val one: (Int) -> Int = ::sum
    val mk: (Array<String>, Int) -> Row = ::Row
    val method: (Table, Array<Any?>, String) -> String = Table::row
    val bound: (Array<Any?>, String) -> String = t::row
    println("${f(intArrayOf(1, 2, 3))} ${g("w", intArrayOf(7, 8), "-")} ${one(9)} ${listOf(4, 5).map(::sum)}")
    println("${mk(arrayOf("p", "q"), 2)} ${method(t, arrayOf(1, 2), "&")} ${bound(arrayOf("z"), "")}")
}
