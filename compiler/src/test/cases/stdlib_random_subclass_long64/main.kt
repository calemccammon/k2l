// A generator of the program with Int arithmetic that wraps, and the Long draws Kotlin derives from it (nextLong() is two
// nextInt()s); exact with --long64 emulate.
import kotlin.random.Random
import kotlin.random.nextLong
import kotlin.random.nextULong

class Xorshift(private var x: Int) : Random() {
    override fun nextBits(bitCount: Int): Int {
        x = x xor (x shl 13)
        x = x xor (x ushr 17)
        x = x xor (x shl 5)
        return x.ushr(32 - bitCount) and (-bitCount).shr(31)
    }
}

class IntLcg(private var state: Int) : Random() {
    override fun nextBits(bitCount: Int): Int {
        state = state * 1103515245 + 12345
        return state.ushr(32 - bitCount) and (-bitCount).shr(31)
    }
}

fun longs(name: String, rng: Random) {
    println("$name: ${rng.nextLong()} ${rng.nextLong()} ${rng.nextLong(Long.MAX_VALUE)} ${rng.nextLong(Long.MIN_VALUE, Long.MAX_VALUE)}")
    println("  ${rng.nextLong(1L shl 62)} ${rng.nextLong(1L shl 32)} ${rng.nextLong(1L shl 20)} ${rng.nextLong(-1000L, 1000L)} " +
        "${rng.nextLong(Long.MIN_VALUE..Long.MAX_VALUE)} ${rng.nextLong(0L..Long.MAX_VALUE)}")
    println("  ulong: ${rng.nextULong()} ${rng.nextULong(ULong.MAX_VALUE)} ${rng.nextULong(5uL, 10uL)}")
    println("  int: ${rng.nextInt()} ${rng.nextInt(Int.MIN_VALUE, 0)} ${rng.nextInt(1 shl 30)} ${rng.nextDouble()}")
}

fun main() {
    longs("xorshift", Xorshift(2463534242.toInt()))
    longs("lcg", IntLcg(1))
    // XorWow: a range of exactly 2^31 values is a power of two to Kotlin (Int.MIN_VALUE)
    val xorwow = Random(2024)
    println("xorwow: ${xorwow.nextInt(Int.MIN_VALUE, 0)} ${xorwow.nextInt(-1073741824, 1073741824)} " +
        "${xorwow.nextInt(-1, Int.MAX_VALUE)} ${xorwow.nextInt(-5, Int.MAX_VALUE)}")
    longs("xorwow", xorwow)
}
