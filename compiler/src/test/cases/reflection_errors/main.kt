class Plain(val x: Int)

fun main() {
    println(Plain::class.annotations)
    println(Plain::class.java.declaredFields)
}
