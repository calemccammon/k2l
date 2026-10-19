import java.util.Arrays
import java.util.Collections
import java.util.Random

fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: Exception) {
        println("$label: ${e::class.simpleName}: ${e.message}")
    }
}

fun sorting() {
    println("-- sorting")
    val list = mutableListOf(5, 3, 9, 1, 7, 3)
    Collections.sort(list)
    println(list)
    Collections.sort(list, Collections.reverseOrder())
    println(list)
    Collections.sort(list, compareBy { it % 4 })
    println(list)
    val words = mutableListOf("pear", "fig", "banana", "kiwi", "apple")
    Collections.sort(words)
    println(words)
    Collections.sort(words, Comparator { a, b -> a.length - b.length })
    println(words)
    Collections.sort(words, Collections.reverseOrder(Comparator { a, b -> a.length - b.length }))
    println(words)
    Collections.reverse(words)
    println(words)
    Collections.swap(words, 0, words.size - 1)
    println(words)
    attempt("swap") { Collections.swap(words, 0, 10) }
    println(Collections.binarySearch(listOf(1, 3, 5, 7, 9), 7))
    println(Collections.binarySearch(listOf(1, 3, 5, 7, 9), 4))
    println(Collections.binarySearch(listOf("a", "c", "e"), "d"))
    println(Collections.binarySearch(listOf(9, 7, 5, 3, 1), 7, Collections.reverseOrder()))
}

fun queries() {
    println("-- queries")
    val list = listOf(4, 8, 15, 16, 23, 42, 8)
    println(Collections.max(list))
    println(Collections.min(list))
    println(Collections.max(list, Collections.reverseOrder()))
    println(Collections.max(listOf("b", "abc", "zz"), compareBy { it.length }))
    println(Collections.frequency(list, 8))
    println(Collections.frequency(list, 99))
    println(Collections.frequency(listOf("a", "b", "a", null), null))
    println(Collections.max(setOf(3, 1, 2)))
    println(Collections.disjoint(listOf(1, 2), listOf(3, 4)))
    println(Collections.disjoint(listOf(1, 2), listOf(2, 4)))
    attempt("emptyMax") { Collections.max(emptyList<Int>()) }
    attempt("emptyMin") { Collections.min(listOf<String>()) }
}

fun mutations() {
    println("-- mutations")
    val list = mutableListOf(1, 2, 3, 4, 5)
    Collections.rotate(list, 2)
    println(list)
    Collections.rotate(list, -1)
    println(list)
    Collections.rotate(list, 7)
    println(list)
    Collections.fill(list, 0)
    println(list)
    val target = mutableListOf(0, 0, 0, 0)
    Collections.copy(target, listOf(7, 8))
    println(target)
    attempt("copy") { Collections.copy(listOf(1).toMutableList(), listOf(1, 2)) }
    println(Collections.replaceAll(target, 0, 9))
    println(target)
    println(Collections.addAll(target, 1, 2, 3))
    println(target)
    val set = mutableSetOf(1, 2)
    println(Collections.addAll(set, 2, 3))
    println(set)
    val shuffled = (1..10).toMutableList()
    Collections.shuffle(shuffled, Random(42))
    println(shuffled)
    Collections.shuffle(shuffled, Random(7))
    println(shuffled)
    Collections.shuffle(shuffled)
    println(shuffled.sorted())
}

fun factories() {
    println("-- factories")
    println(Collections.nCopies(3, "ab"))
    println(Collections.nCopies(0, 1))
    println(Collections.emptyList<Int>())
    println(Collections.emptySet<String>())
    println(Collections.emptyMap<String, Int>())
    println(Collections.singletonList(5))
    println(Collections.singleton("x"))
    println(Collections.singletonMap("k", 1))
    println(Collections.nCopies(3, 1).size)
    println(Collections.nCopies(2, "z").joinToString("+"))
    attempt("nCopies") { Collections.nCopies(-1, 0) }
    val source = mutableListOf(1, 2, 3)
    val view = Collections.unmodifiableList(source)
    println(view)
    println(view.size)
    println(view.map { it * 2 })
    attempt("add") { view.add(4) }
    attempt("set") { (view as MutableList<Int>).set(0, 9) }
    attempt("remove") { (view as MutableList<Int>).removeAt(0) }
    attempt("sort") { Collections.sort(view as MutableList<Int>) }
    attempt("emptyAdd") { (Collections.emptyList<Int>() as MutableList<Int>).add(1) }
    attempt("single") { (Collections.singletonList(1) as MutableList<Int>).add(1) }
    val set = Collections.unmodifiableSet(mutableSetOf(3, 1, 2))
    println(set)
    println(3 in set)
    attempt("setAdd") { (set as MutableSet<Int>).add(4) }
    val map = Collections.unmodifiableMap(mutableMapOf("a" to 1, "b" to 2))
    println(map)
    println(map["a"])
    attempt("mapPut") { (map as MutableMap<String, Int>).put("c", 3) }
    println(Collections.synchronizedList(mutableListOf(1, 2)))
}

