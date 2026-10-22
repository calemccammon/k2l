
// Graph algorithms over a parsed edge list: topological sort with cycle detection,
// union-find and Kruskal, Floyd-Warshall, Tarjan's SCC, and a generic Dijkstra.

/** A binary min-heap by [comparator]: the part of java.util.PriorityQueue the program uses (k2l has no PriorityQueue). */
class MinQueue<T>(private val comparator: Comparator<in T>) {
    private val heap = ArrayList<T>()
    val size: Int get() = heap.size

    fun isEmpty() = heap.isEmpty()

    fun isNotEmpty() = heap.isNotEmpty()

    fun peek(): T? = heap.firstOrNull()

    fun add(item: T): Boolean {
        heap.add(item)
        var i = heap.size - 1
        while (i > 0) {
            val parent = (i - 1) / 2
            if (comparator.compare(heap[i], heap[parent]) >= 0) break
            val t = heap[i]
            heap[i] = heap[parent]
            heap[parent] = t
            i = parent
        }
        return true
    }

    fun offer(item: T) = add(item)

    operator fun plusAssign(item: T) {
        add(item)
    }

    fun poll(): T {
        if (heap.isEmpty()) throw NoSuchElementException("queue is empty")
        val top = heap[0]
        val last = heap.removeAt(heap.size - 1)
        if (heap.isNotEmpty()) {
            heap[0] = last
            var i = 0
            while (true) {
                val l = 2 * i + 1
                if (l >= heap.size) break
                val r = l + 1
                val c = if (r < heap.size && comparator.compare(heap[r], heap[l]) < 0) r else l
                if (comparator.compare(heap[c], heap[i]) >= 0) break
                val t = heap[i]
                heap[i] = heap[c]
                heap[c] = t
                i = c
            }
        }
        return top
    }
}

class Graph<T : Comparable<T>>(val directed: Boolean) {
    private val adj = sortedMapOf<T, MutableList<Pair<T, Int>>>()

    val nodes: Set<T> get() = adj.keys

    fun addEdge(from: T, to: T, weight: Int = 1) {
        adj.getOrPut(from) { mutableListOf() } += to to weight
        val back = adj.getOrPut(to) { mutableListOf() }
        if (!directed) back += from to weight
    }

    fun edges(from: T): List<Pair<T, Int>> = adj[from].orEmpty()

    fun allEdges(): List<Triple<T, T, Int>> = adj.flatMap { (from, list) -> list.map { (to, w) -> Triple(from, to, w) } }
        .filter { directed || it.first <= it.second }

    override fun toString() = adj.entries.joinToString("; ") { (k, v) -> "$k->${v.joinToString(",") { it.first.toString() }}" }
}

class CycleException(val cycle: List<String>) : Exception("cycle: ${cycle.joinToString(" -> ")}")

fun <T : Comparable<T>> Graph<T>.topoSort(): List<T> {
    val state = HashMap<T, Int>() // 1 = visiting, 2 = done
    val order = ArrayDeque<T>()
    val stack = ArrayList<T>()
    fun visit(n: T) {
        when (state[n]) {
            2 -> return
            1 -> throw CycleException((stack.subList(stack.indexOf(n), stack.size) + n).map { it.toString() })
        }
        state[n] = 1
        stack += n
        edges(n).forEach { (m, _) -> visit(m) }
        stack.removeAt(stack.size - 1)
        state[n] = 2
        order.addFirst(n)
    }
    nodes.forEach(::visit)
    return order.toList()
}

class UnionFind(n: Int) {
    private val parent = IntArray(n) { it }
    private val rank = IntArray(n)
    var components = n
        private set

    fun find(x: Int): Int {
        var root = x
        while (parent[root] != root) root = parent[root]
        var cur = x
        while (parent[cur] != root) {
            val next = parent[cur]
            parent[cur] = root
            cur = next
        }
        return root
    }

    fun union(a: Int, b: Int): Boolean {
        var ra = find(a)
        var rb = find(b)
        if (ra == rb) return false
        if (rank[ra] < rank[rb]) ra = rb.also { rb = ra }
        parent[rb] = ra
        if (rank[ra] == rank[rb]) rank[ra]++
        components--
        return true
    }
}

fun <T : Comparable<T>> Graph<T>.kruskal(): List<Triple<T, T, Int>> {
    val index = nodes.withIndex().associate { (i, n) -> n to i }
    val uf = UnionFind(index.size)
    return allEdges().sortedWith(compareBy({ it.third }, { it.first }, { it.second }))
        .filter { (a, b, _) -> uf.union(index.getValue(a), index.getValue(b)) }
}

fun <T : Comparable<T>> Graph<T>.dijkstra(source: T): Map<T, Pair<Int, List<T>>> {
    val dist = mutableMapOf(source to 0)
    val prev = mutableMapOf<T, T>()
    val queue = MinQueue<Pair<T, Int>>(compareBy<Pair<T, Int>> { it.second }.thenBy { it.first })
    queue += source to 0
    while (queue.isNotEmpty()) {
        val (u, d) = queue.poll()
        if (d > dist.getValue(u)) continue
        for ((v, w) in edges(u)) {
            val nd = d + w
            if (nd < (dist[v] ?: Int.MAX_VALUE)) {
                dist[v] = nd
                prev[v] = u
                queue += v to nd
            }
        }
    }
    return dist.keys.sorted().associateWith { node ->
        val path = generateSequence(node) { prev[it] }.toList().asReversed()
        dist.getValue(node) to path
    }
}

