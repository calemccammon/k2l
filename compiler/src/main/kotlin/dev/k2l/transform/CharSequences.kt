package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

private const val CHAR_SEQUENCE = "kotlin/CharSequence"

/**
 * Whether a value of [type] can be an object of a class of the program implementing `CharSequence` (only when the program
 * declares one): the library's text functions then run on its toString() (`__K2L_CharSequenceText`), as strings are Lua
 * strings.
 */
internal fun FileTransformer.isCharSequenceObject(type: KaType?): Boolean = with(session) {
    if (!implementsCharSequence || type == null || type.isStringType) return false
    val symbol = type.withoutFlexibility.expandedSymbol ?: return false
    symbol.classId?.asString() == CHAR_SEQUENCE ||
        (classes.isSource(symbol.psi) && type.allSupertypes.any { it.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE })
}

/** [value] of [type], as the string the library's text functions take. */
internal fun FileTransformer.charSequenceText(value: LuaExpr, type: KaType?): LuaExpr =
    if (isCharSequenceObject(type)) lualibCall("CharSequenceText", value) else value
