// The JVM classes of the lists, sets and maps the factories and operations return, their index messages and their
// read-only behavior.

fun show(label: String, x: Any) {
    println("$label: ${x::class.simpleName} ${x::class.qualifiedName} ${x.javaClass.name} ${x.javaClass.simpleName} $x")
}

fun tryIt(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Throwable) {
        println("$label threw ${e::class.qualifiedName} ${e.javaClass.name}: ${e.message}")
    }
}

fun factories() {
    show("listOf()", listOf<Int>())
    show("emptyList", emptyList<Int>())
    show("listOf(1)", listOf(1))
    show("listOf(1,2)", listOf(1, 2))
    val arr = arrayOf(1)
    show("listOf(*arr)", listOf(*arr))
    show("asList", arrayOf(1, 2).asList())
    show("mutableListOf", mutableListOf(1))
    show("arrayListOf", arrayListOf(1))
    show("listOfNotNull(1)", listOfNotNull(1))
    show("listOfNotNull(null)", listOfNotNull<Int>(null))
    show("listOfNotNull(1,null)", listOfNotNull(1, null))
    show("setOf()", setOf<Int>())
    show("emptySet", emptySet<Int>())
    show("setOf(1)", setOf(1))
    show("setOf(*arr)", setOf(*arr))
    show("setOf(1,1)", setOf(1, 1))
    show("setOf(1,2)", setOf(1, 2))
    show("mutableSetOf", mutableSetOf(1))
    show("mapOf()", mapOf<Int, Int>())
    show("emptyMap", emptyMap<Int, Int>())
    show("mapOf(1)", mapOf(1 to 2))
    val pairs = arrayOf(1 to 2)
    show("mapOf(*pairs)", mapOf(*pairs))
    show("mapOf(2)", mapOf(1 to 2, 3 to 4))
    show("mutableMapOf", mutableMapOf(1 to 2))
    show("Collections.emptyList", java.util.Collections.emptyList<Int>())
    show("Collections.singletonList", java.util.Collections.singletonList(1))
    show("Collections.singleton", java.util.Collections.singleton(1))
    show("Collections.emptySet", java.util.Collections.emptySet<Int>())
    show("Collections.emptyMap", java.util.Collections.emptyMap<Int, Int>())
    show("Collections.singletonMap", java.util.Collections.singletonMap(1, 2))
    show("Collections.nCopies", java.util.Collections.nCopies(2, 0))
}

fun operations() {
    val xs = listOf(1, 2, 3)
    show("toList0", xs.filter { it > 5 }.toList())
    show("toList1", xs.filter { it > 2 }.toList())
    show("toList2", xs.filter { it > 1 }.toList())
    show("toMutableList", listOf(1).toMutableList())
    show("toSet0", xs.filter { it > 5 }.toSet())
    show("toSet1", listOf(1).toSet())
    show("toSet2", xs.toSet())
    show("toMutableSet", listOf(1).toMutableSet())
    show("toMap1", listOf(1 to 2).toMap())
    show("toMap2", listOf(1 to 2, 1 to 3).toMap())
    show("map.toMap", mapOf(1 to 2, 2 to 3).filter { it.key == 1 }.toMap())
    show("map.toList", mapOf(1 to 2).toList())
    show("sorted", listOf(2, 1).sorted())
    show("sorted1", listOf(2).sorted())
    show("sortedWith", xs.sortedWith(compareBy { -it }))
    show("sortedBy", xs.sortedBy { -it })
    show("sortedDescending", xs.sortedDescending())
    show("array.sorted", arrayOf(1).sorted())
    show("filter", xs.filter { true })
    show("map", xs.map { it })
    show("take1", xs.take(1))
    show("take5", xs.take(5))
    show("take0", xs.take(0))
    show("drop2", xs.drop(2))
    show("drop1", xs.drop(1))
    show("takeLast1", xs.takeLast(1))
    show("dropLast2", xs.dropLast(2))
    show("distinct1", listOf(1, 1).distinct())
    show("distinct2", listOf(1, 2).distinct())
    show("reversed1", listOf(1).reversed())
    show("reversed2", listOf(1, 2).reversed())
    show("plus", listOf(1) + 2)
    show("union", setOf(1) union setOf(1))
    show("set plus", setOf(1) + 1)
    show("map plus", mapOf(1 to 2) + (1 to 3))
}

