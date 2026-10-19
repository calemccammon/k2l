// A map's keys, values and entries are live views: they see later changes, write removals through and have the JVM's classes.
import java.util.TreeMap

fun t(name: String, f: () -> Any?) {
    val r = try {
        f()
    } catch (e: Exception) {
        e.javaClass.name + ": " + e.message
    }
    println("$name -> $r")
}

fun views(label: String, m: MutableMap<String, Int>) {
    val keys = m.keys
    val values = m.values
    val entries = m.entries
    t("$label start") { "$keys $values $entries ${keys.size} ${values.size} ${entries.size}" }
    m["d"] = 4
    t("$label after put") { "$keys $values $entries ${keys.size} ${values.size} ${entries.size}" }
    m.remove("a")
    t("$label after remove") { "$keys $values $entries ${keys.isEmpty()} ${"b" in keys} ${2 in values}" }
    t("$label keys.remove") { "${keys.remove("b")} ${keys.remove("zz")} $m" }
    m["e"] = 5
    m["f"] = 6
    t("$label values.removeIf") { "${values.removeIf { it % 2 == 0 }} $m" }
    m["g"] = 7
    m["h"] = 8
    t("$label entries.removeIf") { "${entries.removeIf { it.key == "g" }} $m" }
    val it = m.iterator()
    it.next()
    it.remove()
    t("$label iterator remove") { "$m $keys" }
    for (e in m.entries) e.setValue(e.value * 10)
    t("$label setValue") { "$m $values" }
    t("$label same view") { "${m.keys === m.keys} ${m.values === m.values} ${m.entries === m.entries}" }
    t("$label is") {
        val v: Any = values
        val e: Any = entries
        "${v is List<*>} ${v is Collection<*>} ${v is Set<*>} ${e is Set<*>} ${e is List<*>} ${(keys as Any) is MutableSet<*>}"
    }
    t("$label keys add") { (keys as MutableSet<String>).add("x") }
    t("$label values add") { (values as MutableCollection<Int>).add(1) }
    t("$label entries contains") { "${entries.contains(m.entries.first())} ${entries.any { it.key == "h" }}" }
    t("$label keys eq") { "${keys == m.keys.toSet()} ${keys.hashCode() == m.keys.toSet().hashCode()} ${values == values}" }
    t("$label values eq") { "${values == m.values} ${values.toList() == m.values.toList()}" }
    t("$label entries eq") { "${entries == m.entries} ${entries.hashCode() == m.hashCode()}" }
    t("$label classes") { "${keys.javaClass.name} ${values.javaClass.name} ${entries.javaClass.name} ${entries.first().javaClass.name}" }
    t("$label iterators") { "${keys.iterator().javaClass.name} ${values.iterator().javaClass.name} ${entries.iterator().javaClass.name}" }
    t("$label keys ops") { "${keys.map { it.uppercase() }} ${keys.sorted()} ${keys.first()} ${keys.joinToString("|")} ${keys.toList()}" }
    t("$label values ops") { "${values.sum()} ${values.maxOrNull()} ${values.filter { it > 50 }} ${values.contains(80)}" }
    t("$label keys retainAll") { "${keys.retainAll(listOf("h", "e"))} $m" }
    t("$label values remove") { "${values.remove(50)} ${values.remove(999)} $m" }
    t("$label clear") {
        keys.clear()
        "$m ${keys.size} ${values.isEmpty()} $entries"
    }
    m["z"] = 26
    t("$label after clear put") { "$keys $values $entries" }
    t("$label minus") { "${keys + "q"} ${keys - "z"} ${(keys + "q").javaClass.name}" }
}

fun main() {
    views("linked", linkedMapOf("a" to 1, "b" to 2, "c" to 3))
    views("hash", hashMapOf("a" to 1, "b" to 2, "c" to 3))
    views("tree", TreeMap(mapOf("a" to 1, "b" to 2, "c" to 3)))
    views("mutable", mutableMapOf("a" to 1, "b" to 2, "c" to 3))
    val tm = TreeMap(mapOf(3 to "c", 1 to "a", 2 to "b"))
    val nk = tm.navigableKeySet()
    val dk = tm.descendingKeySet()
    val dm = tm.descendingMap()
    t("tree views") { "$nk $dk $dm ${nk.javaClass.name} ${dk.javaClass.name} ${dm.javaClass.name}" }
    t("dm") { "${dm.firstKey()} ${dm.lastKey()} ${dm.keys} ${dm.values} ${dm.entries} ${dm.size} ${dm[2]}" }
    tm[4] = "d"
    t("tree live") { "$nk $dk $dm ${dm.size} ${dk.size}" }
    nk.remove(1)
    t("nk remove") { tm }
    dm[0] = "z"
    t("dm put") { "$tm $dm" }
    dm.remove(4)
    t("dm remove") { "$tm $dm" }
    t("dm poll") { "${dm.pollFirstEntry()} $tm" }
    dk.remove(2)
    t("dk remove") { "$tm $dk" }
    for (e in dm.entries) e.setValue(e.value + "!")
    t("dm setValue") { tm }
    t("dm iterate") { dm.map { "${it.key}:${it.value}" } }
    t("dm headMap") { "${dm.headMap(0)} ${dm.ceilingKey(1)} ${dm.higherKey(3)} ${dm.floorKey(1)}" }
    val sm = mapOf("x" to 1)
    t("single views") { "${sm.keys} ${sm.values} ${sm.entries} ${sm.values is Set<*>} ${sm.values.javaClass.name}" }
    t("single remove") { (sm.keys as MutableSet<String>).remove("x") }
    val em = emptyMap<String, Int>()
    t("empty views") { "${em.keys} ${em.values} ${em.entries} ${(em.values as Any) is List<*>} ${em.keys.javaClass.name}" }
    val um = java.util.Collections.unmodifiableMap(linkedMapOf("a" to 1))
    t("unmodifiable keys") { "${um.keys} ${um.keys.javaClass.name} ${um.values.javaClass.name}" }
    t("unmodifiable keys remove") { (um.keys as MutableSet<String>).remove("a") }
    t("unmodifiable values remove") { (um.values as MutableCollection<Int>).remove(1) }
    val m = linkedMapOf(1 to "a", 2 to "b")
    val k = m.keys
    m.putAll(mapOf(3 to "c"))
    m.getOrPut(4) { "d" }
    m.compute(1) { _, _ -> null }
    t("compute live") { "$k ${m.values}" }
    m -= listOf(2, 3)
    t("minusAssign") { "$m $k" }
    val nested = mutableMapOf("x" to mutableListOf(1))
    nested.values.first().add(2)
    t("nested") { nested }
    var sum = 0
    for (key in m.keys) sum += key
    for (value in m.values) sum += value.length
    for ((key, value) in m) sum += key + value.length
    t("loops") { sum }
    val counts = mutableMapOf<String, Int>()
    for (w in "a b a c b a".split(" ")) counts[w] = (counts[w] ?: 0) + 1
    t("counts") { "${counts.entries.sortedByDescending { it.value }.map { it.key }} ${counts.values.sorted()}" }
}
