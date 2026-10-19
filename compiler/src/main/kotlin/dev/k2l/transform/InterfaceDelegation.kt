package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.isPrivate

/**
 * `class C(impl: I) : I by impl`: the constructor stores each delegate in a hidden field (`self.____delegate_I`), evaluating
 * its expression once, after the superclass constructor and before the property initializers and `init` blocks.
 */
internal fun FileTransformer.delegateFields(c: KtClassOrObject): Unit = with(session) {
    for (d in classes.superInfo(c).delegations) {
        val expr = d.entry.delegateExpression ?: continue
        emitAll(valueInto(expr) { listOf(assign(LuaIndex(selfRef(), LuaString(d.field)), it)) })
    }
}

/**
 * The members of a delegated interface (and of its superinterfaces), default methods included, forward to the delegate
 * unless the class declares them itself, as Kotlin does. Properties of delegated interfaces always use accessors (see
 * [PropertyFamilies]), so `getX`/`setX` forward too. `toString`, `equals` and `hashCode` are only forwarded when the
 * interface declares them.
 */
internal fun FileTransformer.delegatedMembers(c: KtClassOrObject, ref: LuaExpr) {
    val delegations = classes.superInfo(c).delegations
    if (delegations.isEmpty()) return
    val defined = ownMethodNames(c)
    for (d in delegations) {
        for (iface in classes.hierarchy(d.iface)) {
            iface.declarations.flatMap(::forwardedNames).filter { defined.add(it) }.forEach { forward(ref, d.field, it) }
        }
    }
}

private fun FileTransformer.forwardedNames(decl: KtDeclaration): List<String> = when {
    decl is KtNamedFunction && !decl.isPrivate() -> listOf(naming.function(decl))

    decl is KtProperty && !decl.isPrivate() && hasAccessors(decl) ->
        listOfNotNull(accessorName("get", decl), accessorName("set", decl).takeIf { decl.isVar })

    else -> emptyList()
}

/** The Lua methods [c] declares: its functions and the accessors of its properties. */
private fun FileTransformer.ownMethodNames(c: KtClassOrObject): MutableSet<String> {
    val names = HashSet<String>()
    val properties = c.declarations.filterIsInstance<KtProperty>() +
        (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }.orEmpty()
    properties.filter { hasAccessors(it) }.forEach { names += listOf(accessorName("get", it), accessorName("set", it)) }
    c.declarations.filterIsInstance<KtNamedFunction>().forEach { names += naming.function(it) }
    return names
}

/** `function C:name(...) return self.____delegate_I:name(...) end` */
private fun FileTransformer.forward(ref: LuaExpr, field: String, name: String) {
    val call = LuaMethodCall(LuaIndex(selfRef(), LuaString(field)), name, listOf(LuaName("...")))
    val fn = LuaFunction(emptyList(), listOf(LuaReturn(listOf(call))), isVararg = true)
    emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), fn, isLocal = false, isMethod = true))
}
