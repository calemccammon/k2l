package state

// Internal declarations that other files use: fields of the module table, not globals.
internal class State(val count: Int, val log: List<String>) {
    internal operator fun plus(step: Int) = State(count + step, log + "+$step")
}

internal sealed interface Effect {
    class Say(val text: String) : Effect

    object Beep : Effect
}

internal fun interface Listener {
    fun changed(state: State)
}

internal var ticks = 0

internal val defaults = listOf("a", "b")

internal const val START = 1

internal val summary: String get() = "ticks=$ticks"

internal fun State.describe() = "count=$count log=$log"

internal inline fun traced(block: () -> Unit) {
    trace("before")
    block()
    trace("after")
}

// Only used here, but by an inline function other files expand: a field of the module table too.
internal fun trace(what: String) = println("trace $what")

// Only this file uses these: locals.
internal fun clampCount(n: Int) = if (n > 9) 9 else n

internal class Cache {
    val seen = mutableListOf<Int>()
}

private val cache = Cache()

// Its initializer runs when the file loads, after the functions and classes.
internal val initial = start()

private fun start(): State {
    cache.seen.add(START)
    return State(clampCount(START), emptyList())
}

internal fun notify(listener: Listener, state: State) {
    ticks++
    listener.changed(state)
}
