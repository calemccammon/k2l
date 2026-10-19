fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: Exception) {
        println("$label: ${e::class.simpleName}: ${e.message}")
    }
}

fun defaults() {
    println("-- withDefault")
    val base = mapOf("a" to 1, "b" to 2)
    val m = base.withDefault { it.length * 10 }
    println(m.getValue("a"))
    println(m.getValue("missing"))
    println(m["missing"])
    println(m.get("a"))
    println(m.getOrDefault("zz", -1))
    println(m.size)
    println(m)
    println(m.containsKey("missing"))
    println(m.keys)
    println(m == base)
    for ((k, v) in m) println("$k=$v")
    println(base.getValue("a"))
    attempt("noDefault") { base.getValue("zz") }
    val counts = mutableMapOf<String, Int>().withDefault { 0 }
    for (w in "a b a c b a".split(" ")) counts[w] = counts.getValue(w) + 1
    println(counts)
    println(counts.getValue("nothing"))
    println(counts.size)
    val lists = mutableMapOf<Int, List<String>>().withDefault { emptyList() }
    lists[1] = listOf("x")
    println(lists.getValue(1))
    println(lists.getValue(2))
    println(lists.map { it.key }.sorted())
    val sorted = sortedMapOf("z" to 1, "y" to 2).withDefault { 99 }
    println(sorted.getValue("q"))
    println(sorted.keys)
}

fun iterators() {
    println("-- listIterator")
    val list = mutableListOf(1, 2, 3, 4, 5)
    val it = list.listIterator()
    println("${it.hasPrevious()} ${it.nextIndex()} ${it.previousIndex()}")
    while (it.hasNext()) {
        val idx = it.nextIndex()
        val v = it.next()
        if (v % 2 == 0) it.set(v * 10)
        if (v == 3) it.add(33)
        if (v == 5) it.remove()
        println("$idx $v -> $list")
    }
    while (it.hasPrevious()) print("${it.previous()} ")
    println()
    println(list)
    val mid = list.listIterator(2)
    println("${mid.nextIndex()} ${mid.next()} ${mid.previous()} ${mid.previous()}")
    val end = list.listIterator(list.size)
    println(end.hasNext())
    println(end.previous())
    attempt("empty") { mutableListOf<Int>().listIterator().next() }
    attempt("noPrev") { list.listIterator().previous() }
    attempt("badIndex") { list.listIterator(99) }
    attempt("removeFirst") { list.listIterator().remove() }
    attempt("setFirst") { list.listIterator().set(1) }
    val again = list.listIterator()
    again.next()
    again.remove()
    attempt("removeTwice") { again.remove() }
    println(list)
    val words = mutableListOf("a", "b", "c")
    val wi = words.listIterator()
    while (wi.hasNext()) {
        val w = wi.next()
        wi.set(w.uppercase())
        wi.add(w)
    }
    println(words)
    val ro = listOf(1, 2, 3).listIterator()
    var sum = 0
    while (ro.hasNext()) sum += ro.next()
    println(sum)
}

fun main() {
    defaults()
    iterators()
}
