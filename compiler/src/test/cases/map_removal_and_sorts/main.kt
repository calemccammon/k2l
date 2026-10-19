data class Pt(val x: Int, val y: Int)

class Mutable(var v: Int) {
    override fun hashCode(): Int = v
    override fun equals(other: Any?): Boolean = other is Mutable && other.v == v
    override fun toString(): String = "M$v"
}

fun main() {
    // removal keeps the insertion order and the lookups of the entries after it
    val m = LinkedHashMap<Int, String>()
    for (i in 0 until 10) m[i] = "v$i"
    println(m.remove(0))
    println(m.remove(5))
    println(m.remove(9))
    println(m.remove(42))
    println(m)
    println(m[6])
    m[5] = "again"
    println(m.keys.toList())
    println(m.containsKey(3))

    val names = linkedMapOf("a" to 1, "b" to 2, "c" to 3, "d" to 4)
    names.remove("b")
    println(names)
    println(names["d"])
    println(names.remove("c", 99))
    println(names.remove("c", 3))
    println(names)

    // object keys: buckets are renumbered
    val pts = LinkedHashMap<Pt, Int>()
    for (i in 0 until 6) pts[Pt(i, i * i)] = i
    pts.remove(Pt(1, 1))
    pts.remove(Pt(4, 16))
    println(pts)
    println(pts[Pt(5, 25)])
    println(pts[Pt(2, 4)])
    println(pts.containsKey(Pt(1, 1)))

    // mixed plain and object keys, null key
    val mixed = LinkedHashMap<Any?, Int>()
    mixed[1] = 1
    mixed[Pt(0, 0)] = 2
    mixed[null] = 3
    mixed["s"] = 4
    mixed.remove(1)
    println(mixed)
    println(mixed[null])
    println(mixed[Pt(0, 0)])
    mixed.remove(null)
    println(mixed)

    val set = LinkedHashSet<Pt>()
    for (i in 0 until 5) set.add(Pt(i, 0))
    set.remove(Pt(0, 0))
    set.remove(Pt(3, 0))
    println(set)
    println(set.contains(Pt(4, 0)))
    val ints = linkedSetOf(5, 3, 8, 1)
    ints.remove(3)
    ints.add(3)
    println(ints)

    // a key whose hashCode changed after insertion
    val ms = LinkedHashSet<Mutable>()
    val a = Mutable(1)
    ms.add(a)
    ms.add(Mutable(2))
    ms.add(Mutable(3))
    a.v = 10
    ms.remove(Mutable(2))
    println(ms.size)

    // sorts: numbers, strings, nulls, stability, descending
    println(listOf(3, 1, 2, 1, 5).sorted())
    println(listOf(3.5, -1.5, 2.25).sortedDescending())
    println(listOf("pear", "apple", "fig").sorted())
    val words = listOf("bb", "a", "ccc", "dd", "e")
    println(words.sortedBy { it.length })
    println(words.sortedByDescending { it.length })
    println(words.sortedBy { it.first() })
    println(listOf(Pt(2, 1), Pt(1, 5), Pt(2, 0), Pt(1, 2)).sortedBy { it.x })
    println(listOf<Int?>(3, null, 1).sortedBy { it })
    println(listOf<Int?>(3, null, 1).sortedByDescending { it })
    println(listOf(true, false, true).sortedBy { it })
    val calls = ArrayList<String>()
    val sortedWithCalls = listOf("x", "y").sortedBy { calls.add(it); it }
    println(sortedWithCalls)
    val mutable = mutableListOf(5, 2, 9)
    mutable.sortBy { -it }
    println(mutable)
}
