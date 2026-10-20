package arena.plugins.scoring

import arena.core.BasePlugin
import arena.core.Event
import arena.core.Plugin
import arena.core.PluginFactory
import arena.core.World
import arena.core.teams

class Scoreboard {
    val kills = sortedMapOf<String, Int>()

    fun credit(unit: String) {
        kills[unit] = (kills[unit] ?: 0) + 1
    }
}

/** An object plugin: its factory is itself. */
object ScoringPlugin : BasePlugin("scoring", "combat"), PluginFactory {
    override val pluginId get() = id

    override fun create(): Plugin = this

    private var lastAttacker = mutableMapOf<String, String>()

    override fun setup() {
        ctx.provide(Scoreboard::class, Scoreboard())
    }

    override fun onEvent(event: Event, world: World): Boolean = when (event) {
        is Event.Attack -> {
            lastAttacker[event.target] = event.attacker
            false
        }

        is Event.Died -> {
            val killer = lastAttacker[event.unit] ?: "?"
            ctx.service<Scoreboard>().credit(killer)
            world.history += "${event.unit} killed by $killer, teams left ${world.teams}"
            true
        }

        else -> false
    }
}

/** Never registered by the host; only discovered when asked for. */
class BrokenPlugin : BasePlugin("broken", "teleport") {
    companion object : PluginFactory {
        override val pluginId = "broken"

        override fun create() = BrokenPlugin()
    }
}
