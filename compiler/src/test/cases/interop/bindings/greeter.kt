@file:LuaRequire("lib.greeter")

package bindings

import dev.k2l.lua.LuaExternal
import dev.k2l.lua.LuaMultiReturn2
import dev.k2l.lua.LuaRequire
import dev.k2l.lua.LuaTable
import dev.k2l.lua.NoSelf
import dev.k2l.lua.definedExternally

@LuaExternal
val VERSION: String get() = definedExternally

external fun greet(name: String): String

external fun divmod(a: Int, b: Int): LuaMultiReturn2<Int, Int>

external fun each(items: LuaTable<Int, String>, f: (String) -> Unit)

external fun makeCounter(start: Int): Counter

@LuaExternal
interface Counter {
    val count: Int
    fun increment(by: Int)

    @NoSelf
    fun describe(c: Counter): String
}
