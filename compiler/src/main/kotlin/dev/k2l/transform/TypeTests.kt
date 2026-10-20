package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolModality
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * Whether [type] is a final class of the program (not open, abstract, sealed, an interface, an enum or an object): its
 * instances are exactly the tables whose metatable is the class table, so `is` needs no walk up the hierarchy.
 */
internal fun FileTransformer.isFinalSourceClass(type: KaType): Boolean = with(session) {
    val symbol = type.expandedSymbol as? KaNamedClassSymbol ?: return false
    val psi = symbol.psi as? KtClass ?: return false
    return symbol.classKind == KaClassKind.CLASS && symbol.modality == KaSymbolModality.FINAL && classes.isSource(psi)
}

/** `value is C` for a final class `C`: `getmetatable(value) == C`, with the subject's metatable read once per `when`. */
internal fun FileTransformer.finalClassTest(value: LuaExpr, cls: LuaExpr): LuaExpr =
    LuaBinary(LuaBinOp.Eq, subjectMetatables[value] ?: luaCall(LuaName("getmetatable"), value), cls)

/**
 * Before a `when (subject)` with several `is` branches against final classes: `local ____mt = getmetatable(subject)`, used
 * by [finalClassTest] for those branches (the caller removes it after the `when`).
 */
internal fun FileTransformer.hoistSubjectMetatable(e: KtWhenExpression, subject: LuaExpr?): Unit = with(session) {
    if (subject == null || !isStable(subject)) return
    val finalTests = e.entries.sumOf { entry ->
        entry.conditions.count { c ->
            c is KtWhenConditionIsPattern &&
                c.typeReference?.type?.let { !it.isMarkedNullable && isFinalSourceClass(reifiedType(it)) } == true
        }
    }
    if (finalTests < 2) return
    val name = ctx.temp("mt")
    emit(LuaLocal(listOf(name), listOf(luaCall(LuaName("getmetatable"), subject))))
    subjectMetatables[subject] = LuaName(name).also { stable += it }
}
