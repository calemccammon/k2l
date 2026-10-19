package adventure

import kotlin.random.Random

// A text adventure driven by a scripted list of commands and a seeded random number generator.

enum class Direction(val short: Char) {
    NORTH('n'), SOUTH('s'), EAST('e'), WEST('w');

    val opposite: Direction
        get() = when (this) {
            NORTH -> SOUTH
            SOUTH -> NORTH
            EAST -> WEST
            WEST -> EAST
        }

    companion object {
        fun parse(word: String): Direction? =
            entries.firstOrNull { it.name.equals(word, ignoreCase = true) || (word.length == 1 && it.short == word[0]) }
    }
}

sealed class Item(val name: String, val weight: Int) {
    class Key(val opens: String) : Item("key", 1)
    class Weapon(name: String, val damage: IntRange) : Item(name, 3)
    class Potion(val heal: Int) : Item("potion", 1)
    class Treasure(name: String, val value: Int) : Item(name, 2)

    override fun toString() = name
}

class Monster(val name: String, var hp: Int, val attack: IntRange) {
    val alive get() = hp > 0
}

class Room(val id: String, val description: String) {
    val exits = mutableMapOf<Direction, Room>()
    val items = mutableListOf<Item>()
    var monster: Monster? = null
    var lockedBy: String? = null

    fun connect(dir: Direction, other: Room) {
        exits[dir] = other
        other.exits[dir.opposite] = this
    }

    override fun toString() = buildString {
        append("[$id] $description")
        if (items.isNotEmpty()) append(" Items: ${items.joinToString()}.")
        monster?.takeIf { it.alive }?.let { append(" A ${it.name} blocks the way (hp ${it.hp}).") }
        append(" Exits: ${exits.keys.sorted().joinToString { it.name.lowercase() }}.")
    }
}

class Player(var room: Room) {
    var hp = 20
    val inventory = mutableListOf<Item>()
    val maxWeight = 6
    var score = 0
    var moves = 0

    val carried get() = inventory.sumOf { it.weight }
    val bestWeapon get() = inventory.filterIsInstance<Item.Weapon>().maxByOrNull { it.damage.last }
}

sealed interface Command {
    data class Go(val dir: Direction) : Command
    data class Take(val item: String) : Command
    data class Drop(val item: String) : Command
    data class Use(val item: String) : Command
    data object Look : Command
    data object Inventory : Command
    data object Attack : Command
    data class Unknown(val text: String) : Command
}

fun parseCommand(line: String): Command {
    val words = line.trim().lowercase().split(Regex("\\s+")).filter { it.isNotEmpty() && it !in setOf("the", "a", "an") }
    if (words.isEmpty()) return Command.Unknown(line)
    val (verb, rest) = words.first() to words.drop(1).joinToString(" ")
    return when (verb) {
        "go", "walk" -> Direction.parse(rest)?.let { Command.Go(it) } ?: Command.Unknown(line)
        "n", "s", "e", "w", "north", "south", "east", "west" -> Command.Go(Direction.parse(verb)!!)
        "take", "get" -> Command.Take(rest)
        "drop" -> Command.Drop(rest)
        "use", "drink" -> Command.Use(rest)
        "look", "l" -> Command.Look
        "inventory", "i" -> Command.Inventory
        "attack", "fight", "hit" -> Command.Attack
        else -> Command.Unknown(line)
    }
}

class Game(seed: Int) {
    private val random = Random(seed)
    private val rooms: Map<String, Room>
    val player: Player
    private val out = mutableListOf<String>()
    var over = false
        private set

    init {
        val hall = Room("hall", "A dusty hall.")
        val armory = Room("armory", "Racks of old weapons.")
        val cellar = Room("cellar", "Damp and dark.")
        val vault = Room("vault", "Gold glitters everywhere.")
        hall.connect(Direction.EAST, armory)
        hall.connect(Direction.SOUTH, cellar)
        cellar.connect(Direction.EAST, vault)
        armory.items += Item.Weapon("sword", 3..6)
        armory.items += Item.Weapon("dagger", 1..3)
        hall.items += Item.Potion(8)
        cellar.items += Item.Key("vault")
        cellar.monster = Monster("rat king", 12, 1..4)
        vault.lockedBy = "vault"
        vault.items.addAll(listOf(Item.Treasure("crown", 50), Item.Treasure("coins", 20)))
        rooms = listOf(hall, armory, cellar, vault).associateBy { it.id }
        player = Player(hall)
    }

