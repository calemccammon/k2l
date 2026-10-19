package sim

import sim.ecs.Component
import sim.ecs.World
import sim.game.Combat
import sim.game.Damage
import sim.game.Health
import sim.game.Movement
import sim.game.Name
import sim.game.Player
import sim.game.Position
import sim.game.Reaper
import sim.game.Regeneration
import sim.game.Velocity
import sim.game.nameOf
import sim.game.render
import sim.ecs.System as GameSystem

// An entity-component-system simulation on a small grid: movement, combat, regeneration and removal of the dead.

class Counter : GameSystem("counter") {
    val seen = mutableMapOf<String, Int>()
    override fun update(world: World, dt: Int) {
        for ((e, _) in world.query<Health>()) seen.merge(world.nameOf(e), 1, Int::plus)
    }
}

inline fun <reified C : Component> World.describe(): String {
    val items = query<C>()
    return "${C::class.simpleName}: " + items.joinToString { (e, c) -> "$e=$c" }
}

fun main() {
    val width = 12
    val height = 5
    val counter = Counter()
    val world = World()
        .addSystem(Movement(width, height))
        .addSystem(Combat())
        .addSystem(Regeneration(every = 3))
        .addSystem(Reaper())
        .addSystem(counter)

    val hero = world.spawn(Player, Name("hero"), Position(1, 2), Velocity(1, 0), Health(12, 12), Damage(3, 1))
    val orc = world.spawn(Name("orc"), Position(6, 2), Velocity(-1, 0), Health(8, 8), Damage(2, 1))
    val bat = world.spawn(Name("bat"), Position(10, 0), Velocity(1, 1), Health(3, 3), Damage(1, 0))
    world.spawn(Name("tree"), Position(4, 4))
    val ghost = world.spawn(Name("ghost"), Health(1, 1))

    println(world)
    println(world.describe<Position>())
    println(world.describe<Health>())
    println("hero has player: ${world.has<Player>(hero)}, orc: ${world.has<Player>(orc)}, ghost pos: ${world.get<Position>(ghost)}")

    for (t in 1..8) {
        world.step()
        println("-- tick ${world.tick}: population ${world.population}")
        world.render(width, height).forEach { println("   $it") }
    }
    world.log.forEach { println(it) }
    println(world.describe<Health>())
    println("bat alive: ${world.isAlive(bat.id)}, orc alive: ${world.isAlive(orc.id)}, orc health: ${world.get<Health>(orc)}")
    println("systems: ${world.systems()}")
    println("counter: ${counter.seen.toSortedMap()}")
    world.add(ghost, Position(0, 0))
    world.add(hero, Velocity(0, 1))
    world.step(dt = 2)
    println(world.describe<Position>())
    println(world.query2<Name, Velocity>().map { (_, n, v) -> "${n.value}:${v.dx},${v.dy}" })
    println(world)
}
