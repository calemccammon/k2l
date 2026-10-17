class Holder { val String.last: Char get() = this[length - 1] }

fun localInner() {
    class Local { inner class Inner }
}

suspend fun later() = 1

fun main() {
    val seq = generateSequence(1) { it + 1 }
    println(seq.take(3).toList())
    val x: Any = 1
    println(x::class.simpleName)
}
