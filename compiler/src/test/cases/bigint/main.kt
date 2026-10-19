import java.math.BigInteger

fun factorial(n: Int): BigInteger {
    var result = BigInteger.ONE
    for (i in 2..n) result *= BigInteger.valueOf(i.toLong())
    return result
}

fun fibonacci(n: Int): BigInteger {
    var a = BigInteger.ZERO
    var b = BigInteger.ONE
    repeat(n) {
        val next = a + b
        a = b
        b = next
    }
    return a
}

fun construction() {
    println("-- construction")
    println(BigInteger("123456789012345678901234567890"))
    println(BigInteger("-0042"))
    println(BigInteger("+17"))
    println(BigInteger("ff", 16))
    println(BigInteger("-FF", 16))
    println(BigInteger("101101", 2))
    println(BigInteger("zz", 36))
    println(BigInteger("0"))
    println(BigInteger("-0"))
    println(BigInteger.valueOf(-9007199254740991L))
    println(42.toBigInteger())
    println((-7L).toBigInteger())
    println("98765432109876543210".toBigInteger())
    println("1f".toBigInteger(16))
    println("12x".toBigIntegerOrNull())
    println("-12".toBigIntegerOrNull())
    println("+12".toBigIntegerOrNull())
    println("".toBigIntegerOrNull())
    println(BigInteger.ZERO)
    println(BigInteger.ONE)
    println(BigInteger.TWO)
    println(BigInteger.TEN)
}

fun big() {
    println("-- big values")
    println(factorial(50))
    println(factorial(25).toString(16))
    println(factorial(30).toString(2))
    println(factorial(20).toString(36))
    println(BigInteger.TWO.pow(200))
    println(BigInteger.TWO.pow(200).toString(16))
    println(BigInteger.TWO.pow(64) - BigInteger.ONE)
    println(fibonacci(300))
    println(BigInteger.TEN.pow(40) + BigInteger.ONE)
    println(factorial(40) / factorial(38))
    println(factorial(60) % BigInteger("1000000007"))
    println((-factorial(22)).toString(7))
}

fun divisions() {
    println("-- division")
    val values = listOf("7", "-7", "1000000000000000000000", "-1000000000000000000001")
    val divisors = listOf("2", "-2", "3", "123456789123456789", "-99999999999999999999")
    for (a in values) {
        for (b in divisors) {
            val x = BigInteger(a)
            val y = BigInteger(b)
            val qr = x.divideAndRemainder(y)
            println("$a / $b = ${x / y} rem ${x % y} mod ${x.mod(y.abs())} qr=${qr[0]},${qr[1]} ${(x / y) * y + x % y == x}")
        }
    }
    val huge = BigInteger("98765432109876543210987654321098765432109876543210")
    val divisor = BigInteger("12345678901234567890123")
    println(huge / divisor)
    println(huge % divisor)
    println(huge.remainder(divisor.negate()))
    println(huge.divide(BigInteger.valueOf(10000000)))
    println(BigInteger("100000000000000000000000000000000").divide(BigInteger("10000000000000000")))
    println(BigInteger("99999999999999999999999999999999").divide(BigInteger("99999999999999999")))
}

fun bits() {
    println("-- bits")
    val values = listOf("0", "1", "-1", "255", "-256", "123456789012345678901234567890", "-123456789012345678901234567890")
    for (a in values) {
        val x = BigInteger(a)
        println("$a: bitLength=${x.bitLength()} bitCount=${x.bitCount()} lowest=${x.getLowestSetBit()} not=${x.not()} signum=${x.signum()}")
        println("  shl 5=${x shl 5} shr 5=${x shr 5} shl 100=${x shl 100} shr 100=${x shr 100} shr -3=${x.shiftRight(-3)}")
    }
    val pairs = listOf("12345678901234567890" to "-987654321", "-5" to "3", "-123456789012345678901234567890" to "-7", "0" to "-1")
    for ((a, b) in pairs) {
        val x = BigInteger(a)
        val y = BigInteger(b)
        println("$a, $b: and=${x and y} or=${x or y} xor=${x xor y} andNot=${x.andNot(y)}")
    }
    val m = BigInteger("-1000000000000000000000")
    println(m.testBit(0))
    println(m.testBit(70))
    println(m.testBit(200))
    println(m.setBit(3))
    println(m.clearBit(69))
    println(m.flipBit(100))
    println(BigInteger.ONE.shiftLeft(100).bitLength())
    println((BigInteger.ONE.shiftLeft(100) - BigInteger.ONE).bitLength())
    println((BigInteger.ONE.shiftLeft(100).negate()).bitLength())
}

fun conversions() {
    println("-- conversions")
    val values = listOf("0", "1", "-1", "2147483647", "2147483648", "-2147483649", "4294967296", "123456789012345678901234567890", "-123456789012345678901234567890")
    for (a in values) {
        val x = BigInteger(a)
        println("$a: int=${x.toInt()} hash=${x.hashCode()} double=${x.toDouble()}")
    }
    val longs = listOf("4503599627370496", "-4503599627370497", "123456789012", "9007199254740992", "4294967295")
    for (a in longs) println("$a: long=${BigInteger(a).toLong()} hash=${BigInteger(a).hashCode()}")
    println(BigInteger("18446744073709551616").toLong())
    println(BigInteger("18446744073709551617").toLong())
    println(BigInteger("1" + "0".repeat(400)).toDouble())
    println(BigInteger("123456789012345678901234567890123456789").toDouble())
}

