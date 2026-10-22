// Sets, maps, iterators and Iterables built on the library's abstract classes, and classes extending ArrayList, HashSet,
// LinkedHashSet, HashMap and LinkedHashMap with calls to the library members through `super`.

class Evens(private val limit: Int) : AbstractSet<Int>() {
    override val size: Int get() = (limit + 1) / 2

    override fun iterator(): Iterator<Int> = (0 until limit step 2).iterator()
}

class Bag : AbstractMutableCollection<String>() {
    private val items = mutableListOf<String>()

    override val size: Int get() = items.size

    override fun add(element: String): Boolean = items.add(element)

    override fun iterator(): MutableIterator<String> = items.iterator()
}

class Tags : AbstractMutableSet<String>() {
    private val items = LinkedHashSet<String>()
    var removes = 0

    override val size: Int get() = items.size

    override fun add(element: String): Boolean = items.add(element.lowercase())

    override fun iterator(): MutableIterator<String> = CountingIterator(this, items.iterator())
}

class CountingIterator(private val owner: Tags, private val inner: MutableIterator<String>) : MutableIterator<String> {
    override fun hasNext() = inner.hasNext()

    override fun next() = inner.next()

    override fun remove() {
        owner.removes++
        inner.remove()
    }
}

data class Pair2(override val key: String, override val value: Int) : Map.Entry<String, Int>

class Squares(private val n: Int) : AbstractMap<String, Int>() {
    override val entries: Set<Map.Entry<String, Int>>
        get() = (1..n).map { Pair2("k$it", it * it) }.toSet()
}

class Registry : AbstractMutableMap<String, Int>() {
    private val backing = LinkedHashMap<String, Int>()
    val log = mutableListOf<String>()

    override val entries: MutableSet<MutableMap.MutableEntry<String, Int>> get() = backing.entries

    override fun put(key: String, value: Int): Int? {
        log += "put($key)"
        return backing.put(key, value)
    }
}

class Countdown(private var from: Int) : AbstractIterator<Int>() {
    override fun computeNext() {
        if (from < 0) done() else setNext(from--)
    }
}

class Faulty : AbstractIterator<Int>() {
    private var n = 0

    override fun computeNext() {
        n++
        if (n == 2) error("boom")
        setNext(n)
    }
}

class Words(private val text: String) : Iterable<String> {
    override fun iterator(): Iterator<String> = text.split(" ").iterator()
}

class Stack<T> : ArrayList<T>() {
    var pushes = 0

    override fun add(element: T): Boolean {
        pushes++
        return super.add(element)
    }

    fun peek(): T = this[size - 1]

    override fun toString(): String = "Stack" + super.toString()
}

class Seeded(elements: Collection<String>) : HashSet<String>(elements) {
    override fun add(element: String): Boolean {
        println("Seeded.add($element)")
        return super.add(element)
    }
}

class InstrumentedSet : HashSet<String>() {
    var attempts = 0

    override fun add(element: String): Boolean {
        attempts++
        return super.add(element)
    }

    override fun addAll(elements: Collection<String>): Boolean {
        attempts += elements.size
        return super.addAll(elements)
    }
}

class Ordered : LinkedHashSet<Int>() {
    override fun remove(element: Int): Boolean = super.remove(element * 2)
}

class DefaultMap : HashMap<String, Int>() {
    override fun get(key: String): Int = super.get(key) ?: 0
}

class Lru(private val capacity: Int) : LinkedHashMap<String, Int>() {
    override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Int>?): Boolean = size > capacity
}

class Copied(source: Map<String, Int>) : LinkedHashMap<String, Int>(source) {
    var puts = 0

    override fun put(key: String, value: Int): Int? {
        puts++
        return super.put(key, value)
    }
}

fun sets() {
    val e = Evens(9)
    println("$e ${e.size} ${4 in e} ${5 in e} ${e == setOf(0, 2, 4, 6, 8)} ${setOf(8, 6, 4, 2, 0) == e} ${e.hashCode() == setOf(0, 2, 4, 6, 8).hashCode()}")
    println("${e.map { it / 2 }} ${e.filter { it > 3 }} ${e.sum()} ${e.sortedDescending()} ${e.containsAll(listOf(2, 4))} ${(e as Any) is Set<*>}")
    var total = 0
    for (x in e) total += x
    println("loop $total ${e.first()} ${e.last()} ${e.toList()} ${e.joinToString("|")}")
    val bag = Bag()
    bag.add("b")
    bag.addAll(listOf("a", "b"))
    println("bag $bag ${bag.size} ${"a" in bag} ${bag.count { it == "b" }}")
    bag.remove("b")
    println("bag remove $bag ${bag == Bag()} ${(bag as Any) is List<*>}")
    bag.clear()
    println("bag clear $bag ${bag.isEmpty()}")
    val tags = Tags()
    tags += "Red"
    tags.addAll(listOf("GREEN", "red", "Blue"))
    println("tags $tags ${tags.size} ${"green" in tags}")
    tags.removeAll(listOf("green", "blue", "pink"))
    println("removeAll $tags removes=${tags.removes}")
    tags.addAll(listOf("x", "y", "z"))
    tags.removeAll(listOf("x"))
    tags.retainAll(setOf("red", "y"))
    println("retainAll $tags removes=${tags.removes} ${tags == setOf("y", "red")}")
}

