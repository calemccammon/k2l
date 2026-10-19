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
    )

    private val STREAM_METHODS = listOf(
        "forEach", "filter", "map", "toArray", "boxed", "sum", "anyMatch", "allMatch", "noneMatch", "count", "toList",
    )

    fun install(t: MappingTable) {
        locales(t)
        codePoints(t)
        characterStatics(t)
        streams(t)
    }

    /** A `Locale` is its tag string. Locale-specific rules are not applied: everything behaves like `Locale.ROOT`. */
    private fun locales(t: MappingTable) {
        for ((name, tag) in LOCALES) {
            t.def("java/util/Locale.$name") { LuaString(tag) }
        }
        t.def("java/util/Locale.getDefault") { LuaString("en_US") }
        t.def("java/util/Locale.forLanguageTag") { arg(0) }
        t.def("java/util/Locale.toString", "java/util/Locale.toLanguageTag") { self }
    }

    private fun CallSite.utf16Only(what: String, mapping: CallSite.() -> LuaExpr): LuaExpr =
        if (utf16) mapping() else unsupported("'$what' $WITHOUT_UTF16")

    private fun codePoints(t: MappingTable) {
        t.def("kotlin/text/codePointAt") { utf16Only("codePointAt") { u16("codePointAt", self, arg(0)) } }
        t.def("kotlin/text/codePointBefore") { utf16Only("codePointBefore") { u16("codePointBefore", self, arg(0)) } }
        t.def("kotlin/text/codePointCount") { utf16Only("codePointCount") { u16("codePointCount", self, arg(0), arg(1)) } }
        t.def("kotlin/text/offsetByCodePoints") { utf16Only("offsetByCodePoints") { u16("offsetByCodePoints", self, arg(0), arg(1)) } }
        t.def("kotlin/String.codePoints") { utf16Only("codePoints()") { u16("codePoints", self) } }
        t.def("kotlin/String.chars") { utf16Only("chars()") { u16("chars16", self) } }
        t.def("kotlin/text/intern") { self }
    }

    private fun streams(t: MappingTable) {
        for (method in STREAM_METHODS) {
            t.def("java/util/stream/IntStream.$method", "java/util/stream/Stream.$method") { LuaMethodCall(self, method, args) }
        }
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
