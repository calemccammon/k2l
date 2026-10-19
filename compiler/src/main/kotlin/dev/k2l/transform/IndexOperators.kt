package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCompoundArrayAccessCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** The `operator fun get` and `set` of the program that an index assignment (`m[i, j] = v`, `m[i] += v`, `m[i, j]++`) calls. */
internal class IndexOperators(val get: KtNamedFunction?, val set: KtNamedFunction)

/**
 * The source operators [e] resolves to as the target of an assignment, or null when its `set` is a library function. For
 * `+=` and `++` the Analysis API resolves the enclosing expression to both calls; for `=` the access itself is the `set`.
 */
internal fun FileTransformer.sourceIndexOperators(e: KtArrayAccessExpression): IndexOperators? = with(session) {
    var owner: PsiElement? = e.parent
    while (owner is KtParenthesizedExpression) owner = owner.parent
    val compound = (owner as? KtExpression)?.resolveToCall()?.successfulCallOrNull<KaCompoundArrayAccessCall>()
    val set = compound?.setterCall?.symbol?.psi
        ?: e.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol?.psi
    if (set !is KtNamedFunction || set.name != "set" || !classes.isSource(set)) return null
    val get = compound?.getterCall?.symbol?.psi as? KtNamedFunction
    return IndexOperators(get?.takeIf { classes.isSource(it) }, set)
}

/** Reads and writes through [operators] (a plain `=` resolves no getter, and does not read). */
internal fun FileTransformer.sourceIndexTarget(
    e: KtArrayAccessExpression,
    operators: IndexOperators,
    receiver: LuaExpr,
    keys: List<LuaExpr>,
): Target {
    val read = operators.get?.let { indexCall(e, it, receiver, keys) } ?: LuaNil
    return Target(read) { LuaCallStmt(indexCall(e, operators.set, receiver, keys + it)) }
}

/** A member operator is a method; an extension takes the receiver first. */
private fun FileTransformer.indexCall(e: KtElement, fn: KtNamedFunction, receiver: LuaExpr, args: List<LuaExpr>): LuaExpr = when {
    fn.receiverTypeReference == null -> LuaMethodCall(receiver, naming.function(fn), args)
    fn.containingClassOrObject != null -> unsupported(e, "An index operator declared as a member extension")
    else -> LuaCall(if (fn.isTopLevel) topLevelRef(fn) else LuaName(naming.function(fn)), listOf(receiver) + args)
}
