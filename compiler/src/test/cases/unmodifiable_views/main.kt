import java.util.Collections

fun attempt(label: String, block: () -> Unit) {
    try {
        block()
        println("$label: ok")
    } catch (e: UnsupportedOperationException) {
        println("$label: UnsupportedOperationException")
    }
}

fun total(xs: List<Int>): Int {
    var sum = 0
    for (x in xs) sum += x
    return sum
}

fun main() {
    val backing = mutableListOf(1, 2, 3)
    val view = Collections.unmodifiableList(backing)
    println("$view ${view.size} ${view[0]} ${view.isEmpty()}")
    backing.add(4)
    backing[0] = 10
    println("$view ${view.size} ${view[0]} ${view.last()} ${view.contains(4)}")
    backing.removeAt(1)
    println("$view ${view.size}")

    // loops and lambdas over the view see the current elements
    val seen = mutableListOf<Int>()
    for (x in view) seen.add(x)
    view.forEach { seen.add(it * 100) }
    view.forEachIndexed { i, x -> seen.add(i * 1000 + x) }
    println(seen)
    println(total(view))
    println(view.map { it + 1 })
    println(view.filter { it > 3 })
    println(view.any { it > 9 })
    println(view.sumOf { it })
    println(view.indices)
    println(view.withIndex().map { (i, x) -> i * x })
    println(view.sorted())
    println(view.joinToString("-"))
    println(view.sum())
    val firstBig = view.first { it > 3 }
    println(firstBig)
    for ((i, x) in view.withIndex()) print("$i=$x ")
    println()
    for (i in view.indices) print(view[i])
    println()

    // equality, hashing and copies
    println(view == backing)
    println(view == listOf(10, 3, 4))
    println(view.hashCode() == backing.hashCode())
    val copy = view.toMutableList()
    backing.add(5)
    println("$copy $view")
    println(view.subList(0, 2))

    // writes throw, also through the iterator
    attempt("add") { (view as MutableList<Int>).add(1) }
    attempt("set") { (view as MutableList<Int>)[0] = 1 }
    attempt("removeAt") { (view as MutableList<Int>).removeAt(0) }
    attempt("clear") { (view as MutableList<Int>).clear() }
    attempt("sort") { Collections.sort(view as MutableList<Int>) }
    attempt("iterator") {
        val it = (view as MutableList<Int>).iterator()
        it.next()
        it.remove()
    }
    println(view)

    // a view of a view and of a list that is replaced elementwise
    val outer = Collections.unmodifiableList(view)
    backing.clear()
    println("${outer.size} $outer")
    backing.addAll(listOf(7, 8))
    println("${outer.size} $outer")

    // nullable elements
    val nullable = mutableListOf<String?>("a", null)
    val nullView = Collections.unmodifiableList(nullable)
    nullable.add("c")
    var count = 0
    for (s in nullView) if (s == null) count++
    println("$nullView $count")

    // sets
    val s = mutableSetOf(3, 1, 2)
    val sv = Collections.unmodifiableSet(s)
    s.add(9)
    s.remove(1)
    println("$sv ${sv.size} ${9 in sv} ${1 in sv}")
    for (x in sv) print(x)
    println()
    attempt("setAdd") { (sv as MutableSet<Int>).add(5) }
    attempt("setRemove") { (sv as MutableSet<Int>).remove(3) }
    attempt("setClear") { (sv as MutableSet<Int>).clear() }
    println(sv.map { it * 2 })

    // maps
    val m = mutableMapOf("a" to 1, "b" to 2)
    val mv = Collections.unmodifiableMap(m)
    m["c"] = 3
    m.remove("a")
    println("$mv ${mv.size} ${mv["c"]} ${mv.containsKey("a")} ${mv.keys} ${mv.values}")
    for ((k, v) in mv) print("$k$v ")
    println()
    println(mv.entries.map { it.key + it.value })
    attempt("put") { (mv as MutableMap<String, Int>)["z"] = 0 }
    attempt("mapRemove") { (mv as MutableMap<String, Int>).remove("b") }
    attempt("mapClear") { (mv as MutableMap<String, Int>).clear() }
    val hm = HashMap<String, Int>()
    val hv = Collections.unmodifiableMap(hm)
    hm["zebra"] = 1
    hm["apple"] = 2
    hm["mango"] = 3
    println(hv)
    println(hv.keys.toList())

    // collection views
    val c = Collections.unmodifiableCollection(backing)
    backing.add(1)
    println("${c.size} $c")
    val cs = Collections.unmodifiableCollection(s)
    s.add(77)
    println("${cs.size} ${77 in cs}")
}
