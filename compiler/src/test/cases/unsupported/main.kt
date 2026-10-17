class Outer {
    inner class Inner
}

fun sum(vararg xs: Int) = xs.size

val String.lastChar: Char get() = this[length - 1]

fun main() {
    val xs = listOf(1, 2, 3)
    println(xs)
}
