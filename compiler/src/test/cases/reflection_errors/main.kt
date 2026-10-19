class Plain(val x: Int)

fun main() {
    println(Plain::class.java.methods)
    println(Plain::class.java.declaredFields)
}
