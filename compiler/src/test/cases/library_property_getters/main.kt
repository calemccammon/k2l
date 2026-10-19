import kotlin.coroutines.AbstractCoroutineContextElement
import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.coroutineContext
import kotlin.coroutines.startCoroutine

// Library code reads the properties below through the fields `key`, `context`, `message` and `cause`;
// the getters (with statements and a return) have to be what it sees.

object RequestKey : CoroutineContext.Key<RequestId>

class RequestId(val id: Int) : CoroutineContext.Element {
    override val key: CoroutineContext.Key<*> get() = RequestKey
}

class Tagged(val tag: String) : AbstractCoroutineContextElement(Tagged) {
    companion object Key : CoroutineContext.Key<Tagged>

    override val key: CoroutineContext.Key<*>
        get() = Tagged
}

class Counter(val n: Int) : CoroutineContext.Element {
    var reads = 0
    override val key: CoroutineContext.Key<*>
        get() {
            reads++
            return CounterKey
        }

    companion object CounterKey : CoroutineContext.Key<Counter>
}

class MyError(val code: Int) : Exception() {
    override val message: String
        get() {
            if (code > 100) return "huge code"
            return "code $code"
        }
    override val cause: Throwable?
        get() {
            if (code > 1) return IllegalStateException("inner $code")
            return null
        }
}

open class Parent {
    open val label: String
        get() {
            return "parent"
        }
}

class Child : Parent() {
    var reads = 0
    override val label: String
        get() {
            reads++
            return "child " + super.label
        }
}

class Receiver(val log: MutableList<String>) : Continuation<Int> {
    private val own = EmptyCoroutineContext + Tagged("receiver")
    override val context: CoroutineContext
        get() {
            log.add("context read")
            return own
        }

    override fun resumeWith(result: Result<Int>) {
        log.add("result ${result.getOrNull()}")
    }
}

suspend fun tag(): String = coroutineContext[Tagged]?.tag ?: "none"

fun main() {
    val ctx = EmptyCoroutineContext + RequestId(7) + Tagged("t")
    println(ctx[RequestKey]?.id)
    println(ctx[Tagged]?.tag)
    println(ctx.fold(0) { acc, _ -> acc + 1 })
    val minus = ctx.minusKey(RequestKey)
    println(minus[RequestKey] == null)
    println(minus[Tagged]?.tag)
    val c = Counter(1)
    val c2 = EmptyCoroutineContext + c
    println(c2[Counter]?.n)
    println(c.reads > 0)

    val e = MyError(3)
    println(e.message)
    println(e.cause?.message)
    try {
        throw MyError(1)
    } catch (x: Exception) {
        println(x.message)
        println(x.cause)
    }
    println(MyError(500).message)

    val child = Child()
    println(child.label)
    println(child.reads)

    val log = mutableListOf<String>()
    val receiver = Receiver(log)
    val block: suspend () -> Int = { tag().length }
    block.startCoroutine(receiver)
    println(log)
}
