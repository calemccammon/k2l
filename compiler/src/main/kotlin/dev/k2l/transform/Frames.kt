package dev.k2l.transform

import dev.k2l.lua.*

internal class LoopFrame(val label: String?) {
    var continueLabel: String? = null
    var breakLabel: String? = null

    /** Lua 5.1 (no goto): flags that carry `break@outer` / `continue@outer` out of inner loops. */
    var breakFlag: String? = null
    var continueFlag: String? = null

    /** Checks emitted right after this loop, in the enclosing loop's body. */
    val checksAfter = mutableListOf<LuaStmt>()

    fun addCheck(check: LuaStmt) {
        if (check !in checksAfter) checksAfter += check
    }
}

/**
 * Functions and lambdas being transformed, innermost last. `return` targets one of these; inlined
 * lambdas (scope functions) don't create a Lua function, so returning from them jumps to [endLabel].
 */
internal class FunctionFrame(val kind: Kind, val labels: Set<String>) {
    enum class Kind { Function, Lambda, Inline }

    var sink: ((LuaExpr) -> List<LuaStmt>)? = null
    var endLabel: String? = null
}

/** Something assignable: a variable, or a property of an object (possibly with accessors). */
internal class Target(val read: LuaExpr, val write: (LuaExpr) -> LuaStmt)
