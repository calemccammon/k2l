// kotlin.AssertionError (java.lang.AssertionError on the JVM): thrown, caught as an Error, and extended.

class CheckFailed(message: String) : AssertionError(message)

fun verify(condition: Boolean, message: String) {
    if (!condition) throw CheckFailed(message)
}

fun describe(block: () -> Unit): String = try {
    block()
    "no error"
} catch (e: Exception) {
    "exception $e"
} catch (e: Error) {
    "error ${e::class.simpleName}: ${e.message} (assertion: ${e is AssertionError})"
}

fun main() {
    println(describe { throw AssertionError("plain") })
    println(describe { throw AssertionError() })
    println(describe { verify(1 + 1 == 2, "math") })
    println(describe { verify(false, "expected <1>, actual <2>.") })
    val e = AssertionError("shown")
    println(e)
    println(e.message)
    println(CheckFailed("sub"))
    // the detail object's string is the message; a Throwable detail is also the cause
    println(AssertionError(42).message)
    val nothing: String? = null
    println(AssertionError(nothing).message)
    val cause = IllegalStateException("inner")
    val wrapped = AssertionError(cause)
    println("${wrapped.message} / ${wrapped.cause?.message}")
    val both = AssertionError("outer", cause)
    println("${both.message} / ${both.cause === cause}")
    try {
        verify(false, "rethrown")
    } catch (e: AssertionError) {
        println("caught ${e.message} ${e is CheckFailed} ${e is Throwable}")
    }
}
