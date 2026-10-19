package dev.k2l.transform

import dev.k2l.StringSemantics
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** The lualib tables of `--strings utf16` (see `Utf16.lua` and `Utf16Case.lua`). */
private const val UTF16 = "Utf16"
private const val UTF16_CASE = "Utf16Case"

/** `--strings utf16`: lengths, indices and `Char`s count UTF-16 code units, and Char classification is Unicode-aware. */
internal val FileTransformer.utf16: Boolean get() = ctx.options.strings == StringSemantics.Utf16

internal val CallSite.utf16: Boolean get() = transformer.utf16

/** `__K2L_Utf16.member(args)`; using it loads the Utf16 feature. */
internal fun FileTransformer.u16(member: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(LuaIndex(lualibRef(UTF16, "__K2L_Utf16"), LuaString(member)), args.toList())

/** `__K2L_Utf16Case.member(args)`: Unicode classification and case mapping. */
internal fun FileTransformer.u16Case(member: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(LuaIndex(lualibRef(UTF16_CASE, "__K2L_Utf16Case"), LuaString(member)), args.toList())

internal fun CallSite.u16(member: String, vararg args: LuaExpr): LuaExpr = transformer.u16(member, *args)

internal fun CallSite.u16Case(member: String, vararg args: LuaExpr): LuaExpr = transformer.u16Case(member, *args)

/** Loads the Utf16 feature (which patches `__K2L_Text` and `StringBuilder`) without referencing it. */
internal fun CallSite.isLocale(type: KaType?): Boolean =
    type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() == "java/util/Locale" }

internal fun CallSite.requireUtf16() {
    if (utf16) transformer.ctx.lualib += UTF16
}

/** Loads the Unicode-aware helpers: they replace the ASCII-only `ignoreCase` comparison and digit parsing. */
internal fun CallSite.requireUtf16Case() {
    if (utf16) transformer.ctx.lualib += UTF16_CASE
}

/**
 * With `--strings utf16`, a regex whose pattern may use Unicode properties (`\p{L}`, `\p{Lu}`, `\P{Nd}`, ...) loads the
 * Unicode tables they test non-ASCII characters with: when the pattern is not a literal, or a literal that has `\p` or `\P`.
 */
internal fun CallSite.requireRegexProperties(pattern: LuaExpr) {
    val text = (pattern as? LuaString)?.value
    if (text == null || "\\p" in text || "\\P" in text) requireUtf16Case()
}

/** Wraps [text] so that surrogate halves joined by concatenation become one character. */
internal fun FileTransformer.u16Norm(text: LuaExpr): LuaExpr = u16("norm", text)

/** The iterator over the chars of [text]: a byte pattern, or the UTF-16 units with `--strings utf16`. */
internal fun FileTransformer.stringChars(text: LuaExpr): LuaExpr =
    if (utf16) u16("each", text) else LuaMethodCall(text, "gmatch", listOf(LuaString(".")))

/** A Char's code and the Char of a code, as bytes or UTF-16 units. */
internal fun FileTransformer.charCode(c: LuaExpr): LuaExpr = if (utf16) u16("code", c) else LuaMethodCall(c, "byte", emptyList())

internal fun FileTransformer.charFromCode(code: LuaExpr): LuaExpr =
    if (utf16) u16("char", code) else luaCall(luaPath("string", "char"), code)

/**
 * Members that only make sense with UTF-16 strings (code points, surrogates, `Locale`), and the `Character` statics.
 * Without `--strings utf16` they are reported as unsupported, except what is plain arithmetic or Char classification.
 */
@Suppress("TooManyFunctions") // one small mapping per Character or code point member
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
        characterStatics(t)
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
        return LuaCall(LuaIndex(ref("LocaleNames", "__K2L_LocaleNames"), LuaString(member)), listOf(self) + args)
    }

    private fun CallSite.locale(member: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(LuaIndex(ref("Locale", "__K2L_Locale"), LuaString(member)), args.toList())

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

    /** `Character.isLetter(c)` and friends take a Char or a code point. */
    private fun characterStatics(t: MappingTable) {
        for (name in listOf("isLetter", "isDigit", "isLetterOrDigit", "isUpperCase", "isLowerCase", "isWhitespace")) {
            t.def("java/lang/Character.$name") { charOrCodePoint(name, name) }
        }
        for ((name, member) in listOf(
            "toUpperCase" to "uppercaseChar",
            "toLowerCase" to "lowercaseChar",
            "toTitleCase" to "titlecaseChar",
        )) {
            t.def("java/lang/Character.$name") { charOrCodePoint(name, member) }
        }
        for (name in listOf("isSurrogate", "isHighSurrogate", "isLowSurrogate")) {
            t.def("java/lang/Character.$name") { utf16Only("Character.$name") { u16(name, arg(0)) } }
        }
        t.def("java/lang/Character.isSupplementaryCodePoint") { LuaBinary(LuaBinOp.And, ge(arg(0), "65536"), le(arg(0), "1114111")) }
        t.def("java/lang/Character.isBmpCodePoint") {
            LuaBinary(LuaBinOp.And, ge(arg(0), "0"), LuaBinary(LuaBinOp.Lt, arg(0), num("65536")))
        }
        t.def("java/lang/Character.isValidCodePoint") { LuaBinary(LuaBinOp.And, ge(arg(0), "0"), le(arg(0), "1114111")) }
        t.def("java/lang/Character.charCount") {
            LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, ge(arg(0), "65536"), num("2")), num("1"))
        }
        t.def("java/lang/Character.toChars") { utf16Only("Character.toChars") { u16("toChars", arg(0)) } }
        t.def("java/lang/Character.toCodePoint") { utf16Only("Character.toCodePoint") { u16("toCodePoint", arg(0), arg(1)) } }
        t.def("java/lang/Character.toString") {
            if (isChar(argTypes.firstOrNull())) arg(0) else utf16Only("Character.toString(int)") { u16("codePointString", arg(0)) }
        }
        t.def("java/lang/Character.valueOf") { arg(0) }
    }

    /** The Char overload is the `Char` member; the Int overload (a code point) needs the Unicode tables. */
    private fun CallSite.charOrCodePoint(name: String, charMember: String): LuaExpr = if (isChar(argTypes.firstOrNull())) {
        TextMappings.charMember(charMember, withReceiver(arg(0), argTypes[0])) ?: unsupported("Character.$name")
    } else {
        utf16Only("Character.$name(int)") { u16Case("${name}Cp", arg(0)) }
    }

    private fun ge(e: LuaExpr, n: String): LuaExpr = LuaBinary(LuaBinOp.Ge, e, num(n))

    private fun le(e: LuaExpr, n: String): LuaExpr = LuaBinary(LuaBinOp.Le, e, num(n))
}

/**
 * `uppercase`, `lowercase` and `titlecase` with or without a `Locale`: the Unicode mapping, or the locale's rules. A constant
 * locale of another language than Turkish, Azeri or Lithuanian (`Locale.US`, `Locale.ROOT`) maps like no locale at all.
 */
internal fun CallSite.u16CaseOf(member: String): LuaExpr {
    val tag = (args.firstOrNull() as? LuaString)?.value
    if (args.isEmpty() || (tag != null && tag.substringBefore('_') !in LOCALE_SENSITIVE)) return u16Case(member, self)
    return LuaCall(LuaIndex(ref("Utf16Locale", "__K2L_Utf16Locale"), LuaString(member)), listOf(self, arg(0)))
}

/** The languages whose case mapping differs from `Locale.ROOT`. */
internal val LOCALE_SENSITIVE = setOf("tr", "az", "lt")
