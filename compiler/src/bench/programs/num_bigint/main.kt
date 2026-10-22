// Adapted from realworld_bignum: arbitrary-precision arithmetic written in Kotlin (factorials, Fibonacci, binomials, modPow,
// gcd, toString) on little-endian base-10^4 limbs, and a Rational class with operator overloading over them.

const val SIZE = 1500 // factorial / Fibonacci size
const val BASE = 10000

/** A non-negative integer: `limbs[0]` is the least significant base-10^4 digit, with no leading zero limbs. */
class Big private constructor(private val limbs: IntArray) : Comparable<Big> {
    val isZero get() = limbs.isEmpty()

    operator fun plus(o: Big): Big {
        val n = maxOf(limbs.size, o.limbs.size)
        val out = IntArray(n + 1)
        var carry = 0
        for (i in 0 until n) {
            val s = limb(i) + o.limb(i) + carry
            out[i] = s % BASE
            carry = s / BASE
        }
        out[n] = carry
        return of(out)
    }

    /** `this - o`, for `o <= this`. */
    operator fun minus(o: Big): Big {
        val out = IntArray(limbs.size)
        var borrow = 0
        for (i in limbs.indices) {
            var d = limbs[i] - o.limb(i) - borrow
            borrow = if (d < 0) 1 else 0
            if (d < 0) d += BASE
            out[i] = d
        }
        return of(out)
    }

    operator fun times(o: Big): Big {
        if (isZero || o.isZero) return ZERO
        val out = IntArray(limbs.size + o.limbs.size)
        for (i in limbs.indices) {
            var carry = 0
            val a = limbs[i]
            for (j in o.limbs.indices) {
                val t = out[i + j] + a * o.limbs[j] + carry
                out[i + j] = t % BASE
                carry = t / BASE
            }
            var k = i + o.limbs.size
            while (carry > 0) {
                val t = out[k] + carry
                out[k] = t % BASE
                carry = t / BASE
                k++
            }
        }
        return of(out)
    }

    fun timesSmall(m: Int): Big {
        val out = IntArray(limbs.size + 3)
        var carry = 0
        for (i in limbs.indices) {
            val t = limbs[i] * m + carry
            out[i] = t % BASE
            carry = t / BASE
        }
        var k = limbs.size
        while (carry > 0) {
            out[k] = carry % BASE
            carry /= BASE
            k++
        }
        return of(out)
    }

    /** The quotient and remainder of a division by `d` (below 10^9). */
    fun divSmall(d: Int): Pair<Big, Int> {
        val out = IntArray(limbs.size)
        var rem = 0L
        for (i in limbs.indices.reversed()) {
            val cur = rem * BASE + limbs[i]
            out[i] = (cur / d).toInt()
            rem = cur % d
        }
        return of(out) to rem.toInt()
    }

    /** Long division: each quotient limb found by binary search. */
    fun divMod(d: Big): Pair<Big, Big> {
        if (this < d) return ZERO to this
        if (d.limbs.size == 1) return divSmall(d.limbs[0]).let { (q, r) -> q to valueOf(r.toLong()) }
        val out = IntArray(limbs.size)
        var rem = ZERO
        for (i in limbs.indices.reversed()) {
            rem = rem.shiftLimb(limbs[i])
            var lo = 0
            var hi = BASE - 1
            while (lo < hi) {
                val mid = (lo + hi + 1) / 2
                if (d.timesSmall(mid) <= rem) lo = mid else hi = mid - 1
            }
            out[i] = lo
            if (lo > 0) rem -= d.timesSmall(lo)
        }
        return of(out) to rem
    }

    operator fun div(d: Big) = divMod(d).first
    operator fun rem(d: Big) = divMod(d).second

    fun gcd(o: Big): Big {
        var a = this
        var b = o
        while (!b.isZero) {
            val t = a % b
            a = b
            b = t
        }
        return a
    }

    fun modPow(e: Long, m: Big): Big {
        var result = ONE
        var base = this % m
        var k = e
        while (k > 0) {
            if (k % 2 == 1L) result = result * base % m
            base = base * base % m
            k /= 2
        }
        return result
    }

