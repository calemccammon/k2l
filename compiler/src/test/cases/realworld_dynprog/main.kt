// Classic dynamic programming problems, written the way people write them for interviews and puzzles.

fun editDistance(a: String, b: String): Int {
    val dp = Array(a.length + 1) { IntArray(b.length + 1) }
    for (i in 0..a.length) dp[i][0] = i
    for (j in 0..b.length) dp[0][j] = j
    for (i in 1..a.length) {
        for (j in 1..b.length) {
            val cost = if (a[i - 1] == b[j - 1]) 0 else 1
            dp[i][j] = minOf(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
        }
    }
    return dp[a.length][b.length]
}

fun longestCommonSubsequence(a: String, b: String): String {
    val dp = Array(a.length + 1) { IntArray(b.length + 1) }
    for (i in a.indices.reversed()) {
        for (j in b.indices.reversed()) {
            dp[i][j] = if (a[i] == b[j]) dp[i + 1][j + 1] + 1 else maxOf(dp[i + 1][j], dp[i][j + 1])
        }
    }
    return buildString {
        var i = 0
        var j = 0
        while (i < a.length && j < b.length) {
            when {
                a[i] == b[j] -> {
                    append(a[i]); i++; j++
                }
                dp[i + 1][j] >= dp[i][j + 1] -> i++
                else -> j++
            }
        }
    }
}

data class Item(val name: String, val weight: Int, val value: Int)

fun knapsack(items: List<Item>, capacity: Int): Pair<Int, List<Item>> {
    val n = items.size
    val best = Array(n + 1) { IntArray(capacity + 1) }
    for ((i, item) in items.withIndex()) {
        for (w in 0..capacity) {
            best[i + 1][w] = best[i][w]
            if (item.weight <= w) best[i + 1][w] = maxOf(best[i + 1][w], best[i][w - item.weight] + item.value)
        }
    }
    val chosen = mutableListOf<Item>()
    var w = capacity
    for (i in n downTo 1) {
        if (best[i][w] != best[i - 1][w]) {
            chosen += items[i - 1]
            w -= items[i - 1].weight
        }
    }
    return best[n][capacity] to chosen.reversed()
}

fun coinChangeWays(coins: IntArray, amount: Int): Long {
    val ways = LongArray(amount + 1)
    ways[0] = 1
    for (coin in coins) for (v in coin..amount) ways[v] += ways[v - coin]
    return ways[amount]
}

fun minCoins(coins: List<Int>, amount: Int): Int? {
    val inf = Int.MAX_VALUE
    val dp = IntArray(amount + 1) { if (it == 0) 0 else inf }
    for (v in 1..amount) {
        for (c in coins) {
            if (c <= v && dp[v - c] != inf) dp[v] = minOf(dp[v], dp[v - c] + 1)
        }
    }
    return dp[amount].takeIf { it != inf }
}

fun longestIncreasingSubsequence(xs: List<Int>): List<Int> {
    val tails = mutableListOf<Int>()
    val tailIndex = mutableListOf<Int>()
    val parent = IntArray(xs.size) { -1 }
    for ((i, x) in xs.withIndex()) {
        var pos = tails.binarySearch(x)
        if (pos < 0) pos = -(pos + 1)
        if (pos == tails.size) {
            tails.add(x); tailIndex.add(i)
        } else {
            tails[pos] = x; tailIndex[pos] = i
        }
        if (pos > 0) parent[i] = tailIndex[pos - 1]
    }
    val result = ArrayList<Int>()
    var k = tailIndex.lastOrNull() ?: return emptyList()
    while (k >= 0) {
        result.add(xs[k])
        k = parent[k]
    }
    return result.reversed()
}

// Memoized recursion over a pair key, as in "count arrangements" puzzles.
class Arrangements(private val pattern: String, private val groups: List<Int>) {
    private val memo = HashMap<Pair<Int, Int>, Long>()
    var hits = 0
        private set

    fun count(): Long = count(0, 0)

    private fun count(pos: Int, group: Int): Long {
        val key = pos to group
        memo[key]?.let { hits++; return it }
        val result = when {
            pos >= pattern.length -> if (group == groups.size) 1L else 0L
            else -> {
                var total = 0L
                val c = pattern[pos]
                if (c == '.' || c == '?') total += count(pos + 1, group)
                if ((c == '#' || c == '?') && group < groups.size) {
                    val len = groups[group]
                    val end = pos + len
                    val fits = end <= pattern.length &&
                        (pos until end).none { pattern[it] == '.' } &&
                        (end == pattern.length || pattern[end] != '#')
                    if (fits) total += count(minOf(end + 1, pattern.length), group + 1)
                }
                total
            }
        }
        memo[key] = result
        return result
    }
}

fun unfold(line: String, times: Int): Pair<String, List<Int>> {
    val (springs, counts) = line.split(' ')
    val pattern = List(times) { springs }.joinToString("?")
    val groups = counts.split(',').map(String::toInt)
    return pattern to List(times) { groups }.flatten()
}

val fibMemo = mutableMapOf<Int, Long>()
fun fib(n: Int): Long = if (n < 2) n.toLong() else fibMemo.getOrPut(n) { fib(n - 1) + fib(n - 2) }

fun triangleMaxPath(rows: List<List<Int>>): Int =
    rows.reversed().reduce { below, row -> row.mapIndexed { i, v -> v + maxOf(below[i], below[i + 1]) } }.single()

fun partitions(n: Int): List<List<Int>> {
    val out = mutableListOf<List<Int>>()
    fun go(remaining: Int, max: Int, acc: MutableList<Int>) {
        if (remaining == 0) {
            out.add(acc.toList()); return
        }
        for (k in minOf(max, remaining) downTo 1) {
            acc.add(k)
            go(remaining - k, k, acc)
            acc.removeAt(acc.lastIndex)
        }
    }
    go(n, n, mutableListOf())
    return out
}

fun main() {
    for ((a, b) in listOf("kitten" to "sitting", "flaw" to "lawn", "" to "abc", "intention" to "execution")) {
        println("edit($a, $b) = ${editDistance(a, b)}")
    }
    println("lcs = ${longestCommonSubsequence("AGGTAB", "GXTXAYB")} / ${longestCommonSubsequence("ABCBDAB", "BDCABA")}")

    val items = listOf(
        Item("map", 9, 150), Item("compass", 13, 35), Item("water", 153, 200), Item("sandwich", 50, 160),
        Item("glucose", 15, 60), Item("tin", 68, 45), Item("banana", 27, 60), Item("apple", 39, 40),
        Item("cheese", 23, 30), Item("beer", 52, 10), Item("suntan", 11, 70), Item("camera", 32, 30),
    )
    val (value, chosen) = knapsack(items, 400)
    println("knapsack value=$value weight=${chosen.sumOf { it.weight }}")
    println("  items: ${chosen.joinToString { it.name }}")

    println("ways(100) = ${coinChangeWays(intArrayOf(1, 5, 10, 25, 50), 100)}")
    println("ways(1000) = ${coinChangeWays(intArrayOf(1, 2, 5, 10, 20, 50, 100, 200), 1000)}")
    println("minCoins: ${minCoins(listOf(1, 3, 4), 6)} ${minCoins(listOf(2), 3)} ${minCoins(listOf(186, 419, 83, 408), 6249)}")

    val seq = listOf(10, 9, 2, 5, 3, 7, 101, 18, 4, 8, 6, 12, 15)
    println("lis = ${longestIncreasingSubsequence(seq)}")
    println("lis(empty) = ${longestIncreasingSubsequence(emptyList())}")

    val lines = listOf("???.### 1,1,3", ".??..??...?##. 1,1,3", "?#?#?#?#?#?#?#? 1,3,1,6", "?###???????? 3,2,1")
    var total = 0L
    for (line in lines) {
        val (pattern, groups) = unfold(line, 1)
        val (p5, g5) = unfold(line, 5)
        val a = Arrangements(pattern, groups).count()
        val big = Arrangements(p5, g5)
        val b = big.count()
        total += b
        println("${line.padEnd(26)} -> $a / $b (memo hits ${big.hits})")
    }
    println("total unfolded = $total")

    println("fib(78) = ${fib(78)}, memo size ${fibMemo.size}")
    val triangle = """
        3
        7 4
        2 4 6
        8 5 9 3
    """.trimIndent().lines().map { row -> row.split(" ").map { it.toInt() } }
    println("triangle max path = ${triangleMaxPath(triangle)}")
    val parts = partitions(6)
    println("partitions(6): ${parts.size} -> ${parts.joinToString(" ") { it.joinToString("+") }}")
    println("partition counts: ${(1..12).map { partitions(it).size }}")
}
