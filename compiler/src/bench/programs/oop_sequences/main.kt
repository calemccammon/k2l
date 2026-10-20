// Adapted from realworld_sequences: lazy pipelines with generateSequence, sequence { yield }, map/filter/take/
// takeWhile/zip/windowed/flatMap/distinct on sequences, and lambdas passed through several layers.

const val SIZE = 120_000 // elements per pipeline

fun primes(): Sequence<Int> = sequence {
    yield(2)
    val found = mutableListOf<Int>()
    var n = 3
    while (true) {
        if (found.takeWhile { it * it <= n }.none { n % it == 0 }) {
            found += n
            yield(n)
        }
        n += 2
    }
}

fun collatz(start: Long): Sequence<Long> = generateSequence(start) { if (it == 1L) null else if (it % 2 == 0L) it / 2 else 3 * it + 1 }

data class Reading(val sensor: Int, val value: Int)

fun readings(seed: Int): Sequence<Reading> {
    var s = seed
    return generateSequence {
        s = (s * 75 + 74) % 65537
        Reading(s % 7, s % 1000)
    }
}

fun main() {
    var checksum = 0L
    val p = primes().take(SIZE / 20).toList()
    checksum += p.last() + p.sum()
    println("primes: ${p.size}, last ${p.last()}")

    val longest = (1L..SIZE / 4).asSequence().map { it to collatz(it).count() }.maxBy { it.second }
    println("longest collatz below ${SIZE / 4}: ${longest.first} (${longest.second} steps)")
    checksum += longest.first + longest.second

    val stats = readings(11).take(SIZE * 2)
        .filter { it.value > 100 }
        .groupBy { it.sensor }
        .mapValues { (_, list) -> list.asSequence().map { it.value }.windowed(5, 5) { it.average() }.maxOrNull() ?: 0.0 }
    println("best windows: ${stats.toSortedMap().values.map { it.toInt() }}")
    checksum += stats.values.sumOf { it.toLong() }

    val pairs = readings(5).zip(readings(9)).take(SIZE).filter { (a, b) -> a.sensor == b.sensor }.map { (a, b) -> a.value - b.value }.toList()
    checksum += pairs.sum() + pairs.count()
    val words = generateSequence(1) { it + 1 }.map { i -> "w" + (i * 7919 % 997) }.take(SIZE / 2)
    val distinct = words.distinct().count()
    val nested = (1..200).asSequence().flatMap { i -> (1..i % 30).asSequence().map { j -> i * j } }.filter { it % 3 == 0 }.sum()
    checksum += distinct + nested
    val running = (1..SIZE).asSequence().runningFold(0L) { acc, v -> (acc + v.toLong() * v) % 1_000_003 }.last()
    println("pairs ${pairs.count()}, distinct $distinct, nested $nested, running $running, checksum ${checksum + running}")
}
