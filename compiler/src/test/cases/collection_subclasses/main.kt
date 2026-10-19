// Classes extending the library's abstract collections: every inherited operation is built on the members they implement.

class Tens(private val n: Int) : AbstractList<Int>() {
    var reads = 0

    override val size: Int get() = n

    override fun get(index: Int): Int {
        if (index < 0 || index >= n) throw IndexOutOfBoundsException("index $index of $n")
        reads++
        return index * 10
    }
}

class Fixed(override val size: Int) : AbstractList<String>() {
    override fun get(index: Int): String = "s$index"
}

/** A mutable list over an ArrayList that logs the calls the inherited operations make. */
class Logged : AbstractMutableList<Int>() {
    private val items = ArrayList<Int>()
    val log = mutableListOf<String>()

    override val size: Int get() = items.size

    override fun get(index: Int): Int = items[index]

    override fun set(index: Int, element: Int): Int {
        log += "set($index, $element)"
        return items.set(index, element)
    }

    override fun add(index: Int, element: Int) {
        log += "add($index, $element)"
        items.add(index, element)
    }

    override fun removeAt(index: Int): Int {
        log += "removeAt($index)"
        return items.removeAt(index)
    }

    fun drain(): String = log.joinToString(" ").also { log.clear() }
}

fun readOnlyList() {
    val t = Tens(5)
    println("$t size=${t.size} [2]=${t[2]} get=${t.get(4)} (${t.reads})")
    println("contains ${30 in t} ${35 in t} indexOf ${t.indexOf(20)} ${t.lastIndexOf(40)} ${t.indexOf(7)} (${t.reads})")
    println("first ${t.first()} last ${t.last()} getOrNull ${t.getOrNull(9)} ${t.getOrNull(1)} isEmpty ${t.isEmpty()} (${t.reads})")
    println("map ${t.map { it + 1 }} filter ${t.filter { it > 15 }} sum ${t.sum()} reversed ${t.reversed()} (${t.reads})")
    println("join ${t.joinToString("-")} sortedDesc ${t.sortedDescending()} take ${t.take(2)} drop ${t.drop(3)} (${t.reads})")
    println("subList ${t.subList(1, 3)} slice ${t.slice(listOf(0, 4))} chunked ${t.chunked(2)} (${t.reads})")
    println("equals ${t == listOf(0, 10, 20, 30, 40)} ${listOf(0, 10, 20, 30, 40) == t} ${t == Tens(5)} ${t == Tens(4)} (${t.reads})")
    println("hashCode ${t.hashCode() == listOf(0, 10, 20, 30, 40).hashCode()} (${t.reads})")
    var total = 0
    for (x in t) total += x
    for (i in t.indices) total += t[i]
    t.forEach { total += it }
    println("loops $total (${t.reads})")
    val it = t.iterator()
    println("iterator ${it.next()} ${it.next()} ${it.hasNext()} (${t.reads})")
    val li = t.listIterator(4)
    println("listIterator ${li.previous()} ${li.previousIndex()} (${t.reads})")
    println("is ${(t as Any) is List<*>} ${(t as Any) is Collection<*>} ${(t as Any) is Set<*>} ${t::class.simpleName} (${t.reads})")
    try {
        t[7]
    } catch (e: IndexOutOfBoundsException) {
        println("caught ${e.message}")
    }
    val list: List<Int> = Tens(3)
    println("as List: $list ${list.size} ${list.max()} ${list.toSet()} ${list.withIndex().map { (i, v) -> i + v }} (${t.reads})")
    println("Fixed ${Fixed(3)} ${Fixed(2).map { it.length }} ${Fixed(0)} (${t.reads})")
    println("reads ${t.reads}")
}

fun mutableList() {
    val l = Logged()
    l.add(1)
    l.add(3)
    l.add(1, 2)
    println("$l ${l.drain()}")
    l.addAll(listOf(4, 5))
    println("addAll $l ${l.drain()}")
    l.addAll(0, listOf(-1, 0))
    println("addAll(0) $l ${l.drain()}")
    l[0] = -2
    l += 6
    println("set and += $l ${l.drain()}")
    l.remove(3)
    println("remove $l ${l.drain()}")
    l.removeAll { it % 2 == 0 }
    println("removeAll $l ${l.drain()}")
    l.addAll(listOf(9, 7, 8))
    l.drain()
    l.sort()
    println("sort $l ${l.drain()}")
    l.removeFirst()
    l.removeLast()
    println("removeFirst/Last $l ${l.drain()}")
    val iterator = l.iterator()
    iterator.next()
    iterator.remove()
    println("iterator remove $l ${l.drain()}")
    l.retainAll(listOf(7, 8))
    println("retainAll $l ${l.drain()}")
    l.addAll(listOf(1, 2))
    l.drain()
    l.clear()
    println("clear $l ${l.drain()} ${l.isEmpty()}")
}

fun main() {
    readOnlyList()
    mutableList()
}
