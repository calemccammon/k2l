package dev.k2l.transform

import dev.k2l.codegen.*

/** kotlin.text.Regex, MatchResult and RegexOption (see `Regex.lua`). */
internal object RegexMappings {
    private val OPTIONS = listOf("IGNORE_CASE", "MULTILINE", "DOT_MATCHES_ALL", "LITERAL", "COMMENTS", "UNIX_LINES", "CANON_EQ")

    private val REGEX_METHODS =
        setOf("find", "findAll", "matchEntire", "matches", "containsMatchIn", "replace", "replaceFirst", "split")

    fun install(t: MappingTable) {
        for (option in OPTIONS) {
            t.def("kotlin/text/RegexOption.$option") { LuaString(option) }
        }
        t.def("kotlin/text/Regex.Companion.escape") {
            LuaCall(LuaIndex(ref("Regex", "__K2L_Regex"), LuaString("escape")), listOf(arg(0)))
        }
        t.def("kotlin/text/Regex.Companion.escapeReplacement") {
            LuaCall(LuaIndex(ref("Regex", "__K2L_Regex"), LuaString("escapeReplacement")), listOf(arg(0)))
        }
        t.def("kotlin/text/Regex.Companion.fromLiteral") {
            LuaCall(LuaIndex(ref("Regex", "__K2L_Regex"), LuaString("new")), listOf(arg(0), LuaString("LITERAL")))
        }
        // groups["name"]
        t.def("kotlin/text/get") { if (isString(argTypes.firstOrNull())) method(self, "getNamed", arg(0)) else null }
    }

    fun regexMember(name: String, site: CallSite): LuaExpr? = when {
        name == "pattern" -> LuaIndex(site.self, LuaString("pattern"))
        name in REGEX_METHODS -> LuaMethodCall(site.self, name, site.args)
        else -> null
    }

    fun matchMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "value", "range", "groupValues", "groups", "destructured" -> LuaIndex(site.self, LuaString(name))
        "next" -> LuaMethodCall(site.self, "next", emptyList())
        else -> null
    }
}
