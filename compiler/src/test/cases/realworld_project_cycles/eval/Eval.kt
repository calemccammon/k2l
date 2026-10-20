package calc.eval

import calc.lang.Node
import calc.lang.keywords
import calc.lang.parse
import calc.trace

// Initialized from the parser's state: on the JVM, reading `keywords` initializes the parser's file first.
val reserved: Set<String> = keywords + "def"

val builtins: MutableMap<String, (List<Int>) -> Int> = linkedMapOf(
    "+" to { xs -> xs.sum() },
    "*" to { xs -> xs.fold(1) { a, b -> a * b } },
    "-" to { xs -> if (xs.size == 1) -xs[0] else xs.drop(1).fold(xs[0]) { a, b -> a - b } },
    "max" to { xs -> xs.max() },
)

var evaluations = 0

sealed interface Value {
    data class I(val n: Int) : Value

    data class Q(val node: Node) : Value
}

fun isBuiltin(name: String): Boolean = name in builtins

fun define(name: String, f: (List<Int>) -> Int) {
    require(name !in reserved) { "'$name' is reserved" }
    builtins[name] = f
    trace("defined $name")
}

fun evaluate(node: Node, env: Map<String, Int>): Value {
    evaluations++
    return when (node) {
        is Node.Num -> Value.I(node.value)

        is Node.Sym -> Value.I(env[node.name] ?: error("unbound ${node.name}"))

        is Node.Call -> {
            val head = node.items.first() as Node.Sym
            when (head.name) {
                "quote" -> Value.Q(node.items[1])

                "let" -> {
                    val name = (node.items[1] as Node.Sym).name
                    val v = (evaluate(node.items[2], env) as Value.I).n
                    evaluate(node.items[3], env + (name to v))
                }

                "eval" -> {
                    // (eval "src") parses again: a call back into the parser's file
                    val src = (node.items[1] as Node.Sym).name.replace('_', ' ').replace('[', '(').replace(']', ')')
                    evaluate(parse(src), env)
                }

                else -> {
                    val f = builtins[head.name] ?: error("no builtin ${head.name}")
                    Value.I(f(node.items.drop(1).map { (evaluate(it, env) as Value.I).n }))
                }
            }
        }
    }
}
