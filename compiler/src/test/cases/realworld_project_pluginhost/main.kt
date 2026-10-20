package arena

import arena.core.PluginRegistry
import arena.core.Unit
import arena.core.World
import arena.host.Host
import arena.plugins.combat.CombatPlugin
import arena.plugins.movement.MovementPlugin
import arena.plugins.scoring.BrokenPlugin
import arena.plugins.scoring.Scoreboard
import arena.plugins.scoring.ScoringPlugin

// A small arena simulation: the host knows only the plugin API; plugins from three packages register their factories
// (companion objects, a named companion, an object plugin) and are installed in dependency order.

fun main() {
    println("before registry")
    PluginRegistry.register(ScoringPlugin).register(CombatPlugin).register(MovementPlugin)
    println("registered ${PluginRegistry.ids}")
    println(runCatching { PluginRegistry.register(CombatPlugin.Factory) }.exceptionOrNull()?.message)

    val world = World(8)
    world.units += listOf(Unit("knight", 9, 0, 'A'), Unit("archer", 6, 1, 'A'), Unit("mage", 7, 7, 'B'), Unit("brute", 12, 6, 'B'))
    val host = Host(world, maxTicks = 20)
    println("installed before boot: ${host.installed}")
    host.boot(PluginRegistry)
    println("installed ${host.installed}, lookups ${PluginRegistry.lookups}")
    val ticks = host.run()
    println("finished after $ticks ticks: ${host.summary()}")
    host.log.forEach { println("  $it") }
    world.history.forEach { println("  $it") }
    println("kills ${host.ctx.service<Scoreboard>().kills}")

    PluginRegistry.register(BrokenPlugin)
    println(runCatching { PluginRegistry.discover() }.exceptionOrNull())
    PluginRegistry.clear()
    println("cleared ${PluginRegistry.ids} ${PluginRegistry.discover()}")
}
