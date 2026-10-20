// A TCP-like connection state machine driven by event scripts, plus a vending machine with credit and stock:
// enum states with per-state behavior, sealed events, guarded `when` branches, transition history, timers and
// errors for invalid transitions.
import java.util.EnumMap
import java.util.EnumSet

enum class State(val canSend: Boolean = false) {
    CLOSED, LISTEN, SYN_SENT, SYN_RECEIVED, ESTABLISHED(canSend = true), FIN_WAIT_1, FIN_WAIT_2, CLOSE_WAIT(canSend = true),
    CLOSING, LAST_ACK, TIME_WAIT;

    val isTerminal get() = this == CLOSED || this == TIME_WAIT
}

sealed interface Event {
    data object PassiveOpen : Event
    data object ActiveOpen : Event
    data object Syn : Event
    data object SynAck : Event
    data object Ack : Event
    data object Fin : Event
    data object Close : Event
    data class Send(val bytes: Int) : Event
    data class Tick(val ms: Int) : Event
    data object Reset : Event
}

class InvalidTransition(val from: State, val event: Event) : IllegalStateException("no transition from $from on $event")

data class Step(val from: State, val event: Event, val to: State)

class Connection(val name: String) {
    var state = State.CLOSED
        private set
    val history = mutableListOf<Step>()
    private val visits = EnumMap<State, Int>(State::class.java)
    private var timeWaitMs = 0
    var sent = 0
        private set

    init { visits[State.CLOSED] = 1 }

    fun fire(event: Event) {
        val next = next(event)
        history += Step(state, event, next)
        if (next != state) visits.merge(next, 1, Int::plus)
        if (next == State.TIME_WAIT && state != State.TIME_WAIT) timeWaitMs = 0
        state = next
    }

    private fun next(e: Event): State = when (e) {
        Event.Reset -> State.CLOSED
        is Event.Send if state.canSend -> state.also { sent += e.bytes }
        is Event.Send -> throw InvalidTransition(state, e)
        is Event.Tick if state == State.TIME_WAIT -> {
            timeWaitMs += e.ms
            if (timeWaitMs >= 2 * MSL) State.CLOSED else State.TIME_WAIT
        }
        is Event.Tick -> state
        else -> table[state]?.get(e) ?: throw InvalidTransition(state, e)
    }

    fun visited(): Set<State> = EnumSet.copyOf(visits.keys)

    fun visitCounts(): Map<State, Int> = visits

    companion object {
        const val MSL = 30
        private val table: Map<State, Map<Event, State>> = mapOf(
            State.CLOSED to mapOf(Event.PassiveOpen to State.LISTEN, Event.ActiveOpen to State.SYN_SENT),
            State.LISTEN to mapOf(Event.Syn to State.SYN_RECEIVED, Event.Close to State.CLOSED),
            State.SYN_SENT to mapOf(Event.SynAck to State.ESTABLISHED, Event.Close to State.CLOSED),
            State.SYN_RECEIVED to mapOf(Event.Ack to State.ESTABLISHED, Event.Close to State.FIN_WAIT_1),
            State.ESTABLISHED to mapOf(Event.Close to State.FIN_WAIT_1, Event.Fin to State.CLOSE_WAIT),
            State.FIN_WAIT_1 to mapOf(Event.Ack to State.FIN_WAIT_2, Event.Fin to State.CLOSING),
            State.FIN_WAIT_2 to mapOf(Event.Fin to State.TIME_WAIT),
            State.CLOSING to mapOf(Event.Ack to State.TIME_WAIT),
            State.CLOSE_WAIT to mapOf(Event.Close to State.LAST_ACK),
            State.LAST_ACK to mapOf(Event.Ack to State.CLOSED),
        )
    }
}

fun parseEvents(script: String): List<Event> = script.split(',').map { it.trim() }.filter { it.isNotEmpty() }.map { tok ->
    val name = tok.substringBefore('(')
    val arg = tok.substringAfter('(', "").removeSuffix(")")
    when (name.lowercase()) {
        "listen" -> Event.PassiveOpen
        "open" -> Event.ActiveOpen
        "syn" -> Event.Syn
        "synack" -> Event.SynAck
        "ack" -> Event.Ack
        "fin" -> Event.Fin
        "close" -> Event.Close
        "rst" -> Event.Reset
        "send" -> Event.Send(arg.toInt())
        "tick" -> Event.Tick(arg.toIntOrNull() ?: throw IllegalArgumentException("tick needs a number, got '$arg'"))
        else -> throw IllegalArgumentException("unknown event '$tok'")
    }
}

