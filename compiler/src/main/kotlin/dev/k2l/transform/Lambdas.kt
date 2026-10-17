package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Labels a `return@label` can use to leave [e]: an explicit `label@{}` or the name of the call it is passed to. */
private fun FileTransformer.lambdaLabels(e: KtLambdaExpression): Set<String> {
    val labels = mutableSetOf<String>()
    (e.parent as? KtLabeledExpression)?.getLabelName()?.let { labels += it }
    val call = generateSequence(e.parent) { it.parent }.take(4).filterIsInstance<KtCallExpression>().firstOrNull()
    (call?.calleeExpression as? KtNameReferenceExpression)?.getReferencedName()?.let { labels += it }
    return labels
}

internal fun FileTransformer.lambda(e: KtLambdaExpression): LuaExpr = with(session) {
    val literal = e.functionLiteral
    val type = e.expressionType as? KaFunctionType
    val params = mutableListOf<String>()
    if (type?.hasReceiver == true) {
        val name = receiverName()
        receiverBindings[literal] = LuaName(name).also { stable += it }
        params += name
    }
    val prologue = mutableListOf<LuaStmt>()
    for (p in literal.valueParameters) {
        val destructuring = p.destructuringDeclaration
        if (destructuring != null) {
            val name = ctx.temp("destructured")
            params += name
            prologue += destructure(destructuring.entries, LuaName(name))
        } else {
            params += naming.of(p)
        }
    }
    if (literal.valueParameters.isEmpty() && type?.parameterTypes?.size == 1) params += "it"
    val returnsValue = type?.returnType?.let { !it.isUnitType } ?: true
    val body = inFrame(FunctionFrame(FunctionFrame.Kind.Lambda, lambdaLabels(e))) {
        prologue + collect { lambdaBody(literal, if (returnsValue) ({ listOf(LuaReturn(listOf(it))) }) else null) }
    }
    return LuaFunction(params, body)
}

/** Statements of a lambda; the last expression goes to [sink] (null = the lambda returns Unit). */
private fun FileTransformer.lambdaBody(literal: KtFunctionLiteral, sink: ValueSink?): Unit = with(session) {
    val statements = literal.bodyExpression?.statements.orEmpty()
    statements.dropLast(1).forEach { statement(it) }
    val last = statements.lastOrNull() ?: return
    if (sink == null || last is KtDeclaration) statement(last) else emitAll(valueInto(last, sink))
}

/**
 * Inlines a lambda passed to an inline function such as `let`: its parameters are bound to [args]
 * and its result goes to [sink]. Anything else (a function reference, a variable) is called instead.
 */
internal fun FileTransformer.inlineLambda(lambdaExpr: KtExpression, args: List<LuaExpr>, receiver: LuaExpr?, sink: ValueSink?): Unit =
    with(session) {
        val unwrapped = KtPsiUtil.safeDeparenthesize(lambdaExpr).let { (it as? KtLabeledExpression)?.baseExpression ?: it }
        val lambda = unwrapped as? KtLambdaExpression
        if (lambda == null) {
            val call = LuaCall(expression(lambdaExpr), listOfNotNull(receiver) + args)
            if (sink != null) emitAll(sink(call)) else emit(LuaCallStmt(call))
            return
        }
        val literal = lambda.functionLiteral
        val names = lambdaParameterNames(literal, args)
        val frame = FunctionFrame(FunctionFrame.Kind.Inline, lambdaLabels(lambda)).also { it.sink = sink }
        val body = collect {
            bindLambdaParameters(literal, names, args)
            if (receiver != null) receiverBindings[literal] = receiver
            inFrame(frame) { lambdaBody(literal, sink) }
        }
        val end = frame.endLabel
        if (end != null && !target.hasGoto) {
            // No goto on Lua 5.1: `return@label` breaks out of a one-iteration repeat.
            emit(LuaRepeat(gotoToBreak(body, end, lambda), LuaBool(true)))
            return
        }
        val needsBlock = end != null || body.any { it is LuaLocal || it is LuaFunctionDecl }
        if (needsBlock) emit(LuaDo(body + listOfNotNull(end?.let(::LuaLabel)))) else emitAll(body)
    }

private fun FileTransformer.isInlinableExpression(lambdaExpr: KtExpression, single: KtExpression, args: List<LuaExpr>) = with(session) {
    single !is KtDeclaration && !mayNeedStatements(single) && args.all(::isStable) &&
        PsiTreeUtil.findChildOfType(lambdaExpr, KtReturnExpression::class.java) == null
}

private fun lambdaParameterNames(literal: KtFunctionLiteral, args: List<LuaExpr>) =
    literal.valueParameters.map { it.name ?: "_" }.ifEmpty { if (args.isNotEmpty()) listOf("it") else emptyList() }

