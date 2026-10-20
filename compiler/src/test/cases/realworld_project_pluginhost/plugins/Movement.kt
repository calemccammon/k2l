package arena.plugins.movement

import arena.core.BasePlugin
import arena.core.Event
import arena.core.Plugin
import arena.core.PluginFactory
import arena.core.World
import arena.core.alive

/** A service other plugins look up. */
class Grid(val width: Int) {
    fun clamp(x: Int) = x.coerceIn(0, width - 1)

    fun distance(a: Int, b: Int) = if (a > b) a - b else b - a
}

class MovementPlugin private constructor() : BasePlugin("movement") {
    private var moves = 0

    override fun setup() {
        ctx.provide(Grid::class, Grid(8))
    }

    override fun onTick(tick: Int, world: World) {
        val grid = ctx.service<Grid>()
        for (u in world.alive()) {
            val enemy = world.alive().filter { it.team != u.team }.minByOrNull { grid.distance(it.x, u.x) } ?: continue
            if (grid.distance(enemy.x, u.x) > 1) {
                u.x = grid.clamp(u.x + if (enemy.x > u.x) 1 else -1)
                moves++
                world.post(Event.Moved(u.name, u.x))
            }
        }
    }

    override fun onEvent(event: Event, world: World): Boolean {
        if (event is Event.RoundOver) ctx.log("movement made $moves moves")
        return false
    }

    companion object : PluginFactory {
        override val pluginId = "movement"

        override fun create(): Plugin = MovementPlugin()
    }
}
