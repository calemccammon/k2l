package calc.lang

import calc.eval.Value
import calc.eval.evaluate
import calc.eval.isBuiltin
import calc.trace

// The parser and the evaluator call each other: `(quote ...)` is parsed lazily by the evaluator, and the parser asks
// the evaluator which names are builtins. The two files (and main.kt, through `trace`) form an import cycle.

val keywords = setOf("let", "if", "quote")

// Read from the evaluator while the evaluator reads `keywords`: fine on the JVM, as `keywords` is set first.
val operatorSymbols = calc.eval.builtins.keys.filter { it.length == 1 }

var parsedNodes = 0
    private set

var maxDepth = 0

sealed class Node {
    data class Num(val value: Int) : Node()

    data class Sym(val name: String, val builtin: Boolean) : Node()

    data class Call(val items: List<Node>) : Node()
}

private class Cursor(val tokens: List<String>) {
    var pos = 0

    fun peek(): String? = tokens.getOrNull(pos)

    fun next(): String = tokens[pos++]
}

fun tokenize(src: String): List<String> = src.replace("(", " ( ").replace(")", " ) ").split(' ').filter { it.isNotBlank() }

fun parse(src: String): Node {
    val cursor = Cursor(tokenize(src))
    val node = parseNode(cursor, 1)
    trace("parsed '$src' into ${countNodes(node)} nodes")
    return node
}

private fun parseNode(c: Cursor, depth: Int): Node {
    parsedNodes++
    if (depth > maxDepth) maxDepth = depth
    val tok = c.next()
    if (tok == "(") {
        val items = mutableListOf<Node>()
        while (c.peek() != ")") items += parseNode(c, depth + 1)
        c.next()
        return Node.Call(items)
    }
    return tok.toIntOrNull()?.let { Node.Num(it) } ?: Node.Sym(tok, isBuiltin(tok))
}

fun countNodes(n: Node): Int = when (n) {
    is Node.Call -> 1 + n.items.sumOf { countNodes(it) }
    else -> 1
}

fun run(src: String): Value = evaluate(parse(src), emptyMap())
