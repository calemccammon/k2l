package dev.k2l.transform

import com.intellij.psi.PsiElement
import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Labels a `return@label` can use to leave [e]: an explicit `label@{}` or the name of the call it is passed to. */
internal fun FileTransformer.lambdaLabels(e: KtLambdaExpression): Set<String> {
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
    val frame = FunctionFrame(FunctionFrame.Kind.Lambda, lambdaLabels(e), literal)
    frame.site = jumps.jumpSites.lastOrNull { e in it.lambdas }
    frame.unitResult = !returnsValue && resultExpected(e)
    val body = inFrame(frame) {
        prologue + collect {
            lambdaBody(literal, if (returnsValue) ({ listOf(LuaReturn(listOf(it))) }) else null)
            if (frame.unitResult && buffer.lastOrNull() !is LuaReturn) emit(LuaReturn(listOf(unitObject())))
        }
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
        inlinedLambdaOf(lambdaExpr)?.let { passed ->
            inCallerContext(passed) { inlineLambda(passed.expr, args, receiver, sink) }
            return
        }
        val unwrapped = KtPsiUtil.safeDeparenthesize(lambdaExpr).let { (it as? KtLabeledExpression)?.baseExpression ?: it }
        val lambda = unwrapped as? KtLambdaExpression
        if (lambda == null) {
            val call = LuaCall(expression(lambdaExpr), listOfNotNull(receiver) + args)
            if (sink != null) emitAll(sink(call)) else emit(LuaCallStmt(call))
            return
        }
        val literal = lambda.functionLiteral
        val names = lambdaParameterNames(literal, args)
        val frame = FunctionFrame(FunctionFrame.Kind.Inline, lambdaLabels(lambda), literal).also { it.sink = sink }
        val body = collect {
            bindLambdaParameters(literal, names, args)
            if (receiver != null) receiverBindings[literal] = receiver
            inFrame(frame) { lambdaBody(literal, sink) }
        }
        emitInlinedBody(body, frame, lambda)
    }

/**
 * Emits the statements of an inlined lambda or function. A `return` out of it was lowered to a jump to the frame's end
 * label: a `goto`, or on Lua 5.1 a `break` out of a one-iteration `repeat`. Locals get a `do` block of their own.
 */
internal fun FileTransformer.emitInlinedBody(body: List<LuaStmt>, frame: FunctionFrame, at: KtElement) {
    val end = frame.endLabel
    if (end != null && !target.hasGoto) {
        val flag = ctx.temp("returning")
        val (lowered, usesFlag) = jumpsToBreaks(body, end, flag, at)
        if (usesFlag) emit(LuaLocal(listOf(flag), listOf(LuaBool(false))))
        emit(LuaRepeat(lowered, LuaBool(true)))
        return
    }
    val needsBlock = end != null || body.any { it is LuaLocal || it is LuaFunctionDecl }
    if (needsBlock) emit(LuaDo(body + listOfNotNull(end?.let(::LuaLabel)))) else emitAll(body)
}

private fun FileTransformer.isInlinableExpression(lambdaExpr: KtExpression, single: KtExpression, args: List<LuaExpr>) = with(session) {
    val jumps = PsiTreeUtil.findChildOfAnyType(
        lambdaExpr,
        KtReturnExpression::class.java,
        KtBreakExpression::class.java,
        KtContinueExpression::class.java,
    )
    val params = (KtPsiUtil.safeDeparenthesize(lambdaExpr) as? KtLambdaExpression)?.valueParameters
    single !is KtDeclaration && !mayNeedStatements(single) && args.all(::isStable) && jumps == null &&
        single !is KtThrowExpression && params?.none { it.destructuringDeclaration != null } != false
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

/**
 * Lua 5.1 has no `goto`, so a jump to the end of an inlined body (wrapped in a one-iteration `repeat`) becomes a `break`.
 * From inside loops it sets [flag] and breaks, and the loops it leaves test the flag afterwards to break again.
 */
private fun FileTransformer.jumpsToBreaks(body: List<LuaStmt>, end: String, flag: String, at: KtElement): Pair<List<LuaStmt>, Boolean> {
    var usesFlag = false
    fun lower(stmts: List<LuaStmt>, inLoop: Boolean): List<LuaStmt> = stmts.flatMap { s ->
        fun loop(rebuild: (List<LuaStmt>) -> LuaStmt, loopBody: List<LuaStmt>): List<LuaStmt> {
            val before = usesFlag
            usesFlag = false
            val lowered = lower(loopBody, inLoop = true)
            val leaves = usesFlag
            usesFlag = usesFlag || before
            return if (leaves) listOf(rebuild(lowered), LuaIf(LuaName(flag), listOf(LuaBreak))) else listOf(s)
        }
        when (s) {
            is LuaGoto -> when {
                // a label of a loop or of an enclosing inlined body, lowered there
                s.label != end && s.label in jumps.jumpLabels -> listOf(s)

                s.label != end -> listOf(s.also { ctx.error(at, "This jump out of an inlined lambda or function needs goto (Lua 5.1)") })

                !inLoop -> listOf(LuaBreak)

                else -> listOf(assign(flag, LuaBool(true)), LuaBreak).also { usesFlag = true }
            }

            is LuaIf -> listOf(LuaIf(s.cond, lower(s.then, inLoop), s.orElse?.let { lower(it, inLoop) }))

            is LuaDo -> listOf(LuaDo(lower(s.body, inLoop)))

            is LuaWhile -> loop({ LuaWhile(s.cond, it) }, s.body)

            is LuaRepeat -> loop({ LuaRepeat(it, s.until) }, s.body)

            is LuaNumericFor -> loop({ s.copy(body = it) }, s.body)

            is LuaGenericFor -> loop({ s.copy(body = it) }, s.body)

            else -> listOf(s)
        }
    }
    return lower(body, inLoop = false) to usesFlag
}

/** Inline-lambda result as a value: a temp assigned inside the inlined body. */
internal fun FileTransformer.inlineValue(lambdaExpr: KtExpression, args: List<LuaExpr>, receiver: LuaExpr?): LuaExpr = with(session) {
    if (lambdaReturnsUnit(lambdaExpr)) {
        inlineLambda(lambdaExpr, args, receiver, null)
        return unitObject()
    }
    val single = (KtPsiUtil.safeDeparenthesize(lambdaExpr) as? KtLambdaExpression)?.bodyExpression?.statements?.singleOrNull()
    if (single != null && isInlinableExpression(lambdaExpr, single, args)) {
        // `x.let { it + 1 }` becomes `x + 1`.
        var result: LuaExpr = LuaNil
        var marker: LuaStmt? = null
        val stmts = collect {
            inlineLambda(lambdaExpr, args, receiver) { value ->
                result = value
                listOf(LuaCallStmt(value).also { marker = it })
            }
        }
        if (stmts.lastOrNull() === marker) {
            emitAll(stmts.dropLast(1))
            return result
        }
        // the value needed statements of its own (a cached operand) in a block: assign it there
        val name = ctx.temp("result")
        emit(LuaLocal(listOf(name)))
        emitAll(stmts.mapStatements { s, _ -> if (s === marker) assign(name, result) else s })
        return LuaName(name)
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

/**
 * `::Point`, `::Inner` or `outer::Inner`: the class's `new` function, bound to the outer instance for inner classes. A library
 * constructor (`::ArrayList`) becomes a function making the mapped call.
 */
private fun FileTransformer.constructorReference(e: KtCallableReferenceExpression, symbol: KaConstructorSymbol, psi: PsiElement?): LuaExpr {
    with(session) { typeAliasedOriginal(symbol) }?.let { return constructorReference(e, it, it.psi) }
    val cls = symbol.containingClassId?.let(classes::classInFile)
        ?: ((psi as? KtConstructor<*>)?.getContainingClassOrObject() ?: psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
        ?: return libraryConstructorReference(e, symbol)
            ?: unsupported(e, "Reference to the library constructor '${symbol.containingClassId?.asSingleFqName()}'")
    val constructor = LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi)))
    val params = (psi as? KtConstructor<*>)?.valueParameters ?: (cls as? KtClass)?.primaryConstructorParameters.orEmpty()
    return if (isInner(cls) && (e.receiverExpression == null || isBoundReference(e))) {
        varargAdapter(e, params, 0, innerConstructorReference(e, cls, constructor))
    } else {
        varargAdapter(e, params, if (isInner(cls)) 1 else 0, constructor)
    }
}

/**
 * A referenced callable as a Lua [function], and the value a bound reference closes over; the function takes [leading]
 * receivers before the value arguments (`String::shout`, `Type::method`).
 */
internal class ReferenceValue(val function: LuaExpr, val receiver: LuaExpr?, val leading: Int = 0)

internal fun FileTransformer.callableReference(e: KtCallableReferenceExpression): LuaExpr = with(session) {
    val symbol = e.callableReference.mainReference.resolveToSymbol()
    val psi = symbol?.psi
    return when {
        symbol is KaConstructorSymbol -> constructorReference(e, symbol, psi)

        psi is KtNamedFunction && psi.isMemberExtension() -> unsupported(e, "Reference to a member extension function")

        psi is KtNamedFunction && classes.isSource(psi) && symbol is KaCallableSymbol ->
            functionReference(e, psi).let { varargAdapter(e, psi.valueParameters, it.leading, it.function) }

        (psi is KtProperty || psi is KtParameter) && classes.isSource(psi) ->
            propertyReference(e, psi as KtNamedDeclaration) ?: unsupported(e, "This property reference")

        symbol is KaPropertySymbol -> libraryPropertyReference(e, symbol)

        symbol is KaCallableSymbol ->
            libraryReference(e, symbol)?.function ?: unsupported(e, "This callable reference")

        else -> unsupported(e, "This callable reference")
    }
}

/** `::Inner` and `outer::Inner` are bound to the enclosing instance, which the constructor takes first; `Outer::Inner` is not. */
private fun FileTransformer.innerConstructorReference(
    e: KtCallableReferenceExpression,
    cls: KtClassOrObject,
    constructor: LuaExpr,
): LuaExpr = with(session) {
    val receiverExpr = e.receiverExpression
    val wanted = cls.containingClassOrObject
    val outer = if (receiverExpr != null) {
        expression(receiverExpr)
    } else {
        enclosingInstances().firstOrNull { (c, _) -> wanted != null && wanted in classes.hierarchy(c) }?.second
            ?: return unsupported(e, "Reference to an inner class constructor without an enclosing instance")
    }
    val target = cache(outer, "outer")
    LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(constructor, listOf(target, LuaName("...")))))), isVararg = true)
}

