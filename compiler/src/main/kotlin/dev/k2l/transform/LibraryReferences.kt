package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtCallableReferenceExpression

/**
 * A reference to a standard library function or property, such as `String::length`, `::abs` or
 * `Int::toString`, as a Lua function that makes the same mapped call. Returns null if the library
 * call has no mapping.
 */
internal fun FileTransformer.libraryReference(e: KtCallableReferenceExpression, symbol: KaCallableSymbol): LuaExpr? = with(session) {
    val callableId = symbol.callableId ?: return null
    val valueParameters = (symbol as? KaFunctionSymbol)?.valueParameters.orEmpty()
    if (valueParameters.any { it.isVararg }) return null
    val receiverType = referenceReceiverType(symbol)
    val boundReceiver = e.receiverExpression?.takeIf { receiverType != null && isBoundReference(e) }
    val bound = boundReceiver?.let { cache(expression(it), "receiver") }
    val params = mutableListOf<String>()
    fun param() = "____p${params.size + 1}".also { params += it }
    val receiver = when {
        bound != null -> bound
        receiverType != null -> LuaName(param())
        else -> null
    }
    val args = valueParameters.map { LuaName(param()) }
    val site = CallSite(
        session = this,
        transformer = this@libraryReference,
        element = e,
        name = (symbol as? KaNamedFunctionSymbol)?.name?.asString() ?: symbol.callableId?.callableName?.asString(),
        receiver = receiver,
        receiverType = receiverType ?: bound?.let { boundReceiver.expressionType },
        args = args,
        argTypes = valueParameters.map { it.returnType },
    )
    var mapped: LuaExpr? = null
    val body = inFrame(FunctionFrame(FunctionFrame.Kind.Lambda, emptySet())) {
        collect {
            mapped = StdlibMappings.map(callableId.toString(), site)
            mapped?.let { emit(LuaReturn(listOf(it))) }
        }
    }
    return if (mapped == null) null else LuaFunction(params, body)
}

/** The type of the receiver a reference to [symbol] takes: its extension receiver or its containing class. */
context(s: KaSession)
private fun referenceReceiverType(symbol: KaCallableSymbol): KaType? = with(s) {
    symbol.receiverParameter?.returnType
        ?: (symbol.containingDeclaration as? KaClassSymbol)?.takeUnless { it.classKind.isObject }?.defaultType
}
