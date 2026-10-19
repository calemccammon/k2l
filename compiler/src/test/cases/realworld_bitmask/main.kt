// Bit-twiddling puzzles: a bitboard sudoku solver, travelling salesman by bitmask DP, Gray codes,
// subset enumeration and a sieve packed into an IntArray.

class Sudoku(puzzle: String) {
    private val grid = IntArray(81)
    private val rows = IntArray(9)
    private val cols = IntArray(9)
    private val boxes = IntArray(9)
    var guesses = 0
        private set

    init {
        val digits = puzzle.filter { it.isDigit() || it == '.' }
        require(digits.length == 81) { "expected 81 cells, got ${digits.length}" }
        digits.forEachIndexed { i, c -> if (c != '.' && c != '0') place(i, c.digitToInt()) }
    }

    private fun box(i: Int) = (i / 27) * 3 + (i % 9) / 3

    private fun place(i: Int, d: Int) {
        val bit = 1 shl d
        check(rows[i / 9] and bit == 0 && cols[i % 9] and bit == 0 && boxes[box(i)] and bit == 0) { "conflict at $i" }
        grid[i] = d
        rows[i / 9] = rows[i / 9] or bit
        cols[i % 9] = cols[i % 9] or bit
        boxes[box(i)] = boxes[box(i)] or bit
    }

    private fun remove(i: Int) {
        val mask = (1 shl grid[i]).inv()
        rows[i / 9] = rows[i / 9] and mask
        cols[i % 9] = cols[i % 9] and mask
        boxes[box(i)] = boxes[box(i)] and mask
        grid[i] = 0
    }

    private fun candidates(i: Int) = 0x3FE and (rows[i / 9] or cols[i % 9] or boxes[box(i)]).inv()

    fun solve(): Boolean {
        var best = -1
        var bestCount = 10
        for (i in 0 until 81) {
            if (grid[i] != 0) continue
            val n = Integer.bitCount(candidates(i))
            if (n < bestCount) {
                best = i
                bestCount = n
                if (n <= 1) break
            }
        }
        if (best < 0) return true
        var cands = candidates(best)
        while (cands != 0) {
            val bit = cands and -cands
            cands = cands xor bit
            guesses++
            place(best, Integer.numberOfTrailingZeros(bit))
            if (solve()) return true
            remove(best)
        }
        return false
    }

    override fun toString() = grid.toList().chunked(9).joinToString("\n") { row ->
        row.chunked(3).joinToString(" | ") { it.joinToString(" ") }
    }
}

fun tsp(dist: Array<IntArray>): Pair<Int, List<Int>> {
    val n = dist.size
    val full = 1 shl n
    val inf = Int.MAX_VALUE / 2
    val dp = Array(full) { IntArray(n) { inf } }
    val parent = Array(full) { IntArray(n) { -1 } }
    dp[1][0] = 0
    for (mask in 1 until full) {
        if (mask and 1 == 0) continue
        for (last in 0 until n) {
            if (mask and (1 shl last) == 0 || dp[mask][last] >= inf) continue
            for (next in 0 until n) {
                if (mask and (1 shl next) != 0) continue
                val nm = mask or (1 shl next)
                val cost = dp[mask][last] + dist[last][next]
                if (cost < dp[nm][next]) {
                    dp[nm][next] = cost
                    parent[nm][next] = last
                }
            }
        }
    }
    val (end, total) = (1 until n).map { it to dp[full - 1][it] + dist[it][0] }.minBy { it.second }
    val tour = ArrayDeque<Int>()
    var mask = full - 1
    var cur = end
    while (cur != -1) {
        tour.addFirst(cur)
        val p = parent[mask][cur]
        mask = mask xor (1 shl cur)
        cur = p
    }
    return total to tour + 0
}

fun gray(n: Int) = n xor (n shr 1)
fun fromGray(g: Int): Int {
    var n = g
    var shift = g shr 1
    while (shift != 0) {
        n = n xor shift
        shift = shift shr 1
    }
    return n
}