fun floydWarshall(n: Int, edges: List<Triple<Int, Int, Int>>): Array<LongArray> {
    val inf = Long.MAX_VALUE / 4
    val d = Array(n) { i -> LongArray(n) { j -> if (i == j) 0L else inf } }
    for ((a, b, w) in edges) d[a][b] = minOf(d[a][b], w.toLong())
    for (k in 0 until n) for (i in 0 until n) for (j in 0 until n) {
        if (d[i][k] + d[k][j] < d[i][j]) d[i][j] = d[i][k] + d[k][j]
    }
    return d
}

fun tarjan(n: Int, edges: List<Pair<Int, Int>>): List<List<Int>> {
    val adj = List(n) { mutableListOf<Int>() }
    edges.forEach { (a, b) -> adj[a].add(b) }
    var counter = 0
    val index = IntArray(n) { -1 }
    val low = IntArray(n)
    val onStack = BooleanArray(n)
    val stack = ArrayDeque<Int>()
    val result = mutableListOf<List<Int>>()
    fun strong(v: Int) {
        index[v] = counter
        low[v] = counter
        counter++
        stack.addLast(v)
        onStack[v] = true
        for (w in adj[v]) {
            if (index[w] == -1) {
                strong(w)
                low[v] = minOf(low[v], low[w])
            } else if (onStack[w]) {
                low[v] = minOf(low[v], index[w])
            }
        }
        if (low[v] == index[v]) {
            val comp = mutableListOf<Int>()
            do {
                val w = stack.removeLast()
                onStack[w] = false
                comp += w
            } while (w != v)
            result += comp.sorted()
        }
    }
    for (v in 0 until n) if (index[v] == -1) strong(v)
    return result.sortedBy { it.first() }
}

val TASKS = """
    wake -> shower
    wake -> coffee
    coffee -> breakfast
    shower -> dress
    dress -> leave
    breakfast -> leave
    leave -> commute
""".trimIndent()

val ROADS = """
    A-B 7, A-D 5, B-C 8, B-D 9, B-E 7, C-E 5,
    D-E 15, D-F 6, E-F 8, E-G 9, F-G 11
"""

fun main() {
    val tasks = Graph<String>(directed = true)
    TASKS.lines().map { it.split(" -> ") }.forEach { (a, b) -> tasks.addEdge(a, b) }
    println("tasks: $tasks")
    println("order: ${tasks.topoSort()}")
    tasks.addEdge("commute", "wake")
    try {
        tasks.topoSort()
    } catch (e: CycleException) {
        println("caught ${e.message} (${e.cycle.size - 1} edges)")
    }

    val roads = Graph<Char>(directed = false)
    val edgePattern = Regex("""([A-Z])-([A-Z]) (\d+)""")
    edgePattern.findAll(ROADS).forEach { m ->
        val (a, b, w) = m.destructured
        roads.addEdge(a.single(), b.single(), w.toInt())
    }
    println("roads: ${roads.allEdges().size} edges between ${roads.nodes}")
    val mst = roads.kruskal()
    println("mst: ${mst.joinToString { (a, b, w) -> "$a$b($w)" }} total=${mst.sumOf { it.third }}")
    val routes = roads.dijkstra('A')
    for ((node, info) in routes) {
        val (dist, path) = info
        println("  A to $node: ${dist.toString().padStart(2)} via ${path.joinToString("")}")
    }
    val farthest = routes.maxWith(compareBy<Map.Entry<Char, Pair<Int, List<Char>>>> { it.value.first }.thenByDescending { it.key })
    println("farthest from A: ${farthest.key} at ${farthest.value.first}")

    val fwEdges = listOf(Triple(0, 1, 3), Triple(1, 2, 1), Triple(2, 0, 2), Triple(2, 3, 7), Triple(3, 4, 1), Triple(0, 3, 15))
    val d = floydWarshall(5, fwEdges)
    for (row in d) println(row.joinToString(" ") { if (it >= Long.MAX_VALUE / 4) "  ∞" else it.toString().padStart(3) })
    val reachable = d.indices.associateWith { i -> d[i].indices.count { j -> d[i][j] < Long.MAX_VALUE / 4 } }
    println("reachable counts: $reachable")

    val sccEdges = listOf(0 to 1, 1 to 2, 2 to 0, 2 to 3, 3 to 4, 4 to 5, 5 to 3, 6 to 5, 6 to 7, 7 to 6, 8 to 8)
    val sccs = tarjan(9, sccEdges)
    println("sccs: $sccs (${sccs.count { it.size > 1 }} non-trivial)")

    val uf = UnionFind(10)
    listOf(1 to 2, 3 to 4, 2 to 3, 5 to 6, 7 to 7, 9 to 0, 4 to 1).forEach { (a, b) ->
        val merged = uf.union(a, b)
        if (!merged) println("  $a and $b already connected")
    }
    val groups = (0 until 10).groupBy(uf::find).values.map { it.sorted() }.sortedWith(compareByDescending<List<Int>> { it.size }.thenBy { it.first() })
    println("components=${uf.components} groups=$groups")

    val grid = Graph<Int>(directed = false)
    for (r in 0 until 3) for (c in 0 until 3) {
        val id = r * 3 + c
        if (c < 2) grid.addEdge(id, id + 1, (r + 1) * (c + 2))
        if (r < 2) grid.addEdge(id, id + 3, (c + 1) * (r + 2))
    }
    val gr = grid.dijkstra(0)
    println("grid distances: ${gr.mapValues { it.value.first }}")
    println("path to 8: ${gr.getValue(8).second}")
    val degrees = grid.nodes.associateWith { grid.edges(it).size }.entries.groupBy({ it.value }) { it.key }.toSortedMap()
    println("nodes by degree: $degrees")
}
