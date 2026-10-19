// Array content hashes and deep equality, and members of arrays read from `out`-projected containers
// (a `vararg` of arrays, `Array<out IntArray>`), whose elements have captured types.

class Grid(vararg rows: IntArray) {
    private val cells = rows.map { it.copyOf() }
    val width = rows[0].size
    val corner = rows[0][0]

    override fun equals(other: Any?) = other is Grid && cells.zip(other.cells).all { (a, b) -> a.contentEquals(b) }
    override fun hashCode() = cells.fold(17) { h, row -> 31 * h + row.contentHashCode() }
}

fun total(rows: Array<out IntArray>) = rows.sumOf { it.size } + rows[rows.size - 1].sum()

fun widest(vararg rows: DoubleArray): Int = rows.maxOf { it.size }

fun main() {
    println("${intArrayOf(1, 2, 3).contentHashCode()} ${intArrayOf().contentHashCode()} ${arrayOf("a", "b").contentHashCode()}")
    println("${booleanArrayOf(true, false).contentHashCode()} ${charArrayOf('a', 'b').contentHashCode()} ${longArrayOf(5L, 7L).contentHashCode()}")
    println("${arrayOf(intArrayOf(1), intArrayOf(2, 3)).contentDeepHashCode()} ${arrayOf(arrayOf("x"), arrayOf("y", "z")).contentDeepHashCode()}")
    println(intArrayOf(4, 5).contentHashCode() == listOf(4, 5).hashCode())
    val a = arrayOf(intArrayOf(1, 2), intArrayOf(3))
    val b = arrayOf(intArrayOf(1, 2), intArrayOf(3))
    println("${a.contentEquals(b)} ${a.contentDeepEquals(b)} ${a.contentDeepEquals(arrayOf(intArrayOf(1, 2), intArrayOf(4)))}")
    println("${arrayOf("p", null).contentDeepEquals(arrayOf("p", null))} ${a.contentDeepToString()}")
    val g1 = Grid(intArrayOf(1, 2, 3), intArrayOf(4, 5, 6))
    val g2 = Grid(intArrayOf(1, 2, 3), intArrayOf(4, 5, 6))
    println("${g1 == g2} ${g1.hashCode() == g2.hashCode()} ${g1.hashCode()} ${g1.width} ${g1.corner}")
    println("${setOf(g1, g2).size} ${total(arrayOf(intArrayOf(1, 2), intArrayOf(3, 4, 5)))} ${widest(doubleArrayOf(1.0), doubleArrayOf(2.0, 3.0))}")
}
