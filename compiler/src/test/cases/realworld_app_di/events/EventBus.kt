package app.di.events


sealed interface Event {
    val source: String
}

data class UserCreated(override val source: String, val user: String) : Event
data class UserDeleted(override val source: String, val user: String, val reason: String = "unspecified") : Event
data class OrderPlaced(override val source: String, val orderId: Int, val total: Double) : Event
object Shutdown : Event {
    override val source = "system"
    override fun toString() = "Shutdown"
}

sealed class Delivery {
    data class Delivered(val handlers: Int) : Delivery()
    data class Failed(val errors: List<String>) : Delivery()
    object Dropped : Delivery() {
        override fun toString() = "Dropped"
    }
}

typealias Handler<E> = (E) -> Unit

class Subscription internal constructor(private val onCancel: () -> Unit) {
    var active = true
        private set

    fun cancel() {
        if (active) {
            active = false
            onCancel()
        }
    }
}

class EventBus {
    private val handlers = linkedMapOf<String, MutableList<Handler<Event>>>()
    private val deadLetters = mutableListOf<Event>()
    var published = 0
        private set

    fun <E : Event> subscribe(type: String, handler: Handler<E>): Subscription {
        @Suppress("UNCHECKED_CAST")
        val h = handler as Handler<Event>
        val list = handlers.getOrPut(type) { mutableListOf() }
        list += h
        return Subscription { list.remove(h) }
    }

    inline fun <reified E : Event> on(noinline handler: (E) -> Unit): Subscription = subscribe(E::class.simpleName!!, handler)

    fun publish(event: Event): Delivery {
        published++
        val targets = handlers[event::class.simpleName!!].orEmpty().toList()
        if (targets.isEmpty()) {
            deadLetters += event
            return Delivery.Dropped
        }
        val errors = mutableListOf<String>()
        for (h in targets) {
            try {
                h(event)
            } catch (e: IllegalStateException) {
                errors += "${e::class.simpleName}: ${e.message}"
            }
        }
        return if (errors.isEmpty()) Delivery.Delivered(targets.size) else Delivery.Failed(errors)
    }

    val dead: List<Event> get() = deadLetters

    fun subscriberCounts(): Map<String, Int> = handlers.map { (k, v) -> k to v.size }.toMap()
}

/** Extension in another package: counts how many of a kind of event were dropped. */
inline fun <reified E : Event> EventBus.deadOf(): List<E> = dead.filterIsInstance<E>()
