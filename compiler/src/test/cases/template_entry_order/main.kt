// A template turns each entry into text in order, so a later call that changes an earlier entry's value doesn't show.
class Box(var n: Int) {
    fun bump(): Int = ++n

    override fun toString() = "Box($n)"
}

var counter = 0

fun tick(): Int = ++counter

fun main() {
    val d = ArrayDeque(listOf(1, 2, 3))
    println("$d ${d.removeFirst()} $d")
    val b = Box(0)
    println("$b ${b.bump()} $b ${b.bump()}")
    val sb = StringBuilder("a")
    println("$sb ${sb.append("b")} $sb")
    val list = mutableListOf(1)
    println("${list.add(2)} $list ${list.removeAt(0)} $list")
    println("$counter ${tick()} $counter")
    val c = Box(5)
    val s = "" + c + c.bump() + c
    println(s)
    println("${c}" + c.bump() + "$c")
    val jd = java.util.ArrayDeque(listOf(1, 2, 3))
    println("${jd.poll()} $jd ${jd.poll()} $jd")
    val q: java.util.Queue<Int> = java.util.LinkedList(listOf(4, 5))
    println("$q ${q.poll()} $q")
    val pq = java.util.PriorityQueue(listOf(3, 1, 2))
    println("${pq.poll()} $pq")
    val m = java.util.TreeMap(mapOf(1 to "a", 2 to "b"))
    println("$m ${m.pollFirstEntry()} $m")
}
