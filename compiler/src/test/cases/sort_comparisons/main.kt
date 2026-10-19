// Comparators, compareTo and compareBy selectors run in the same order and as often as on the JVM (TimSort).

data class Item(val key: Int, val id: Int) : Comparable<Item> {
    override fun compareTo(other: Item): Int {
        Log.calls++
        Log.hash = (Log.hash * 31 + key * 7 + other.key) % 999983
        return key.compareTo(other.key)
    }
}

object Log {
    var calls = 0
    var hash = 0

    fun reset() {
        calls = 0
        hash = 0
    }

    fun record(a: Int, b: Int) {
        calls++
        hash = (hash * 31 + a * 7 + b) % 999983
    }

    fun summary(): String = "calls=$calls hash=$hash"
}

class Lcg(private var state: Int) {
    fun next(bound: Int): Int {
        state = (state * 75 + 74) % 65537
        return state % bound
    }
}

/** Arrays of different shapes: random, few distinct keys, ascending and descending runs, sawtooth. */
fun shapes(n: Int, seed: Int): List<List<Int>> {
    val rnd = Lcg(seed)
    return listOf(
        List(n) { rnd.next(1000) },
        List(n) { rnd.next(4) },
        List(n) { it },
        List(n) { n - it },
        List(n) { (it * 7) % 13 },
        List(n) { if (it % 50 < 25) it else n - it },
        List(n) { if (rnd.next(10) == 0) rnd.next(1000) else it },
    )
}

val byValue = Comparator<Int> { a, b ->
    Log.record(a, b)
    a.compareTo(b)
}

fun smallSequence() {
    val calls = mutableListOf<String>()
    val sorted = listOf(5, 2, 4, 1, 3).sortedWith { a, b ->
        calls += "$a-$b"
        a - b
    }
    println("$sorted ${calls.joinToString(" ")}")
    calls.clear()
    val desc = listOf(1, 2, 3, 4).sortedWith { a, b ->
        calls += "$a-$b"
        b - a
    }
    println("$desc ${calls.joinToString(" ")}")
}

fun counts() {
    val sizes = listOf(0, 1, 2, 3, 7, 31, 32, 33, 64, 65, 100, 257, 1000, 3000)
    for (n in sizes) {
        val line = StringBuilder("n=$n")
        for ((i, input) in shapes(n, n + 11).withIndex()) {
            Log.reset()
            val sorted = input.sortedWith(byValue)
            check(sorted == input.sorted())
            line.append(" [$i ${Log.summary()}]")
        }
        println(line)
    }
}

fun selectors() {
    var selected = 0
    val words = listOf("pear", "fig", "banana", "kiwi", "apple", "plum", "cherry", "date")
    val byLength = words.sortedBy {
        selected++
        it.length
    }
    println("sortedBy $byLength selector=$selected")
    selected = 0
    val desc = words.sortedByDescending {
        selected++
        it.length
    }
    println("sortedByDescending $desc selector=$selected")
    val order = mutableListOf<String>()
    listOf("b", "a", "c").sortedBy {
        order += it
        it
    }
    println("selector order $order")
    order.clear()
    listOf("b", "a", "c").sortedByDescending {
        order += it
        it
    }
    println("descending selector order $order")
    selected = 0
    val mutable = words.toMutableList()
    mutable.sortBy {
        selected++
        it.last()
    }
    println("sortBy $mutable selector=$selected")
    selected = 0
    mutable.sortByDescending {
        selected++
        it.first()
    }
    println("sortByDescending $mutable selector=$selected")
    selected = 0
    val single = listOf("x").sortedBy {
        selected++
        it
    }
    println("one element $single selector=$selected")
    selected = 0
    val chained = words.sortedWith(
        compareBy<String> {
            selected++
            it.length
        }.thenBy {
            selected++
            it
        },
    )
    println("compareBy.thenBy $chained selector=$selected")
}

fun comparables() {
    val rnd = Lcg(7)
    val items = List(80) { Item(rnd.next(20), it) }
    Log.reset()
    val sorted = items.sorted()
    println("sorted() ${Log.summary()} stable=${sorted.zipWithNext().all { (a, b) -> a.key < b.key || (a.key == b.key && a.id < b.id) }}")
    Log.reset()
    val desc = items.sortedDescending()
    println("sortedDescending() ${Log.summary()} first=${desc.first()}")
    Log.reset()
    val mutable = items.toMutableList()
    mutable.sort()
    println("sort() ${Log.summary()} ${mutable == sorted}")
    Log.reset()
    mutable.sortDescending()
    println("sortDescending() ${Log.summary()} ${mutable == desc}")
    Log.reset()
    val array = items.toTypedArray()
    array.sort()
    println("Array.sort() ${Log.summary()} ${array.toList() == sorted}")
    Log.reset()
    println("max ${items.max()} ${Log.summary()}")
    Log.reset()
    println("maxOrNull ${items.maxOrNull()} minOrNull ${items.minOrNull()} ${Log.summary()}")
    Log.reset()
    println("sortedBy item ${items.sortedBy { it }.first()} ${Log.summary()}")
    Log.reset()
    println("maxBy ${items.maxBy { it }} ${Log.summary()}")
}

