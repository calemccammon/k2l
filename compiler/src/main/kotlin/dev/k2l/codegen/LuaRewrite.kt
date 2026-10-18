package dev.k2l.codegen

/**
 * Rewrites the leaf statements of this list, recursing into the bodies of `if`, `do` and loops (not into nested
 * functions). [transform] receives each non-compound statement and its loop depth (0 outside any loop nested in
 * this list) and returns the statements that replace it.
 */
fun List<LuaStmt>.flatMapStatements(depth: Int = 0, transform: (LuaStmt, Int) -> List<LuaStmt>): List<LuaStmt> = flatMap { s ->
    fun body(list: List<LuaStmt>, d: Int) = list.flatMapStatements(d, transform)
    when (s) {
        is LuaIf -> listOf(LuaIf(s.cond, body(s.then, depth), s.orElse?.let { body(it, depth) }))
        is LuaDo -> listOf(LuaDo(body(s.body, depth)))
        is LuaWhile -> listOf(LuaWhile(s.cond, body(s.body, depth + 1)))
        is LuaRepeat -> listOf(LuaRepeat(body(s.body, depth + 1), s.until))
        is LuaNumericFor -> listOf(s.copy(body = body(s.body, depth + 1)))
        is LuaGenericFor -> listOf(s.copy(body = body(s.body, depth + 1)))
        else -> transform(s, depth)
    }
}

/** Like [flatMapStatements], with a one-to-one [transform]. */
fun List<LuaStmt>.mapStatements(depth: Int = 0, transform: (LuaStmt, Int) -> LuaStmt): List<LuaStmt> =
    flatMapStatements(depth) { s, d -> listOf(transform(s, d)) }

/** Visits every non-compound statement, recursing into the bodies of `if`, `do` and loops (not nested functions). */
fun List<LuaStmt>.forEachLeafStatement(action: (LuaStmt) -> Unit) {
    for (s in this) {
        when (s) {
            is LuaIf -> {
                s.then.forEachLeafStatement(action)
                s.orElse?.forEachLeafStatement(action)
            }

            is LuaDo -> s.body.forEachLeafStatement(action)

            is LuaWhile -> s.body.forEachLeafStatement(action)

            is LuaRepeat -> s.body.forEachLeafStatement(action)

            is LuaNumericFor -> s.body.forEachLeafStatement(action)

            is LuaGenericFor -> s.body.forEachLeafStatement(action)

            else -> action(s)
        }
    }
}
