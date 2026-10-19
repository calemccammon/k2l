import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.ln
import kotlin.math.sqrt

// Number crunching: big factorials and binomials, modular arithmetic on Longs,
// rational numbers with operator overloading, numeric integration and Double formatting.

fun factorial(n: Int): BigInteger = (2..n).fold(BigInteger.ONE) { acc, i -> acc * i.toBigInteger() }

fun binomial(n: Int, k: Int): BigInteger {
    var result = BigInteger.ONE
    for (i in 0 until k) result = result * BigInteger.valueOf((n - i).toLong()) / BigInteger.valueOf((i + 1).toLong())
    return result
}

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

tailrec fun gcd(a: Long, b: Long): Long = if (b == 0L) abs(a) else gcd(b, a % b)
fun lcm(a: Long, b: Long): Long = a / gcd(a, b) * b

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

fun isPrime(n: Long): Boolean {
    if (n < 2) return false
    if (n % 2 == 0L) return n == 2L
    var d = 3L
    while (d * d <= n) {
        if (n % d == 0L) return false
        d += 2
    }
    return true
}

fun primeFactors(n: Long): Map<Long, Int> {
    val factors = linkedMapOf<Long, Int>()
    var x = n
    var p = 2L
    while (p * p <= x) {
        while (x % p == 0L) {
            factors.merge(p, 1, Int::plus)
            x /= p
        }
        p++
    }
    if (x > 1) factors[x] = (factors[x] ?: 0) + 1
    return factors
}

class Rational private constructor(val num: BigInteger, val den: BigInteger) : Comparable<Rational> {
    operator fun plus(o: Rational) = of(num * o.den + o.num * den, den * o.den)
    operator fun minus(o: Rational) = of(num * o.den - o.num * den, den * o.den)
    operator fun times(o: Rational) = of(num * o.num, den * o.den)
    operator fun div(o: Rational): Rational {
        if (o.num.signum() == 0) throw ArithmeticException("division by zero rational")
        return of(num * o.den, den * o.num)
    }
    operator fun unaryMinus() = Rational(-num, den)
    override fun compareTo(other: Rational) = (num * other.den).compareTo(other.num * den)
    override fun equals(other: Any?) = other is Rational && num == other.num && den == other.den
    override fun hashCode() = 31 * num.hashCode() + den.hashCode()
    override fun toString() = if (den == BigInteger.ONE) "$num" else "$num/$den"
    fun toDouble() = num.toDouble() / den.toDouble()

    companion object {
        val ZERO = of(0)
        fun of(n: Long, d: Long = 1) = of(n.toBigInteger(), d.toBigInteger())
        fun of(n: BigInteger, d: BigInteger): Rational {
            require(d.signum() != 0) { "denominator is zero" }
            val g = n.gcd(d).let { if (d.signum() < 0) -it else it }
            return Rational(n / g, d / g)
        }
    }
}

fun Int.r() = Rational.of(this.toLong())

fun harmonic(n: Int) = (1..n).fold(Rational.ZERO) { acc, k -> acc + Rational.of(1, k.toLong()) }

fun bernoulli(n: Int): Rational {
    val a = Array(n + 1) { Rational.ZERO }
    for (m in 0..n) {
        a[m] = Rational.of(1, (m + 1).toLong())
        for (j in m downTo 1) a[j - 1] = j.r() * (a[j - 1] - a[j])
    }
    return a[0]
}

inline fun integrate(from: Double, to: Double, steps: Int = 1000, f: (Double) -> Double): Double {
    val h = (to - from) / steps
    var sum = f(from) + f(to)
    for (i in 1 until steps) sum += f(from + i * h) * if (i % 2 == 1) 4 else 2
    return sum * h / 3
}

fun sqrtNewton(x: Double, eps: Double = 1e-12): Double {
    var guess = x / 2
    var iterations = 0
    while (abs(guess * guess - x) > eps * x) {
        guess = (guess + x / guess) / 2
        iterations++
        check(iterations < 100) { "did not converge" }
    }
    return guess
}