fun subsetsWithSum(items: IntArray, target: Int): List<List<Int>> = (0 until (1 shl items.size))
    .filter { mask -> items.indices.sumOf { if (mask shr it and 1 == 1) items[it] else 0 } == target }
    .map { mask -> items.indices.filter { mask and (1 shl it) != 0 }.map { items[it] } }

class BitSieve(val limit: Int) {
    private val bits = IntArray(limit / 32 + 1)
    operator fun get(i: Int) = bits[i ushr 5] and (1 shl (i and 31)) != 0
    private fun set(i: Int) {
        bits[i ushr 5] = bits[i ushr 5] or (1 shl (i and 31))
    }

    init {
        set(0); set(1)
        var p = 2
        while (p * p <= limit) {
            if (!this[p]) for (m in p * p..limit step p) set(m)
            p++
        }
    }

    fun primes() = (2..limit).filterNot { this[it] }
    fun count() = limit + 1 - bits.sumOf { Integer.bitCount(it) } + Integer.bitCount(bits.last() ushr ((limit and 31) + 1))
}

fun main() {
    val puzzle = """
        53..7.... 6..195... .98....6.
        8...6...3 4..8.3..1 7...2...6
        .6....28. ...419..5 ....8..79
    """
    val s = Sudoku(puzzle)
    println("solved=${s.solve()} guesses=${s.guesses}")
    println(s)
    val hard = Sudoku("8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..")
    println("hard solved=${hard.solve()} guesses=${hard.guesses}")
    println(hard.toString().lines().first())
    println(runCatching { Sudoku("123") }.exceptionOrNull()?.message)
    println(runCatching { Sudoku("11" + ".".repeat(79)) }.exceptionOrNull()?.message)

    val cities = listOf("A", "B", "C", "D", "E", "F")
    val dist = arrayOf(
        intArrayOf(0, 12, 10, 19, 8, 14),
        intArrayOf(12, 0, 3, 7, 2, 11),
        intArrayOf(10, 3, 0, 6, 20, 4),
        intArrayOf(19, 7, 6, 0, 4, 9),
        intArrayOf(8, 2, 20, 4, 0, 13),
        intArrayOf(14, 11, 4, 9, 13, 0),
    )
    val (cost, tour) = tsp(dist)
    println("tsp cost=$cost tour=${tour.joinToString("->") { cities[it] }}")
    println("check: ${tour.zipWithNext { a, b -> dist[a][b] }.sum() == cost}")

    val codes = (0 until 8).map { gray(it) }
    println("gray: ${codes.map { it.toString(2).padStart(3, '0') }} back=${codes.map(::fromGray)}")
    println("one bit apart: ${codes.zipWithNext { a, b -> Integer.bitCount(a xor b) }.all { it == 1 }}")
    println("subsets of [3,34,4,12,5,2] summing to 9: ${subsetsWithSum(intArrayOf(3, 34, 4, 12, 5, 2), 9)}")
    val x = 0b1011_0110
    println("bits of $x: count=${x.countOneBits()} lowest=${x.takeLowestOneBit()} highest=${x.takeHighestOneBit()} tz=${x.countTrailingZeroBits()} lz=${x.countLeadingZeroBits()}")
    println("swap nibbles: ${((x and 0x0F) shl 4 or (x and 0xF0 shr 4)).toString(2)} reversed bits: ${Integer.reverse(x) ushr 24}")
    println("masks: ${(-1 ushr 28)} ${(1 shl 31)} ${(1 shl 31) ushr 31} ${-16 shr 2} ${-16 ushr 28} ${0x7FFFFFFF + 0}")
    val sieve = BitSieve(200)
    println("primes ≤ 200: ${sieve.primes().size}, count()=${sieve.count()}, last ${sieve.primes().takeLast(3)}, 97 prime? ${!sieve[97]}")
}
