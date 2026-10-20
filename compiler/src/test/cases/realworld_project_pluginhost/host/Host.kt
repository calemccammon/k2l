package arena.host

import arena.core.Context
import arena.core.Event
import arena.core.Plugin
import arena.core.PluginException
import arena.core.PluginRegistry
import arena.core.World
import arena.core.alive
import arena.core.teams

class Host(private val world: World, private val maxTicks: Int) {
    val log = mutableListOf<String>()
    private val context = Context { log += it }
    private lateinit var plugins: List<Plugin>

    val installed: List<String> get() = if (::plugins.isInitialized) plugins.map { it.id } else emptyList()

    val ctx: Context get() = context

    fun boot(registry: PluginRegistry) {
        plugins = registry.discover()
        plugins.forEach { it.install(context) }
    }

    /** Runs ticks until one team is left; events are offered to the plugins in install order until one consumes them. */
    fun run(): Int {
        var tick = 0
        while (tick < maxTicks && world.teams.size > 1) {
            tick++
            for (p in plugins) {
                try {
                    p.onTick(tick, world)
                } catch (e: IllegalStateException) {
                    throw PluginException(p.id, e)
                }
            }
            drain()
        }
        world.post(Event.RoundOver)
        drain()
        return tick
    }

    private fun drain() {
        while (world.queue.isNotEmpty()) {
            val e = world.queue.removeFirst()
            val consumer = plugins.firstOrNull { it.onEvent(e, world) }
            if (e is Event.Died || e is Event.RoundOver) log += "$e -> ${consumer?.id ?: "nobody"}"
        }
    }

    fun summary(): String = world.alive().joinToString { "${it.name}(${it.hp}@${it.x})" }
}
