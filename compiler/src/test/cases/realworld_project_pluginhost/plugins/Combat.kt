package arena.plugins.combat

import arena.core.BasePlugin
import arena.core.Event
import arena.core.PluginFactory
import arena.core.World
import arena.core.alive
import arena.plugins.movement.Grid

/** Damage per attacker name prefix, built once on first use. */
val damageTable: Map<Char, Int> by lazy {
    println("building damage table")
    mapOf('k' to 4, 'a' to 3, 'm' to 5)
}

class CombatPlugin(private val critEvery: Int) : BasePlugin("combat", "movement") {
    private var swings = 0

    override fun onTick(tick: Int, world: World) {
        val grid = ctx.service<Grid>()
        for (u in world.alive()) {
            val target = world.alive().firstOrNull { it.team != u.team && grid.distance(it.x, u.x) <= 1 } ?: continue
            swings++
            val base = damageTable[u.name.first()] ?: 1
            world.post(Event.Attack(u.name, target.name, if (swings % critEvery == 0) base * 2 else base))
        }
    }

    override fun onEvent(event: Event, world: World): Boolean {
        if (event !is Event.Attack) return false
        val target = world[event.target] ?: return true
        if (target.hp <= 0) return true
        target.hp -= event.power
        if (target.hp <= 0) world.post(Event.Died(target.name))
        // not consumed: scoring sees the attack too
        return false
    }

    companion object Factory : PluginFactory {
        override val pluginId = "combat"

        override fun create() = CombatPlugin(critEvery = 3)
    }
}
