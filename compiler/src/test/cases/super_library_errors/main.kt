// Only Any's toString/equals/hashCode and Throwable's message/cause/toString/printStackTrace/fillInStackTrace are available through `super`.
class Failure : Exception("failed") {
    fun dump() = super.printStackTrace() // supported: written to stderr

    fun same() = super.fillInStackTrace() === this // supported

    fun trace() = super.getStackTrace()

    fun suppressed() = super.getSuppressed()
}

class Names {
    override fun toString(): String = super.toString()
}

fun main() {
    println(Names().toString().isNotEmpty())
}
