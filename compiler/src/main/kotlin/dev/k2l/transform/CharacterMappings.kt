package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * The `java.lang.Character` statics of the mapping table: classification and case of a Char or a code point, the members
 * that are Kotlin `Char` members, surrogates and code points (UTF-16 code units exist only with `--strings utf16`).
 * `forDigit`, `digit` and `hashCode` are in JavaUtilMappings, which is tried before the table.
 */
internal object CharacterMappings {
    private const val WITHOUT_UTF16 = "without --strings utf16"

    /** `Character.x(c)` that is the Kotlin `Char` member `x`. */
    private val CHAR_MEMBERS = listOf(
        "isISOControl",
        "isTitleCase",
        "isDefined",
        "isJavaIdentifierStart",
        "isJavaIdentifierPart",
        "isIdentifierIgnorable",
    )

    fun install(t: MappingTable) {
        classification(t)
        charMembers(t)
        surrogates(t)
    }

    /** `Character.isLetter(c)` and friends take a Char or a code point. */
    private fun classification(t: MappingTable) {
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
        t.def("java/lang/Character.getNumericValue") { libMember(NUM_TABLE, "numericValue", arg(0)) }
    }

    private fun charMembers(t: MappingTable) {
        for (name in CHAR_MEMBERS) {
            t.def("java/lang/Character.$name") {
                when {
                    isChar(argTypes.firstOrNull()) -> StdlibMappings.map("kotlin/text/$name", withReceiver(arg(0), argTypes[0]))
                    name == "isISOControl" -> libMember(JAVA_NUMBERS_TABLE, "isISOControl", arg(0))
                    else -> null
                }
            }
        }
        // the difference of the codes, as Character.compare is
        t.def("java/lang/Character.compare") {
            val codes = (0..1).map { TextMappings.charMember("code", withReceiver(arg(it), argTypes[it])) ?: return@def null }
            LuaBinary(LuaBinOp.Sub, codes[0], codes[1])
        }
    }

    /** The surrogate and code point functions. */
    private fun surrogates(t: MappingTable) {
        t.def("java/lang/Character.isSurrogatePair") {
            utf16Only("Character.isSurrogatePair") {
                LuaBinary(LuaBinOp.And, u16("isHighSurrogate", arg(0)), u16("isLowSurrogate", arg(1)))
            }
        }
        for (name in listOf("highSurrogate", "lowSurrogate")) {
            t.def("java/lang/Character.$name") { utf16Only("Character.$name") { u16(name, arg(0)) } }
        }
        t.def("java/lang/Character.reverseBytes") {
            utf16Only("Character.reverseBytes") {
                u16("char", libMember(JAVA_NUMBERS_TABLE, "reverseChar", u16("code", arg(0))))
            }
        }
        for (name in listOf("codePointAt", "codePointBefore", "codePointCount", "offsetByCodePoints")) {
            t.def("java/lang/Character.$name") {
                if (isTextual(argTypes.firstOrNull()) || isCharSequence(argTypes.firstOrNull())) {
                    val site = onFirstArgument(name)
                    utf16Only("Character.$name") { StdlibMappings.map("kotlin/text/$name", site) ?: unsupported("Character.$name") }
                } else {
                    null
                }
            }
        }
    }

    /** The Char overload is the `Char` member; the Int overload (a code point) needs the Unicode tables. */
    private fun CallSite.charOrCodePoint(name: String, charMember: String): LuaExpr = if (isChar(argTypes.firstOrNull())) {
        TextMappings.charMember(charMember, withReceiver(arg(0), argTypes[0])) ?: unsupported("Character.$name")
    } else {
        utf16Only("Character.$name(int)") { u16Case("${name}Cp", arg(0)) }
    }

    private fun CallSite.isCharSequence(type: KaType?) =
        with(session) { (type?.withoutFlexibility as? KaClassType)?.classId?.asString() == "kotlin/CharSequence" }

    private fun CallSite.utf16Only(what: String, mapping: CallSite.() -> LuaExpr): LuaExpr =
        if (utf16) mapping() else unsupported("'$what' $WITHOUT_UTF16")

    private fun ge(e: LuaExpr, n: String): LuaExpr = LuaBinary(LuaBinOp.Ge, e, num(n))

    private fun le(e: LuaExpr, n: String): LuaExpr = LuaBinary(LuaBinOp.Le, e, num(n))
}
