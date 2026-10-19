// Compiled with long64=emulate (see options.txt): Long arithmetic is exact 64-bit on Lua 5.1, 5.2 and LuaJIT.
import kotlin.math.sign

data class Account(val id: Long, val balance: Long)

fun fib(n: Int): Long {
    var a = 0L
    var b = 1L
    repeat(n) {
        val t = a + b
        a = b
        b = t
    }
    return a
}

fun collatz(start: Long): Int {
    var n = start
    var steps = 0
    while (n != 1L) {
        n = if (n % 2 == 0L) n / 2 else 3 * n + 1
        steps++
    }
    return steps
}

fun <T : Comparable<T>> larger(a: T, b: T): T = if (a > b) a else b

fun describe(x: Any): String = when (x) {
    is Long -> "long $x"
    is Int -> "int $x"
    is String -> "string $x"
    else -> "other"
}

fun classify(n: Long): String = when (n) {
    0L -> "zero"
    Long.MAX_VALUE -> "max"
    Long.MIN_VALUE -> "min"
    in 1L..1000L -> "small"
    in 1001L..Long.MAX_VALUE -> "large"
    else -> "negative"
}

fun main() {
    val big = 5_000_000_000_000_000_000L
    val max = Long.MAX_VALUE
    val min = Long.MIN_VALUE

    // arithmetic wraps like the JVM
    println(max + 1)
    println(min - 1)
    println(big * 3)
    println(-min)
    println(min / -1)
    println(max * max)
    println(big + big)
    println(1L - 3)
    println(7 + 2L * big / 4)
    println((big + 1) % 1000)
    println((-big - 1) % 1000)
    println((-big - 1) / 1000)
    println(max % -1000)
    println(fib(90))
    println(fib(92) + fib(91))
    println(collatz(837799L))
    println(collatz(1000000000039L))

    // compound assignment and increments
    var v = max - 2
    v++
    v++
    println(v)
    v++
    println(v)
    v -= 5
    println(v)
    v *= 2
    println(v)
    v /= 3
    println(v)
    v %= 1000003
    println(v)
    var w = min + 1
    w--
    println(w)
    w--
    println(w)
    println(-w)

    // division by zero
    try {
        println(big / (big - big))
    } catch (e: ArithmeticException) {
        println(e.message)
    }
    try {
        println(big % 0L)
    } catch (e: ArithmeticException) {
        println(e.message)
    }

    // bit operations
    println(big and 0xFFFFFFFFL)
    println(big or 1L)
    println(big xor max)
    println(big.inv())
    println(1L shl 63)
    println(min ushr 63)
    println(min ushr 1)
    println(-1L ushr 60)
    println(-256L shr 4)
    println(big shr 20)
    println(big shl 3)
    println(0xCAFEBABEL shl 32 or 0xDEADBEEFL)
    println((0xCAFEBABEL shl 32 or 0xDEADBEEFL).countOneBits())
    println(big.countLeadingZeroBits())
    println(big.countTrailingZeroBits())
    println(big.takeHighestOneBit())
    println(big.takeLowestOneBit())
    println(big.rotateLeft(13))
    println(big.rotateRight(13))
    println(min.countLeadingZeroBits())

    // conversions
    println(big.toInt())
    println((big + 12345).toInt())
    println(max.toInt())
    println(min.toInt())
    println(big.toShort())
    println(big.toByte())
    println(big.toDouble())
    println(max.toDouble())
    println(min.toFloat())
    println(12345678901L.toFloat())
    println(1e19.toLong())
    println(-1e19.toLong())
    println(9.223372036854775E18.toLong())
    println(4.611686018427388E18.toLong())
    println(1234567890123456789.0.toLong())
    println(Double.NaN.toLong())
    println(3.99.toLong())
    println((-3.99).toLong())
    println(123456789L.toBigInteger() * 1000000000000L.toBigInteger())
    println(big.toULong())
    println((-1L).toULong())
    println(max.toString(16))
    println(min.toString(2))
    println(big.toString(36))
    println((-big).toString(7))
    println("9223372036854775807".toLong())
    println("-9223372036854775808".toLong())
    println("9223372036854775808".toLongOrNull())
    println("-9223372036854775809".toLongOrNull())
    println("12x".toLongOrNull())
    println("".toLongOrNull())
    println("+77".toLong())
    println("ff".toLong(16))
    println("7fffffffffffffff".toLong(16))
    try {
        "9223372036854775808".toLong()
    } catch (e: NumberFormatException) {
        println(e.message)
    }
    println(java.lang.Long.parseLong("-4611686018427387904"))
    println(Math.floorMod(-big, 7L))
    println(Math.floorDiv(-big, 7L))
    println((-big).mod(7L))
    println((-big).floorDiv(7L))
    println(Math.abs(-big))
    println(Math.abs(min))
    println(kotlin.math.abs(-big))
    println(maxOf(big, -big))
    println(minOf(big, -big, 0L))
    println(Math.max(big, max))
    println((-big).coerceAtLeast(-7L))
    println(big.coerceAtMost(99L))
    println(big.coerceIn(-5L, max))
    println(big.compareTo(max))
    println(max.compareTo(big))
    println(big.compareTo(big))
    println((-big).sign)
    println(big.sign)

    // comparison and equality
    println(big < max)
    println(big > max)
    println(big <= big)
    println(min < max)
    println(min < 0)
    println(0 < min)
    println(max >= big + big)
    println(big == 5000000000000000000L)
    println(big != big + 1)
    println(big.equals(big))
    println(big.equals(5000000000000000001L))
    val boxed: Long? = big
    println(boxed == big)
    println(boxed == null)
    println(larger(big, -big))
    println(larger(3L, 4L))
    println(listOf(max, min, 0L, big, -big, 1L).sorted())
    println(listOf(max, min, 0L, big, -big, 1L).sortedDescending())
    println(listOf(max, min, 0L, big).maxOrNull())
    println(listOf(max, min, 0L, big).minOrNull())

    // text
    println("big=$big, max=${max}, min=$min")
    println(big.toString().length)
    println("%d|%5d|%x".format(1L, 22L, 255L))
    println(String.format("%d", big))
    println(String.format("%,d", max))
    println(String.format("%x", big))
    println(String.format("%020d", min))
    println("%d".format(min))
    println(max.hashCode())
    println(min.hashCode())
    println(big.hashCode())
    println(1234567890123L.hashCode())

    // collections
    val ids = listOf(big, max, 17L, big + 1, min)
    println(ids)
    println(ids.sum())
    println(ids.sumOf { it / 2 })
    println(ids.map { it % 100 })
    println(ids.filter { it > 100 })
    println(ids.indexOf(max))
    println(ids.contains(big))
    println(ids.count { it < 0 })
    println(ids.fold(1L) { acc, x -> acc * 31 + x })
    println(ids.reduce { a, b -> a xor b })
    println(ids.distinct().size)
    println(ids.zip(ids.drop(1)).map { (a, b) -> b - a })
    println(ids.associateWith { it.countOneBits() })
    val counts = HashMap<Long, Int>()
    for (x in ids + ids) counts[x] = (counts[x] ?: 0) + 1
    println(counts.size)
    println(counts[max])
    println(counts[big + 1])
    println(counts[12345L])
    val set = HashSet<Long>()
    set.add(max)
    set.add(Long.MAX_VALUE)
    set.add(max - 1)
    set.add(3L)
    println(set.size)
    println(set.contains(max))
    println(max in set)
    val sorted = java.util.TreeMap<Long, String>()
    sorted[big] = "big"
    sorted[min] = "min"
    sorted[3L] = "three"
    sorted[max] = "max"
    println(sorted)
    println(sorted.firstKey())
    println(sorted.lastKey())
    val accounts = listOf(Account(max, big), Account(1L, 2L), Account(max, big))
    println(accounts[0])
    println(accounts[0] == accounts[2])
    println(accounts[0] == accounts[1])
    println(accounts.toSet().size)
    println(accounts[0].hashCode() == accounts[2].hashCode())
    println(accounts.groupBy { it.id }.mapValues { it.value.size })
    println(accounts.sumOf { it.balance })
    println(accounts.maxByOrNull { it.balance })
    val arr = longArrayOf(big, 1L, max, min)
    println(arr.sum())
    println(arr.max())
    println(arr.min())
    println(arr.sorted())
    arr[1] = arr[0] * 2
    println(arr.contentToString())
    println(arr.size)

    // ranges and loops
    var total = 0L
    for (i in 1L..100000L) total += i * i
    println(total)
    for (i in big downTo big - 2) print("$i ")
    println()
    for (i in 0L until 10L step 4L) print("$i ")
    println()
    for (i in 10L downTo 0L step 5L) print("$i ")
    println()
    println(3L in 1L..5L)
    println(big in 1L..max)
    println(big !in 1L until big)
    println(min in min..max)
    println(classify(0L))
    println(classify(max))
    println(classify(min))
    println(classify(500L))
    println(classify(big))
    println(classify(-5L))
    println((1L..5L).toList())
    println((1L..5L).map { it * big })
    println((1L..5L).sum())
    println(generateSequence(1L) { it * 3 }.take(45).last())
    println(generateSequence(big) { it / 7 }.takeWhile { it > 0 }.toList())

    // Any
    println(describe(big))
    println(describe("x"))
    val anys = listOf<Any>(big, "s", max)
    println(anys)
    println(anys.filterIsInstance<Long>().sum())
    val anyBig: Any = big
    println(anyBig == big)
    println(anyBig.equals(5000000000000000000L))
    println(anyBig.hashCode())
    println(anyBig as Long + 1)

    // random access and indices
    val table = LongArray(5) { it * big }
    println(table.toList())
    val m = mutableMapOf<Long, MutableList<Long>>()
    for (i in 0L until 6L) m.getOrPut(i % 3 * big) { mutableListOf() }.add(i)
    println(m)
}
