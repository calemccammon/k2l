class Failure(private val code: Int) : Exception("ignored") {
    override val message: String get() = "failed with code $code"
}

class Wrapped : RuntimeException() {
    override val cause: Throwable? get() = IllegalStateException("inner")
    override val message: String? get() = "wrapped/" + super.message
}

open class Base(text: String) : Exception(text) {
    override val message: String get() = "base:" + super.message
}

class Leaf : Base("leaf")

fun main() {
    val f = Failure(7)
    println(f.message)
    println(f)
    val asThrowable: Throwable = f
    println(asThrowable.message)
    try {
        throw f
    } catch (e: Exception) {
        println("caught ${e.message}")
    }
    val w = Wrapped()
    println(w.message)
    println(w.cause?.message)
    println(Leaf().message)
    val leaf: Throwable = Leaf()
    println(leaf.message)
    println(leaf)
}
