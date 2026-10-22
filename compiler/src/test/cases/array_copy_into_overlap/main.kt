// copyInto within one array with overlapping ranges, which copies as if through a temporary array like
// System.arraycopy (kotlinx.collections.immutable's TrieNode moves the entries of a node's buffer up this way).
fun main() {
    val up = arrayOf<Any?>(1, 2, 3, 4, 5, null)
    up.copyInto(up, 1, 0, 5)
    println(up.toList())

    val down = arrayOf(1, 2, 3, 4, 5)
    down.copyInto(down, 0, 1, 5)
    println(down.toList())

    val ints = intArrayOf(1, 2, 3, 4, 5, 6, 7)
    ints.copyInto(ints, 2, 0, 4)
    println(ints.toList())

    val chars = charArrayOf('a', 'b', 'c', 'd')
    chars.copyInto(chars, 1, 0, 3)
    println(chars.concatToString())

    val grown = up.copyOf(8)
    grown.copyInto(grown, 3, 1, 6)
    println(grown.toList())

    val same = arrayOf("x", "y", "z")
    same.copyInto(same, 0, 0, 3)
    println(same.toList())
}
