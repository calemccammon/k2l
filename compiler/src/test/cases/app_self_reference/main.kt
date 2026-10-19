// A top-level property whose initializer refers to the property itself, in a lambda that runs later (recursive grammars,
// self-scheduling callbacks).
class Node(val name: String, val children: () -> List<Node>)

val tree: Node = Node("root") { listOf(Node("leaf") { emptyList() }, Node("loop") { listOf(tree) }) }

val countdown: (Int) -> List<Int> = { n -> if (n == 0) listOf(0) else listOf(n) + countdown(n - 1) }

val greeting by lazy { "hello from ${greetingName()}" }

fun greetingName() = "lazy"

fun main() {
    println(tree.children().map { it.name })
    println(tree.children()[1].children().single() === tree)
    println(countdown(4))
    println(greeting)
}
