// `vararg` parameters of primary and secondary constructors, also through super calls, enums and spreads.

class Tags(vararg val names: String) {
    override fun toString() = names.joinToString(",", "Tags(", ")")
}

open class Batch(val id: Int, vararg items: Int) {
    val items = items.toList()

    constructor(label: String, vararg items: Int) : this(label.length, *items, 0)

    override fun toString() = "Batch($id, $items)"
}

class Labeled(val label: String, vararg xs: Int) : Batch(label.length * 10, *xs)

enum class Chord(vararg val notes: String) {
    C_MAJOR("C", "E", "G"),
    POWER("C", "G"),
    SILENCE,
}

fun main() {
    println(Tags())
    println(Tags("a"))
    println(Tags("a", "b", "c").names.size)
    val more = arrayOf("y", "z")
    println(Tags("x", *more))
    println(Batch(1))
    println(Batch(2, 5, 6))
    val xs = intArrayOf(7, 8)
    println(Batch(3, *xs, 9))
    println(Batch("four", 1, 2))
    println(Labeled("ab", 4, 4))
    println(Chord.entries.map { "${it.name}=${it.notes.joinToString("")}" })
    spreads()
}

fun total(label: String, vararg xs: Int) = "$label=${xs.sum()}/${xs.size}"

/** A spread that is not the last argument. */
fun spreads() {
    val a = arrayOf("a", "b")
    val n = intArrayOf(1, 2, 3)
    val none = arrayOf<String?>()
    println(listOf(*a, "c"))
    println(mutableListOf("0", *a, *a, "z"))
    println(arrayOf(*a, null, "q").toList())
    println(listOf(*none, null, *a).size)
    println(total("t", *n, 10))
    println(total("u", *n, *n))
    println(total("v", 5, *n, 6))
    println(setOf(*a, "a"))
    println(Tags(*a, "!", *arrayOf("?")))
}
