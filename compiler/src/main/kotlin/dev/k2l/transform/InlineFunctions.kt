package dev.k2l.transform

import com.intellij.psi.PsiElement
import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

internal fun KtNamedFunction.isReifiedInline() =
    hasModifier(KtTokens.INLINE_KEYWORD) && typeParameters.any { it.hasModifier(KtTokens.REIFIED_KEYWORD) }

/** The actual type a reified type parameter stands for in the inlined function being expanded; `T?` makes it nullable. */
internal fun FileTransformer.reifiedType(type: KaType): KaType = with(session) {
    val actual = (type as? KaTypeParameterType)?.let { reifiedTypes[it.symbol.psi] } ?: return type
    if (type.isMarkedNullable && !actual.isMarkedNullable) actual.withNullability(true) else actual
}

/** Runs [block] with the receivers of the code that passed [lambda], which is where the lambda's `this` is resolved. */
internal inline fun <T> FileTransformer.inCallerContext(lambda: InlinedLambda, block: () -> T): T {
    val inlined = HashMap(receiverBindings)
    val inlinedLoops = loops
    receiverBindings.clear()
    receiverBindings.putAll(lambda.callerBindings)
    // a `break` or `continue` in the lambda leaves the caller's loops, not those of the inlined body
    loops = lambda.callerLoops
    try {
        return block()
    } finally {
        receiverBindings.clear()
        receiverBindings.putAll(inlined)
        loops = inlinedLoops
    }
}

/** The lambda bound to the inlined function's parameter that [e] names, if it does. */
internal fun FileTransformer.inlinedLambdaOf(e: KtExpression?): InlinedLambda? {
    if (inlinedLambdas.isEmpty()) return null
    val ref = KtPsiUtil.safeDeparenthesize(e ?: return null) as? KtNameReferenceExpression ?: return null
    return with(session) { (ref.mainReference.resolve() as? KtParameter)?.let { inlinedLambdas[it] } }
}

/** Whether [call] may be expanded into statements: it invokes an inlined lambda, or calls an `inline fun` of this program. */
internal fun FileTransformer.mayExpandInline(call: KtCallExpression): Boolean = with(session) {
    val callee = call.calleeExpression as? KtNameReferenceExpression ?: return false
    val target = callee.mainReference.resolve()
    when {
        target is KtParameter && target in inlinedLambdas -> true
        target is KtNamedFunction -> target.hasModifier(KtTokens.INLINE_KEYWORD) && classes.isSource(target)
        callee.getReferencedName() == "invoke" -> inlinedLambdaOf((call.parent as? KtDotQualifiedExpression)?.receiverExpression) != null
        else -> false
    }
}

