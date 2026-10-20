// Recursion through try blocks: every level runs its body in a protected call.

sealed class Expr
class Num(val n: Int) : Expr()
class Add(val l: Expr, val r: Expr) : Expr()
class Div(val l: Expr, val r: Expr) : Expr()

class EvalError(message: String) : Exception(message)

var finallies = 0

fun eval(e: Expr): Int = try {
    when (e) {
        is Num -> e.n
        is Add -> eval(e.l) + eval(e.r)
        is Div -> {
            val d = eval(e.r)
            if (d == 0) throw EvalError("division by zero")
            eval(e.l) / d
        }
    }
} finally {
    finallies++
}

fun depthOf(n: Int): Int {
    try {
        return if (n == 0) 0 else 1 + depthOf(n - 1)
    } catch (e: IllegalStateException) {
        return -1
    }
}

// a catch deep down handles an error thrown deeper still
fun catchAt(n: Int, at: Int): String {
    try {
        if (n == 0) throw IllegalStateException("bottom")
        return catchAt(n - 1, at)
    } catch (e: IllegalStateException) {
        if (n == at) return "caught at $n: ${e.message}"
        throw e
    }
}

fun usesRunCatching(n: Int): Int = if (n == 0) 0 else runCatching { usesRunCatching(n - 1) + 1 }.getOrThrow()

class Resource(val id: Int) : AutoCloseable {
    override fun close() {
        closed++
    }

    companion object {
        var closed = 0
    }
}

fun nestedUse(n: Int): Int = if (n == 0) 0 else Resource(n).use { nestedUse(n - 1) + 1 }

fun infinite(n: Int): Int = try {
    infinite(n + 1) + 1
} finally {
    finallies++
}

fun main() {
    var e: Expr = Num(1)
    for (i in 1..3000) e = Add(e, Num(i % 7))
    println("eval ${eval(e)} finallies=$finallies")
    println("depth ${depthOf(5000)}")
    println(catchAt(4000, 2500))
    println("runCatching ${usesRunCatching(1000)}")
    println("use ${nestedUse(1000)} closed=${Resource.closed}")
    try {
        eval(Div(Num(1), Add(Num(0), Num(0))))
    } catch (x: EvalError) {
        println("error: ${x.message}")
    }
    finallies = 0
    try {
        infinite(0)
    } catch (x: StackOverflowError) {
        println("StackOverflowError, finally blocks ran: ${finallies > 1000}")
    }
}
