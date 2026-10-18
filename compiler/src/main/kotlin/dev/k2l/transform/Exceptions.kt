package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.psi.*

internal fun FileTransformer.throwStatement(e: KtThrowExpression): Unit = with(session) {
    val thrown = e.thrownExpression ?: return
    emit(LuaCallStmt(luaCall(LuaName("error"), expression(thrown))))
}

/**
 * try/catch/finally via pcall. The try (and, with finally, the catch) blocks become functions, so a
 * Kotlin `return` inside them becomes `return true, value` and is re-issued after the pcall.
 */
internal fun FileTransformer.tryInto(e: KtTryExpression, sink: ValueSink?): Unit = with(session) {
    val ok = ctx.temp("ok")
    val result = ctx.temp("result")
    val returned = ctx.temp("returned")
    var hasReturn = false
    val pcall = protectedCall(e)
    fun tryFunction(stmts: List<LuaStmt>, element: KtElement): LuaExpr {
        val (rewritten, returns) = rewriteReturns(stmts, element)
        hasReturn = hasReturn || returns
        return luaCall(pcall, LuaFunction(emptyList(), rewritten))
    }
    fun branch(body: KtExpression) = if (sink != null) valueInto(body, sink) else collect { block(body) }
    fun resultNames() = if (hasReturn) listOf(ok, result, returned) else listOf(ok, result)

    val tryBlock = e.tryBlock
    val tryCall = tryFunction(branch(tryBlock), tryBlock)
    val finally = e.finallyBlock?.finalExpression
    val dispatch = catchDispatch(e.catchClauses, result, ::branch)
    if (finally == null) {
        val names = resultNames()
        emit(LuaLocal(names, listOf(tryCall)))
        val onSuccess = listOf(LuaIf(LuaName(result), listOf(LuaReturn(listOf(LuaName(returned))))))
        if (hasReturn) emit(LuaIf(LuaName(ok), onSuccess, dispatch)) else emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), dispatch))
    } else {
        val catchCall = if (e.catchClauses.isNotEmpty()) tryFunction(dispatch, e) else null
        val names = resultNames()
        emit(LuaLocal(names, listOf(tryCall)))
        if (catchCall != null) {
            emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaAssign(names.map { LuaName(it) }, listOf(catchCall)))))
        }
        emitAll(collect { block(finally) })
        emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaCallStmt(luaCall(LuaName("error"), LuaName(result), LuaNumber("0"))))))
        if (hasReturn) emit(LuaIf(LuaName(result), listOf(LuaReturn(listOf(LuaName(returned))))))
    }
}

/** Picks the first catch clause matching the error in [result], or rethrows it. */
private fun FileTransformer.catchDispatch(
    catches: List<KtCatchClause>,
    result: String,
    branch: (KtExpression) -> List<LuaStmt>,
): List<LuaStmt> = with(session) {
    val errorName = ctx.temp("error")
    return collect {
        emit(LuaLocal(listOf(errorName), listOf(lualibCall("ToThrowable", LuaName(result)))))
        var tail: List<LuaStmt> = listOf(LuaCallStmt(luaCall(LuaName("error"), LuaName(errorName), LuaNumber("0"))))
        for (clause in catches.reversed()) {
            val param = clause.catchParameter
            val type = param?.typeReference?.type ?: continue
            val body = listOf(LuaLocal(listOf(naming.of(param)), listOf(LuaName(errorName)))) + (clause.catchBody?.let(branch).orEmpty())
            val catchesAll = type.expandedSymbol?.classId?.asString() in setOf("java/lang/Throwable", "kotlin/Throwable")
            tail = if (catchesAll) body else listOf(LuaIf(typeTest(LuaName(errorName), type, clause), body, tail))
        }
        emitAll(tail)
    }
}

/** Rewrites `return x` into `return true, x` outside nested functions; reports jumps that would leave the function. */
private fun FileTransformer.rewriteReturns(stmts: List<LuaStmt>, element: KtElement): Pair<List<LuaStmt>, Boolean> {
    var found = false
    val labels = mutableSetOf<String>()
    stmts.forEachLeafStatement { if (it is LuaLabel) labels += it.label }
    val rewritten = stmts.mapStatements { s, depth ->
        when (s) {
            is LuaReturn -> {
                found = true
                LuaReturn(listOf(LuaBool(true)) + s.values.ifEmpty { listOf(LuaNil) })
            }

            LuaBreak -> {
                if (depth == 0) ctx.error(element, "break out of a try block is not supported yet")
                s
            }

            is LuaGoto -> {
                if (s.label !in labels) ctx.error(element, "Jumping out of a try block is not supported yet")
                s
            }

            else -> s
        }
    }
    return rewritten to found
}
