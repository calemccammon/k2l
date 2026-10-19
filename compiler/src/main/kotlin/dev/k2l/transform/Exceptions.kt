package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

internal fun FileTransformer.throwStatement(e: KtThrowExpression): Unit = with(session) {
    val thrown = e.thrownExpression ?: return
    emit(LuaCallStmt(luaCall(LuaName("error"), expression(thrown))))
}

/**
 * try/catch/finally via pcall. The try (and, with finally, the catch) blocks become functions, so a
 * Kotlin `return` inside them becomes `return true, value` and is re-issued after the pcall. A `break`, `continue` or
 * inlined-function exit that leaves the try becomes `return n` (n = 1, 2, ... for each distinct jump) and the
 * matching jump is re-issued after the pcall; `finally` runs in between.
 */
internal fun FileTransformer.tryInto(e: KtTryExpression, sink: ValueSink?): Unit = with(session) {
    fun branch(body: KtExpression) = if (sink != null) valueInto(body, sink) else collect { block(body) }
    val finally = e.finallyBlock?.finalExpression
    lowerTry(
        TryParts(
            pcall = protectedCall(e),
            body = { branch(e.tryBlock) },
            handler = { result -> catchDispatch(e.catchClauses, result, ::branch) },
            hasCatch = e.catchClauses.isNotEmpty(),
            finally = finally?.let { f -> { _, _ -> collect { block(f) } } },
        ),
    )
}

/**
 * The parts of a protected call, see [lowerTry]. [handler] gets the name of the variable that holds the error and is always
 * evaluated, [hasCatch] tells whether it is used when there is a [finally], which gets the names of the success flag and of
 * the result (the error when the flag is false).
 */
internal class TryParts(
    val pcall: LuaExpr,
    val body: () -> List<LuaStmt>,
    val handler: (String) -> List<LuaStmt>,
    val hasCatch: Boolean,
    val finally: ((String, String) -> List<LuaStmt>)?,
)

internal fun FileTransformer.lowerTry(parts: TryParts) {
    val ok = ctx.temp("ok")
    val result = ctx.temp("result")
    val returned = ctx.temp("returned")
    val exits = TryExits()
    fun tryFunction(stmts: List<LuaStmt>): LuaExpr = luaCall(parts.pcall, LuaFunction(emptyList(), exits.rewrite(stmts)))
    fun resultNames() = if (exits.hasReturn) listOf(ok, result, returned) else listOf(ok, result)

    val tryCall = tryFunction(parts.body())
    val dispatch = parts.handler(result)
    val finally = parts.finally
    if (finally == null) {
        val names = resultNames()
        emit(LuaLocal(names, listOf(tryCall)))
        val onSuccess = exits.reissue(result, returned)
        val failed = LuaUnary(LuaUnOp.Not, LuaName(ok))
        if (onSuccess.isNotEmpty()) emit(LuaIf(LuaName(ok), onSuccess, dispatch)) else emit(LuaIf(failed, dispatch))
    } else {
        val catchCall = if (parts.hasCatch) tryFunction(dispatch) else null
        val names = resultNames()
        emit(LuaLocal(names, listOf(tryCall)))
        if (catchCall != null) {
            emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaAssign(names.map { LuaName(it) }, listOf(catchCall)))))
        }
        emitAll(finally(ok, result))
        emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaCallStmt(luaCall(LuaName("error"), LuaName(result), LuaNumber("0"))))))
        emitAll(exits.reissue(result, returned))
    }
}

/** What leaves the pcall'd functions of one `try`: whether they return, and the distinct `break`/`goto` statements. */
private class TryExits {
    var hasReturn = false
    private val jumps = mutableListOf<LuaStmt>()

    private fun codeOf(jump: LuaStmt): LuaExpr {
        if (jump !in jumps) jumps += jump
        return LuaNumber((jumps.indexOf(jump) + 1).toString())
    }

    /** Rewrites `return x` into `return true, x` and jumps leaving [stmts] into `return n`, outside nested functions. */
    fun rewrite(stmts: List<LuaStmt>): List<LuaStmt> {
        val labels = mutableSetOf<String>()
        stmts.forEachLeafStatement { if (it is LuaLabel) labels += it.label }
        return stmts.mapStatements { s, depth ->
            when {
                s is LuaReturn -> {
                    hasReturn = true
                    LuaReturn(listOf(LuaBool(true)) + s.values.ifEmpty { listOf(LuaNil) })
                }

                s === LuaBreak && depth == 0 -> LuaReturn(listOf(codeOf(s)))

                s is LuaGoto && s.label !in labels -> LuaReturn(listOf(codeOf(s)))

                else -> s
            }
        }
    }

    /** The statements after the pcall that perform what the function asked for in its first result. */
    fun reissue(result: String, returned: String): List<LuaStmt> = buildList {
        if (hasReturn) {
            val isReturn = if (jumps.isEmpty()) LuaName(result) else LuaBinary(LuaBinOp.Eq, LuaName(result), LuaBool(true))
            add(LuaIf(isReturn, listOf(LuaReturn(listOf(LuaName(returned))))))
        }
        jumps.forEachIndexed { i, jump -> add(LuaIf(LuaBinary(LuaBinOp.Eq, LuaName(result), codeOf(jumps[i])), listOf(jump))) }
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
