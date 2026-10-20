@file:LuaRequire("lib.host")

package mods.bindings

import dev.k2l.lua.LuaExternal
import dev.k2l.lua.LuaRequire
import dev.k2l.lua.LuaTable
import dev.k2l.lua.NoSelf

/** The Lua host's table passed to every mod: plain functions, called without `self`. */
@LuaExternal
@NoSelf
interface Host {
    val name: String

    fun log(msg: String)

    fun schedule(delay: Int, task: () -> Unit)
}

/** Runs the hand-written Lua driver, which loads the Kotlin mods by module name. */
external fun boot(modules: LuaTable<Int, String>): Int
