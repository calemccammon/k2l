package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtLambdaExpression
import org.jetbrains.kotlin.psi.KtPsiUtil
import org.jetbrains.kotlin.psi.KtQualifiedExpression

/**
 * One key comparison of a fused comparator: the keys of `a` and `b` ([first] is evaluated first, as the lualib's selector
 * calls are), compared as Ints when [exact], else with compareValues.
 */
internal class ComparatorStep(val first: LuaExpr, val second: LuaExpr, val exact: Boolean)

/** The parameters of a fused comparator and its key comparisons so far, for a `thenBy` to extend. */
internal class FusedComparator(val a: String, val b: String, val steps: List<ComparatorStep>)

/**
 * `compareBy { it.x }`, `compareByDescending { }`, `compareBy({ }, { })` and `.thenBy { }` / `.thenByDescending { }` on
 * one of those, with lambdas whose body is one expression: one Lua function comparing the keys in turn, with the
 * selector bodies inlined (no selector call, no closure per step) and Int keys compared directly, instead of the lualib's
 * chain of closures calling compareValues. Null when the call does not have that shape.
 */
internal fun CallSite.fusedComparator(descending: Boolean, base: FusedComparator?): LuaExpr? {
    val transformer = transformer
    val ctx = transformer.ctx
    val lambdas = selectorLambdas() ?: return null
    if (lambdas.size != args.size || args.isEmpty()) return null
    val a = base?.a ?: ctx.temp("a")
    val b = base?.b ?: ctx.temp("b")
    val steps = base?.steps.orEmpty().toMutableList()
    for ((i, lambda) in lambdas.withIndex()) {
        steps += step(args[i] as? LuaFunction ?: return null, lambda, a, b, descending) ?: return null
    }
    val fused = FusedComparator(a, b, steps)
    return comparatorFunction(fused).also { transformer.fusedComparators[it] = fused }
}

/** The key comparison of the selector [fn] (from [lambda]) with its parameter bound to [a] and [b]; null unless one `return`. */
private fun CallSite.step(fn: LuaFunction, lambda: KtLambdaExpression, a: String, b: String, descending: Boolean): ComparatorStep? {
    val param = fn.params.singleOrNull()?.takeIf { !fn.isVararg } ?: return null
    val body = (fn.body.singleOrNull() as? LuaReturn)?.values?.singleOrNull() ?: return null
    val keyA = substituteName(body, param, a) ?: return null
    val keyB = substituteName(body, param, b) ?: return null
    val exact = isIntKey(lambda)
    return if (descending) ComparatorStep(keyB, keyA, exact) else ComparatorStep(keyA, keyB, exact)
}

/** `.thenBy { }` on a fused comparator: the same function with one more step. */
internal fun CallSite.thenBy(descending: Boolean): LuaExpr? =
    transformer.fusedComparators[receiver]?.let { fusedComparator(descending, it) }

/** The Kotlin lambdas passed as the call's arguments, when every argument is one. */
private fun CallSite.selectorLambdas(): List<KtLambdaExpression>? {
    val call = element as? KtCallExpression ?: (element as? KtQualifiedExpression)?.selectorExpression as? KtCallExpression
    val arguments = call?.valueArguments ?: return null
    return arguments.map { (it.getArgumentExpression()?.let(KtPsiUtil::safeDeparenthesize) as? KtLambdaExpression) ?: return null }
}

/** Whether the lambda's result is a non-null Int, Short or Byte (compared with `<` like the JVM). */
private fun CallSite.isIntKey(lambda: KtLambdaExpression): Boolean = with(session) {
    val type = lambda.bodyExpression?.statements?.lastOrNull()?.expressionType?.withoutFlexibility ?: return false
    !type.isMarkedNullable && (type.isIntType || type.isShortType || type.isByteType)
}

private fun CallSite.comparatorFunction(fused: FusedComparator): LuaFunction {
    val compareValues = ref("Compare", "__K2L_CompareValues")
    val ctx = transformer.ctx
    val body = mutableListOf<LuaStmt>()
    for ((i, step) in fused.steps.withIndex()) {
        val last = i == fused.steps.lastIndex
        if (step.exact) {
            val x = ctx.temp("x")
            val y = ctx.temp("y")
            body += LuaLocal(listOf(x, y), listOf(step.first, step.second))
            val order = LuaBinary(
                LuaBinOp.Or,
                LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Lt, LuaName(x), LuaName(y)), LuaNumber("-1")),
                LuaNumber("1"),
            )
            body += LuaIf(LuaBinary(LuaBinOp.Ne, LuaName(x), LuaName(y)), listOf(LuaReturn(listOf(order))))
            if (last) body += LuaReturn(listOf(LuaNumber("0")))
        } else if (last) {
            body += LuaReturn(listOf(LuaCall(compareValues, listOf(step.first, step.second))))
        } else {
            val c = ctx.temp("c")
            body += LuaLocal(listOf(c), listOf(LuaCall(compareValues, listOf(step.first, step.second))))
            body += LuaIf(LuaBinary(LuaBinOp.Ne, LuaName(c), LuaNumber("0")), listOf(LuaReturn(listOf(LuaName(c)))))
        }
    }
    return LuaFunction(listOf(fused.a, fused.b), body, hoistable = true)
}

/** [e] with the name [from] replaced by [to]; null when [e] contains a function or table (which might rebind or capture it). */
private fun substituteName(e: LuaExpr, from: String, to: String): LuaExpr? {
    var substitutable = true
    fun sub(x: LuaExpr): LuaExpr = when (x) {
        is LuaName -> if (x.name == from) LuaName(to) else x
        is LuaIndex -> LuaIndex(sub(x.target), sub(x.key))
        is LuaCall -> LuaCall(sub(x.fn), x.args.map(::sub))
        is LuaMethodCall -> LuaMethodCall(sub(x.target), x.method, x.args.map(::sub))
        is LuaBinary -> LuaBinary(x.op, sub(x.left), sub(x.right))
        is LuaUnary -> LuaUnary(x.op, sub(x.operand))
        LuaNil, is LuaBool, is LuaNumber, is LuaString -> x
        is LuaFunction, is LuaTable -> x.also { substitutable = false }
    }
    return sub(e).takeIf { substitutable }
}
