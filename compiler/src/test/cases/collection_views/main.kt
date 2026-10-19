// Collection views and classes as on the JVM: subList and asList are live views, read-only collections are not mutable ones
// (`is`/`as MutableList`), and map views, iterators and arrays report the JVM's classes.
fun t(name: String, f: () -> Any?) {
    val r = try {
        f()
    } catch (e: Exception) {
        e.javaClass.name + ": " + e.message
    }
    println("$name -> $r")
}

class Logged : ArrayList<Int>() {
    val log = mutableListOf<String>()

    override fun add(index: Int, element: Int) {
        log += "add($index)"
        super.add(index, element)
    }

    override fun removeAt(index: Int): Int {
        log += "removeAt($index)"
        return super.removeAt(index)
    }

    override fun set(index: Int, element: Int): Int {
        log += "set($index)"
        return super.set(index, element)
    }
}

class Fixed(private val items: List<String>) : List<String> by items

class Growing(private val items: MutableList<String>) : MutableList<String> by items

fun subLists() {
    val list = mutableListOf(1, 2, 3, 4, 5)
    val sub = list.subList(1, 4)
    t("sub") { sub }
    sub[0] = 20
    t("write through") { list }
    list[2] = 30
    t("read through") { sub }
    sub.add(99)
    t("add") { "$list $sub ${sub.size}" }
    sub.removeAt(0)
    t("removeAt") { "$list $sub" }
    sub.clear()
    t("clear") { "$list $sub ${sub.isEmpty()}" }
    sub.addAll(listOf(7, 8))
    t("addAll") { "$list $sub" }
    val subsub = sub.subList(1, 2)
    subsub.add(100)
    t("subsub") { "$list $sub $subsub" }
    t("sum") { sub.sum() }
    t("eq") { sub == listOf(7, 100, 8) }
    sub.sort()
    t("sort") { list }
    sub.removeAll { it > 50 }
    t("removeAll") { "$list $sub" }
    t("get out") { sub[5] }
    t("bounds") { list.subList(2, 1) }
    t("bounds2") { list.subList(0, 10) }
    var s = 0
    for (x in sub) s += x
    t("loop") { s }
    val l2 = mutableListOf(5, 6, 7, 8, 9)
    l2.subList(1, 3).clear()
    t("remove range") { l2 }
    val ro = listOf(1, 2, 3, 4)
    val rosub = ro.subList(1, 3)
    t("ro sub") { "$rosub ${rosub.javaClass.name} ${list.subList(0, 1).javaClass.name} ${emptyList<Int>().subList(0, 0)}" }
    t("ro add") { (rosub as MutableList<Int>).add(5) }
    t("ro set") {
        (rosub as MutableList<Int>)[0] = 9
        ro
    }
    val lg = Logged()
    lg.addAll(listOf(1, 2, 3, 4))
    val lsub = lg.subList(1, 3)
    lsub.add(9)
    lsub.removeAt(0)
    lsub[0] = 5
    lsub.add(0, 6)
    t("logged") { "$lg ${lg.log}" }
}

fun arrayViews() {
    val arr = arrayOf(1, 2, 3)
    val view = arr.asList()
    arr[0] = 10
    t("asList read") { view }
    (view as MutableList<Int>)[1] = 20
    t("asList write") { arr.toList() }
    t("asList add") { (view as MutableList<Int>).add(4) }
    t("asList class") { view.javaClass.name }
    t("asList eq") { view == listOf(10, 20, 3) }
    t("asList sub") { view.subList(0, 2) }
    (view as MutableList<Int>).sortDescending()
    t("asList sort") { arr.toList() }
    var vs = 0
    for (x in view) vs += x
    t("asList loop") { "$vs ${view.indexOf(3)} ${view.map { it + 1 }}" }
    val ints = intArrayOf(3, 1, 2)
    val iview = ints.asList()
    ints[0] = 30
    t("int view") { "$iview ${iview.size} ${iview[0]} ${iview.sum()} ${iview is MutableList<*>} ${iview.javaClass.name}" }
    t("int view cast") { iview as MutableList<Int> }
    t("int view get") { iview[5] }
    t("chars view") { charArrayOf('a', 'b').asList().javaClass.name }
}

