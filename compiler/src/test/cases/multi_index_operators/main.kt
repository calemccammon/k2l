// `operator fun get`/`set` with several indices: reads, `=`, compound assignments and `++`/`--`.
class Matrix(val rows: Int, val cols: Int) {
    private val data = IntArray(rows * cols)

    operator fun get(i: Int, j: Int): Int = data[i * cols + j]

    operator fun set(i: Int, j: Int, v: Int) {
        data[i * cols + j] = v
    }

    // an overload with the same number of indices
    operator fun get(row: String, col: String): Int = get(row.toInt(), col.toInt())

    operator fun set(row: String, col: String, v: Int) = set(row.toInt(), col.toInt(), v)

    override fun toString() = (0 until rows).joinToString(" / ") { i -> (0 until cols).joinToString(",") { j -> "${this[i, j]}" } }
}

class Cube {
    private val cells = mutableMapOf<String, Double>()

    operator fun get(x: Int, y: Int, z: Int): Double = cells["$x/$y/$z"] ?: 0.0

    operator fun set(x: Int, y: Int, z: Int, v: Double) {
        cells["$x/$y/$z"] = v
    }
}

// declared in an interface and an open class, used through subclasses
interface Grid<T> {
    operator fun get(x: Int, y: Int): T

    operator fun set(x: Int, y: Int, value: T)
}

open class MapGrid<T>(private val default: T) : Grid<T> {
    private val cells = HashMap<Pair<Int, Int>, T>()

    override fun get(x: Int, y: Int): T = cells[x to y] ?: default

    override fun set(x: Int, y: Int, value: T) {
        println("set $x,$y = $value")
        cells[x to y] = value
    }
}

class TextGrid : MapGrid<String>(".")

// an extension operator on a library type
operator fun List<MutableList<Int>>.get(i: Int, j: Int) = this[i][j]

operator fun List<MutableList<Int>>.set(i: Int, j: Int, v: Int) {
    this[i][j] = v
}

// and on a class of the program, next to its member get with one index
class Row(val values: MutableList<String>) {
    operator fun get(i: Int) = values[i]
}

operator fun Row.get(i: Int, suffix: String) = values[i] + suffix

operator fun Row.set(i: Int, suffix: String, v: String) {
    values[i] = v + suffix
}

var calls = 0

fun index(n: Int): Int {
    calls++
    println("index $n")
    return n
}

fun main() {
    val m = Matrix(2, 3)
    m[0, 1] = 5
    m[1, 2] = m[0, 1] * 2
    m[0, 1] += 3
    m[1, 2] -= 4
    m[0, 0]++
    m[0, 0]++
    m[1, 1]--
    ++m[1, 0]
    println(m)
    val old = m[0, 1]++
    val new = ++m[0, 1]
    println("$old $new ${m[0, 1]}")
    m["1", "1"] = 9
    m["1", "1"] *= 2
    println(m["1", "1"])
    println(m)

    // the receiver and indices are evaluated once, in order
    m[index(1), index(2)] += 100
    m[index(0), index(2)]++
    println("$m, $calls calls")

    val c = Cube()
    c[1, 2, 3] = 1.5
    c[1, 2, 3] += 2.0
    c[0, 0, 0] -= 1.0
    println("${c[1, 2, 3]} ${c[0, 0, 0]} ${c[9, 9, 9]}")

    val g: Grid<String> = TextGrid()
    g[0, 0] = "a"
    g[0, 0] += "b"
    println(g[0, 0] + g[5, 5])
    val counts = MapGrid(0)
    for (i in 0 until 3) counts[i % 2, 0]++
    println("${counts[0, 0]} ${counts[1, 0]}")

    val table = listOf(mutableListOf(1, 2), mutableListOf(3, 4))
    table[1, 0] = 30
    table[0, 1] *= 10
    table[1, 1]++
    println("$table ${table[1, 0]}")

    val row = Row(mutableListOf("x", "y"))
    row[1, "!"] = "z"
    row[0, "?"] += "w"
    println("${row[0]} ${row[1]} ${row[0, "."]}")
}
