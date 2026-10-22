package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/** Library properties that are fields of the lualib values (or Lua's own), so reading them runs no program code. */
private val FIELD_PROPERTIES = setOf(
    "kotlin/String.length", "kotlin/collections/List.size", "kotlin/collections/Collection.size", "kotlin/Pair.first",
    "kotlin/Pair.second", "kotlin/Triple.first", "kotlin/Triple.second", "kotlin/Triple.third", "kotlin/collections/Map.Entry.key",
    "kotlin/collections/Map.Entry.value", "kotlin/collections/IndexedValue.index", "kotlin/collections/IndexedValue.value",
    "kotlin/Enum.name", "kotlin/Enum.ordinal",
)

private val PURE_OPERATORS = setOf(
    KtTokens.PLUS, KtTokens.MINUS, KtTokens.MUL, KtTokens.LT, KtTokens.GT, KtTokens.LTEQ, KtTokens.GTEQ, KtTokens.EQEQ,
    KtTokens.EXCLEQ, KtTokens.ANDAND, KtTokens.OROR, KtTokens.EXCL,
)

/**
 * Whether the selector passed to `sortedBy` and the like (the last argument of the call [element]) runs no code anybody
 * could observe: a lambda whose body reads its parameter, fields and constants, combined with arithmetic and comparisons
 * on numbers, booleans and strings; or a reference to such a field. Then the lualib may compute each element's key once
 * instead of once per comparison, with the same result.
 */
internal fun FileTransformer.isPureSelector(element: KtExpression): Boolean {
    val call = element as? KtCallExpression ?: (element as? KtQualifiedExpression)?.selectorExpression as? KtCallExpression
    val argument = call?.valueArguments?.lastOrNull()?.getArgumentExpression()?.let { KtPsiUtil.safeDeparenthesize(it) }
    return when (argument) {
        is KtLambdaExpression -> argument.bodyExpression?.statements?.singleOrNull()?.let { isPureKey(it) } == true
        is KtCallableReferenceExpression -> argument.receiverExpression != null && isFieldRead(argument.callableReference)
        else -> false
    }
}

private fun FileTransformer.isPureKey(e: KtExpression): Boolean = with(session) {
    when (e) {
        is KtParenthesizedExpression -> e.expression?.let { isPureKey(it) } == true

        is KtConstantExpression -> true

        is KtStringTemplateExpression -> !e.hasInterpolation()

        is KtNameReferenceExpression -> when (val symbol = e.mainReference.resolveToSymbol()) {
            is KaValueParameterSymbol -> true
            is KaLocalVariableSymbol -> symbol.isVal
            else -> isFieldRead(e)
        }

        is KtQualifiedExpression -> {
            val selector = e.selectorExpression as? KtNameReferenceExpression
            isPureKey(e.receiverExpression) && selector != null && isFieldRead(selector)
        }

        is KtPrefixExpression, is KtBinaryExpression -> isPureOperation(e as KtOperationExpression)

        else -> false
    }
}

/** `-x`, `!x`, `a + b`, `a < b`, ... on numbers, booleans and strings, with pure operands. */
private fun FileTransformer.isPureOperation(e: KtOperationExpression): Boolean = with(session) {
    val operands = when (e) {
        is KtPrefixExpression -> listOfNotNull(e.baseExpression)
        is KtBinaryExpression -> listOfNotNull(e.left, e.right).takeIf { it.size == 2 }.orEmpty()
        else -> emptyList()
    }
    val token = e.operationReference.getReferencedNameElementType()
    val primitive = operands.isNotEmpty() && operands.all { o -> o.expressionType?.let { it.isPrimitive || it.isStringType } == true }
    token in PURE_OPERATORS && primitive && operands.all { isPureKey(it) }
}

/** A read of a member property that is a plain table field: declared without accessors, or a field of a library value. */
private fun FileTransformer.isFieldRead(reference: KtSimpleNameExpression): Boolean = with(session) {
    val symbol = reference.mainReference.resolveToSymbol() as? KaCallableSymbol ?: return false
    val psi = symbol.psi
    if (psi is KtNamedDeclaration && classes.isSource(psi)) return isMemberProperty(psi) && !hasAccessors(psi)
    return symbol.callableId?.toString() in FIELD_PROPERTIES
}
