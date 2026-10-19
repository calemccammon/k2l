// References to library constructors are functions making the same call as the constructor would.
import java.util.TreeMap
import kotlin.reflect.KFunction1

fun <T> build(n: Int, make: () -> T): List<T> = List(n) { make() }

fun <A, R> apply(a: A, f: (A) -> R): R = f(a)

class Holder(val items: MutableList<String>)

fun main() {
    // collections: the expected type picks the constructor
    val lists: List<ArrayList<Int>> = build(2, ::ArrayList)
    lists[0].add(1)
    println(lists)
    val maps: List<HashMap<String, Int>> = build(1, ::HashMap)
    maps[0]["a"] = 1
    println(maps)
    val linked: () -> LinkedHashMap<String, Int> = ::LinkedHashMap
    println(linked().apply { put("z", 1); put("a", 2) })
    val sets: () -> HashSet<Int> = ::HashSet
    println(sets().apply { add(3) })
    val copy: (Collection<Int>) -> ArrayList<Int> = ::ArrayList
    println(copy(listOf(1, 2, 3)))
    val sorted: () -> TreeMap<String, Int> = ::TreeMap
    println(sorted().apply { put("b", 1); put("a", 2) })
    val deque: () -> ArrayDeque<Int> = ::ArrayDeque
    println(deque().apply { addFirst(1); addFirst(2) })

    // StringBuilder: with no arguments or from a String
    val empty: () -> StringBuilder = ::StringBuilder
    val fromText: (String) -> StringBuilder = ::StringBuilder
    println(empty().append("x").append(1))
    println(fromText("hi").append('!'))
    println(listOf("a", "b").map(::StringBuilder).map { it.reverse().append("?").toString() })

    // Pair and Triple
    println(listOf(1, 2, 3).zip(listOf("one", "two", "three"), ::Pair))
    val triple: (Int, String, Boolean) -> Triple<Int, String, Boolean> = ::Triple
    println(triple(1, "t", true))

    // exceptions, with a message, a cause or both
    val errors = listOf("bad", "worse").map(::IllegalStateException)
    println(errors.map { it.message })
    val wrap: (String, Throwable) -> RuntimeException = ::RuntimeException
    val wrapped = wrap("outer", errors[0])
    println("${wrapped.message} ${wrapped.cause?.message}")
    val noMessage: () -> UnsupportedOperationException = ::UnsupportedOperationException
    println(noMessage().message)
    try {
        throw apply("from a reference", ::IllegalArgumentException)
    } catch (e: IllegalArgumentException) {
        println("caught ${e.message}")
    }

    // Regex
    val patterns = listOf("a+b", "[0-9]+").map(::Regex)
    println(patterns.map { it.matches("aab") })

    // a source constructor held as a KFunction, and a library one taking an option
    val holder: KFunction1<MutableList<String>, Holder> = ::Holder
    println(holder(mutableListOf("x")).items)
    val ref: (String, RegexOption) -> Regex = ::Regex
    println(ref("X*", RegexOption.IGNORE_CASE).matches("xxx"))
}
