// sumOf with a BigInteger or BigDecimal selector over a sequence starts from that type's zero, as over a list.
import java.math.BigDecimal
import java.math.BigInteger

fun main() {
    val nums = sequenceOf(1, 2, 3)
    println(nums.sumOf { BigInteger.valueOf(it.toLong()).pow(20) })
    println(nums.sumOf { BigDecimal("0.1").multiply(BigDecimal(it)) })
    println(emptySequence<Int>().sumOf { BigInteger.valueOf(it.toLong()) })
    println(emptySequence<Int>().sumOf { BigDecimal(it) })
    println(generateSequence(1) { it + 1 }.take(30).sumOf { BigInteger.TWO.pow(it) })
    println(listOf(1, 2, 3).sumOf { BigDecimal("1.5") })
}
