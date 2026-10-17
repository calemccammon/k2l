package dev.k2l.lua

/** A plain Lua table. `t[k]` and `t[k] = v` index it directly; `length` is Lua's `#t`. */
@Suppress("UnusedParameter") // stub: parameters only describe the Lua API
class LuaTable<K, V> {
    operator fun get(key: K): V? = definedExternally

    operator fun set(key: K, value: V?): Unit = definedExternally

    /** The border of the sequence part, `#t`. */
    val length: Int get() = definedExternally

    fun has(key: K): Boolean = definedExternally

    fun remove(key: K): Unit = definedExternally

    /** `for k, v in pairs(t)`. */
    fun forEach(action: (K, V) -> Unit): Unit = definedExternally
}

/** Results of a Lua function that returns several values. Destructure them: `val (ok, err) = pcall(f)`. */
class LuaMultiReturn2<out A, out B> {
    operator fun component1(): A = definedExternally
    operator fun component2(): B = definedExternally
}

class LuaMultiReturn3<out A, out B, out C> {
    operator fun component1(): A = definedExternally
    operator fun component2(): B = definedExternally
    operator fun component3(): C = definedExternally
}
