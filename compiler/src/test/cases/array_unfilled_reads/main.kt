// Reading an element of an `Array<T>` that is still null (an unchecked `arrayOfNulls` cast) gives null,
// and an index out of range still throws.
@Suppress("UNCHECKED_CAST")
class Slots<T>(n: Int) {
    val items = arrayOfNulls<Any>(n) as Array<T>

    operator fun get(i: Int): T = items[i]

    operator fun set(i: Int, v: T) {
        items[i] = v
    }
}

fun main() {
    @Suppress("UNCHECKED_CAST")
    val names = arrayOfNulls<String>(3) as Array<String>
    names[1] = "b"
    println(names[0] == null)
    println(names[1])
    println(names[2] == null)
    val grid = arrayOfNulls<IntArray>(2)
    grid[0] = intArrayOf(1, 2)
    println(grid[1] == null)
    println(grid[0]!![1])
    val s = Slots<String>(2)
    s[0] = "x"
    println("${s[0]} ${s[1] == null}")
    try {
        println(names[3])
    } catch (e: ArrayIndexOutOfBoundsException) {
        println("caught ${e.message}")
    }
    try {
        println(names[-1])
    } catch (e: ArrayIndexOutOfBoundsException) {
        println("caught ${e.message}")
    }
}
