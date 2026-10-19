// Guard conditions in `when` (`is Int if x < 0 ->`, `else if ... ->`): the guard is checked only after the conditions
// matched, with their smart casts, and a failing guard moves on to the next branch.

sealed interface Event {
    data class Click(val x: Int, val y: Int) : Event
    data class Key(val code: Char, val shift: Boolean) : Event
    data object Tick : Event
}

var guardCalls = 0

fun big(n: Int): Boolean {
    guardCalls++
    return n > 100
}

fun classify(x: Any?): String = when (x) {
    null -> "null"
    is Int if x < 0 -> "negative"
    is Int if big(x) -> "big"
    is Int -> when (x) {
        0 -> "zero"
        in 1..9 -> "digit"
        else -> "int"
    }
    is String if x.isEmpty() -> "empty"
    is String if x.first().isUpperCase() -> "capitalized"
    is String -> "text"
    else if x is List<*> -> "list of ${x.size}"
    else -> "other"
}

fun describe(e: Event, debug: Boolean) = when (e) {
    is Event.Click if e.x == e.y -> "diagonal click at ${e.x}"
    is Event.Click -> "click (${e.x}, ${e.y})"
    is Event.Key if e.shift && e.code.isLetter() -> "key ${e.code.uppercaseChar()}"
    is Event.Key -> "key ${e.code}"
    Event.Tick if debug -> "tick (debug)"
    Event.Tick -> "tick"
}

fun main() {
    println(listOf(-3, 0, 7, 42, 500, "", "Hello", "hey", listOf(1, 2), 2.5, null).map(::classify))
    println("guard calls: $guardCalls")
    val events = listOf(Event.Click(3, 3), Event.Click(1, 2), Event.Key('a', true), Event.Key('1', true), Event.Key('b', false), Event.Tick)
    println(events.map { describe(it, debug = false) })
    println(describe(Event.Tick, debug = true))
    val n = 15
    val fizz = when (n % 15) {
        0 -> "FizzBuzz"
        else if n % 3 == 0 -> "Fizz"
        else -> n.toString()
    }
    println(fizz)
}
