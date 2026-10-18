class Holder { val String.last: Char get() = this[length - 1]; val Int.last: Int get() = this }

fun localInner() {
    class Local { inner class Inner }
}

fun main() {
    println(Holder())
}
