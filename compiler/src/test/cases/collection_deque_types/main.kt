// java.util.ArrayDeque is not a List; Queue and Deque type tests.
import java.util.LinkedList
import java.util.PriorityQueue
import java.util.Queue
import java.util.Deque

fun t(name: String, f: () -> Any?) {
    val r = try {
        f()
    } catch (e: Exception) {
        e.javaClass.name + ": " + e.message
    }
    println("$name -> $r")
}

fun main() {
    val d = java.util.ArrayDeque(listOf(1, 2, 3))
    val a: Any = d
    t("is") { "${a is List<*>} ${a is MutableList<*>} ${a is Collection<*>} ${a is MutableCollection<*>} ${a is Iterable<*>} ${a is Set<*>}" }
    t("is queue") { "${a is Queue<*>} ${a is Deque<*>} ${a is java.util.ArrayDeque<*>} ${a is LinkedList<*>} ${a is ArrayDeque<*>}" }
    t("as list") { a as List<*> }
    t("as mutable list") { a as MutableList<*> }
    t("as queue") { (a as Queue<*>).peek() }
    t("eq") { "${d == listOf(1, 2, 3)} ${listOf(1, 2, 3) == d} ${d.toList() == listOf(1, 2, 3)} ${d == d}" }
    t("first empty") { java.util.ArrayDeque<Int>().first() }
    t("single") { d.single() }
    t("ops") { "${d.map { it * 2 }} ${d.first()} ${d.last()} ${d.elementAt(1)} ${d.indexOf(2)} ${d.contains(3)} ${d.sum()}" }
    t("loop") { var s = 0; for (x in d) s += x; s }
    t("toString") { d.toString() }
    t("unmodifiable") { java.util.Collections.unmodifiableCollection(d).javaClass.name }
    val ll: Any = LinkedList(listOf(1))
    t("linked") { "${ll is List<*>} ${ll is Queue<*>} ${ll is Deque<*>} ${ll is java.util.ArrayDeque<*>}" }
    val kd: Any = ArrayDeque(listOf(1))
    t("kotlin deque") { "${kd is List<*>} ${kd is Queue<*>} ${kd is Deque<*>} ${kd is ArrayDeque<*>} ${kd is MutableList<*>}" }
    val pq: Any = PriorityQueue(listOf(1))
    t("pq") { "${pq is Queue<*>} ${pq is Deque<*>} ${pq is List<*>} ${pq is Collection<*>} ${pq is PriorityQueue<*>}" }
    val al: Any = arrayListOf(1)
    t("arraylist") { "${al is Queue<*>} ${al is Deque<*>} ${al is LinkedList<*>} ${al is ArrayDeque<*>} ${al is java.util.ArrayDeque<*>}" }
}
