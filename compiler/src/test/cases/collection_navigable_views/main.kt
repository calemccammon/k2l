// headMap/tailMap/subMap/descendingMap and headSet/tailSet/subSet/descendingSet are live views of the TreeMap or TreeSet:
// they see its later changes, write through to it, check their range, and narrow it for views of views.
import java.util.TreeMap
import java.util.TreeSet

fun t(label: String, f: () -> Any?) {
    try {
        println("$label: ${f()}")
    } catch (e: Throwable) {
        println("$label: ${e::class.simpleName} ${e.message}")
    }
}

fun tm() = TreeMap((1..9).associateWith { "v$it" })

fun ts() = TreeSet((1..9).toList())

class Audited : TreeMap<Int, String>() {
    val log = mutableListOf<String>()

    override fun put(key: Int, value: String): String? {
        log += "put $key"
        return super.put(key, value)
    }
}

fun main() {
    // live: later changes of the map show, and so does the size
    val m = tm()
    val h = m.headMap(5)
    val nh = m.headMap(5, true)
    val tl = m.tailMap(7)
    val sub = m.subMap(3, 6)
    println("$h $nh $tl $sub ${h.javaClass.name}")
    m[0] = "zero"
    m.remove(4)
    m[10] = "ten"
    println("$h ${h.size} $nh ${nh.size} $tl ${tl.size} $sub ${sub.size}")
    println("${h.keys} ${h.values} ${h.entries} ${nh.firstKey()} ${nh.lastKey()} ${tl.firstEntry()} ${sub.isEmpty()}")

    // reads outside the range miss; writes outside it throw
    t("get out") { "${h[8]} ${h.containsKey(8)} ${h.getOrDefault(8, "d")} ${h.remove(8)} ${8 in h.keys}" }
    t("put out") { h[7] = "x" }
    t("putIfAbsent out") { h.putIfAbsent(9, "x") }
    t("merge out") { h.merge(9, "x") { a, b -> a + b } }
    t("compute out") { h.compute(9) { _, _ -> "x" } }
    t("computeIfAbsent out") { h.computeIfAbsent(9) { "x" } }
    t("putAll partly out") { val c = tm(); val v = c.headMap(3); v.putAll(mapOf(-1 to "a", 8 to "b")); c }
    t("put in") { val c = tm(); val v = c.headMap(3); v[-5] = "m"; v.putIfAbsent(0, "z"); v.merge(1, "!") { a, b -> a + b }; c }
    t("remove in") { val c = tm(); val v = c.subMap(3, 6); "${v.remove(4)} ${v.remove(3, "nope")} ${v.remove(5, "v5")} $c" }
    t("replaceAll") { val c = tm(); c.tailMap(7).replaceAll { k, v -> "$v$k" }; c }
    t("clear") { val c = tm(); val v = c.subMap(2, 8); v.clear(); "$c $v ${v.size}" }
    t("poll") { val c = tm(); val v = c.headMap(4); val p = "${v.pollFirstEntry()} ${v.pollLastEntry()} $c"; "$p ${v.pollFirstEntry()?.javaClass?.name} $c" }
    t("navigation") { val v = tm().subMap(3, true, 6, true); "${v.ceilingKey(7)} ${v.floorKey(100)} ${v.higherKey(5)} ${v.lowerKey(3)} ${v.floorEntry(4)}" }
    t("empty view") { val v = tm().subMap(4, 4); "$v ${v.size} ${v.isEmpty()} ${v.firstEntry()}" }
    t("empty firstKey") { tm().headMap(-1).firstKey() }
    t("reversed bounds") { tm().subMap(6, 3) }
    t("equals") { val v = tm().headMap(4); "${v == mapOf(1 to "v1", 2 to "v2", 3 to "v3")} ${v.hashCode() == TreeMap(v).hashCode()} ${TreeMap(v)}" }

    // views of views narrow the range; a bound outside it throws
    t("head of head") { m.headMap(5, false).headMap(3) }
    t("head of head out") { m.headMap(5, false).headMap(7) }
    t("tail of head") { m.headMap(5, false).tailMap(2, true) }
    t("tail of head at the bound") { "${m.headMap(5, false).tailMap(5, false)}" }
    t("tail of head past the bound") { m.headMap(5, false).tailMap(5, true) }
    t("sub of tail") { m.tailMap(2, true).subMap(3, false, 8, true) }
    t("sub of tail out") { m.tailMap(2, true).subMap(1, true, 8, true) }
    t("view of view live") { val c = tm(); val v = c.tailMap(2, true).headMap(8, false).subMap(3, true, 6, true); c.remove(5); c[4] = "four"; "$v ${v.size}" }

    // descending views
    val dm = m.descendingMap()
    println("$dm ${dm.javaClass.name} ${dm.descendingMap().javaClass.name} ${dm.firstKey()}")
    t("descending head") { dm.headMap(5) }
    t("descending tail") { dm.tailMap(5, false) }
    t("descending sub") { dm.subMap(7, 3) }
    t("descending sub reversed") { dm.subMap(3, 7) }
    t("descending of a view") { val v = m.subMap(2, true, 6, true).descendingMap(); "$v ${v.headMap(3)} ${v.descendingMap()} ${v.ceilingKey(4)}" }
    t("descending poll") { val c = tm(); val v = c.headMap(4, true).descendingMap(); "${v.pollFirstEntry()} $c" }
    t("descending put out") { tm().headMap(4, true).descendingMap()[6] = "x" }
    t("descending keys") { "${m.descendingKeySet()} ${m.headMap(3, true).descendingKeySet()} ${m.headMap(3, true).navigableKeySet()}" }
    t("view classes") {
        val v = m.headMap(4, true)
        listOf(v.keys, v.values, v.entries, v.entries.iterator(), v.keys.iterator(), dm.entries, dm.keys.iterator(), dm.entries.iterator())
            .joinToString { it.javaClass.name }
    }

    // loops and iterators over views see the map change
    t("loop") { val out = mutableListOf<String>(); for ((k, v) in m.subMap(1, 4)) out += "$k$v"; out }
    t("loop cme") { val c = tm(); for (k in c.headMap(3).keys) c[100] = "x"; c }
    t("loop change at the end") { val c = tm(); for (e in c.headMap(3).entries) if (e.key == 2) c[100] = "x"; c.size }
    t("iterator remove") { val c = tm(); val it = c.headMap(4).entries.iterator(); it.next(); it.remove(); it.next(); it.remove(); c }
    t("keys remove") { val c = tm(); val v = c.subMap(2, 6); v.keys.remove(3); v.keys.removeIf { it % 2 == 0 }; v.values.remove("v5"); "$c $v" }
    t("entries live") { val c = tm(); val e = c.subMap(2, 6).entries.first(); c[2] = "two"; e.setValue("TWO"); "$e ${c[2]}" }
    t("keys headSet") { "${m.navigableKeySet().headSet(3)} ${m.navigableKeySet().tailSet(8)} ${m.navigableKeySet().subSet(2, 4)}" }
    t("copies") { val v = tm().subMap(2, 5); "${TreeMap(v)} ${v.toSortedMap()} ${v.toMap()} ${v.filter { it.key > 2 }} ${v.map { it.value }}" }

    // the map's own put is called, as NavigableSubMap.put calls it
    t("subclass") { val a = Audited(); a[1] = "a"; val v = a.headMap(5); v[2] = "b"; v.putAll(mapOf(3 to "c")); "${a.log} $a" }
    // a map ordered by a comparator: the ranges follow its order
    t("comparator") {
        val r = TreeMap<Int, String>(reverseOrder())
        for (i in 1..6) r[i] = "r$i"
        "${r.headMap(4)} ${r.tailMap(4)} ${r.subMap(5, 2)} ${r.descendingMap().headMap(3)}"
    }

    // TreeSet views
    val s = ts()
    val hs = s.headSet(5)
    val ss = s.subSet(2, true, 6, true)
    println("$hs $ss ${hs.javaClass.name}")
    s.add(0)
    s.remove(3)
    println("$hs ${hs.size} $ss ${ss.size} ${hs.first()} ${hs.last()} ${3 in hs} ${8 in hs}")
    t("set add out") { hs.add(7) }
    t("set add in") { val c = ts(); val v = c.headSet(5); "${v.add(-1)} ${v.add(2)} $c" }
    t("set addAll partly out") { val c = ts(); val v = c.headSet(5); v.addAll(listOf(-3, 20)); c }
    t("set remove") { val c = ts(); val v = c.headSet(5); "${v.remove(8)} ${v.remove(2)} $c" }
    t("set removeAll") { val c = ts(); c.headSet(6).removeAll(listOf(1, 2, 8)); c }
    t("set removeAll larger") { val c = ts(); c.headSet(3).removeAll(listOf(1, 5, 7, 8, 9)); c }
    t("set retainAll") { val c = ts(); c.subSet(2, 7).retainAll(setOf(3, 4, 9)); c }
    t("set removeIf") { val c = ts(); c.tailSet(4).removeIf { it % 2 == 0 }; c }
    t("set clear") { val c = ts(); val v = c.subSet(3, 6); v.clear(); "$c $v ${v.isEmpty()}" }
    t("set poll") { val c = ts(); val v = c.subSet(3, true, 7, false); "${v.pollFirst()} ${v.pollLast()} $c" }
    t("set navigation") { val v = ts().subSet(3, true, 7, false); "${v.ceiling(8)} ${v.floor(100)} ${v.higher(5)} ${v.lower(3)}" }
    t("set empty first") { ts().headSet(0).first() }
    t("set empty") { val v = ts().subSet(4, 4); "$v ${v.size} ${v.isEmpty()} ${v.firstOrNull()}" }
    t("set reversed bounds") { ts().subSet(6, 3) }
    t("set head of head out") { ts().headSet(5, false).headSet(7) }
    t("set tail of head out") { ts().headSet(5, false).tailSet(6, true) }
    t("set view of view") { val c = ts(); val v = c.tailSet(1).headSet(7).subSet(2, 6); c.remove(4); c.add(4); c.remove(3); "$v ${v.size}" }
    t("set descending") {
        val c = ts()
        val d = c.descendingSet()
        c.add(50)
        "$d ${d.first()} ${d.headSet(4)} ${d.tailSet(4)} ${d.subSet(8, 5)} ${d.descendingSet()} ${d.javaClass.name}"
    }
    t("set descending add") { val c = ts(); val d = c.headSet(3, true).descendingSet(); d.add(-7); "${d.remove(9)} $d $c" }
    t("set descending out") { ts().headSet(3, true).descendingSet().add(8) }
    t("set descendingIterator") { val c = ts(); val it = c.descendingIterator(); val a = it.next(); it.remove(); "$a ${it.next()} $c ${it.javaClass.name}" }
    t("set iterators") { "${hs.iterator().javaClass.name} ${s.headSet(5, false).descendingSet().iterator().javaClass.name}" }
    t("set loop") { val out = mutableListOf<Int>(); for (x in ss) out += x * 10; out }
    t("set loop cme") { val c = ts(); for (x in c.headSet(3)) c.add(100); c }
    t("set loop cme outside the range") { val c = ts(); for (x in c.headSet(3)) c.remove(9); c }
    t("set iterator remove") { val c = ts(); val it = c.subSet(2, 5).iterator(); it.next(); it.remove(); it.next(); "$c" }
    t("set operations") { val v = ts().subSet(2, 6); "${v.toList()} ${v.map { it * 2 }} ${v.filter { it > 3 }} ${v.sum()} ${v.toSortedSet()} ${TreeSet(v)}" }
    t("set equals") { val v = ts().headSet(4); "${v == setOf(1, 2, 3)} ${setOf(1, 2, 3) == v} ${v.hashCode()}" }
    t("set comparator") { val r = TreeSet(reverseOrder<Int>()).apply { addAll(1..6) }; "${r.headSet(4)} ${r.subSet(5, 2)} ${r.descendingSet().tailSet(3)}" }
}
