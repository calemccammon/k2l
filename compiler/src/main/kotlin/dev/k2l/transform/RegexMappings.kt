package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.psi.KtCallElement
import org.jetbrains.kotlin.psi.KtQualifiedExpression
import org.jetbrains.kotlin.psi.psiUtil.getQualifiedExpressionForSelector

/**
 * kotlin.text.Regex, MatchResult and RegexOption on Lua patterns (see `Regex.lua`). Patterns are compile-time constants,
 * translated to their Lua pattern here, so a construct Lua patterns lack is a compile error (see [RegexTranslator]).
 */
internal object RegexMappings {
    private val OPTIONS = listOf("IGNORE_CASE", "MULTILINE", "DOT_MATCHES_ALL", "LITERAL", "COMMENTS", "UNIX_LINES", "CANON_EQ")

    private val REGEX_METHODS =
        setOf("find", "matchEntire", "matches", "containsMatchIn", "replace", "replaceFirst", "split", "matchAt", "matchesAt")

    fun install(t: MappingTable) {
        for (option in OPTIONS) {
            t.def("kotlin/text/RegexOption.$option") { LuaString(option) }
        }
        // escape and escapeReplacement of a non-constant string still work: they only make a string
        t.def("kotlin/text/Regex.Companion.escape") {
            (arg(0) as? LuaString)?.let { LuaString(RegexTranslator.escape(it.value)) } ?: libCall(REGEX_TABLE, "escape", listOf(arg(0)))
        }
        t.def("kotlin/text/Regex.Companion.escapeReplacement") {
            (arg(0) as? LuaString)?.let { LuaString(RegexTranslator.escapeReplacement(it.value)) }
                ?: libCall(REGEX_TABLE, "escapeReplacement", listOf(arg(0)))
        }
        // a literal regex needs no translation: its Lua pattern is the text with the magic characters escaped
        t.def("kotlin/text/Regex.Companion.fromLiteral") {
            if (arg(0) is LuaString) construct(this, arg(0), LuaString("LITERAL")) else libCall(REGEX_TABLE, "fromLiteral", listOf(arg(0)))
        }
        // groups["name"]: there are no named groups
        t.def("kotlin/text/get") { if (isString(argTypes.firstOrNull())) unsupported("Regex named group lookup `groups[name]`") else null }
    }

    /**
     * `Regex(pattern)`, `Regex(pattern, options)` and `pattern.toRegex(options)`: the pattern and the options must be
     * compile-time constants (a `const val` or a template of them is folded to one), translated to a Lua pattern here.
     */
    fun construct(site: CallSite, luaPattern: LuaExpr, options: LuaExpr?, isReceiver: Boolean = false): LuaExpr {
        val pattern = luaPattern as? LuaString ?: constantPattern(site, isReceiver) ?: luaPattern
        val known = constantOptions(options)
        if (pattern !is LuaString || known == null) {
            site.transformer.ctx.error(site.element, if (pattern !is LuaString) NOT_CONSTANT else OPTIONS_NOT_CONSTANT)
            return LuaNil
        }
        val lua = try {
            RegexTranslator.translate(pattern.value, known)
        } catch (e: RegexUnsupported) {
            site.transformer.ctx.error(site.element, e.message.orEmpty())
            return LuaNil
        }
        return site.libNew(REGEX_TABLE, listOf(pattern, LuaString(lua)))
    }

    /** The value of a pattern the Analysis API evaluates (a template of constants, a concatenation of literals). */
    private fun constantPattern(site: CallSite, isReceiver: Boolean): LuaString? = with(site.session) {
        val e = site.element
        val call = e as? KtCallElement ?: (e as? KtQualifiedExpression)?.selectorExpression as? KtCallElement
        val expression = if (isReceiver) {
            (e as? KtQualifiedExpression)?.receiverExpression ?: e.getQualifiedExpressionForSelector()?.receiverExpression
        } else {
            call?.valueArguments?.firstOrNull()?.getArgumentExpression()
        }
        (expression?.evaluate() as? KaConstantValue.StringValue)?.let { LuaString(it.value) }
    }

    /** The option names of a constant `RegexOption.X` or `setOf(RegexOption.X, ...)`, null when they are not constants. */
    private fun constantOptions(options: LuaExpr?): Set<String>? = when (options) {
        null, LuaNil -> emptySet()

        is LuaString -> setOf(options.value)

        is LuaCall -> if ((options.fn as? LuaName)?.name == "__K2L_SetOf") {
            options.args.map { (it as? LuaString)?.value ?: return null }.toSet()
        } else {
            null
        }

        else -> null
    }

    private const val OPTIONS_NOT_CONSTANT = "Regex options must be compile-time constants (RegexOption entries or a setOf of them)"

    private const val NOT_CONSTANT = "Regex pattern must be a compile-time constant (k2l translates it to a Lua pattern)"

    fun regexMember(name: String, site: CallSite): LuaExpr? = when {
        name == "pattern" -> LuaIndex(site.self, LuaString("pattern"))

        // a lazy Sequence, as in Kotlin: matches are searched for as they are pulled
        name == "findAll" -> site.libNew(SEQUENCE_FEATURE, "__K2L_Sequence", listOf(LuaMethodCall(site.self, "findAllFactory", site.args)))

        name in REGEX_METHODS -> LuaMethodCall(site.self, name, site.args)

        else -> null
    }

    /** The members of a MatchResult and of a MatchGroup, which has no range (groups are Lua captures). */
    fun matchMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "range" -> if (isMatchGroup(site)) null else LuaIndex(site.self, LuaString(name))
        "value", "groupValues", "groups", "destructured" -> LuaIndex(site.self, LuaString(name))
        "next" -> LuaMethodCall(site.self, "next", emptyList())
        else -> null
    }

    private fun isMatchGroup(site: CallSite): Boolean = with(site.session) {
        (site.receiverType?.withoutFlexibility as? KaClassType)?.classId?.asString() == "kotlin/text/MatchGroup"
    }
}