/** `f(x)` or `f.invoke(x)` where `f` is a lambda parameter of an inlined function: the lambda's body, in place. */
internal fun FileTransformer.inlinedParameterCall(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr? = with(session) {
    if (inlinedLambdas.isEmpty()) return null
    val pas = call.partiallyAppliedSymbol
    val lambda = inlinedLambdaOf(pas.dispatchReceiver?.let { explicitReceiver(it) }) ?: return null
    val extension = pas.extensionReceiver?.let { receiverOperand(it, full) ?: return LuaNil }
    val values = arguments(listOfNotNull(extension), invokeArguments(call))
    val takesReceiver = (lambda.expr.expressionType as? KaFunctionType)?.hasReceiver == true
    val receiver = if (takesReceiver) values.firstOrNull() else null
    val args = if (takesReceiver) values.drop(1) else values
    return inCallerContext(lambda) {
        if (full.expressionType?.isUnitType == true) {
            inlineLambda(lambda.expr, args, receiver, null)
            LuaNil
        } else {
            inlineValue(lambda.expr, args, receiver)
        }
    }
}

private class InlineSite(
    val fn: KtNamedFunction,
    val call: KaCallableMemberCall<*, *>,
    val full: KtExpression,
    val lambdas: Map<KtParameter, InlinedLambda>,
    val provided: Map<KtParameter, KtExpression>,
    /** The arguments of a trailing `vararg` parameter, a spread among them. */
    val varargs: List<KtExpression>,
)

/**
 * The call expanded in place, or null if [call] is not to an `inline fun` of this program that has to be inlined:
 * one with a lambda argument that returns from the caller, or with a `reified` type parameter. The body is expanded at
 * the call site: arguments are evaluated once, in order, and bound to the parameters; a lambda argument is inlined
 * wherever the body invokes its parameter (so its `return` leaves the caller); a `return` in the body jumps to the end
 * of the expansion. `noinline` and `crossinline` lambdas stay closures. Declarations of the body whose names would
 * capture a name used by the call's arguments are renamed.
 */
internal fun FileTransformer.userInlineCall(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr? = with(session) {
    if (call !is KaFunctionCall<*>) return null
    val fn = call.symbol.psi as? KtNamedFunction ?: return null
    if (!fn.hasModifier(KtTokens.INLINE_KEYWORD) || !classes.isSource(fn) || fn.bodyExpression == null) return null
    val provided = call.valueArgumentMapping.entries.mapNotNull { (arg, sig) -> (sig.symbol.psi as? KtParameter)?.let { it to arg } }
        .groupBy({ it.first }, { it.second }).filterKeys { !it.isVarArg }.mapValues { it.value.single() }
    val lambdas = fn.valueParameters.filter(::isInlinedParameter).mapNotNull { p ->
        provided[p]?.let(::lambdaArgument)?.let { p to it }
    }.toMap()
    if (!fn.isReifiedInline() && lambdas.values.none { it.fromParameter || hasNonLocalJump(it) }) return null
    return inlineUserFunction(InlineSite(fn, call, full, lambdas, provided, varargArguments(fn, call)))
}

/** The arguments of the function's `vararg` parameter in source order, spreads (`*array`) among them. */
private fun FileTransformer.varargArguments(fn: KtNamedFunction, call: KaFunctionCall<*>): List<KtExpression> = with(session) {
    val vararg = fn.valueParameters.firstOrNull { it.isVarArg } ?: return emptyList()
    val args = call.valueArgumentMapping.entries.filter { it.value.symbol.psi == vararg }.map { it.key }
        .sortedBy { it.textRange.startOffset }
    args.filterTo(spreads) { (it.parent as? KtValueArgument)?.getSpreadElement() != null }
    return args
}

internal fun FileTransformer.isInlinedParameter(p: KtParameter) = with(session) {
    !p.hasModifier(KtTokens.NOINLINE_KEYWORD) && !p.hasModifier(KtTokens.CROSSINLINE_KEYWORD) &&
        p.returnType.let { it is KaFunctionType && !it.isMarkedNullable }
}

/** A lambda literal, or a parameter of an enclosing inlined function that holds one. */
private fun FileTransformer.lambdaArgument(arg: KtExpression): InlinedLambda? {
    inlinedLambdaOf(arg)?.let { return InlinedLambda(it.expr, true, it.callerBindings, it.callerLoops) }
    val unwrapped = KtPsiUtil.safeDeparenthesize(arg).let { (it as? KtLabeledExpression)?.baseExpression ?: it }
    return (unwrapped as? KtLambdaExpression)?.let { InlinedLambda(it, false, HashMap(receiverBindings), loops) }
}

/** Whether the lambda has a `return` that leaves the function it is written in, or a `break`/`continue` of a loop around it. */
private fun FileTransformer.hasNonLocalJump(lambda: InlinedLambda): Boolean = hasNonLocalJump(lambda.expr)

internal fun FileTransformer.hasNonLocalJump(lambda: KtLambdaExpression): Boolean {
    var found = false
    lambda.accept(object : KtTreeVisitorVoid() {
        override fun visitReturnExpression(expression: KtReturnExpression) {
            super.visitReturnExpression(expression)
            if (leavesLambda(expression, lambda)) found = true
        }

        override fun visitBreakExpression(expression: KtBreakExpression) {
            if (leavesLambda(expression, lambda)) found = true
        }

        override fun visitContinueExpression(expression: KtContinueExpression) {
            if (leavesLambda(expression, lambda)) found = true
        }
    })
    return found
}

/** Whether a `break` or `continue` in [lambda] targets a loop around it (Kotlin allows that only in inlined lambdas). */
private fun leavesLambda(jump: KtExpressionWithLabel, lambda: KtLambdaExpression): Boolean {
    val label = jump.getLabelName()
    var node: PsiElement? = jump.parent
    while (node != null && node !== lambda) {
        if (node is KtNamedFunction || node is KtPropertyAccessor || node is KtClassOrObject) return false
        if (node is KtLoopExpression && (label == null || (node.parent as? KtLabeledExpression)?.getLabelName() == label)) return false
        node = node.parent
    }
    return true
}

private fun FileTransformer.leavesLambda(ret: KtReturnExpression, lambda: KtLambdaExpression): Boolean {
    val label = ret.getLabelName()
    var node: PsiElement? = ret.parent
    while (node != null && node !== lambda) {
        when {
            node is KtNamedFunction && (label == null || label == node.name) -> return false
            node is KtLambdaExpression && label != null && label in lambdaLabels(node) -> return false
        }
        node = node.parent
    }
    return label == null || label !in lambdaLabels(lambda)
}

/** Changes to the transformer's state that last as long as one expansion. */
private class Scope {
    private val undo = mutableListOf<() -> Unit>()

    fun <K, V> put(map: MutableMap<K, V>, key: K, value: V) {
        val old = map.put(key, value)
        undo += { if (old == null) map.remove(key) else map[key] = old }
    }

    fun close() = undo.asReversed().forEach { it() }
}

private fun FileTransformer.inlineUserFunction(site: InlineSite): LuaExpr = with(session) {
    val fn = site.fn
    val pas = site.call.partiallyAppliedSymbol
    val receivers = listOfNotNull(pas.dispatchReceiver, pas.extensionReceiver).map { receiverOperand(it, site.full) ?: return LuaNil }
    val valueArgs = fn.valueParameters.filter { !it.isVarArg }.map { p -> site.provided[p]?.takeIf { p !in site.lambdas } } + site.varargs
    // a spread that is not last makes the rest of the vararg's arguments one `__K2L_Spread(...)`, the last element of the Array
    val collapsed = site.varargs.dropLast(1).any { it in spreads }
    val values = arguments(receivers, valueArgs).let {
        if (collapsed) {
            it
        } else {
            it +
                List(receivers.size + valueArgs.size - it.size) { LuaNil }
        }
    }

    val scope = Scope()
    avoidCaptures(site, values, scope)
    val unit = site.full.expressionType.let { it == null || it.isUnitType || it.isNothingType }
    val result = if (unit) null else ctx.temp("result").also { emit(LuaLocal(listOf(it))) }
    val sink: ValueSink? = result?.let { name -> { listOf(assign(name, it)) } }
    val frame = FunctionFrame(FunctionFrame.Kind.InlineFunction, setOfNotNull(fn.name), fn).also { it.sink = sink }
    val body = collect {
        bindTypeArguments(site, scope)
        bindReceivers(site, values, scope)
        bindParameters(site, values.drop(receivers.size), scope)
        inFrame(frame) { inlinedBody(fn, sink) }
    }
    emitInlinedBody(body, frame, site.full)
    scope.close()
    return result?.let { LuaName(it) } ?: LuaNil
}

private fun FileTransformer.bindTypeArguments(site: InlineSite, scope: Scope) {
    site.call.typeArgumentsMapping.forEach { (parameter, type) ->
        parameter.psi?.let { scope.put(reifiedTypes, it, reifiedType(type)) }
    }
}

private fun FileTransformer.bindReceivers(site: InlineSite, values: List<LuaExpr>, scope: Scope) {
    val pas = site.call.partiallyAppliedSymbol
    var next = 0
    if (pas.dispatchReceiver != null) {
        site.fn.containingClassOrObject?.let { scope.put(receiverBindings, it, cache(values[next], "this")) }
        next++
    }
    if (pas.extensionReceiver != null) scope.put(receiverBindings, site.fn, cache(values[next], "this"))
}

/** A parameter stands for its argument (substituted when it is stable, else copied to a local); lambdas are inlined where invoked. */
private fun FileTransformer.bindParameters(site: InlineSite, values: List<LuaExpr>, scope: Scope) {
    val varargAt = site.fn.valueParameters.indexOfFirst { it.isVarArg }
    for ((i, p) in site.fn.valueParameters.withIndex()) {
        val lambda = site.lambdas[p]
        when {
            p.isVarArg -> {
                // The arguments, spreads included, become the Array the body sees (they follow the other parameters' values).
                val array = LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), values.drop(site.fn.valueParameters.size - 1))
                scope.put(lambdaBindings, site.fn to p.name!!, bindToLocal(p, array))
            }

            lambda != null -> scope.put(inlinedLambdas, p, lambda)

            else -> bindArgument(site, p, if (varargAt in 0 until i) i - 1 else i, values, scope)
        }
    }
}

