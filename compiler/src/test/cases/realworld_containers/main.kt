package containers

// A generic container library: variance, bounded type parameters, reified helpers, iterators and operators.

interface Source<out T> : Iterable<T> {
    val size: Int
    operator fun get(index: Int): T
    fun isEmpty() = size == 0

    override fun iterator(): Iterator<T> = object : Iterator<T> {
        private var i = 0
        override fun hasNext() = i < size
        override fun next(): T = if (hasNext()) get(i++) else throw NoSuchElementException("index $i of $size")
    }
}

interface Sink<in T> {
    fun put(item: T)
}

class Vec<T>(initialCapacity: Int = 4) : Source<T>, Sink<T> {
    private var items = arrayOfNulls<Any?>(initialCapacity)
    override var size = 0
        private set
    var growths = 0
        private set

    override fun get(index: Int): T {
        if (index !in 0 until size) throw IndexOutOfBoundsException("Index $index out of bounds for length $size")
        @Suppress("UNCHECKED_CAST")
        return items[index] as T
    }

    operator fun set(index: Int, value: T) {
        get(index)
        items[index] = value
    }

    override fun put(item: T) {
        if (size == items.size) {
            items = items.copyOf(items.size * 2)
            growths++
        }
        items[size++] = item
    }

    operator fun plusAssign(item: T) = put(item)

    operator fun contains(item: T) = indexOf(item) >= 0

    fun indexOf(item: T): Int {
        for (i in 0 until size) if (items[i] == item) return i
        return -1
    }

    fun removeAt(index: Int): T {
        val old = get(index)
        for (i in index until size - 1) items[i] = items[i + 1]
        items[--size] = null
        return old
    }

    inline fun <R> mapTo(transform: (T) -> R): Vec<R> {
        val out = Vec<R>(maxOf(size, 1))
        for (x in this) out.put(transform(x))
        return out
    }

    override fun toString() = joinToString(", ", "Vec[", "]")

    companion object {
        fun <T> of(vararg xs: T): Vec<T> = Vec<T>(xs.size.coerceAtLeast(1)).apply { xs.forEach { put(it) } }
    }
}

fun <T> Sink<T>.putAll(items: Iterable<T>) = items.forEach { put(it) }

fun <T : Comparable<T>> Source<T>.maxOrNull(): T? {
    var best: T? = null
    for (x in this) if (best == null || x > best) best = x
    return best
}

fun copy(from: Source<Number>, to: Sink<Any>) {
    for (x in from) to.put(x)
}

inline fun <reified R> Source<*>.only(): List<R> = filterIsInstance<R>()

inline fun <reified T : Any> Iterable<Any?>.countOf(): Int = count { it is T }

class Matrix(val rows: Int, val cols: Int, init: (Int, Int) -> Double = { _, _ -> 0.0 }) {
    private val data = DoubleArray(rows * cols) { init(it / cols, it % cols) }

    operator fun get(r: Int, c: Int) = data[r * cols + c]
    operator fun set(r: Int, c: Int, v: Double) {
        data[r * cols + c] = v
    }

    operator fun times(o: Matrix): Matrix {
        require(cols == o.rows) { "shape mismatch ${rows}x$cols * ${o.rows}x${o.cols}" }
        return Matrix(rows, o.cols) { r, c -> (0 until cols).sumOf { this[r, it] * o[it, c] } }
    }

    operator fun invoke(r: Int) = Row(r)

    inner class Row(val r: Int) : Iterable<Double> {
        override fun iterator() = (0 until cols).map { this@Matrix[r, it] }.iterator()
        override fun toString() = joinToString(" ", "(", ")") { "%.1f".format(it) }
    }

    override fun toString() = (0 until rows).joinToString("\n") { this(it).toString() }
}

class Cache<K, V : Any>(private val capacity: Int, private val loader: (K) -> V) {
    private val entries = LinkedHashMap<K, V>()
    var hits = 0
    var misses = 0

    operator fun get(key: K): V {
        entries.remove(key)?.let {
            hits++
            entries[key] = it
            return it
        }
        misses++
        val value = loader(key)
        entries[key] = value
        if (entries.size > capacity) entries.remove(entries.keys.first())
        return value
    }

