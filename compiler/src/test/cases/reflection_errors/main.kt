class Plain(val x: Int)

fun main() {
    println(Plain::class.members)
    println(Plain::class.isData)
    println(Plain::class.objectInstance)
}
