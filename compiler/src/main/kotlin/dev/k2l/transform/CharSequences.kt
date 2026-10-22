package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

private const val CHAR_SEQUENCE = "kotlin/CharSequence"

/** `Any`'s members, which a CharSequence object answers itself rather than with its text. */
internal val CHAR_SEQUENCE_OWN_MEMBERS = setOf("toString", "equals", "hashCode")

/**
 * Whether a value of [type] can be something other than a string where the library expects text: a value typed
 * `CharSequence` (a string, a `StringBuilder` or an object of a class of the program implementing it), or an object of such
 * a class. The library's text functions then run on its text (`__K2L_CharSequenceText`), as strings are Lua strings.
 */
internal fun FileTransformer.isCharSequenceObject(type: KaType?): Boolean = with(session) {
    if (type == null || type.isStringType) return false
    val symbol = type.withoutFlexibility.expandedSymbol ?: return false
    if (symbol.classId?.asString() == CHAR_SEQUENCE) return true
    implementsCharSequence && classes.isSource(symbol.psi) &&
        type.allSupertypes.any { it.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE }
}

/** [value] of [type], as the string the library's text functions take. */
internal fun FileTransformer.charSequenceText(value: LuaExpr, type: KaType?): LuaExpr =
    if (isCharSequenceObject(type)) lualibCall("CharSequenceText", value) else value

/** Whether the receiver of a library call of [name] on a value of [type] is passed as its text, see [isCharSequenceObject]. */
internal fun FileTransformer.isTextReceiver(name: String?, type: KaType?): Boolean =
    name !in CHAR_SEQUENCE_OWN_MEMBERS && isCharSequenceObject(type)

/** [values] of [types] passed to library parameters of [parameterTypes] (the last one is the vararg's), see [charSequenceArgument]. */
internal fun FileTransformer.charSequenceArguments(
    values: List<LuaExpr>,
    types: List<KaType?>,
    parameterTypes: List<KaType?>,
): List<LuaExpr> =
    values.mapIndexed { i, v -> charSequenceArgument(v, types.getOrNull(i), parameterTypes.getOrNull(i) ?: parameterTypes.lastOrNull()) }

/**
 * An argument [value] of [type] passed to a library parameter of [parameterType] (null when unknown): as its text when the
 * parameter takes a `CharSequence` and the value may not be a string (a `StringBuilder` too, `"abc".contains(sb)`).
 */
internal fun FileTransformer.charSequenceArgument(value: LuaExpr, type: KaType?, parameterType: KaType?): LuaExpr = with(session) {
    if (parameterType == null) return charSequenceText(value, type)
    val takesText = parameterType.withoutFlexibility.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE
    val builder = type != null && !type.isStringType && type.collectionKind() == CollectionKind.StringBuilder
    if (takesText && (builder || isCharSequenceObject(type))) lualibCall("CharSequenceText", value) else value
}

/**
 * `length`, `s[i]`, `lastIndex` and `indices` of a value that may not be a string ([isCharSequenceObject]): the members of
 * the object itself (`__K2L_Text.charsLength`), as the JVM calls them, rather than of its text.
 */
internal fun FileTransformer.charSequenceMember(callableId: String?, receiver: LuaExpr, args: List<LuaExpr>): LuaExpr? {
    fun length(of: LuaExpr) = textMember("charsLength", of)
    return when (callableId) {
        "kotlin/CharSequence.length" -> length(receiver)
        "kotlin/CharSequence.get" -> textMember("charsGet", receiver, args.firstOrNull() ?: return null)
        "kotlin/text/lastIndex" -> LuaBinary(LuaBinOp.Sub, length(receiver), LuaNumber("1"))
        "kotlin/text/indices" -> libNew(INT_RANGE_TABLE, listOf(LuaNumber("0"), LuaBinary(LuaBinOp.Sub, length(receiver), LuaNumber("1"))))
        else -> null
    }
}

/** `for (c in s)` over a value that may not be a string: its chars, read with `get(i)` while `i < length` like the JVM's iterator. */
internal fun FileTransformer.charSequenceLoop(text: LuaExpr, variable: String, body: List<LuaStmt>) {
    emit(LuaGenericFor(listOf(variable), listOf(textMember("chars", text)), body))
}

private fun FileTransformer.textMember(member: String, vararg args: LuaExpr): LuaExpr = libCall(TEXT_TABLE, member, args.toList())

/** `for (c in s)` by byte index, `local c = s:sub(i, i)` (LuaJIT compiles `sub`, not the `gmatch(".")` iterator). */
internal fun FileTransformer.eachChar(text: LuaExpr, variable: String, body: List<LuaStmt>) {
    val s = cache(text, "text")
    val i = LuaName(ctx.temp("i"))
    val char = LuaLocal(listOf(variable), listOf(LuaMethodCall(s, "sub", listOf(i, i))))
    emit(LuaNumericFor(i.name, LuaNumber("1"), LuaUnary(LuaUnOp.Len, s), null, listOf(char) + body))
}

/** A Char's code (its byte). */
internal fun charCode(c: LuaExpr): LuaExpr = LuaMethodCall(c, "byte", emptyList())

/** The Char of a code. */
internal fun charFromCode(code: LuaExpr): LuaExpr = lua("string.char", code)
