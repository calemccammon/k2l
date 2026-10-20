import java.math.BigInteger

// Adapted from realworld_bignum: BigInteger arithmetic (factorials, Fibonacci, binomials, modPow, gcd, toString)
// and a Rational class with operator overloading over BigIntegers.

const val SIZE = 1500 // factorial / Fibonacci size

fun factorial(n: Int): BigInteger = (2..n).fold(BigInteger.ONE) { acc, i -> acc * i.toBigInteger() }

fun bigFib(n: Int): BigInteger {
    var a = BigInteger.ZERO
    var b = BigInteger.ONE
    repeat(n) {
        val t = a + b
        a = b
        b = t
    }
    return a
}

fun binomial(n: Int, k: Int): BigInteger {
    var result = BigInteger.ONE
    for (i in 0 until k) result = result * BigInteger.valueOf((n - i).toLong()) / BigInteger.valueOf((i + 1).toLong())
    return result
}

class Rational private constructor(val num: BigInteger, val den: BigInteger) {
    operator fun plus(o: Rational) = of(num * o.den + o.num * den, den * o.den)
    operator fun times(o: Rational) = of(num * o.num, den * o.den)
    override fun toString() = if (den == BigInteger.ONE) "$num" else "$num/$den"

    companion object {
        val ZERO = of(BigInteger.ZERO, BigInteger.ONE)
        fun of(n: Long, d: Long) = of(n.toBigInteger(), d.toBigInteger())
        fun of(n: BigInteger, d: BigInteger): Rational {
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
    println("F(${SIZE * 4}) mod 1e9+7 = ${fib.mod(BigInteger.valueOf(1_000_000_007))}, bits ${fib.bitLength()}")
    var rows = BigInteger.ZERO
    for (n in 0..SIZE / 3 step 10) for (k in 0..n step 7) rows += binomial(n, k)
    println("binomials ${rows.toString().takeLast(20)}")
    val m = BigInteger.TWO.pow(127) - BigInteger.ONE
    var pw = BigInteger.ZERO
    for (i in 1..SIZE / 20) pw += BigInteger.valueOf(i.toLong() + 3).modPow(BigInteger.valueOf(i.toLong() * 1000 + 1), m)
    println("modpow ${pw.mod(m)}")
    val h = (1..SIZE / 6).fold(Rational.ZERO) { acc, k -> acc + Rational.of(1, k.toLong()) }
    println("harmonic ${h.toString().length} chars, ${h.toString().take(24)}")
    val g = (1..SIZE).fold(BigInteger.ZERO) { acc, i -> acc + factorial(i % 40 + 20).gcd(bigFib(i % 90 + 10)) }
    println("gcds $g")
}
