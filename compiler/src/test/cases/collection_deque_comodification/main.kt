// Changing an ArrayDeque while iterating over it. Kotlin's ArrayDeque is an AbstractList: its iterators check a modCount,
// which only adding and removing elements move. java.util.ArrayDeque's iterators check nothing: they read the circular
// array slot by slot and throw only on an empty slot, so whether a loop fails depends on where the elements are.
import java.util.Deque
import java.util.Queue

fun t(label: String, f: () -> Any?) {
    try {
        println("$label: ${f()}")
    } catch (e: Throwable) {
        println("$label: ${e::class.simpleName} ${e.message}")
    }
}

fun kd() = ArrayDeque(listOf(1, 2, 3))

fun jd() = java.util.ArrayDeque(listOf(1, 2, 3))

fun <T> walk(d: Iterable<T>, change: (T) -> Unit): String {
    val seen = mutableListOf<T>()
    for (x in d) {
        seen += x
        change(x)
    }
    return "$seen $d"
}

class Tracked : java.util.ArrayDeque<String>(2) {
    var adds = 0

    override fun addLast(e: String) {
        adds++
        super.addLast(e)
    }
}

fun main() {
    // kotlin.collections.ArrayDeque
    t("kd addLast") { val d = kd(); for (x in d) if (x == 1) d.addLast(9); d }
    t("kd addFirst") { val d = kd(); for (x in d) if (x == 1) d.addFirst(9); d }
    t("kd removeFirst") { val d = kd(); for (x in d) if (x == 1) d.removeFirst(); d }
    t("kd removeLast at the end") { val d = kd(); for (x in d) if (x == 2) d.removeLast(); d }
    t("kd set") { val d = kd(); for (x in d) d[0] = x; d }
    t("kd add(i)") { val d = kd(); for (x in d) if (x == 1) d.add(0, 5); d }
    t("kd remove absent") { val d = kd(); for (x in d) if (x == 1) d.remove(7); d }
    t("kd clear") { val d = kd(); for (x in d) if (x == 1) d.clear(); d }
    t("kd addAll") { val d = kd(); for (x in d) if (x == 1) d.addAll(listOf(4)); d }
    t("kd addAll empty") { val d = kd(); for (x in d) if (x == 1) d.addAll(listOf()); d }
    t("kd addAll(i) empty") { val d = kd(); for (x in d) if (x == 1) d.addAll(1, listOf()); d }
    t("kd removeAll none") { val d = kd(); for (x in d) if (x == 1) d.removeAll { it == 7 }; d }
    t("kd retainAll") { val d = kd(); for (x in d) if (x == 1) d.retainAll { it != 3 }; d }
    t("kd sort") { val d = ArrayDeque(listOf(3, 1, 2)); for (x in d) if (x == 3) d.sort(); d }
    t("kd sortWith") { val d = ArrayDeque(listOf(3, 1, 2)); for (x in d) if (x == 3) d.sortWith(compareByDescending { it }); d }
    t("kd sortBy") { val d = ArrayDeque(listOf(3, 1, 2)); for (x in d) if (x == 3) d.sortBy { -it }; d }
    t("kd replaceAll") { val d = kd(); for (x in d) if (x == 1) d.replaceAll { it * 10 }; d }
    t("kd reverse shuffle fill") { val d = kd(); for (x in d) if (x == 1) { d.reverse(); d.fill(4) }; d }
    t("kd removeFirstOrNull") { val d = kd(); for (x in d) if (x == 1) d.removeFirstOrNull(); d }
    t("kd removeFirstOrNull empty") { val d = ArrayDeque<Int>(); val it = d.iterator(); d.removeFirstOrNull(); d.clear(); it.hasNext() }
    t("kd iterator after clear of empty") { val d = ArrayDeque<Int>(); val it = d.iterator(); d.clear(); it.next() }
    t("kd iterator after add") { val d = ArrayDeque<Int>(); val it = d.iterator(); d.addLast(1); it.next() }
    t("kd iterator remove") { val d = kd(); val it = d.iterator(); while (it.hasNext()) if (it.next() == 2) it.remove(); d }
    t("kd forEach") { val d = kd(); d.forEach { if (it == 1) d.addLast(4) }; d }
    t("kd subList") { val d = kd(); val s = d.subList(0, 2); d.addLast(5); s.size }
    t("kd subList after sort") { val d = kd(); val s = d.subList(0, 2); d.sortDescending(); s }
    t("kd add(i) index") { kd().add(4, 1) }
    t("kd addAll(i) index") { kd().addAll(-1, listOf(1)) }

    // java.util.ArrayDeque: 3 elements in an array of 4 slots
    t("jd addLast") { walk(jd()) { if (it == 1) jd().addLast(0) } }
    t("jd addLast grows") { val d = jd(); walk(d) { if (it == 1) d.addLast(9) } }
    t("jd addLast at the end") { val d = jd(); walk(d) { if (it == 3) d.addLast(9) } }
    t("jd addFirst grows") { val d = jd(); walk(d) { if (it == 1) d.addFirst(9) } }
    t("jd removeFirst") { val d = jd(); walk(d) { if (it == 1) d.removeFirst() } }
    t("jd poll") { val d = jd(); walk(d) { if (it == 2) d.poll() } }
    t("jd removeLast") { val d = jd(); walk(d) { if (it == 1) d.removeLast() } }
    t("jd pollLast at the end") { val d = jd(); walk(d) { if (it == 3) d.pollLast() } }
    t("jd clear") { val d = jd(); walk(d) { if (it == 1) d.clear() } }
    t("jd remove middle") { val d = jd(); walk(d) { if (it == 1) d.remove(2) } }
    t("jd remove first") { val d = jd(); walk(d) { if (it == 2) d.remove(1) } }
    t("jd removeIf") { val d = jd(); walk(d) { if (it == 1) d.removeIf { e -> e == 3 } } }
    t("jd push pop") { val d = jd(); walk(d) { if (it == 2) { d.push(7); d.pop() } } }
    // with room to spare: adding does not move the elements, so the loop goes on over the ones it started with
    t("jd roomy addLast") { val d = java.util.ArrayDeque<Int>(); d.addAll(listOf(1, 2, 3)); walk(d) { if (it < 3) d.addLast(it * 10) } }
    t("jd roomy addFirst") { val d = java.util.ArrayDeque<Int>(); d.addAll(listOf(1, 2, 3)); walk(d) { if (it == 1) d.addFirst(0) } }
    t("jd capacity") { val d = java.util.ArrayDeque<Int>(8); for (i in 1..3) d.addLast(i); walk(d) { if (it == 1) d.addLast(4) } }
    // a deque that wraps around its array before it grows
    t("jd wrapped") {
        val d = java.util.ArrayDeque<Int>(4)
        for (i in 1..4) d.addLast(i)
        d.pollFirst()
        d.pollFirst()
        d.addLast(5)
        d.addLast(6)
        walk(d) { if (it == 4) d.addLast(7) }
    }
    t("jd wrapped grows") {
        val d = java.util.ArrayDeque<Int>(4)
        for (i in 1..4) d.addLast(i)
        d.pollFirst()
        d.addLast(5)
        walk(d) { if (it == 3) d.addLast(6) }
    }
    t("jd many") {
        val d = java.util.ArrayDeque<Int>()
        for (i in 1..40) if (i % 3 == 0) d.addFirst(i) else d.addLast(i)
        repeat(5) { d.pollFirst() }
        var steps = 0
        for (x in d) {
            if (++steps % 7 == 0) d.addLast(x)
        }
        "$steps ${d.size}"
    }
    // through the iterator, its descending one, and forEach
    t("jd iterator remove") { val d = jd(); val it = d.iterator(); while (it.hasNext()) if (it.next() != 2) it.remove(); d }
    t("jd iterator remove all") { val d = java.util.ArrayDeque((1..9).toList()); val it = d.iterator(); while (it.hasNext()) { it.next(); it.remove() }; d }
    t("jd iterator twice") { val d = jd(); val it = d.iterator(); it.next(); it.remove(); it.remove() }
    t("jd iterator class") { "${jd().iterator().javaClass.name} ${jd().descendingIterator().javaClass.name}" }
    t("jd iterator end") { val i = jd().iterator(); repeat(3) { i.next() }; i.next() }
    t("jd descending") {
        val d = java.util.ArrayDeque((1..6).toList())
        val out = mutableListOf<Int>()
        val it = d.descendingIterator()
        while (it.hasNext()) {
            val x = it.next()
            out += x
            if (x % 2 == 0) it.remove()
        }
        "$out $d"
    }
    t("jd descending pollLast") { val d = jd(); val it = d.descendingIterator(); it.next(); d.pollLast(); it.next() }
    t("jd descending pollFirst") { val d = jd(); val it = d.descendingIterator(); it.next(); d.pollFirst(); "${it.next()} ${it.hasNext()}" }
    t("jd forEach") { val d = jd(); d.forEach { if (it == 1) d.removeLast() }; d }
    t("jd forEachIndexed") { val d = jd(); d.forEachIndexed { i, x -> if (i == 0) d.addFirst(x) }; d }
    // typed as Deque, Queue or a subclass
    t("Deque") { val d: Deque<Int> = jd(); for (x in d) if (x == 1) d.removeLast(); d }
    t("Queue") { val q: Queue<Int> = jd(); for (x in q) if (x == 2) q.poll(); q }
    t("Queue of a LinkedList") { val q: Queue<Int> = java.util.LinkedList(listOf(1, 2, 3)); for (x in q) if (x == 2) q.poll(); q }
    t("Queue of a PriorityQueue") { val q: Queue<Int> = java.util.PriorityQueue(listOf(3, 1, 2)); for (x in q) if (x == 3) q.add(0); q }
    t("subclass") {
        val d = Tracked()
        d.addAll(listOf("a", "b"))
        val seen = mutableListOf<String>()
        for (x in d) {
            seen += x
            if (x == "a") d.addLast("c")
        }
        "$seen $d ${d.adds}"
    }
}
