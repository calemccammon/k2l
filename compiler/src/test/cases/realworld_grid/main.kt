import java.util.PriorityQueue

// An Advent-of-Code-style grid puzzle: parse a map from a multi-line string, then
// flood-fill regions, run BFS and Dijkstra, and simulate a guard walking around.

data class Pos(val row: Int, val col: Int) {
    operator fun plus(d: Dir) = Pos(row + d.dr, col + d.dc)
    fun manhattan(other: Pos) = Math.abs(row - other.row) + Math.abs(col - other.col)
    override fun toString() = "($row,$col)"
}

enum class Dir(val dr: Int, val dc: Int, val symbol: Char) {
    UP(-1, 0, '^'), RIGHT(0, 1, '>'), DOWN(1, 0, 'v'), LEFT(0, -1, '<');

    fun turnRight() = entries[(ordinal + 1) % entries.size]
    fun turnLeft() = entries[(ordinal + 3) % entries.size]

    companion object {
        fun of(c: Char): Dir? = entries.firstOrNull { it.symbol == c }
    }
}

class Grid(private val cells: List<CharArray>) {
    val height get() = cells.size
    val width get() = cells[0].size

    operator fun get(p: Pos): Char? = cells.getOrNull(p.row)?.getOrNull(p.col)
    operator fun set(p: Pos, c: Char) {
        cells[p.row][p.col] = c
    }

    operator fun contains(p: Pos) = p.row in 0 until height && p.col in 0 until width

    fun positions(): Sequence<Pos> = sequence {
        for (r in 0 until height) for (c in 0 until width) yield(Pos(r, c))
    }

    fun find(c: Char): Pos = positions().first { this[it] == c }

    fun neighbours(p: Pos): List<Pos> = Dir.entries.map { p + it }.filter { it in this }

    fun copy() = Grid(cells.map { it.copyOf() })

    fun render(): String = cells.joinToString("\n") { String(it) }

    companion object {
        fun parse(text: String) = Grid(text.trimIndent().lines().map { it.toCharArray() })
    }
}

val MAZE = """
    #################
    #S..#.....#.....#
    #.#.#.###.#.###.#
    #.#...#...#...#.#
    #.#####.#####.#.#
    #.....#.....#.#.#
    #####.#####.#.#.#
    #...#.....#...#E#
    #.#.#####.#####.#
    #.#.......#.....#
    #################
"""

fun bfs(grid: Grid, start: Pos, goal: Pos): List<Pos>? {
    val previous = HashMap<Pos, Pos>()
    val queue = ArrayDeque<Pos>()
    val seen = mutableSetOf(start)
    queue.addLast(start)
    while (queue.isNotEmpty()) {
        val cur = queue.removeFirst()
        if (cur == goal) {
            val path = mutableListOf(cur)
            var p = cur
            while (p != start) {
                p = previous.getValue(p)
                path.add(p)
            }
            return path.asReversed()
        }
        for (n in grid.neighbours(cur)) {
            if (grid[n] == '#' || !seen.add(n)) continue
            previous[n] = cur
            queue.addLast(n)
        }
    }
    return null
}

// Dijkstra where turning costs 1000 and stepping costs 1 (state = position + facing).
data class State(val pos: Pos, val dir: Dir)

fun cheapestRoute(grid: Grid, start: Pos, goal: Pos): Int {
    val best = mutableMapOf<State, Int>()
    val pq = PriorityQueue<Pair<Int, State>>(compareBy { it.first })
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

val GARDEN = """
    AAAABBC
    AABBBCC
    DDBEECC
    DDDEEEF
    GGDDFFF
"""

data class Region(val plant: Char, val area: Int, val perimeter: Int) {
    val price get() = area * perimeter
}

fun regions(grid: Grid): List<Region> {
    val visited = HashSet<Pos>()
    val result = mutableListOf<Region>()
    for (start in grid.positions()) {
        if (start in visited) continue
        val plant = grid[start]!!
        var area = 0
        var perimeter = 0
        val stack = ArrayDeque(listOf(start))
        visited += start
        while (stack.isNotEmpty()) {
            val p = stack.removeLast()
            area++
            for (d in Dir.entries) {
                val n = p + d
                if (grid[n] != plant) {
                    perimeter++
                } else if (visited.add(n)) {
                    stack.addLast(n)
                }
            }
        }
        result += Region(plant, area, perimeter)
    }
    return result
}

val PATROL = """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
"""

fun patrol(grid: Grid): Pair<Int, Boolean> {
    var pos = grid.positions().first { Dir.of(grid[it]!!) != null }
    var dir = Dir.of(grid[pos]!!)!!
    val visited = mutableSetOf<Pos>()
    val states = mutableSetOf<State>()
    while (true) {
        visited += pos
        if (!states.add(State(pos, dir))) return visited.size to true
        val ahead = pos + dir
        when (grid[ahead]) {
            null -> return visited.size to false
            '#', 'O' -> dir = dir.turnRight()
            else -> pos = ahead
        }
    }
}

fun main() {
    val maze = Grid.parse(MAZE)
    println("maze ${maze.width}x${maze.height}")
    val start = maze.find('S')
    val end = maze.find('E')
    println("start=$start end=$end distance=${start.manhattan(end)}")
    val path = bfs(maze, start, end) ?: error("no path")
    println("shortest path: ${path.size - 1} steps")
    println("first steps: ${path.take(5).joinToString(" -> ")}")
    val drawn = maze.copy()
    path.zipWithNext().forEach { (a, b) ->
        val d = Dir.entries.single { a + it == b }
        if (drawn[b] == '.') drawn[b] = d.symbol
    }
    println(drawn.render())
    println("cheapest route: ${cheapestRoute(maze, start, end)}")
    println("walled-in: ${bfs(maze, start, Pos(0, 0))}")

    val garden = Grid.parse(GARDEN)
    val rs = regions(garden)
    rs.sortedWith(compareByDescending<Region> { it.price }.thenBy { it.plant })
        .forEach { println("  ${it.plant}: area=${it.area} perimeter=${it.perimeter} price=${it.price}") }
    println("total price: ${rs.sumOf { it.price }}")
    val byPlant = rs.groupBy({ it.plant }, { it.area })
    println("areas by plant: $byPlant")

    val lab = Grid.parse(PATROL)
    val (count, looped) = patrol(lab)
    println("guard visits $count cells, loop=$looped")
    val startPos = lab.positions().first { lab[it] == '^' }
    var loops = 0
    outer@ for (r in 0 until lab.height) {
        for (c in 0 until lab.width) {
            val p = Pos(r, c)
            if (p == startPos || lab[p] != '.') continue
            if (p.manhattan(startPos) > 6) continue@outer
            val trial = lab.copy()
            trial[p] = 'O'
            if (patrol(trial).second) loops++
        }
    }
    println("obstacles creating loops (near start): $loops")
}
