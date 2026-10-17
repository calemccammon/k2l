package dev.k2l.lua

/** Lua's global functions. `Lua.print(x)` is `print(x)`. */
@LuaExternal
@LuaName("_G")
object Lua {
    external fun print(vararg values: Any?)
    external fun tostring(value: Any?): String
    external fun tonumber(value: Any?): Double?
    external fun type(value: Any?): String
    external fun pcall(f: () -> Unit): LuaMultiReturn2<Boolean, Any?>
    external fun error(message: Any?): Nothing
    external fun require(module: String): Any?
    external fun select(index: String, vararg values: Any?): Int
}

/** Lua's `os` library. */
@LuaExternal
@LuaName("os")
object LuaOs {
    external fun time(): Long
    external fun clock(): Double
    external fun getenv(name: String): String?
    external fun date(format: String): String
}

/** Lua's `io` library (the parts that don't need file handles). */
@LuaExternal
@LuaName("io")
object LuaIo {
    external fun write(vararg values: Any?)
    external fun read(format: String): String?
}
