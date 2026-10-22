// AssertionError: constructed, thrown, caught and type-checked like the JVM's java.lang.AssertionError, whose
// constructor takes any value as its message (kotlin.test's assertions throw it).
fun check(ok: Boolean, message: Any?) {
    if (!ok) throw AssertionError(message)
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
}
