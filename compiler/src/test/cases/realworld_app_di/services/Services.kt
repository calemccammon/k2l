package app.di.services

import app.di.events.EventBus
import app.di.events.OrderPlaced
import app.di.events.UserCreated
import app.di.events.UserDeleted
import app.di.core.Provider

interface Clock {
    fun now(): Long
}

class FakeClock(private var time: Long = 1_000L) : Clock {
    override fun now(): Long = time.also { time += 15 }
}

interface Logger {
    val prefix: String
    fun info(msg: String)
    fun lines(): List<String>
}

abstract class BufferedLogger : Logger {
    private val buffer = mutableListOf<String>()
    protected abstract fun format(msg: String): String
    override fun info(msg: String) {
        buffer += format(msg)
    }
    override fun lines(): List<String> = buffer
}

class ConsoleLogger(private val clock: Clock, override val prefix: String = "app") : BufferedLogger() {
    override fun format(msg: String) = "[$prefix@${clock.now()}] $msg"
}

class UserRepository(private val logger: Logger) {
    private val users = sortedMapOf<String, Int>()
    private var nextId = 1

    fun add(name: String): Int {
        check(name !in users) { "user $name already exists" }
        val id = nextId++
        users[name] = id
        logger.info("added $name as #$id")
        return id
    }

    fun remove(name: String): Boolean = (users.remove(name) != null).also { logger.info("remove $name -> $it") }

    fun all(): Map<String, Int> = users
}

class UserService(
    private val repo: UserRepository,
    private val bus: EventBus,
    private val ids: Provider<RequestId>,
) {
    fun create(name: String): Int {
        val id = repo.add(name)
        bus.publish(UserCreated("users/${ids.get()}", name))
        return id
    }

    fun delete(name: String, reason: String? = null) {
        if (repo.remove(name)) {
            bus.publish(if (reason == null) UserDeleted("users/${ids.get()}", name) else UserDeleted("users/${ids.get()}", name, reason))
        }
    }
}

class OrderService(private val bus: EventBus, private val logger: Logger) {
    private var next = 100
    fun place(vararg prices: Double): Int {
        require(prices.isNotEmpty()) { "an order needs at least one item" }
        val id = next++
        val total = prices.sum()
        logger.info("order $id: ${prices.size} items")
        bus.publish(OrderPlaced("orders", id, total))
        return id
    }
}

/** A prototype: every request for one gets a fresh id. */
class RequestId private constructor(val value: Int) {
    override fun toString() = "req-$value"

    companion object {
        private var counter = 0
        fun next(): RequestId = RequestId(++counter)
        val issued: Int get() = counter
    }
}

class Session(val user: String) {
    val id = sessions++

    override fun toString() = "Session($user, #$id)"

    private companion object {
        var sessions = 0
    }
}
