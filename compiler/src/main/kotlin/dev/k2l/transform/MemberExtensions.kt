package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Extension functions and properties declared in a class have two receivers: the dispatch receiver (the instance, `self`)
 * and the extension receiver, which is passed as the first explicit argument of a method:
 * `fun String.unaryPlus()` in `Builder` is `function Builder:unaryPlus(____this)`, and `+"x"` inside the class (or in a
 * `with(builder) { }`) is `builder:unaryPlus("x")`. In the body `this` is the extension receiver and `this@Builder` is `self`.
 * A member extension property is a pair of methods, `getX(receiver)` and `setX(receiver, value)`.
 */
internal fun KtCallableDeclaration.isMemberExtension() = receiverTypeReference != null && containingClassOrObject != null

/** A call or read of a member extension of this program, or null if [call] is something else. */
internal fun FileTransformer.memberExtensionAccess(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr? = with(session) {
    val psi = call.partiallyAppliedSymbol.symbol.psi as? KtCallableDeclaration ?: return null
    if (!psi.isMemberExtension() || !classes.isSource(psi)) return null
    val pas = call.partiallyAppliedSymbol
    val receivers = listOfNotNull(pas.dispatchReceiver, pas.extensionReceiver).map { receiverOperand(it, full) ?: return LuaNil }
    return when (psi) {
        is KtNamedFunction -> {
            val values = arguments(receivers, callArguments(call))
            LuaMethodCall(values[0], naming.function(psi), values.drop(1))
        }

        is KtProperty -> {
            val values = arguments(receivers, emptyList())
            LuaMethodCall(values[0], accessorName("get", psi), values.drop(1))
        }

        else -> null
    }
}

/** `getX`/`setX` methods taking the extension receiver. */
internal fun FileTransformer.memberExtensionPropertyDeclaration(p: KtProperty, ref: LuaExpr) {
    val receiver = receiverName()
    val binding = LuaName(receiver).also { stable += it }
    receiverBindings[p] = binding
    listOfNotNull(p.getter, p.setter).forEach { receiverBindings[it] = binding }
    p.getter?.takeIf { it.hasBody() }?.let { getter ->
        val body = accessorFunction(getter, listOf(receiver))
        emitMethod(ref, accessorName("get", p), body.params, body.body)
    }
    val setter = p.setter?.takeIf { it.hasBody() }
    if (p.isVar && setter != null) {
        val body = accessorFunction(setter, listOf(receiver, LuaNames.of(setter.parameter?.name ?: "value")))
        emitMethod(ref, accessorName("set", p), body.params, body.body)
    }
}

/** The accessor methods of member extension properties share Lua's one namespace with functions and other accessors. */
internal fun FileTransformer.checkMemberExtensionProperties(c: KtClassOrObject) {
    val properties = c.declarations.filterIsInstance<KtProperty>().filter { it.name != null }
    val extensions = properties.filter { it.receiverTypeReference != null }
    if (extensions.isEmpty()) return
    fun methods(p: KtProperty) = listOfNotNull(accessorName("get", p), if (p.isVar) accessorName("set", p) else null)
    val others = properties.filter { it.receiverTypeReference == null && hasAccessors(it) }.flatMap(::methods) +
        c.declarations.filterIsInstance<KtNamedFunction>().map { naming.function(it) }
    val seen = HashSet<String>()
    for (p in extensions) {
        val clash = methods(p).firstOrNull { it in others || !seen.add(it) } ?: continue
        ctx.error(p, "Extension property '${p.name}' would share its Lua method '$clash' with another member")
    }
}

/** `this.x += 1` on a member extension property is `self:setX(r, self:getX(r) + 1)`, evaluating both receivers once. */
internal fun FileTransformer.memberExtensionPropertyTarget(
    p: KtProperty,
    ref: KtNameReferenceExpression,
    receiverExpr: KtExpression?,
): Target? = with(session) {
    val call = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    val pas = call.partiallyAppliedSymbol
    val dispatch = pas.dispatchReceiver?.let { implicitReceiver(it, ref) } ?: return null
    val extension = if (receiverExpr != null) {
        cache(expression(receiverExpr), "object")
    } else {
        pas.extensionReceiver?.let { implicitReceiver(it, ref) } ?: return null
    }
    if (!p.isVar) return null
    Target(LuaMethodCall(dispatch, accessorName("get", p), listOf(extension))) {
        LuaCallStmt(LuaMethodCall(dispatch, accessorName("set", p), listOf(extension, it)))
    }
}
