// Only Any's toString/equals/hashCode and Throwable's message/cause/toString are available through `super`.
class Failure : Exception("failed") {
    fun dump() = super.printStackTrace()

    fun trace() = super.fillInStackTrace()
}

class Names {
    override fun toString(): String = super.toString()
}

fun main() {
    println(Names().toString().isNotEmpty())
}
