@file:LuaRequire("lib.scripting")

package game.bindings

import dev.k2l.lua.LuaExternal
import dev.k2l.lua.LuaMultiReturn3
import dev.k2l.lua.LuaName
import dev.k2l.lua.LuaRequire
import dev.k2l.lua.LuaTable
import dev.k2l.lua.NoSelf
import dev.k2l.lua.definedExternally

// Bindings for lib/scripting.lua, a hand-written Lua module that itself requires the Kotlin module engine.Api.

@LuaExternal
@LuaName("VERSION")
val scriptVersion: String get() = definedExternally

external fun loadScripts(): LuaTable<Int, Script>

@LuaName("run_all")
external fun runAll(scripts: LuaTable<Int, Script>, hook: (String, Int) -> Int): Int

/** `end` is a Lua keyword: the call must be `____scripting["end"](...)`. */
@LuaName("end")
external fun finish(summary: LuaTable<String, Any?>): String

external fun stats(xs: List<Int>): LuaMultiReturn3<Int, Int, Double>

external fun broken(kind: String)

@LuaExternal
interface Script {
    val name: String
    val priority: Int?

    @LuaName("on_event")
    fun onEvent(kind: String, payload: LuaTable<String, Any?>): String?

    @NoSelf
    fun describe(): String

    @LuaName("repeat")
    fun repeatTimes(n: Int): String
}
