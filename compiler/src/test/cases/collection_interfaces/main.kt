// Classes implementing List, Collection and Map directly, generic and inherited collection subclasses, super calls into
// the abstract classes, and JDK helpers on them.

class Window(private val data: IntArray, private val from: Int, private val to: Int) : List<Int> {
    override val size: Int get() = to - from

    override fun get(index: Int): Int = data[from + index]

    override fun isEmpty(): Boolean = size == 0

    override fun contains(element: Int): Boolean = indexOf(element) >= 0

    override fun containsAll(elements: Collection<Int>): Boolean = elements.all { contains(it) }

    override fun indexOf(element: Int): Int = (0 until size).firstOrNull { get(it) == element } ?: -1

    override fun lastIndexOf(element: Int): Int = (size - 1 downTo 0).firstOrNull { get(it) == element } ?: -1

    override fun iterator(): Iterator<Int> = listIterator()

    override fun listIterator(): ListIterator<Int> = listIterator(0)

    override fun listIterator(index: Int): ListIterator<Int> = data.copyOfRange(from, to).toList().listIterator(index)

    override fun subList(fromIndex: Int, toIndex: Int): List<Int> = Window(data, from + fromIndex, from + toIndex)
}

class Numbers(private val count: Int) : Collection<Int> {
    override val size: Int get() = count

    override fun isEmpty() = count == 0

    override fun contains(element: Int) = element in 1..count

    override fun containsAll(elements: Collection<Int>) = elements.all { it in this }

    override fun iterator(): Iterator<Int> = (1..count).iterator()
}

class Constants : Map<String, Double> {
    private val backing = linkedMapOf("pi" to 3.14, "e" to 2.72)

    override val entries: Set<Map.Entry<String, Double>> get() = backing.entries
    override val keys: Set<String> get() = backing.keys
    override val values: Collection<Double> get() = backing.values
    override val size: Int get() = backing.size

    override fun isEmpty() = backing.isEmpty()

    override fun containsKey(key: String) = key in backing

    override fun containsValue(value: Double) = value in backing.values

    override fun get(key: String): Double? = backing[key]
}

class Matrix(private val rows: Int, private val cols: Int) : AbstractList<List<Int>>() {
    override val size: Int get() = rows

    override fun get(index: Int): List<Int> = List(cols) { index * cols + it }

    override fun toString(): String = "Matrix" + super.toString()

    fun find(row: List<Int>): Int = super.indexOf(row)
}

class Bounded<T>(private val max: Int) : ArrayList<T>() {
    val rejected = mutableListOf<T>()

    init {
        require(max > 0)
    }

    override fun add(element: T): Boolean {
        if (size >= max) {
            rejected += element
            return false
        }
        return super.add(element)
    }
}

open class Base : ArrayList<Int>() {
    fun total() = sum()
}

class Derived(val extra: Int) : Base() {
    override fun add(element: Int): Boolean = super.add(element + extra)
}

class Snapshot(source: List<Int>) : ArrayList<Int>(source)

class Sized : HashMap<Int, String>(64)

class Unsized : HashMap<Int, String>()

class Shelf : AbstractMutableList<String>() {
    private val items = mutableListOf<String>()
    var sets = 0

    override val size get() = items.size

    override fun get(index: Int) = items[index]

    override fun set(index: Int, element: String): String {
        sets++
        return items.set(index, element)
    }

    override fun add(index: Int, element: String) = items.add(index, element)

    override fun removeAt(index: Int) = items.removeAt(index)
}

fun interfaces() {
    val w = Window(intArrayOf(5, 6, 7, 8, 9), 1, 4)
    println("${w.toString().startsWith("Window@")} ${w.size} ${w[1]} ${w.indexOf(8)} ${7 in w} ${w.subList(1, 3).toList()} ${w.map { it * 2 }} ${w == listOf(6, 7, 8)}")
    println("${w.sum()} ${w.reversed()} ${w.last()} ${w.containsAll(listOf(6, 8))} ${w.listIterator(1).next()} ${w.joinToString()}")
    var t = 0
    for (x in w) t += x
    println("loop $t ${w.toString() == "[6, 7, 8]"} ${w.hashCode() == listOf(6, 7, 8).hashCode()}")
    val n = Numbers(4)
    println("${n.toString().startsWith("Numbers@")} ${n.size} ${3 in n} ${n.filter { it % 2 == 0 }} ${n.toList()} ${n.max()} ${n == Numbers(4)}")
    val c = Constants()
    println("${"$c".startsWith("Constants@")} ${c["pi"]} ${c.keys} ${c.values} ${c.size} ${c.containsKey("e")} ${c.map { it.key }} ${c == mapOf("pi" to 3.14, "e" to 2.72)}")
    for ((k, v) in c) print("$k=$v;")
    println()
}

fun subclasses() {
    val m = Matrix(3, 2)
    println("$m ${m[2]} ${m.find(listOf(2, 3))} ${m.flatten()} ${m.map { it.sum() }}")
    val b = Bounded<String>(2)
    b.add("x")
    b.add("y")
    b.add("z")
    b.addAll(listOf("p", "q"))
    println("bounded $b rejected=${b.rejected} ${b.size}")
    val d = Derived(100)
    d.add(1)
    d += 2
    println("derived $d ${d.total()} ${d.extra} ${d::class.simpleName}")
    val s = Snapshot(listOf(3, 1, 2))
    s.sort()
    println("snapshot $s ${s.size}")
    val sized = Sized()
    val unsized = Unsized()
    for (k in listOf(40, 3, 17, 64, 1)) {
        sized[k] = "v$k"
        unsized[k] = "v$k"
    }
    println("sized ${sized.keys} unsized ${unsized.keys}")
    val shelf = Shelf()
    shelf.addAll(listOf("c", "a", "b"))
    shelf.sort()
    println("shelf $shelf sets=${shelf.sets}")
    shelf.reverse()
    shelf.replaceAll { it.uppercase() }
    println("reverse/replaceAll $shelf ${shelf.sets > 0}")
    shelf.shuffle(kotlin.random.Random(4))
    println("shuffle ${shelf.sorted()} ${shelf.size}")
    shelf.removeIf { it == "A" }
    shelf.add(0, "Z")
    println("removeIf/add $shelf ${shelf.toMutableList().apply { add("!") }} ${shelf.indices}")
    for (i in shelf.indices) shelf[i] = shelf[i] + i
    println("indices $shelf")
}

fun main() {
    interfaces()
    subclasses()
}
