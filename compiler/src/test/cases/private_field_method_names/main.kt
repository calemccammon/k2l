// A private property may share its name with a method of its class (the usual iterator with `private var next`):
// its field is stored under another key, so the method stays callable.

class Countdown(private val from: Int) : Iterator<Int> {
    private var next = from
    override fun hasNext() = next > 0
    override fun next(): Int {
        if (!hasNext()) throw NoSuchElementException("done")
        return next--
    }
    fun from() = "from $from"
}

class Fib : Iterator<Long> {
    private var current = 0L
        get() = field
    private var next = 1L
    override fun hasNext() = true
    override fun next(): Long {
        val r = current
        current = next.also { next += current }
        return r
    }
    fun current() = current
}

class Buffer(private val size: Int) {
    private val items = ArrayList<String>()
    fun size() = items.size
    fun add(s: String) = apply { if (items.size < size) items += s }
    fun capacity() = size
    fun items() = items.toList()
}

fun main() {
    val c = Countdown(3)
    println("${c.asSequence().toList()} ${c.hasNext()} ${c.from()}")
    println(runCatching { c.next() }.exceptionOrNull())
    val f = Fib()
    println("${List(10) { f.next() }} ${f.current()}")
    val b = Buffer(2).add("a").add("b").add("c")
    println("${b.size()} ${b.capacity()} ${b.items()}")
    for (x in Countdown(2)) print("$x ")
    println()
}
