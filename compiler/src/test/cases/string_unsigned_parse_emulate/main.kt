fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: Exception) {
        println("$label: ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    println("18446744073709551615".toULong())
    println("9223372036854775808".toULong())
    println("9223372036854775807".toULong())
    println("ffffffffffffffff".toULong(16))
    println("8000000000000000".toULong(16))
    println("18446744073709551616".toULongOrNull())
    println("18446744073709551617".toULongOrNull())
    println("ffffffffffffffff0".toULongOrNull(16))
    println("-1".toULongOrNull())
    println("+18446744073709551615".toULongOrNull()!!)
    attempt("overflow") { "18446744073709551616".toULong() }
    attempt("negative") { "-1".toULong() }
    println(ULong.MAX_VALUE.toString(16))
    println(ULong.MAX_VALUE.toString(36))
    println(ULong.MAX_VALUE.toString(2))
    println(9223372036854775808uL.toString(10))
    println(9223372036854775808uL.toString(16))
    println("zzzzzzzzzzzz".toULong(36).toString(36))
}
