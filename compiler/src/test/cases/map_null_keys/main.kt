// Maps with a null key: copies (putAll, toMutableMap, HashMap(map)), forEach { k, v -> }, equality and getOrElse go on
// past the null key, also for a class extending AbstractMap.
class Backed(private val backing: Map<String?, Int>) : AbstractMap<String?, Int>() {
    override val entries: Set<Map.Entry<String?, Int>> get() = backing.entries
}

fun main() {
    val a = linkedMapOf<String?, Int>(null to 1, "b" to 2)
    val b = LinkedHashMap<String?, Int>()
    b.putAll(a)
    println(b)
    println(a.toMutableMap())
    println(HashMap(a))
    a.forEach { k, v -> print("$k=$v ") }
    println()
    val sorted = sortedMapOf<String, Int>("x" to 1)
    sorted.putAll(linkedMapOf("y" to 2, "a" to 0))
    println(sorted)

    val backed = Backed(a)
    println(backed)
    println(backed == a)
    println(a == backed)
    println(LinkedHashMap(backed))
    val copy = mutableMapOf<String?, Int>()
    copy.putAll(backed)
    println(copy)
    backed.forEach { k, v -> print("$k=$v ") }
    println()
    println(backed.getOrElse(null) { -1 })
    println(backed.getOrElse("z") { -1 })
    println(backed.hashCode() == a.hashCode())
}
