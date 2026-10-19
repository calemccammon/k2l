// The same for LinkedList, TreeSet, LinkedHashSet, PriorityQueue, ArrayDeque, LinkedHashMap and TreeMap.
import java.util.LinkedList
import java.util.PriorityQueue
import java.util.TreeMap
import java.util.TreeSet

val log = mutableListOf<String>()

fun op(name: String, f: () -> Any?) {
    log.clear()
    val r = try { f() } catch (e: Exception) { e.javaClass.name }
    println("$name -> $r ${log.joinToString(",")}")
}

class LL : LinkedList<Int>(listOf(1, 2, 3)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
    override fun get(index: Int): Int { log += "get($index)"; return super.get(index) }
    override fun contains(element: Int): Boolean { log += "contains"; return super.contains(element) }
    override fun indexOf(element: Int): Int { log += "indexOf"; return super.indexOf(element) }
}

class TS : TreeSet<Int>(listOf(3, 1, 2)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
    override fun contains(element: Int): Boolean { log += "contains"; return super.contains(element) }
}

class LS : LinkedHashSet<Int>(listOf(1, 2, 3)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
    override fun isEmpty(): Boolean { log += "isEmpty"; return super.isEmpty() }
}

class PQ : PriorityQueue<Int>(listOf(3, 1, 2)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
}

class JD : java.util.ArrayDeque<Int>(listOf(1, 2, 3)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
}

class LM : LinkedHashMap<Int, String>(mapOf(1 to "a", 2 to "b")) {
    override val size: Int get() { log += "size"; return super.size }
    override val entries: MutableSet<MutableMap.MutableEntry<Int, String>> get() { log += "entries"; return super.entries }
    override fun get(key: Int): String? { log += "get"; return super.get(key) }
}

class TM : TreeMap<Int, String>(mapOf(2 to "b", 1 to "a")) {
    override val size: Int get() { log += "size"; return super.size }
    override val entries: MutableSet<MutableMap.MutableEntry<Int, String>> get() { log += "entries"; return super.entries }
    override fun containsKey(key: Int): Boolean { log += "containsKey"; return super.containsKey(key) }
}

fun coll(label: String, c: Collection<Int>) {
    op("$label toString") { c.toString() }
    op("$label map") { c.map { it + 1 } }
    op("$label filter") { c.filter { it > 1 } }
    op("$label for") { var s = 0; for (x in c) s += x; s }
    op("$label isEmpty") { c.isEmpty() }
    op("$label contains") { 2 in c }
    op("$label containsAll") { c.containsAll(listOf(1, 3)) }
    op("$label first") { c.first() }
    // a TreeSet's last() is its own member here (on the JVM the stdlib's, as the static type is Collection)
    if (c !is TreeSet<*>) op("$label last") { c.last() }
    op("$label toList") { c.toList() }
    op("$label toSet") { c.toSet() }
    op("$label sorted") { c.sorted() }
    op("$label count") { c.count() }
    op("$label any") { c.any { it > 2 } }
    op("$label sum") { c.sum() }
    // a PriorityQueue's and an ArrayDeque's hash codes are identity hashes
    if (c !is PriorityQueue<*> && c !is java.util.ArrayDeque<*>) op("$label hashCode") { c.hashCode() }
    op("$label eq") { c == c.toList() }
    op("$label eq set") { c == c.toSet() }
    op("$label ArrayList") { ArrayList(c) }
    op("$label HashSet") { HashSet(c) }
    op("$label plus") { c + 9 }
    op("$label joinToString") { c.joinToString() }
    op("$label single") { c.singleOrNull() }
}

fun maps(label: String, m: Map<Int, String>) {
    op("$label toString") { m.toString() }
    op("$label for") { var s = 0; for ((k, _) in m) s += k; s }
    op("$label map") { m.map { it.key } }
    op("$label filter") { m.filter { it.key > 1 } }
    op("$label eq") { m == mapOf(1 to "a", 2 to "b") }
    op("$label eq2") { mapOf(1 to "a", 2 to "b") == m }
    op("$label hashCode") { m.hashCode() }
    op("$label getOrElse") { m.getOrElse(1) { "z" } }
    op("$label toList") { m.toList() }
    op("$label HashMap") { HashMap(m) }
    op("$label count") { m.count() }
    op("$label containsKey") { 1 in m }
    op("$label getValue") { m.getValue(1) }
    op("$label keys") { m.keys.toString() }
    op("$label values") { m.values.toString() }
    op("$label isEmpty") { m.isEmpty() }
}

fun main() {
    coll("LL", LL())
    coll("TS", TS())
    coll("LS", LS())
    coll("PQ", PQ())
    coll("JD", JD())
    maps("LM", LM())
    maps("TM", TM())
    val ll = LL()
    op("LL getOrNull") { ll.getOrNull(1) }
    op("LL indexOf") { ll.indexOf(2) }
    op("LL remove") { ll.remove(5) }
    val pq = PQ()
    op("PQ isEmpty") { pq.isEmpty() }
    op("PQ peek") { pq.peek() }
}