fun indexes() {
    tryIt("listOf()[0]") { listOf<Int>()[0] }
    tryIt("listOf(1)[1]") { listOf(1)[1] }
    tryIt("listOf(1)[-1]") { listOf(1)[-1] }
    tryIt("listOf(1,2)[2]") { listOf(1, 2)[2] }
    tryIt("listOf(1,2)[-1]") { listOf(1, 2)[-1] }
    tryIt("arr[2]") { arrayOf(1, 2)[2] }
    tryIt("intarr[2]") { intArrayOf(1, 2)[2] }
    tryIt("arr set") {
        val a = arrayOf(1)
        a[3] = 4
    }
    tryIt("mutable[2]") { mutableListOf(1, 2)[2] }
    tryIt("mutable[-1]") { mutableListOf(1, 2)[-1] }
    tryIt("asList.get") { arrayOf(1).asList()[3] }
    tryIt("sorted get") { listOf(2, 1).sorted()[2] }
    tryIt("Collections.emptyList get") { java.util.Collections.emptyList<Int>()[0] }
    tryIt("nCopies get") { java.util.Collections.nCopies(2, 0)[5] }
    tryIt("singletonList get") { java.util.Collections.singletonList(0)[5] }
    tryIt("elementAt listOf(1)") { listOf(1).elementAt(4) }
    tryIt("elementAt listOf(1, 2)") { listOf(1, 2).elementAt(4) }
    tryIt("elementAt emptyList") { emptyList<Int>().elementAt(4) }
    tryIt("elementAt mutable") { mutableListOf(1, 2).elementAt(5) }
    tryIt("elementAt via Iterable") { (listOf(1, 2) as Iterable<Int>).elementAt(5) }
    tryIt("elementAt set") { setOf(1, 2).elementAt(4) }
    tryIt("elementAt set -1") { setOf(1, 2).elementAt(-1) }
    tryIt("catch IndexOutOfBounds") {
        try {
            listOf(1)[3]
        } catch (e: IndexOutOfBoundsException) {
            "caught ${e.message}"
        }
    }
    tryIt("catch for an array") {
        try {
            arrayOf(1)[3]
        } catch (e: IndexOutOfBoundsException) {
            "caught ${e::class.simpleName} ${e.message}"
        }
    }
    tryIt("catch ArrayIndexOutOfBounds") {
        try {
            listOf(1, 2)[3]
        } catch (e: ArrayIndexOutOfBoundsException) {
            "caught ${e.message}"
        }
    }
    tryIt("not caught as ArrayIndexOutOfBounds") {
        try {
            mutableListOf(1)[3]
        } catch (e: ArrayIndexOutOfBoundsException) {
            "wrong"
        } catch (e: IndexOutOfBoundsException) {
            "caught ${e::class.simpleName}"
        }
    }
    tryIt("is") { listOf(1, 2).getOrNull(5) == null && IndexOutOfBoundsException() !is ArrayIndexOutOfBoundsException }
}

