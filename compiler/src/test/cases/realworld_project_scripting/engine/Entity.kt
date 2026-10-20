package game.engine

// Entities are Kotlin objects that the Lua scripts receive and call methods on (`e:damage(3)`).

class Entity(val name: String, var hp: Int) {
    val tags = mutableListOf<String>()

    val alive: Boolean get() = hp > 0

    fun damage(amount: Int): Boolean {
        hp = maxOf(0, hp - amount)
        return alive
    }

    fun tag(vararg names: String): Entity {
        tags += names
        return this
    }

    override fun toString() = "Entity($name, hp=$hp${if (tags.isEmpty()) "" else ", tags=$tags"})"
}

data class Vec(val x: Int, val y: Int) {
    operator fun plus(o: Vec) = Vec(x + o.x, y + o.y)
}
