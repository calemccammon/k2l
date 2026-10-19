// Constructs next to the ones library_constructor_refs and interface_delegation cover that are reported instead of
// miscompiled.
import java.util.concurrent.atomic.AtomicInteger
import kotlin.coroutines.CoroutineContext

// library interfaces without an implementation for classes of the program cannot be delegated either
class Context(c: CoroutineContext) : CoroutineContext by c

class Executor(e: java.util.concurrent.Executor) : java.util.concurrent.Executor by e

fun main() {
    // a library constructor whose call is not supported either
    val counter: () -> AtomicInteger = ::AtomicInteger
    println(counter())
    println(Context(kotlin.coroutines.EmptyCoroutineContext))
    println(Executor { it.run() })
}
