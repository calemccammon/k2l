// Adapted from realworld_compress and realworld_bitmask, compiled with --int-overflow wrap: 32-bit hashes and
// generators that rely on Int overflow (FNV-1a, murmur3 finalizer, xorshift, an LCG), a table-driven CRC-32,
// Adler-32, and run-length plus LZ77-style compression of the generated data.

const val SIZE = 150_000 // bytes of data

fun fnv1a(data: IntArray): Int {
    var h = -2128831035
    for (b in data) {
        h = h xor b
        h *= 16777619
    }
    return h
}

fun murmurMix(k0: Int): Int {
    var k = k0
    k = k xor (k ushr 16)
    k *= -2048144789
    k = k xor (k ushr 13)
    k *= -1028477387
    return k xor (k ushr 16)
}

val CRC_TABLE = IntArray(256) { n ->
    var c = n
    repeat(8) { c = if (c and 1 != 0) -306674912 xor (c ushr 1) else c ushr 1 }
    c
}

fun crc32(data: IntArray): Int {
    var crc = -1
    for (b in data) crc = CRC_TABLE[(crc xor b) and 0xFF] xor (crc ushr 8)
    return crc.inv()
}

fun adler32(data: IntArray): Int {
    var a = 1
    var b = 0
    for (x in data) {
        a = (a + x) % 65521
        b = (b + a) % 65521
    }
    return (b shl 16) or a
}

class XorShift(private var state: Int) {
    fun next(): Int {
        var x = state
        x = x xor (x shl 13)
        x = x xor (x ushr 17)
        x = x xor (x shl 5)
        state = x
        return x
    }
}

fun runLength(data: IntArray): List<Int> {
    val out = ArrayList<Int>()
    var i = 0
    while (i < data.size) {
        var j = i
        while (j < data.size && data[j] == data[i] && j - i < 255) j++
        out.add(j - i)
        out.add(data[i])
        i = j
    }
    return out
}

/** LZ77 with a hash of the next 3 bytes: returns the number of literals and matches. */
fun lz(data: IntArray): Pair<Int, Int> {
    val head = IntArray(4096) { -1 }
    var literals = 0
    var matches = 0
    var i = 0
    while (i + 3 < data.size) {
        val h = (murmurMix(data[i] or (data[i + 1] shl 8) or (data[i + 2] shl 16)) ushr 20)
        val candidate = head[h]
        head[h] = i
        var len = 0
        if (candidate >= 0 && i - candidate < 4096) {
            while (i + len < data.size && data[candidate + len] == data[i + len] && len < 258) len++
        }
        if (len >= 3) {
            matches++
            i += len
        } else {
            literals++
            i++
        }
    }
    return literals to matches
}

fun main() {
    val rng = XorShift(2463534)
    val data = IntArray(SIZE)
    var lcg = 12345
    for (i in data.indices) {
        lcg = lcg * 1103515245 + 12345
        data[i] = if (i % 64 < 40) (rng.next() ushr 24) and 0x0F else (lcg ushr 16) and 0xFF
    }
    var mixed = 0
    for (round in 0 until 6) {
        mixed = mixed * 31 + fnv1a(data) + crc32(data) * (round + 1) + adler32(data)
        for (i in 0 until SIZE step 7) mixed += murmurMix(data[i] + i + mixed)
    }
    println("fnv ${fnv1a(data)} crc ${crc32(data)} adler ${adler32(data)} mixed $mixed")
    val rle = runLength(data)
    val (literals, matches) = lz(data)
    var h = 0
    for (v in rle) h = 31 * h + v
    println("rle ${rle.size} hash $h, lz literals $literals matches $matches")
    var hashes = 0
    for (i in 0 until SIZE * 4) hashes += "key$i".hashCode() * (i or 1)
    println("string hashes $hashes")
}
