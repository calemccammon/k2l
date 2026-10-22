package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

// Values of expressions that need statements (if, when, try and blocks as values), written into a ValueSink.

internal fun FileTransformer.needsBranching(e: KtExpression): Boolean = with(session) {
    val ex = KtPsiUtil.safeDeparenthesize(e)
    return ex is KtWhenExpression || ex is KtTryExpression || (ex is KtIfExpression && !canTernary(ex))
}

/**
 * Emits statements that compute [e] and hand its value to [sink], pushing the sink into the
 * branches of `if`/`when` so no temporary is needed.
 */
internal fun FileTransformer.valueInto(e: KtExpression, sink: ValueSink): List<LuaStmt> = with(session) {
    collect {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        when {
            ex is KtIfExpression && !canTernary(ex) -> ifInto(ex, sink)

            ex is KtWhenExpression -> whenInto(ex, sink)

            ex is KtTryExpression -> tryInto(ex, sink)

            ex is KtBlockExpression -> {
                ex.statements.dropLast(1).forEach { statement(it) }
                ex.statements.lastOrNull()?.let { emitAll(valueInto(it, sink)) }
            }

            isJump(ex) -> statement(ex)

            else -> emitAll(sink(expression(ex)))
        }
    }
}

internal fun FileTransformer.isJump(e: KtExpression) = with(session) {
    e is KtReturnExpression || e is KtBreakExpression || e is KtContinueExpression || e is KtThrowExpression ||
        e.expressionType.let { it != null && it.isNothingType && !it.isMarkedNullable }
}

private fun FileTransformer.ifInto(e: KtIfExpression, sink: ValueSink): Unit = with(session) {
    val cond = expression(e.condition ?: return)
    val then = e.then?.let { valueInto(it, sink) }.orEmpty()
    val orElse = e.`else`?.let { valueInto(it, sink) }
    emit(LuaIf(cond, then, orElse))
}

/**
 * `c and a or b` is only equivalent to `if (c) a else b` when `a` can never be nil or false, and
 * when no operand needs preceding statements (checked syntactically, so this has no side effects).
 */
internal fun FileTransformer.canTernary(e: KtIfExpression): Boolean = with(session) {
    val cond = e.condition ?: return false
    val then = e.then?.let { singleExpression(it) } ?: return false
    val orElse = e.`else`?.let { singleExpression(it) } ?: return false
    val thenType = then.expressionType ?: return false
    if (canBeFalsyInLua(thenType)) return false
    return !isJump(orElse) && listOf(cond, then, orElse).none { mayNeedStatements(it) }
}

/** Nullable, Boolean, Nothing and Unit values may be nil or false in Lua. */
private fun FileTransformer.canBeFalsyInLua(t: KaType) = with(session) {
    t.isMarkedNullable || t.isBooleanType || t.isNothingType || t.isUnitType
}

internal fun FileTransformer.ternary(e: KtIfExpression): LuaExpr = with(session) {
    val parts = listOf(e.condition!!, singleExpression(e.then!!)!!, singleExpression(e.`else`!!)!!).map { expression(it) }
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, parts[0], parts[1]), parts[2])
}

internal fun FileTransformer.mayNeedStatements(e: KtExpression): Boolean = with(session) {
    var found = false
    e.accept(object : KtTreeVisitorVoid() {
        override fun visitElement(element: PsiElement) {
            if (found) return
            if (needsStatements(element) || mayExpandOrCheck(element)) {
                found = true
                return
            }
            super.visitElement(element)
        }
    })
    return found
}

private fun FileTransformer.mayExpandOrCheck(element: PsiElement) = with(session) {
    (element is KtCallExpression && mayExpandInline(element)) || (element is KtBinaryExpressionWithTypeRHS && mayCheckCast(element))
}

private fun FileTransformer.needsStatements(element: PsiElement) = when (element) {
    is KtIfExpression, is KtWhenExpression, is KtTryExpression, is KtSafeQualifiedExpression, is KtLambdaExpression,
    is KtObjectLiteralExpression,
    -> true

    is KtBinaryExpression -> element.operationToken == KtTokens.ELVIS

    is KtUnaryExpression -> element.operationToken == KtTokens.PLUSPLUS || element.operationToken == KtTokens.MINUSMINUS

    else -> false
}

private fun FileTransformer.singleExpression(e: KtExpression): KtExpression? = with(session) {
    if (e is KtBlockExpression) e.statements.singleOrNull()?.takeIf { it !is KtDeclaration } else e
}

internal fun FileTransformer.branchingValue(e: KtExpression): LuaExpr = with(session) {
    val name = ctx.temp("temp")
    emit(LuaLocal(listOf(name)))
    emitAll(valueInto(e) { listOf(assign(name, it)) })
    return LuaName(name)
}
