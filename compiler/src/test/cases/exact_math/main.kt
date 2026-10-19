fun attempt(label: String, block: () -> Any) {
    try {
        println("$label = ${block()}")
    } catch (e: ArithmeticException) {
        println("$label: ArithmeticException ${e.message}")
    }
}

fun main() {
    val max = Int.MAX_VALUE
    val min = Int.MIN_VALUE
    attempt("add") { Math.addExact(1, 2) }
    attempt("add overflow") { Math.addExact(max, 1) }
    attempt("add underflow") { Math.addExact(min, -1) }
    attempt("sub") { Math.subtractExact(5, 7) }
    attempt("sub overflow") { Math.subtractExact(min, 1) }
    attempt("mul") { Math.multiplyExact(46340, 46340) }
    attempt("mul overflow") { Math.multiplyExact(46341, 46341) }
    attempt("mul overflow 2") { Math.multiplyExact(max, 2) }
    attempt("neg") { Math.negateExact(5) }
    attempt("neg overflow") { Math.negateExact(min) }
    attempt("inc") { Math.incrementExact(41) }
    attempt("inc overflow") { Math.incrementExact(max) }
    attempt("dec") { Math.decrementExact(41) }
    attempt("dec overflow") { Math.decrementExact(min) }
    attempt("toIntExact") { Math.toIntExact(123456L) }
    attempt("toIntExact overflow") { Math.toIntExact(3000000000L) }
    attempt("toIntExact negative overflow") { Math.toIntExact(-3000000000L) }
    attempt("absExact") { Math.absExact(-9) }
    attempt("absExact overflow") { Math.absExact(min) }

    val big = 3000000000L
    attempt("long add") { Math.addExact(big, big) }
    attempt("long sub") { Math.subtractExact(big, big * 2) }
    attempt("long mul") { Math.multiplyExact(big, 1000L) }
    attempt("long neg") { Math.negateExact(big) }
    attempt("long inc") { Math.incrementExact(big) }
    attempt("long dec") { Math.decrementExact(big) }
    attempt("mixed") { Math.addExact(max.toLong(), 5L) }

    println(Math.floorMod(-7, 3))
    println(Math.floorMod(7, -3))
    println(Math.floorMod(-7L, 3L))
    println(Math.floorDiv(-7, 3))
    println(Math.floorDiv(7, -3))
    println(Math.floorDiv(-7L, 3L))
    attempt("floorMod zero") { Math.floorMod(5, 0) }
    attempt("floorDiv zero") { Math.floorDiv(5, 0) }
}
