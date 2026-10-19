data class Key(val a: Int, val b: Int)

fun main() {
    val m = HashMap<Int, Int>()
    for (i in 0 until 300000) m[i] = i * 2
    var s = 0L
    for (i in 0 until 300000) s += m[i]!!
    println(s)
    val sm = mutableMapOf<String, Int>()
    for (i in 0 until 100000) sm["key$i"] = i
    var t = 0
    for (i in 0 until 100000) t += sm.getValue("key$i")
    println(t)
    for ((k, v) in sm) if (v % 50000 == 0) println("$k=$v")
    val km = HashMap<Key, Int>()
    for (i in 0 until 50000) km[Key(i, i + 1)] = i
    var u = 0
    for (i in 0 until 50000) u += km[Key(i, i + 1)] ?: 0
    println(u)
    val set = HashSet<Int>()
    for (i in 0 until 200000) set.add(i % 1000)
    println(set.size)
    val counts = mutableMapOf<Int, Int>()
    for (i in 0 until 300000) counts[i % 100] = (counts[i % 100] ?: 0) + 1
    println(counts[7])
    val small = HashMap<Int, Int>()
    for (i in 0 until 20000) small[i] = i
    var rm = 0
    for (i in 0 until 2000) if (small.remove(i) != null) rm++
    println(rm)
    val hs = HashSet<Key>()
    for (i in 0 until 5000) hs.add(Key(i, i))
    for (i in 0 until 500) hs.remove(Key(i, i))
    println(hs.size)
}
