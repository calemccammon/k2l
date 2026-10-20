package game.engine

import dev.k2l.lua.LuaTable

// The module the Lua scripts `require("engine.Api")`: plain top-level Kotlin functions and properties, exported as fields.

val world = mutableListOf<Entity>()

var tick = 0

val journal = mutableListOf<String>()

private val handlers = linkedMapOf<String, MutableList<(LuaTable<String, Any?>) -> Unit>>()

fun spawn(name: String, hp: Int = 10): Entity {
    val e = Entity(name, hp)
    world += e
    journal += "spawn $name"
    return e
}

fun find(name: String): Entity? = world.firstOrNull { it.name == name }

/** Lua passes its own functions here; Kotlin calls them later with a Lua table. */
fun on(event: String, handler: (LuaTable<String, Any?>) -> Unit) {
    handlers.getOrPut(event) { mutableListOf() } += handler
}

fun emit(event: String, payload: LuaTable<String, Any?>): Int {
    tick++
    val list = handlers[event] ?: return 0
    payload["tick"] = tick
    list.forEach { it(payload) }
    return list.size
}

fun names(): LuaTable<Int, String> {
    val t = LuaTable<Int, String>()
    world.forEachIndexed { i, e -> t[i + 1] = e.name }
    return t
}

/** A nested table built in Kotlin and read by Lua. */
fun snapshot(): LuaTable<String, Any?> {
    val t = LuaTable<String, Any?>()
    t["tick"] = tick
    t["alive"] = world.count { it.alive }
    val hp = LuaTable<String, Int>()
    world.forEach { hp[it.name] = it.hp }
    t["hp"] = hp
    return t
}

fun log(vararg parts: Any?) {
    journal += parts.joinToString(" ")
}

fun fail(reason: String): Nothing = throw IllegalStateException(reason)

