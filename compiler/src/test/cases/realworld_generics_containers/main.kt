package generics.containers

// Generic containers of a small library: a typed heterogeneous map keyed by Key<T>, an LRU cache, a bounded priority
// queue ordered by a Comparator, and a trie of values.

class Key<T : Any>(val name: String, val default: T? = null) {
    override fun toString() = "Key($name)"
}

class TypedMap {
    private val values = LinkedHashMap<Key<*>, Any>()

    operator fun <T : Any> set(key: Key<T>, value: T) {
        values[key] = value
    }

    @Suppress("UNCHECKED_CAST")
    operator fun <T : Any> get(key: Key<T>): T? = values[key] as T? ?: key.default

    fun <T : Any> require(key: Key<T>): T = get(key) ?: throw NoSuchElementException("missing $key")

    fun <T : Any> update(key: Key<T>, f: (T?) -> T): T = f(get(key)).also { set(key, it) }

    operator fun contains(key: Key<*>) = key in values

    val size get() = values.size

    override fun toString() = values.entries.joinToString(", ", "{", "}") { (k, v) -> "${k.name}=$v" }
}

class LruCache<K, V>(private val capacity: Int, private val onEvict: (K, V) -> Unit = { _, _ -> }) {
    private val map = LinkedHashMap<K, V>()
    var hits = 0
        private set
    var misses = 0
        private set

    init {
        require(capacity > 0) { "capacity must be positive, was $capacity" }
    }

    operator fun get(key: K): V? {
        val v = map.remove(key) ?: run {
            misses++
            return null
        }
        hits++
        map[key] = v
        return v
    }

    operator fun set(key: K, value: V) {
        map.remove(key)
        map[key] = value
        while (map.size > capacity) {
            val eldest = map.entries.first()
            map.remove(eldest.key)
            onEvict(eldest.key, eldest.value)
        }
    }

    fun getOrPut(key: K, compute: (K) -> V): V = get(key) ?: compute(key).also { set(key, it) }

    val keys: List<K> get() = map.keys.toList()

    override fun toString() = "LRU${map.entries.map { "${it.key}:${it.value}" }} hits=$hits misses=$misses"
}

class BoundedQueue<T>(private val limit: Int, private val comparator: Comparator<in T>) : Iterable<T> {
    private val heap = ArrayList<T>()

    val size get() = heap.size

    /** Keeps the [limit] greatest elements: offering below the minimum of a full queue is rejected. */
    fun offer(item: T): Boolean {
        if (heap.size < limit) {
            heap += item
            siftUp(heap.lastIndex)
            return true
        }
        if (comparator.compare(item, heap[0]) <= 0) return false
        heap[0] = item
        siftDown(0)
        return true
    }

    fun peek(): T? = heap.firstOrNull()

    fun poll(): T? {
        if (heap.isEmpty()) return null
        val top = heap[0]
        val last = heap.removeAt(heap.lastIndex)
        if (heap.isNotEmpty()) {
            heap[0] = last
            siftDown(0)
        }
        return top
    }

    private fun siftUp(start: Int) {
        var i = start
        while (i > 0) {
            val parent = (i - 1) / 2
            if (comparator.compare(heap[i], heap[parent]) >= 0) break
            heap[i] = heap[parent].also { heap[parent] = heap[i] }
            i = parent
        }
    }

    private fun siftDown(start: Int) {
        var i = start
        while (true) {
            val l = 2 * i + 1
            val r = l + 1
            var smallest = i
            if (l < heap.size && comparator.compare(heap[l], heap[smallest]) < 0) smallest = l
            if (r < heap.size && comparator.compare(heap[r], heap[smallest]) < 0) smallest = r
            if (smallest == i) return
            heap[i] = heap[smallest].also { heap[smallest] = heap[i] }
            i = smallest
        }
    }

    fun drainDescending(): List<T> = generateSequence { poll() }.toList().asReversed()

    override fun iterator(): Iterator<T> = heap.sortedWith(comparator).iterator()
}

class Trie<V> {
    private class Node<V> {
        val children = sortedMapOf<Char, Node<V>>()
        var value: V? = null
        var terminal = false
    }

    private val root = Node<V>()
    var size = 0
        private set

    operator fun set(word: String, value: V) {
        var node = root
        for (c in word) node = node.children.getOrPut(c) { Node() }
        if (!node.terminal) size++
        node.terminal = true
        node.value = value
    }

    operator fun get(word: String): V? = find(word)?.takeIf { it.terminal }?.value

