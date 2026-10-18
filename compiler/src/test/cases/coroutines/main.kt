import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.coroutineContext
import kotlin.coroutines.createCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.startCoroutine
import kotlin.coroutines.suspendCoroutine

/** A continuation parked by [awaitValue], resumed later from `main`. */
var parked: Continuation<Int>? = null

suspend fun awaitValue(label: String): Int {
    println("  $label: suspending")
    val value = suspendCoroutine<Int> { cont -> parked = cont }
    println("  $label: resumed with $value")
    return value
}

/** Resumes before the block returns: the coroutine never actually suspends. */
suspend fun immediate(x: Int): Int = suspendCoroutine { cont -> cont.resume(x * 2) }

suspend fun failLater(): String = suspendCoroutine { cont ->
    cont.resumeWithException(IllegalStateException("async failure"))
}

suspend fun sum(): Int {
    val a = awaitValue("a")
    val b = immediate(a)
    return a + b
}

class Printer(val name: String) : Continuation<Int> {
    override val context: CoroutineContext = EmptyCoroutineContext

    override fun resumeWith(result: Result<Int>) {
        println("$name completed: $result")
    }
}

fun <T> completion(name: String): Continuation<T> = Continuation(EmptyCoroutineContext) { result ->
    result.fold(
        onSuccess = { println("$name -> success $it") },
        onFailure = { println("$name -> failure ${it.message}") },
    )
}

suspend fun recovering(): String = try {
    failLater()
} catch (e: IllegalStateException) {
    "recovered from ${e.message}"
} finally {
    println("  finally in recovering")
}

class Counter {
    var count = 0

    suspend fun tick(): Int {
        count += immediate(1) / 2
        return count
    }
}

suspend fun loopAndWhen(n: Int): List<String> {
    val out = mutableListOf<String>()
    for (i in 1..n) {
        val doubled = immediate(i)
        out += when {
            doubled % 4 == 0 -> "four:$doubled"
            else -> "other:$doubled"
        }
    }
    listOf(10, 20).forEach { out += "each:${immediate(it)}" }
    return out
}

fun main() {
    println("-- start and resume")
    val block: suspend () -> Int = { sum() }
    block.startCoroutine(Printer("sum"))
    println("main: coroutine is parked")
    val cont = parked!!
    parked = null
    cont.resume(5)
    println("main: after resume")

    println("-- resume twice")
    try {
        cont.resume(6)
    } catch (e: IllegalStateException) {
        println("caught: ${e.message}")
    }

    println("-- exceptions")
    suspend { failLater() }.startCoroutine(completion("failLater"))
    suspend { recovering() }.startCoroutine(completion("recovering"))
    suspend {
        awaitValue("thrower")
        throw IllegalArgumentException("thrown after resume")
    }.startCoroutine(completion<Nothing>("thrower"))
    parked!!.resume(1)
    suspend { awaitValue("rejected") }.startCoroutine(completion("rejected"))
    parked!!.resumeWithException(RuntimeException("rejected by main"))

    println("-- createCoroutine")
    val created = suspend {
        println("  created coroutine runs")
        42
    }.createCoroutine(completion("created"))
    println("not started yet")
    created.resume(Unit)
    try {
        created.resume(Unit)
    } catch (e: IllegalStateException) {
        println("caught: ${e.message}")
    }

    println("-- receivers, members and loops")
    val counter = Counter()
    val withReceiver: suspend Counter.() -> Int = { tick() + tick() }
    withReceiver.startCoroutine(counter, completion("receiver"))
    println("count = ${counter.count}")
    suspend { loopAndWhen(3) }.startCoroutine(completion("loops"))
    suspend { EmptyCoroutineContext.toString() }.startCoroutine(completion("context"))
    ::sumOfImmediates.startCoroutine(completion("reference"))

    nested()

    println("-- Result")
    val ok: Result<Int> = Result.success(3)
    val bad: Result<Int> = Result.failure(IllegalStateException("nope"))
    println("$ok $bad")
    println("${ok.isSuccess} ${ok.isFailure} ${bad.isSuccess} ${bad.isFailure}")
    println("${ok.getOrNull()} ${bad.getOrNull()} ${bad.exceptionOrNull()?.message}")
    println("${ok.getOrDefault(0)} ${bad.getOrDefault(0)} ${bad.getOrElse { -1 }}")
    println(ok.map { it * 10 })
    println(bad.recover { 7 }.getOrThrow())
    ok.onSuccess { println("onSuccess $it") }.onFailure { println("not called") }
    bad.onFailure { println("onFailure ${it.message}") }
    println(runCatching { "fine".length })
    println(runCatching { error("broken") }.exceptionOrNull())
    println(ok == Result.success(3))
    try {
        bad.getOrThrow()
    } catch (e: IllegalStateException) {
        println("getOrThrow threw ${e.message}")
    }
}

suspend fun sumOfImmediates(): Int = immediate(1) + immediate(2)

suspend fun twice(f: suspend (Int) -> Int): Int = f(1) + f(2)

suspend fun String.shout(): String = immediate(length).toString() + "!"

interface Source {
    suspend fun next(): Int
}

class Parked : Source {
    var waiting: Continuation<Int>? = null

    override suspend fun next(): Int = suspendCoroutine { waiting = it }
}

fun nested() {
    println("-- nested coroutines")
    val source = Parked()
    suspend {
        println("  outer: starting inner")
        suspend {
            println("  inner: waiting")
            val v = source.next()
            println("  inner: got $v")
            v * 100
        }.startCoroutine(completion("inner"))
        println("  outer: inner is parked, resuming it from here")
        source.waiting!!.resume(immediate(3))
        println("  outer: back")
        "outer done"
    }.startCoroutine(completion("outer"))

    suspend { twice { immediate(it) + 1 } }.startCoroutine(completion("twice"))
    suspend { "hey".shout() }.startCoroutine(completion("extension"))
    suspend { coroutineContext.toString() }.startCoroutine(completion("coroutineContext"))
    val caught = Parked()
    suspend {
        val r = runCatching {
            println("  runCatching: waiting")
            caught.next()
        }
        println("  runCatching: $r")
        r.getOrThrow()
    }.startCoroutine(completion("runCatching"))
    caught.waiting!!.resumeWithException(IllegalArgumentException("late failure"))
}
