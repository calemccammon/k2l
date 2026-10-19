package sim

// A cooperative "async" simulation without coroutines libraries: tasks are `sequence { yield }` generators that a
// round-robin scheduler steps; they wait on timers and channels and report through callbacks.

sealed class Effect {
    data class Sleep(val ticks: Int) : Effect()
    data class Send(val channel: String, val value: Int) : Effect()
    data class Receive(val channel: String) : Effect()
    object Yield : Effect() {
        override fun toString() = "Yield"
    }
}

class Mailbox {
    private val queues = mutableMapOf<String, ArrayDeque<Int>>()
    fun offer(channel: String, value: Int) = queues.getOrPut(channel) { ArrayDeque() }.addLast(value)
    fun poll(channel: String): Int? = queues[channel]?.removeFirstOrNull()
    fun pending() = queues.filterValues { it.isNotEmpty() }.mapValues { it.value.toList() }
}

class Task(val name: String, private val body: suspend SequenceScope<Effect>.(TaskContext) -> Unit) {
    lateinit var iterator: Iterator<Effect>
    var wakeAt = 0
    var waitingOn: String? = null
    var received: Int? = null
    var finished = false
    var steps = 0

    fun start(ctx: TaskContext) {
        iterator = sequence { body(ctx) }.iterator()
    }

    override fun toString() = "$name(${if (finished) "done" else "steps=$steps"})"
}

class TaskContext(private val scheduler: Scheduler, private val task: Task) {
    val now get() = scheduler.clock
    fun log(msg: String) = scheduler.log("[t=${scheduler.clock}] ${task.name}: $msg")
    fun lastReceived(): Int = task.received ?: error("${task.name} has received nothing")
}

class Scheduler(private val maxTicks: Int = 100) {
    var clock = 0
        private set
    private val tasks = mutableListOf<Task>()
    private val mailbox = Mailbox()
    private val output = mutableListOf<String>()
    private val listeners = mutableListOf<(Task) -> Unit>()

    fun log(line: String) {
        output += line
    }

    fun onFinish(listener: (Task) -> Unit) {
        listeners += listener
    }

    fun spawn(name: String, body: suspend SequenceScope<Effect>.(TaskContext) -> Unit): Task =
        Task(name, body).also {
            it.start(TaskContext(this, it))
            tasks += it
        }

    private fun runnable(t: Task): Boolean = when {
        t.finished -> false
        t.wakeAt > clock -> false
        t.waitingOn != null -> {
            val value = mailbox.poll(t.waitingOn!!)
            if (value != null) {
                t.received = value
                t.waitingOn = null
                true
            } else {
                false
            }
        }
        else -> true
    }

    private fun step(t: Task) {
        if (!t.iterator.hasNext()) {
            t.finished = true
            listeners.forEach { it(t) }
            return
        }
        t.steps++
        when (val effect = t.iterator.next()) {
            is Effect.Sleep -> t.wakeAt = clock + effect.ticks
            is Effect.Send -> mailbox.offer(effect.channel, effect.value)
            is Effect.Receive -> t.waitingOn = effect.channel
            Effect.Yield -> Unit
        }
    }

    fun run(): List<String> {
        while (clock < maxTicks && tasks.any { !it.finished }) {
            val ready = tasks.filter(::runnable)
            ready.forEach(::step)
            if (ready.isEmpty()) {
                val next = tasks.filter { !it.finished && it.waitingOn == null }.minOfOrNull { it.wakeAt }
                if (next == null) {
                    log("deadlock at t=$clock: ${tasks.filter { !it.finished }.map { "${it.name} waits on ${it.waitingOn}" }}")
                    break
                }
                clock = maxOf(clock + 1, next)
            }
        }
        log("pending messages: ${mailbox.pending()}")
        return output
    }

    val summary get() = tasks.joinToString()
}

// Plain generators used by the tasks.
fun fibonacci() = sequence {
    var (a, b) = 0L to 1L
    while (true) {
        yield(a)
        val next = a + b
        a = b
        b = next
    }
}

fun primes(): Sequence<Int> = sequence {
    val found = mutableListOf<Int>()
    var n = 2
    while (true) {
        if (found.none { n % it == 0 }) {
            found += n
            yield(n)
        }
        n++
    }
}

fun <T> Sequence<T>.chunkedBy(size: Int): Sequence<List<T>> = sequence {
    val buffer = ArrayList<T>(size)
    for (item in this@chunkedBy) {
        buffer += item
        if (buffer.size == size) {
            yield(buffer.toList())
            buffer.clear()
        }
    }
    if (buffer.isNotEmpty()) yield(buffer)
}

fun tree(depth: Int, prefix: String = "r"): Sequence<String> = sequence {
    yield(prefix)
    if (depth > 0) {
        yieldAll(tree(depth - 1, "${prefix}L"))
        yieldAll(tree(depth - 1, "${prefix}R"))
    }
}

fun main() {
    println(fibonacci().take(12).toList())
    println(primes().takeWhile { it < 40 }.joinToString(" "))
    println(primes().map { it * it }.filter { it % 10 == 9 }.take(4).toList())
    println((1..10).asSequence().chunkedBy(4).toList())
    println(tree(2).toList())
    val lazyLog = mutableListOf<String>()
    val pipeline = generateSequence(1) { it * 3 }.onEach { lazyLog += "gen $it" }.map { it - 1 }.filter { it % 2 == 0 }
    println("${pipeline.first { it > 20 }} after ${lazyLog.size} steps")

    val scheduler = Scheduler()
    val finished = mutableListOf<String>()
    scheduler.onFinish { finished += it.name }
    scheduler.spawn("producer") { ctx ->
        for (x in fibonacci().drop(3).take(4)) {
            ctx.log("send $x")
            yield(Effect.Send("numbers", x.toInt()))
            yield(Effect.Sleep(2))
        }
        yield(Effect.Send("numbers", -1))
        ctx.log("done producing")
    }
    scheduler.spawn("consumer") { ctx ->
        var total = 0
        while (true) {
            yield(Effect.Receive("numbers"))
            val v = ctx.lastReceived()
            if (v < 0) break
            total += v
            ctx.log("got $v, total $total")
            if (total > 6) yield(Effect.Send("report", total))
        }
        ctx.log("consumer finished with $total")
    }
    scheduler.spawn("ticker") { ctx ->
        repeat(3) {
            yield(Effect.Sleep(3))
            ctx.log("tick ${it + 1}")
        }
    }
    scheduler.spawn("waiter") { ctx ->
        yield(Effect.Yield)
        yield(Effect.Receive("never"))
        ctx.log("unreachable")
    }
    scheduler.run().forEach(::println)
    println("finished: $finished")
    println(scheduler.summary)

    val failing = Scheduler(5)
    failing.spawn("broken") { ctx ->
        yield(Effect.Yield)
        ctx.log("about to fail")
        ctx.lastReceived()
    }
    try {
        failing.run()
    } catch (e: IllegalStateException) {
        println("caught: ${e.message}")
    }
}
