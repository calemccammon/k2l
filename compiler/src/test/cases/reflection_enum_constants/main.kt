// Class.enumConstants: a fresh array of the entries of an enum class, in declaration order, or null for any other class
enum class Color { RED, GREEN, BLUE }

enum class Op(val symbol: String) {
    PLUS("+") {
        override fun apply(a: Int, b: Int) = a + b
    },
    TIMES("*") {
        override fun apply(a: Int, b: Int) = a * b
    };

    abstract fun apply(a: Int, b: Int): Int
}

enum class Empty

class Plain

fun <T> names(constants: Array<T>?): String = constants?.joinToString(",") ?: "null"

fun main() {
    println(names(Color::class.java.enumConstants))
    println(names(Color.GREEN.javaClass.enumConstants))
    println(names(Color.RED.declaringJavaClass.enumConstants))
    // an entry with a body has a class of its own, which is not an enum class; its declaring class is
    println(names(Op.PLUS.javaClass.enumConstants) + " " + names(Op.PLUS.declaringJavaClass.enumConstants))
    println(Op.TIMES.declaringJavaClass == Op::class.java)
    println(names(Op::class.java.enumConstants))
    println(Op::class.java.enumConstants.map { it.apply(6, 7) })
    println(names(Empty::class.java.enumConstants))
    println(Empty::class.java.enumConstants.size)
    println(names(Plain::class.java.enumConstants))
    println(names(String::class.java.enumConstants))
    println(names("text".javaClass.enumConstants))

    // a fresh array each time: changing one leaves the next alone
    val first = Color::class.java.enumConstants
    first[0] = Color.BLUE
    println(names(first) + " " + names(Color::class.java.enumConstants))
    println(first === Color::class.java.enumConstants)

    // through a generic Class
    fun <E : Enum<E>> count(cls: Class<E>) = cls.enumConstants.size
    println(count(Color::class.java) + count(Op::class.java))
    val any: Class<*> = Color::class.java
    println(any.enumConstants?.size)
}