fun mutation() {
    tryIt("removeFirst") { mutableListOf<Int>().removeFirst() }
    tryIt("removeLast") { mutableListOf<Int>().removeLast() }
    tryIt("ArrayList removeFirst") { ArrayList<Int>().removeFirst() }
    tryIt("removeFirstOrNull") { mutableListOf<Int>().removeFirstOrNull() }
    tryIt("first") { mutableListOf<Int>().first() }
    tryIt("add listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).add(3) }
    tryIt("set listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).set(0, 5) }
    tryIt("set listOf(1,2) bad") { (listOf(1, 2) as MutableList<Int>).set(5, 1) }
    tryIt("sort listOf(3,1,2)") {
        val l = listOf(3, 1, 2)
        (l as MutableList<Int>).sort()
        l
    }
    tryIt("remove listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).remove(1) }
    tryIt("remove absent listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).remove(5) }
    tryIt("removeAt listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).removeAt(0) }
    tryIt("clear listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).clear() }
    tryIt("addAll empty listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).addAll(emptyList()) }
    tryIt("removeFirst listOf(1,2)") { (listOf(1, 2) as MutableList<Int>).removeFirst() }
    tryIt("add listOf(1)") { (listOf(1) as MutableList<Int>).add(3) }
    tryIt("set listOf(1)") { (listOf(1) as MutableList<Int>).set(0, 3) }
    tryIt("remove listOf(1)") { (listOf(1) as MutableList<Int>).remove(1) }
    tryIt("remove absent listOf(1)") { (listOf(1) as MutableList<Int>).remove(2) }
    tryIt("clear listOf(1)") { (listOf(1) as MutableList<Int>).clear() }
    tryIt("removeAt listOf(1)") { (listOf(1) as MutableList<Int>).removeAt(0) }
    tryIt("sort listOf(1)") {
        (listOf(1) as MutableList<Int>).sort()
        "ok"
    }
    tryIt("add sorted") { (listOf(2, 1).sorted() as MutableList<Int>).add(3) }
    tryIt("add setOf(1)") { (setOf(1) as MutableSet<Int>).add(3) }
    tryIt("remove setOf(1)") { (setOf(1) as MutableSet<Int>).remove(1) }
    tryIt("clear setOf(1)") { (setOf(1) as MutableSet<Int>).clear() }
    tryIt("add setOf(1,2)") { (setOf(1, 2) as MutableSet<Int>).add(3) }
    tryIt("put mapOf(1)") { (mapOf(1 to 2) as MutableMap<Int, Int>).put(3, 3) }
    tryIt("remove mapOf(1)") { (mapOf(1 to 2) as MutableMap<Int, Int>).remove(1) }
    tryIt("clear mapOf(1)") { (mapOf(1 to 2) as MutableMap<Int, Int>).clear() }
    tryIt("Collections.emptyList add") { java.util.Collections.emptyList<Int>().add(1) }
    tryIt("toMutableList of listOf(1)") { listOf(1).toMutableList().apply { add(2) } }
    tryIt("ArrayList(listOf(1))") { ArrayList(listOf(1)).apply { add(2) } }
    tryIt("LinkedHashSet(setOf(1))") { LinkedHashSet(setOf(1)).apply { add(2) } }
    tryIt("LinkedHashMap(mapOf(1))") { LinkedHashMap(mapOf(1 to 2)).apply { put(3, 4) } }
    tryIt("toMutableMap of mapOf(1)") { mapOf(1 to 2).toMutableMap().apply { put(3, 4) } }
}

fun equality() {
    tryIt("eq") { listOf(1) == mutableListOf(1) && setOf(1) == mutableSetOf(1) && mapOf(1 to 2) == mutableMapOf(1 to 2) }
    tryIt("eq empty") { emptyList<Int>() == mutableListOf<Int>() && emptySet<Int>() == mutableSetOf<Int>() && emptyMap<Int, Int>() == mutableMapOf<Int, Int>() }
    tryIt("hash") { listOf(1, 2).hashCode() + setOf(1).hashCode() + mapOf(1 to 2).hashCode() + emptyList<Int>().hashCode() }
    tryIt("same empty") { emptyList<Int>() === listOf<String>() && emptySet<Int>() === setOf<String>() && emptyMap<Int, Int>() === mapOf<String, Int>() }
    tryIt("toString") { emptyList<Int>().toString() + emptySet<Int>() + emptyMap<Int, Int>() + listOf(1) + setOf(1) + mapOf(1 to 2) }
    tryIt("class equality") { listOf(1)::class == java.util.Collections.singletonList(2)::class }
    tryIt("contains") { 1 in listOf(1) && 2 in listOf(1, 2) && 1 in setOf(1) && 1 in mapOf(1 to 2) }
    val single = listOf(5)
    var total = 0
    for (x in single) total += x
    for (x in emptyList<Int>()) total += x
    for (x in setOf(7)) total += x
    for ((k, v) in mapOf(1 to 2)) total += k + v
    println("loops $total ${single.map { it * 2 }} ${setOf(3).map { it }} ${mapOf(1 to 2).map { it.value }}")
}

fun main() {
    factories()
    operations()
    indexes()
    mutation()
    equality()
}
