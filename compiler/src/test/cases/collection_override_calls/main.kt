// Overrides of size, iterator, get, contains, ... in subclasses of ArrayList, HashSet and HashMap are called by the library
// where the JVM calls them.
val log = mutableListOf<String>()

fun op(name: String, f: () -> Any?) {
    log.clear()
    val r = try { f() } catch (e: Exception) { e.javaClass.name }
    println("$name -> $r ${log.joinToString(",")}")
}

class L : ArrayList<Int>(listOf(1, 2, 3)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
    override fun get(index: Int): Int { log += "get($index)"; return super.get(index) }
    override fun contains(element: Int): Boolean { log += "contains($element)"; return super.contains(element) }
    override fun isEmpty(): Boolean { log += "isEmpty"; return super.isEmpty() }
    override fun indexOf(element: Int): Int { log += "indexOf"; return super.indexOf(element) }
    override fun listIterator(): MutableListIterator<Int> { log += "listIterator"; return super.listIterator() }
    override fun listIterator(index: Int): MutableListIterator<Int> { log += "listIterator($index)"; return super.listIterator(index) }
}

class S : HashSet<Int>(listOf(1, 2, 3)) {
    override val size: Int get() { log += "size"; return super.size }
    override fun iterator(): MutableIterator<Int> { log += "iterator"; return super.iterator() }
    override fun contains(element: Int): Boolean { log += "contains($element)"; return super.contains(element) }
    override fun isEmpty(): Boolean { log += "isEmpty"; return super.isEmpty() }
}

class M : HashMap<Int, String>(mapOf(1 to "a", 2 to "b")) {
    override val size: Int get() { log += "size"; return super.size }
    override fun get(key: Int): String? { log += "get($key)"; return super.get(key) }
    override fun containsKey(key: Int): Boolean { log += "containsKey($key)"; return super.containsKey(key) }
    override val entries: MutableSet<MutableMap.MutableEntry<Int, String>> get() { log += "entries"; return super.entries }
    override val keys: MutableSet<Int> get() { log += "keys"; return super.keys }
    override val values: MutableCollection<String> get() { log += "values"; return super.values }
    override fun isEmpty(): Boolean { log += "isEmpty"; return super.isEmpty() }
}

fun main() {
    val l = L()
    op("l toString") { l.toString() }
    op("l str") { "$l" }
    op("l map") { l.map { it * 2 } }
    op("l filter") { l.filter { it > 1 } }
    op("l for") { var s = 0; for (x in l) s += x; s }
    op("l forEach") { var s = 0; l.forEach { s += it }; s }
    op("l isEmpty") { l.isEmpty() }
    op("l isNotEmpty") { l.isNotEmpty() }
    op("l containsAll") { l.containsAll(listOf(1, 2)) }
    op("l contains") { 2 in l }
    op("l equals") { l == listOf(1, 2, 3) }
    op("l equals2") { listOf(1, 2, 3) == l }
    op("l hashCode") { l.hashCode() }
    op("l sum") { l.sum() }
    op("l first") { l.first() }
    op("l last") { l.last() }
    op("l joinToString") { l.joinToString() }
    op("l toList") { l.toList() }
    op("l toMutableList") { l.toMutableList() }
    op("l toSet") { l.toSet() }
    op("l indexOf") { l.indexOf(2) }
    op("l sorted") { l.sorted() }
    op("l reversed") { l.reversed() }
    op("l count") { l.count() }
    op("l any") { l.any { it > 2 } }
    op("l getOrNull") { l.getOrNull(1) }
    op("l elementAt") { l.elementAt(1) }
    op("l addAll to") { ArrayList<Int>().apply { addAll(l) } }
    op("l ArrayList(l)") { ArrayList(l) }
    op("l HashSet(l)") { HashSet(l) }
    op("l subList") { l.subList(0, 2).toString() }
    op("l remove") { l.remove(5) }
    op("l size") { l.size }
    op("l max") { l.max() }
    op("l take") { l.take(2) }
    op("l drop") { l.drop(1) }
    op("l zip") { l.zip(listOf(1)) }
    op("l withIndex") { l.withIndex().toList() }
    op("l asSequence") { l.asSequence().toList() }
    op("l plus") { l + 4 }
    op("l lastIndex") { l.lastIndex }
    op("l indices") { l.indices }
    op("l single") { listOf(1).let { l.singleOrNull() } }
    val s = S()
    op("s toString") { s.toString() }
    op("s map") { s.map { it * 2 } }
    op("s for") { var t = 0; for (x in s) t += x; t }
    op("s isEmpty") { s.isEmpty() }
    op("s containsAll") { s.containsAll(listOf(1, 2)) }
    op("s equals") { s == setOf(1, 2, 3) }
    op("s equals2") { setOf(1, 2, 3) == s }
    op("s hashCode") { s.hashCode() }
    op("s toList") { s.toList() }
    op("s first") { s.first() }
    op("s count") { s.count() }
    op("s joinToString") { s.joinToString() }
    op("s addAll to") { ArrayList<Int>().apply { addAll(s) } }
    op("s removeAll") { S().removeAll(listOf(1)) }
    op("s retainAll") { S().retainAll(listOf(1)) }
    val m = M()
    op("m toString") { m.toString() }
    op("m for") { var t = 0; for ((k, _) in m) t += k; t }
    op("m forEach2") { var t = 0; m.forEach { (k, _) -> t += k }; t }
    op("m forEachkv") { var t = 0; m.forEach { k, _ -> t += k }; t }
    op("m keys") { m.keys.toString() }
    op("m map") { m.map { it.key } }
    op("m filter") { m.filter { it.key > 1 } }
    op("m equals") { m == mapOf(1 to "a", 2 to "b") }
    op("m equals2") { mapOf(1 to "a", 2 to "b") == m }
    op("m hashCode") { m.hashCode() }
    op("m isEmpty") { m.isEmpty() }
    op("m getValue") { m.getValue(1) }
    op("m getOrDefault") { m.getOrDefault(1, "z") }
    op("m getOrElse") { m.getOrElse(1) { "z" } }
    op("m getOrPut") { m.getOrPut(1) { "z" } }
    op("m contains") { 1 in m }
    op("m containsValue") { m.containsValue("a") }
    op("m toList") { m.toList() }
    op("m toMap") { m.toMap() }
    op("m HashMap(m)") { HashMap(m) }
    op("m putAll to") { HashMap<Int, String>().apply { putAll(m) } }
    op("m mapValues") { m.mapValues { it.value } }
    op("m count") { m.count() }
    op("m any") { m.any { it.key > 1 } }
    op("m size") { m.size }
    op("m entries size") { m.entries.size }
    op("m keys size") { m.keys.size }
    op("m plus") { m + (3 to "c") }
    op("m toSortedMap") { m.toSortedMap() }
    op("m maxBy") { m.maxBy { it.key } }
    op("m isNotEmpty") { m.isNotEmpty() }
    op("m orEmpty") { m.orEmpty() }
    op("m merge") { M().merge(1, "x") { a, b -> a + b } }
    op("m putIfAbsent") { M().putIfAbsent(1, "x") }
    op("m computeIfAbsent") { M().computeIfAbsent(1) { "x" } }
}
