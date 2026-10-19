// Lazy number sequences, sliding windows and signal processing over sensor readings.

fun collatz(start: Long): Sequence<Long> = generateSequence(start) { n ->
    when {
        n == 1L -> null
        n % 2 == 0L -> n / 2
        else -> 3 * n + 1
    }
}

val primes: Sequence<Int> = sequence {
    yield(2)
    val found = mutableListOf<Int>()
    var candidate = 3
    while (true) {
        val limit = kotlin.math.sqrt(candidate.toDouble()).toInt()
        if (found.takeWhile { it <= limit }.none { candidate % it == 0 }) {
            found += candidate
            yield(candidate)
        }
        candidate += 2
    }
}

fun sieve(n: Int): List<Int> {
    val composite = BooleanArray(n + 1)
    for (i in 2..n) {
        if (composite[i]) continue
        for (j in i.toLong() * i..n step i.toLong()) composite[j.toInt()] = true
    }
    return (2..n).filterNot { composite[it] }
}

fun fibonacci() = generateSequence(0L to 1L) { (a, b) -> b to a + b }.map { it.first }

fun digitsOf(n: Long): List<Int> = n.toString().map { it.digitToInt() }

fun isHappy(n: Int): Boolean {
    val seen = mutableSetOf<Int>()
    return generateSequence(n) { x -> x.toString().sumOf { (it - '0') * (it - '0') } }
        .first { it == 1 || !seen.add(it) } == 1
}

data class Reading(val minute: Int, val celsius: Double)

val SENSOR = """
    0 21.5
    1 21.7
    2 22.4
    3 23.9
    4 24.1
    5 99.9
    6 24.6
    7 24.2
    8 23.0
    9 22.1
    10 21.4
    11 20.9
    12 -40.0
    13 20.5
    14 20.8
    15 21.6
""".trimIndent()

fun parseReadings(text: String) = text.lineSequence()
    .map { it.split(' ') }
    .map { (m, c) -> Reading(m.toInt(), c.toDouble()) }

fun Double.fmt(decimals: Int = 2) = "%.${decimals}f".format(this)

fun main() {
    val longest = (1L..30L).maxBy { collatz(it).count() }
    println("collatz(27) has ${collatz(27).count()} terms, peak ${collatz(27).max()}")
    println("longest under 30: $longest (${collatz(longest).count()} terms)")
    println("collatz(6) = ${collatz(6).joinToString(" -> ")}")

    println("first primes: ${primes.take(15).toList()}")
    println("100th prime: ${primes.elementAt(99)}; sieve agrees: ${sieve(541).last()}")
    println("primes below 100 by last digit: ${sieve(100).groupBy { it % 10 }.toSortedMap()}")
    val twin = primes.zipWithNext().filter { (a, b) -> b - a == 2 }.take(6).toList()
    println("twin primes: $twin")
    val gaps = sieve(1000).zipWithNext { a, b -> b - a }
    println("max prime gap below 1000: ${gaps.max()} after ${sieve(1000)[gaps.indexOf(gaps.max())]}")

    println("fibonacci: ${fibonacci().take(20).joinToString()}")
    val firstBig = fibonacci().withIndex().first { it.value.toString().length >= 15 }
    println("first 15-digit fibonacci: F(${firstBig.index}) = ${firstBig.value}")
    println("even fib sum below 4M: ${fibonacci().takeWhile { it < 4_000_000 }.filter { it % 2 == 0L }.sum()}")
    println("digit sum of F(75): ${digitsOf(fibonacci().elementAt(75)).sum()}")
    println("happy numbers: ${(1..50).filter(::isHappy)}")

    val readings = parseReadings(SENSOR).toList()
    val median3 = readings.windowed(3) { w -> w.map { it.celsius }.sorted()[1] }
    println("median-of-3: ${median3.joinToString { it.fmt(1) }}")
    val outliers = readings.windowed(3).filter { (a, b, c) ->
        Math.abs(b.celsius - (a.celsius + c.celsius) / 2) > 10
    }.map { it[1] }
    println("outliers: $outliers")
    val clean = readings.filter { it !in outliers }
    val movingAvg = clean.map { it.celsius }.windowed(4, step = 2, partialWindows = true) { it.average() }
    println("moving average (4, step 2): ${movingAvg.map { it.fmt() }}")
    val chunks = clean.chunked(5) { chunk -> "${chunk.first().minute}-${chunk.last().minute}: max ${chunk.maxOf { it.celsius }}" }
    chunks.forEach { println("  $it") }
    val trend = clean.zipWithNext { a, b ->
        when {
            b.celsius > a.celsius + 0.5 -> '+'
            b.celsius < a.celsius - 0.5 -> '-'
            else -> '='
        }
    }.joinToString("")
    println("trend: $trend")
    val runs = trend.fold(mutableListOf<Pair<Char, Int>>()) { acc, c ->
        if (acc.isNotEmpty() && acc.last().first == c) acc[acc.lastIndex] = c to acc.last().second + 1 else acc += c to 1
        acc
    }
    println("runs: ${runs.joinToString(" ") { (c, n) -> "$c$n" }}")
    val warm = clean.asSequence().dropWhile { it.celsius < 23 }.takeWhile { it.celsius >= 23 }.map { it.minute }.toList()
    println("warm spell minutes: $warm")

    val triangular = generateSequence(1 to 1) { (n, t) -> (n + 1) to t + n + 1 }
    val firstWithDivisors = triangular.first { (_, t) -> (1..t).count { t % it == 0 } > 20 }
    println("first triangular number with >20 divisors: ${firstWithDivisors.second} (n=${firstWithDivisors.first})")
    val evens = generateSequence(0) { it + 2 }
    println("evens: ${evens.take(5).toList()} squares of odds: ${(1..20 step 2).map { it * it }}")
    val countdown = (10 downTo 0 step 3).toList()
    println("countdown $countdown, sum ${countdown.sum()}, reversed ${countdown.asReversed()}")
    val chars = ('a'..'z').filterIndexed { i, _ -> i % 5 == 0 }.joinToString("")
    println("letters: $chars ${('A'..'F').toList().chunked(2).map { it.joinToString("") }}")
    val pythagorean = sequence {
        for (c in 1..30) for (b in 1 until c) for (a in 1..b) if (a * a + b * b == c * c) yield(Triple(a, b, c))
    }
    println("pythagorean triples: ${pythagorean.take(6).toList()}")
    println("lazy evaluation:")
    val evaluated = mutableListOf<String>()
    val result = listOf("one", "two", "three", "four", "five").asSequence()
        .onEach { evaluated += "see $it" }
        .filter { it.length > 3 }
        .map { it.uppercase() }
        .firstOrNull()
    println("  result=$result after $evaluated")
}
