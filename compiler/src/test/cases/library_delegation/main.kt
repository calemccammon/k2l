// Delegating the library interfaces: every member is forwarded to the delegate, overrides win, and the library's
// functions, for loops, printing and equality work on the delegating objects.

class Counting<T>(private val cmp: Comparator<T>) : Comparator<T> by cmp {
    var calls = 0

    override fun compare(a: T, b: T): Int {
        calls++
        return cmp.compare(a, b)
    }
}

class Plain<T>(cmp: Comparator<T>) : Comparator<T> by cmp

class Logging(val inner: MutableList<Int>) : MutableList<Int> by inner {
    val log = mutableListOf<String>()

    override fun add(element: Int): Boolean {
        log += "add $element"
        return inner.add(element)
    }
}

class ReadOnly(list: List<String>) : List<String> by list {
    fun shout() = joinToString(" ") { it.uppercase() }
}

class Tagged(private val m: MutableMap<String, Int>) : MutableMap<String, Int> by m {
    override fun put(key: String, value: Int): Int? = m.put(key.lowercase(), value)
}

class Lookup(m: Map<String, Int>) : Map<String, Int> by m

class Unique(s: Set<Int>) : Set<Int> by s

class Bag(c: Collection<String>) : Collection<String> by c

class Wrap(it: Iterable<Int>) : Iterable<Int> by it

class Steps(it: Iterator<Int>) : Iterator<Int> by it

class Name(s: String) : CharSequence by s

class Job(r: Runnable) : Runnable by r

class Twice(f: (Int) -> Int) : (Int) -> Int by f

fun comparators() {
    val words = listOf("ccc", "a", "bb", "dddd")
    val byLength = Counting<String>(compareBy { it.length })
    println("${words.sortedWith(byLength)} ${byLength.calls > 0} ${byLength.compare("aa", "b")}")
    println(words.sortedWith(byLength.reversed()))
    val natural = Plain<String>(naturalOrder())
    println("${words.sortedWith(natural)} ${natural.compare("a", "b")} ${words.maxWith(natural)} ${(natural as Any) is Comparator<*>}")
    val tree = sortedSetOf(Plain<Int>(reverseOrder()), 3, 1, 2)
    println(tree)
}

fun lists() {
    val l = Logging(mutableListOf(3, 1, 2))
    l.add(4)
    l += 5
    l.addAll(listOf(6, 7))
    l.add(0, 9)
    println("${l.log} ${l.inner} ${l.size} ${l[0]} ${l.indexOf(2)} ${l.contains(7)} ${l.isEmpty()}")
    l.removeAt(0)
    l.remove(7)
    l[0] = 30
    l.sort()
    println("${l.inner} ${l.first()} ${l.last()} ${l.sum()} ${l.map { it * 2 }} ${l.filter { it > 3 }} ${l.joinToString("-")}")
    var total = 0
    for (x in l) total += x
    println("loop $total ${l == listOf(1, 2, 4, 5, 6, 30)} ${listOf(1, 2, 4, 5, 6, 30) == l} ${l.hashCode() == l.inner.hashCode()}")
    println("${l.toString().startsWith("Logging@")} ${l.subList(1, 3)} ${l.reversed()} ${l.sortedDescending()} ${l.indices}")
    val it = l.listIterator()
    it.next()
    it.remove()
    println("${l.inner} ${l.removeIf { it > 10 }} ${l.inner} ${l.log}")
    val r = ReadOnly(listOf("a", "b", "c"))
    println("${r.shout()} ${r.size} ${r[1]} ${r.lastIndexOf("c")} ${r.containsAll(listOf("a", "c"))} ${r.asReversed()} ${r.zip(r.drop(1))}")
    println("${r == listOf("a", "b", "c")} ${r.toString().startsWith("ReadOnly@")} ${r.toList()} ${r.toSet()} ${r.withIndex().last()}")
}

fun maps() {
    val t = Tagged(linkedMapOf("x" to 1))
    t["Y"] = 2
    t.put("Z", 3)
    t.putAll(mapOf("W" to 4))
    println("${t.size} ${t["y"]} ${t.keys} ${t.values} ${t.containsKey("z")} ${t.containsValue(4)} ${"x" in t}")
    for ((k, v) in t) print("$k=$v ")
    println()
    t.remove("x")
    println("${t.entries.map { it.key + it.value }} ${t.toString().startsWith("Tagged@")} ${t == mapOf("y" to 2, "z" to 3, "W" to 4)}")
    println("${t.getOrDefault("q", 0)} ${t.getOrPut("q") { 7 }} ${t.filterValues { it > 3 }} ${t.maxBy { it.value }.key} ${t.toList()}")
    val m = Lookup(mapOf("a" to 1, "b" to 2))
    println("${m["a"]} ${m.getValue("b")} ${m.isEmpty()} ${m.mapValues { it.value * 10 }} ${m.count()} ${m.any { it.value > 1 }}")
}

