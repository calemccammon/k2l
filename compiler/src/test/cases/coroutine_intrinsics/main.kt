import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.intrinsics.COROUTINE_SUSPENDED
import kotlin.coroutines.intrinsics.createCoroutineUnintercepted
import kotlin.coroutines.intrinsics.startCoroutineUninterceptedOrReturn
import kotlin.coroutines.intrinsics.suspendCoroutineUninterceptedOrReturn
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.startCoroutine

val parked = mutableListOf<Continuation<Int>>()

suspend fun immediate(x: Int): Int = suspendCoroutineUninterceptedOrReturn { x * 2 }

suspend fun park(): Int = suspendCoroutineUninterceptedOrReturn { cont ->
    parked.add(cont)
    COROUTINE_SUSPENDED
}

suspend fun resumedBeforeSuspend(): Int = suspendCoroutineUninterceptedOrReturn { cont ->
    cont.resume(41)
    COROUTINE_SUSPENDED
}

suspend fun failing(): Int = suspendCoroutineUninterceptedOrReturn { cont ->
    parked.add(cont)
    COROUTINE_SUSPENDED
}

fun run(block: suspend () -> Unit) {
    block.startCoroutine(Continuation(EmptyCoroutineContext) { it.exceptionOrNull()?.let { e -> println("failed: ${e.message}") } })
}

suspend fun nested(): Int = suspendCoroutineUninterceptedOrReturn { cont ->
    val block: suspend () -> Int = {
        val a = park()
        a + 1
    }
    block.startCoroutineUninterceptedOrReturn(cont)
}

suspend fun nestedSync(): Int = suspendCoroutineUninterceptedOrReturn { cont ->
    val block: suspend () -> Int = { immediate(5) + 1 }
    block.startCoroutineUninterceptedOrReturn(cont)
}

fun main() {
    run {
        println("immediate ${immediate(21)}")
        println("resumedBeforeSuspend ${resumedBeforeSuspend()}")
        println("park ${park()}")
        println("nestedSync ${nestedSync()}")
        println("nested ${nested()}")
        try {
            failing()
        } catch (e: IllegalStateException) {
            println("caught ${e.message}")
        }
        println("end")
    }
    println("parked ${parked.size}")
    parked.removeAt(0).resume(7)
    println("parked ${parked.size}")
    parked.removeAt(0).resume(99)
    println("parked ${parked.size}")
    parked.removeAt(0).resumeWithException(IllegalStateException("boom"))

    val created = suspend { println("unintercepted body") }.createCoroutineUnintercepted(Continuation(EmptyCoroutineContext) { println("done ${it.isSuccess}") })
    println("created")
    created.resume(Unit)
}
