package game.bindings

import dev.k2l.lua.LuaExternal
import dev.k2l.lua.LuaName
import dev.k2l.lua.LuaRequire
import dev.k2l.lua.definedExternally

/** A Lua module used as an object: members are called with `.`, and its fields are read live. */
@LuaExternal
@LuaRequire("lib.audio")
object Audio {
    val played: Int get() = definedExternally

    @LuaName("last_sound")
    val lastSound: String? get() = definedExternally

    external fun play(sound: String, volume: Double): Boolean

    @LuaName("set_muted")
    external fun setMuted(muted: Boolean)
}