private fun FileTransformer.functionReference(e: KtCallableReferenceExpression, psi: KtNamedFunction): ReferenceValue = with(session) {
    val receiverExpr = e.receiverExpression
    val boundReceiver = receiverExpr?.takeIf { isBoundReference(e) }
    val rest = listOf(LuaName("..."))
    if (psi.containingClassOrObject == null) {
        val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
        // An extension function already takes its receiver first, so `String::shout` is just `shout`. Only extensions can
        // have a receiver here: Kotlin rejects `x::f` and `pkg::f` for other top-level and local functions.
        if (boundReceiver == null || psi.receiverTypeReference == null) {
            return ReferenceValue(fn, null, if (psi.receiverTypeReference != null) 1 else 0)
        }
        val target = cache(expression(boundReceiver), "receiver")
        return ReferenceValue(
            LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(fn, listOf(target) + rest)))), isVararg = true),
            target,
        )
    }
    val method = naming.function(psi)
    // `::method` inside the class (or object, companion, `with` block) is bound to the implicit `this`
    val implicit = if (receiverExpr == null) implicitReferenceReceiver(e) else null
    if (boundReceiver != null || implicit != null) {
        // obj::method
        val target = cache(implicit ?: expression(boundReceiver!!), "receiver")
        return ReferenceValue(
            LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaMethodCall(target, method, rest)))), isVararg = true),
            target,
        )
    }
    // Class::method takes the instance first.
    ReferenceValue(
        LuaFunction(listOf("self"), listOf(LuaReturn(listOf(LuaMethodCall(LuaName("self"), method, rest)))), isVararg = true),
        null,
        1,
    )
}