fun readOnly() {
    t("emptyList as") { emptyList<Int>() as MutableList<Int> }
    t("emptySet as") { emptySet<Int>() as MutableSet<Int> }
    t("emptyMap as") { emptyMap<Int, Int>() as MutableMap<Int, Int> }
    t("listOf() as") { listOf<String>() as MutableList<String> }
    t("emptyList is") { (emptyList<Int>() as Any) is MutableList<*> }
    t("emptyList is List") { (emptyList<Int>() as Any) is List<*> }
    t("empty filter is") { (listOf(1).filter { it > 5 } as Any) is MutableCollection<*> }
    t("emptyMap keys is") { (emptyMap<Int, Int>().keys as Any) is MutableSet<*> }
    t("range is") { "${((1..3) as Any) is MutableIterable<*>} ${((1..3) as Any) is Iterable<*>}" }
    t("listOf2 as") {
        val m = listOf(1, 2) as MutableList<Int>
        m[0] = 5
        "$m ${(m as Any) is MutableList<*>}"
    }
    t("listOf1 set") { (listOf(1) as MutableList<Int>).set(0, 2) }
    t("setOf1 add") { (setOf(1) as MutableSet<Int>).add(2) }
    t("string as") { ("x" as Any) as MutableList<*> }
    val fixed = Fixed(listOf("a"))
    t("delegating is") { "${(fixed as Any) is List<*>} ${(fixed as Any) is MutableList<*>} ${(Growing(mutableListOf()) as Any) is MutableList<*>}" }
    t("delegating as") { (fixed as Any) as MutableList<*> }
    t("keys add") { mutableMapOf(1 to 2).keys.add(3) }
    t("values add") { mutableMapOf(1 to 2).values.add(3) }
    val m = mutableMapOf("a" to 1, "b" to 2)
    m.keys.remove("a")
    m.values.remove(2)
    t("views remove") { m }
}

fun classNames() {
    val linked = linkedMapOf(1 to 2)
    val hashed = hashMapOf(1 to 2)
    val sorted = sortedMapOf(1 to 2)
    for ((name, map) in listOf("linked" to linked, "hashed" to hashed, "sorted" to sorted, "single" to mapOf(1 to 2))) {
        println("$name ${map.keys.javaClass.name} ${map.values.javaClass.name} ${map.entries.javaClass.name}")
        println("$name ${map.entries.first().javaClass.name} ${map.keys.iterator().javaClass.name} ${map.iterator().javaClass.name}")
    }
    println("empty ${emptyMap<Int, Int>().keys.javaClass.name} ${emptyMap<Int, Int>().values.javaClass.name}")
    val iterators = listOf(
        mutableListOf(1).iterator(), listOf(1, 2).iterator(), listOf(1).iterator(), emptyList<Int>().iterator(),
        mutableSetOf(1).iterator(), hashSetOf(1).iterator(), sortedSetOf(1).iterator(), (1..2).iterator(),
        arrayOf(1).iterator(), java.util.PriorityQueue(listOf(1)).iterator(), ArrayDeque(listOf(1)).iterator(),
    )
    println(iterators.map { it.javaClass.name })
    val ints = intArrayOf(1)
    val strings = arrayOf("a")
    val nested = arrayOf(intArrayOf(1))
    val objects = arrayOfNulls<Any>(1)
    println("${ints::class.simpleName} ${ints::class.qualifiedName} ${ints.javaClass.name} ${ints.javaClass.simpleName} ${ints::class}")
    println("${strings::class.simpleName} ${strings.javaClass.name} ${strings.javaClass.simpleName} ${strings.javaClass}")
    println("${nested.javaClass.name} ${nested.javaClass.simpleName} ${objects.javaClass.name} ${doubleArrayOf(1.0).javaClass.name}")
    println("${ints::class == IntArray(2)::class} ${strings::class == arrayOf(1)::class} ${listOf("a").toTypedArray().javaClass.name}")
    println("${booleanArrayOf().javaClass.name} ${longArrayOf().javaClass.name} ${charArrayOf().javaClass.name} ${arrayOf(listOf(1)).javaClass.name}")
}

fun main() {
    subLists()
    arrayViews()
    readOnly()
    classNames()
}
