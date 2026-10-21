import kotlin.random.Random

// Cellular automata on flat arrays: Conway's Life on a torus (with cycle detection by hashing
// generations), elementary automata (rules 30, 90, 110), Langton's ant and a sandpile.

class Life(val width: Int, val height: Int) {
    private var cells = BooleanArray(width * height)
    private var next = BooleanArray(width * height)
    var generation = 0
        private set

    operator fun get(x: Int, y: Int): Boolean = cells[Math.floorMod(y, height) * width + Math.floorMod(x, width)]

    operator fun set(x: Int, y: Int, alive: Boolean) {
        cells[Math.floorMod(y, height) * width + Math.floorMod(x, width)] = alive
    }

    fun place(pattern: String, ox: Int, oy: Int) {
        pattern.trimIndent().lines().forEachIndexed { dy, row ->
            row.forEachIndexed { dx, c -> if (c == '#') this[ox + dx, oy + dy] = true }
        }
    }

    private fun neighbours(x: Int, y: Int): Int {
        var n = 0
        for (dy in -1..1) for (dx in -1..1) if ((dx != 0 || dy != 0) && this[x + dx, y + dy]) n++
        return n
    }

    fun step() {
        for (y in 0 until height) {
            for (x in 0 until width) {
                val n = neighbours(x, y)
                next[y * width + x] = n == 3 || (n == 2 && cells[y * width + x])
            }
        }
        val t = cells
        cells = next
        next = t
        generation++
    }

    fun population() = cells.count { it }

    fun signature(): Int = cells.contentHashCode()

    fun render(): String = (0 until height).joinToString("\n") { y -> (0 until width).joinToString("") { x -> if (this[x, y]) "#" else "." } }
}

fun elementary(rule: Int, width: Int, steps: Int, seedCells: IntArray? = null): List<String> {
    var row = IntArray(width)
    if (seedCells == null) row[width - 1] = 1 else seedCells.forEach { row[it] = 1 }
    val out = mutableListOf<String>()
    repeat(steps) {
        out += row.joinToString("") { if (it == 1) "#" else " " }.trimEnd()
        val next = IntArray(width)
        for (i in 0 until width) {
            val l = if (i == 0) 0 else row[i - 1]
            val c = row[i]
            val r = if (i == width - 1) 0 else row[i + 1]
            next[i] = (rule shr (l shl 2 or (c shl 1) or r)) and 1
        }
        row = next
    }
    return out
}

fun langtonsAnt(size: Int, steps: Int): Pair<Int, String> {
    val grid = Array(size) { BooleanArray(size) }
    var x = size / 2
    var y = size / 2
    var dir = 0
    val dx = intArrayOf(0, 1, 0, -1)
    val dy = intArrayOf(-1, 0, 1, 0)
    repeat(steps) {
        dir = if (grid[y][x]) (dir + 3) % 4 else (dir + 1) % 4
        grid[y][x] = !grid[y][x]
        x = (x + dx[dir] + size) % size
        y = (y + dy[dir] + size) % size
    }
    val black = grid.sumOf { row -> row.count { it } }
    return black to "ant at ($x, $y) facing ${"NESW"[dir]}"
}

fun sandpile(size: Int, grains: Int): Array<IntArray> {
    val pile = Array(size) { IntArray(size) }
    pile[size / 2][size / 2] = grains
    var unstable = true
    var topples = 0
    while (unstable) {
        unstable = false
        for (y in 0 until size) {
            for (x in 0 until size) {
                if (pile[y][x] >= 4) {
                    val q = pile[y][x] / 4
                    pile[y][x] %= 4
                    topples += q
                    if (y > 0) pile[y - 1][x] += q
                    if (y < size - 1) pile[y + 1][x] += q
                    if (x > 0) pile[y][x - 1] += q
                    if (x < size - 1) pile[y][x + 1] += q
                    unstable = true
                }
            }
        }
    }
    println("sandpile topples: $topples")
    return pile
}

fun main() {
    println("-- life: glider and blinker")
    val life = Life(12, 10)
    life.place(
        """
        .#.
        ..#
        ###
        """,
        1,
        1,
    )
    life.place("###", 8, 6)
    println(life.render())
    repeat(4) { life.step() }
    println("gen ${life.generation} pop ${life.population()}")
    println(life.render())

    println("-- life: random soup until it repeats")
    val soup = Life(16, 16)
    val rng = Random(1234)
    for (y in 0 until 16) for (x in 0 until 16) soup[x, y] = rng.nextInt(100) < 35
    val seen = HashMap<Int, Int>()
    val populations = mutableListOf<Int>()
    while (soup.generation < 400) {
        val sig = soup.signature()
        val first = seen[sig]
        if (first != null) {
            println("cycle: generation ${soup.generation} repeats ${first} (period ${soup.generation - first})")
            break
        }
        seen[sig] = soup.generation
        populations += soup.population()
        soup.step()
    }
    println("population trace: ${populations.filterIndexed { i, _ -> i % 10 == 0 }}")
    println("peak ${populations.max()} final ${soup.population()}")
    println(soup.render())

    for (rule in listOf(30, 90, 110)) {
        println("-- rule $rule")
        val rows = elementary(rule, 40, 16)
        rows.forEach { println("|$it") }
        println("live cells: ${rows.sumOf { r -> r.count { it == '#' } }}")
    }
    val wide = elementary(110, 200, 200, intArrayOf(199))
    println("rule 110 width 200 after 200 steps: ${wide.last().count { it == '#' }} live, hash ${wide.joinToString("").hashCode()}")

    println("-- langton's ant")
    for (steps in listOf(200, 11000)) {
        val (black, where) = langtonsAnt(64, steps)
        println("$steps steps: $black black cells, $where")
    }

    println("-- sandpile")
    val pile = sandpile(9, 300)
    pile.forEach { println(it.joinToString("")) }
    println("grains left: ${pile.sumOf { it.sum() }}")
}
