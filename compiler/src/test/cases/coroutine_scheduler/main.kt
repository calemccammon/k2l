import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.startCoroutine
import kotlin.coroutines.suspendCoroutine

/** A tiny game-loop scheduler: coroutines wait for frames; `main` drives the loop. */
class Scheduler {
    private class Waiting(val wakeAt: Int, val cont: Continuation<Unit>)

    var frame = 0
        private set
    private val waiting = mutableListOf<Waiting>()
    private var active = 0

    fun launch(name: String, task: suspend () -> Unit) {
        active++
        task.startCoroutine(
            Continuation(EmptyCoroutineContext) { result ->
                active--
                val error = result.exceptionOrNull()
                if (error != null) println("[$frame] $name failed: ${error.message}") else println("[$frame] $name finished")
            },
        )
    }

    suspend fun waitFrames(n: Int) {
        if (n <= 0) return
        suspendCoroutine<Unit> { cont -> waiting.add(Waiting(frame + n, cont)) }
    }

    /** Cancels everything still waiting by resuming it with an exception. */
    fun cancelAll(reason: String) {
        val all = waiting.toList()
        waiting.clear()
        for (w in all) w.cont.resumeWithException(IllegalStateException(reason))
    }

    fun runFrame(): Boolean {
        frame++
        val due = waiting.filter { it.wakeAt <= frame }
        waiting.removeAll(due)
        for (w in due) w.cont.resume(Unit)
        return active > 0
    }
}

/** Single-value channel between coroutines. */
class Mailbox<T> {
    private var value: T? = null
    private var receiver: Continuation<T>? = null

    fun send(v: T) {
        val r = receiver
        if (r != null) {
            receiver = null
            r.resume(v)
        } else {
            value = v
        }
    }

    suspend fun receive(): T {
        val v = value
        if (v != null) {
            value = null
            return v
        }
        return suspendCoroutine { cont -> receiver = cont }
    }
}

val scheduler = Scheduler()

suspend fun blink(name: String, times: Int, every: Int) {
    repeat(times) { i ->
        println("[${scheduler.frame}] $name blink ${i + 1}")
        scheduler.waitFrames(every)
    }
}

suspend fun guardedWait(): String {
    try {
        println("[${scheduler.frame}] guard: waiting inside try")
        scheduler.waitFrames(2)
        println("[${scheduler.frame}] guard: woke inside try")
        scheduler.waitFrames(100)
        return "unreachable"
    } catch (e: IllegalStateException) {
        println("[${scheduler.frame}] guard: caught ${e.message}")
        scheduler.waitFrames(1)
        return "recovered"
    } finally {
        println("[${scheduler.frame}] guard: finally")
    }
}

fun main() {
    val mailbox = Mailbox<String>()
    scheduler.launch("fast") { blink("fast", 3, 1) }
    scheduler.launch("slow") { blink("slow", 2, 3) }
    scheduler.launch("consumer") {
        val first = mailbox.receive()
        println("[${scheduler.frame}] consumer got $first")
        val second = mailbox.receive()
        println("[${scheduler.frame}] consumer got $second")
    }
    scheduler.launch("producer") {
        scheduler.waitFrames(2)
        mailbox.send("hello")
        scheduler.waitFrames(2)
        mailbox.send("world")
    }
    scheduler.launch("guard") {
        val outcome = guardedWait()
        println("[${scheduler.frame}] guard: $outcome")
    }
    scheduler.launch("crasher") {
        scheduler.waitFrames(1)
        error("boom at frame ${scheduler.frame}")
    }
    scheduler.launch("instant") { println("[${scheduler.frame}] instant runs without waiting") }

    while (scheduler.runFrame()) {
        if (scheduler.frame == 4) {
            println("-- frame 4: cancelling")
            scheduler.cancelAll("cancelled")
        }
        if (scheduler.frame > 20) break
    }
    println("done at frame ${scheduler.frame}")
}
