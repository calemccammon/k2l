package arena.core

import kotlin.reflect.KClass

data class Unit(val name: String, var hp: Int, var x: Int, val team: Char)

sealed interface Event {
    data class Moved(val unit: String, val to: Int) : Event

    data class Attack(val attacker: String, val target: String, val power: Int) : Event

    data class Died(val unit: String) : Event

    data object RoundOver : Event
}

class World(val width: Int) {
    val units = mutableListOf<Unit>()
    val queue = ArrayDeque<Event>()
    val history = mutableListOf<String>()

    fun post(e: Event) {
        queue.addLast(e)
    }

    operator fun get(name: String): Unit? = units.find { it.name == name }
}

fun World.alive(team: Char? = null): List<Unit> = units.filter { it.hp > 0 && (team == null || it.team == team) }

val World.teams: Set<Char> get() = alive().map { it.team }.toSortedSet()

/** What plugins see of the host: logging and typed services that other plugins provide. */
class Context(private val logger: (String) -> kotlin.Unit) {
    private val services = HashMap<KClass<*>, Any>()

    fun log(msg: String) = logger(msg)

    fun <T : Any> provide(type: KClass<T>, service: T) {
        services[type] = service
    }

    fun <T : Any> lookup(type: KClass<T>): T? {
        @Suppress("UNCHECKED_CAST")
        return services[type] as T?
    }

    inline fun <reified T : Any> service(): T = lookup(T::class) ?: error("no service ${T::class.simpleName}")
}
