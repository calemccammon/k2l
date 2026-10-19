package sim.game

import sim.ecs.Component
import sim.ecs.Entity
import sim.ecs.System
import sim.ecs.World

data class Position(var x: Int, var y: Int) : Component
data class Velocity(val dx: Int, val dy: Int) : Component
data class Health(var hp: Int, val max: Int) : Component {
    val dead get() = hp <= 0
}
data class Name(val value: String) : Component
data class Damage(val amount: Int, val range: Int) : Component
object Player : Component {
    override fun toString() = "Player"
}

class Movement(private val width: Int, private val height: Int) : System("movement") {
    override fun update(world: World, dt: Int) {
        for ((_, pos, vel) in world.query2<Position, Velocity>()) {
            pos.x = (pos.x + vel.dx * dt).mod(width)
            pos.y = (pos.y + vel.dy * dt).coerceIn(0, height - 1)
        }
    }
}

class Combat : System("combat") {
    override fun update(world: World, dt: Int) {
        val attackers = world.query2<Position, Damage>()
        val targets = world.query2<Position, Health>()
        for ((a, apos, dmg) in attackers) {
            for ((t, tpos, health) in targets) {
                if (a == t || health.dead) continue
                val dist = distance(apos, tpos)
                if (dist <= dmg.range) {
                    health.hp -= dmg.amount
                    world.log += "t${world.tick}: ${world.nameOf(a)} hits ${world.nameOf(t)} for ${dmg.amount} (hp ${health.hp})"
                }
            }
        }
    }
}

class Reaper : System("reaper") {
    override fun update(world: World, dt: Int) {
        world.query<Health>().filter { (_, h) -> h.dead }.forEach { (e, _) ->
            if (world.has<Player>(e)) world.log += "t${world.tick}: the player died"
            world.destroy(e)
        }
    }
}

/** Heals entities by one point every [every] ticks, up to their maximum. */
class Regeneration(private val every: Int) : System("regen") {
    override fun update(world: World, dt: Int) {
        if (world.tick % every != 0) return
        world.query<Health>().forEach { (_, h) -> if (!h.dead && h.hp < h.max) h.hp++ }
    }
}

fun distance(a: Position, b: Position): Int = maxOf(kotlin.math.abs(a.x - b.x), kotlin.math.abs(a.y - b.y))

fun World.nameOf(e: Entity): String = get<Name>(e)?.value ?: e.toString()

fun World.render(width: Int, height: Int): List<String> {
    val grid = List(height) { CharArray(width) { '.' } }
    for ((e, pos) in query<Position>()) {
        val c = when {
            has<Player>(e) -> '@'
            has<Damage>(e) -> 'M'
            else -> nameOf(e).first().lowercaseChar()
        }
        grid[pos.y][pos.x] = c
    }
    return grid.map { String(it) }
}
