fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: Exception) {
        println("$label: ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    println("42".toUInt())
    println("+42".toUInt())
    println("4294967295".toUInt())
    println("0".toUInt())
    println("ff".toUInt(16))
    println("FF".toUInt(16))
    println("zz".toUInt(36))
    println("11111111".toUInt(2))
    println("255".toUByte())
    println("65535".toUShort())
    println("12345678901234".toULong())
    println("1000000".toULong())
    println("ff".toULong(16))
    println("77".toULong(8))

    println("4294967296".toUIntOrNull())
    println("-1".toUIntOrNull())
    println("-0".toUIntOrNull())
    println("".toUIntOrNull())
    println("+".toUIntOrNull())
    println("12a".toUIntOrNull())
    println("1_000".toUIntOrNull())
    println(" 1".toUIntOrNull())
    println("256".toUByteOrNull())
    println("255".toUByteOrNull())
    println("65536".toUShortOrNull())
    println("65535".toUShortOrNull())
    println("-5".toULongOrNull())
    println("abc".toULongOrNull())
    println("g".toUIntOrNull(16))
    println("7fffffff".toUIntOrNull(16))
    println("ffffffff".toUIntOrNull(16))
    println("100000000".toUIntOrNull(16))
    println("ff".toUByteOrNull(16))
    println("100".toUByteOrNull(16))
    println("ffff".toUShortOrNull(16))
    println("10000".toUShortOrNull(16))

    attempt("abc") { "abc".toUInt() }
    attempt("neg") { "-1".toUInt() }
    attempt("big") { "4294967296".toUInt() }
    attempt("empty") { "".toUInt() }
    attempt("byte") { "256".toUByte() }
    attempt("short") { "65536".toUShort() }
    attempt("ulong") { "x".toULong() }
    attempt("radix") { "19".toUInt(8) }
    attempt("badradix") { "19".toUInt(40) }
    attempt("badradix1") { "19".toUIntOrNull(1) }

    println(255u.toString(16))
    println(255u.toString(2))
    println(4294967295u.toString(36))
    println(200.toUByte().toString(16))
    println(65535.toUShort().toString(8))
    println(12345678901234uL.toString(7))
    println(0u.toString(2))
}
