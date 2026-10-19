import kotlin.coroutines.AbstractCoroutineContextElement
import kotlin.coroutines.Continuation
import kotlin.coroutines.ContinuationInterceptor
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.coroutineContext
import kotlin.coroutines.createCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.startCoroutine
import kotlin.coroutines.suspendCoroutine

class CoroutineName(val name: String) : AbstractCoroutineContextElement(CoroutineName) {
    companion object Key : CoroutineContext.Key<CoroutineName>

    override fun toString() = "CoroutineName($name)"
}

class UserId(val id: Int) : CoroutineContext.Element {
    override val key: CoroutineContext.Key<*> = UserId

    companion object : CoroutineContext.Key<UserId>
}

/** Runs everything on one queue, in order, from [runAll]. */
class QueueDispatcher : AbstractCoroutineContextElement(ContinuationInterceptor), ContinuationInterceptor {
    val queue = ArrayDeque<() -> Unit>()
    var dispatched = 0

    override fun <T> interceptContinuation(continuation: Continuation<T>): Continuation<T> = DispatchedContinuation(this, continuation)

    fun runAll() {
        while (queue.isNotEmpty()) queue.removeFirst()()
    }
}

class DispatchedContinuation<T>(private val dispatcher: QueueDispatcher, private val delegate: Continuation<T>) : Continuation<T> {
    override val context: CoroutineContext = delegate.context

    override fun resumeWith(result: Result<T>) {
        dispatcher.dispatched++
        dispatcher.queue.add { delegate.resumeWith(result) }
    }
}

val waiting = mutableListOf<Continuation<Unit>>()

suspend fun park() = suspendCoroutine<Unit> { waiting.add(it) }

suspend fun nameNow(): String = coroutineContext[CoroutineName]?.name ?: "<none>"

suspend fun worker(label: String, steps: Int) {
    for (i in 1..steps) {
        println("$label step $i in ${nameNow()} user=${coroutineContext[UserId]?.id}")
        park()
    }
    println("$label done")
}

fun launch(context: CoroutineContext, block: suspend () -> Unit) {
    block.startCoroutine(
        Continuation(context) { result ->
            result.exceptionOrNull()?.let { println("failed: ${it.message}") }
        },
    )
}

fun main() {
    val dispatcher = QueueDispatcher()
    launch(dispatcher + CoroutineName("alpha") + UserId(1)) { worker("A", 2) }
    launch(CoroutineName("beta") + dispatcher) { worker("B", 1) }
    println("launched, queue=${dispatcher.queue.size}")
    dispatcher.runAll()
    println("after first run, waiting=${waiting.size}")
    while (waiting.isNotEmpty()) {
        val next = waiting.toList()
        waiting.clear()
        next.forEach { it.resume(Unit) }
        dispatcher.runAll()
    }
    println("dispatched=${dispatcher.dispatched}")

    // plain context operations
    val ctx = CoroutineName("n") + UserId(7)
    println(ctx[CoroutineName]?.name)
    println(ctx[UserId]?.id)
    println(ctx[ContinuationInterceptor] == null)
    println(ctx.minusKey(CoroutineName)[CoroutineName] == null)
    println(ctx.minusKey(CoroutineName)[UserId]?.id)
    println((ctx + CoroutineName("m"))[CoroutineName]?.name)
    println(ctx.fold(0) { acc, element -> acc + (if (element is UserId) element.id else 100) })
    println((EmptyCoroutineContext + ctx)[UserId]?.id)
    println((ctx + EmptyCoroutineContext)[CoroutineName]?.name)
    println(CoroutineName("x").key == CoroutineName)
    println(ctx.minusKey(CoroutineName).minusKey(UserId) === EmptyCoroutineContext)
    val withDispatcher = dispatcher + ctx
    println(withDispatcher[ContinuationInterceptor] === dispatcher)
    println(withDispatcher.fold("") { acc, element -> acc + (element is QueueDispatcher) })

    // createCoroutine starts through the dispatcher too
    var finished = false
    val creator = QueueDispatcher()
    val cont = suspend { println("created body in ${nameNow()}") }.createCoroutine(
        Continuation(creator + CoroutineName("created")) { finished = true },
    )
    cont.resume(Unit)
    println("queued=${creator.queue.size} finished=$finished")
    creator.runAll()
    println("finished=$finished")
}