fun numberTheory() {
    println("-- number theory")
    val a = BigInteger("123456789012345678901234567890")
    val b = BigInteger("987654321098765432109876543210")
    println(a.gcd(b))
    println(a.gcd(BigInteger.ZERO))
    println(BigInteger.ZERO.gcd(BigInteger.ZERO))
    println((-a).gcd(b))
    println(BigInteger.valueOf(3).modPow(BigInteger.valueOf(200), BigInteger("1000000007")))
    println(a.modPow(b, BigInteger("1000000000000000000000007")))
    println(BigInteger.valueOf(7).modPow(BigInteger.valueOf(-1), BigInteger.valueOf(40)))
    println(BigInteger.valueOf(17).modInverse(BigInteger.valueOf(3120)))
    println(a.sqrt())
    println(BigInteger.TEN.pow(41).sqrt())
    println(BigInteger.valueOf(99).sqrt())
    println(BigInteger.valueOf(100).sqrt())
    println(BigInteger.ZERO.sqrt())
    println(BigInteger.valueOf(1000000007).isProbablePrime(20))
    println(BigInteger.valueOf(1000000011).isProbablePrime(20))
    println(BigInteger("170141183460469231731687303715884105727").isProbablePrime(20))
    println(BigInteger("170141183460469231731687303715884105729").isProbablePrime(20))
    println(BigInteger.valueOf(100).nextProbablePrime())
    println(BigInteger.valueOf(-5).pow(3))
    println(BigInteger.valueOf(0).pow(0))
    println(a.abs().min(b).max(BigInteger.TEN))
    println(a.negate().abs() == a)
    println(a.signum())
}

fun comparisons() {
    println("-- comparisons")
    val a = BigInteger("100000000000000000000")
    val b = BigInteger("99999999999999999999")
    val c = BigInteger("100000000000000000000")
    println(a > b)
    println(a < b)
    println(a >= c)
    println(a <= b)
    println(a == c)
    println(a != c)
    println(a.equals(c))
    println(a.equals(b))
    println(a.compareTo(b))
    println(b.compareTo(a))
    println(a.compareTo(c))
    println((-a).compareTo(b))
    println(a.hashCode() == c.hashCode())
    val sorted = listOf(a, b, BigInteger.ZERO, -a, BigInteger.TEN).sorted()
    println(sorted)
    println(listOf(a, b, c).distinct().size)
    println(setOf(a, c, b).size)
    val counts = mutableMapOf<BigInteger, Int>()
    for (x in listOf(a, b, c, a)) counts[x] = (counts[x] ?: 0) + 1
    println(counts)
    println(listOf(a, b).maxOrNull())
    println(listOf(a, b).minByOrNull { it })
    println(maxOf(a, b))
}

fun operators() {
    println("-- operators")
    var x = BigInteger("5")
    x++
    println(x)
    x--
    x--
    println(x)
    x += BigInteger.TEN
    x *= x
    x -= BigInteger.ONE
    x /= BigInteger.TWO
    x %= BigInteger.valueOf(50)
    println(x)
    println(-x)
    println(x.inv())
    val y = BigInteger("-12")
    println("$y $x ${y * x} ${y + x} ${y - x}")
    println(listOf(1, 2, 3, 4, 5).map { it.toBigInteger() }.fold(BigInteger.ONE) { acc, v -> acc * v })
    println(listOf("1", "2", "3").sumOf { it.toBigInteger() })
    println((1..5).map { BigInteger.valueOf(it.toLong()) }.reduce { acc, v -> acc.multiply(v) })
}

fun failures() {
    println("-- failures")
    fun attempt(label: String, block: () -> Any?) {
        try {
            println("$label: ${block()}")
        } catch (e: Exception) {
            println("$label: ${e::class.simpleName}: ${e.message}")
        }
    }
    attempt("div0") { BigInteger.TEN / BigInteger.ZERO }
    attempt("rem0") { BigInteger.TEN % BigInteger.ZERO }
    attempt("mod0") { BigInteger.TEN.mod(BigInteger.ZERO) }
    attempt("modNeg") { BigInteger.TEN.mod(BigInteger.valueOf(-3)) }
    attempt("sqrtNeg") { BigInteger.valueOf(-4).sqrt() }
    attempt("powNeg") { BigInteger.TEN.pow(-1) }
    attempt("inverse") { BigInteger.valueOf(4).modInverse(BigInteger.valueOf(8)) }
    attempt("empty") { BigInteger("") }
    attempt("sign only") { BigInteger("-") }
    attempt("letters") { BigInteger("abc") }
    attempt("embedded") { BigInteger("12-3") }
    attempt("double sign") { BigInteger("--3") }
    attempt("digit") { BigInteger("12345678901234567890x") }
    attempt("radix") { BigInteger("12", 99) }
    attempt("hex") { BigInteger("xyz", 16) }
    attempt("bit") { BigInteger.TEN.testBit(-1) }
    attempt("intExact") { BigInteger("12345678901").intValueExact() }
    attempt("longExact") { BigInteger("123456789012345678901").longValueExact() }
}

fun main() {
    construction()
    big()
    divisions()
    bits()
    conversions()
    numberTheory()
    comparisons()
    operators()
    failures()
}
