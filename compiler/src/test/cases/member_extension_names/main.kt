class Holder {
    // both would be the method getX
    val String.x: Int get() = length
    val Int.x: Int get() = this

    // a function and an extension property both called getY
    fun getY() = 1
    val String.y: Int get() = 2

    fun String.shout() = this + "!"

    var counter = 0
    var String.z: Int
        get() = length + counter
        set(v) {
            counter = v
        }
    var Int.z: Int
        get() = this * 2 + counter
        set(v) {
            counter = v * 10
        }

    fun run(): String {
        "ab".z = 5
        val a = "abc".z
        7.z = 3
        val b = 4.z
        "q".z += 1
        return "$a $b $counter"
    }
}

open class Parent {
    open val String.tag: String get() = "parent:$this"
    val Int.tag: String get() = "int:$this"

    fun tags() = with("s") { tag } + " " + with(1) { tag }
}

class Child : Parent() {
    override val String.tag: String get() = "child:$this"
    val Double.tag: String get() = "double:$this"

    fun more() = with(2.5) { tag } + " " + with("t") { tag }
}

fun main() {
    val h = Holder()
    println(with(h) { "a".x + 1.x + "b".y + getY() + "c".shout().length })
    println(h.run())
    println(Parent().tags())
    val c = Child()
    println(c.tags())
    println(c.more())
}
