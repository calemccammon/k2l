// Collections, maps and pairs of Doubles print integral elements as Doubles on targets without an integer subtype
// (Lua 5.1, 5.2, LuaJIT), where the static type says every number in them is a Double.
data class P(val n: Int, val xs: List<Double>)

fun main() {
    val a = listOf(1.5, 3.0)
    println(a)
    println("a=$a")
    val m = mapOf("x" to 2.0, "y" to -0.0)
    println(m)
    println(listOf(listOf(1.0), listOf<Double>()))
    println(P(3, listOf(4.0)))
    println(Pair("w", 7.0))
    val n: List<Double>? = listOf(5.0)
    println(n)
    println(setOf(1.0, 2.0).toString())
    println(listOf(1, 2))
}
