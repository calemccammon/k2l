// DeepRecursiveFunction: recursion deeper than the stack, mutual recursion, exceptions through deep calls
class Tree(val left: Tree?, val right: Tree?)

val depthOf = DeepRecursiveFunction<Tree?, Int> { tree ->
    if (tree == null) 0 else maxOf(callRecursive(tree.left), callRecursive(tree.right)) + 1
}

val countDown = DeepRecursiveFunction<Int, Long> { n ->
    if (n == 0) 0L else n + callRecursive(n - 1)
}

// mutual recursion through two functions
lateinit var isOdd: DeepRecursiveFunction<Int, Boolean>
val isEven: DeepRecursiveFunction<Int, Boolean> = DeepRecursiveFunction { n -> if (n == 0) true else isOdd.callRecursive(n - 1) }

fun fib(): DeepRecursiveFunction<Int, Long> {
    val memo = HashMap<Int, Long>()
    return DeepRecursiveFunction { n ->
        if (n < 2) {
            n.toLong()
        } else {
            memo[n] ?: (callRecursive(n - 1) + callRecursive(n - 2)).also { memo[n] = it }
        }
    }
}

class Parser(private val text: String) {
    private var pos = 0

    // nesting depth of brackets, recursively
    val nesting: DeepRecursiveFunction<Unit, Int> = DeepRecursiveFunction {
        var best = 0
        while (pos < text.length && text[pos] == '[') {
            pos++
            best = maxOf(best, callRecursive(Unit) + 1)
            if (pos >= text.length || text[pos] != ']') throw IllegalStateException("expected ] at $pos")
            pos++
        }
        best
    }
}

fun main() {
    isOdd = DeepRecursiveFunction { n -> if (n == 0) false else isEven.callRecursive(n - 1) }

    // a degenerate tree 100000 levels deep
    var tree: Tree? = null
    repeat(100_000) { tree = Tree(tree, null) }
    println("depth: ${depthOf(tree)}")
    println("small: ${depthOf(Tree(Tree(null, null), Tree(null, Tree(null, null))))}")
    println("sum: ${countDown(100_000)}")
    println("again: ${countDown.invoke(10)}")
    println("even: ${isEven(100_000)}, ${isEven(99_999)}, odd: ${isOdd(7)}")
    println("fib: ${fib()(70)}")

    // an exception thrown deep down reaches the caller, and a catch inside the function sees it
    val failing = DeepRecursiveFunction<Int, Int> { n ->
        if (n == 0) throw IllegalArgumentException("bottom reached")
        callRecursive(n - 1) + 1
    }
    try {
        failing(50_000)
    } catch (e: IllegalArgumentException) {
        println("caught: ${e.message}")
    }
    val recovering = DeepRecursiveFunction<Int, Int> { n ->
        when {
            n == 0 -> throw ArithmeticException("zero")
            n == 1000 -> try {
                callRecursive(n - 1)
            } catch (e: ArithmeticException) {
                -1
            }
            else -> callRecursive(n - 1) + 1
        }
    }
    println("recovered: ${recovering(30_000)}")

    println("nesting: ${Parser("[[[]][]]").nesting(Unit)}")
    println("deep nesting: ${Parser("[".repeat(20_000) + "]".repeat(20_000)).nesting(Unit)}")
    try {
        Parser("[[]").nesting(Unit)
    } catch (e: IllegalStateException) {
        println("parse error: ${e.message}")
    }
}
