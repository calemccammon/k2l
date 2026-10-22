package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.getQualifiedExpressionForSelector

/**
 * `x in map.keys`, `map.keys.contains(x)` and `map.values.contains(x)`: `containsKey`/`containsValue` on the map, as
 * `keys` and `values` are snapshots that would be copied for each test. Null for any other `contains`.
 */
internal fun mapViewContains(site: CallSite): LuaExpr? {
    val view = site.self as? LuaMethodCall ?: return null
    val method = when (view.method) {
        "getKeys" -> "containsKey"
        "getValues" -> "containsValue"
        else -> return null
    }
    if (view.args.isNotEmpty()) return null
    val receiver = containsReceiver(site.element) ?: return null
    val viewAccess = KtPsiUtil.safeDeparenthesize(receiver) as? KtDotQualifiedExpression ?: return null
    val name = (viewAccess.selectorExpression as? KtNameReferenceExpression)?.getReferencedName()
    if (name != (if (method == "containsKey") "keys" else "values")) return null
    val mapType = with(site.session) { viewAccess.receiverExpression.expressionType }
    return if (site.kindOf(mapType) == CollectionKind.Map) LuaMethodCall(view.target, method, site.args) else null
}

/** The collection a `contains` call tests: the right side of `in`, the range of a `when` `in` condition, or the receiver. */
private fun containsReceiver(e: KtExpression): KtExpression? = when {
    e is KtBinaryExpression -> e.right
    e.parent is KtWhenConditionInRange -> (e.parent as KtWhenConditionInRange).rangeExpression
    e is KtQualifiedExpression -> e.receiverExpression
    else -> e.getQualifiedExpressionForSelector()?.receiverExpression
}
