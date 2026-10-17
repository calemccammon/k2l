package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Field of an enum class table holding its entries in order. */
internal const val ENUM_VALUES = "____values"

internal fun FileTransformer.enumEntries(c: KtClass, ref: LuaExpr): Unit = with(session) {
    val entries = c.declarations.filterIsInstance<KtEnumEntry>()
    entries.forEachIndexed { ordinal, entry ->
        val callEntry = entry.initializerList?.initializers?.firstOrNull() as? KtSuperTypeCallEntry
        val resolved = callEntry?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
        val suffix = constructorSuffix(resolved?.signature?.symbol?.psi ?: implicitConstructor(c))
        val args = if (resolved != null) arguments(emptyList(), callArguments(resolved)) else emptyList()
        val ctorArgs = listOf(LuaString(entry.name!!), LuaNumber(ordinal.toString())) + args
        val entryRef = LuaIndex(ref, LuaString(entry.name!!))
        if (entry.body == null) {
            emit(assign(entryRef, LuaCall(LuaIndex(ref, LuaString("new$suffix")), ctorArgs)))
        } else {
            emit(LuaDo(entryWithBody(entry, ref, suffix, ctorArgs)))
        }
    }
    val values = entries.map { LuaField.Positional(LuaIndex(ref, LuaString(it.name!!))) }
    emit(assign(LuaIndex(ref, LuaString(ENUM_VALUES)), LuaTable(values)))
}

/** The constructor an entry without arguments calls: the primary one, or else a secondary one callable with no arguments. */
private fun implicitConstructor(c: KtClass): KtSecondaryConstructor? =
    if (hasPrimary(c)) null else c.secondaryConstructors.firstOrNull { ctor -> ctor.valueParameters.all { it.hasDefaultValue() } }

/**
 * An entry with a body is an instance of an anonymous subclass of its enum class. Returns the statements of
 * the `do` block that defines the subclass and assigns the entry.
 */
private fun FileTransformer.entryWithBody(entry: KtEnumEntry, enumRef: LuaExpr, suffix: String, ctorArgs: List<LuaExpr>): List<LuaStmt> =
    collect {
        val enumClass = entry.containingClassOrObject!!
        val local = LuaName(ctx.temp(entry.name!!))
        emit(LuaLocal(listOf(local.name), listOf(lualibCall("Class", LuaString(enumClass.name ?: "?"), enumRef))))
        withClass(entry) {
            checkMembers(entry)
            members(entry, local)
            val init = collect { initializers(entry) }
            if (init.isNotEmpty() || suffix.isNotEmpty()) {
                val parentInit = LuaIndex(enumRef, LuaString("$INIT$suffix"))
                val body = listOf(LuaCallStmt(LuaCall(parentInit, listOf(selfRef(), LuaName("..."))))) + init
                emit(
                    LuaFunctionDecl(
                        LuaIndex(local, LuaString(INIT)),
                        LuaFunction(emptyList(), body, isVararg = true),
                        isLocal = false,
                        isMethod = true,
                    ),
                )
            }
        }
        emit(assign(LuaIndex(enumRef, LuaString(entry.name!!)), LuaCall(LuaIndex(local, LuaString("new")), ctorArgs)))
    }
