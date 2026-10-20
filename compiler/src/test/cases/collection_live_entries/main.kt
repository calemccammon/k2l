// The entries of a map's `entries` are live, like the JVM's nodes: they see a later put of their key, setValue writes
// through while the map holds them, and a removed key's entry keeps its last value. firstEntry() and the like are copies.
import java.util.TreeMap

fun t(label: String, f: () -> Any?) {
    try {
        println("$label: ${f()}")
    } catch (e: Throwable) {
        println("$label: ${e::class.simpleName} ${e.message}")
    }
}

class Lru(private val capacity: Int) : LinkedHashMap<String, Int>(4, 0.75f, true) {
    var eldestSeen: Map.Entry<String, Int>? = null

    override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Int>): Boolean {
        eldestSeen = eldest
        return size > capacity
    }
}

fun maps(): List<Pair<String, MutableMap<Int, String>>> = listOf(
    "HashMap" to HashMap(mapOf(1 to "a", 2 to "b", 3 to "c")),
    "LinkedHashMap" to linkedMapOf(1 to "a", 2 to "b", 3 to "c"),
    "TreeMap" to TreeMap(mapOf(1 to "a", 2 to "b", 3 to "c")),
    "mutableMapOf" to mutableMapOf(1 to "a", 2 to "b", 3 to "c"),
)

fun main() {
    for ((name, m) in maps()) {
        val first = m.entries.first()
        val all = m.entries.toList()
        m[1] = "z"
        m.put(2, "y")
        m.compute(3) { _, v -> v + "!" }
        println("$name: $first ${first.value} $all ${first === m.entries.first()} ${first.javaClass.name}")
        first.setValue("w")
        println("$name setValue: $m ${m[1]}")
        // a removed key's entry keeps its last value and no longer writes to the map
        m.remove(1)
        m[1] = "n"
        println("$name removed: ${first.value} ${first.setValue("q")} $first $m")
        // removing other keys leaves the remaining entries live (a TreeMap's remove of a key with two children moves
        // the next key into its node on the JVM, see the README: here a leaf is removed)
        val third = m.entries.first { it.key == 3 }
        m.remove(1)
        m[3] = "three"
        m.merge(3, "+") { a, b -> a + b }
        println("$name after remove: $third ${m.entries}")
        m.replaceAll { k, v -> "$v$k" }
        m.putIfAbsent(3, "ignored")
        m.computeIfPresent(3) { _, v -> v.uppercase() }
        println("$name replaceAll: $third $m")
        m.clear()
        m[3] = "fresh"
        println("$name cleared: $third ${m.entries.first()}")
    }

    // entries held across many insertions (a HashMap reorders and grows, a TreeMap inserts before them)
    val hm = HashMap<Int, String>()
    hm[1] = "a"
    val e1 = hm.entries.first()
    for (i in 2..40) hm[i * 16] = "x$i"
    hm[1] = "y"
    println("grown: $e1 ${hm.entries.first { it.key == 1 } === e1}")
    val tm = TreeMap<Int, String>()
    tm[50] = "fifty"
    val e50 = tm.entries.first()
    for (i in 1..20) tm[i] = "v$i"
    tm[50] = "FIFTY"
    println("tree: $e50 ${tm.lastEntry()} ${tm.entries.last() === e50}")

    // entries from a loop, and destructured
    val scores = linkedMapOf("ann" to 1, "bob" to 2)
    val seen = mutableListOf<Map.Entry<String, Int>>()
    for (e in scores.entries) seen += e
    for (e in scores) seen += e
    scores["ann"] = 10
    scores["bob"] = 20
    println("loops: $seen")
    val it = scores.entries.iterator()
    val head = it.next()
    scores["ann"] = 100
    println("iterator: $head")
    for ((k, v) in scores.entries) print("$k=$v ")
    println()

    // a LinkedHashMap in access order moves the entry along with its key
    val lru = Lru(2)
    lru["a"] = 1
    lru["b"] = 2
    val a = lru.entries.first()
    lru["a"]
    lru["a"] = 5
    println("lru: $a $lru ${lru.eldestSeen}")
    lru["c"] = 3
    println("lru evicted: $lru ${lru.eldestSeen} ${lru.eldestSeen?.value}")
    lru["a"] = 6
    println("lru eldest live: ${lru.eldestSeen}")

    // buildMap's entries see the builder's later puts
    var built: Map.Entry<Int, String>? = null
    val b = buildMap {
        put(1, "a")
        built = entries.first()
        put(1, "b")
    }
    println("buildMap: $built $b")
    t("built setValue") { (b.entries.first() as MutableMap.MutableEntry<Int, String>).setValue("c") }

    // TreeMap's firstEntry(), floorEntry() and pollFirstEntry() are copies that cannot be set
    val nav = TreeMap(mapOf(1 to "a", 2 to "b", 3 to "c"))
    val fe = nav.firstEntry()
    val fl = nav.floorEntry(2)
    nav[1] = "z"
    nav[2] = "y"
    println("copies: $fe $fl ${fe.javaClass.name} ${nav.entries.first().javaClass.name}")
    t("firstEntry setValue") { (nav.firstEntry() as MutableMap.MutableEntry<Int, String>).setValue("q") }
    t("pollFirstEntry") { val p = nav.pollFirstEntry(); "$p ${p.javaClass.name} $nav" }
    t("lastEntry equals") { nav.lastEntry() == nav.entries.last() }

    // entries as keys and in sets compare by key and value
    val counts = HashMap(mapOf("x" to 1))
    val ex = counts.entries.first()
    val set = hashSetOf<Map.Entry<String, Int>>(ex)
    counts["x"] = 2
    println("hash: ${ex.hashCode() == ("x".hashCode() xor 2)} ${counts.entries.contains(ex)} ${set.size}")
    // a descending map's entries are the map's
    val dm = TreeMap(mapOf(1 to "a", 2 to "b")).let { it to it.descendingMap() }
    val de = dm.second.entries.first()
    dm.first[2] = "z"
    de.setValue("w")
    println("descending: $de ${dm.first}")
}
