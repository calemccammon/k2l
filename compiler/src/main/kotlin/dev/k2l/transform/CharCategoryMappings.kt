package dev.k2l.transform

import dev.k2l.codegen.*

/**
 * `Char.category`, `CharCategory`, `Char.directionality`, `CharDirectionality` and the Char predicates read from the general
 * category (`isDefined`, the Java identifier predicates), plus the surrogate and title-case predicates of a byte (always false) without `--strings utf16`.
 */
internal object CharCategoryMappings {
    private const val TEXT = "kotlin/text/"
    private const val CATEGORY = "kotlin/text/CharCategory."
    private const val DIRECTIONALITY = "kotlin/text/CharDirectionality."

    /** Predicates of a character code that are functions of the same name in `CharCategory.lua`. */
    private val CODE_PREDICATES = setOf("isIdentifierIgnorable", "isJavaIdentifierStart", "isJavaIdentifierPart")

    /** False for a byte: it is no surrogate half, and the title-case letters are not ASCII. */
    private val NEVER_A_BYTE = setOf("isSurrogate", "isHighSurrogate", "isLowSurrogate", "isTitleCase")

    fun map(callableId: String?, site: CallSite): LuaExpr? = when {
        callableId == null -> null

        callableId.startsWith(CATEGORY) -> category(callableId.removePrefix(CATEGORY), site)

        callableId.startsWith(DIRECTIONALITY) -> directionality(callableId.removePrefix(DIRECTIONALITY), site)

        callableId.startsWith(TEXT) && site.receiver != null && site.isChar(site.receiverType) ->
            charMember(callableId.removePrefix(TEXT), site)

        else -> null
    }

    private fun CallSite.table(): LuaExpr {
        if (utf16) transformer.ctx.lualib += CHAR_CATEGORY_UNICODE
        return ref(CHAR_CATEGORY, "__K2L_CharCategory")
    }

    private fun CallSite.directions(): LuaExpr {
        if (utf16) transformer.ctx.lualib += UNICODE_DIRECTIONALITY
        return ref(CHAR_CATEGORY, "__K2L_CharDirectionality")
    }

    private fun CallSite.call(member: String, vararg args: LuaExpr): LuaExpr = LuaCall(LuaIndex(table(), LuaString(member)), args.toList())

    private fun CallSite.code(c: LuaExpr): LuaExpr = transformer.charCode(c)

    private fun charMember(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "category" -> call("of", code(self))
            "directionality" -> LuaCall(LuaIndex(directions(), LuaString("of")), listOf(code(self)))
            "isDefined" -> LuaBinary(LuaBinOp.Ne, call("typeOf", code(self)), LuaNumber("0"))
            in CODE_PREDICATES -> call(name, code(self))
            in NEVER_A_BYTE -> if (utf16) null else LuaBool(false)
            else -> null
        }
    }

    private fun category(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "code", "value" -> receiver?.let { LuaIndex(it, LuaString(name)) }
            "contains" -> receiver?.let { LuaMethodCall(it, "contains", listOf(code(arg(0)))) }
            "values", "entries" -> call("values")
            "valueOf" -> call("valueOf", arg(0))
            "Companion.valueOf" -> call("ofType", arg(0))
            else -> if (receiver == null && name.all { it.isUpperCase() || it == '_' }) LuaIndex(table(), LuaString(name)) else null
        }
    }

    private fun directionality(name: String, site: CallSite): LuaExpr? = with(site) {
        fun call(member: String, vararg args: LuaExpr) = LuaCall(LuaIndex(directions(), LuaString(member)), args.toList())
        when (name) {
            "value" -> receiver?.let { LuaIndex(it, LuaString(name)) }
            "values", "entries" -> call("values")
            "valueOf" -> call("valueOf", arg(0))
            "Companion.valueOf" -> call("ofValue", arg(0))
            else -> if (receiver == null && name.all { it.isUpperCase() || it == '_' }) LuaIndex(directions(), LuaString(name)) else null
        }
    }
}