    private fun limb(i: Int) = if (i < limbs.size) limbs[i] else 0

    /** `this * BASE + low`. */
    private fun shiftLimb(low: Int): Big {
        val out = IntArray(limbs.size + 1)
        out[0] = low
        limbs.copyInto(out, 1)
        return of(out)
    }

    override fun compareTo(other: Big): Int {
        if (limbs.size != other.limbs.size) return limbs.size - other.limbs.size
        for (i in limbs.indices.reversed()) {
            if (limbs[i] != other.limbs[i]) return limbs[i] - other.limbs[i]
        }
        return 0
    }

    override fun equals(other: Any?) = other is Big && compareTo(other) == 0
    override fun hashCode() = limbs.contentHashCode()

    override fun toString(): String {
        if (isZero) return "0"
        val sb = StringBuilder()
        sb.append(limbs.last())
        for (i in limbs.size - 2 downTo 0) sb.append(limbs[i].toString().padStart(4, '0'))
        return sb.toString()
    }

    companion object {
        val ZERO = Big(IntArray(0))
        val ONE = valueOf(1)

        fun powerOfTwo(e: Int): Big {
            var result = ONE
            repeat(e) { result = result.timesSmall(2) }
            return result
        }

        fun valueOf(v: Long): Big {
            val out = ArrayList<Int>()
            var x = v
            while (x > 0) {
                out.add((x % BASE).toInt())
                x /= BASE
            }
            return Big(out.toIntArray())
        }

        private fun of(raw: IntArray): Big {
            var n = raw.size
            while (n > 0 && raw[n - 1] == 0) n--
            return Big(if (n == raw.size) raw else raw.copyOf(n))
        }
    }
}

fun factorial(n: Int): Big = (2..n).fold(Big.ONE) { acc, i -> acc.timesSmall(i) }

fun bigFib(n: Int): Big {
    var a = Big.ZERO
    var b = Big.ONE
    repeat(n) {
        val t = a + b
        a = b
        b = t
    }
    return a
}

fun binomial(n: Int, k: Int): Big {
    var result = Big.ONE
    for (i in 0 until k) result = result.timesSmall(n - i).divSmall(i + 1).first
    return result
}

class Rational private constructor(val num: Big, val den: Big) {
    operator fun plus(o: Rational) = of(num * o.den + o.num * den, den * o.den)
    operator fun times(o: Rational) = of(num * o.num, den * o.den)
    override fun toString() = if (den == Big.ONE) "$num" else "$num/$den"

    companion object {
        val ZERO = of(Big.ZERO, Big.ONE)
        fun of(n: Long, d: Long) = of(Big.valueOf(n), Big.valueOf(d))
        fun of(n: Big, d: Big): Rational {
            val g = n.gcd(d)
            return Rational(n / g, d / g)
        }
    }
}

fun main() {
    val f = factorial(SIZE)
    val digits = f.toString()
    println("$SIZE! has ${digits.length} digits, digit sum ${digits.sumOf { it.digitToInt() }}")
    val fib = bigFib(SIZE * 4)
    println("F(${SIZE * 4}) mod 1e9+7 = ${fib.divSmall(1_000_000_007).second}, digits ${fib.toString().length}")
    var rows = Big.ZERO
    for (n in 0..SIZE / 3 step 10) for (k in 0..n step 7) rows += binomial(n, k)
    println("binomials ${rows.toString().takeLast(20)}")
    val m = Big.powerOfTwo(127) - Big.ONE
    var pw = Big.ZERO
    for (i in 1..SIZE / 60) pw += Big.valueOf(i.toLong() + 3).modPow(i.toLong() * 1000 + 1, m)
    println("modpow ${pw % m}")
    val h = (1..SIZE / 20).fold(Rational.ZERO) { acc, k -> acc + Rational.of(1, k.toLong()) }
    println("harmonic ${h.toString().length} chars, ${h.toString().take(24)}")
    val g = (1..SIZE / 10).fold(Big.ZERO) { acc, i -> acc + factorial(i % 40 + 20).gcd(bigFib(i % 90 + 10)) }
    println("gcds $g")
}
