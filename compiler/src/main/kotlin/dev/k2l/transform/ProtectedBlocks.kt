package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.psi.KtExpression

/**
 * `use`, `synchronized`, `runCatching` and `measureTimeMillis` with a lambda expanded in place, so a `return` out of the lambda
 * leaves the caller. `use` and `synchronized` are always expanded; the other two only for a lambda with a non-local `return`
 * (otherwise they are calls of the lualib).
 */
internal fun FileTransformer.protectedBlock(
    callableId: String?,
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    receiver: LuaExpr?,
): LuaExpr? = with(session) {
    val kind = when (callableId) {
        "kotlin/io/use", "kotlin/use" -> Block.Use
        "kotlin/synchronized" -> Block.Synchronized
        "kotlin/runCatching" -> Block.RunCatching
        "kotlin/system/measureTimeMillis", "kotlin/system/measureNanoTime" -> Block.Measure
        else -> return null
    }
    val args = callArguments(call)
    val lambda = args.lastOrNull() ?: return null
    if (kind.onlyNonLocal && lambdaLiteral(lambda)?.let { hasNonLocalJump(it) } != true) return null
    return when (kind) {
        Block.Use -> using(cache(receiver ?: expression(receiverExpr ?: return null), "resource"), receiverExpr, lambda)
        Block.Synchronized -> synchronizing(args[0]!!, lambda)
        Block.RunCatching -> catching(receiver ?: receiverExpr?.let { expression(it) }, lambda)
        Block.Measure -> measuring(lambda, if (callableId == "kotlin/system/measureNanoTime") "1e9" else "1000")
    }
}

private enum class Block(val onlyNonLocal: Boolean) {
    Use(false),
    Synchronized(false),
    RunCatching(true),
    Measure(true),
}

/** The lambda's value: its result, or nil for a lambda returning Unit. */
private fun FileTransformer.blockValue(lambda: KtExpression, args: List<LuaExpr>, receiver: LuaExpr?): LuaExpr =
    if (lambdaReturnsUnit(lambda)) {
        inlineLambda(lambda, args, receiver, null)
        LuaNil
    } else {
        inlineValue(lambda, args, receiver)
    }

private fun FileTransformer.synchronizing(lock: KtExpression, lambda: KtExpression): LuaExpr = with(session) {
    val value = expression(lock)
    // the lock expression is evaluated for its side effects only
    if (value !is LuaName && value !is LuaNumber && value !is LuaString) cache(value, "lock")
    return blockValue(lambda, emptyList(), null)
}

private fun FileTransformer.measuring(lambda: KtExpression, scale: String): LuaExpr {
    val start = declare("start", lua("os.clock"))
    inlineLambda(lambda, emptyList(), null, null)
    val elapsed = LuaBinary(LuaBinOp.Mul, LuaBinary(LuaBinOp.Sub, lua("os.clock"), start), LuaNumber(scale))
    return lua("math.floor", elapsed)
}

/** The `pcall` to use: the coroutine-aware one on Lua 5.1 when the block can suspend. */
private fun FileTransformer.pcallFor(lambda: KtExpression): LuaExpr = with(session) {
    val suspends = !target.yieldsAcrossPcall && lambdaLiteral(lambda)?.let { containsSuspensionPoint(it) } == true
    if (suspends) lualibRef("CoPcall", "__K2L_CoPcall") else luaPcall()
}

/** `runCatching { }`: the block runs in a protected call; the error, if any, becomes a failure. */
private fun FileTransformer.catching(receiver: LuaExpr?, lambda: KtExpression): LuaExpr {
    val self = receiver?.let { cache(it, "receiver") }
    val outcome = declare("outcome")
    val resultClass = lualibRef(RESULT_FEATURE, "__K2L_Result")
    fun make(kind: String, value: LuaExpr) = LuaCall(LuaIndex(resultClass, LuaString(kind)), listOf(value))
    lowerTry(
        TryParts(
            pcall = pcallFor(lambda),
            body = { collect { emit(assign(outcome.name, make("success", blockValue(lambda, emptyList(), self)))) } },
            handler = { error -> listOf(assign(outcome.name, make("failure", lualibCall("ToThrowable", LuaName(error))))) },
            hasCatch = true,
            finally = null,
        ),
    )
    return outcome
}

/** `resource.use { }`: the block runs in a protected call, then the resource is closed whether or not it failed. */
private fun FileTransformer.using(resource: LuaExpr, receiverExpr: KtExpression?, lambda: KtExpression): LuaExpr = with(session) {
    val value = declare("result")
    val nullable = receiverExpr?.expressionType?.isMarkedNullable == true
    val raised = jumps.jumpsRaised
    fun closing(statement: LuaStmt): LuaStmt =
        if (nullable) LuaIf(LuaBinary(LuaBinOp.Ne, resource, LuaNil), listOf(statement)) else statement
    lowerTry(
        TryParts(
            pcall = pcallFor(lambda),
            body = {
                collect {
                    if (lambdaReturnsUnit(lambda)) {
                        inlineLambda(lambda, listOf(resource), null, null)
                    } else {
                        emit(assign(value.name, inlineValue(lambda, listOf(resource), null)))
                    }
                }
            },
            handler = { emptyList() },
            hasCatch = false,
            finally = { ok, outcome ->
                // an error of close() must not hide the error of the block (it is added to its suppressed exceptions), but a
                // jump out of a lambda in the block is no error
                val quietly = LuaCallStmt(LuaCall(lualibRef("Suppressed", "__K2L_CloseAfter"), listOf(resource, LuaName(outcome))))
                val plain = LuaCallStmt(LuaMethodCall(resource, "close", emptyList()))
                val closesPlainly = if (jumps.jumpsRaised > raised) {
                    LuaBinary(LuaBinOp.Or, LuaName(ok), LuaCall(lualibRef("Jump", "__K2L_IsJump"), listOf(LuaName(outcome))))
                } else {
                    LuaName(ok)
                }
                listOf(closing(LuaIf(closesPlainly, listOf(plain), listOf(quietly))))
            },
        ),
    )
    return value
}
