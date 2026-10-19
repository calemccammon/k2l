class Node(val left: Node?, val right: Node?)

fun make(d: Int): Node = if (d == 0) Node(null, null) else Node(make(d - 1), make(d - 1))

fun check(n: Node): Int = if (n.left == null) 1 else 1 + check(n.left) + check(n.right!!)

fun main() {
    val maxDepth = 15
    val stretch = make(maxDepth + 1)
    println("stretch tree of depth ${maxDepth + 1} check: ${check(stretch)}")
    val longLived = make(maxDepth)
    var d = 4
    while (d <= maxDepth) {
        val iterations = 1 shl (maxDepth - d + 4)
        var sum = 0
        for (i in 0 until iterations) sum += check(make(d))
        println("$iterations trees of depth $d check: $sum")
        d += 4
    }
    println("long lived tree of depth $maxDepth check: ${check(longLived)}")
}
