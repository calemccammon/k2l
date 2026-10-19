import java.math.BigInteger

class Name(val s: String) : CharSequence {
    override val length get() = s.length
    override fun get(index: Int) = s[index]
    override fun subSequence(startIndex: Int, endIndex: Int) = s.subSequence(startIndex, endIndex)
    override fun toString() = s
}

data class Score(val n: Int) : Comparable<Score> {
    override fun compareTo(other: Score) = n - other.n
}

enum class Dir { N, S }

fun kind(x: Any?): String = when (x) {
    null -> "null"
    is Number -> "number"
    is CharSequence -> "text(${x.length})"
    is Comparable<*> -> "comparable"
    else -> "other"
}

fun main() {
    val values = listOf(1, 2.5, 3L, "abc", StringBuilder("xy"), Name("name"), Score(1), Dir.S, true, listOf(1), Pair(1, 2), null, BigInteger.TEN)
    println(values.map(::kind))
    println(values.filterIsInstance<Comparable<*>>().size)
    println(values.filterIsInstance<CharSequence>().joinToString("|"))
    println(values.filterIsInstance<Number>().sumOf { it.toDouble() })
    val any: Any = "text"
    val cs = any as CharSequence
    println(cs.length)
    println((Score(2) as? Comparable<*>) != null)
    println((listOf(1) as? Comparable<*>) == null)
    val numbers = listOf<Number>(2.7, -3, 10L, BigInteger.valueOf(300), -3300000000.5)
    println(numbers.map { "${it.toInt()} ${it.toLong()} ${it.toShort()} ${it.toByte()} ${it.toDouble()}" })
}