fun runConnection(name: String, script: String) {
    val c = Connection(name)
    try {
        for (e in parseEvents(script)) c.fire(e)
        println("$name: ended in ${c.state}${if (c.state.isTerminal) " (terminal)" else ""}, sent ${c.sent} bytes")
    } catch (e: InvalidTransition) {
        println("$name: ${e.message}; last good state ${e.from} after ${c.history.size} steps")
    } catch (e: IllegalArgumentException) {
        println("$name: bad script: ${e.message}")
    }
    val path = c.history.filter { it.from != it.to }.joinToString(" -> ", prefix = "  path: CLOSED -> ") { it.to.name }
    if (c.history.any { it.from != it.to }) println(path)
    println("  visited ${c.visited()} counts ${c.visitCounts()}")
}

enum class Coin(val cents: Int) { NICKEL(5), DIME(10), QUARTER(25), DOLLAR(100) }

class VendingMachine(stock: Map<String, Pair<Int, Int>>) {
    private val prices = stock.mapValues { it.value.first }
    private val counts = stock.mapValues { it.value.second }.toMutableMap()
    private var credit = 0
    val log = StringBuilder()

    sealed class Mode {
        object Idle : Mode() { override fun toString() = "Idle" }
        data class HasCredit(val cents: Int) : Mode()
        data class SoldOut(val item: String) : Mode()
    }

    var mode: Mode = Mode.Idle
        private set

    fun insert(c: Coin) {
        credit += c.cents
        mode = Mode.HasCredit(credit)
        log.append("+${c.name.lowercase()} ")
    }

    fun select(item: String): String {
        val price = prices[item] ?: return "unknown item '$item'"
        val left = counts.getValue(item)
        return when {
            left == 0 -> { mode = Mode.SoldOut(item); "$item sold out" }
            credit < price -> "insert ${price - credit}c more for $item"
            else -> {
                counts[item] = left - 1
                val change = makeChange(credit - price)
                credit = 0
                mode = Mode.Idle
                log.append("[$item] ")
                "vend $item, change ${if (change.isEmpty()) "none" else change.entries.joinToString { "${it.value}x${it.key}" }}"
            }
        }
    }

    private fun makeChange(amount: Int): Map<Coin, Int> {
        var rest = amount
        val out = linkedMapOf<Coin, Int>()
        for (coin in Coin.entries.reversed().filter { it != Coin.DOLLAR }) {
            val n = rest / coin.cents
            if (n > 0) { out[coin] = n; rest -= n * coin.cents }
        }
        check(rest == 0) { "cannot make change for $amount" }
        return out
    }

    fun refund(): Int = credit.also { credit = 0; mode = Mode.Idle }
}

fun main() {
    runConnection("client", "open, synack, send(512), send(1024), close, ack, fin, tick(30), tick(29), tick(1)")
    runConnection("server", "listen, syn, ack, send(64), fin, send(8), close, ack")
    runConnection("simultaneous", "open, synack, close, fin, ack, tick(100)")
    runConnection("early-send", "listen, send(10)")
    runConnection("bad-ack", "open, ack")
    runConnection("reset", "open, synack, rst, listen, close")
    runConnection("typo", "open, synak")
    runConnection("tick", "open, tick(soon)")

    println(State.valueOf("LISTEN").ordinal to State.entries.count { it.canSend })
    println(runCatching { State.valueOf("OPEN") }.exceptionOrNull()?.javaClass?.simpleName)
    val byPrefix = State.entries.groupBy { it.name.substringBefore('_') }.filterValues { it.size > 1 }
    println(byPrefix)

    val vm = VendingMachine(mapOf("cola" to (125 to 2), "chips" to (65 to 1), "gum" to (35 to 0)))
    val actions = listOf("Q", "Q", "cola", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "cola", "gum", "chips",
        "$", "N", "chips", "chips", "Q", "nachos", "refund")
    for (a in actions) {
        val result = when (a) {
            "Q" -> { vm.insert(Coin.QUARTER); null }
            "D" -> { vm.insert(Coin.DIME); null }
            "N" -> { vm.insert(Coin.NICKEL); null }
            "$" -> { vm.insert(Coin.DOLLAR); null }
            "refund" -> "refunded ${vm.refund()}c"
            else -> vm.select(a)
        }
        if (result != null) println("$a -> $result  [${vm.mode}]")
    }
    println(vm.log.toString().trimEnd())
}
