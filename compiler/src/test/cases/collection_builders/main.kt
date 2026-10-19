// buildList/buildSet/buildMap return the stdlib's builders, read-only after the block.
fun t(name: String, f: () -> Any?) {
    val r = try {
        f()
    } catch (e: Exception) {
        e.javaClass.name + ": " + e.message
    }
    println("$name -> $r")
}

fun main() {
    val l = buildList { add(1); add(2) }
    t("list") { "$l ${l.javaClass.name} ${l.size} ${l is MutableList<*>} ${l == listOf(1, 2)} ${l.hashCode()}" }
    t("add") { (l as MutableList<Int>).add(3) }
    t("set") { (l as MutableList<Int>).set(0, 3) }
    t("remove") { (l as MutableList<Int>).removeAt(0) }
    t("clear") { (l as MutableList<Int>).clear() }
    t("sort") { (l as MutableList<Int>).sort() }
    t("empty") { val e = buildList<Int> { }; "$e ${e.javaClass.name}" }
    t("empty add") { (buildList<Int> { } as MutableList<Int>).add(1) }
    t("cap") { buildList(5) { add("x") }.javaClass.name }
    t("sub") { val s = l.subList(0, 1); "$s ${s.javaClass.name}" }
    t("iter") { l.iterator().javaClass.name }
    t("iter remove") { val it = (l as MutableList<Int>).iterator(); it.next(); it.remove() }
    t("listIterator") { l.listIterator().javaClass.name }
    t("map") { l.map { it * 2 }.javaClass.name }
    t("toList") { l.toList().javaClass.name }
    t("toMutableList") { l.toMutableList().apply { add(9) } }
    val s = buildSet { add(1); add(2); add(1) }
    t("set") { "$s ${s.javaClass.name} ${s.size} ${s == setOf(1, 2)} ${s.hashCode()}" }
    t("set add") { (s as MutableSet<Int>).add(3) }
    t("set remove") { (s as MutableSet<Int>).remove(1) }
    t("set iter") { s.iterator().javaClass.name }
    t("set empty") { val e = buildSet<Int> { }; "$e ${e.javaClass.name}" }
    val m = buildMap { put(1, "a"); put(2, "b") }
    t("map") { "$m ${m.javaClass.name} ${m.size} ${m == mapOf(1 to "a", 2 to "b")} ${m.hashCode()}" }
    t("map put") { (m as MutableMap<Int, String>).put(3, "c") }
    t("map remove") { (m as MutableMap<Int, String>).remove(1) }
    t("map keys") { "${m.keys} ${m.keys.javaClass.name} ${m.values.javaClass.name} ${m.entries.javaClass.name}" }
    t("map keys remove") { (m.keys as MutableSet<Int>).remove(1) }
    t("map entry set") { (m.entries.first() as MutableMap.MutableEntry<Int, String>).setValue("z") }
    t("map entry class") { m.entries.first().javaClass.name }
    t("map empty") { val e = buildMap<Int, Int> { }; "$e ${e.javaClass.name}" }
    t("inside") {
        buildList {
            add(1)
            println("in ${this.javaClass.name} ${this}")
            addAll(listOf(2, 3))
            removeAt(0)
            set(0, 5)
        }
    }
    t("escape") {
        var saved: MutableList<Int>? = null
        val r = buildList { add(1); saved = this }
        saved!!.add(2)
    }
    t("is") { "${(l as Any) is MutableList<*>} ${(s as Any) is MutableSet<*>} ${(m as Any) is MutableMap<*, *>}" }
    val nm: Map<String, Int>? = null
    val nl: List<Int>? = null
    val ns: Set<Int>? = null
    val m2: Map<String, Int>? = mapOf("a" to 1)
    t("orEmpty") { "${nm.orEmpty()} ${nl.orEmpty()} ${ns.orEmpty()} ${m2.orEmpty()} ${nm.orEmpty().javaClass.name} ${nl.orEmpty().javaClass.name} ${ns.orEmpty().javaClass.name}" }
}
