import java.util.EmptyStackException
import java.util.Stack
import java.util.StringJoiner

// java.util.Stack's EmptyStackException (caught by its class, by `is` and as RuntimeException) and StringJoiner.length()
// in UTF-16 code units (this case runs with --strings utf16).
fun popOrNull(stack: Stack<String>): String? = try {
    stack.pop()
} catch (e: EmptyStackException) {
    null
}

fun describe(e: Throwable): String = when (e) {
    is EmptyStackException -> "EmptyStackException message=${e.message}"
    is RuntimeException -> "other RuntimeException"
    else -> "other"
}

fun main() {
    val stack = Stack<String>()
    stack.push("é")
    println("pop: ${popOrNull(stack)} then ${popOrNull(stack)}")
    try {
        stack.peek()
    } catch (e: EmptyStackException) {
        println("peek: caught ${e::class.simpleName} ${e.message} $e")
    }
    try {
        stack.pop()
    } catch (e: RuntimeException) {
        println("pop as RuntimeException: ${describe(e)} ${e is EmptyStackException} ${e is IllegalStateException}")
    }
    val made = EmptyStackException()
    println("constructed: $made ${made.message} ${made is RuntimeException}")
    val result = runCatching { Stack<Int>().pop() }
    println("runCatching: ${result.exceptionOrNull()?.let(::describe)}")

    val joiner = StringJoiner("·", "«", "»")
    println("empty length: ${joiner.length()} ${joiner}")
    joiner.add("naïve").add("😀")
    println("length: ${joiner.length()} ${joiner.toString().length} $joiner")
    val plain = StringJoiner(", ")
    plain.setEmptyValue("ø")
    println("empty value length: ${plain.length()}")
    plain.add("abc")
    println("ascii length: ${plain.length()}")
}
