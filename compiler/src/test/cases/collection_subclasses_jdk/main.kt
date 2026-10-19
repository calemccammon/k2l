// Classes of the program extending the JDK's PriorityQueue, ArrayDeque, LinkedList, TreeMap and TreeSet: overrides and super
// calls, and which overridden methods the library's own methods call (as in the JDK: PriorityQueue.add calls offer and addAll
// calls add, ArrayDeque.addAll calls addLast, LinkedList.addAll(elements) calls addAll(index, elements), TreeMap.putAll calls
// put, TreeSet(elements) calls add, ...).
import java.util.*

val log = mutableListOf<String>()
fun l(s: String) { log += s }
fun show(what: String, f: () -> Any?) {
    log.clear()
    val r = try { f() } catch (e: Exception) { e.javaClass.simpleName }
    println("$what -> $r $log")
}

class PQ : PriorityQueue<Int>() {
    override fun add(element: Int): Boolean { l("add"); return super.add(element) }
    override fun offer(e: Int): Boolean { l("offer"); return super.offer(e) }
    override fun poll(): Int? { l("poll"); return super.poll() }
    override fun peek(): Int? { l("peek"); return super.peek() }
    override fun remove(element: Int): Boolean { l("remove(e)"); return super.remove(element) }
    override fun addAll(elements: Collection<Int>): Boolean { l("addAll"); return super.addAll(elements) }
    override fun clear() { l("clear"); super.clear() }
    override fun contains(element: Int): Boolean { l("contains"); return super.contains(element) }
    override fun removeAll(elements: Collection<Int>): Boolean { l("removeAll"); return super.removeAll(elements) }
}

class AD : ArrayDeque<Int>() {
    override fun add(element: Int): Boolean { l("add"); return super.add(element) }
    override fun addFirst(e: Int) { l("addFirst"); super.addFirst(e) }
    override fun addLast(e: Int) { l("addLast"); super.addLast(e) }
    override fun offerFirst(e: Int): Boolean { l("offerFirst"); return super.offerFirst(e) }
    override fun offerLast(e: Int): Boolean { l("offerLast"); return super.offerLast(e) }
    override fun pollFirst(): Int? { l("pollFirst"); return super.pollFirst() }
    override fun pollLast(): Int? { l("pollLast"); return super.pollLast() }
    override fun removeFirst(): Int { l("removeFirst"); return super.removeFirst() }
    override fun removeLast(): Int { l("removeLast"); return super.removeLast() }
    override fun peekFirst(): Int? { l("peekFirst"); return super.peekFirst() }
    override fun peekLast(): Int? { l("peekLast"); return super.peekLast() }
    override fun getFirst(): Int { l("getFirst"); return super.getFirst() }
    override fun getLast(): Int { l("getLast"); return super.getLast() }
    override fun addAll(elements: Collection<Int>): Boolean { l("addAll"); return super.addAll(elements) }
}

class LL : LinkedList<Int>() {
    override fun add(element: Int): Boolean { l("add"); return super.add(element) }
    override fun add(index: Int, element: Int) { l("add(i)"); super.add(index, element) }
    override fun addFirst(e: Int) { l("addFirst"); super.addFirst(e) }
    override fun addLast(e: Int) { l("addLast"); super.addLast(e) }
    override fun removeFirst(): Int { l("removeFirst"); return super.removeFirst() }
    override fun removeLast(): Int { l("removeLast"); return super.removeLast() }
    override fun poll(): Int? { l("poll"); return super.poll() }
    override fun pollFirst(): Int? { l("pollFirst"); return super.pollFirst() }
    override fun offer(e: Int): Boolean { l("offer"); return super.offer(e) }
    override fun get(index: Int): Int { l("get"); return super.get(index) }
    override fun removeAt(index: Int): Int { l("removeAt"); return super.removeAt(index) }
    override fun addAll(elements: Collection<Int>): Boolean { l("addAll"); return super.addAll(elements) }
    override fun addAll(index: Int, elements: Collection<Int>): Boolean { l("addAll(i)"); return super.addAll(index, elements) }
    override fun peek(): Int? { l("peek"); return super.peek() }
    override fun getFirst(): Int { l("getFirst"); return super.getFirst() }
}

