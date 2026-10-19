package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.psi.KtExpression

private val RESULT_LAMBDAS = setOf("getOrElse", "onFailure", "onSuccess", "fold", "map", "recover")

private fun field(target: LuaExpr, name: String): LuaExpr = LuaIndex(target, LuaString(name))

/** A `Result` in the generated code: its fields (see `Result.lua`) and the tests of which one it is. */
private class ResultParts(val result: LuaExpr) {
    val failure = field(result, "exception")
    val value = field(result, "value")
    val failed = LuaBinary(LuaBinOp.Ne, failure, LuaNil)
    val succeeded = LuaBinary(LuaBinOp.Eq, failure, LuaNil)
}

/**
 * `Result.getOrElse`, `onSuccess`, `onFailure`, `fold`, `map` and `recover` with a lambda that has a non-local `return`: expanded
 * in place on the `value` and `exception` fields of the result (see `Result.lua`). Without such a return they are method calls.
 */
internal fun FileTransformer.inlinedResultCall(
    callableId: String?,
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
): LuaExpr? = with(session) {
    if (call !is KaFunctionCall<*> || callableId == null || !callableId.startsWith("kotlin/")) return null
    val name = callableId.removePrefix("kotlin/").takeIf { it in RESULT_LAMBDAS } ?: return null
    val type = receiverExpr?.expressionType ?: call.extensionReceiver?.type
    if (type?.expandedSymbol?.classId?.asString() != "kotlin/Result") return null
    val args = callArguments(call).map { it!! }
    if (args.mapNotNull(::lambdaLiteral).none { hasNonLocalReturn(it) }) return null
    val parts = ResultParts(cache(implicit ?: expression(receiverExpr ?: return null), "result"))
    return when (name) {
        "getOrElse", "fold" -> resultValue(parts, args)
        "onFailure", "onSuccess" -> resultAction(parts, args[0], name == "onFailure")
        else -> resultTransform(parts, args[0], name == "recover")
    }
}

/** What a lambda of a result does with [argument]: its value goes to [target], or it only runs when [target] is null. */
private fun FileTransformer.resultBranch(lambda: KtExpression, argument: LuaExpr, target: LuaName?, wrap: (LuaExpr) -> LuaExpr = { it }) =
    collect {
        if (target == null || lambdaReturnsUnit(lambda)) {
            inlineLambda(lambda, listOf(argument), null, null)
        } else {
            emit(assign(target.name, wrap(inlineValue(lambda, listOf(argument), null))))
        }
    }

/** `getOrElse { exception -> }` and `fold(onSuccess, onFailure)`. */
private fun FileTransformer.resultValue(parts: ResultParts, lambdas: List<KtExpression>): LuaExpr {
    val out = declare("value")
    if (lambdas.size == 1) {
        emit(LuaIf(parts.failed, resultBranch(lambdas[0], parts.failure, out), listOf(assign(out.name, parts.value))))
    } else {
        emit(LuaIf(parts.succeeded, resultBranch(lambdas[0], parts.value, out), resultBranch(lambdas[1], parts.failure, out)))
    }
    return out
}

/** `onFailure { }` and `onSuccess { }`: the result itself. */
private fun FileTransformer.resultAction(parts: ResultParts, lambda: KtExpression, onFailure: Boolean): LuaExpr {
    val test = if (onFailure) parts.failed else parts.succeeded
    emit(LuaIf(test, resultBranch(lambda, if (onFailure) parts.failure else parts.value, null)))
    return parts.result
}

/** `map { }` and `recover { }`: a new success when the lambda ran, else the result itself. */
private fun FileTransformer.resultTransform(parts: ResultParts, lambda: KtExpression, recovering: Boolean): LuaExpr {
    val out = declare("result", parts.result)
    val success = lualibRef(RESULT_FEATURE, "__K2L_Result")
    val wrap = { v: LuaExpr -> LuaCall(LuaIndex(success, LuaString("success")), listOf(v)) }
    val test = if (recovering) parts.failed else parts.succeeded
    emit(LuaIf(test, resultBranch(lambda, if (recovering) parts.failure else parts.value, out, wrap)))
    return out
}
