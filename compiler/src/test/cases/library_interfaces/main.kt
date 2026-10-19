// Classes of the program implementing library interfaces: Comparator, Comparable, Iterator, Iterable, CharSequence,
// Runnable, Callable and function types.

class ByLength : Comparator<String> {
    var calls = 0

    override fun compare(a: String, b: String): Int {
        calls++
        return a.length - b.length
    }
}

data class Version(val major: Int, val minor: Int) : Comparable<Version> {
    override fun compareTo(other: Version): Int = compareValuesBy(this, other, { it.major }, { it.minor })
}

class Count(private val n: Int) : Iterator<Int> {
    private var i = 0

    override fun hasNext() = i < n

    override fun next(): Int = i++
}

class Upto(private val n: Int) : Iterable<Int> {
    override fun iterator(): Iterator<Int> = Count(n)
}

class Letters(private val text: String) : CharSequence {
    override val length: Int get() = text.length

    override fun get(index: Int): Char = text[index]

    override fun subSequence(startIndex: Int, endIndex: Int): CharSequence = Letters(text.substring(startIndex, endIndex))

    override fun toString(): String = text
}

class Task(private val name: String) : Runnable {
    override fun run() {
        println("run $name")
    }
}

class Answer : java.util.concurrent.Callable<Int> {
    override fun call(): Int = 42
}

class Doubler : (Int) -> Int {
    override fun invoke(x: Int): Int = x * 2
}

fun interface Check {
    fun test(x: Int): Boolean
}

fun comparators() {
    val words = listOf("ccc", "a", "bb", "dddd", "ee")
    val byLength = ByLength()
    println(words.sortedWith(byLength))
    println("calls ${byLength.calls} ${byLength.compare("aa", "b")}")
    println(words.sortedWith(byLength.reversed()))
    println(words.sortedWith(byLength.thenBy { it }))
    println(words.sortedWith(byLength.thenDescending(naturalOrder())))
    println("${words.maxWith(byLength)} ${words.minWithOrNull(byLength)}")
    val mutable = words.toMutableList()
    mutable.sortWith(byLength)
    java.util.Collections.sort(mutable, ByLength())
    println(mutable)
    val tree = java.util.TreeSet(ByLength())
    tree.addAll(words)
    println(tree)
    val sam = Comparator<String> { a, b -> b.compareTo(a) }
    println("${words.sortedWith(sam)} ${sam.compare("a", "b")} ${words.sortedWith(sam.reversed())}")
    val arr = words.toTypedArray()
    java.util.Arrays.sort(arr, byLength)
    println(arr.toList())
}

fun comparables() {
    val vs = listOf(Version(1, 2), Version(0, 9), Version(1, 0))
    println("${vs.sorted()} ${vs.max()} ${vs.minOrNull()} ${vs.sortedDescending()}")
    println("${Version(1, 0) < Version(1, 1)} ${Version(2, 0) >= Version(1, 9)} ${Version(1, 1).compareTo(Version(1, 1))}")
    println("${Version(3, 0).coerceIn(Version(1, 0), Version(2, 0))} ${maxOf(Version(1, 0), Version(0, 5))} ${vs.sortedBy { it }}")
    println(vs.sortedWith(naturalOrder()))
}

fun iterators() {
    for (x in Count(3)) print("$x ")
    println()
    val c = Count(4)
    println("${c.next()} ${c.hasNext()} ${c.asSequence().toList()}")
    val u = Upto(5)
    println("${u.map { it * it }} ${u.filter { it % 2 == 0 }} ${u.toList()} ${u.joinToString("-")} ${u.sum()} ${u.count()}")
    var total = 0
    for (x in u) total += x
    u.forEach { total += it }
    println("total $total ${u.first()} ${u.last()} ${u.contains(3)} ${u.sortedDescending()} ${u.toSet()} ${u.zip(u.drop(1))}")
}

fun others() {
    val l = Letters("hello")
    println("${l.length} ${l[1]} ${l.subSequence(1, 3)} $l ${"[" + l + "]"} ${l.toString().uppercase()}")
    Task("t1").run()
    val tasks: List<Runnable> = listOf(Task("t2"), Runnable { println("lambda runnable") })
    tasks.forEach { it.run() }
    println(Answer().call())
    val d = Doubler()
    println("${d(4)} ${listOf(1, 2).map(d)}")
    val even = Check { it % 2 == 0 }
    println("${even.test(4)} ${even.test(3)}")
}

open class Named(val name: String)

class Reverse : Named("reverse"), Comparator<Int> {
    override fun compare(a: Int, b: Int) = b.compareTo(a)
}

class Backwards(private val items: List<String>) : ListIterator<String> {
    private var i = items.size

    override fun hasNext() = i > 0

    override fun next(): String = items[--i]

    override fun hasPrevious() = i < items.size

    override fun previous(): String = items[i++]

    override fun nextIndex() = items.size - i

    override fun previousIndex() = nextIndex() - 1
}

fun describe(cs: CharSequence): String = "${cs.length}:${cs[0]}:${cs.subSequence(1, 3)}:${cs.isEmpty()}:${cs.reversed()}:${cs.indexOf('l')}"

fun countMatching(xs: List<Int>, check: Check): Int = xs.count { check.test(it) }

fun twice(r: Runnable) {
    r.run()
    r.run()
}

fun smallest(words: List<String>, c: Comparator<String>): String = words.minWith(c)

fun more() {
    twice { println("sam lambda") }
    twice(Task("t3"))
    println("${smallest(listOf("bb", "a"), ByLength())} ${smallest(listOf("bb", "a")) { x, y -> y.length - x.length }}")
    val r = Reverse()
    println("${listOf(1, 3, 2).sortedWith(r)} ${r.name} ${(r as Any) is Comparator<*>} ${listOf(5, 9).maxWith(r)}")
    println(listOf("b", "aa", "c").sortedWith(compareBy(ByLength()) { it + it }))
    println("${describe(Letters("hello"))} ${describe("world")} ${"o" in Letters("foo")} ${Letters("abc").first()}")
    println("${countMatching(listOf(1, 2, 3, 4), Check { it > 1 })} ${countMatching(listOf(1, 2, 3), { it % 2 == 1 })}")
    val b = Backwards(listOf("x", "y", "z"))
    val seen = mutableListOf<String>()
    for (s in b) seen += s
    println("$seen ${b.hasPrevious()} ${b.previous()} ${b.nextIndex()}")
    println("${Version(1, 5).coerceAtLeast(Version(2, 0))} ${listOf(Version(0, 1), Version(0, 0)).sortedWith(compareBy { it })}")
}

fun main() {
    more()
    comparators()
    comparables()
    iterators()
    others()
}
