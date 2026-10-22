// AssertionError: constructed, thrown, caught (as an Error), type-checked and extended. Its constructor takes any value
// as its message (kotlin.test's assertions throw it); a Throwable detail is also the cause.
fun check(ok: Boolean, message: Any?) {
    if (!ok) throw AssertionError(message)
}

class CheckFailed(message: String) : AssertionError(message)

fun verify(condition: Boolean, message: String) {
    if (!condition) throw CheckFailed(message)
}

fun outcome(block: () -> Unit): String = try {
    block()
    "no error"
} catch (e: Exception) {
    "exception $e"
} catch (e: Error) {
    "error ${e::class.simpleName}: ${e.message} (assertion: ${e is AssertionError})"
}

fun describe(e: Throwable): String = when (e) {
    is AssertionError -> "assertion: ${e.message}"
    is RuntimeException -> "runtime: ${e.message}"
    else -> "other: $e"
}

fun main() {
    try {
        check(false, "values differ")
    } catch (e: AssertionError) {
        println(e)
        println(e.message)
        println(e is Error)
        println((e as Throwable) is Exception)
    }
    println(describe(AssertionError("x")))
    println(describe(IllegalStateException("y")))
    println(AssertionError().message)
    println(AssertionError(42).message)
    println(AssertionError(null).message)
    val cause = IllegalArgumentException("bad")
    val wrapped = AssertionError(cause)
    println(wrapped.message)
    println(wrapped.cause === cause)
    println(AssertionError("with cause", cause).cause === cause)
    try {
        check(false, 7)
    } catch (e: Error) {
        println("caught as Error: ${e.message}")
    }
    val caught: Throwable = try {
        throw AssertionError("t")
    } catch (e: Throwable) {
        e
    }
    println(caught is AssertionError)
    println(outcome { verify(1 + 1 == 2, "math") })
    println(outcome { verify(false, "expected <1>, actual <2>.") })
    println(CheckFailed("sub"))
    try {
        verify(false, "rethrown")
    } catch (e: AssertionError) {
        println("caught ${e.message} ${e is CheckFailed} ${e is Throwable}")
    }
}