private fun FileTransformer.bindArgument(site: InlineSite, p: KtParameter, slot: Int, values: List<LuaExpr>, scope: Scope) {
    val value = if (site.provided[p] != null) values[slot] else with(session) { p.defaultValue?.let { expression(it) } }
    if (value != null) scope.put(lambdaBindings, site.fn to p.name!!, bindToLocal(p, value))
}

private fun FileTransformer.bindToLocal(p: KtParameter, value: LuaExpr): LuaExpr {
    if (isStable(value)) return value
    val local = naming.renamed(p) ?: LuaNames.of(p.name!!)
    emit(LuaLocal(listOf(local), listOf(value)))
    return LuaName(local).also { stable += it }
}

/** The function's statements; a `return` in tail position just hands its value to [sink]. */
private fun FileTransformer.inlinedBody(fn: KtNamedFunction, sink: ValueSink?): Unit = with(session) {
    val body = fn.bodyExpression ?: return
    fun result(value: KtExpression) = if (sink != null) emitAll(valueInto(value, sink)) else statement(value)
    if (!fn.hasBlockBody()) {
        result(body)
        return
    }
    val statements = (body as KtBlockExpression).statements
    statements.dropLast(1).forEach { statement(it) }
    val last = statements.lastOrNull() ?: return
    if (last is KtReturnExpression && (last.getLabelName() ?: fn.name) == fn.name) {
        last.returnedExpression?.let(::result)
    } else {
        statement(last)
    }
}

