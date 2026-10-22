// A property overriding a library one with an accessor and a backing field (`override var size` with a setter in an
// AbstractMutableMap): the library reads `size` through the getter, which reads the backing field.
class Sized : AbstractMutableMap<String, Int>() {
    private val backing = LinkedHashMap<String, Int>()
    var sizeChanges = 0

    override var size = 0
        set(value) {
            field = value
            sizeChanges++
        }

    override val entries: MutableSet<MutableMap.MutableEntry<String, Int>> get() = backing.entries

    override fun put(key: String, value: Int): Int? {
        val old = backing.put(key, value)
        size = backing.size
        return old
    }

    override fun remove(key: String): Int? {
        val old = backing.remove(key)
        size = backing.size
        return old
    }
}

class Failure(text: String) : Exception() {
    override var message: String? = text
        set(value) {
            field = "[$value]"
        }
}

fun main() {
    val m = Sized()
    println(m.size)
    m["a"] = 1
    m["b"] = 2
    println(m.size)
    println(m.isEmpty())
    println(m)
    m.remove("a")
    println("${m.size} ${m.sizeChanges}")
    val asMap: Map<String, Int> = m
    println(asMap.size)
    println(asMap == mapOf("b" to 2))

    val f = Failure("x")
    println(f.message)
    f.message = "y"
    println(f.message)
    println(f)
}
