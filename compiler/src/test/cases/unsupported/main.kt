class Outer {
    inner class Inner
}

class Overloads {
    fun f(x: Int) = x
    fun f(x: String) = x
}

class MyError : Exception("boom")

fun main() {
    val xs = listOf(1, 2, 3)
    println(xs)
}
