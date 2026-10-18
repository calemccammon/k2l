import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.resume
import kotlin.coroutines.startCoroutine
import kotlin.coroutines.suspendCoroutine

suspend fun double(x: Int): Int = suspendCoroutine { it.resume(x * 2) }

val pending = mutableListOf<Continuation<String>>()

suspend fun request(name: String): String = suspendCoroutine { pending.add(it) }

suspend fun main() {
    println("main runs as a coroutine: ${double(21)}")
    val results = mutableListOf<String>()
    for (name in listOf("a", "b")) {
        suspend { results.add(request(name)) }.startCoroutine(Continuation(EmptyCoroutineContext) { })
    }
    println("pending ${pending.size}")
    pending.forEachIndexed { i, cont -> cont.resume("reply$i") }
    println(results)
    try {
        double(1).also { check(it == 3) { "two is not three" } }
    } catch (e: IllegalStateException) {
        println("caught ${e.message}")
    }
}
