data class Version(val major: Int, val minor: Int) : Comparable<Version> {
    override fun compareTo(other: Version): Int =
        if (major != other.major) major - other.major else minor - other.minor
}

fun sumAll(vararg numbers: Int): Int {
    var total = 0
    for (n in numbers) total += n
    return total
}

fun describe(label: String, vararg parts: String) = label + ": " + parts.joinToString(" ")

fun main() {
    println(sumAll())
    println(sumAll(1, 2, 3))
    val nums = intArrayOf(4, 5)
    println(sumAll(*nums))
    println(describe("parts", "a", "b"))

    val pair = "x" to 1
    println(pair)
    println(pair.first + pair.second)
    val (name, value) = pair
    println("$name=$value")
    val triple = Triple(1, "two", 3.0)
    println(triple)

    val versions = listOf(Version(1, 2), Version(0, 9), Version(1, 0))
    println(versions.sorted())
    println(Version(1, 0) < Version(1, 2))
    println(versions.maxOrNull())
    println(versions.sortedWith(compareBy { it.minor }))
    println(versions.sortedWith(compareByDescending<Version> { it.major }.thenBy { it.minor }))

    val r = 1..10
    println(r.toList().filter { it % 3 == 0 })
    println((1..4).map { it * it })
    println((10 downTo 1 step 4).toList())
    println(5 in r)
    var sum = 0
    for (i in r) sum += i
    println(sum)
    println(r)
    val evens = (0 until 10 step 2).toList()
    println(evens)

    val words = listOf("banana", "Apple", "cherry")
    println(words.sortedBy { it.lowercase() })
    println(words.map { it.length }.sum())
    println(words.filter { it.length > 5 }.size)
    val lookup = words.withIndex().associate { (i, w) -> w to i }
    println(lookup)
    println(listOf(3, 1, 2).sortedWith { a, b -> b - a })
    val queue = ArrayList<Int>()
    queue.addAll(listOf(1, 2, 3))
    println(queue.removeFirst())
    println(queue)
    println(listOf(1, 2, 3, 4).windowedSumPairs())
}

fun List<Int>.windowedSumPairs(): List<Int> = zip(drop(1)).map { (a, b) -> a + b }
