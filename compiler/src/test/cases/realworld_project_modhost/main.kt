package mods

import dev.k2l.lua.LuaTable
import mods.bindings.boot
import mods.mods.clickCount
import mods.mods.style
import mods.mods.summary
import mods.shared.Events

// The entry point hands control to a Lua host (lib/host.lua), which loads the Kotlin mods in mods/ by module name,
// calls their `@LuaName` functions and writes their properties. It needs the Lua host, so it can't run on the JVM
// (jvm-skip); stdout.txt is what Kotlin semantics give.

fun main() {
    println("kotlin main starts")
    val modules = LuaTable<Int, String>()
    modules[1] = "mods.Greeter"
    modules[2] = "mods.Counter"
    val n = boot(modules)
    println("booted $n mods")
    println("kotlin sees style=$style clicks=$clickCount")
    println(summary())
    println("fired ${Events.fired}")
}
