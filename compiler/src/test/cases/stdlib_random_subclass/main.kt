// Generators of the program extending kotlin.random.Random: only nextBits is abstract, and every other method (and the
// extensions taking a Random) draws from it as Kotlin's default implementations do.
import kotlin.random.Random
import kotlin.random.nextInt
import kotlin.random.nextLong
import kotlin.random.nextUInt

// a 32-bit LCG, in Long arithmetic so that no Int overflows (and every product stays below 2^53)
open class Lcg(seed: Long) : Random() {
    private var state = seed and 0xFFFFFFFFL
    var draws = 0

    override fun nextBits(bitCount: Int): Int {
        draws++
        state = (state * 69069L + 1L) and 0xFFFFFFFFL
        return (state ushr (32 - bitCount)).toInt()
    }

    // members of Random called on the implicit receiver
    fun dice(): Int = nextInt(1, 7)
    fun coin(): String = if (nextBoolean()) "heads" else "tails"
}

class Loaded(seed: Long) : Lcg(seed) {
    override fun nextBoolean(): Boolean = true
}

fun show(name: String, rng: Random) {
    println("$name: ${rng.nextInt()} ${rng.nextInt(10)} ${rng.nextInt(1000)} ${rng.nextInt(-5, 5)} ${rng.nextInt(16)}")
    println("  ranges: ${rng.nextInt(1..6)} ${rng.nextInt(Int.MIN_VALUE, 0)} ${rng.nextInt(Int.MIN_VALUE, Int.MAX_VALUE)} " +
        "${rng.nextInt(Int.MIN_VALUE..Int.MAX_VALUE)} ${rng.nextInt(0, 1)} ${rng.nextInt(-100, 2147483647)}")
    println("  doubles: ${rng.nextDouble()} ${rng.nextDouble(10.0)} ${rng.nextDouble(-1.0, 1.0)} ${rng.nextDouble(-Double.MAX_VALUE, Double.MAX_VALUE)}")
    println("  floats: ${rng.nextFloat()} ${rng.nextFloat()} booleans: ${rng.nextBoolean()} ${rng.nextBoolean()} ${rng.nextBoolean()}")
    println("  longs: ${rng.nextLong(1000L)} ${rng.nextLong(-5L, 5L)} ${rng.nextLong(1L shl 40)} ${rng.nextLong(1L shl 32)} " +
        "${rng.nextLong(3L shl 33)} ${rng.nextLong(10L..20L)}")
    println("  bytes: ${rng.nextBytes(7).toList()} ${rng.nextBytes(ByteArray(8), 1, 6).toList()} ${rng.nextBytes(0).size}")
    println("  unsigned: ${rng.nextUInt()} ${rng.nextUInt(10u)} ${rng.nextUInt(5u, 50u)}")
    println("  bits: ${rng.nextBits(0)} ${rng.nextBits(1)} ${rng.nextBits(31)}")
}

fun main() {
    val lcg = Lcg(42)
    show("lcg", lcg)
    println("draws: ${lcg.draws}")
    println("dice: ${List(10) { lcg.dice() }} ${lcg.coin()} ${lcg.coin()}")

    val rng = Lcg(7)
    println("shuffled: ${(1..10).toList().shuffled(rng)}")
    val list = mutableListOf("a", "b", "c", "d", "e")
    list.shuffle(rng)
    println("shuffle: $list")
    println("random: ${listOf(10, 20, 30).random(rng)} ${(1..100).random(rng)} ${(1L..100L).random(rng)} ${"xyz".random(rng)} " +
        "${arrayOf(1.5, 2.5).random(rng)} ${intArrayOf(4, 5, 6).random(rng)} ${('a'..'z').random(rng)} ${emptyList<Int>().randomOrNull(rng)}")
    println("sequence: ${(1..8).asSequence().shuffled(rng).toList()}")
    val array = intArrayOf(1, 2, 3, 4, 5, 6)
    array.shuffle(rng)
    println("array shuffle: ${array.toList()}")

    val loaded = Loaded(3)
    println("loaded: ${loaded.coin()} ${loaded.nextBoolean()} ${loaded.nextInt(100)} ${loaded.dice()}")

    var s = 12345L
    val anonymous = object : Random() {
        override fun nextBits(bitCount: Int): Int {
            s = (s * 1103L + 12345L) % 2147483648L
            return (s shl 1 ushr (32 - bitCount)).toInt()
        }
    }
    show("anonymous", anonymous)
    try {
        anonymous.nextInt(5, 5)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        anonymous.nextInt(IntRange.EMPTY)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    val asRandom: Random = Lcg(99)
    println("as Random: ${asRandom.nextInt(50)} ${asRandom.nextBits(8)}")
}
