class Holder { val String.last: Char get() = this[length - 1]; val Int.last: Int get() = this }

fun localInner() {
    class Local { inner class Inner }
}

fun main() {
    val x: Any = 1
    println(x::class.simpleName)
}
