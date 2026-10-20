import java.util.PriorityQueue

// Adapted from realworld_graphs: a generic weighted graph with adjacency lists of Pairs in a HashMap,
// Dijkstra with a PriorityQueue and a comparator chain, union-find and Kruskal over a sorted edge list.

const val SIZE = 100 // the graph is a SIZE x SIZE grid with extra random edges

class Graph<T : Comparable<T>> {
    private val adj = HashMap<T, MutableList<Pair<T, Int>>>()

    val nodes: Set<T> get() = adj.keys

    fun addEdge(from: T, to: T, weight: Int) {
        adj.getOrPut(from) { mutableListOf() } += to to weight
        adj.getOrPut(to) { mutableListOf() } += from to weight
    }

    fun edges(from: T): List<Pair<T, Int>> = adj[from].orEmpty()

    fun allEdges(): List<Triple<T, T, Int>> = adj.flatMap { (from, list) -> list.map { (to, w) -> Triple(from, to, w) } }
        .filter { it.first < it.second }
}

fun <T : Comparable<T>> Graph<T>.dijkstra(source: T): Map<T, Int> {
    val dist = HashMap<T, Int>()
    dist[source] = 0
    val queue = PriorityQueue<Pair<T, Int>>(compareBy<Pair<T, Int>> { it.second }.thenBy { it.first })
    queue += source to 0
    while (queue.isNotEmpty()) {
        val (u, d) = queue.poll()
        if (d > dist.getValue(u)) continue
        for ((v, w) in edges(u)) {
            val nd = d + w
            if (nd < (dist[v] ?: Int.MAX_VALUE)) {
                dist[v] = nd
                queue += v to nd
            }
        }
    }
    return dist
}

class UnionFind(n: Int) {
    private val parent = IntArray(n) { it }
    private val rank = IntArray(n)

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
        return true
    }
}

fun <T : Comparable<T>> Graph<T>.kruskal(index: Map<T, Int>): List<Triple<T, T, Int>> {
    val uf = UnionFind(index.size)
    return allEdges().sortedWith(compareBy({ it.third }, { it.first }, { it.second }))
        .filter { (a, b, _) -> uf.union(index.getValue(a), index.getValue(b)) }
}

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

fun main() {
    val rng = Lcg(42)
    val graph = Graph<Int>()
    for (r in 0 until SIZE) for (c in 0 until SIZE) {
        val id = r * SIZE + c
        if (c + 1 < SIZE) graph.addEdge(id, id + 1, 1 + rng.next(20))
        if (r + 1 < SIZE) graph.addEdge(id, id + SIZE, 1 + rng.next(20))
    }
    repeat(SIZE * 4) { graph.addEdge(rng.next(SIZE * SIZE), rng.next(SIZE * SIZE), 5 + rng.next(50)) }
    var checksum = 0L
    for (s in 0 until 8) {
        val source = rng.next(SIZE * SIZE)
        val dist = graph.dijkstra(source)
        checksum += dist.values.sumOf { it.toLong() }
        checksum += dist.values.max()
    }
    println("dijkstra checksum $checksum")

    val index = graph.nodes.sorted().withIndex().associate { (i, n) -> n to i }
    val mst = graph.kruskal(index)
    println("mst ${mst.size} edges, weight ${mst.sumOf { it.third }}")

    val words = Graph<String>()
    for (i in 0 until SIZE * 20) words.addEdge("w${rng.next(SIZE * 6)}", "w${rng.next(SIZE * 6)}", 1 + rng.next(9))
    val wd = words.dijkstra("w0")
    println("words reached ${wd.size}, total ${wd.values.sum()}, farthest ${wd.entries.maxWith(compareBy({ it.value }, { it.key })).key}")
}
