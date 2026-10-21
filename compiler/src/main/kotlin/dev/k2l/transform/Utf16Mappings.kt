package dev.k2l.transform

import dev.k2l.StringSemantics
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** `--strings utf16`: lengths, indices and `Char`s count UTF-16 code units, and Char classification is Unicode-aware. */
internal val FileTransformer.utf16: Boolean get() = ctx.options.strings == StringSemantics.Utf16

internal val CallSite.utf16: Boolean get() = transformer.utf16

/** `__K2L_Utf16.member(args)`; using it loads the Utf16 feature. */
internal fun FileTransformer.u16(member: String, vararg args: LuaExpr): LuaExpr = libCall(UTF16_TABLE, member, args.toList())

/** `__K2L_Utf16Case.member(args)`: Unicode classification and case mapping. */
internal fun FileTransformer.u16Case(member: String, vararg args: LuaExpr): LuaExpr = libCall(UTF16_CASE_TABLE, member, args.toList())

internal fun CallSite.u16(member: String, vararg args: LuaExpr): LuaExpr = transformer.u16(member, *args)

internal fun CallSite.u16Case(member: String, vararg args: LuaExpr): LuaExpr = transformer.u16Case(member, *args)

/** Whether [type] is `java.util.Locale`. */
internal fun CallSite.isLocale(type: KaType?): Boolean =
    type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() == "java/util/Locale" }

/** Loads the Utf16 feature (which patches `__K2L_Text` and `StringBuilder`) without referencing it. */
internal fun CallSite.requireUtf16() {
    if (utf16) transformer.ctx.lualib += UTF16_FEATURE
}

/** Loads the Unicode-aware helpers: they replace the ASCII-only `ignoreCase` comparison and digit parsing. */
internal fun CallSite.requireUtf16Case() {
    if (utf16) transformer.ctx.lualib += UTF16_CASE_FEATURE
}

/**
 * With `--strings utf16`, a regex whose pattern may use Unicode properties (`\p{L}`, `\p{Lu}`, `\P{Nd}`, ...) loads the
 * Unicode tables they test non-ASCII characters with (and the general categories, `UnicodeCategories.lua`): when the
 * pattern is not a literal, or a literal that has `\p` or `\P`.
 */
internal fun CallSite.requireRegexProperties(pattern: LuaExpr) {
    val text = (pattern as? LuaString)?.value
    if (text == null || "\\p" in text || "\\P" in text) {
        requireUtf16Case()
        if (utf16) transformer.ctx.lualib += UNICODE_CATEGORIES
    }
}

/** Wraps [text] so that surrogate halves joined by concatenation become one character. */
internal fun FileTransformer.u16Norm(text: LuaExpr): LuaExpr = u16("norm", text)

/**
 * `for (c in s)`: over the UTF-16 units with `--strings utf16`, else by byte index, `local c = s:sub(i, i)` (LuaJIT
 * compiles `sub`, not the `gmatch(".")` iterator).
 */
internal fun FileTransformer.eachChar(text: LuaExpr, variable: String, body: List<LuaStmt>) {
    if (utf16) {
        emit(LuaGenericFor(listOf(variable), listOf(u16("each", text)), body))
        return
    }
    val s = cache(text, "text")
    val i = LuaName(ctx.temp("i"))
    val char = LuaLocal(listOf(variable), listOf(LuaMethodCall(s, "sub", listOf(i, i))))
    emit(LuaNumericFor(i.name, LuaNumber("1"), LuaUnary(LuaUnOp.Len, s), null, listOf(char) + body))
}

/** A Char's code and the Char of a code, as bytes or UTF-16 units. */
internal fun FileTransformer.charCode(c: LuaExpr): LuaExpr = if (utf16) u16("code", c) else LuaMethodCall(c, "byte", emptyList())

internal fun FileTransformer.charFromCode(code: LuaExpr): LuaExpr = if (utf16) u16("char", code) else lua("string.char", code)

/**
 * Members that only make sense with UTF-16 strings (code points, `Locale`); the `Character` statics are in CharacterMappings.
 * Without `--strings utf16` they are reported as unsupported, except what is plain arithmetic or Char classification.
 */
internal object Utf16Mappings {
    private const val WITHOUT_UTF16 = "without --strings utf16"

    private val LOCALES = mapOf(
        "ROOT" to "", "US" to "en_US", "ENGLISH" to "en", "UK" to "en_GB", "GERMANY" to "de_DE", "GERMAN" to "de",
        "FRANCE" to "fr_FR", "FRENCH" to "fr", "ITALY" to "it_IT", "JAPAN" to "ja_JP", "CHINA" to "zh_CN", "CANADA" to "en_CA",
        "CANADA_FRENCH" to "fr_CA", "ITALIAN" to "it", "JAPANESE" to "ja", "KOREA" to "ko_KR", "KOREAN" to "ko", "CHINESE" to "zh",
        "SIMPLIFIED_CHINESE" to "zh_CN", "TRADITIONAL_CHINESE" to "zh_TW", "PRC" to "zh_CN", "TAIWAN" to "zh_TW",
    )