    private fun say(msg: String) {
        out += msg
    }

    fun run(script: List<String>): List<String> {
        say(player.room.toString())
        for (line in script) {
            if (over) break
            say("> $line")
            step(parseCommand(line))
        }
        say("Final: hp=${player.hp} score=${player.score} moves=${player.moves} carried=${player.carried}")
        return out
    }

    private fun findItem(items: List<Item>, name: String): Item? = items.firstOrNull { it.name == name }

    private fun step(cmd: Command) {
        player.moves++
        when (cmd) {
            is Command.Go -> move(cmd.dir)
            is Command.Take -> {
                val item = findItem(player.room.items, cmd.item) ?: return say("There is no ${cmd.item} here.")
                if (player.carried + item.weight > player.maxWeight) return say("The ${item.name} is too heavy.")
                player.room.items -= item
                player.inventory += item
                if (item is Item.Treasure) player.score += item.value
                say("Taken: $item.")
            }
            is Command.Drop -> findItem(player.inventory, cmd.item)?.let {
                player.inventory.remove(it)
                player.room.items.add(it)
                if (it is Item.Treasure) player.score -= it.value
                say("Dropped $it.")
            } ?: say("You have no ${cmd.item}.")
            is Command.Use -> use(cmd.item)
            Command.Look -> say(player.room.toString())
            Command.Inventory -> say(
                if (player.inventory.isEmpty()) "You carry nothing." else "You carry: ${player.inventory.joinToString()}",
            )
            Command.Attack -> attack()
            is Command.Unknown -> say("I don't understand '${cmd.text}'.")
        }
    }

    private fun move(dir: Direction) {
        val next = player.room.exits[dir] ?: return say("You can't go ${dir.name.lowercase()}.")
        val blocker = player.room.monster
        if (blocker != null && blocker.alive && dir != Direction.NORTH) return say("The ${blocker.name} won't let you pass.")
        next.lockedBy?.let { lock ->
            val key = player.inventory.filterIsInstance<Item.Key>().find { it.opens == lock }
                ?: return say("The door to the ${next.id} is locked.")
            next.lockedBy = null
            say("You unlock the door with the ${key.name}.")
        }
        player.room = next
        say(next.toString())
    }

    private fun use(name: String) {
        when (val item = findItem(player.inventory, name)) {
            null -> say("You have no $name.")
            is Item.Potion -> {
                val before = player.hp
                player.hp = minOf(20, player.hp + item.heal)
                player.inventory.remove(item)
                say("You feel better (${before} -> ${player.hp}).")
            }
            else -> say("Nothing happens with the ${item.name}.")
        }
    }

    private fun attack() {
        val monster = player.room.monster?.takeIf { it.alive } ?: return say("There is nothing to attack.")
        val weapon = player.bestWeapon
        val damage = weapon?.damage?.let { random.nextInt(it.first, it.last + 1) } ?: 1
        monster.hp -= damage
        say("You hit the ${monster.name} with ${weapon ?: "your fists"} for $damage.")
        if (!monster.alive) {
            player.score += 10
            return say("The ${monster.name} dies!")
        }
        val bite = monster.attack.random(random)
        player.hp -= bite
        say("The ${monster.name} bites you for $bite (hp ${player.hp}).")
        if (player.hp <= 0) {
            over = true
            say("You died.")
        }
    }

    fun roomCount() = rooms.size
}

fun main() {
    val script = listOf(
        "look", "take potion", "go east", "take sword", "take dagger", "i", "w", "s", "e",
        "attack", "attack", "attack", "attack", "attack", "drink potion", "attack",
        "take the key", "e", "take crown", "take coins", "drop dagger", "take coins", "dance", "go up", "n",
    )
    val game = Game(seed = 42)
    game.run(script).forEach(::println)
    println("rooms=${game.roomCount()} alive=${game.player.hp > 0}")

    val r1 = Random(7)
    val r2 = Random(7)
    println(List(5) { r1.nextInt(100) } == List(5) { r2.nextInt(100) })
    println(listOf("n", "go west", "take", "hit", "   ", "walk e").map(::parseCommand))
}
