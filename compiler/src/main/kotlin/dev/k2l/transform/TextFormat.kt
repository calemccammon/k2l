package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `String.format(format, args)` and `format.format(args)` are Lua's `string.format`. A literal format is translated here:
 * `%n` is a newline, `%s`, `%S`, `%b` and `%B` take the text of their argument (its `toString()`), `%c` of a Char its string,
 * the `,` flag of `%d` and `%f` groups the digits by three (`__K2L_Text.grouped`), and the specifiers Lua has no equivalent
 * of (argument indexes, `%<s`, the `(` flag, `%h`, dates) are reported.
 * Other formats go through `__K2L_StringFormat` (Strings.lua), which does the same at run time and raises an error there.
 * The overloads taking a `Locale` are not supported.
 */
internal object TextFormat {
    /** `%[index$][flags][width][.precision]conversion`, as java.util.Formatter reads it. */
    private val SPECIFIER = Regex("%(\\d+\\$)?([-#+ 0,(<]*)(\\d+)?(\\.\\d+)?([a-zA-Z%])")

    /** The conversions Lua's string.format has with the same meaning. */
    private const val LUA_CONVERSIONS = "doxXeEfgGaA"

    /** `String.format(...)` (no [format] receiver) or `format.format(...)`. */
    fun format(site: CallSite, format: LuaExpr?): LuaExpr = with(site) {
        // the callee's parameter decides: `"%s %s".format(null, x)` is the Locale overload, as Kotlin resolves it
        if (args.isNotEmpty() && isLocale(parameterTypes.getOrNull(0) ?: argTypes.getOrNull(0))) {
            return unsupported("String.format with a Locale")
        }
        val formatExpr = format ?: args.firstOrNull() ?: return unsupported("String.format without a format")
        val values = if (format == null) args.drop(1) else args
        val types = if (format == null) argTypes.drop(1) else argTypes
        val literal = (formatExpr as? LuaString)?.value
        if (literal == null || values.size != types.size) {
            return LuaCall(ref("Strings", "__K2L_StringFormat"), listOf(formatExpr) + values)
        }
        return literalFormat(literal, values, types)
    }

    /** One specifier of a literal format: its parts, as [SPECIFIER] groups them. */
    private class Spec(m: MatchResult) {
        val text = m.value
        val index = m.groupValues[1]
        val flags = m.groupValues[2]
        val width = m.groupValues[3]
        val precision = m.groupValues[4]
        val conversion = m.groupValues[5][0]
    }

    /** `string.format` with [format] translated and each argument as its specifier needs it. */
    private fun CallSite.literalFormat(format: String, values: List<LuaExpr>, types: List<KaType?>): LuaExpr {
        val out = StringBuilder()
        val arguments = mutableListOf<LuaExpr>()
        var last = 0
        for (m in SPECIFIER.findAll(format)) {
            out.append(format, last, m.range.first)
            last = m.range.last + 1
            val spec = Spec(m)
            when {
                spec.conversion == '%' -> out.append("%%")

                spec.conversion == 'n' -> out.append('\n')

                spec.index.isNotEmpty() || !isTranslatable(spec.flags, spec.conversion) ->
                    return unsupported("String.format specifier '${spec.text}'")

                else -> {
                    val i = arguments.size
                    val value = values.getOrNull(i) ?: return unsupported("String.format specifier '${spec.text}' without an argument")
                    val (luaSpec, argument) = specifier(spec, value, types[i])
                    out.append(luaSpec)
                    arguments += argument
                }
            }
        }
        out.append(format, last, format.length)
        // arguments no specifier takes are still evaluated, as in Kotlin
        return lua("string.format", LuaString(out.toString()), *(arguments + values.drop(arguments.size)).toTypedArray())
    }

    /** The Lua specifier for [spec] and the argument it formats. */
    private fun CallSite.specifier(spec: Spec, value: LuaExpr, type: KaType?): Pair<String, LuaExpr> = with(spec) {
        if (',' in flags) {
            // the digits grouped, then padded to the width as a string
            val inner = "%" + flags.filter { it != ',' && it != '-' } + precision + conversion
            val grouped = libMember(TEXT_TABLE, "grouped", lua("string.format", LuaString(inner), value))
            return "%" + (if ('-' in flags) "-" else "") + width + "s" to grouped
        }
        val (luaConversion, argument) = argument(conversion, value, type)
        "%$flags$width$precision$luaConversion" to argument
    }

    private fun isTranslatable(flags: String, conversion: Char): Boolean = when {
        '(' in flags || '<' in flags -> false
        ',' in flags -> (conversion == 'd' || conversion == 'f') && '0' !in flags
        else -> conversion in LUA_CONVERSIONS || conversion in "sSbBcC"
    }

    /** The Lua conversion for a Java one, and the argument it formats. */
    private fun CallSite.argument(conversion: Char, value: LuaExpr, type: KaType?): Pair<Char, LuaExpr> = when (conversion) {
        's' -> 's' to str(value, type)
        'S' -> 's' to upper(str(value, type))
        'b' -> 's' to booleanText(value)
        'B' -> 's' to upper(booleanText(value))
        'c' -> if (isChar(type)) 's' to value else 'c' to value
        'C' -> 's' to upper(if (isChar(type)) value else lua("string.char", value))
        else -> conversion to value
    }

    /** `%b`: "false" for null and false, "true" for anything else, as java.util.Formatter writes it. */
    private fun booleanText(value: LuaExpr): LuaExpr = luaCall(LuaName("tostring"), LuaUnary(LuaUnOp.Not, LuaUnary(LuaUnOp.Not, value)))

    private fun upper(text: LuaExpr): LuaExpr = lua("string.upper", text)
}

/** Whether [type] is `java.util.Locale`. */
internal fun CallSite.isLocale(type: KaType?): Boolean =
    type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() == "java/util/Locale" }
