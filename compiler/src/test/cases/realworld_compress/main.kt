import java.util.PriorityQueue

// Compression toolkit: Huffman coding with a PriorityQueue of sealed tree nodes, LZ77-style tokens,
// base-64 encoding by hand, CRC-32, and a memoizing function wrapper.

sealed class Node(val weight: Int) : Comparable<Node> {
    abstract val minChar: Char
    override fun compareTo(other: Node) = compareValuesBy(this, other, Node::weight, Node::minChar)

    class Leaf(val ch: Char, weight: Int) : Node(weight) {
        override val minChar get() = ch
    }

    class Branch(val left: Node, val right: Node) : Node(left.weight + right.weight) {
        override val minChar: Char = minOf(left.minChar, right.minChar)
    }
}

fun buildTree(text: String): Node {
    val queue = PriorityQueue<Node>()
    text.groupingBy { it }.eachCount().forEach { (c, n) -> queue.add(Node.Leaf(c, n)) }
    if (queue.size == 1) return Node.Branch(queue.poll(), Node.Leaf('\u0000', 0))
    while (queue.size > 1) {
        val a = queue.poll()
        val b = queue.poll()
        queue.add(Node.Branch(a, b))
    }
    return queue.single()
}

fun codes(node: Node, prefix: String = "", out: MutableMap<Char, String> = sortedMapOf()): Map<Char, String> {
    when (node) {
        is Node.Leaf -> out[node.ch] = prefix.ifEmpty { "0" }
        is Node.Branch -> {
            codes(node.left, prefix + "0", out)
            codes(node.right, prefix + "1", out)
        }
    }
    return out
}

fun decode(tree: Node, bits: String): String = buildString {
    var node = tree
    for (b in bits) {
        node = (node as Node.Branch).let { if (b == '0') it.left else it.right }
        if (node is Node.Leaf) {
            append(node.ch)
            node = tree
        }
    }
}

sealed interface Token {
    data class Literal(val c: Char) : Token
    data class Ref(val distance: Int, val length: Int) : Token
}

fun lz77(input: String, window: Int = 32): List<Token> {
    val out = mutableListOf<Token>()
    var i = 0
    while (i < input.length) {
        var bestLen = 0
        var bestDist = 0
        for (j in maxOf(0, i - window) until i) {
            var len = 0
            while (i + len < input.length && input[j + len] == input[i + len] && len < 255) len++
            if (len > bestLen) {
                bestLen = len
                bestDist = i - j
            }
        }
        if (bestLen >= 3) {
            out += Token.Ref(bestDist, bestLen)
            i += bestLen
        } else {
            out += Token.Literal(input[i++])
        }
    }
    return out
}

fun unlz77(tokens: List<Token>): String {
    val sb = StringBuilder()
    for (t in tokens) {
        when (t) {
            is Token.Literal -> sb.append(t.c)
            is Token.Ref -> repeat(t.length) { sb.append(sb[sb.length - t.distance]) }
        }
    }
    return sb.toString()
}

private const val B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

fun base64(bytes: List<Int>): String = bytes.chunked(3).joinToString("") { chunk ->
    val n = chunk.foldIndexed(0) { i, acc, b -> acc or (b shl (16 - 8 * i)) }
    (0 until 4).map { k -> if (k <= chunk.size) B64[(n shr (18 - 6 * k)) and 63] else '=' }.joinToString("")
}

fun unbase64(s: String): List<Int> = s.filter { it != '=' }.map { B64.indexOf(it) }.chunked(4).flatMap { group ->
    val n = group.foldIndexed(0) { i, acc, v -> acc or (v shl (18 - 6 * i)) }
    (0 until group.size - 1).map { k -> (n shr (16 - 8 * k)) and 0xFF }
}

val CRC_TABLE = IntArray(256) { n ->
    var c = n
    repeat(8) { c = if (c and 1 != 0) (c ushr 1) xor 0xEDB88320.toInt() else c ushr 1 }
    c
}

fun crc32(bytes: List<Int>): Long {
    var crc = -1
    for (b in bytes) crc = CRC_TABLE[(crc xor b) and 0xFF] xor (crc ushr 8)
    return (crc.inv()).toLong() and 0xFFFFFFFFL
}

fun <A, R> ((A) -> R).memoized(): (A) -> R {
    val cache = HashMap<A, R>()
    return { a -> cache.getOrPut(a) { this(a) } }
}

var slowCalls = 0
val slowSquare: (Int) -> Int = { x -> slowCalls++; x * x }

fun main() {
    val text = "abracadabra alakazam"
    val tree = buildTree(text)
    val table = codes(tree)
    println("weights: total=${tree.weight}, codes=$table")
    val encoded = text.map { table.getValue(it) }.joinToString("")
    println("encoded ${encoded.length} bits vs ${text.length * 8}: ${encoded.chunked(8).joinToString(" ")}")
    println("decoded: ${decode(tree, encoded)} ok=${decode(tree, encoded) == text}")
    val avg = table.entries.sumOf { (c, code) -> code.length * text.count { it == c } }.toDouble() / text.length
    println("average code length: ${"%.3f".format(avg)}")
    println("single symbol: ${codes(buildTree("zzzz"))}")

    val sample = "to be or not to be, that is the question; to be or not to be"
    val tokens = lz77(sample)
    println("lz77: ${tokens.size} tokens, ${tokens.count { it is Token.Ref }} refs; first refs ${tokens.filterIsInstance<Token.Ref>().take(3)}")
    println("round trip: ${unlz77(tokens) == sample}")
    val pattern = "abcabcabcabcabcabcx"
    println("lz77($pattern) = ${lz77(pattern).joinToString("") { if (it is Token.Literal) "${it.c}" else (it as Token.Ref).let { r -> "<${r.distance},${r.length}>" } }}")

    for (s in listOf("Man", "Ma", "M", "hello, world!", "")) {
        val bytes = s.map { it.code }
        val enc = base64(bytes)
        val back = unbase64(enc).map { it.toChar() }.joinToString("")
        println("base64('$s') = '$enc' -> '$back' crc=${crc32(bytes).toString(16).padStart(8, '0')}")
    }
    println("crc32('123456789') = ${crc32("123456789".map { it.code })} (0x${java.lang.Long.toHexString(crc32("123456789".map { it.code }))})")
    println("table: ${CRC_TABLE.take(4).map { Integer.toHexString(it) }}")

    val fast = slowSquare.memoized()
    val results = listOf(3, 4, 3, 3, 5, 4).map(fast)
    println("memoized: $results, underlying calls $slowCalls")
    lateinit var fib: (Int) -> Long
    fib = { n: Int -> if (n < 2) n.toLong() else fib(n - 1) + fib(n - 2) }.memoized()
    println("fib(60) = ${fib(60)}")
}
