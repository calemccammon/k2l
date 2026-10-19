package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaConstantInitializerValue
import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaKotlinPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

/** A property reference's getter and setter (null for a `val`), and the receiver a bound reference closes over. */
private class Accessors(val getter: LuaExpr, val setter: LuaExpr?, val receiver: LuaExpr? = null)

/**
 * `__K2L_PropertyRef.new(name, key, getter, setter, receiver)` (see `PropertyRef.lua`): [key] identifies the property for `==`,
 * [receiver] is the value a bound reference closes over.
 */
internal fun FileTransformer.propertyRefObject(name: String, key: String, getter: LuaExpr, setter: LuaExpr?, receiver: LuaExpr?): LuaExpr {
    val args = listOf(LuaString(name), LuaString(key), getter, setter ?: LuaNil, receiver ?: LuaNil).dropLastWhile { it == LuaNil }
    return LuaCall(LuaIndex(lualibRef("PropertyRef", "__K2L_PropertyRef"), LuaString("new")), args)
}

/**
 * `Person::name`, `person::name` and `::counter` as values: a `__K2L_PropertyRef` with the property's name and its getter and,
 * for a `var`, setter. An unbound reference's accessors take the receiver first; a bound one (and the reference to a property of
 * an `object`) closes over it. Returns null for what is not supported.
 */
internal fun FileTransformer.propertyReference(e: KtCallableReferenceExpression, property: KtNamedDeclaration): LuaExpr? = with(session) {
    val mutable = (property as? KtProperty)?.isVar ?: (property as KtParameter).isMutable
    val receiver = e.receiverExpression
    val accessors = when {
        property is KtProperty && property.receiverTypeReference != null -> extensionAccessors(e, property)
        isMemberProperty(property) -> memberAccessors(e, receiver, property) ?: return null
        property is KtProperty && property.isTopLevel -> topLevelAccessors(property)
        else -> null
    } ?: return null
    val symbol = property.symbol as KaCallableSymbol
    propertyRefObject(property.name!!, referenceKey(symbol), accessors.getter, accessors.setter?.takeIf { mutable }, accessors.receiver)
}

/**
 * A reference to a library property (`String::length`, `"abc"::length`, `List<*>::size`, `CharSequence::indices`): a property
 * reference whose getter makes the mapped read. Passed straight to a parameter of a function type (`map(String::length)`) it
 * stays the plain getter function.
 */
internal fun FileTransformer.libraryPropertyReference(e: KtCallableReferenceExpression, symbol: KaPropertySymbol): LuaExpr = with(session) {
    // Writes to library properties are not mapped
    if (!symbol.isVal) return unsupported(e, "Reference to the mutable library property '${symbol.name}'")
    val reference = libraryReference(e, symbol) ?: libraryConstant(e, symbol)
        ?: return unsupported(e, "Reference to library property '${symbol.name}'")
    val expected = e.expectedType
    if (expected is KaFunctionType && !expected.isReflectionFunctionType()) return reference.function
    propertyRefObject(symbol.name.asString(), referenceKey(symbol), reference.function, null, reference.receiver)
}

/** `Int.Companion::MAX_VALUE`: a library constant (which reads fold to a literal) as a getter returning it. */
@OptIn(KaExperimentalApi::class)
private fun FileTransformer.libraryConstant(e: KtCallableReferenceExpression, symbol: KaPropertySymbol): ReferenceValue? {
    val constant = ((symbol as? KaKotlinPropertySymbol)?.initializer as? KaConstantInitializerValue)?.constant ?: return null
    return ReferenceValue(LuaFunction(emptyList(), listOf(LuaReturn(listOf(constantValue(constant, e))))), null)
}

private fun FileTransformer.memberAccessors(
    e: KtCallableReferenceExpression,
    receiver: KtExpression?,
    property: KtNamedDeclaration,
): Accessors? = with(session) {
    // `::count` inside the class is bound to the implicit `this`
    val implicit = if (receiver == null) implicitReferenceReceiver(e) ?: return null else null
    val owner = receiver?.let { r ->
        (
            r as? KtNameReferenceExpression
                ?: (r as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
            )
    }
        ?.mainReference?.resolve()
    val bound = implicit != null || isBoundReference(e) || owner is KtObjectDeclaration
    val value = LuaName("value")
    if (!bound) {
        val self = LuaName("receiver")
        return Accessors(
            LuaFunction(listOf("receiver"), listOf(LuaReturn(listOf(propertyRead(self, property))))),
            LuaFunction(listOf("receiver", "value"), listOf(propertyWrite(self, property, value))),
        )
    }
    val target = cache(implicit ?: expression(receiver!!), "receiver")
    Accessors(
        LuaFunction(emptyList(), listOf(LuaReturn(listOf(propertyRead(target, property))))),
        LuaFunction(listOf("value"), listOf(propertyWrite(target, property, value))),
        target,
    )
}

private fun FileTransformer.topLevelAccessors(property: KtProperty): Accessors {
    val value = LuaName("value")
    if (property.delegate != null) {
        val target = delegatedVariableTarget(property) ?: return Accessors(LuaNil, null)
        return Accessors(
            LuaFunction(emptyList(), listOf(LuaReturn(listOf(target.read)))),
            if (property.isVar) LuaFunction(listOf("value"), listOf(target.write(value))) else null,
        )
    }
    if (property.hasAccessorFunctions()) {
        val set = if (property.isVar) topLevelRef(property, naming.propertyAccessor(property, "set")) else LuaNil
        return Accessors(
            LuaFunction(emptyList(), listOf(LuaReturn(listOf(accessorPropertyRead(property))))),
            LuaFunction(listOf("value"), listOf(LuaCallStmt(LuaCall(set, listOf(value))))),
        )
    }
    val slot = topLevelRef(property)
    return Accessors(LuaFunction(emptyList(), listOf(LuaReturn(listOf(slot)))), LuaFunction(listOf("value"), listOf(assign(slot, value))))
}

/** `String::lastChar` takes the receiver first, `"abc"::lastChar` closes over it; the accessors are the generated functions. */
private fun FileTransformer.extensionAccessors(e: KtCallableReferenceExpression, property: KtProperty): Accessors? = with(session) {
    if (!property.isTopLevel) return null
    val get = topLevelRef(property, naming.propertyAccessor(property, "get"))
    val set = if (property.isVar) topLevelRef(property, naming.propertyAccessor(property, "set")) else LuaNil
    val receiver = e.receiverExpression
    if (receiver == null || !isBoundReference(e)) return Accessors(get, set)
    val target = cache(expression(receiver), "receiver")
    val value = LuaName("value")
    Accessors(
        LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(get, listOf(target)))))),
        LuaFunction(listOf("value"), listOf(LuaCallStmt(LuaCall(set, listOf(target, value))))),
        target,
    )
}
