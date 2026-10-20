package game

import dev.k2l.lua.LuaTable
import game.bindings.Audio
import game.bindings.Script
import game.bindings.broken
import game.bindings.finish
import game.bindings.loadScripts
import game.bindings.runAll
import game.bindings.scriptVersion
import game.bindings.stats
import game.engine.Vec
import game.engine.journal
import game.engine.tick
import game.engine.world

// A game host that runs hand-written Lua scripts: Kotlin calls Lua (lib/scripting.lua, lib/audio.lua), and the Lua
// scripts call back into the Kotlin module engine.Api. It can't run on the JVM (see jvm-skip); stdout.txt is what
// Kotlin semantics give.

fun main() {
    println("scripts $scriptVersion")
    val scripts = loadScripts()
    println("loaded ${scripts.length}")

    val hooked = mutableListOf<String>()
    val total = runAll(scripts) { name, index ->
        hooked += "$index:$name"
        index * 10
    }
    println("hook total $total, calls $hooked")
    journal.forEach { println("  $it") }
    println(world)
    println("tick $tick")

    for (i in 1..scripts.length) {
        val s: Script = scripts[i]!!
        val payload = LuaTable<String, Any?>()
        payload["damage"] = 3 * i
        payload["tick"] = tick
        println("${s.describe()} (priority ${s.priority ?: "none"}) ${s.repeatTimes(i + 1)}: ${s.onEvent("hit", payload)}")
        println("  on spawn: ${s.onEvent("spawn", payload) ?: "ignored"}")
    }

    val (n, max, mean) = stats(listOf(4, 9, 2))
    println("stats $n $max $mean")

    val summary = LuaTable<String, Any?>()
    summary["scripts"] = scripts.length
    println(runCatching { finish(summary) }.exceptionOrNull()?.message)
    summary["tick"] = tick
    println(finish(summary))

    for (kind in listOf("string", "table", "index")) {
        try {
            broken(kind)
        } catch (e: RuntimeException) {
            // a table's message is its address, and the wording of Lua's own errors differs between versions
            val msg = e.message.orEmpty()
            println("$kind: ${e::class.simpleName} ${if (kind == "string") msg else msg.startsWith("table:") || "nil" in msg}")
        }
    }

    println("${Audio.play("boom", 0.5)} ${Audio.play("zap", 1.0)} ${Audio.played} ${Audio.lastSound}")
    Audio.setMuted(true)
    println("${Audio.play("hush", 0.1)} ${Audio.played} ${Audio.lastSound}")

    println(Vec(1, 2) + Vec(3, 4))
}
