// A reference to a library constructor works for every class whose constructor call does.
import java.util.Stack
import java.util.StringJoiner
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TestTimeSource

fun main() {
    val joiner: (CharSequence) -> StringJoiner = ::StringJoiner
    println(joiner(", ").add("a").add("b"))
    val stacks: () -> Stack<Int> = ::Stack
    val s = stacks()
    s.push(1)
    s.push(2)
    println("${s.pop()} $s")
    val clock: () -> TestTimeSource = ::TestTimeSource
    val source = clock()
    val mark = source.markNow()
    source += 3.seconds
    println(mark.elapsedNow())
    val indexed: (Int, String) -> IndexedValue<String> = ::IndexedValue
    println(listOf("x", "y").mapIndexed(indexed))
    val version: (Int, Int, Int) -> KotlinVersion = ::KotlinVersion
    println(version(1, 9, 0) < KotlinVersion(2, 0))
    val anys = List(2) { ::Any }.map { it() }
    println(anys[0] == anys[1])
    val pair: (String, Int) -> Pair<String, Int> = ::Pair
    println(listOf(1 to "a", 2 to "b").map { (n, t) -> pair(t, n) })
}
