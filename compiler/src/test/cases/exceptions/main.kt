class ValidationError(val field: String) : IllegalArgumentException("invalid $field")

fun parsePositive(n: Int): Int {
    if (n < 0) throw IllegalArgumentException("negative: $n")
    return n
}

fun risky(mode: Int): String {
    try {
        when (mode) {
            0 -> return "ok"
            1 -> throw IllegalStateException("bad state")
            2 -> throw ValidationError("email")
            else -> error("unexpected mode $mode")
        }
    } catch (e: ValidationError) {
        return "validation failed for ${e.field}: ${e.message}"
    } catch (e: IllegalStateException) {
        return "state: ${e.message}"
    } finally {
        println("finally $mode")
    }
}

fun safeDivide(a: Int, b: Int): Int = try {
    a / b
} catch (e: ArithmeticException) {
    println("caught ${e.message}")
    0
}

fun main() {
    println(parsePositive(5))
    try {
        parsePositive(-1)
    } catch (e: IllegalArgumentException) {
        println("caught: ${e.message}")
    }
    println(risky(0))
    println(risky(1))
    println(risky(2))
    try {
        risky(3)
    } catch (e: Exception) {
        println("outer: $e")
    }
    println(safeDivide(10, 2))
    println(safeDivide(1, 0))
    val e = ValidationError("name")
    println(e is IllegalArgumentException)
    println(e is RuntimeException)
    println(e)
    try {
        require(1 > 2) { "one is not greater" }
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        check(false)
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    val value: String? = null
    try {
        println(value!!.length)
    } catch (e: NullPointerException) {
        println("npe")
    }
    var attempts = 0
    while (attempts < 3) {
        attempts++
        try {
            if (attempts < 3) throw RuntimeException("try again")
            println("succeeded after $attempts")
        } catch (e: RuntimeException) {
            println(e.message)
        }
    }
}
