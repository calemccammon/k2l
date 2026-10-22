package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.*

/**
 * What identifies a callable for `==` between references: its id, with the receiver type of an extension and the parameter types
 * of a function (`kotlin.String.kotlin/text/uppercase()`), since overloads share an id. Local declarations have no id.
 */
context(s: KaSession)
internal fun referenceKey(symbol: KaCallableSymbol): String = with(s) {
    val id = symbol.callableId?.toString()
        ?: (symbol as? KaConstructorSymbol)?.containingClassId?.let { "$it.<init>" }
        ?: (symbol.psi as? KtNamedDeclaration)?.let { "${it.name}@${it.textOffset}" }
        ?: "?"
    val receiver = symbol.receiverParameter?.returnType?.let { "${it.pretty()}." }.orEmpty()
    val params = (symbol as? KaFunctionSymbol)?.valueParameters?.joinToString(",", "(", ")") { it.returnType.pretty() }.orEmpty()
    receiver + id + params
}

/**
 * A reference to a function or constructor with a `vararg` parameter, whose Lua function takes the vararg's elements as its
 * last arguments (see `callArguments`): when the function type passes the Array (`val f: (IntArray) -> Int = ::sum`), the
 * reference is a function unpacking it after the other arguments for [function], which takes [leading] receivers first. A
 * reference adapted to separate elements (`listOf(1).map(::sum)`) is [function] itself.
 */
internal fun FileTransformer.varargAdapter(
    e: KtCallableReferenceExpression,
    params: List<KtParameter>,
    leading: Int,
    function: LuaExpr,
): LuaExpr = with(session) {
    val at = params.indexOfFirst { it.isVarArg }
    val type = e.expressionType as? KaFunctionType
    if (at < 0 || type == null || function == LuaNil) return function
    val types = listOfNotNull(type.receiverType) + type.parameterTypes
    val elementType = (params[at].symbol as? KaValueParameterSymbol)?.returnType ?: return function
    if (types.size - leading != params.size || types[leading + at].semanticallyEquals(elementType)) return function
    val names = (1..types.size).map { "____p$it" }
    val args = names.map(::LuaName)
    val values = args.drop(leading)
    val target = if (function is LuaName || function is LuaIndex) function else cache(function, "reference")
    val call = LuaCall(target, args.take(leading) + values.filterIndexed { i, _ -> i != at } + lualibCall("Unpack", values[at]))
    LuaFunction(names, listOf(LuaReturn(listOf(call))))
}
