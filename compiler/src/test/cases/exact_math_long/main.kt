// Long limits need 64-bit integers
fun attempt(label: String, block: () -> Any) {
    try {
        println("$label = ${block()}")
    } catch (e: ArithmeticException) {
        println("$label: ArithmeticException ${e.message}")
    }
}

fun main() {
    val max = Long.MAX_VALUE
    val min = Long.MIN_VALUE
    attempt("add") { Math.addExact(max - 1, 1L) }
    attempt("add overflow") { Math.addExact(max, 1L) }
    attempt("add underflow") { Math.addExact(min, -1L) }
    attempt("sub") { Math.subtractExact(min + 1, 1L) }
    attempt("sub overflow") { Math.subtractExact(min, 1L) }
    attempt("sub overflow 2") { Math.subtractExact(0L, min) }
    attempt("mul") { Math.multiplyExact(3037000499L, 3037000499L) }
    attempt("mul overflow") { Math.multiplyExact(3037000500L, 3037000500L) }
    attempt("mul min") { Math.multiplyExact(min, -1L) }
    attempt("mul min 2") { Math.multiplyExact(-1L, min) }
    attempt("mul zero") { Math.multiplyExact(min, 0L) }
    attempt("neg overflow") { Math.negateExact(min) }
    attempt("inc overflow") { Math.incrementExact(max) }
    attempt("dec overflow") { Math.decrementExact(min) }
    attempt("absExact overflow") { Math.absExact(min) }
    attempt("toIntExact") { Math.toIntExact(max) }
    println(Math.floorMod(min, 7L))
    println(Math.floorDiv(min, 7L))
    println(max.rotateLeft(1))
    println(1L.rotateRight(1))
    println(0x123456789ABCDEFL.rotateLeft(8))
    println(0x123456789ABCDEFL.rotateRight(60))
    println(12345678901234L.takeHighestOneBit())
    println((-5L).takeHighestOneBit())
    println(12345678901232L.takeLowestOneBit())
    println(0L.takeHighestOneBit())
    println(max.countOneBits())
    println(min.countOneBits())
    println(1L.countLeadingZeroBits())
    println(0L.countLeadingZeroBits())
    println(min.countLeadingZeroBits())
    println(8L.countTrailingZeroBits())
    println(0L.countTrailingZeroBits())
    println(3.14.toBits())
    println((-2.5).toBits())
    println(1.0.toRawBits())
    println(Double.fromBits(4614253070214989087L))
    println(Double.fromBits(0x7FF0000000000000L))
    println(Double.NaN.toBits())
    println((0.0 / 0.0).toRawBits() != 0L)
    println((-0.0).toBits())
    println(Double.MIN_VALUE.toBits())
    println(Double.MAX_VALUE.toBits())
    println(Double.fromBits(1L))
}
