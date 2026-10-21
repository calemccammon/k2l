package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.KtCallElement

/** Calls the base class constructor that [call] (a super-type entry or `super(...)`) resolves to. */
internal fun FileTransformer.superInit(call: KtCallElement?, info: SuperInfo): Unit = with(session) {
    val base = info.base
    when {
        info.collectionBase != null -> return collectionSuperInit(call, info.collectionBase)
        info.elementBase -> return elementSuperInit(call)
        info.randomBase -> return
        info.libraryBase != null -> return librarySuperInit(call, info.libraryBase)
        base == null -> return
    }
    val outer = if (isInner(base)) listOf(enclosingInstanceFor(base, call ?: base)) else emptyList()
    if (call == null) {
        if (classes.initNeeded(base)) emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString(INIT)), listOf(selfRef()) + outer)))
        return
    }
    val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
    val suffix = constructorSuffix(resolved.signature.symbol.psi)
    if (suffix.isEmpty() && !classes.initNeeded(base)) return
    val args = arguments(outer.map { it.asOperand() }, callArguments(resolved))
    emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString("$INIT$suffix")), listOf(selfRef()) + args)))
}

/** `AbstractCoroutineContextElement(key)` */
private fun FileTransformer.elementSuperInit(call: KtCallElement?): Unit = with(session) {
    val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
    val args = arguments(emptyList(), callArguments(resolved))
    val init = LuaIndex(lualibRef(COROUTINES_FEATURE, "__K2L_AbstractCoroutineContextElement"), LuaString(INIT))
    emit(LuaCallStmt(LuaCall(init, listOf(selfRef()) + args)))
}

/** A lualib exception class such as `__K2L_Exception`. */
private fun FileTransformer.librarySuperInit(call: KtCallElement?, libraryBase: String): Unit = with(session) {
    val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
    val args = resolved?.let { throwableArguments(callArguments(it), it.signature.symbol.valueParameters) }.orEmpty()
    emit(LuaCallStmt(LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, libraryBase), LuaString(INIT)), listOf(selfRef()) + args)))
}
