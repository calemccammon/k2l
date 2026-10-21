package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotated
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.psi.*

// Calls of external declarations (Lua interop, see LuaInterop).

/**
 * A call to (or access of) something implemented in Lua. Top-level functions are globals or fields of
 * a required module; members of external objects are called with `.`, instance members with `:`.
 */
internal fun FileTransformer.externalCall(
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    element: KtExpression,
): LuaExpr = with(session) {
    val symbol = call.partiallyAppliedSymbol.symbol
    val args = callArguments(call)
    val isFunction = call is KaFunctionCall<*>
    if (symbol is KaConstructorSymbol) return externalConstructor(symbol, args, element)
    val name = interop.luaName(symbol)
    val container = symbol.containingDeclaration as? KaClassSymbol
    if (container == null || container.classKind.isObject) {
        val base = when (container) {
            null -> interop.fileRequire(symbol.psi)?.let(interop::moduleRequire)
            else -> interop.externalClassRef(container)
        }
        val target = base?.let { LuaIndex(it, LuaString(name)) } ?: LuaName(name)
        return if (isFunction) LuaCall(target, arguments(emptyList(), args)) else target
    }
    val receiver = receiverOperand(implicit, receiverExpr) ?: return unsupported(element, "External member without a receiver")
    val values = arguments(listOf(receiver), args)
    if (!isFunction) return LuaIndex(values[0], LuaString(name))
    val noSelf = (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true || container.annotations.contains(NO_SELF)
    if (noSelf) return LuaCall(LuaIndex(values[0], LuaString(name)), values.drop(1))
    if (LuaPrinter.isIdentifier(name)) return LuaMethodCall(values[0], name, values.drop(1))
    // `@LuaName("repeat")`: `s:repeat(n)` is not Lua, `s["repeat"](s, n)` is
    val self = cache(values[0], "self")
    return LuaCall(LuaIndex(self, LuaString(name)), listOf(self) + values.drop(1))
}

private fun FileTransformer.externalConstructor(symbol: KaConstructorSymbol, args: List<KtExpression?>, element: KtExpression): LuaExpr =
    with(session) {
        val cls = symbol.containingClassId?.let { findClass(it) } ?: return unsupported(element, "This external constructor")
        val ref = interop.externalClassRef(cls) ?: return unsupported(element, "Constructing _G")
        return LuaCall(LuaIndex(ref, LuaString("new")), arguments(emptyList(), args))
    }
