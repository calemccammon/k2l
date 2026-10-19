package toolkit

import kotlin.reflect.KClass

// A grab bag of utilities from a real code base: validation, retry with backoff, timing, resource scopes, a tiny
// state machine, all leaning on inline functions, reified types, closures and labeled returns.

class ValidationException(val field: String, message: String) : IllegalArgumentException("$field: $message")

/** Collects all failures instead of stopping at the first. */
class Validator<T>(private val subject: T) {
    private val errors = mutableListOf<String>()

    inline fun check(field: String, condition: (T) -> Boolean, crossinline message: () -> String): Validator<T> {
        if (!condition(subjectValue())) fail(field) { message() }
        return this
    }

    @PublishedApi
    internal fun subjectValue(): T = subject

    fun fail(field: String, message: () -> String) {
        errors += "$field ${message()}"
    }

    fun result(): List<String> = errors
}

inline fun <T> validate(subject: T, block: Validator<T>.() -> Unit): List<String> = Validator(subject).apply(block).result()

/** Retries [block] on the given exception type, with exponential backoff recorded in [delays]. */
inline fun <reified E : Throwable, R> retry(times: Int, delays: MutableList<Int>, block: (attempt: Int) -> R): R {
    var delay = 10
    repeat(times - 1) { attempt ->
        try {
            return block(attempt + 1)
        } catch (e: Throwable) {
            if (e !is E) throw e
            delays += delay
            delay *= 2
        }
    }
    return block(times)
}

/** Measures in fake ticks so output is deterministic. */
object Clock {
    var now = 0L
        private set

    fun advance(by: Long) {
        now += by
    }
}

inline fun <R> timed(label: String, log: MutableList<String>, block: () -> R): R {
    val start = Clock.now
    try {
        return block()
    } finally {
        log += "$label took ${Clock.now - start}"
    }
}

/** A scope that closes registered resources in reverse order, like `use` for several. */
class ResourceScope {
    private val closers = ArrayDeque<() -> Unit>()

    fun <T> T.closeWith(closer: (T) -> Unit): T = also { closers.addFirst { closer(it) } }

    fun closeAll(): List<String> {
        val failures = mutableListOf<String>()
        while (closers.isNotEmpty()) {
            try {
                closers.removeFirst()()
            } catch (e: IllegalStateException) {
                failures += e.message ?: "?"
            }
        }
        return failures
    }
}

inline fun <R> resourceScope(block: ResourceScope.() -> R): Pair<R, List<String>> {
    val scope = ResourceScope()
    val result = try {
        scope.block()
    } catch (e: Exception) {
        scope.closeAll()
        throw e
    }
    return result to scope.closeAll()
}

inline fun <reified T> List<Any?>.firstOfType(): T? {
    for (x in this) if (x is T) return x
    return null
}

inline fun <reified T : Any> typeName(): String = T::class.simpleName ?: "anonymous"

inline fun <reified T : Any> Map<KClass<*>, Any>.lookup(): T? = this[T::class] as? T

/** A vararg inline function with a reified type: the spread may come before other arguments. */
inline fun <reified T> countOf(vararg items: Any?): Int = items.count { it is T }

inline fun <reified T> joinTyped(separator: String, vararg items: Any?, last: String = "."): String =
    items.filterIsInstance<T>().joinToString(separator) + last

fun fatal(message: String): Nothing = throw IllegalStateException("fatal: $message")

class Machine(private val name: String) {
    enum class State { IDLE, RUNNING, PAUSED, STOPPED }

    var state = State.IDLE
        private set
    private val transitions = mutableListOf<String>()

    inner class Transition(private val from: Set<State>, private val to: State) {
        fun fire(): Boolean {
            if (state !in from) return false
            transitions += "${this@Machine.name}: $state -> $to"
            state = to
            return true
        }
    }

    val start = Transition(setOf(State.IDLE, State.PAUSED), State.RUNNING)
    val pause = Transition(setOf(State.RUNNING), State.PAUSED)
    val stop = Transition(State.values().toSet() - State.STOPPED, State.STOPPED)

    fun history() = transitions.toList()
}

fun findIndex(grid: List<List<Int>>, target: Int): Pair<Int, Int>? {
    grid.forEachIndexed { r, row ->
        row.forEachIndexed { c, v -> if (v == target) return r to c }
    }
    return null
}

fun firstNegativeSums(rows: List<List<Int>>): List<Int> = rows.map { row ->
    var sum = 0
    row.forEach {
        if (it < 0) return@map sum
        sum += it
    }
    sum
}

