package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** `String.format` and `format` of kotlin.text, on the lualib's formatter (`__K2L_StringFormat`). */
internal object TextFormat {
    /** `String.format(...)` (no [format] receiver) or `format.format(...)`. */
    fun format(site: CallSite, format: LuaExpr?): LuaExpr = site.formatCall(format)

    private fun CallSite.text(member: String, vararg args: LuaExpr) =
        libMember(TEXT_TABLE, member, *args.toList().dropTrailingNil().toTypedArray())

    /**
     * `String.format(locale, format, args)` and `format.format(locale, args)`. The locale chooses the decimal and grouping
     * separators and the digits of the numbers (see `LocaleFormat.lua`), and with `--strings utf16` the case rules of `%S`.
     * `Locale.ROOT`, `en_US` and no locale at all use the formatter's own symbols.
     */
    private fun CallSite.formatCall(format: LuaExpr?): LuaExpr {
        // the callee's parameter decides: `"%s %s".format(null, x)` is the Locale overload, as Kotlin resolves it
        val hasLocale = args.isNotEmpty() && isLocale(parameterTypes.getOrNull(0) ?: argTypes.getOrNull(0))
        val values = if (hasLocale) args.drop(1) else args
        val valueTypes = if (hasLocale) argTypes.drop(1) else argTypes
        val sized = formatArguments(format, values, valueTypes)
        // a null locale formats without localization, like java.util.Formatter
        val locale = if (hasLocale) args[0].takeIf { it != LuaNil } else null
        val formatAndArguments = listOfNotNull(format) + sized
        val tag = (locale as? LuaString)?.value
        val uppercase = formatUppercase(formatAndArguments.firstOrNull(), tag, dynamicLocale = locale != null && tag == null)
        return when {
            locale != null && tag != "" && tag != "en_US" -> libCall(
                "LocaleFormat",
                "__K2L_LocaleFormat",
                "format",
                listOf(locale, uppercase ?: LuaNil) + formatAndArguments,
            )

            uppercase != null -> libCall(TEXT_TABLE, "formatWith", listOf(LuaNil, uppercase) + formatAndArguments)

            else -> LuaCall(ref("Strings", "__K2L_StringFormat"), formatAndArguments)
        }
    }

    /**
     * With `--strings utf16`, the Unicode (and, for a locale of Turkish, Azeri or Lithuanian, the locale's) upper-casing of `%S`,
     * `%C` and `%B`; null when the format has none of them or the strings are byte strings.
     */
    private fun CallSite.formatUppercase(format: LuaExpr?, tag: String?, dynamicLocale: Boolean): LuaExpr? {
        if (!utf16) return null
        val text = (format as? LuaString)?.value
        if (text != null && !UPPERCASE_CONVERSION.containsMatchIn(text)) return null
        if (dynamicLocale || (tag != null && tag.substringBefore('_') in LOCALE_SENSITIVE)) {
            return luaField(ref("Utf16Locale", "__K2L_Utf16Locale"), "uppercase")
        }
        return luaField(ref(UTF16_CASE_TABLE), "uppercase")
    }

    private val UPPERCASE_CONVERSION = Regex("%[-#+ 0,(<\\d$.]*[SCB]")
    private val HASH_CONVERSION = Regex("%[-#+ 0,(<\\d$.]*[hH]")
    private val SPECIFIER = Regex("%(\\d+\\$)?([-#+ 0,(<]*)(?:\\d+)?(?:\\.\\d+)?([a-zA-Z%])")
    private val SIZED_BITS = mapOf("kotlin/Byte" to 8, "kotlin/Short" to 16, "kotlin/Long" to 64)

    /**
     * The arguments after the locale (the format first, unless it is the receiver [format]), as the formatter takes them; loads
     * `%h`'s hashing when the format may use it.
     */
    private fun CallSite.formatArguments(format: LuaExpr?, values: List<LuaExpr>, types: List<KaType?>): List<LuaExpr> {
        val formatText = ((format ?: values.firstOrNull()) as? LuaString)?.value
        if (formatText == null || HASH_CONVERSION.containsMatchIn(formatText)) transformer.ctx.lualib += "FormatHash"
        return typedArguments(values, types, firstArgument = if (format == null) 1 else 0, formatText)
    }

    /** The (1-based) argument and the conversion of each specifier of a literal format, as java.util.Formatter picks them. */
    private fun formatSpecifiers(format: String): List<Pair<Int, Char>> {
        val used = mutableListOf<Pair<Int, Char>>()
        var ordinary = 0
        var last = 0
        for (m in SPECIFIER.findAll(format)) {
            val (index, flags, conversion) = m.destructured
            if (conversion == "%" || conversion == "n") continue
            val arg = when {
                '<' in flags -> last
                index.isNotEmpty() -> index.dropLast(1).toInt()
                else -> ++ordinary
            }
            last = arg
            used += arg to conversion[0]
        }
        return used
    }