    /** `Locale.displayLanguage` and the other display names, with the Kotlin property name and the Java getter. */
    private val DISPLAY_NAMES = mapOf(
        "Language" to "language",
        "Country" to "country",
        "Script" to "script",
        "Variant" to "variant",
        "Name" to "name",
    )

    fun install(t: MappingTable) {
        locales(t)
        codePoints(t)
    }

    /**
     * A `Locale` is its string form (`tr_TR`, see `Locale.lua`). The default locale is `en_US`. Only with `--strings utf16`
     * does the language change anything: Turkish, Azeri and Lithuanian case mapping (see `Utf16Locale.lua`).
     */
    private fun locales(t: MappingTable) {
        for ((name, tag) in LOCALES) {
            t.def("java/util/Locale.$name") { LuaString(tag) }
        }
        t.def("java/util/Locale.getDefault") { LuaString("en_US") }
        t.def("java/util/Locale.forLanguageTag") { locale("forLanguageTag", arg(0)) }
        t.def("java/util/Locale.of") { locale("of", *args.toTypedArray()) }
        t.def("java/util/Locale.toString") { self }
        t.def("java/util/Locale.toLanguageTag") { locale("languageTag", self) }
        t.def("java/util/Locale.language", "java/util/Locale.getLanguage") { locale("language", self) }
        t.def("java/util/Locale.country", "java/util/Locale.getCountry") { locale("country", self) }
        t.def("java/util/Locale.variant", "java/util/Locale.getVariant") { locale("variant", self) }
        for ((suffix, member) in DISPLAY_NAMES) {
            val property = "display$suffix"
            t.def("java/util/Locale.$property", "java/util/Locale.getDisplay$suffix") { displayName(member) }
        }
    }

    /** The English display names (`LocaleNames.lua`), for the default locale or an English one. */
    private fun CallSite.displayName(member: String): LuaExpr {
        val inLocale = (args.firstOrNull() as? LuaString)?.value
        if (inLocale != null && inLocale.substringBefore('_') !in setOf("", "en")) {
            return unsupported("Locale display names in a language other than English ('$inLocale')")
        }
        return libCall("LocaleNames", "__K2L_LocaleNames", member, listOf(self) + args)
    }

    private fun CallSite.locale(member: String, vararg args: LuaExpr): LuaExpr = libCall("Locale", "__K2L_Locale", member, args.toList())

    /** `Locale(language)`, `Locale(language, country)` and `Locale(language, country, variant)`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? =
        if (classId == "java/util/Locale") site.locale("of", *site.args.toTypedArray()) else null

    private fun CallSite.utf16Only(what: String, mapping: CallSite.() -> LuaExpr): LuaExpr =
        if (utf16) mapping() else unsupported("'$what' $WITHOUT_UTF16")

    /** `chars()` and `codePoints()` are `IntStream`s, which live in `Streams.lua`. */
    private fun CallSite.streamOf(member: String): LuaExpr {
        transformer.ctx.lualib += "Streams"
        return u16(member, self)
    }

    private fun codePoints(t: MappingTable) {
        t.def("kotlin/text/codePointAt") { utf16Only("codePointAt") { u16("codePointAt", self, arg(0)) } }
        t.def("kotlin/text/codePointBefore") { utf16Only("codePointBefore") { u16("codePointBefore", self, arg(0)) } }
        t.def("kotlin/text/codePointCount") { utf16Only("codePointCount") { u16("codePointCount", self, arg(0), arg(1)) } }
        t.def("kotlin/text/offsetByCodePoints") { utf16Only("offsetByCodePoints") { u16("offsetByCodePoints", self, arg(0), arg(1)) } }
        t.def("kotlin/String.codePoints") { utf16Only("codePoints()") { streamOf("codePoints") } }
        t.def("kotlin/String.chars") { utf16Only("chars()") { streamOf("chars16") } }
        t.def("kotlin/text/intern") { self }
    }
}

/**
 * `uppercase`, `lowercase` and `titlecase` with or without a `Locale`: the Unicode mapping, or the locale's rules. A constant
 * locale of another language than Turkish, Azeri or Lithuanian (`Locale.US`, `Locale.ROOT`) maps like no locale at all.
 */
internal fun CallSite.u16CaseOf(member: String): LuaExpr {
    val tag = (args.firstOrNull() as? LuaString)?.value
    if (args.isEmpty() || (tag != null && tag.substringBefore('_') !in LOCALE_SENSITIVE)) return u16Case(member, self)
    return libCall("Utf16Locale", "__K2L_Utf16Locale", member, listOf(self, arg(0)))
}

/** The languages whose case mapping differs from `Locale.ROOT`. */
internal val LOCALE_SENSITIVE = setOf("tr", "az", "lt")
