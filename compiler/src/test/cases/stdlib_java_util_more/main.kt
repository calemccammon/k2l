import java.util.ArrayDeque
import java.util.Arrays
import java.util.Collections
import java.util.LinkedList
import java.util.Objects
import java.util.Optional
import java.util.OptionalDouble
import java.util.OptionalInt
import java.util.OptionalLong
import java.util.TreeMap
import java.util.TreeSet

enum class Color { RED, GREEN, BLUE }

// More of java.util: Collections views and helpers, Optional, Arrays.compare/mismatch, Objects, clone() and friends
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    val tree = TreeSet(listOf(5, 1, 3))
    val sorted = Collections.unmodifiableSortedSet(tree)
    t("unmodifiableSortedSet") { "$sorted ${sorted.first()} ${sorted.last()} ${sorted.size} ${3 in sorted}" }
    t("unmodifiableSortedSet add") { sorted.add(9) }
    tree.add(4)
    t("view is live") { sorted }
    val nav = Collections.unmodifiableNavigableSet(tree)
    t("unmodifiableNavigableSet") { "${nav.floor(2)} ${nav.ceiling(2)} ${nav.headSet(4)}" }
    t("unmodifiableNavigableSet poll") { nav.pollFirst() }
    val map = TreeMap(mapOf("b" to 2, "a" to 1, "c" to 3))
    val sortedMap = Collections.unmodifiableSortedMap(map)
    t("unmodifiableSortedMap") { "$sortedMap ${sortedMap.firstKey()} ${sortedMap["b"]} ${sortedMap.keys}" }
    t("unmodifiableSortedMap put") { sortedMap["d"] = 4 }
    val navMap = Collections.unmodifiableNavigableMap(map)
    t("unmodifiableNavigableMap") { "${navMap.floorKey("bb")} ${navMap.lastEntry()}" }
    t("unmodifiableNavigableMap poll") { navMap.pollFirstEntry() }
    t("unmodifiableNavigableMap keys") { navMap.keys.remove("a") }
    t("emptySortedSet") { Collections.emptySortedSet<Int>().let { "$it ${it.size} ${it.isEmpty()}" } }
    t("emptySortedSet add") { Collections.emptySortedSet<Int>().add(1) }
    t("emptyNavigableMap") { Collections.emptyNavigableMap<String, Int>().let { "$it ${it.size}" } }
    t("emptySortedMap put") { Collections.emptySortedMap<String, Int>()["x"] = 1 }
    t("emptyIterator") { Collections.emptyIterator<Int>().hasNext() }
    t("emptyListIterator") { Collections.emptyListIterator<Int>().let { "${it.hasNext()} ${it.hasPrevious()} ${it.nextIndex()}" } }
    t("emptyIterator next") { Collections.emptyIterator<Int>().next() }
    t("synchronized") { "${Collections.synchronizedSortedSet(tree).first()} ${Collections.synchronizedNavigableMap(map).lastKey()}" }

    val source = listOf(1, 2, 3, 1, 2, 3, 4)
    t("indexOfSubList") { listOf(Collections.indexOfSubList(source, listOf(2, 3)), Collections.indexOfSubList(source, listOf(3, 2)), Collections.indexOfSubList(source, emptyList<Int>())) }
    t("lastIndexOfSubList") { listOf(Collections.lastIndexOfSubList(source, listOf(2, 3)), Collections.lastIndexOfSubList(source, listOf(9)), Collections.lastIndexOfSubList(source, emptyList<Int>())) }
    val fromMap = Collections.newSetFromMap(LinkedHashMap<String, Boolean>())
    fromMap.add("z")
    fromMap.add("a")
    fromMap.add("z")
    t("newSetFromMap") { fromMap }
    t("newSetFromMap tree") { Collections.newSetFromMap(TreeMap<String, Boolean>()).apply { addAll(listOf("q", "b", "k")) } }
    t("newSetFromMap non-empty") { Collections.newSetFromMap(hashMapOf("a" to true)) }
    t("nCopies") { Collections.nCopies(3, "ab") }
    t("frequency/disjoint") { "${Collections.frequency(source, 3)} ${Collections.disjoint(source, listOf(7, 8))} ${Collections.disjoint(source, listOf(4))}" }
    t("rotate/swap") { source.toMutableList().apply { Collections.rotate(this, 2); Collections.swap(this, 0, 6) } }
    t("min/max comparator") { "${Collections.max(source, compareByDescending { it })} ${Collections.min(listOf("bb", "a", "ccc"), compareBy { it.length })}" }
    t("reverseOrder comparator") { listOf("bb", "a", "ccc").sortedWith(Collections.reverseOrder(compareBy { it.length })) }

    t("Optional.or") { listOf(Optional.of(1).or { Optional.of(2) }, Optional.empty<Int>().or { Optional.of(2) }) }
    t("Optional.stream") { listOf(Optional.of("x").stream().toList(), Optional.empty<String>().stream().count()) }
    t("Optional.hashCode") { listOf(Optional.of("ab").hashCode(), Optional.empty<String>().hashCode(), Optional.of(7).hashCode()) }
    t("Optional.isEmpty") { listOf(Optional.empty<Int>().isEmpty, Optional.of(1).isEmpty) }
    t("Optional.orElseThrow") { Optional.empty<Int>().orElseThrow() }
    t("Optional.ifPresentOrElse") {
        val out = mutableListOf<String>()
        Optional.of(3).ifPresentOrElse({ out += "got $it" }, { out += "none" })
        Optional.empty<Int>().ifPresentOrElse({ out += "got $it" }, { out += "none" })
        out
    }
    t("OptionalInt") { "${OptionalInt.of(5).hashCode()} ${OptionalInt.of(5).stream().sum()} ${OptionalInt.empty().stream().count()}" }
    t("OptionalLong") { "${OptionalLong.of(-1L).hashCode()} ${OptionalLong.of(5_000_000_000L).hashCode()} ${OptionalLong.of(9L).stream().sum()}" }
    t("OptionalDouble") { "${OptionalDouble.of(1.5).hashCode()} ${OptionalDouble.of(2.5).stream().sum()} ${OptionalDouble.empty().hashCode()}" }

    t("Arrays.compare") {
        listOf(
            Arrays.compare(intArrayOf(1, 2, 3), intArrayOf(1, 2, 4)), Arrays.compare(intArrayOf(1, 2), intArrayOf(1, 2, 3)),
            Arrays.compare(intArrayOf(5), intArrayOf(5)), Arrays.compare(byteArrayOf(1, 9), byteArrayOf(1, 2)),
            Arrays.compare(charArrayOf('a', 'z'), charArrayOf('a', 'b')), Arrays.compare(booleanArrayOf(true), booleanArrayOf(false)),
            Arrays.compare(doubleArrayOf(0.0), doubleArrayOf(-0.0)), Arrays.compare(arrayOf("abc", "x"), arrayOf("abd", "x")),
            Arrays.compare(arrayOf("b"), arrayOf("a", "b")), Arrays.compare(longArrayOf(1L, 5L), longArrayOf(1L, 2L, 3L, 4L)),
        )
    }
    t("Arrays.compare ranges") { listOf(Arrays.compare(intArrayOf(9, 1, 2), 1, 3, intArrayOf(1, 2, 7), 0, 2), Arrays.compare(intArrayOf(1, 2, 3), 0, 3, intArrayOf(1, 2), 0, 2)) }
    t("Arrays.compare comparator") { Arrays.compare(arrayOf("aa", "b"), arrayOf("c", "bbb"), compareBy<String> { it.length }) }
    t("Arrays.compare nulls") { listOf(Arrays.compare(null as IntArray?, intArrayOf()), Arrays.compare(arrayOf<String>("a"), arrayOf<String>("a", "b"))) }
    t("Arrays.compare range error") { Arrays.compare(intArrayOf(1), 0, 5, intArrayOf(1), 0, 1) }
    t("Arrays.compareUnsigned") { listOf(Arrays.compareUnsigned(byteArrayOf(-1), byteArrayOf(1)), Arrays.compareUnsigned(intArrayOf(-1), intArrayOf(1)), Arrays.compareUnsigned(longArrayOf(1L), longArrayOf(-1L))) }
    t("Arrays.mismatch") {
        listOf(
            Arrays.mismatch(intArrayOf(1, 2, 3), intArrayOf(1, 2, 4)), Arrays.mismatch(intArrayOf(1, 2), intArrayOf(1, 2, 3)),
            Arrays.mismatch(intArrayOf(1, 2), intArrayOf(1, 2)), Arrays.mismatch(doubleArrayOf(Double.NaN), doubleArrayOf(Double.NaN)),
            Arrays.mismatch(doubleArrayOf(0.0), doubleArrayOf(-0.0)), Arrays.mismatch(arrayOf("a", null), arrayOf("a", "b")),
            Arrays.mismatch(intArrayOf(5, 1, 2), 1, 3, intArrayOf(1, 2), 0, 2),
            Arrays.mismatch(arrayOf("A", "b"), arrayOf("a", "c"), String.CASE_INSENSITIVE_ORDER),
        )
    }
    t("Arrays.parallelPrefix") { intArrayOf(1, 2, 3, 4, 5).apply { Arrays.parallelPrefix(this) { a, b -> a + b } }.toList() }
    t("Arrays.parallelPrefix range") { intArrayOf(1, 2, 3, 4, 5).apply { Arrays.parallelPrefix(this, 1, 4) { a, b -> a * b } }.toList() }
    t("Arrays.parallelSort") { intArrayOf(5, 3, 9, 1).apply { Arrays.parallelSort(this) }.toList() }
    t("Arrays.parallelSetAll") { IntArray(4).apply { Arrays.parallelSetAll(this) { it * it } }.toList() }

    t("Objects.checkFromToIndex") { Objects.checkFromToIndex(1, 3, 5) }
    t("Objects.checkFromToIndex bad") { Objects.checkFromToIndex(2, 1, 5) }
    t("Objects.checkFromIndexSize") { Objects.checkFromIndexSize(1, 3, 5) }
    t("Objects.checkFromIndexSize bad") { Objects.checkFromIndexSize(2, 4, 5) }
    t("Objects.requireNonNullElseGet") { listOf(Objects.requireNonNullElseGet("a") { "b" }, Objects.requireNonNullElseGet(null) { "b" }) }
    t("Objects.requireNonNullElseGet null") { Objects.requireNonNullElseGet<String>(null) { null } }
    t("Objects.deepEquals") { listOf(Objects.deepEquals(arrayOf(intArrayOf(1)), arrayOf(intArrayOf(1))), Objects.deepEquals("a", "a"), Objects.deepEquals(null, 1), Objects.deepEquals(1.0, 1.0)) }

    val list = arrayListOf(3, 1, 2)
    @Suppress("UNCHECKED_CAST")
    val copy = list.clone() as ArrayList<Int>
    copy.add(9)
    list.ensureCapacity(100)
    list.trimToSize()
    t("ArrayList.clone") { "$list $copy" }
    val byLength = TreeMap<String, Int>(compareBy { it.length })
    byLength["ccc"] = 3
    byLength["a"] = 1
    @Suppress("UNCHECKED_CAST")
    val mapCopy = byLength.clone() as TreeMap<String, Int>
    mapCopy["bb"] = 2
    t("TreeMap.clone") { "$byLength $mapCopy ${mapCopy.comparator() != null} ${TreeMap<String, Int>().comparator()}" }
    @Suppress("UNCHECKED_CAST")
    val setCopy = hashSetOf(1, 2).clone() as HashSet<Int>
    t("HashSet.clone") { setCopy.size }
    t("TreeSet.comparator") { TreeSet<Int>(compareByDescending { it }).apply { addAll(listOf(1, 3, 2)) }.let { "${it.comparator() != null} ${(it.clone() as TreeSet<*>)}" } }
    val deque = ArrayDeque(listOf(1, 2, 3, 2, 1))
    t("ArrayDeque.removeLastOccurrence") { "${deque.removeLastOccurrence(2)} ${deque.removeFirstOccurrence(1)} ${deque.removeLastOccurrence(7)} $deque" }
    val linked = LinkedList(listOf("a", "b", "a", "c"))
    t("LinkedList.removeLastOccurrence") { "${linked.removeLastOccurrence("a")} $linked" }
    t("toArray") { linked.toArray().toList() }
    val hm = hashMapOf("k" to 1)
    t("HashMap.replace") { "${hm.replace("k", 2)} ${hm.replace("z", 3)} ${hm.replace("k", 2, 5)} ${hm.replace("k", 9, 7)} $hm" }
    t("newHashMap") { HashMap.newHashMap<String, Int>(10).apply { put("a", 1) } }
    t("LinkedHashMap.putLast") { linkedMapOf("a" to 1, "b" to 2).apply { putLast("a", 3) } }
    t("LinkedHashMap.sequencedKeySet") { linkedMapOf("x" to 1, "y" to 2).sequencedKeySet() }
    t("TreeMap.putFirst") { TreeMap<String, Int>().putFirst("a", 1) }

    val bits = java.util.BitSet()
    bits[2, 6] = true
    bits[3, 4] = false
    t("BitSet range index") { "$bits ${bits[0, 5]}" }
    t("toArray(array)") { listOf(linked.toArray(arrayOf<String>()).toList(), linked.toArray(arrayOfNulls<String>(5)).toList()) }
    val colors = java.util.EnumSet.of(Color.BLUE)
    val colorsCopy = colors.clone().apply { add(Color.RED) }
    t("EnumSet.clone") { "$colors $colorsCopy" }
    val counts = java.util.EnumMap(mapOf(Color.GREEN to 1))
    val countsCopy = counts.clone().apply { put(Color.RED, 2) }
    t("EnumMap.clone") { "$counts $countsCopy" }

    val sb = StringBuilder("ab")
    sb.repeat("xy", 2)
    sb.repeat('z'.code, 3)
    t("StringBuilder.repeat") { sb }
    t("StringBuilder.repeat negative") { StringBuilder().repeat("a", -1) }
}
