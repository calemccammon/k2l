// Adapted from realworld_grid: a generated maze; BFS with HashMap/HashSet of data-class positions, flood-filled regions,
// and a Dijkstra over (position, facing) states keyed by a nested data class.

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

const val SIZE = 101 // maze side, odd

data class Pos(val row: Int, val col: Int) {
    operator fun plus(d: Dir) = Pos(row + d.dr, col + d.dc)
}

enum class Dir(val dr: Int, val dc: Int) {
    UP(-1, 0), RIGHT(0, 1), DOWN(1, 0), LEFT(0, -1);

    fun turnRight() = entries[(ordinal + 1) % 4]
    fun turnLeft() = entries[(ordinal + 3) % 4]
}

class Grid(private val cells: Array<CharArray>) {
    val height get() = cells.size
    val width get() = cells[0].size

    operator fun get(p: Pos): Char = if (p.row in 0 until height && p.col in 0 until width) cells[p.row][p.col] else '#'

    fun neighbours(p: Pos): List<Pos> = Dir.entries.map { p + it }.filter { this[it] != '#' }
}

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

/** A maze carved by a randomized depth-first search, with some extra openings. */
fun maze(size: Int, rng: Lcg): Grid {
    val cells = Array(size) { CharArray(size) { '#' } }
    val stack = ArrayDeque<Pos>()
    val start = Pos(1, 1)
    cells[1][1] = '.'
    stack.addLast(start)
    while (stack.isNotEmpty()) {
        val cur = stack.last()
        val options = Dir.entries.filter { d ->
            val n = Pos(cur.row + 2 * d.dr, cur.col + 2 * d.dc)
            n.row in 1 until size - 1 && n.col in 1 until size - 1 && cells[n.row][n.col] == '#'
        }
        if (options.isEmpty()) {
            stack.removeLast()
            continue
        }
        val d = options[rng.next(options.size)]
        cells[cur.row + d.dr][cur.col + d.dc] = '.'
        cells[cur.row + 2 * d.dr][cur.col + 2 * d.dc] = '.'
        stack.addLast(Pos(cur.row + 2 * d.dr, cur.col + 2 * d.dc))
    }
    repeat(size * 2) { cells[1 + rng.next(size - 2)][1 + rng.next(size - 2)] = '.' }
    return Grid(cells)
}

fun bfs(grid: Grid, start: Pos, goal: Pos): Int {
    val previous = HashMap<Pos, Pos>()
    val queue = ArrayDeque<Pos>()
    val seen = hashSetOf(start)
    queue.addLast(start)
    while (queue.isNotEmpty()) {
        val cur = queue.removeFirst()
        if (cur == goal) {
            var steps = 0
            var p = cur
            while (p != start) {
                p = previous.getValue(p)
                steps++
            }
            return steps
        }
        for (n in grid.neighbours(cur)) {
            if (!seen.add(n)) continue
            previous[n] = cur
            queue.addLast(n)
        }
    }
    return -1
}

data class State(val pos: Pos, val dir: Dir)

fun cheapestRoute(grid: Grid, start: Pos, goal: Pos): Int {
    val best = mutableMapOf<State, Int>()
    val pq = MinQueue<Pair<Int, State>>(compareBy { it.first })
    val first = State(start, Dir.RIGHT)
    best[first] = 0
    pq.add(0 to first)
    while (pq.isNotEmpty()) {
        val (cost, state) = pq.poll()
        if (state.pos == goal) return cost
        if (cost > (best[state] ?: Int.MAX_VALUE)) continue
        val moves = listOf(
            State(state.pos + state.dir, state.dir) to 1,
            State(state.pos, state.dir.turnLeft()) to 1000,
            State(state.pos, state.dir.turnRight()) to 1000,
        )
        for ((next, step) in moves) {
            if (grid[next.pos] == '#') continue
            val newCost = cost + step
            if (newCost < best.getOrDefault(next, Int.MAX_VALUE)) {
                best[next] = newCost
                pq.offer(newCost to next)
            }
        }
    }
    return -1
}

fun regions(grid: Grid): Map<Char, Int> {
    val visited = HashSet<Pos>()
    val result = mutableMapOf<Char, Int>()
    for (r in 0 until grid.height) for (c in 0 until grid.width) {
        val start = Pos(r, c)
        if (start in visited || grid[start] == '#') continue
        var area = 0
        val stack = ArrayDeque(listOf(start))
        visited += start
        while (stack.isNotEmpty()) {
            val p = stack.removeLast()
            area++
            for (n in grid.neighbours(p)) if (visited.add(n)) stack.addLast(n)
        }
        result[grid[start]] = (result[grid[start]] ?: 0) + area
    }
    return result
}

fun main() {
    val rng = Lcg(7)
    var checksum = 0L
    repeat(3) { round ->
        val grid = maze(SIZE, rng)
        val start = Pos(1, 1)
        val goal = Pos(SIZE - 2, SIZE - 2)
        val steps = bfs(grid, start, goal)
        val cost = cheapestRoute(grid, start, goal)
        val areas = regions(grid)
        println("round $round: bfs $steps, route $cost, open ${areas['.']}")
        checksum += steps * 31L + cost + (areas['.'] ?: 0)
    }
    val counts = HashMap<Pos, Int>()
    for (i in 0 until SIZE * SIZE * 4) {
        val p = Pos(rng.next(SIZE), rng.next(SIZE))
        counts[p] = (counts[p] ?: 0) + 1
    }
    println("distinct ${counts.size}, max ${counts.values.max()}, checksum $checksum")
}
