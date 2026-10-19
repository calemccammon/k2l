import kotlin.math.absoluteValue

class Counter {
    var total: Long = 0
    var big: Long = 5_000_000_000_000_000_000L
    fun bump(by: Long): Long {
        total += by
        big++
        big -= 2
        return total
    }
}

object Consts {
    const val LIMIT = 9_000_000_000_000_000_000L
    val MASK = 0xFFFF_FFFF_FFFFL
}

interface Shape {
    val area: Long
}

class Sq(val side: Long) : Shape {
    override val area: Long get() = side * side
}

fun parse(s: String): Long? = s.toLongOrNull()

fun gcd(a: Long, b: Long): Long = if (b == 0L) a else gcd(b, a % b)

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

fun main() {
    val big = 5_000_000_000_000_000_000L
    val max = Long.MAX_VALUE
    println(big.plus(big))
    println(big.minus(-big))
    println(big.times(3))
    println(big.div(7))
    println(big.rem(7))
    println(big.inc())
    println(big.dec())
    println(big.unaryMinus())
    println(big.and(0xFFL))
    println(big.or(1))
    println(big.xor(max))
    println(big.shl(3))
    println(big.shr(3))
    println(big.ushr(3))
    println(Long.SIZE_BITS)
    println(Long.SIZE_BYTES)
    println(Long.MIN_VALUE.absoluteValue)
    println(Consts.LIMIT + Consts.LIMIT)
    println(Consts.MASK and big)
    val c = Counter()
    println(c.bump(big))
    println(c.bump(big))
    println(c.big)
    println(Sq(3_000_000_000L).area)
    println(Sq(3_037_000_500L).area)
    println(parse("9223372036854775807"))
    println(parse("x"))
    println(parse("9223372036854775808"))
    println(gcd(big, 1_000_000_007L * 1_000_003L))
    println(gcd(6_000_000_000_000_000_000L, 4_000_000_000_000_000_000L))
    println(modPow(2, 1_000_000_006L, 1_000_000_007L))
    println(modPow(3, big, 998_244_353L))
    println(modPow(123456789L, 987654321L, max))
    var h = 1125899906842597L
    for (ch in "hello world") h = 31 * h + ch.code
    println(h)
    var x = 88172645463325252L
    repeat(5) {
        x = x xor (x shl 13)
        x = x xor (x ushr 7)
        x = x xor (x shl 17)
        println(x)
    }
    val fact = (1..25).fold(1L) { acc, i -> acc * i }
    println(fact)
    val sumSq = (1L..2_000_000L).sumOf { it * it }
    println(sumSq)
    println((1..20).map { it.toLong() }.reduce { a, b -> a * b })
    println((big downTo big - 3).toList())
    println((1L..3L).reversed().toList())
    println((big..big + 2).count())
    println(listOf(1L, 2L, 3L).sum() / 2)
    println(generateSequence(big) { it - 1_000_000_000_000_000_000L }.takeWhile { it >= 0 }.toList())
    val seq = sequence {
        yield(big)
        yield(max)
    }
    println(seq.toList())
    println(seq.map { it / 3 }.sum())
    val pairs = listOf(big to 1L, max to 2L)
    println(pairs.map { (a, b) -> a + b })
    println(pairs.toMap())
    println(pairs.maxByOrNull { it.first })
    val nested = mapOf(big to mapOf(max to listOf(1L, big)))
    println(nested)
    println(nested[big]?.get(max)?.last())
    val text = "id=" + big + ";max=" + max
    println(text)
    println("$big$max".length)
    println("${big + 1}")
    println("a${-big}b")
    println(big.toString() + max.toString())
    println(buildString { for (i in 0L until 3L) append(big + i).append(',') })
    val unsigned = ULong.MAX_VALUE
    println(unsigned.toLong())
    println(unsigned / 3uL)
    println(unsigned.toString())
    println(unsigned - 1uL)
    println((unsigned - big.toULong()).toLong())
    println(big.toULong() * 4uL)
    println(max.toULong() + 1uL)
    println(max.toULong().toDouble())
    println(unsigned.toDouble())
}
