package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.KtClass
import org.jetbrains.kotlin.psi.KtExpression
import org.jetbrains.kotlin.psi.KtNamedFunction

/** The `fun interface` of the program [type] is, if any. */
internal fun FileTransformer.sourceFunInterface(type: KaType?): KtClass? = with(session) {
    val cls = type?.expandedSymbol?.psi as? KtClass ?: return null
    cls.takeIf { classes.isSource(it) && it.isInterface() && it.hasModifier(KtTokens.FUN_KEYWORD) }
}

/** A lambda (a function value) passed for a parameter whose type is a `fun interface` of the program is SAM-converted. */
internal fun FileTransformer.registerSamConversion(parameterType: KaType, arg: KtExpression): Unit = with(session) {
    val cls = sourceFunInterface(parameterType) ?: return
    if (arg.expressionType is KaFunctionType) callState.samConversions[arg] = cls
}

/**
 * `Check { x -> ... }` and SAM conversions to a `fun interface Check` of the program: an object of the interface whose
 * abstract method calls the function [f]. Without `self`, the method is [f] itself, and the object gets the interface's
 * other members without `self` bound to it.
 */
internal fun FileTransformer.funInterfaceObject(cls: KtClass, f: LuaExpr): LuaExpr {
    val method = cls.declarations.filterIsInstance<KtNamedFunction>().first { !it.hasBody() }
    val name = naming.function(method)
    if (!noSelf.isNoSelf(method)) return LuaCall(lualibRef(SAM_FEATURE, "__K2L_FunInterface"), listOf(classRef(cls), LuaString(name), f))
    val made = luaCall(LuaName("setmetatable"), LuaTable(listOf(LuaField.Named(name, f))), classRef(cls))
    val others = boundMembers(cls) - name
    if (others.isEmpty()) return made
    val target = cache(made, "object")
    bindMembers(target, others)
    return target
}
