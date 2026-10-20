package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall

private val LIST_OF_SIZE = setOf("kotlin/collections/List", "kotlin/collections/MutableList")

/**
 * `List(n) { init }` and `MutableList(n) { init }` with a lambda literal: a loop filling a plain table with the lambda
 * inlined, made a list at the end (`__K2L_ListWrap`), as `__K2L_ListOfSize` does with a closure called per element.
 * Null for other calls.
 */
internal fun FileTransformer.loopedListOfSize(callableId: String?, call: KaCallableMemberCall<*, *>): LuaExpr? = with(session) {
    if (callableId !in LIST_OF_SIZE || call !is KaFunctionCall<*>) return null
    val args = callArguments(call)
    val size = args.getOrNull(0) ?: return null
    val lambda = lambdaLiteral(args.getOrNull(1)) ?: return null
    if (args.size != 2 || hasNonLocalJump(lambda)) return null
    val n = cache(expression(size), "size")
    val out = declare("out", LuaTable(emptyList()))
    val i = ctx.temp("i")
    val params = lambda.functionLiteral.valueParameters
    val index = if (params.isEmpty()) "it" else forEachVar(params, 0, "it")
    val body = collect {
        emit(LuaLocal(listOf(index), listOf(LuaBinary(LuaBinOp.Sub, LuaName(i), LuaNumber("1")))))
        val value = inlineValue(lambda, listOf(LuaName(index).also { stable += it }), null)
        emit(assign(LuaIndex(out, LuaName(i)), value))
    }
    emit(LuaNumericFor(i, LuaNumber("1"), n, null, body))
    lualibCall("ListWrap", out, n)
}
