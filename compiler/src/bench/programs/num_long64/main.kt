// Adapted from realworld_bitmask and bigint_long64, compiled with --long64 emulate: full 64-bit Long arithmetic that
// overflows (splitmix64, xorshift64*, FNV-1a 64, a 64-bit LCG), unsigned shifts, rotations, bit counts,
// Long division and remainder, and Long keys in a HashMap.

const val SIZE = 400_000 // iterations

fun splitmix(state: Long): Long {
    var z = state + -7046029254386353131L
    z = (z xor (z ushr 30)) * -4658895280553007687L
    z = (z xor (z ushr 27)) * -7723592293110705685L
    return z xor (z ushr 31)
}

class XorShift64(private var s: Long) {
    fun next(): Long {
        s = s xor (s shl 13)
        s = s xor (s ushr 7)
        s = s xor (s shl 17)
        return s * 2685821657736338717L
    }
}

fun fnv64(text: String): Long {
    var h = -3750763034362895579L
    for (c in text) {
        h = h xor c.code.toLong()
        h *= 1099511628211L
    }
    return h
}

fun main() {
    var acc = 0L
    var state = 42L
    for (i in 0 until SIZE) {
        state = splitmix(state)
        acc = acc xor java.lang.Long.rotateLeft(state, i % 64)
        acc += state / 1_000_003 + state % 977
    }
    println("splitmix $acc")

    val rng = XorShift64(88172645463325252L)
    var bits = 0
    var maxv = Long.MIN_VALUE
    for (i in 0 until SIZE) {
        val v = rng.next()
        bits += java.lang.Long.bitCount(v) + java.lang.Long.numberOfTrailingZeros(v or 1L)
        if (v > maxv) maxv = v
    }
    println("xorshift bits $bits max $maxv")

    var h = 0L
    for (i in 0 until SIZE / 4) h = h * 31 + fnv64("item-$i")
    println("fnv $h")

    var lcg = 1L
    val buckets = HashMap<Long, Int>()
    for (i in 0 until SIZE) {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        val key = lcg ushr 54
        buckets[key] = (buckets[key] ?: 0) + 1
    }
    println("buckets ${buckets.size} max ${buckets.values.max()} lcg $lcg ${lcg.toULong()} ${java.lang.Long.toHexString(lcg)}")
}