/** `List<Int>` and `Map.Entry<K, V>` in `List<Int>::size` parse as calls with type arguments only. */
private fun isGenericTypeName(receiver: KtExpression): Boolean {
    val call = (receiver as? KtDotQualifiedExpression)?.selectorExpression ?: receiver
    return call is KtCallExpression && call.valueArgumentList == null && call.lambdaArguments.isEmpty()
}

/** `obj::f` is bound to a value, and so is `Obj::f` of an `object`; `Type::f` is not. */
internal fun FileTransformer.isBoundReference(e: KtCallableReferenceExpression): Boolean = with(session) {
    val receiver = e.receiverExpression ?: return false
    if (isGenericTypeName(receiver)) return false
    val ref = (receiver as? KtNameReferenceExpression)
        ?: (receiver as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
        ?: return true
    val symbol = ref.mainReference.resolveToSymbol()
    return symbol !is KaClassLikeSymbol || (symbol.psi is KtObjectDeclaration && classes.isSource(symbol.psi))
}

/** The implicit `this` a member reference without a receiver (`::scale`, `::prop`) is bound to, or null for other references. */
internal fun FileTransformer.implicitReferenceReceiver(e: KtCallableReferenceExpression): LuaExpr? = with(session) {
    val call = e.callableReference.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    val value = call.partiallyAppliedSymbol.dispatchReceiver ?: return null
    implicitReceiver(value, e)
}
