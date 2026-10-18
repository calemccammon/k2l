class Holder {
    // both would be the method getX
    val String.x: Int get() = length
    val Int.x: Int get() = this

    // a function and an extension property both called getY
    fun getY() = 1
    val String.y: Int get() = 2

    fun String.shout() = this + "!"
}

fun main() {
    val h = Holder()
    println(with(h) { "a".x + 1.x + "b".y + getY() + "c".shout().length })
}
