// Library collections without a lualib base to extend are reported, and so are collection interfaces next to a base
// class that is not a collection.
import java.util.TreeMap

class Sorted : TreeMap<String, Int>()

class Deque : java.util.ArrayDeque<Int>()

open class Plain

class Mixed : Plain(), Iterable<Int> {
    override fun iterator(): Iterator<Int> = listOf(1).iterator()
}

class Wrapped : Exception(), Collection<Int> {
    override val size: Int get() = 0

    override fun isEmpty() = true

    override fun contains(element: Int) = false

    override fun containsAll(elements: Collection<Int>) = elements.isEmpty()

    override fun iterator(): Iterator<Int> = emptyList<Int>().iterator()
}

fun main() {
    println(Sorted().size + Deque().size + Mixed().count() + Wrapped().size)
}
