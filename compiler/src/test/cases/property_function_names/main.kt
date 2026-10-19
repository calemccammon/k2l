interface Source {
    fun items(): List<String>
}

open class Base {
    open fun size(): Int = 1
    fun total() = size() * 10
}

class Derived : Base() {
    val size = 5
    override fun size(): Int = size + 1
}

class Inbox(private val items: MutableList<String>) : Source {
    override fun items(): List<String> = items.toList()
    fun count() = items.size
    fun count(prefix: String) = items.count { it.startsWith(prefix) }
}

class Holder {
    private val values = mutableListOf(1, 2)
    fun values() = values.map { it * 2 }
}

fun main() {
    val box = Inbox(mutableListOf("a", "ab"))
    val s: Source = box
    println(s.items())
    println(box.count())
    println(box.count("ab"))
    println(Derived().total())
    println(Derived().size)
    println(Holder().values())
    val f = Holder::values
    println(f(Holder()))
}
