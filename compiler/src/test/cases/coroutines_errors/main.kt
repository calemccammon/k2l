import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

class GetterContinuation : Continuation<Unit> {
    override val context: CoroutineContext get() = EmptyCoroutineContext

    override fun resumeWith(result: Result<Unit>) {}
}

fun main() {
    val items: Sequence<Any> = sequenceOf(1, "two")
    println(items.filterIsInstance<String>().toList())
    println(items.lastIndexOf(1))
}
