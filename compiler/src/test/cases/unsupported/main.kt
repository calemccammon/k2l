class Outer {
    inner class Inner
}

val String.lastChar: Char get() = this[length - 1]

suspend fun later() = 1

fun main() {
    val seq = generateSequence(1) { it + 1 }
    println(seq.take(3).toList())
    val x: Any = 1
    println(x::class.simpleName)
}