    val keys: List<K> get() = entries.keys.toList()
}

class Graph<N> {
    private val edges = mutableMapOf<N, MutableSet<N>>()

    fun edge(a: N, b: N) {
        edges.getOrPut(a, ::linkedSetOf).add(b)
        edges.getOrPut(b) { linkedSetOf() }
    }

    fun bfs(start: N): List<N> {
        val seen = linkedSetOf(start)
        val queue = ArrayDeque(listOf(start))
        while (queue.isNotEmpty()) {
            val n = queue.removeFirst()
            for (m in edges[n].orEmpty()) if (seen.add(m)) queue.addLast(m)
        }
        return seen.toList()
    }

    fun topo(): List<N> {
        val inDegree = edges.keys.associateWith { 0 }.toMutableMap()
        edges.values.flatten().forEach { inDegree[it] = inDegree.getValue(it) + 1 }
        val ready = inDegree.filterValues { it == 0 }.keys.toMutableList()
        val out = mutableListOf<N>()
        while (ready.isNotEmpty()) {
            val n = ready.removeAt(0)
            out += n
            for (m in edges.getValue(n)) {
                inDegree[m] = inDegree.getValue(m) - 1
                if (inDegree[m] == 0) ready += m
            }
        }
        check(out.size == edges.size) { "cycle detected" }
        return out
    }
}

data class Version(val major: Int, val minor: Int) : Comparable<Version> {
    override fun compareTo(other: Version) = compareValuesBy(this, other, Version::major, Version::minor)
    override fun toString() = "$major.$minor"
}

fun main() {
    val v = Vec<Int>(1)
    v.putAll(listOf(5, 3, 8, 1))
    v += 9
    println("$v size=${v.size} growths=${v.growths} max=${v.maxOrNull()} has8=${8 in v} has4=${4 in v}")
    v[1] = 30
    println("removed ${v.removeAt(0)} -> $v, doubled ${v.mapTo { it * 2 }}")
    try {
        v[10]
    } catch (e: IndexOutOfBoundsException) {
        println(e.message)
    }
    val it = Vec.of("a").iterator()
    it.next()
    println(runCatching { it.next() }.exceptionOrNull())

    val numbers: Vec<Number> = Vec.of(1, 2.5, 3)
    val anything = Vec<Any>()
    copy(numbers, anything)
    anything.put("text")
    val src: Source<Any> = anything
    println("${src.size} ints=${anything.only<Int>()} texts=${anything.only<CharSequence>()} strings=${src.countOf<String>()}")
    println(Vec.of(Version(1, 2), Version(1, 10), Version(0, 9)).maxOrNull())
    println(Vec<String>().isEmpty() && Vec<String>().maxOrNull() == null)

    val m = Matrix(2, 3) { r, c -> (r * 3 + c).toDouble() }
    val id = Matrix(3, 3) { r, c -> if (r == c) 1.0 else 0.0 }
    id[0, 2] = 2.0
    println(m * id)
    println(m(1).sum())
    println(runCatching { m * m }.exceptionOrNull()?.message)

    var loads = 0
    val cache = Cache<Int, String>(2) { k -> loads++; "v$k" }
    println(listOf(1, 2, 1, 3, 2, 1).map { cache[it] })
    println("hits=${cache.hits} misses=${cache.misses} loads=$loads keys=${cache.keys}")

    val g = Graph<String>()
    listOf("shirt" to "tie", "tie" to "jacket", "pants" to "shoes", "pants" to "belt", "belt" to "jacket", "shirt" to "belt")
        .forEach { (a, b) -> g.edge(a, b) }
    println(g.bfs("shirt"))
    println(g.topo())
    g.edge("jacket", "shirt")
    println(runCatching { g.topo() }.exceptionOrNull()?.message)

    val comparators = listOf<Comparator<Version>>(naturalOrder(), reverseOrder(), compareBy { it.minor })
    val versions = listOf(Version(2, 0), Version(1, 5), Version(1, 12))
    comparators.forEach { println(versions.sortedWith(it)) }
}
