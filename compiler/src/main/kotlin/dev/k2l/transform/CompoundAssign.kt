package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCompoundVariableAccessCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.KtBinaryExpression
import org.jetbrains.kotlin.psi.KtNamedFunction

/**
 * The value of `a op= b` when it is `a = a op b` through an `operator fun` (`var total: Money; total += x`): the
 * call of that operator, or null when the expression does not resolve that way.
 */
internal fun FileTransformer.compoundOperatorCall(e: KtBinaryExpression): LuaExpr? = with(session) {
    val operation = e.resolveToCall()?.successfulCallOrNull<KaCompoundVariableAccessCall>()?.compoundOperation ?: return null
    val symbol = operation.operationCall.symbol
    val left = e.left ?: return null
    val right = e.right ?: return null
    val psi = symbol.psi
    if (psi is KtNamedFunction && classes.isSource(psi)) return sourceFunctionCall(psi, listOf(right), left, null)
    return libraryCall(symbol.name.asString(), symbol.callableId?.toString(), left, null, left.expressionType, listOf(right), e)
}