    /**
     * Format arguments as the formatter needs to see them, which their Lua value cannot tell:
     * - of static type `Byte`, `Short` or `Long` that a `%x` or `%o` prints, `__K2L_Text.sized(x, bits)`, so a negative value
     *   gives the two's complement of the type's width (`(-1).toByte()` is `ff`, `-1L` sixteen `f`s), as on the JVM;
     * - that a conversion rejects by the JVM class of their static type (`%f` of an `Int`, `%d` of a `Double`, `%c` of a
     *   `String`), `__K2L_Text.typed(x, bits, class)`, so it throws `IllegalFormatConversionException` there.
     *
     * Arguments of a literal format that no conversion rejects stay as they are; with a format that is not a literal, every
     * argument of such a type is wrapped. [firstArgument] is the index of the first argument after the format in [values].
     */
    private fun CallSite.typedArguments(values: List<LuaExpr>, types: List<KaType?>, firstArgument: Int, format: String?): List<LuaExpr> {
        if (values.size != types.size) return values
        val specifiers = format?.let(::formatSpecifiers)
        return values.mapIndexed { i, v ->
            val arg = i - firstArgument + 1
            val classId = with(session) { (types[i]?.withoutFlexibility as? KaClassType)?.classId?.asString() }
            if (arg < 1 || classId == null) return@mapIndexed v
            val conversions = specifiers?.filter { it.first == arg }?.map { it.second }
            // only printed with %s: the text of its static type (a Double `2.0`, which a Lua number cannot tell from `2`)
            if (classId in FLOATING && onlyAsString(conversions)) {
                return@mapIndexed str(v, types[i])
            }
            val bits = SIZED_BITS[classId]?.takeIf { conversions == null || conversions.any { it in "xXo" } }
            val boxed = BOXED_CLASSES[classId]
            val rejected = boxed?.takeIf {
                if (conversions == null) classId !in RUNTIME_CHECKED else conversions.any { c -> rejects(c, boxed) }
            }
            when {
                rejected != null -> text("typed", v, bits?.let { LuaNumber(it.toString()) } ?: LuaNil, LuaString(rejected))
                bits != null -> text("sized", v, LuaNumber(bits.toString()))
                else -> v
            }
        }
    }

    private fun onlyAsString(conversions: List<Char>?) = !conversions.isNullOrEmpty() && conversions.all { it == 's' || it == 'S' }

    /** Whether java.util.Formatter's [conversion] rejects an argument of the JVM class [boxed]. */
    private fun rejects(conversion: Char, boxed: String): Boolean = when (conversion.lowercaseChar()) {
        'd', 'o', 'x' -> boxed !in INTEGRAL_ARGUMENTS
        'e', 'f', 'g' -> boxed !in FLOAT_ARGUMENTS
        'c' -> boxed !in CHAR_ARGUMENTS
        else -> false
    }

    /** The JVM classes of the boxed values of the types the formatter checks, by the Kotlin class. */
    private val BOXED_CLASSES = mapOf(
        "kotlin/Int" to "java.lang.Integer", "kotlin/Long" to "java.lang.Long", "kotlin/Short" to "java.lang.Short",
        "kotlin/Byte" to "java.lang.Byte", "kotlin/Double" to "java.lang.Double", "kotlin/Float" to "java.lang.Float",
        "kotlin/Char" to "java.lang.Character", "kotlin/String" to "java.lang.String", "kotlin/Boolean" to "java.lang.Boolean",
        "java/math/BigInteger" to "java.math.BigInteger", "java/math/BigDecimal" to "java.math.BigDecimal",
        "kotlin/UInt" to "kotlin.UInt", "kotlin/ULong" to "kotlin.ULong", "kotlin/UShort" to "kotlin.UShort",
        "kotlin/UByte" to "kotlin.UByte",
    )

    private val FLOATING = setOf("kotlin/Double", "kotlin/Float")

    /** Types whose Lua values the formatter tells apart itself (booleans, `BigInteger`/`BigDecimal` objects). */
    private val RUNTIME_CHECKED = setOf("kotlin/Boolean", "java/math/BigInteger", "java/math/BigDecimal")
    private val INTEGRAL_ARGUMENTS =
        setOf("java.lang.Integer", "java.lang.Long", "java.lang.Short", "java.lang.Byte", "java.math.BigInteger")
    private val FLOAT_ARGUMENTS = setOf("java.lang.Double", "java.lang.Float", "java.math.BigDecimal")
    private val CHAR_ARGUMENTS = setOf("java.lang.Character", "java.lang.Integer", "java.lang.Short", "java.lang.Byte")
}
