fun String.shout(): String = uppercase() + "!"

fun Int.isEven(): Boolean = this % 2 == 0

fun String?.orEmptyText(): String = this ?: ""

class Vec(val x: Int, val y: Int)

fun Vec.length2(): Int = x * x + y * y

fun Vec.scaled(k: Int): Vec = Vec(x * k, y * k)

fun Vec.describe(): String = "(${this.x}, $y) len2=${length2()}"

fun main() {
    println("hi".shout())
    println(4.isEven())
    println(7.isEven())
    val missing: String? = null
    println(missing.orEmptyText().length)
    println("x".orEmptyText())
    val v = Vec(3, 4)
    println(v.length2())
    println(v.scaled(2).describe())
    val shout = String::shout
    println(shout("ref"))
}