fun others() {
    val u = Unique(setOf(3, 1, 2))
    println("${u.size} ${2 in u} ${u.sorted()} ${u == setOf(1, 2, 3)} ${u.toString().startsWith("Unique@")} ${u.intersect(setOf(2, 9))}")
    val b = Bag(listOf("x", "y"))
    println("${b.size} ${"y" in b} ${b.joinToString()} ${b.isEmpty()} ${b.toList()}")
    val w = Wrap(1..4)
    println("${w.map { it * it }} ${w.sum()} ${w.toList()} ${w.count()} ${w.first()}")
    var s = 0
    for (x in w) s += x
    val steps = Steps(listOf(5, 6).iterator())
    println("$s ${steps.hasNext()} ${steps.next()} ${steps.next()} ${steps.hasNext()}")
    for (x in Steps(listOf(7, 8).iterator())) print("$x ")
    println()
    val n = Name("hello")
    println("${n.length} ${n[1]} ${n.subSequence(1, 3)} ${n.toString().startsWith("Name@")} ${n.startsWith("he")} ${'l' in n} ${n.count { it == 'l' }}")
    val j = Job { println("job ran") }
    j.run()
    val jobs: List<Runnable> = listOf(j)
    jobs.forEach { it.run() }
    val twice = Twice { it * 2 }
    println("${twice(21)} ${listOf(1, 2).map(twice)}")
}

class Sized(private val items: MutableSet<String>) : MutableSet<String> by items {
    override val size: Int get() = items.size * 10

    override fun add(element: String): Boolean = items.add(element.trim())
}

class Pool(c: MutableCollection<Int>) : MutableCollection<Int> by c

class Draining(private val source: MutableIterator<Int>) : MutableIterator<Int> by source

data class Version(val n: Int) : Comparable<Version> {
    override fun compareTo(other: Version) = n.compareTo(other.n)
}

class Release(v: Version, val label: String) : Comparable<Version> by v

class Pairing(e: Map.Entry<String, Int>) : Map.Entry<String, Int> by e

class Lines(s: Sequence<String>) : Sequence<String> by s

class Window(private val data: List<Int>, private val from: Int) : List<Int> {
    override val size: Int get() = data.size - from

    override fun get(index: Int): Int = data[from + index]

    override fun isEmpty() = size == 0

    override fun contains(element: Int) = indexOf(element) >= 0

    override fun containsAll(elements: Collection<Int>) = elements.all { contains(it) }

    override fun indexOf(element: Int) = (0 until size).firstOrNull { get(it) == element } ?: -1

    override fun lastIndexOf(element: Int) = (size - 1 downTo 0).firstOrNull { get(it) == element } ?: -1

    override fun iterator(): Iterator<Int> = (0 until size).map { get(it) }.iterator()

    override fun listIterator(): ListIterator<Int> = (0 until size).map { get(it) }.listIterator()

    override fun listIterator(index: Int): ListIterator<Int> = (0 until size).map { get(it) }.listIterator(index)

    override fun subList(fromIndex: Int, toIndex: Int): List<Int> = (fromIndex until toIndex).map { get(it) }
}

class Layer(w: List<Int>) : List<Int> by w

fun more() {
    val s = Sized(mutableSetOf("a"))
    s.add(" b ")
    s.addAll(listOf("c", "a"))
    println("${s.size} ${s.count()} ${s.toList()} ${s.contains("b")} ${s.isEmpty()} ${s.remove("a")} ${s.toSortedSet()}")
    val p = Pool(mutableListOf(1, 2, 3))
    p.add(4)
    p.removeAll { it % 2 == 0 }
    println("${p.size} ${p.toList()} ${p.retainAll(listOf(3))} ${p.toList()}")
    p.clear()
    println("${p.isEmpty()} ${p.size}")
    val backing = mutableListOf(1, 2, 3)
    val d = Draining(backing.iterator())
    while (d.hasNext()) if (d.next() == 2) d.remove()
    println(backing)
    val r = Release(Version(3), "three")
    println("${r > Version(2)} ${r < Version(3)} ${r.compareTo(Version(4))} ${r.label}")
    val e = Pairing(mapOf("k" to 5).entries.first())
    println("${e.key} ${e.value} ${listOf(e).associate { it.key to it.value }}")
    val lines = Lines(sequenceOf("x", "yy", "zzz"))
    println("${lines.map { it.length }.toList()} ${lines.filter { it.length > 1 }.count()} ${lines.first()}")
    for (line in lines) print("$line ")
    println()
    val layer = Layer(Window(listOf(1, 2, 3, 4), 1))
    println("${layer.size} ${layer[0]} ${layer.toList()} ${layer.indexOf(4)} ${layer.subList(0, 2)} ${layer.sum()} ${layer.max()}")
    var total = 0
    for (x in layer) total += x
    val anonymous = object : List<Int> by listOf(7, 8) {}
    println("$total ${anonymous.size} ${anonymous.last()} ${anonymous.map { it + 1 }}")
    println("${Pair.size} ${Pair.toList()} ${Pair.last()} ${Words.size} ${Words.sorted()} ${Words.first()}")
}

class Traced(private val inner: List<Int>) : List<Int> by inner {
    val log = mutableListOf<String>()

    override fun iterator(): Iterator<Int> {
        log += "iterator"
        return inner.iterator()
    }

    override fun get(index: Int): Int {
        log += "get $index"
        return inner[index]
    }
}

fun traced() {
    val t = Traced(listOf(4, 5, 6))
    for (x in t) print("$x ")
    t.forEach { print("$it ") }
    println(t.log)
    t.log.clear()
    println("${t.joinToString()} ${t.map { it * 2 }} ${t.sum()} ${t.toList()} ${t.contains(5)} ${t.log}")
    t.log.clear()
    println("${t.first()} ${t.last()} ${t[1]} ${t.getOrNull(2)} ${t.log}")
}

object Pair : AbstractList<Int>() {
    override val size: Int get() = 2

    override fun get(index: Int) = index * 10
}

object Words : List<String> by listOf("b", "a")

fun main() {
    comparators()
    lists()
    maps()
    others()
    more()
    traced()
}
