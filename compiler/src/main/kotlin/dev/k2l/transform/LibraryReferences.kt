package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtCallableReferenceExpression

/**
 * A reference to a standard library function or property, such as `String::length`, `::abs` or
 * `Int::toString`, as a Lua function that makes the same mapped call. Returns null if the library
 * call has no mapping.
 */
internal fun FileTransformer.libraryReference(e: KtCallableReferenceExpression, symbol: KaCallableSymbol): ReferenceValue? = with(session) {
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
    return if (mapped == null) null else ReferenceValue(LuaFunction(params, body), bound)
}

/** The type of the receiver a reference to [symbol] takes: its extension receiver or its containing class. */
context(s: KaSession)
private fun referenceReceiverType(symbol: KaCallableSymbol): KaType? = with(s) {
    symbol.receiverParameter?.returnType
        ?: (symbol.containingDeclaration as? KaClassSymbol)?.takeUnless { it.classKind.isObject }?.defaultType
}

/**
 * `::ArrayList`, `::Pair`, `::IllegalStateException` or `::Regex`: a Lua function that constructs the library (or external)
 * class the way a call of the same constructor does. Null if such a call has no mapping either.
 */
internal fun FileTransformer.libraryConstructorReference(e: KtCallableReferenceExpression, symbol: KaConstructorSymbol): LuaExpr? =
    with(session) {
        val classId = symbol.containingClassId ?: return null
        if (interop.isExternal(symbol)) {
            val cls = findClass(classId) ?: return null
            return interop.externalClassRef(cls)?.let { LuaIndex(it, LuaString("new")) }
        }
        val valueParameters = symbol.valueParameters
        if (valueParameters.any { it.isVararg }) return null
        val params = valueParameters.indices.map { "____p${it + 1}" }
        val args = params.map { LuaName(it) }
        val types = valueParameters.map { it.returnType }
        val site = CallSite(this, this@libraryConstructorReference, e, null, null, null, args, types)
        var mapped: LuaExpr? = null
        val body = inFrame(FunctionFrame(FunctionFrame.Kind.Lambda, emptySet())) {
            collect {
                val exception = LIBRARY_CLASSES[classId.asString()]
                mapped = if (exception != null) {
                    LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, exception), LuaString("new")), throwableParameters(args, types))
                } else {
                    FactoryMappings.construct(classId.asString(), site)
                }
                mapped?.let { emit(LuaReturn(listOf(it))) }
            }
        }
        return if (mapped == null) null else LuaFunction(params, body)
    }

/** The message and cause that a reference to an exception constructor passes on, as `throwableArguments` does for a call. */
private fun KaSession.throwableParameters(args: List<LuaExpr>, types: List<KaType>): List<LuaExpr> {
    val isMessage = types.map { it.withoutFlexibility.expandedSymbol?.classId?.asString() == "kotlin/String" }
    val message = args.filterIndexed { i, _ -> isMessage[i] }.firstOrNull()
    val cause = args.filterIndexed { i, _ -> !isMessage[i] }.firstOrNull()
    return if (cause == null) listOfNotNull(message) else listOf(message ?: LuaNil, cause)
}
