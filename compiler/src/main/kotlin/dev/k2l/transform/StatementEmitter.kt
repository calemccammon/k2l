package dev.k2l.transform

import dev.k2l.lua.*
import java.util.Collections
import java.util.IdentityHashMap

/** Collects the Lua statements an expression needs to run before it, see [collect]. */
abstract class StatementEmitter {
    abstract val ctx: TransformContext

    internal var buffer = mutableListOf<LuaStmt>()

    fun emit(stmt: LuaStmt) {
        buffer += stmt
    }

    internal fun emitAll(stmts: List<LuaStmt>) {
        buffer += stmts
    }

    /** Runs [block] with a fresh statement buffer and returns what it emitted. */
    internal inline fun collect(block: () -> Unit): List<LuaStmt> {
        val saved = buffer
        val mine = mutableListOf<LuaStmt>()
        buffer = mine
        try {
            block()
        } finally {
            buffer = saved
        }
        return mine
    }

    internal inline fun <T> withPreceding(block: () -> T): Pair<T, List<LuaStmt>> {
        var result: T? = null
        val stmts = collect { result = block() }
        @Suppress("UNCHECKED_CAST")
        return (result as T) to stmts
    }

    /** Lua expressions known not to change if evaluated later (literals, `val`s and parameters). */
    internal val stable: MutableSet<LuaExpr> = Collections.newSetFromMap(IdentityHashMap())

    internal fun isStable(e: LuaExpr) =
        e is LuaNil || e is LuaBool || e is LuaNumber || e is LuaString || e in stable

    /** Stores [value] in a local unless it is stable, so it can be read more than once. */
    internal fun cache(value: LuaExpr, hint: String): LuaExpr {
        if (isStable(value)) return value
        val name = ctx.temp(hint)
        emit(LuaLocal(listOf(name), listOf(value)))
        return LuaName(name).also { stable += it }
    }
}
