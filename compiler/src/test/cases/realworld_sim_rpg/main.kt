import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.random.Random

// A turn-based dungeon crawl with a seeded RNG: parties, inventories, loot tables with weights,
// critical hits and dodges, status effects, and a tournament of many seeded battles.

enum class Element { FIRE, ICE, POISON, NONE }

data class Item(val name: String, val attack: Int = 0, val defense: Int = 0, val heal: Int = 0, val element: Element = Element.NONE)

sealed interface Effect {
    val turns: Int

    data class Burn(override val turns: Int, val damage: Int) : Effect

    data class Freeze(override val turns: Int) : Effect

    data class Poison(override val turns: Int, val percent: Int) : Effect
}

class Fighter(val name: String, val maxHp: Int, val baseAttack: Int, val baseDefense: Int, val agility: Int) {
    var hp = maxHp
    val inventory = mutableListOf<Item>()
    val effects = mutableListOf<Effect>()
    var weapon: Item? = null
    var armor: Item? = null
    var kills = 0

    val alive get() = hp > 0
    val attack get() = baseAttack + (weapon?.attack ?: 0)
    val defense get() = baseDefense + (armor?.defense ?: 0)

    fun equipBest() {
        weapon = inventory.filter { it.attack > 0 }.maxByOrNull { it.attack } ?: weapon
        armor = inventory.filter { it.defense > 0 }.maxByOrNull { it.defense } ?: armor
    }

    override fun toString() = "$name(${max(hp, 0)}/$maxHp)"
}

class LootTable(private val entries: List<Pair<Item, Int>>) {
    private val total = entries.sumOf { it.second }

    fun roll(rng: Random): Item {
        var pick = rng.nextInt(total)
        for ((item, weight) in entries) {
            if (pick < weight) return item
            pick -= weight
        }
        error("unreachable")
    }
}

val loot = LootTable(
    listOf(
        Item("potion", heal = 25) to 40,
        Item("dagger", attack = 3) to 20,
        Item("flame sword", attack = 7, element = Element.FIRE) to 8,
        Item("frost axe", attack = 6, element = Element.ICE) to 8,
        Item("venom blade", attack = 5, element = Element.POISON) to 8,
        Item("leather", defense = 2) to 20,
        Item("plate", defense = 6) to 6,
    ),
)

class Battle(private val rng: Random, private val log: Boolean) {
    var rounds = 0
        private set

    private fun say(s: String) {
        if (log) println(s)
    }

    private fun tickEffects(f: Fighter): Boolean {
        var frozen = false
        val remaining = mutableListOf<Effect>()
        for (e in f.effects) {
            when (e) {
                is Effect.Burn -> f.hp -= e.damage.also { say("  ${f.name} burns for $it") }
                is Effect.Poison -> f.hp -= max(1, f.maxHp * e.percent / 100).also { say("  ${f.name} takes $it poison") }
                is Effect.Freeze -> frozen = true.also { say("  ${f.name} is frozen") }
            }
            if (e.turns > 1) {
                remaining += when (e) {
                    is Effect.Burn -> e.copy(turns = e.turns - 1)
                    is Effect.Freeze -> e.copy(turns = e.turns - 1)
                    is Effect.Poison -> e.copy(turns = e.turns - 1)
                }
            }
        }
        f.effects.clear()
        f.effects += remaining
        return frozen
    }

    private fun strike(a: Fighter, d: Fighter) {
        if (rng.nextInt(100) < d.agility) {
            say("  ${d.name} dodges ${a.name}")
            return
        }
        val variance = rng.nextDouble(0.85, 1.15)
        val crit = rng.nextDouble() < 0.1
        var damage = ((a.attack * a.attack).toDouble() / (a.attack + d.defense) * variance).roundToInt()
        if (crit) damage = (damage * 1.75).roundToInt()
        damage = max(1, damage)
        d.hp -= damage
        say("  ${a.name} hits ${d.name} for $damage${if (crit) " (critical)" else ""}")
        when (a.weapon?.element) {
            Element.FIRE -> if (rng.nextBoolean()) d.effects += Effect.Burn(2, 3)
            Element.ICE -> if (rng.nextInt(4) == 0) d.effects += Effect.Freeze(1)
            Element.POISON -> if (d.effects.none { it is Effect.Poison }) d.effects += Effect.Poison(3, 5)
            else -> {}
        }
        if (!d.alive) {
            a.kills++
            say("  ${d.name} falls")
        }
    }

    fun fight(heroes: List<Fighter>, monsters: List<Fighter>): Boolean {
        while (heroes.any { it.alive } && monsters.any { it.alive } && rounds < 50) {
            rounds++
            say("round $rounds")
            val order = (heroes + monsters).filter { it.alive }.shuffled(rng).sortedByDescending { it.agility }
            for (f in order) {
                if (!f.alive) continue
                if (tickEffects(f) || !f.alive) continue
                val foes = (if (f in heroes) monsters else heroes).filter { it.alive }
                if (foes.isEmpty()) break
                val potion = f.inventory.firstOrNull { it.heal > 0 }
                if (potion != null && f.hp < f.maxHp / 3) {
                    f.inventory.remove(potion)
                    f.hp = minOf(f.maxHp, f.hp + potion.heal)
                    say("  ${f.name} drinks a ${potion.name}")
                    continue
                }
                strike(f, foes.random(rng))
            }
        }
        return heroes.any { it.alive }
    }
}

fun party() = listOf(Fighter("Knight", 60, 9, 5, 10), Fighter("Rogue", 40, 8, 2, 35), Fighter("Mage", 35, 11, 1, 15))

fun monsters(rng: Random, depth: Int) = List(rng.nextInt(2, 4)) { i ->
    val hp = 20 + depth * 6 + rng.nextInt(10)
    Fighter("Goblin${depth}_$i", hp, 6 + depth, 1 + depth / 2, rng.nextInt(5, 20))
}

fun crawl(seed: Int, log: Boolean): String {
    val rng = Random(seed)
    val heroes = party()
    for (h in heroes) repeat(2) { h.inventory += loot.roll(rng) }
    heroes.forEach { it.equipBest() }
    var depth = 0
    var totalRounds = 0
    while (depth < 10) {
        depth++
        val battle = Battle(rng, log)
        if (log) println("== depth $depth: ${heroes.filter { it.alive }}")
        val won = battle.fight(heroes, monsters(rng, depth))
        totalRounds += battle.rounds
        if (!won) break
        for (h in heroes.filter { it.alive }) {
            if (rng.nextInt(3) == 0) h.inventory += loot.roll(rng)
            h.equipBest()
            h.hp = minOf(h.maxHp, h.hp + h.maxHp / 10)
        }
    }
    val survivors = heroes.filter { it.alive }
    val gear = heroes.joinToString(" ") { "${it.name}:${it.weapon?.name ?: "-"}/${it.armor?.name ?: "-"}/${it.inventory.size}" }
    return "seed $seed reached depth $depth in $totalRounds rounds; survivors $survivors; kills ${heroes.map { it.kills }}; $gear"
}

fun main() {
    println(crawl(1, log = true).let { "\n$it" })
    println("-- tournament")
    val results = (2..13).map { crawl(it * 97, log = false) }
    results.forEach(::println)
    val depths = results.map { it.substringAfter("depth ").substringBefore(' ').toInt() }
    println("average depth ${"%.2f".format(depths.average())}, best ${depths.max()}, cleared ${depths.count { it == 10 }}")
    val rng = Random(5)
    val drops = List(1000) { loot.roll(rng).name }.groupingBy { it }.eachCount().toSortedMap()
    println("loot distribution $drops")
}
