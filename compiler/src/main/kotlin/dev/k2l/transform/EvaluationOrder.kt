package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

// Evaluating operands in Kotlin's order when some need statements before them.

/**
 * Transforms [exprs] left to right. If a later expression needs preceding statements, earlier
 * results are cached in locals first so evaluation order is preserved; with [unlessReads], statements that only compute
 * values without calls into locals (`local ____receiver = a.b` of `a.b?.c`) do not count.
 */
internal fun FileTransformer.ordered(exprs: List<KtExpression>, unlessReads: Boolean = false): List<LuaExpr> = with(session) {
    val results = exprs.map { withPreceding { expression(it) } }
    val last = results.indexOfLast { (_, pre) -> if (unlessReads) pre.any { !isLocalRead(it) } else pre.isNotEmpty() }
    return results.mapIndexed { i, (value, pre) ->
        emitAll(pre)
        if (i < last) cache(touchedIfCached(exprs[i], value), "arg") else value
    }
}

/**
 * The arguments [exprs] of a call, transformed in the order they are written (named arguments can be in any order), after
 * the first [receivers], and returned in the order of [exprs]. Where that would run some of them in another order, the values
 * are stored in locals first.
 */
internal fun FileTransformer.orderedAsWritten(exprs: List<KtExpression>, receivers: Int = 0): List<LuaExpr> {
    val written = exprs.take(receivers) + exprs.drop(receivers).sortedBy { it.textRange.startOffset }
    if (written == exprs) return ordered(exprs)
    val values = ordered(written).toMutableList()
    val runs = written.indices.filter { !isStable(values[it]) && values[it] !is LuaFunction }
    if (exprs.map(written::indexOf).filter { it in runs } != runs) runs.forEach { values[it] = cache(values[it], "arg") }
    return exprs.map { values[written.indexOf(it)] }
}

internal fun FileTransformer.isLocalRead(stmt: LuaStmt): Boolean = stmt is LuaLocal && stmt.values.all(::isRead)

/** Reads and operators, no calls: a local holding one can be computed before or after the expressions around it. */
private fun FileTransformer.isRead(e: LuaExpr): Boolean = when (e) {
    is LuaIndex -> isRead(e.target) && isRead(e.key)
    is LuaBinary -> isRead(e.left) && isRead(e.right)
    is LuaUnary -> isRead(e.operand)
    else -> isStable(e) || e is LuaName
}

/**
 * An object (or companion) with observable initialization named as a qualifier (`Registry.register(...)`) is initialized when
 * the member is reached; when the qualifier is cached in a local because a later argument needs statements, the cached
 * value touches it, so it is initialized before the later arguments run, as in Kotlin.
 */
private fun FileTransformer.touchedIfCached(expr: KtExpression, value: LuaExpr): LuaExpr = with(session) {
    if ((expr.parent as? KtQualifiedExpression)?.receiverExpression != expr) return value // a value is touched already
    val name = when (val e = KtPsiUtil.safeDeparenthesize(expr)) {
        is KtNameReferenceExpression -> e
        is KtDotQualifiedExpression -> e.selectorExpression as? KtNameReferenceExpression
        else -> null
    } ?: return value
    if (name.mainReference.resolveToSymbol() !is KaClassLikeSymbol) return value
    val target = name.expressionType?.expandedSymbol?.psi as? KtObjectDeclaration ?: return value
    return if (lazyInit.isObservable(target)) lualibCall("TouchObject", value) else value
}