fun main() {
    println("20! = ${factorial(20)} (fits in Long: ${factorial(20) <= Long.MAX_VALUE.toBigInteger()})")
    println("25! = ${factorial(25)}")
    val f100 = factorial(100)
    println("100! has ${f100.toString().length} digits, digit sum ${f100.toString().sumOf { it.digitToInt() }}, trailing zeros ${f100.toString().takeLastWhile { it == '0' }.length}")
    println("C(50, 25) = ${binomial(50, 25)}, C(100, 3) = ${binomial(100, 3)}")
    println("pascal row 10: ${(0..10).map { binomial(10, it) }}")
    println("F(100) = ${bigFib(100)}")
    println("F(300) mod 1e9+7 = ${bigFib(300).mod(BigInteger.valueOf(1_000_000_007))}")
    println("2^100 = ${BigInteger.TWO.pow(100)}, bits ${BigInteger.TWO.pow(100).bitLength()}")
    println("3^200 mod 1000007 = ${BigInteger.valueOf(3).modPow(BigInteger.valueOf(200), BigInteger.valueOf(1000007))} vs ${modPow(3, 200, 1000007)}")

    println("gcd(1071, 462) = ${gcd(1071, 462)}, lcm(1..20) = ${(1L..20L).reduce(::lcm)}")
    println("2^62 = ${1L shl 62}, Long.MAX_VALUE / 7 = ${Long.MAX_VALUE / 7}, -17 mod 5 = ${-17 % 5} / ${(-17).mod(5)} / ${Math.floorMod(-17L, 5L)}")
    println("big modpow: ${modPow(2, 1_000_000, 1_000_000_007)} ${modPow(12345, 6789, 999_983)}")
    println("primes near 1e9: ${(1_000_000_000L..1_000_000_100L).filter(::isPrime)}")
    println("factors: ${primeFactors(600851475143)} ${primeFactors(360)} ${primeFactors(9_999_999_967)}")
    val divisorSum = { n: Long -> primeFactors(n).entries.fold(1L) { acc, (p, e) -> acc * ((1..e).fold(1L) { s, _ -> s * p + 1 }) } }
    println("sigma(360) = ${divisorSum(360)}, perfect: ${(2L..10_000L).filter { divisorSum(it) == 2 * it }}")

    println("H(10) = ${harmonic(10)} ≈ ${"%.6f".format(harmonic(10).toDouble())}, ln(10)+γ ≈ ${"%.6f".format(ln(10.0) + 0.5772156649)}")
    println("bernoulli: ${(0..12).map { bernoulli(it) }}")
    val third = Rational.of(1, 3)
    println("1/3 + 1/6 = ${third + Rational.of(1, 6)}, -(2/4) = ${-Rational.of(2, 4)}, (3/4)/(1/8) = ${Rational.of(3, 4) / Rational.of(1, 8)}")
    println("sorted: ${listOf(Rational.of(3, 7), Rational.of(1, 2), Rational.of(-2, 5), 1.r()).sorted()}")
    println("set: ${setOf(Rational.of(2, 4), Rational.of(1, 2), Rational.of(3, 6)).size}")
    try {
        third / Rational.ZERO
    } catch (e: ArithmeticException) {
        println("caught: ${e.message}")
    }
    println(runCatching { Rational.of(1, 0) }.exceptionOrNull()?.message)

    val pi = integrate(0.0, 1.0) { 4 / (1 + it * it) }
    println("pi ≈ ${"%.12f".format(pi)} error ${"%.2e".format(abs(pi - PI))}")
    val gauss = integrate(-5.0, 5.0, 2000) { kotlin.math.exp(-it * it / 2) } / sqrt(2 * PI)
    println("gaussian area ≈ ${"%.8f".format(gauss)}")
    for (x in listOf(2.0, 10.0, 12345.678)) println("sqrt($x) = ${"%.10f".format(sqrtNewton(x))} (${sqrt(x)})")
    println("doubles: ${0.1 + 0.2} ${1.0 / 3} ${2.0 / 3 * 3} ${1e20} ${1.5e-7} ${100.0} ${-0.0} ${Double.MAX_VALUE}")
    println("format: ${"%8.3f|%-8.2f|%08.2f|%+.1e|%,d".format(PI, -PI, 3.14159, 12345.678, 1234567890L)}")
    println("rounding: ${listOf(2.5, 3.5, -2.5, 0.125).map { Math.round(it) }} ${listOf(1.005, 2.675).map { "%.2f".format(it) }}")
    val bd = BigDecimal("10").divide(BigDecimal("3"), 20, RoundingMode.HALF_UP)
    println("10/3 = $bd, scaled ${bd.setScale(4, RoundingMode.DOWN)}, money ${BigDecimal("19.99") * BigDecimal(3)}")
    val compound = (1..10).fold(BigDecimal("1000.00")) { acc, _ -> (acc * BigDecimal("1.05")).setScale(2, RoundingMode.HALF_EVEN) }
    println("compound interest: $compound")
    println("Int ops: ${Int.MAX_VALUE.toLong() + 1} ${(1 shl 30) * 2L} ${Integer.toHexString(255)} ${"ff".toInt(16)} ${0b1011} ${Long.MIN_VALUE}")
}
