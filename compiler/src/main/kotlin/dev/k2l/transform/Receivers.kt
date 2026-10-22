package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaExplicitReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaImplicitReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaSmartCastedReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaAnonymousObjectSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaReceiverParameterSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

// Receivers: this, implicit receivers and the explicit receiver of a call.

/** `Math` in `Math.abs(x)` or `Random` in `Random.nextInt()`: a library class named as the receiver, not a value. */
internal fun FileTransformer.isLibraryClassQualifier(value: KaReceiverValue): Boolean = with(session) {
    val expr = explicitReceiver(value) ?: return false
    val ref = expr as? KtNameReferenceExpression ?: (expr as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
    val symbol = ref?.mainReference?.resolveToSymbol()
    return symbol is KaClassLikeSymbol && symbol.classId?.asString() !in LIBRARY_OBJECTS && !classes.isSource(symbol.psi) &&
        !interop.isExternal(symbol)
}

internal fun FileTransformer.explicitReceiver(value: KaReceiverValue): KtExpression? = with(session) {
    when (value) {
        is KaExplicitReceiverValue -> value.expression
        is KaSmartCastedReceiverValue -> explicitReceiver(value.original)
        else -> null
    }
}

internal fun FileTransformer.thisRef(e: KtThisExpression): LuaExpr = with(session) {
    receiverValue(e.instanceReference.mainReference.resolveToSymbol(), e) ?: LuaNil
}

internal fun FileTransformer.implicitReceiverOf(ref: KtNameReferenceExpression): LuaExpr? = with(session) {
    val call = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    val value = call.partiallyAppliedSymbol.dispatchReceiver ?: return null
    return implicitReceiver(value, ref)
}

/** The Lua value of an implicit `this`. */
internal fun FileTransformer.implicitReceiver(value: KaReceiverValue, element: KtElement): LuaExpr? = with(session) {
    val original = (value as? KaSmartCastedReceiverValue)?.original ?: value
    return receiverValue((original as? KaImplicitReceiverValue)?.symbol, element)
}

/**
 * What a `this` symbol is in Lua: `self` for the class being transformed, the table of an object or
 * companion, or the receiver parameter of an extension function or lambda.
 */
private fun FileTransformer.receiverValue(symbol: KaSymbol?, element: KtElement): LuaExpr? = with(session) {
    val psi = when (symbol) {
        is KaReceiverParameterSymbol -> symbol.owningCallableSymbol.psi

        // an object expression, or the body of an enum entry
        is KaAnonymousObjectSymbol -> objectLiteralOf(symbol.psi) ?: symbol.containingDeclaration?.psi

        else -> symbol?.psi
    }
    receiverBindings[psi]?.let { return it }
    val enclosing = if (psi is KtClassOrObject) enclosingInstances().firstOrNull { it.first == psi }?.second else null
    return when {
        enclosing != null -> enclosing

        psi is KtObjectDeclaration && classes.isSource(psi) -> classRef(psi)

        else -> {
            unsupported(element, "This receiver")
            null
        }
    }
}