fun makeCounters(): List<() -> Int> {
    val counters = mutableListOf<() -> Int>()
    var shared = 0
    for (i in 1..3) {
        var own = i * 10
        counters += {
            shared++
            own += i
            own + shared
        }
    }
    return counters
}

fun fib(n: Int): Long {
    val memo = HashMap<Int, Long>()
    fun go(k: Int): Long = if (k < 2) k.toLong() else memo.getOrPut(k) { go(k - 1) + go(k - 2) }
    return go(n)
}

fun main() {
    data class User(val name: String, val age: Int, val email: String)

    val users = listOf(User("ada", 36, "ada@example.com"), User("", -1, "nope"), User("bob", 17, "bob@example"))
    for (u in users) {
        val problems = validate(u) {
            check("name", { it.name.isNotBlank() }) { "must not be blank" }
            check("age", { it.age >= 0 }) { "must be positive, was ${u.age}" }
            check("age", { it.age >= 18 }) { "must be an adult" }
            check("email", { '@' in it.email && it.email.substringAfter('@').contains('.') }) { "is invalid: ${u.email}" }
        }
        println("${u.name.ifEmpty { "<anon>" }}: ${if (problems.isEmpty()) "ok" else problems.joinToString("; ")}")
    }

    val delays = mutableListOf<Int>()
    var calls = 0
    val value = retry<IllegalStateException, String>(4, delays) { attempt ->
        calls++
        if (attempt < 3) throw IllegalStateException("flaky $attempt")
        "succeeded on $attempt"
    }
    println("$value after $calls calls, delays $delays")
    try {
        retry<IllegalStateException, Unit>(3, delays) { throw IllegalArgumentException("not retried") }
    } catch (e: IllegalArgumentException) {
        println("gave up: ${e.message}, delays $delays")
    }

    val log = mutableListOf<String>()
    val total = timed("sum", log) {
        Clock.advance(5)
        (1..10).sum()
    }
    fun earlyExit(): String {
        timed("early", log) {
            Clock.advance(3)
            return "left early"
        }
    }
    println("$total ${earlyExit()} $log")

    val (opened, failures) = resourceScope {
        val a = "db".closeWith { log += "closed $it" }
        val b = "cache".closeWith { error("cache refused to close") }
        val c = 42.closeWith { log += "closed #$it" }
        listOf(a, b, c)
    }
    println("opened $opened, close failures $failures, log ${log.drop(2)}")

    val mixed = listOf(1, "two", true, null, listOf(5))
    println("${mixed.firstOfType<String>()} ${mixed.firstOfType<Boolean>()} ${mixed.firstOfType<List<*>>()} ${mixed.firstOfType<Map<*, *>>()}")
    println("${typeName<User>()} ${typeName<Machine.State>()} ${typeName<Machine.Transition>()}")
    val registry: Map<KClass<*>, Any> = mapOf(String::class to "text", Int::class to 7)
    println("${registry.lookup<String>()} ${registry.lookup<Int>()} ${registry.lookup<Machine>()}")
    val extra = arrayOf<Any?>(4, "five", 6)
    println(countOf<Int>(1, "x", *extra, 2))
    println(countOf<String>(*extra, "y", *extra))
    println(joinTyped<String>(", ", "a", 1, *extra, "z", last = "!"))
    println(joinTyped<Int>("+", *extra, 10))

    val m = Machine("pump")
    println("${m.start.fire()} ${m.start.fire()} ${m.pause.fire()} ${m.start.fire()} ${m.stop.fire()} ${m.pause.fire()} ${m.state}")
    m.history().forEach { println("  $it") }

    val grid = listOf(listOf(1, 2, 3), listOf(4, 5, 6))
    println("${findIndex(grid, 5)} ${findIndex(grid, 9)} ${firstNegativeSums(listOf(listOf(1, 2, -1, 5), listOf(3, 4), listOf(-2)))}")
    val counters = makeCounters()
    println(List(2) { counters.map { it() } })
    println("fib(60) = ${fib(60)}")
    val outcome = runCatching { fatal("disk full") }
    println("${outcome.isFailure} ${outcome.exceptionOrNull()?.message}")
    val lazyTodo = runCatching<Int> { TODO("parse config") }
    println(lazyTodo.exceptionOrNull()?.let { "${it::class.simpleName}: ${it.message}" })
    try {
        require(users.size > 5) { "need more than 5 users, got ${users.size}" }
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    val e = ValidationException("age", "too low")
    println("${e.field} ${e.message} ${e is IllegalArgumentException}")
}
