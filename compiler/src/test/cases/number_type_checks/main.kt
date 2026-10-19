import java.math.BigDecimal
import java.math.BigInteger

// `is Number`, `as? Number` and filterIsInstance<Number>() over mixed values.

fun describe(x: Any?): String = when (x) {
    null -> "null"
    is Number -> "number ${x.toDouble()}"
    is String -> "text '$x'"
    else -> "other $x"
}

fun main() {
    val values: List<Any?> = listOf(1, 2.5, "3", 4L, null, BigInteger.TEN, BigDecimal("1.5"), listOf(1), true, 3.0f)
    values.forEach { println(describe(it)) }
    println(values.filterIsInstance<Number>().size)
    println(values.map { (it as? Number)?.toInt() })
    println(values.count { it !is Number })
    val total = values.filterIsInstance<Number>().sumOf { it.toDouble() }
    println(total)
}
