import kotlin.math.abs
import kotlin.math.sqrt
import kotlin.random.Random
import kotlin.random.nextInt

// Seeded Monte Carlo experiments: every draw goes through Kotlin's XorWow generator, so the
// numbers printed here are the JVM's exact sequences for each Random method.

fun estimatePi(seed: Int, samples: Int): Double {
    val rng = Random(seed)
    var inside = 0
    repeat(samples) {
        val x = rng.nextDouble()
        val y = rng.nextDouble()
        if (x * x + y * y <= 1.0) inside++
    }
    return 4.0 * inside / samples
}

data class Walk(val x: Int, val y: Int, val maxDistance: Double, val returns: Int)

fun randomWalk(rng: Random, steps: Int): Walk {
    var x = 0
    var y = 0
    var best = 0.0
    var returns = 0
    repeat(steps) {
        when (rng.nextInt(4)) {
            0 -> x++
            1 -> x--
            2 -> y++
            else -> y--
        }
        val d = sqrt((x * x + y * y).toDouble())
        if (d > best) best = d
        if (x == 0 && y == 0) returns++
    }
    return Walk(x, y, best, returns)
}

class DiceStats(private val sides: Int) {
    private val counts = IntArray(sides + 1)
    private var rolls = 0
    private var sum = 0L

    fun roll(rng: Random) {
        val v = rng.nextInt(1, sides + 1)
        counts[v]++
        rolls++
        sum += v
    }

    fun mean(): Double = sum.toDouble() / rolls

    fun chiSquare(): Double {
        val expected = rolls.toDouble() / sides
        var chi = 0.0
        for (face in 1..sides) {
            val diff = counts[face] - expected
            chi += diff * diff / expected
        }
        return chi
    }

    fun histogram(): String = (1..sides).joinToString(" ") { "$it:${counts[it]}" }
}

fun rawSequences() {
    println("-- raw sequences")
    val r = Random(42)
    println(List(6) { r.nextInt() })
    println(List(6) { r.nextInt(100) })
    println(List(6) { r.nextInt(-50, 50) })
    println(List(6) { r.nextInt(1 shl 16) })
    println(List(4) { r.nextInt(Int.MIN_VALUE, Int.MAX_VALUE) })
    println(List(4) { r.nextInt(-2000000000, 2000000000) })
    println(List(6) { r.nextInt(3..9) })
    println(List(6) { r.nextBits(5) })
    println(List(3) { r.nextBits(32) })
    println(r.nextBits(0))
    println(List(8) { r.nextBoolean() })
    println(List(4) { "%.12f".format(r.nextDouble()) })
    println(List(3) { "%.10f".format(r.nextDouble(10.0)) })
    println(List(3) { "%.10f".format(r.nextDouble(-1.5, 2.5)) })
    println(List(4) { r.nextFloat() })
    println(List(4) { r.nextLong(1000L) })
    println(List(3) { r.nextLong(-5L, 5L) })
    println(r.nextBytes(7).joinToString(","))
    val buffer = ByteArray(10)
    r.nextBytes(buffer, 2, 9)
    println(buffer.joinToString(","))
    r.nextBytes(buffer)
    println(buffer.joinToString(","))
}

fun seeds() {
    println("-- seeds")
    for (seed in listOf(0, 1, -1, 7, 123456, Int.MIN_VALUE, Int.MAX_VALUE)) {
        val r = Random(seed)
        println("$seed: ${r.nextInt()} ${r.nextInt(10)} ${"%.6f".format(r.nextDouble())}")
    }
    for (seed in listOf(0L, 42L, -42L, 4294967296L, 1234567890123L, -9007199254740992L)) {
        val r = Random(seed)
        println("${seed}L: ${r.nextInt()} ${r.nextInt(1000)}")
    }
    println(Random(5).nextInt() == Random(5L).nextInt())
    println(Random(-5).nextInt() == Random(-5L).nextInt())
}

fun collections() {
    println("-- collections")
    val deck = (1..13).flatMap { rank -> listOf("S", "H", "D", "C").map { "$rank$it" } }
    val shuffled = deck.shuffled(Random(2024))
    println(shuffled.take(10))
    println(shuffled.sorted() == deck.sorted())
    val hand = deck.toMutableList()
    hand.shuffle(Random(7))
    println(hand.takeLast(5))
    val array = IntArray(10) { it * it }
    array.shuffle(Random(3))
    println(array.joinToString())
    val boxed = arrayOf("a", "b", "c", "d", "e", "f")
    boxed.shuffle(Random(11))
    println(boxed.joinToString(""))
    val picker = Random(99)
    println(List(6) { deck.random(picker) })
    println(List(5) { (1..100).random(picker) })
    println(List(5) { ('a'..'z').random(picker) })
    println(List(3) { "kotlin".random(picker) })
    println(List(4) { arrayOf(10, 20, 30).random(picker) })
    println(List(4) { intArrayOf(1, 2, 3, 4, 5).random(picker) })
    println(emptyList<Int>().randomOrNull(picker))
    println(listOf(9).randomOrNull(picker))
    println((1..0).randomOrNull(picker))
    try {
        IntRange.EMPTY.random(picker)
    } catch (e: NoSuchElementException) {
        println("empty range: ${e.message}")
    }
    try {
        picker.nextInt(5..4)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        picker.nextDouble(2.0, 1.0)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
}

fun experiments() {
    println("-- experiments")
    for ((seed, samples) in listOf(1 to 1000, 2 to 10000, 3 to 50000)) {
        val pi = estimatePi(seed, samples)
        println("pi($seed, $samples) = $pi error=${"%.5f".format(abs(pi - Math.PI))}")
    }
    val walker = Random(31337)
    repeat(3) { println(randomWalk(walker, 500)) }
    val d6 = DiceStats(6)
    val d20 = DiceStats(20)
    val dice = Random(6)
    repeat(6000) { d6.roll(dice) }
    repeat(4000) { d20.roll(dice) }
    println(d6.histogram())
    println("d6 mean=${"%.4f".format(d6.mean())} chi2=${"%.4f".format(d6.chiSquare())}")
    println("d20 mean=${"%.4f".format(d20.mean())} chi2=${"%.4f".format(d20.chiSquare())}")
    val coin = Random(1)
    var streak = 0
    var longest = 0
    repeat(10000) {
        if (coin.nextBoolean()) {
            streak++
            if (streak > longest) longest = streak
        } else {
            streak = 0
        }
    }
    println("longest heads streak: $longest")
    val birthdays = Random(365)
    var collisions = 0
    repeat(2000) {
        val seen = HashSet<Int>()
        var hit = false
        repeat(23) { if (!seen.add(birthdays.nextInt(365))) hit = true }
        if (hit) collisions++
    }
    println("birthday paradox (23 people): ${"%.3f".format(collisions / 2000.0)}")
}

fun defaults() {
    println("-- default")
    val values = List(200) { Random.nextInt(10) }
    println(values.all { it in 0..9 })
    println(Random.nextDouble() in 0.0..1.0)
    println(Random.Default.nextInt(5, 6))
    println(Random.nextBits(4) in 0..15)
    println(Random.nextBytes(3).size)
    println(Random.nextFloat() < 1.0f)
    println(Random.nextLong(3L, 4L))
}

fun main() {
    rawSequences()
    seeds()
    collections()
    experiments()
    defaults()
}
