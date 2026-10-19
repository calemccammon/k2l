// ConcurrentModificationException where the JVM throws it: changes during for loops, forEach and iterators, stale subLists.
import java.util.TreeMap
import java.util.LinkedList
import java.util.PriorityQueue

fun t(name: String, f: () -> Any?) {
    val r = try {
        f()
    } catch (e: Exception) {
        e.javaClass.name + ": " + e.message
    }
    println("$name -> $r")
}

fun main() {
    t("list add in for") {
        val l = mutableListOf(1, 2, 3)
        val seen = mutableListOf<Int>()
        for (x in l) { seen += x; if (x == 1) l.add(9) }
        seen
    }
    t("list remove second-to-last") {
        val l = mutableListOf(1, 2, 3)
        val seen = mutableListOf<Int>()
        for (x in l) { seen += x; if (x == 2) l.remove(x) }
        "$seen $l"
    }
    t("list remove last") {
        val l = mutableListOf(1, 2, 3)
        val seen = mutableListOf<Int>()
        for (x in l) { seen += x; if (x == 3) l.remove(x) }
        "$seen $l"
    }
    t("list remove first") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) if (x == 1) l.remove(x)
        l
    }
    t("list add at last") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) if (x == 3) l.add(4)
        l
    }
    t("list remove two at second") {
        val l = mutableListOf(1, 2, 3, 4)
        val seen = mutableListOf<Int>()
        for (x in l) { seen += x; if (x == 2) { l.removeAt(3); l.removeAt(2) } }
        "$seen $l"
    }
    t("list add+remove") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) if (x == 1) { l.add(5); l.removeAt(3) }
        l
    }
    t("list sort in loop") {
        val l = mutableListOf(3, 2, 1)
        for (x in l) l.sort()
        l
    }
    t("list set in loop") {
        val l = mutableListOf(3, 2, 1)
        for ((i, x) in l.withIndex()) l[i] = x * 2
        for (x in l) l[0] = x
        l
    }
    t("list forEach add") {
        val l = mutableListOf(1, 2)
        l.forEach { if (it == 1) l.add(3) }
        l
    }
    t("list forEachIndexed add") {
        val l = mutableListOf(1, 2)
        l.forEachIndexed { i, x -> if (i == 0) l.add(x) }
        l
    }
    t("list break after add") {
        val l = mutableListOf(1, 2)
        for (x in l) { l.add(x); break }
        l
    }
    t("list continue after add") {
        val l = mutableListOf(1, 2)
        val seen = mutableListOf<Int>()
        for (x in l) { seen += x; if (x == 1) { l.add(7); continue }; seen += 100 }
        seen
    }
    t("iterator add") {
        val l = mutableListOf(1, 2, 3)
        val it = l.iterator()
        it.next()
        l.add(4)
        it.next()
    }
    t("iterator hasNext after remove") {
        val l = mutableListOf(1, 2, 3)
        val it = l.iterator()
        it.next(); it.next()
        l.removeAt(0)
        "${it.hasNext()}"
    }
    t("iterator remove ok") {
        val l = mutableListOf(1, 2, 3, 4)
        val it = l.iterator()
        while (it.hasNext()) if (it.next() % 2 == 0) it.remove()
        l
    }
    t("iterator remove twice") {
        val l = mutableListOf(1, 2, 3)
        val it = l.iterator()
        it.next(); it.remove(); it.remove()
    }
    t("removeIf in loop?") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) if (x == 1) l.removeIf { it == 99 }
        l
    }
    t("clear in loop") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) l.clear()
        l
    }
    t("addAll empty") {
        val l = mutableListOf(1, 2, 3)
        for (x in l) l.addAll(emptyList())
        l
    }
    t("sublist stale") {
        val l = mutableListOf(1, 2, 3, 4)
        val s = l.subList(1, 3)
        l.add(5)
        s.size
    }
    t("sublist stale print") {
        val l = mutableListOf(1, 2, 3, 4)
        val s = l.subList(1, 3)
        l.removeAt(0)
        s.toString()
    }
    t("sublist stale get") {
        val l = mutableListOf(1, 2, 3, 4)
        val s = l.subList(1, 3)
        l.add(0, 0)
        s[0]
    }
    t("sublist set ok") {
        val l = mutableListOf(1, 2, 3, 4)
        val s = l.subList(1, 3)
        l[0] = 100
        "$s ${s.size}"
    }
    t("sublist via sublist ok") {
        val l = mutableListOf(1, 2, 3, 4)
        val s = l.subList(1, 3)
        s.add(9)
        "$s $l"
    }
    t("sibling stale") {
        val l = mutableListOf(1, 2, 3, 4)
        val a = l.subList(0, 2)
        val b = l.subList(2, 4)
        a.add(7)
        b.size
    }
    t("parent of sub ok") {
        val l = mutableListOf(1, 2, 3, 4)
        val a = l.subList(0, 3)
        val b = a.subList(0, 2)
        b.add(7)
        "$a $l"
    }
    t("sub loop root change") {
        val l = mutableListOf(1, 2, 3, 4)
        val a = l.subList(0, 3)
        for (x in a) l.add(x)
        l
    }
    t("hashmap put in loop") {
        val m = hashMapOf(1 to 1, 2 to 2, 3 to 3)
        for ((k, _) in m) if (k == 1) m[10] = 10
        m
    }
    t("hashmap put at last") {
        val m = hashMapOf(1 to 1, 2 to 2, 3 to 3)
        for ((k, _) in m) if (k == 3) m[10] = 10
        m
    }
    t("hashmap remove at last") {
        val m = hashMapOf(1 to 1, 2 to 2, 3 to 3)
        for ((k, _) in m) if (k == 3) m.remove(1)
        m
    }
    t("hashmap remove current second") {
        val m = hashMapOf(1 to 1, 2 to 2, 3 to 3)
        for (k in m.keys) if (k == 2) m.remove(k)
        m
    }
    t("linked put in keys loop") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        for (k in m.keys) m[k + 10] = 0
        m
    }
    t("linked values loop remove") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        for (v in m.values) m.remove(1)
        m
    }
    t("linked entries setValue ok") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        for (e in m.entries) e.setValue(5)
        for ((k, _) in m) m[k] = 7
        m
    }
    t("map forEach kv put") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        val seen = mutableListOf<Int>()
        m.forEach { k, _ -> seen += k; if (k == 1) m[3] = 3 }
        "$seen $m"
    }
    t("map forEach kv put last") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        m.forEach { k, _ -> if (k == 2) m[3] = 3 }
        m
    }
    t("map forEach entry put") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        m.forEach { e -> if (e.key == 1) m[3] = 3 }
        m
    }
    t("map iterator remove") {
        val m = linkedMapOf(1 to 1, 2 to 2, 3 to 3)
        val it = m.entries.iterator()
        while (it.hasNext()) if (it.next().key == 2) it.remove()
        m
    }
    t("map keys iterator then put") {
        val m = linkedMapOf(1 to 1, 2 to 2, 3 to 3)
        val it = m.keys.iterator()
        it.next()
        m[4] = 4
        it.next()
    }
    t("set add in loop") {
        val s = mutableSetOf(1, 2, 3)
        for (x in s) if (x == 1) s.add(9)
        s
    }
    t("hashset remove in loop at last") {
        val s = hashSetOf(1, 2, 3)
        for (x in s) if (x == 3) s.remove(1)
        s
    }
    t("set clear in loop") {
        val s = mutableSetOf(1, 2, 3)
        for (x in s) s.clear()
        s
    }
    t("treemap put in loop") {
        val m = TreeMap(mapOf(1 to 1, 2 to 2))
        for ((k, _) in m) if (k == 1) m[0] = 0
        m
    }
    t("treeset in loop") {
        val s = sortedSetOf(1, 2, 3)
        for (x in s) if (x == 2) s.add(0)
        s
    }
    t("linkedlist add") {
        val l = LinkedList(listOf(1, 2))
        for (x in l) if (x == 1) l.add(3)
        l
    }
    t("linkedlist remove last") {
        val l = LinkedList(listOf(1, 2, 3))
        for (x in l) if (x == 3) l.removeFirst()
        l
    }
    t("arraydeque kotlin add") {
        val d = ArrayDeque(listOf(1, 2))
        for (x in d) if (x == 1) d.addLast(3)
        d
    }
    t("pq add") {
        val q = PriorityQueue(listOf(1, 2, 3))
        for (x in q) if (x == 1) q.add(0)
        q
    }
    t("pq add at last") {
        val q = PriorityQueue(listOf(1, 2, 3))
        for (x in q) if (x == 3) q.add(5)
        q.toList()
    }
    t("map entries loop remove via entries") {
        val m = linkedMapOf(1 to 1, 2 to 2, 3 to 3)
        for (e in m.entries) if (e.key == 1) m.entries.remove(e)
        m
    }
    t("removeAll during keys loop") {
        val m = linkedMapOf(1 to 1, 2 to 2, 3 to 3)
        for (k in m.keys) if (k == 1) m.keys.removeAll(listOf(3))
        m
    }
    t("getOrPut in loop existing") {
        val m = linkedMapOf(1 to 1, 2 to 2)
        for (k in m.keys) m.getOrPut(k) { 0 }
        m
    }
    t("array no cme") {
        val a = arrayOf(1, 2, 3)
        for (x in a) a[0] = x
        a.toList()
    }
}