fun maps() {
    val sq = Squares(3)
    println("$sq ${sq.size} ${sq["k2"]} ${sq["x"]} ${sq.containsKey("k3")} ${sq.containsValue(9)} ${sq.keys} ${sq.values}")
    println("${sq == mapOf("k1" to 1, "k2" to 4, "k3" to 9)} ${mapOf("k1" to 1, "k2" to 4, "k3" to 9) == sq} ${sq.isEmpty()}")
    println("${sq.map { it.key + it.value }} ${sq.filter { it.value > 1 }} ${sq.mapValues { it.value + 1 }} ${sq.maxByOrNull { it.value }?.key}")
    for ((k, v) in sq) print("$k:$v ")
    println(sq.getOrDefault("zz", -1))
    val r = Registry()
    r["a"] = 1
    r.put("b", 2)
    r.putAll(mapOf("c" to 3, "d" to 4))
    println("registry $r ${r.size} ${r["c"]} ${r.log}")
    println("remove ${r.remove("b")} ${r.remove("zz")} $r")
    println("getOrPut ${r.getOrPut("e") { 5 }} ${r.getOrPut("a") { 9 }} ${r.log}")
    r.clear()
    println("clear $r ${r.isEmpty()} ${(r as Any) is Map<*, *>}")
}

fun iterators() {
    val c = Countdown(3)
    println("${c.hasNext()} ${c.hasNext()} ${c.next()} ${c.next()}")
    val rest = mutableListOf<Int>()
    for (x in c) rest += x
    println("rest $rest ${c.hasNext()}")
    try {
        c.next()
    } catch (e: NoSuchElementException) {
        println("done ${e::class.simpleName}")
    }
    println(Countdown(4).asSequence().map { it * 2 }.toList())
    val f = Faulty()
    println("faulty ${f.next()}")
    for (step in 1..2) {
        try {
            f.hasNext()
        } catch (e: Exception) {
            println("faulty $step ${e::class.simpleName}: ${e.message}")
        }
    }
    val w = Words("the quick brown fox")
    println("${w.map { it.length }} ${w.count()} ${w.first()} ${w.sortedBy { it }} ${w.joinToString("+")}")
    for (x in w) print("$x.")
    println()
    println("${w.toString().startsWith("Words@")} ${w == Words("x")} ${(w as Any) is Iterable<*>} ${(w as Any) is Collection<*>}")
}

fun concrete() {
    val s = Stack<Int>()
    s.add(1)
    s.add(2)
    s.addAll(listOf(3, 4))
    s += 5
    println("$s ${s.peek()} ${s.size} pushes=${s.pushes} ${s.sum()} ${s.reversed()} ${s::class.simpleName} ${(s as Any) is ArrayList<*>}")
    s.removeAt(0)
    s.remove(4)
    s[0] = 20
    println("$s ${s.indexOf(3)} ${s == listOf(20, 3, 5)} ${s.contains(5)} ${s.hashCode() == listOf(20, 3, 5).hashCode()}")
    println("seeded ${Seeded(listOf("b", "a"))}")
    val i = InstrumentedSet()
    i.addAll(listOf("c", "d", "a"))
    println("$i attempts=${i.attempts} ${i.size}")
    val o = Ordered()
    o.addAll(listOf(1, 2, 3, 4))
    o.remove(2)
    println("ordered $o")
    val d = DefaultMap()
    d["x"] = 1
    println("default ${d["x"]} ${d["y"]} ${d.getValue("x")} $d")
    val lru = Lru(2)
    lru["a"] = 1
    lru["b"] = 2
    lru["a"]
    lru["c"] = 3
    println("lru $lru ${lru.keys}")
    val copy = Copied(mapOf("p" to 1, "q" to 2))
    copy.putAll(mapOf("r" to 3))
    copy["s"] = 4
    println("copied $copy puts=${copy.puts}")
}

fun main() {
    sets()
    maps()
    iterators()
    concrete()
}
