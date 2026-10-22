// Members that share a Lua name with an override of a library member, whose name the library fixes: a final
// property named like the method (`val hashCode` next to `override fun hashCode()`) and a property accessor named like it (`override var value` next to `override fun setValue`).
class Wrapper(val obj: String, val hashCode: Int) {
    override fun hashCode(): Int = hashCode

    override fun equals(other: Any?): Boolean = other is Wrapper && other.obj == obj

    override fun toString(): String = "Wrapper($obj, hashCode = $hashCode)"
}

open class Pair2(override val key: String, override val value: Int) : Map.Entry<String, Int> {
    override fun toString() = "$key=$value"
}

class Cell(key: String, override var value: Int) : Pair2(key, value), MutableMap.MutableEntry<String, Int> {
    var writes = 0

    override fun setValue(newValue: Int): Int {
        val old = value
        value = newValue
        writes++
        return old
    }
}

fun main() {
    val w = Wrapper("a", 7)
    println(w.hashCode)
    println(w.hashCode())
    println(setOf(w, Wrapper("a", 7)).size)
    println(w)
    val read: (Wrapper) -> Int = { it.hashCode }
    println(read(w))

    val cell = Cell("k", 1)
    println(cell.setValue(5))
    println(cell.value)
    cell.value = 6
    println("$cell ${cell.writes}")
    val entry: MutableMap.MutableEntry<String, Int> = cell
    println(entry.setValue(8))
    println("${entry.value} ${cell.writes}")
    val base: Pair2 = cell
    println(base.value)
}