// ---- name hygiene ----

/**
 * The expansion puts the caller's code (the arguments, and the lambdas inlined into the body) in the scope of the body's
 * declarations. A declaration that has the name of something the call mentions gets a fresh name instead. Conversely, a
 * top-level declaration of this file that the body uses must not be hidden by a local of the caller.
 */
private fun FileTransformer.avoidCaptures(site: InlineSite, values: List<LuaExpr>, scope: Scope) {
    val used = HashSet<String>()
    site.full.accept(object : KtTreeVisitorVoid() {
        override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
            used += LuaNames.of(expression.getReferencedName())
            super.visitSimpleNameExpression(expression)
        }

        override fun visitNamedDeclaration(declaration: KtNamedDeclaration) {
            val name: String? = declaration.name
            if (name != null) used += LuaNames.of(name)
            super.visitNamedDeclaration(declaration)
        }

        override fun visitLambdaExpression(lambdaExpression: KtLambdaExpression) {
            used += "it"
            super.visitLambdaExpression(lambdaExpression)
        }
    })
    values.forEach { collectNames(it, used) }
    val body = site.fn.bodyExpression ?: return
    val declared = PsiTreeUtil.collectElements(body) { it is KtProperty || it is KtParameter || it is KtDestructuringDeclarationEntry }
        .filterIsInstance<KtNamedDeclaration>() + site.fn.valueParameters
    for (d in declared) {
        val raw: String? = d.name
        val name = raw?.takeIf { it != "_" }?.let { LuaNames.of(it) } ?: continue
        if (name in used) scope.put(naming.renames, d, ctx.temp(name))
    }
}

private fun collectNames(e: LuaExpr, out: MutableSet<String>) {
    when (e) {
        is LuaName -> out += e.name

        is LuaIndex -> listOf(e.target, e.key).forEach { collectNames(it, out) }

        is LuaCall -> (listOf(e.fn) + e.args).forEach { collectNames(it, out) }

        is LuaMethodCall -> (listOf(e.target) + e.args).forEach { collectNames(it, out) }

        is LuaBinary -> listOf(e.left, e.right).forEach { collectNames(it, out) }

        is LuaUnary -> collectNames(e.operand, out)

        is LuaTable -> e.fields.forEach { f ->
            when (f) {
                is LuaField.Positional -> collectNames(f.value, out)
                is LuaField.Named -> collectNames(f.value, out)
                is LuaField.Keyed -> listOf(f.key, f.value).forEach { collectNames(it, out) }
            }
        }

        else -> Unit
    }
}

internal fun KtNamedDeclaration.isTopLevel() = parent is KtFile
