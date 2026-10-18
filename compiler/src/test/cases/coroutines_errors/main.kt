import kotlin.coroutines.Continuation
import kotlin.coroutines.ContinuationInterceptor
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.coroutineContext
import kotlin.coroutines.intrinsics.COROUTINE_SUSPENDED
import kotlin.coroutines.intrinsics.suspendCoroutineUninterceptedOrReturn

class GetterContinuation : Continuation<Unit> {
    override val context: CoroutineContext get() = EmptyCoroutineContext

    override fun resumeWith(result: Result<Unit>) {}
}

class Numbers : Sequence<Int> {
    override fun iterator(): Iterator<Int> = listOf(1, 2).iterator()
}

suspend fun intrinsic(): Int = suspendCoroutineUninterceptedOrReturn { COROUTINE_SUSPENDED }

suspend fun interceptor() = coroutineContext[ContinuationInterceptor]

fun main() {
    val items: Sequence<Any> = sequenceOf(1, "two")
    println(items.filterIsInstance<String>().toList())
    println(items.asIterable())
}