fun javaSorts() {
    val rnd = Lcg(3)
    val values = List(150) { rnd.next(500) }
    Log.reset()
    val list = values.toMutableList()
    java.util.Collections.sort(list, byValue)
    println("Collections.sort ${Log.summary()}")
    Log.reset()
    val array = values.toTypedArray()
    java.util.Arrays.sort(array, byValue)
    println("Arrays.sort ${Log.summary()} ${array.toList() == list}")
    Log.reset()
    val part = values.toTypedArray()
    java.util.Arrays.sort(part, 10, 120, byValue)
    println("Arrays.sort range ${Log.summary()} ${part.take(12)}")
    Log.reset()
    val other = values.toTypedArray()
    other.sortWith(byValue)
    println("Array.sortWith ${Log.summary()}")
    Log.reset()
    println("sortedArrayWith ${values.toTypedArray().sortedArrayWith(byValue).take(5)} ${Log.summary()}")
    Log.reset()
    list.shuffle(java.util.Random(5))
    list.sortWith(byValue)
    println("MutableList.sortWith ${Log.summary()}")
    Log.reset()
    println("reversed comparator ${values.sortedWith(byValue.reversed()).take(5)} ${Log.summary()}")
    Log.reset()
    println("maxWith ${values.maxWith(byValue)} ${Log.summary()}")
    Log.reset()
    println("minWith ${values.minWith(byValue)} ${Log.summary()}")
    val pairs = mutableListOf<String>()
    listOf(3, 1, 2).maxWithOrNull { a, b ->
        pairs += "$a-$b"
        a - b
    }
    println("maxWith order $pairs")
}

fun brokenComparators() {
    for (seed in 1..6) {
        val rnd = Lcg(seed)
        val values = List(400) { rnd.next(100) }
        val coin = Lcg(seed * 13)
        val result = try {
            values.sortedWith { _, _ -> coin.next(3) - 1 }
            "sorted"
        } catch (e: IllegalArgumentException) {
            e.message
        }
        println("random comparator $seed: $result")
    }
}

class Counted(val raw: Int) {
    val key: Int
        get() {
            Log.calls++
            return raw % 5
        }
}

enum class Suit { CLUBS, HEARTS, SPADES }

// Selectors that only read fields compute each key once (no observable difference); a getter runs per comparison.
fun pureSelectors() {
    val rnd = Lcg(11)
    val items = List(60) { Item(rnd.next(9), it) }
    println(items.sortedBy { it.key }.take(6))
    println(items.sortedByDescending { it.key * 2 - it.id }.take(4))
    println(items.sortedBy(Item::id).take(3))
    println(listOf("bb", "a", "ccc", "dd").sortedBy { it.length })
    println(listOf(1 to "z", 0 to "y", 1 to "x").sortedBy { it.first })
    println(listOf(Suit.SPADES, Suit.CLUBS, Suit.HEARTS).sortedByDescending { it.ordinal })
    println(listOf(2.5, -0.0, 0.0, Double.NaN, -1.0).sortedBy { it }.joinToString { it.toString() })
    println(listOf(0.0, Double.NaN, -0.0, -3.5).sorted().joinToString { it.toString() })
    println(List(40) { if (it % 7 == 0) Double.NaN else if (it % 2 == 0) -0.0 else 0.0 }.sortedDescending().joinToString { it.toString() })
    println("${(-0.0).compareTo(0.0)} ${Double.NaN.compareTo(1.0)} ${compareValues(Double.NaN, Double.NaN)} ${compareValues(0.0, -0.0)}")
    println(mapOf("b" to 2, "a" to 1).entries.sortedBy { it.value }.map { it.key })
    val mutable = items.toMutableList()
    mutable.sortBy { it.id % 7 }
    println(mutable.take(5))
    println(items.asSequence().sortedBy { -it.id }.take(2).toList())
    Log.reset()
    val counted = List(40) { Counted(it * 37 % 41) }.sortedBy { it.key }
    println("getter selector calls=${Log.calls} ${counted.take(5).map { it.raw }}")
}

fun main() {
    smallSequence()
    pureSelectors()
    counts()
    selectors()
    comparables()
    javaSorts()
    brokenComparators()
}
