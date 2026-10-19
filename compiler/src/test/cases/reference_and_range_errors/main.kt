// Constructs next to the ones library_constructor_refs and interface_delegation cover that are reported instead of
// miscompiled.
import java.util.concurrent.atomic.AtomicInteger

// classes of the program cannot implement Comparator or Iterator, so they cannot delegate them either
class ByLength(cmp: Comparator<String>) : Comparator<String> by cmp

class Numbers(it: Iterator<Int>) : Iterator<Int> by it

fun main() {
    // a library constructor whose call is not supported either
    val counter: () -> AtomicInteger = ::AtomicInteger
    println(counter())
    println(listOf("bb", "a").sortedWith(ByLength(compareBy { it.length })))
    println(Numbers(listOf(1).iterator()))
}
