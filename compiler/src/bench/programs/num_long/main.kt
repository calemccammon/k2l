// Adapted from realworld_dynprog and realworld_bignum: Long arithmetic in loops (modular exponentiation, dynamic
// programming over LongArrays, gcd, prime counting, bit tricks). Values stay below 2^53, so the default
// `--long64 double` is exact on every target.

const val SIZE = 300_000 // sieve limit and loop counts
const val MOD = 67_108_859L // a prime below 2^26: products of two residues stay below 2^53

fun modPow(base: Long, exp: Long, mod: Long): Long {
    var result = 1L
    var b = base % mod
    var e = exp
    while (e > 0) {
        if (e and 1L == 1L) result = result * b % mod
        b = b * b % mod
        e = e shr 1
    }
    return result
}

tailrec fun gcd(a: Long, b: Long): Long = if (b == 0L) a else gcd(b, a % b)

fun coinWays(amount: Int, coins: IntArray): Long {
    val ways = LongArray(amount + 1)
    ways[0] = 1
    for (c in coins) for (v in c..amount) ways[v] = (ways[v] + ways[v - c]) % MOD
    return ways[amount]
}

fun lcsLength(a: String, b: String): Long {
    var prev = LongArray(b.length + 1)
    var cur = LongArray(b.length + 1)
    for (i in 1..a.length) {
        for (j in 1..b.length) {
            cur[j] = if (a[i - 1] == b[j - 1]) prev[j - 1] + 1 else maxOf(prev[j], cur[j - 1])
        }
        val t = prev
        prev = cur
        cur = t
    }
    return prev[b.length]
}

fun popcount(x0: Long): Int {
    var x = x0
    var n = 0
    while (x != 0L) {
        x = x and (x - 1)
        n++
    }
    return n
}

fun main() {
    var checksum = 0L
    for (i in 1..SIZE / 20) checksum = (checksum + modPow(i.toLong(), (i * 7919).toLong(), MOD)) % MOD
    println("modpow sum $checksum")

    val composite = BooleanArray(SIZE + 1)
    var primeSum = 0L
    var count = 0
    for (i in 2..SIZE) {
        if (composite[i]) continue
        count++
        primeSum += i.toLong() * i
        var j = i.toLong() * i
        while (j <= SIZE) {
            composite[j.toInt()] = true
            j += i
        }
    }
    println("primes $count, sum of squares $primeSum")

    var g = 0L
    for (i in 1..SIZE / 2) g += gcd(i.toLong() * 1_000_003, (i.toLong() * 7 + 13) * 999_983)
    println("gcd sum $g")
    println("coin ways ${coinWays(SIZE / 20, intArrayOf(1, 2, 5, 10, 20, 50, 100, 200))}")
    val a = (0 until 600).map { 'a' + (it * 7 % 13) }.joinToString("")
    val b = (0 until 600).map { 'a' + (it * 5 % 11) }.joinToString("")
    println("lcs ${lcsLength(a, b)}")
    var bits = 0L
    var x = 0x1234_5678_9ABCL
    for (i in 0 until SIZE) {
        x = (x * 5 + 17) % (1L shl 48)
        bits += popcount(x) + (x shr 40) + (x and 0xFFF)
    }
    println("bits $bits, avg ${bits / SIZE}")
}
