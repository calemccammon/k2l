package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.*

/**
 * The enum class of the program whose `entries` (or `values()`) [e] is. Reading its elements needs no copy of the list
 * `__K2L_EnumValues` makes: they are the class's `____values` table, which never changes.
 */
internal fun FileTransformer.enumEntriesOf(e: KtExpression?): KtClass? = with(session) {
    val ex = e?.let { KtPsiUtil.safeDeparenthesize(it) } ?: return null
    val selector = (ex as? KtDotQualifiedExpression)?.selectorExpression ?: ex
    val name = when (selector) {
        is KtNameReferenceExpression -> selector.getReferencedName()

        is KtCallExpression -> (selector.calleeExpression as? KtNameReferenceExpression)?.getReferencedName()
            ?.takeIf { selector.valueArguments.isEmpty() }

        else -> null
    }
    if (name != "entries" && name != "values") return null
    val call = ex.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    val symbol = call.partiallyAppliedSymbol.symbol
    val psi = symbol.psi
    if (symbol.callableId?.callableName?.asString() != name || (psi != null && psi !is KtClass)) return null
    val id = symbol.callableId?.classId ?: return null
    return (classes.classInFile(id) as? KtClass)?.takeIf { it.isEnum() }
}

/** The `____values` table of an enum class, cached in a local. */
internal fun FileTransformer.enumValuesTable(c: KtClass): LuaExpr = cache(LuaIndex(classRef(c), LuaString(ENUM_VALUES)), "values")

/** `for (x in E.entries)`: over the class's `____values`, which nothing changes. */
internal fun FileTransformer.enumEntriesSource(rangeExpr: KtExpression): LoopSource? {
    val c = enumEntriesOf(rangeExpr) ?: return null
    val values = enumValuesTable(c)
    return LoopSource(values, LuaUnary(LuaUnOp.Len, values), null, null)
}

/** `xs[i]` read: [enumEntryAt], or the call of `get` (see CollectionMappings). */
internal fun FileTransformer.arrayAccess(e: KtArrayAccessExpression): LuaExpr = enumEntryAt(e) ?: with(session) { call(e, e) }

/**
 * `E.entries[i]`: the entry read from `____values` (entries are never nil), or the IndexOutOfBoundsException the list
 * of entries throws.
 */
internal fun FileTransformer.enumEntryAt(e: KtArrayAccessExpression): LuaExpr? = with(session) {
    val c = enumEntriesOf(e.arrayExpression) ?: return null
    val index = e.indexExpressions.singleOrNull() ?: return null
    if (index.expressionType?.isIntType != true) return null
    val values = enumValuesTable(c)
    val i = cache(expression(index), "index")
    val fail = lualibCall("IndexError", i, LuaUnary(LuaUnOp.Len, values))
    LuaBinary(LuaBinOp.Or, CollectionMappings.index(values, i), fail)
}
