// Throwable.addSuppressed and suppressedExceptions, and `use` recording an exception of close() as suppressed
class Resource(private val name: String, private val failClose: Boolean, private val log: MutableList<String>) : AutoCloseable {
    override fun close() {
        log += "close $name"
        if (failClose) throw IllegalStateException("close $name failed")
    }
}

fun report(e: Throwable): String = "${e.message} suppressed=${e.suppressedExceptions.map { it.message }}"

fun main() {
    // addSuppressed and suppressedExceptions
    val main = RuntimeException("main")
    println(main.suppressedExceptions)
    main.addSuppressed(IllegalArgumentException("first"))
    main.addSuppressed(UnsupportedOperationException("second"))
    println(report(main))
    println(main.suppressedExceptions.map { it::class.simpleName })
    println(main.suppressedExceptions.size)
    // Kotlin's addSuppressed ignores the exception itself
    main.addSuppressed(main)
    println("self ignored: ${main.suppressedExceptions.size}")
    val copy = main.suppressedExceptions
    main.addSuppressed(Exception("third"))
    println("copy ${copy.size}, now ${main.suppressedExceptions.size}")

    // use: a failing close() after a failing block is suppressed
    val log = mutableListOf<String>()
    try {
        Resource("a", failClose = true, log).use { throw IllegalStateException("body failed") }
    } catch (e: IllegalStateException) {
        println(report(e))
        println(e.suppressedExceptions.first() is IllegalStateException)
    }
    // a failing close() after a successful block is thrown
    try {
        Resource("b", failClose = true, log).use { "ok" }
    } catch (e: IllegalStateException) {
        println("thrown: ${report(e)}")
    }
    // nested resources: both close errors are suppressed into the body's exception
    try {
        Resource("outer", failClose = true, log).use {
            Resource("inner", failClose = true, log).use { error("nested body") }
        }
    } catch (e: IllegalStateException) {
        println(report(e))
        println(e.suppressedExceptions.map { report(it) })
    }
    // a close that succeeds adds nothing
    try {
        Resource("c", failClose = false, log).use { throw ArithmeticException("plain") }
    } catch (e: ArithmeticException) {
        println(report(e))
    }
    println(Resource("d", failClose = false, log).use { 42 })
    println(log)

    // printStackTrace-free description of a chain with suppressed exceptions
    val outer = IllegalStateException("outer", main)
    outer.addSuppressed(ArithmeticException("side"))
    println(listOf(outer.suppressedExceptions.size, outer.cause?.suppressedExceptions?.size))
}
