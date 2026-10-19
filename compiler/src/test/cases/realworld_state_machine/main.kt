package machine

// An order workflow: enum states with abstract methods, sealed events, observers, an event bus and registries.

sealed interface Event {
    val orderId: Int

    data class Placed(override val orderId: Int, val amount: Double) : Event
    data class Paid(override val orderId: Int, val amount: Double) : Event
    data class Shipped(override val orderId: Int, val carrier: String) : Event
    data class Cancelled(override val orderId: Int, val reason: String) : Event
    data class Delivered(override val orderId: Int) : Event
}

enum class OrderState(val terminal: Boolean = false) {
    NEW {
        override fun next(event: Event) = when (event) {
            is Event.Paid -> PAID
            is Event.Cancelled -> CANCELLED
            else -> null
        }
    },
    PAID {
        override fun next(event: Event) = when (event) {
            is Event.Shipped -> SHIPPED
            is Event.Cancelled -> REFUNDED
            else -> null
        }
    },
    SHIPPED {
        override fun next(event: Event): OrderState? = if (event is Event.Delivered) DELIVERED else null
    },
    DELIVERED(terminal = true) {
        override fun next(event: Event): OrderState? = null
    },
    CANCELLED(true) {
        override fun next(event: Event): OrderState? = null
    },
    REFUNDED(true) {
        override fun next(event: Event): OrderState? = null
        override val label get() = "refunded (money back)"
    },
    ;

    abstract fun next(event: Event): OrderState?

    open val label: String get() = name.lowercase().replaceFirstChar { it.uppercase() }
}

fun interface Listener<in E : Event> {
    fun onEvent(event: E)
}

class IllegalTransition(val state: OrderState, val event: Event) :
    IllegalStateException("cannot apply ${event::class.simpleName} in state $state")

class EventBus {
    private val listeners = mutableMapOf<String, MutableList<Listener<Event>>>()
    private val history = ArrayDeque<Event>()
    var dispatched = 0
        private set

    fun subscribe(topic: String, listener: Listener<Event>): () -> Unit {
        listeners.getOrPut(topic) { mutableListOf() } += listener
        return { listeners[topic]?.remove(listener) }
    }

    inline fun <reified E : Event> on(crossinline handler: (E) -> Unit) =
        subscribe("*", Listener { if (it is E) handler(it) })

    fun publish(event: Event) {
        dispatched++
        history.addLast(event)
        if (history.size > 4) history.removeFirst()
        val topic = event::class.simpleName ?: "?"
        (listeners[topic].orEmpty() + listeners["*"].orEmpty()).forEach { it.onEvent(event) }
    }

    fun recent(): List<Event> = history.toList()
}

class Order private constructor(val id: Int, val amount: Double) {
    var state: OrderState = OrderState.NEW
        private set(value) {
            transitions += "${field.name}->${value.name}"
            field = value
        }
    val transitions = mutableListOf<String>()

    fun apply(event: Event) {
        require(event.orderId == id) { "event for order ${event.orderId} sent to order $id" }
        check(!state.terminal) { "order $id is closed (${state.label})" }
        state = state.next(event) ?: throw IllegalTransition(state, event)
    }

    override fun toString() = "Order#$id[$state, ${"%.2f".format(amount)}]"

    companion object Factory {
        private var nextId = 100
        fun create(amount: Double): Order = Order(nextId++, amount)
        val issued: Int get() = nextId - 100
    }
}

object OrderRegistry {
    private val orders = linkedMapOf<Int, Order>()
    val size get() = orders.size

    operator fun get(id: Int): Order = orders[id] ?: throw NoSuchElementException("no order $id")
    operator fun plusAssign(order: Order) {
        orders[order.id] = order
    }

    fun byState(): Map<OrderState, List<Int>> = orders.values.groupBy({ it.state }, { it.id }).toSortedMap()
}

interface Metrics {
    fun count(name: String)
    fun report(): String
}

class Processor(private val bus: EventBus, metrics: Metrics) : Metrics by metrics {
    private val failures = mutableListOf<String>()

    init {
        bus.on<Event.Placed> { e ->
            val order = Order.create(e.amount)
            OrderRegistry += order
            count("placed")
        }
    }

    fun handle(event: Event) {
        bus.publish(event)
        if (event is Event.Placed) return
        try {
            OrderRegistry[event.orderId].apply(event)
            count(event::class.simpleName!!.lowercase())
        } catch (e: IllegalTransition) {
            failures += "transition: ${e.message} (from ${e.state.label})"
        } catch (e: IllegalStateException) {
            failures += "state: ${e.message}"
        } catch (e: IllegalArgumentException) {
            failures += "argument: ${e.message}"
        } catch (e: NoSuchElementException) {
            failures += "lookup: ${e.message}"
        }
    }

    fun failures(): List<String> = failures
}

fun main() {
    val bus = EventBus()
    val log = mutableListOf<String>()
    val counts = sortedMapOf<String, Int>()
    val metrics = object : Metrics {
        override fun count(name: String) {
            counts.merge(name, 1, Int::plus)
        }

        override fun report() = counts.entries.joinToString(", ") { "${it.key}=${it.value}" }
    }
    val processor = Processor(bus, metrics)
    val unsubscribe = bus.subscribe("Paid") { log += "paid ${it.orderId}" }
    bus.on<Event.Shipped> { log += "shipped ${it.orderId} via ${it.carrier}" }
    var cancellations = 0
    bus.subscribe("Cancelled", object : Listener<Event> {
        override fun onEvent(event: Event) {
            cancellations++
            log += "cancelled #$cancellations: ${(event as Event.Cancelled).reason}"
        }
    })

    val script = listOf(
        Event.Placed(0, 25.0),
        Event.Placed(0, 99.5),
        Event.Placed(0, 7.25),
        Event.Paid(100, 25.0),
        Event.Shipped(100, "UPS"),
        Event.Delivered(100),
        Event.Paid(101, 99.5),
        Event.Cancelled(101, "changed mind"),
        Event.Delivered(102),
        Event.Cancelled(102, "out of stock"),
        Event.Paid(102, 7.25),
        Event.Paid(999, 1.0),
    )
    for ((step, event) in script.withIndex()) {
        if (step == 7) unsubscribe()
        processor.handle(event)
    }

    log.forEach(::println)
    processor.failures().forEach { println("! $it") }
    println(processor.report())
    for (id in 100..102) {
        val order = OrderRegistry[id]
        println("$order ${order.state.label}: ${order.transitions.joinToString(" ")}")
    }
    println(OrderRegistry.byState())
    println("issued=${Order.issued} registry=${OrderRegistry.size} dispatched=${bus.dispatched}")
    println(bus.recent().map { it::class.simpleName })
    println(OrderState.entries.filter { it.terminal }.joinToString { it.label })
    println(OrderState.valueOf("PAID").next(Event.Shipped(1, "DHL")))
    val sameEvents = setOf(Event.Paid(1, 2.0), Event.Paid(1, 2.0), Event.Delivered(1))
    println(sameEvents.size)
    val describe: (Event) -> String = { e ->
        when (e) {
            is Event.Placed, is Event.Paid -> "money"
            is Event.Shipped -> "carrier ${e.carrier}"
            else -> "other"
        }
    }
    println(script.take(5).map(describe).distinct())
}