private fun FileTransformer.bindLambdaParameters(literal: KtFunctionLiteral, names: List<String>, args: List<LuaExpr>) {
    literal.valueParameters.zip(args).forEach { (p, value) ->
        p.destructuringDeclaration?.let { emit(destructure(it.entries, cache(value, "destructured"))) }
    }
    // Parameters bound to stable values are substituted; others get a local named like the parameter.
    names.zip(args).forEach { (name, value) ->
        lambdaBindings[literal to name] = if (isStable(value)) {
            value
        } else {
            emit(LuaLocal(listOf(LuaNames.of(name)), listOf(value)))
            LuaName(LuaNames.of(name)).also { stable += it }
        }
    }
}

private fun FileTransformer.gotoToBreak(body: List<LuaStmt>, end: String, lambda: KtLambdaExpression) = body.mapStatements { s, depth ->
    when {
        s !is LuaGoto -> s
        s.label == end && depth == 0 -> LuaBreak
        else -> s.also { ctx.error(lambda, "return@label from inside a loop in an inlined lambda needs goto (Lua 5.1)") }
    }
}

/** Inline-lambda result as a value: a temp assigned inside the inlined body. */
internal fun FileTransformer.inlineValue(lambdaExpr: KtExpression, args: List<LuaExpr>, receiver: LuaExpr?): LuaExpr = with(session) {
    val single = (KtPsiUtil.safeDeparenthesize(lambdaExpr) as? KtLambdaExpression)?.bodyExpression?.statements?.singleOrNull()
    if (single != null && isInlinableExpression(lambdaExpr, single, args)) {
        // `x.let { it + 1 }` becomes `x + 1`.
        var result: LuaExpr = LuaNil
        inlineLambda(lambdaExpr, args, receiver) { listOf(LuaCallStmt(it.also { v -> result = v })) }
        buffer.removeLastOrNull()
        return result
    }
    val name = ctx.temp("result")
    emit(LuaLocal(listOf(name)))
    inlineLambda(lambdaExpr, args, receiver) { listOf(assign(name, it)) }
    return LuaName(name)
}

internal fun FileTransformer.lambdaReturnsUnit(e: KtExpression): Boolean = with(session) {
    (e.expressionType as? KaFunctionType)?.returnType?.isUnitType == true
}

internal fun FileTransformer.symbol(call: KaCallableMemberCall<*, *>) = call.partiallyAppliedSymbol.symbol

internal fun FileTransformer.callableReference(e: KtCallableReferenceExpression): LuaExpr = with(session) {
    val symbol = e.callableReference.mainReference.resolveToSymbol()
    val psi = symbol?.psi
    val receiverExpr = e.receiverExpression
    return when {
        symbol is KaConstructorSymbol -> {
            val cls = symbol.containingClassId?.let(classes::classInFile) ?: return unsupported(e, "Reference to a library constructor")
            LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi)))
        }

        psi is KtNamedFunction && classes.isSource(psi) -> functionReference(e, psi)

        else -> unsupported(e, "This callable reference")
    }
}

private fun FileTransformer.functionReference(e: KtCallableReferenceExpression, psi: KtNamedFunction): LuaExpr = with(session) {
    val receiverExpr = e.receiverExpression
    val boundReceiver = receiverExpr?.takeIf { isBoundReference(e) }
    val rest = listOf(LuaName("..."))
    if (psi.containingClassOrObject == null) {
        val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
        if (receiverExpr != null && psi.receiverTypeReference == null) unsupported(e, "Bound function reference")
        // An extension function already takes its receiver first, so `String::shout` is just `shout`.
        if (boundReceiver == null) return fn
        val target = cache(expression(boundReceiver), "receiver")
        return LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(fn, listOf(target) + rest)))), isVararg = true)
    }
    val method = naming.function(psi)
    if (boundReceiver != null) {
        // obj::method
        val target = cache(expression(boundReceiver), "receiver")
        return LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaMethodCall(target, method, rest)))), isVararg = true)
    }
    // Class::method takes the instance first.
    return LuaFunction(listOf("self"), listOf(LuaReturn(listOf(LuaMethodCall(LuaName("self"), method, rest)))), isVararg = true)
}

/** `obj::f` is bound to a value; `Type::f` is not. */
private fun FileTransformer.isBoundReference(e: KtCallableReferenceExpression): Boolean = with(session) {
    val receiver = e.receiverExpression ?: return false
    val ref = (receiver as? KtNameReferenceExpression)
        ?: (receiver as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
        ?: return true
    return ref.mainReference.resolveToSymbol() !is KaClassLikeSymbol
}
