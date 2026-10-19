// Collection interfaces implemented (or delegated) next to a base class that is not a collection: the class gets the
// library's collection operations while keeping its base's members.
open class Named(val name: String) {
    open fun describe() = "named $name"
}

class Mixed : Named("mixed"), Iterable<Int> {
    override fun iterator(): Iterator<Int> = listOf(3, 1, 2).iterator()
}

class Wrapped : Exception("wrapped"), Collection<Int> {
    override val size: Int get() = 2

    override fun isEmpty() = false

    override fun contains(element: Int) = element == 4 || element == 5

    override fun containsAll(elements: Collection<Int>) = elements.all { contains(it) }

    override fun iterator(): Iterator<Int> = listOf(4, 5).iterator()
}

class Row(name: String, private val cells: List<String>) : Named(name), List<String> by cells {
    override fun describe() = "row $name of $size"
}

class Scores(private val values: IntArray) : Named("scores"), List<Int> {
    override val size: Int get() = values.size

    override fun get(index: Int) = values[index]

    override fun isEmpty() = values.isEmpty()

    override fun contains(element: Int) = element in values

    override fun containsAll(elements: Collection<Int>) = elements.all { it in values }

    override fun indexOf(element: Int) = values.indexOf(element)

    override fun lastIndexOf(element: Int) = values.lastIndexOf(element)

    override fun iterator(): Iterator<Int> = values.iterator()

    override fun listIterator(): ListIterator<Int> = values.toList().listIterator()

    override fun listIterator(index: Int): ListIterator<Int> = values.toList().listIterator(index)

    override fun subList(fromIndex: Int, toIndex: Int): List<Int> = values.toList().subList(fromIndex, toIndex)
}

class Settings(private val backing: MutableMap<String, String>) : Named("settings"), MutableMap<String, String> by backing

fun main() {
    val m = Mixed()
    println("${m.name} ${m.describe()} ${m.toList()} ${m.sorted()} ${m.sum()} ${m.map { it * 10 }} ${m.count()} ${m.first()}")
    var total = 0
    for (x in m) total += x
    println("loop $total ${(m as Any) is Iterable<*>} ${(m as Any) is Named}")
    val w = Wrapped()
    println("${w.message} ${w.size} ${4 in w} ${w.toList()} ${w.joinToString("+")} ${(w as Any) is Collection<*>} ${(w as Any) is Throwable}")
    try {
        throw w
    } catch (e: Exception) {
        println("caught ${e.message} ${(e as Wrapped).size}")
    }
    val r = Row("r1", listOf("a", "b", "c"))
    println("${r.describe()} ${r[1]} ${r.indexOf("c")} ${r.reversed()} ${r.joinToString("")} ${r.name} ${(r as Any) is List<*>}")
    for (cell in r) print("$cell ")
    println()
    val s = Scores(intArrayOf(5, 7, 9))
    println("${s.size} ${s[2]} ${s.max()} ${s.subList(0, 2)} ${s.filter { it > 5 }} ${s.describe()} ${s.lastIndex} ${s.getOrNull(5)}")
    var sum = 0
    for (i in s.indices) sum += s[i]
    println("sum $sum ${s.toList() == listOf(5, 7, 9)}")
    val settings = Settings(linkedMapOf("theme" to "dark"))
    settings["font"] = "mono"
    println("${settings.size} ${settings["theme"]} ${settings.keys} ${settings.entries.map { it.value }} ${settings.describe()}")
    for ((k, v) in settings) print("$k=$v ")
    println()
}