class TM : TreeMap<String, Int>() {
    override fun put(key: String, value: Int): Int? { l("put $key"); return super.put(key, value) }
    override fun get(key: String): Int? { l("get"); return super.get(key) }
    override fun putAll(from: Map<out String, Int>) { l("putAll"); super.putAll(from) }
    override fun containsKey(key: String): Boolean { l("containsKey"); return super.containsKey(key) }
    override fun remove(key: String): Int? { l("remove"); return super.remove(key) }
    override fun firstKey(): String { l("firstKey"); return super.firstKey() }
}

class TS : TreeSet<Int>() {
    override fun add(element: Int): Boolean { l("add $element"); return super.add(element) }
    override fun addAll(elements: Collection<Int>): Boolean { l("addAll"); return super.addAll(elements) }
    override fun remove(element: Int): Boolean { l("remove"); return super.remove(element) }
    override fun contains(element: Int): Boolean { l("contains"); return super.contains(element) }
    override fun first(): Int { l("first"); return super.first() }
    override fun pollFirst(): Int? { l("pollFirst"); return super.pollFirst() }
}

fun main() {
    val pq = PQ()
    show("pq.add") { pq.add(3) }
    show("pq.offer") { pq.offer(1) }
    show("pq.addAll") { pq.addAll(listOf(5, 2)) }
    show("pq.remove()") { pq.remove() }
    show("pq.element()") { pq.element() }
    show("pq.remove(e)") { pq.remove(5) }
    show("pq.toString") { pq.toString() }
    show("pq.contains") { 3 in pq }
    show("pq.removeAll") { pq.removeAll(listOf(3)) }
    show("pq.removeIf") { pq.removeIf { it > 100 } }
    show("pq.isEmpty") { pq.isEmpty() }
    show("pq.toList") { pq.toList() }
    show("pq.clear") { pq.clear() }
    show("pq.size") { pq.size }

    val ad = AD()
    show("ad.add") { ad.add(1) }
    show("ad.addFirst") { ad.addFirst(0) }
    show("ad.addLast") { ad.addLast(2) }
    show("ad.offer") { ad.offer(3) }
    show("ad.offerFirst") { ad.offerFirst(-1) }
    show("ad.push") { ad.push(-2) }
    show("ad.addAll") { ad.addAll(listOf(7, 8)) }
    show("ad.pop") { ad.pop() }
    show("ad.poll") { ad.poll() }
    show("ad.remove()") { ad.remove() }
    show("ad.removeFirst") { ad.removeFirst() }
    show("ad.removeLast") { ad.removeLast() }
    show("ad.peek") { ad.peek() }
    show("ad.element") { ad.element() }
    show("ad.first") { ad.first() }
    show("ad.last") { ad.last() }
    show("ad.toString") { ad.toString() }
    show("ad.size") { ad.size }
    show("ad.contains") { ad.contains(2) }
    show("ad.pollLast") { ad.pollLast() }
    show("ad.descending") { ad.descendingIterator().asSequence().toList() }
    show("ad.clear") { ad.clear() }
    show("ad.removeFirst empty") { ad.removeFirst() }

    val ll = LL()
    show("ll.add") { ll.add(1) }
    show("ll.add(i)") { ll.add(0, 0) }
    show("ll.addFirst") { ll.addFirst(-1) }
    show("ll.push") { ll.push(-2) }
    show("ll.offer") { ll.offer(2) }
    show("ll.offerFirst") { ll.offerFirst(-3) }
    show("ll.offerLast") { ll.offerLast(3) }
    show("ll.addAll") { ll.addAll(listOf(7, 8)) }
    show("ll.pop") { ll.pop() }
    show("ll.poll") { ll.poll() }
    show("ll.remove()") { ll.remove() }
    show("ll.removeLast") { ll.removeLast() }
    show("ll.peek") { ll.peek() }
    show("ll.element") { ll.element() }
    show("ll.get") { ll[1] }
    show("ll.toString") { ll.toString() }
    show("ll.removeAt") { ll.removeAt(0) }
    show("ll.indexOf") { ll.indexOf(7) }
    show("ll.contains") { ll.contains(7) }
    show("ll.equals") { ll == listOf(2, 3, 7) }
    show("ll.sum") { ll.sum() }
    show("ll.clear") { ll.clear() }

    val tm = TM()
    show("tm.put") { tm.put("b", 2) }
    show("tm.set") { tm["a"] = 1 }
    show("tm.putAll") { tm.putAll(mapOf("d" to 4, "c" to 3)) }
    show("tm.putIfAbsent") { tm.putIfAbsent("e", 5) }
    show("tm.getOrPut") { tm.getOrPut("f") { 6 } }
    show("tm.merge") { tm.merge("a", 10, Int::plus) }
    show("tm.compute") { tm.compute("a") { _, v -> v!! + 1 } }
    show("tm.computeIfAbsent") { tm.computeIfAbsent("g") { 7 } }
    show("tm.get") { tm["a"] }
    show("tm.getValue") { tm.getValue("a") }
    show("tm.contains") { "a" in tm }
    show("tm.getOrDefault") { tm.getOrDefault("z", 0) }
    show("tm.toString") { tm.toString() }
    show("tm.firstKey") { tm.firstKey() }
    show("tm.firstEntry") { tm.firstEntry().key }
    show("tm.remove") { tm.remove("g") }
    show("tm.for") { for ((k, v) in tm) {} }
    show("tm.forEach") { tm.forEach { (k, v) -> } }
    show("tm.keys") { tm.keys.toList() }
    show("tm.map") { tm.map { it.key } }
    show("tm.equals") { tm == mapOf("a" to 12) }
    show("tm.size") { tm.size }
    show("tm.pollFirst") { tm.pollFirstEntry().key }
    show("tm.headMap") { tm.headMap("d") }

    val ts = TS()
    show("ts.add") { ts.add(5) }
    show("ts.addAll") { ts.addAll(listOf(3, 9, 1)) }
    show("ts.plusAssign") { ts += listOf(4) }
    show("ts.contains") { 3 in ts }
    show("ts.remove") { ts.remove(9) }
    show("ts.first") { ts.first() }
    show("ts.last") { ts.last() }
    show("ts.pollFirst") { ts.pollFirst() }
    show("ts.toString") { ts.toString() }
    show("ts.size") { ts.size }
    show("ts.isEmpty") { ts.isEmpty() }
    show("ts.toList") { ts.toList() }
    show("ts.equals") { ts == setOf(3, 4, 5) }
    show("ts.removeAll") { ts.removeAll(listOf(4)) }
    show("ts.ceiling") { ts.ceiling(4) }
    show("ts.headSet") { ts.headSet(5) }
    show("ts.descendingSet") { ts.descendingSet() }
    show("ts.clear") { ts.clear() }
    log.clear()
    val fromList = object : TreeSet<Int>(listOf(2, 1)) { override fun add(element: Int): Boolean { l("ctor add $element"); return super.add(element) } }
    println("TreeSet(coll) $fromList $log")
    log.clear()
    val fromMap = object : TreeMap<String, Int>(mapOf("b" to 1, "a" to 2)) { override fun put(key: String, value: Int): Int? { l("ctor put $key"); return super.put(key, value) } }
    println("TreeMap(map) $fromMap $log")
    log.clear()
    val pqFrom = object : PriorityQueue<Int>(listOf(3, 1, 2)) { override fun add(element: Int): Boolean { l("ctor add"); return super.add(element) } }
    println("PQ(coll) $pqFrom $log")
    println("${ByLength().apply { addAll(listOf("ccc", "a", "bb", "dd")) }} ${MaxFirst().apply { addAll(listOf(1, 5, 3)) }.poll()}")
    val dq = object : ArrayDeque<Int>(listOf(1, 2)) {
        override fun addLast(e: Int) {
            l("ctor addLast $e")
            super.addLast(e)
        }
    }
    println("ArrayDeque(coll) $dq $log")
}

class ByLength : TreeSet<String>(compareBy { it.length })

class MaxFirst : PriorityQueue<Int>(11, reverseOrder())
