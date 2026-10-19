data class P(val a: Long, val b: Long?)

fun sum3(a: Long?, b: Long): Long {
    if (a != null) return a + b
    return b
}

fun main() {
    val big = 5_000_000_000_000_000_000L
    val max = Long.MAX_VALUE
    val sb = StringBuilder()
    sb.append(big).append(' ').append(max).append("x").append(-big)
    println(sb)
    println(buildString { append(big); append(1L); append(max) })
    println(listOf(big, max).joinToString(","))
    println(listOf(big, max).joinToString { it.toString() })
    println(listOf(big, max).joinToString { "<$it>" })
    println(Pair(big, max))
    println(mapOf(big to max, 1L to 2L))
    println(P(big, null))
    println(P(big, max))
    println(P(big, max) == P(big, max))
    println(P(big, max).hashCode() == P(big, max).hashCode())
    println(String.format("%s|%10s|%-12s|", big, max, 5L))
    println("%s".format(big))
    println(big.toString().padStart(25, '0'))
    println(sum3(null, big))
    println(sum3(max - 1, 1))
    println(sum3(max, 1))
    val n: Long? = big
    if (n != null) println(n + 1)
    val m: Long? = if (big > 0) max else null
    println((m ?: 0L) + 1)
    println(m!! - 1)
    println(listOf(big, max, 5L).average())
    println(longArrayOf(big, max).average())
    println(listOf(3L, 1L, 2L).sortedBy { -it })
    println(listOf(big, max, 5L).maxByOrNull { it % 1000 })
    println(listOf(big, max, 5L).maxOf { it % 1000 })
    println(listOf(big, max, 5L).minOf { it })
    println(listOf(big, 1L).sortedByDescending { it })
    println(listOf(big, max).sumOf { it.toDouble() })
    val ms = System.currentTimeMillis()
    val elapsed = System.currentTimeMillis() - ms
    println(elapsed >= 0)
    println(elapsed < 1000L)
    val arr = LongArray(3)
    arr[0] = max
    arr[1] = arr[0] / 2
    arr[2] += big
    arr[2] -= 1
    println(arr.toList())
    arr.fill(big)
    println(arr.toList())
    val list = mutableListOf(1L, 2L)
    list[0] += big
    list[1] = list[1] * big
    println(list)
    var counter = 0L
    val inc = { counter += big }
    inc()
    inc()
    println(counter)
    val lazyBig by lazy { big * 2 }
    println(lazyBig)
    val e = when (big) {
        5_000_000_000_000_000_000L -> "match"
        else -> "no"
    }
    println(e)
    println(max.coerceIn(0L, big))
    println(Long.MAX_VALUE.toString().reversed())
    println(big.toString(10) == "5000000000000000000")
    println(java.lang.Long.valueOf(big))
    println(big.toBigInteger().multiply(big.toBigInteger()))
    println(java.math.BigInteger.valueOf(max).add(java.math.BigInteger.ONE).toLong())
    println(java.math.BigInteger("123456789012345678901").toLong())
    println(java.math.BigInteger("-9223372036854775808").longValueExact())
    println(java.math.BigDecimal.valueOf(big).toPlainString())
}
