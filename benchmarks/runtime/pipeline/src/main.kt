data class P(val id: Int, val score: Int, val tag: String)

fun main() {
    val items = (0 until 200000).map { P(it, (it * 7919) % 1000, "t${it % 10}") }
    var acc = 0L
    for (round in 0 until 5) {
        val r = items.filter { it.score > 100 }.map { it.score * 2 }.sum()
        acc += r
        val g = items.groupBy { it.tag }.mapValues { (_, v) -> v.size }
        acc += g.size
        val top = items.sortedByDescending { it.score }.take(10).map { it.id }
        acc += top.sum()
        acc += items.count { it.tag == "t3" }
        acc += items.fold(0) { a, p -> a + p.id % 3 }
        val xs = IntArray(100000) { it }
        var s = 0
        for (x in xs) s += x
        acc += s
        val list = ArrayList<Int>()
        for (i in 0 until 100000) list.add(i)
        var t = 0
        for (i in 0 until list.size) t += list[i]
        for (v in list) t += v
        list.forEach { t += it }
        acc += t
    }
    println(acc)
}
