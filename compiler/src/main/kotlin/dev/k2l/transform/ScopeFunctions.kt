package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * `forEach` resolves to Kotlin's inline extension or, for (k, v) lambdas, to `java.util.Map.forEach`; those are expanded as a
 * loop. The `forEach` of a stream is a method of the stream.
 */
private fun effectiveCallableId(callableId: String, simpleName: String?): String {
    val isLibrary = callableId.startsWith("kotlin/") || (callableId.startsWith("java/") && !callableId.startsWith("java/util/stream/"))
    return if (simpleName == "forEach" && isLibrary) "kotlin/collections/forEach" else callableId
}

/** Kotlin's inline scope functions and preconditions, expanded in place. */
internal fun FileTransformer.scopeFunction(
    callableId: String?,
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
): LuaExpr? = with(session) {
    if (callableId == null || call !is KaFunctionCall<*>) return null
    val effectiveId = effectiveCallableId(callableId, symbol(call).callableId?.callableName?.asString())
    inlinedResultCall(callableId, call, receiverExpr, implicit)?.let { return it }
    protectedBlock(callableId, call, receiverExpr, implicit)?.let { return it }
    if (effectiveId !in SCOPE_FUNCTIONS) return null
    val args = callArguments(call)
    val receiver = (implicit ?: receiverExpr?.let { expression(it) })
    return when (effectiveId) {
        "kotlin/let" -> letCall(receiver!!, args)

        "kotlin/also" -> alsoCall(receiver!!, args)

        "kotlin/apply" -> applyCall(receiver!!, args)

        "kotlin/run" -> runCall(receiver, args)

        "kotlin/with" -> withCall(args)

        "kotlin/takeIf", "kotlin/takeUnless" -> takeIfCall(receiver!!, receiverExpr, args, negated = callableId != "kotlin/takeIf")

        "kotlin/repeat" -> repeatCall(args)

        "kotlin/require", "kotlin/check" -> requireCall(effectiveId, args)

        "kotlin/requireNotNull", "kotlin/checkNotNull" -> requireNotNullCall(effectiveId, args)

        "kotlin/error" -> errorCall(args)

        "kotlin/text/buildString" -> buildStringCall(args)

        "kotlin/collections/buildList" -> buildCollectionCall("__K2L_ListBuilderOf", args)

        "kotlin/collections/buildMap" -> buildCollectionCall("__K2L_MapBuilderOf", args)

        "kotlin/collections/buildSet" -> buildCollectionCall("__K2L_SetBuilderOf", args)

        "kotlin/collections/forEach", "kotlin/sequences/forEach", "java/lang/Iterable.forEach", "java/util/Map.forEach",
        "kotlin/text/forEach",
        ->
            forEachCall(receiver!!, receiverExpr?.expressionType ?: call.dispatchReceiver?.type, args, indexed = false)

        "kotlin/collections/forEachIndexed", "kotlin/text/forEachIndexed" -> forEachCall(
            receiver!!,
            receiverExpr?.expressionType,
            args,
            indexed = true,
        )

        "kotlin/TODO" -> todoCall(args)

        else -> null
    }
}

private fun FileTransformer.letCall(receiver: LuaExpr, args: List<KtExpression?>): LuaExpr = with(session) {
    val value = cache(receiver, "value")
    if (lambdaReturnsUnit(args[0]!!)) {
        // a call of type Unit: where its value is used, that is the Unit object (see UnitValues.kt)
        inlineLambda(args[0]!!, listOf(value), null, null)
        LuaNil
    } else {
        inlineValue(args[0]!!, listOf(value), null)
    }
}

private fun FileTransformer.alsoCall(receiver: LuaExpr, args: List<KtExpression?>): LuaExpr = with(session) {
    cache(receiver, "value").also { inlineLambda(args[0]!!, listOf(it), null, null) }
}

private fun FileTransformer.applyCall(receiver: LuaExpr, args: List<KtExpression?>): LuaExpr = with(session) {
    cache(receiver, "value").also { inlineLambda(args[0]!!, emptyList(), it, null) }
}

/** `run { }` has no receiver; `x.run { }` binds `this`. */
private fun FileTransformer.runCall(receiver: LuaExpr?, args: List<KtExpression?>): LuaExpr = with(session) {
    if (receiver != null) runInline(args[0]!!, cache(receiver, "value")) else runInline(args[0]!!, null)
}

private fun FileTransformer.withCall(args: List<KtExpression?>): LuaExpr = with(session) {
    val target = cache(expression(args[0]!!), "value")
    return runInline(args[1]!!, target)
}

/** `x.takeIf { p }` is `p and x or nil`, except for Boolean receivers where `false` would fall through. */
private fun FileTransformer.takeIfCall(
    receiver: LuaExpr,
    receiverExpr: KtExpression?,
    args: List<KtExpression?>,
    negated: Boolean,
): LuaExpr = with(session) {
    val value = cache(receiver, "value")
    val cond = inlineValue(args[0]!!, listOf(value), null)
    val test = if (negated) negate(cond) else cond
    if (receiverExpr?.expressionType?.isBooleanType != true) {
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, test, value), LuaNil)
    }
    val name = ctx.temp("result")
    emit(LuaLocal(listOf(name)))
    emit(LuaIf(test, listOf(assign(name, value))))
    return LuaName(name)
}