    private fun find(prefix: String): Node<V>? {
        var node = root
        for (c in prefix) node = node.children[c] ?: return null
        return node
    }

    fun withPrefix(prefix: String): List<Pair<String, V>> {
        val out = mutableListOf<Pair<String, V>>()
        fun walk(node: Node<V>, path: StringBuilder) {
            @Suppress("UNCHECKED_CAST")
            if (node.terminal) out += path.toString() to node.value as V
            for ((c, child) in node.children) {
                path.append(c)
                walk(child, path)
                path.setLength(path.length - 1)
            }
        }
        find(prefix)?.let { walk(it, StringBuilder(prefix)) }
        return out
    }

    fun longestPrefixOf(text: String): String? {
        var node = root
        var best: String? = null
        for ((i, c) in text.withIndex()) {
            node = node.children[c] ?: break
            if (node.terminal) best = text.substring(0, i + 1)
        }
        return best
    }
}

data class Task(val name: String, val priority: Int, val cost: Double)

val PORT = Key("port", 8080)
val HOST = Key<String>("host")
val TAGS = Key<List<String>>("tags")
val RETRIES = Key("retries", 3)

fun main() {
    println("== typed map")
    val config = TypedMap()
    println("port=${config[PORT]} host=${config[HOST]} size=${config.size}")
    config[HOST] = "localhost"
    config[TAGS] = listOf("web", "api")
    config[PORT] = 9000
    println("host length=${config.require(HOST).length} tags=${config[TAGS]?.joinToString("|")}")
    println("retries=${config.update(RETRIES) { (it ?: 0) + 1 }} then ${config.update(RETRIES) { it!! * 10 }}")
    println("contains HOST=${HOST in config} contains Key(host)=${Key<String>("host") in config}")
    println(config)
    try {
        config.require(Key<Int>("timeout"))
    } catch (e: NoSuchElementException) {
        println("error: ${e.message}")
    }

    println("== lru")
    val evicted = mutableListOf<String>()
    val cache = LruCache<String, Int>(3) { k, v -> evicted += "$k=$v" }
    for (w in "the quick brown fox jumps over the lazy dog the end".split(" ")) {
        cache.getOrPut(w) { it.length }
    }
    println(cache)
    println("evicted: $evicted")
    println("keys=${cache.keys} get(the)=${cache["the"]} get(fox)=${cache["fox"]}")
    try {
        LruCache<Int, Int>(0)
    } catch (e: IllegalArgumentException) {
        println("error: ${e.message}")
    }

    println("== bounded queue")
    val tasks = listOf(
        Task("deploy", 5, 2.5), Task("lint", 1, 0.25), Task("test", 4, 7.0), Task("docs", 2, 1.0),
        Task("bench", 4, 12.0), Task("release", 5, 0.5), Task("audit", 3, 3.25),
    )
    val top = BoundedQueue(3, compareBy<Task> { it.priority }.thenByDescending { it.cost })
    val accepted = tasks.map { t -> "${t.name}:${if (top.offer(t)) "+" else "-"}" }
    println(accepted.joinToString(" "))
    println("peek=${top.peek()?.name} ordered=${top.map { it.name }}")
    println("drained=${top.drainDescending().map { "${it.name}(${it.priority})" }} empty=${top.poll()}")
    val words = BoundedQueue<String>(4, compareBy(String::length).then(reverseOrder()))
    "kotlin lua generic variance bound star projection reified".split(" ").forEach { words.offer(it) }
    println("longest=${words.toList()}")

    println("== trie")
    val trie = Trie<Int>()
    listOf("car", "card", "care", "cart", "cat", "dog", "do").forEachIndexed { i, w -> trie[w] = i * 10 }
    trie["car"] = -1
    println("size=${trie.size} car=${trie["car"]} ca=${trie["ca"]} dog=${trie["dog"]}")
    println("car*: ${trie.withPrefix("car")}")
    println("d*: ${trie.withPrefix("d").map { (w, v) -> "$w/$v" }}")
    println("x*: ${trie.withPrefix("x")}")
    println("longest prefix of 'cartography'=${trie.longestPrefixOf("cartography")} of 'dots'=${trie.longestPrefixOf("dots")}")
    val counts = Trie<MutableList<Int>>()
    "abracadabra".windowed(3).forEachIndexed { i, gram -> (counts[gram] ?: mutableListOf<Int>().also { counts[gram] = it }) += i }
    println("trigrams: ${counts.withPrefix("").joinToString { (g, at) -> "$g@$at" }}")
}
