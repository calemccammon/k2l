package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

/**
 * `Person::name`, `person::name` and `::counter` as values: a `__K2L_PropertyRef` (see `PropertyRef.lua`) with the property's
 * name and its getter and, for a `var`, setter. An unbound reference's accessors take the receiver first; a bound one (and
 * the reference to a property of an `object`) closes over it. Returns null for what is not supported.
 */
internal fun FileTransformer.propertyReference(e: KtCallableReferenceExpression, property: KtNamedDeclaration): LuaExpr? {
    val mutable = (property as? KtProperty)?.isVar ?: (property as KtParameter).isMutable
    if (property is KtProperty && property.delegate != null) return null
    val receiver = e.receiverExpression
    val (getter: LuaExpr, setter: LuaExpr) = when {
        property is KtProperty && property.receiverTypeReference != null -> extensionAccessors(e, property)
        isMemberProperty(property) -> memberAccessors(e, receiver ?: return null, property)
        property is KtProperty && property.isTopLevel -> topLevelAccessors(property)
        else -> null
    } ?: return null
    val args = listOf(LuaString(property.name!!), getter) + listOfNotNull(setter.takeIf { mutable })
    return LuaCall(LuaIndex(lualibRef("PropertyRef", "__K2L_PropertyRef"), LuaString("new")), args)
}

private fun FileTransformer.memberAccessors(
    e: KtCallableReferenceExpression,
    receiver: KtExpression,
    property: KtNamedDeclaration,
): Pair<LuaFunction, LuaFunction>? = with(session) {
    val owner = receiver.let { r ->
        (
            r as? KtNameReferenceExpression
                ?: (r as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
            )
    }
        ?.mainReference?.resolve()
    val bound = isBoundReference(e) || owner is KtObjectDeclaration
    val value = LuaName("value")
    if (!bound) {
        val self = LuaName("receiver")
        return LuaFunction(listOf("receiver"), listOf(LuaReturn(listOf(propertyRead(self, property))))) to
            LuaFunction(listOf("receiver", "value"), listOf(propertyWrite(self, property, value)))
    }
    val target = cache(expression(receiver), "receiver")
    LuaFunction(emptyList(), listOf(LuaReturn(listOf(propertyRead(target, property))))) to
        LuaFunction(listOf("value"), listOf(propertyWrite(target, property, value)))
}

private fun FileTransformer.topLevelAccessors(property: KtProperty): Pair<LuaFunction, LuaFunction> {
    val value = LuaName("value")
    if (property.hasAccessorFunctions()) {
        val set = if (property.isVar) topLevelRef(property, naming.propertyAccessor(property, "set")) else LuaNil
        return LuaFunction(emptyList(), listOf(LuaReturn(listOf(accessorPropertyRead(property))))) to
            LuaFunction(listOf("value"), listOf(LuaCallStmt(LuaCall(set, listOf(value)))))
    }
    val slot = topLevelRef(property)
    return LuaFunction(emptyList(), listOf(LuaReturn(listOf(slot)))) to LuaFunction(listOf("value"), listOf(assign(slot, value)))
}

/** `String::lastChar` takes the receiver first, `"abc"::lastChar` closes over it; the accessors are the generated functions. */
private fun FileTransformer.extensionAccessors(e: KtCallableReferenceExpression, property: KtProperty): Pair<LuaExpr, LuaExpr>? =
    with(session) {
        if (!property.isTopLevel) return null
        val get = topLevelRef(property, naming.propertyAccessor(property, "get"))
        val set = if (property.isVar) topLevelRef(property, naming.propertyAccessor(property, "set")) else LuaNil
        val receiver = e.receiverExpression
        if (receiver == null || !isBoundReference(e)) return get to set
        val target = cache(expression(receiver), "receiver")
        val value = LuaName("value")
        LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(get, listOf(target)))))) to
            LuaFunction(listOf("value"), listOf(LuaCallStmt(LuaCall(set, listOf(target, value)))))
    }
