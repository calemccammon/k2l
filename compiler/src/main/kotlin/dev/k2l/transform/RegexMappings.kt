package dev.k2l.transform

import dev.k2l.codegen.*

/** kotlin.text.Regex, MatchResult and RegexOption (see `Regex.lua`). */
internal object RegexMappings {
    private val OPTIONS = listOf("IGNORE_CASE", "MULTILINE", "DOT_MATCHES_ALL", "LITERAL", "COMMENTS", "UNIX_LINES", "CANON_EQ")

    private val REGEX_METHODS =
        setOf("find", "matchEntire", "matches", "containsMatchIn", "replace", "replaceFirst", "split", "matchAt", "matchesAt")

    fun install(t: MappingTable) {
        for (option in OPTIONS) {
            t.def("kotlin/text/RegexOption.$option") {
                // with --strings utf16, IGNORE_CASE compares by the Unicode case folding
                if (option == "IGNORE_CASE") requireUtf16Case()
                LuaString(option)
            }
        }
        t.def("kotlin/text/Regex.Companion.escape") {
            libCall(REGEX_TABLE, "escape", listOf(arg(0)))
        }
        t.def("kotlin/text/Regex.Companion.escapeReplacement") {
            libCall(REGEX_TABLE, "escapeReplacement", listOf(arg(0)))
        }
        t.def("kotlin/text/Regex.Companion.fromLiteral") {
            libNew(REGEX_TABLE, listOf(arg(0), LuaString("LITERAL")))
        }
        // groups["name"]
        t.def("kotlin/text/get") { if (isString(argTypes.firstOrNull())) method(self, "getNamed", arg(0)) else null }
    }

    fun regexMember(name: String, site: CallSite): LuaExpr? = when {
        name == "pattern" -> LuaIndex(site.self, LuaString("pattern"))

        // a lazy Sequence, as in Kotlin: matches are searched for as they are pulled
        name == "findAll" -> site.libNew(SEQUENCE_FEATURE, "__K2L_Sequence", listOf(LuaMethodCall(site.self, "findAllFactory", site.args)))

        name in REGEX_METHODS -> LuaMethodCall(site.self, name, site.args)

        else -> null
    }

    fun matchMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "value", "range", "groupValues", "groups", "destructured" -> LuaIndex(site.self, LuaString(name))
        "next" -> LuaMethodCall(site.self, "next", emptyList())
        else -> null
    }
}