fun arrays() {
    println("-- arrays")
    val ints = intArrayOf(5, 2, 8, 1, 9, 3)
    Arrays.sort(ints)
    println(Arrays.toString(ints))
    val part = intArrayOf(9, 8, 7, 6, 5, 4)
    Arrays.sort(part, 1, 4)
    println(Arrays.toString(part))
    try {
        Arrays.sort(part, 4, 9)
    } catch (e: IndexOutOfBoundsException) {
        println("sortRange: ${e.message}")
    }
    attempt("sortRange2") { Arrays.sort(part, 3, 1) }
    val strings = arrayOf("pear", "fig", "banana")
    Arrays.sort(strings)
    println(Arrays.toString(strings))
    Arrays.sort(strings, Comparator { a, b -> b.length - a.length })
    println(Arrays.toString(strings))
    val filled = IntArray(5)
    Arrays.fill(filled, 7)
    println(Arrays.toString(filled))
    Arrays.fill(filled, 1, 3, 0)
    println(Arrays.toString(filled))
    println(Arrays.toString(Arrays.copyOf(ints, 3)))
    println(Arrays.toString(Arrays.copyOf(ints, 9)))
    println(Arrays.toString(Arrays.copyOfRange(ints, 2, 4)))
    println(Arrays.toString(Arrays.copyOfRange(ints, 4, 9)))
    println(Arrays.toString(Arrays.copyOf(strings, 5)))
    println(Arrays.toString(Arrays.copyOf(booleanArrayOf(true), 3)))
    attempt("copyRange") { Arrays.copyOfRange(ints, 5, 2) }
    println(Arrays.toString(null as IntArray?))
    println(Arrays.equals(intArrayOf(1, 2), intArrayOf(1, 2)))
    println(Arrays.equals(intArrayOf(1, 2), intArrayOf(2, 1)))
    println(Arrays.equals(intArrayOf(1, 2), intArrayOf(1, 2, 3)))
    println(Arrays.hashCode(intArrayOf(1, 2, 3)))
    println(Arrays.hashCode(arrayOf("a", "b")))
    println(Arrays.hashCode(null as IntArray?))
    println(Arrays.deepToString(arrayOf(intArrayOf(1, 2), intArrayOf(3))))
    println(Arrays.deepToString(arrayOf(arrayOf(1, 2), arrayOf(3, arrayOf(4)))))
    val sorted = intArrayOf(1, 3, 5, 7, 9, 11)
    println(Arrays.binarySearch(sorted, 7))
    println(Arrays.binarySearch(sorted, 4))
    println(Arrays.binarySearch(sorted, 2, 5, 9))
    println(Arrays.binarySearch(sorted, 2, 5, 11))
    println(Arrays.binarySearch(arrayOf("a", "c", "e"), "c"))
    val squares = IntArray(5)
    Arrays.setAll(squares) { it * it }
    println(Arrays.toString(squares))
    val list = Arrays.asList(3, 1, 2)
    println(list)
    list[0] = 10
    println(list)
    println(list.sorted())
    Collections.sort(list)
    println(list)
    attempt("asListAdd") { list.add(4) }
    attempt("asListRemove") { list.removeAt(0) }
    println(Arrays.asList("x", "y").size)
    println(Arrays.asList(*arrayOf(1, 2, 3)))
}

fun main() {
    sorting()
    queries()
    mutations()
    factories()
    arrays()
}