/** `repeat(n) { i -> }` as a numeric `for` with the lambda inlined. */
private fun FileTransformer.repeatCall(args: List<KtExpression?>): LuaExpr = with(session) {
    val times = arguments(emptyList(), listOf(args[0]))[0]
    val lambda = args[1]!!
    val index = (KtPsiUtil.safeDeparenthesize(lambda) as? KtLambdaExpression)?.functionLiteral?.valueParameters
        ?.singleOrNull()?.name ?: "it"
    val body = collect { inlineLambda(lambda, listOf(LuaName(LuaNames.of(index)).also { stable += it }), null, null) }
    emit(LuaNumericFor(LuaNames.of(index), LuaNumber("0"), plusConstant(times, -1), null, body))
    return LuaNil
}

/** `require(cond) { message }` / `check(cond) { message }`. */
private fun FileTransformer.requireCall(id: String, args: List<KtExpression?>): LuaExpr = with(session) {
    val cond = arguments(emptyList(), listOf(args[0]))[0]
    val (exception, default) = PRECONDITION_FAILURES.getValue(id)
    failUnless(negate(cond), exception, default, args.getOrNull(1))
    return LuaNil
}

/** `requireNotNull(x) { message }` / `checkNotNull(x) { message }`; the result is the value. */
private fun FileTransformer.requireNotNullCall(id: String, args: List<KtExpression?>): LuaExpr = with(session) {
    val value = cache(arguments(emptyList(), listOf(args[0]))[0], "value")
    val (exception, default) = PRECONDITION_FAILURES.getValue(id)
    failUnless(LuaBinary(LuaBinOp.Eq, value, LuaNil), exception, default, args.getOrNull(1))
    return value
}

private fun FileTransformer.errorCall(args: List<KtExpression?>): LuaExpr = with(session) {
    val message = arguments(emptyList(), listOf(args[0]))[0]
    emit(throwNew(ILLEGAL_STATE_EXCEPTION, str(message, args.getOrNull(0)?.expressionType)))
    return LuaNil
}

/** `buildString { }` and `buildString(capacity) { }`, whose capacity is only a hint, as for `buildList`. */
private fun FileTransformer.buildStringCall(args: List<KtExpression?>): LuaExpr = with(session) {
    val builder = cache(LuaCall(LuaIndex(lualibRef("Strings", "__K2L_StringBuilder"), LuaString("new")), emptyList()), "builder")
    inlineLambda(args.last()!!, emptyList(), builder, null)
    return LuaMethodCall(builder, "toString", emptyList())
}

/** `buildList { add(1) }`: a new builder that the lambda fills through its receiver, read-only afterwards (`____build()`). */
private fun FileTransformer.buildCollectionCall(factory: String, args: List<KtExpression?>): LuaExpr = with(session) {
    val target = cache(LuaCall(lualibRef("Collections", factory), emptyList()), "builder")
    inlineLambda(args.last()!!, emptyList(), target, null)
    return LuaMethodCall(target, "____build", emptyList())
}

private fun FileTransformer.forEachCall(receiver: LuaExpr, type: KaType?, args: List<KtExpression?>, indexed: Boolean): LuaExpr =
    with(session) {
        forEachLoop(receiver, type, args[0]!!, indexed)
        return LuaNil
    }

private fun FileTransformer.todoCall(args: List<KtExpression?>): LuaExpr = with(session) {
    val reason = args.getOrNull(0)?.let { expression(it) }
    val message = if (reason == null) {
        LuaString("An operation is not implemented.")
    } else {
        LuaBinary(LuaBinOp.Concat, LuaString("An operation is not implemented: "), reason)
    }
    emit(throwNew(NOT_IMPLEMENTED_ERROR, message))
    return LuaNil
}

private fun FileTransformer.runInline(lambda: KtExpression, receiver: LuaExpr?): LuaExpr = with(session) {
    if (lambdaReturnsUnit(lambda)) {
        inlineLambda(lambda, emptyList(), receiver, null)
        LuaNil
    } else {
        inlineValue(lambda, emptyList(), receiver)
    }
}

/** `if <failed> then error(Exception.new(message)) end`, with the message from an optional lazy lambda. */
private fun FileTransformer.failUnless(failed: LuaExpr, exception: String, default: String, lazyMessage: KtExpression?): Unit =
    with(session) {
        val body = collect {
            val message = if (lazyMessage == null) {
                LuaString(default)
            } else {
                val value = inlineValue(lazyMessage, emptyList(), null)
                val last = (KtPsiUtil.safeDeparenthesize(lazyMessage) as? KtLambdaExpression)?.bodyExpression?.statements?.lastOrNull()
                str(value, last?.expressionType ?: (lazyMessage.expressionType as? KaFunctionType)?.returnType)
            }
            emit(throwNew(exception, message))
        }
        emit(LuaIf(failed, body))
    }

internal fun FileTransformer.throwNew(exception: String, message: LuaExpr): LuaStmt =
    LuaCallStmt(luaCall(LuaName("error"), LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, exception), LuaString("new")), listOf(message))))
