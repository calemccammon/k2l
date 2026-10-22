// A class overriding one overload of a library member the lualib implements as one Lua method: removeAll/retainAll
// (elements) also take a predicate, a map's remove(key) also takes the value; a new overload of the same name
// (`fun removeAll(predicate)`, `fun remove(key, value)`) gets its own Lua name. Also removeAll of a sequence.
class Bag : AbstractMutableList<Int>() {
    private val items = ArrayList<Int>()
    var log = ""

    override val size: Int get() = items.size
    override fun get(index: Int): Int = items[index]
    override fun set(index: Int, element: Int): Int = items.set(index, element)
    override fun add(index: Int, element: Int) = items.add(index, element)
    override fun removeAt(index: Int): Int = items.removeAt(index)

    override fun removeAll(elements: Collection<Int>): Boolean {
        log += "removeAll(elements) "
        return removeAll { it in elements }
    }

    override fun retainAll(elements: Collection<Int>): Boolean {
        log += "retainAll(elements) "
        return items.retainAll(elements)
    }

    // a new overload, not the stdlib's MutableList.removeAll { }
    fun removeAll(predicate: (Int) -> Boolean): Boolean {
        log += "own removeAll(predicate) "
        return items.removeAll(predicate)
    }
}

class Registry : AbstractMutableMap<String, Int>() {
    private val backing = LinkedHashMap<String, Int>()
    var log = ""

    override val entries: MutableSet<MutableMap.MutableEntry<String, Int>> get() = backing.entries

    override fun put(key: String, value: Int): Int? = backing.put(key, value)

    override fun remove(key: String): Int? {
        log += "remove($key) "
        return backing.remove(key)
    }

    fun remove(key: String, value: Int): Boolean {
        log += "remove($key, $value) "
        if (backing[key] != value) return false
        backing.remove(key)
        return true
    }
}

class Plain : AbstractMutableMap<String, Int>() {
    private val backing = LinkedHashMap<String, Int>()

    override val entries: MutableSet<MutableMap.MutableEntry<String, Int>> get() = backing.entries

    override fun put(key: String, value: Int): Int? = backing.put(key, value)

    override fun remove(key: String): Int? = backing.remove(key)
}

class Tags : AbstractMutableSet<String>() {
    private val items = LinkedHashSet<String>()
    override val size: Int get() = items.size
    override fun iterator(): MutableIterator<String> = items.iterator()
    override fun add(element: String): Boolean = items.add(element)
}

fun main() {
    val bag = Bag()
    bag.addAll(listOf(1, 2, 3, 4, 5, 6))
    val list: MutableList<Int> = bag
    println(list.removeAll { it % 2 == 0 })
    println(bag)
    println(list.removeAll(listOf(1)))
    println(bag)
    println(list.retainAll { it > 3 })
    println(bag)
    println(list.retainAll(listOf(5)))
    println("$bag ${bag.log}")
    println(bag.removeAll { true })

    val registry = Registry()
    registry["a"] = 1
    registry["b"] = 2
    registry["c"] = 3
    val map: MutableMap<String, Int> = registry
    println(map.remove("a", 9))
    println(map.remove("a", 1))
    println(map.remove("b"))
    println(registry.remove("c", 3))
    println("$registry ${registry.log}")

    val plain = Plain()
    plain["x"] = 1
    plain["y"] = 2
    val plainMap: MutableMap<String, Int> = plain
    println(plainMap.remove("x", 2))
    println(plainMap.remove("x", 1))
    println(plainMap.remove("y"))
    println(plain)

    val tags = Tags()
    tags.addAll(listOf("a", "b", "c", "d"))
    println(tags.removeAll(sequenceOf("a", "c")))
    println(tags)
    println(tags.retainAll(sequenceOf("d")))
    println(tags)
}
