package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/*
 * `Unit` as a value. A Kotlin function returning Unit returns nothing in Lua, and a call of one as a statement stays a plain
 * call. Where a Unit expression is used as a value (an argument, an initializer, an element, a string template, a value of
 * type Any or T), the expression runs as a statement and the value is the runtime object `__K2L_Unit` (see Unit.lua),
 * which prints as `kotlin.Unit`.
 */

/** The Unit object. */
internal fun FileTransformer.unitObject(): LuaExpr = lualibRef("Unit", "__K2L_Unit")

/** Whether [e] (not in statement position) is an expression of type Unit whose Lua value would be nil: a call, `if`, `when`, ... */
internal fun FileTransformer.isUnitValued(e: KtExpression): Boolean = with(session) {
    val syntax = e is KtCallExpression || e is KtDotQualifiedExpression || e is KtIfExpression || e is KtWhenExpression ||
        e is KtTryExpression || e is KtArrayAccessExpression ||
        (e is KtBinaryExpression && e.operationToken == KtTokens.IDENTIFIER)
    syntax && e !in callState.overrides && e.expressionType.let { it != null && it.isUnitType && !it.isMarkedNullable }
}

/** Whether [e] names the `Unit` object. */
internal fun FileTransformer.isUnitObject(e: KtExpression): Boolean = with(session) {
    e is KtNameReferenceExpression && e.getReferencedName() == "Unit" &&
        (e.mainReference.resolveToSymbol() as? KaClassLikeSymbol)?.classId?.asString() == "kotlin/Unit"
}

/** A Unit expression used as a value: it runs as a statement, and its value is the Unit object. */
internal fun FileTransformer.unitValueOf(e: KtExpression): LuaExpr = with(session) {
    asStatement(e) { statement(e) }
    return unitObject()
}

/** Runs [block], in which [e] is in statement position: if it is of type Unit, its value is not needed. */
internal inline fun <T> FileTransformer.asStatement(e: KtExpression, block: () -> T): T {
    val saved = statementExpression
    statementExpression = e
    try {
        return block()
    } finally {
        statementExpression = saved
    }
}

/**
 * Whether [e], a lambda returning Unit, is passed or assigned where a function returning a value is expected, such as
 * `() -> R` of `runCatching { }` or `(T) -> R` of `map { }`: the lambda then returns the Unit object.
 */
internal fun FileTransformer.resultExpected(e: KtLambdaExpression): Boolean = with(session) {
    val expr = e.parent as? KtLabeledExpression ?: e
    // `val f: () -> Any = { unitCall() }`
    val argument = expr.parent as? KtValueArgument ?: return (expr.expectedType as? KaFunctionType)?.returnType?.isUnitType == false
    val callElement = PsiTreeUtil.getParentOfType(argument, KtCallElement::class.java) ?: return false
    val call = callElement.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return false
    val declared = call.valueArgumentMapping[expr]?.symbol?.returnType as? KaFunctionType ?: return false
    !declared.returnType.isUnitType
}

/** Whether [frame] is a function or lambda whose Lua result is not used: it returns Unit (and not the Unit object). */
internal fun FileTransformer.returnsNothing(frame: FunctionFrame): Boolean = with(session) {
    when (val psi = frame.psi) {
        is KtNamedFunction -> psi.returnType.let { it.isUnitType && !it.isMarkedNullable }

        is KtPropertyAccessor -> psi.isSetter

        is KtFunctionLiteral ->
            !frame.unitResult && ((psi.parent as? KtLambdaExpression)?.expressionType as? KaFunctionType)?.returnType?.isUnitType == true

        else -> false
    }
}

/**
 * Notes [arg] if it is a function value returning Unit, such as `::work` or a `() -> Unit` variable, passed for a parameter
 * whose function type has a result (`runCatching(::work)`): the argument is then wrapped by [returningUnit].
 */
internal fun FileTransformer.noteUnitResult(parameter: KaValueParameterSymbol, arg: KtExpression): Unit = with(session) {
    val declared = parameter.returnType as? KaFunctionType ?: return
    if (declared.returnType.isUnitType || lambdaLiteral(arg) != null) return
    val actual = (arg.expressionType as? KaFunctionType)?.returnType ?: return
    if (actual.isUnitType && !actual.isMarkedNullable) callState.unitResults += arg
}

/**
 * Whether [e], a function reference or a function value returning Unit (`::work`, a `() -> Unit` variable), is used where a
 * function type with a result is expected other than as an argument for such a parameter (see [noteUnitResult]):
 * `val h: () -> Any = ::work`, `return ::work`, `listOf<() -> Any>(::work)`. Its value is then wrapped by [returningUnit].
 */
internal fun FileTransformer.convertsUnitFunction(e: KtExpression): Boolean = with(session) {
    if (e !is KtCallableReferenceExpression && e !is KtNameReferenceExpression && e !is KtDotQualifiedExpression) return false
    if (e in callState.unitResults) return false
    val actual = (e.expressionType as? KaFunctionType)?.returnType ?: return false
    if (!actual.isUnitType || actual.isMarkedNullable) return false
    val expected = (e.expectedType as? KaFunctionType)?.returnType ?: return false
    !expected.isUnitType
}

/** [fn], a function returning nothing, as one returning the Unit object. */
internal fun FileTransformer.returningUnit(fn: LuaExpr): LuaExpr {
    val target = if (fn is LuaName) fn else cache(fn, "fn")
    val body = listOf(LuaCallStmt(LuaCall(target, listOf(LuaName("...")))), LuaReturn(listOf(unitObject())))
    return LuaFunction(emptyList(), body, isVararg = true)
}
