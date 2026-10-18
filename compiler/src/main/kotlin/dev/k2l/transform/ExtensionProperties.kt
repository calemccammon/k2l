package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Extension properties are plain functions taking the receiver first: `val String.lastChar` becomes
 * `getLastChar(self)`, and a `var` also gets `setLastChar(self, value)`.
 */
internal fun FileTransformer.extensionPropertyDeclaration(p: KtProperty, forwardDeclared: Boolean) {
    if (p.containingClassOrObject != null) return // reported by checkMembers
    val receiver = receiverName()
    val binding = LuaName(receiver).also { stable += it }
    receiverBindings[p] = binding
    listOfNotNull(p.getter, p.setter).forEach { receiverBindings[it] = binding }
    p.getter?.takeIf { it.hasBody() }?.let { getter ->
        val body = accessorFunction(getter, listOf(receiver))
        emit(LuaFunctionDecl(LuaName(naming.propertyAccessor(p, "get")), body, isLocal = !forwardDeclared))
    }
    val setter = p.setter?.takeIf { it.hasBody() }
    if (p.isVar && setter != null) {
        val param = LuaNames.of(setter.parameter?.name ?: "value")
        val body = accessorFunction(setter, listOf(receiver, param))
        emit(LuaFunctionDecl(LuaName(naming.propertyAccessor(p, "set")), body, isLocal = !forwardDeclared))
    }
}

internal fun FileTransformer.accessorFunction(accessor: KtPropertyAccessor, params: List<String>): LuaFunction = with(session) {
    inFrame(FunctionFrame(FunctionFrame.Kind.Function, emptySet(), accessor)) {
        LuaFunction(params, collect { functionBody(accessor) })
    }
}

/** `s.lastChar` is `getLastChar(s)`. */
internal fun FileTransformer.extensionPropertyRead(p: KtProperty, receiverExpr: KtExpression?, implicit: LuaExpr?): LuaExpr =
    with(session) {
        val receiver = receiverOperand(implicit, receiverExpr) ?: return unsupported(p, "Extension property without a receiver")
        LuaCall(topLevelRef(p, naming.propertyAccessor(p, "get")), arguments(listOf(receiver), emptyList()))
    }

/** Assignment to a top-level or local property (not a member): a variable, a delegated variable or an extension property. */
internal fun FileTransformer.variableTarget(p: KtProperty, ref: KtNameReferenceExpression, receiverExpr: KtExpression?): Target? = when {
    p.receiverTypeReference != null -> extensionPropertyTarget(p, ref, receiverExpr)

    p.hasAccessorFunctions() -> accessorPropertyTarget(p)

    p.delegate != null -> delegatedVariableTarget(p)

    else -> {
        val name = if (p.isTopLevel) topLevelRef(p) else LuaName(naming.of(p))
        Target(name) { assign(name, it) }
    }
}

/** `s.x += 1` is `setX(s, getX(s) + 1)`, evaluating the receiver once. */
internal fun FileTransformer.extensionPropertyTarget(p: KtProperty, ref: KtNameReferenceExpression, receiverExpr: KtExpression?): Target? =
    with(session) {
        val receiver = if (receiverExpr != null) {
            cache(expression(receiverExpr), "object")
        } else {
            val value = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()?.partiallyAppliedSymbol?.extensionReceiver
            value?.let { implicitReceiver(it, ref) } ?: return null
        }
        if (!p.isVar) return null
        val get = topLevelRef(p, naming.propertyAccessor(p, "get"))
        val set = topLevelRef(p, naming.propertyAccessor(p, "set"))
        Target(LuaCall(get, listOf(receiver))) { LuaCallStmt(LuaCall(set, listOf(receiver, it))) }
    }
