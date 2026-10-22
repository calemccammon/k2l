package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** Members of `String`, `CharSequence` and `Char` (kotlin.text). Strings are Lua strings and chars one-character strings. */
@Suppress("TooManyFunctions") // one small mapper per group of members
internal object TextMappings {
    /** `CharSequence` operations that are the `Iterable` ones over the characters and return a list, map or scalar. */
    private val ON_CHAR_LIST = setOf(
        "any", "all", "none", "map", "mapIndexed", "mapNotNull", "flatMap", "forEachIndexed", "withIndex", "toSet", "toMutableList",
        "toMutableSet", "zip", "groupBy", "associate", "associateWith", "associateBy", "sumOf", "maxOrNull", "minOrNull", "max", "min",
        "maxBy", "minBy", "maxByOrNull", "minByOrNull", "maxOf", "minOf", "indexOfFirst", "indexOfLast", "find", "findLast", "randomOrNull",
        "firstOrNull", "lastOrNull", "fold", "reduce", "foldIndexed", "reduceOrNull", "zipWithNext", "asIterable", "onEach", "distinct",
        "count", "first", "last", "random", "elementAtOrNull", "elementAtOrElse", "getOrElse", "single", "singleOrNull",
        "iterator", "groupingBy", "toSortedSet", "maxOfWith", "minOfWith", "maxOfWithOrNull", "minOfWithOrNull", "maxWith",
        "minWith", "maxWithOrNull", "minWithOrNull", "foldRight", "foldRightIndexed", "reduceRight", "reduceIndexed",
        "reduceIndexedOrNull", "runningFold",
        "runningFoldIndexed", "runningReduce", "runningReduceIndexed", "mapIndexedNotNull", "mapIndexedNotNullTo", "mapIndexedTo", "mapTo",
        "flatMapIndexed", "flatMapIndexedTo", "associateByTo", "associateWithTo", "toCollection", "toHashSet", "maxOfOrNull",
        "minOfOrNull", "firstNotNullOf", "firstNotNullOfOrNull", "scan", "scanIndexed",
    )

    /** The list methods of the [ON_CHAR_LIST] operations named differently. */
    private val LIST_NAMES = mapOf("scan" to "runningFold", "scanIndexed" to "runningFoldIndexed")

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        val receiverType = site.receiverType
        val name = site.name ?: return null
        if (receiverType == null) return topLevel(callableId, site)
        if (site.isChar(receiverType)) return charMember(name, site)
        val isString = with(site.session) { receiverType.withoutFlexibility.let { it.isStringType || it.isCharSequenceType } }
        if (!isString || callableId?.startsWith("kotlin/") != true) return null
        return stringMember(name, StringCall(site))
    }

    private fun stringMember(name: String, c: StringCall): LuaExpr? =
        regexMember(name, c) ?: indexing(name, c) ?: search(name, c) ?: trimming(name, c) ?: nullAndBlank(name, c)
            ?: conversion(name, c) ?: substrings(name, c) ?: onChars(name, c)

    /** Calls without a String receiver: `String.format(...)`, `String(chars)`, `String.CASE_INSENSITIVE_ORDER`. */
    private fun topLevel(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
        "kotlin/text/format" -> TextFormat.format(site, null)
        "kotlin/text/String" -> site.text("string", site.arg(0))
        "kotlin/text/CASE_INSENSITIVE_ORDER" -> luaField(site.ref(TEXT_TABLE), "caseInsensitiveOrder")
        else -> null
    }

    private fun CallSite.text(member: String, vararg args: LuaExpr) =
        libMember(TEXT_TABLE, member, *args.toList().dropTrailingNil().toTypedArray())

    private fun CallSite.helper(fn: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(ref("Strings", "__K2L_String$fn"), args.toList().dropTrailingNil())

    private class StringCall(val site: CallSite) {
        val self = site.self
        val args get() = site.args

        fun text(member: String, vararg rest: LuaExpr) = site.text(member, self, *rest)

        fun helper(fn: String, vararg rest: LuaExpr) = site.helper(fn, self, *rest)

        /** The argument at [i], or nil when it is omitted. */
        fun arg(i: Int): LuaExpr = site.args.getOrElse(i) { LuaNil }

        /** The `ignoreCase` argument at [i] as an expression, or null when it is absent or literally false. */
        fun ignoreCase(i: Int): LuaExpr? = site.args.getOrNull(i)?.takeIf { it != LuaBool(false) && it != LuaNil }

        fun literalIgnoreCase(i: Int): Boolean = site.args.getOrNull(i) == LuaBool(true)

        fun lower(e: LuaExpr): LuaExpr = LuaMethodCall(e, "lower", emptyList())

        /** The length of the receiver in chars (bytes). */
        fun length(): LuaExpr = LuaUnary(LuaUnOp.Len, self)

        fun argType(i: Int): KaType? = site.argTypes.getOrNull(i)

        fun isRange(i: Int) = site.kindOf(site.argTypes.getOrNull(i)) == CollectionKind.Range

        fun isString(i: Int) = site.isString(site.argTypes.getOrNull(i))

        fun helperOf(e: LuaExpr): LuaExpr = LuaCall(site.ref("Strings", "__K2L_StringToList"), listOf(e))

        fun isRegex(i: Int) = site.kindOf(site.argTypes.getOrNull(i)) == CollectionKind.Regex

        fun isFunction(i: Int) = site.argTypes.getOrNull(i) is KaFunctionType

        /** Whether argument [i] is an integer (which tells overloads apart). */
        fun isInt(i: Int) = site.isIntegral(site.argTypes.getOrNull(i))

        fun listOfChars(): LuaExpr = helper("ToList")

        fun noArgs(fn: String) = if (args.isEmpty()) helper(fn) else null
    }

    private fun regexMember(name: String, c: StringCall): LuaExpr? {
        if (!c.isRegex(0)) return null
        val regex = c.args[0]
        return when (name) {
            "contains" -> LuaMethodCall(regex, "containsMatchIn", listOf(c.self))
            "matches" -> LuaMethodCall(regex, "matches", listOf(c.self))
            "replace" -> LuaMethodCall(regex, "replace", listOf(c.self, c.args[1]))
            "replaceFirst" -> LuaMethodCall(regex, "replaceFirst", listOf(c.self, c.args[1]))
            "split" -> LuaMethodCall(regex, "split", listOf(c.self) + c.args.drop(1))
            else -> null
        }
    }

    private fun indexing(name: String, c: StringCall): LuaExpr? = when (name) {
        // s[i] and s.get(i) throw StringIndexOutOfBoundsException, except for the index of a loop over s.indices
        "get" -> when {
            c.site.transformer.isProvenIndex(c.site.element, c.site.receiverType) -> charAt(c)
            c.site.isString(c.site.receiverType) -> c.site.transformer.inlineCharAt(c.self, c.args[0]) ?: c.helper("CharAt", c.args[0])
            else -> c.helper("CharAt", c.args[0])
        }

        "substring", "subSequence" -> if (c.isRange(0)) c.text("substringOf", c.args[0]) else c.text("substring", *c.args.toTypedArray())

        "reversed" -> LuaMethodCall(c.self, "reverse", emptyList())

        "lastIndex" -> LuaBinary(LuaBinOp.Sub, c.length(), LuaNumber("1"))

        "indices" -> c.site.libNew(INT_RANGE_TABLE, listOf(LuaNumber("0"), LuaBinary(LuaBinOp.Sub, c.length(), LuaNumber("1"))))

        "getOrNull", "elementAtOrNull" -> c.text("getOrNull", c.args[0])

        "elementAt" -> c.text("get", c.args[0])

        "slice" -> c.text("slice", c.args[0])

        else -> null
    }

    /** `s:sub(i + 1, i + 1)` */
    private fun charAt(c: StringCall): LuaExpr {
        val i = c.args[0]
        val n = (i as? LuaNumber)?.text?.toLongOrNull()
        val at = if (n != null) LuaNumber("${n + 1}") else LuaBinary(LuaBinOp.Add, i, LuaNumber("1"))
        return LuaMethodCall(c.self, "sub", listOf(at, at))
    }

    private fun search(name: String, c: StringCall): LuaExpr? {
        val a = c.args
        return when (name) {
            "startsWith" -> compareEnds(c, "StartsWith")

            "endsWith" -> compareEnds(c, "EndsWith")

            "contains" -> when {
                c.literalIgnoreCase(1) -> ignoreCaseCall(c, "Contains")
                c.ignoreCase(1) != null -> if (c.isString(0)) dynamicIgnoreCase(c, "Contains") else null
                else -> c.helper("Contains", a[0])
            }

            "indexOf" -> if (a.size <= 2) c.helper("IndexOf", *a.toTypedArray()) else c.text("indexOf", a[0], a[1], a[2])

            "lastIndexOf" -> if (a.size == 1) {
                c.helper("LastIndexOf", a[0])
            } else {
                c.text("lastIndexOf", a[0], a.getOrElse(1) { LuaNil }, a.getOrElse(2) { LuaNil })
            }

            "indexOfAny" -> c.text("indexOfAny", a[0], a.getOrElse(1) { LuaNil })

            "replace" -> if (a.size == 2) c.helper("Replace", a[0], a[1]) else c.text("replace", a[0], a[1], a.getOrElse(2) { LuaNil })

            "replaceFirst" -> c.text("replaceFirst", a[0], a[1], a.getOrElse(2) { LuaNil })

            "split" -> split(c)

            "equals" -> if (c.ignoreCase(1) != null) c.helper("EqualsIgnoreCase", a[0]) else LuaBinary(LuaBinOp.Eq, c.self, a[0])

            "contentEquals" -> LuaBinary(LuaBinOp.Eq, c.self, a[0])

            "compareTo" -> compareTo(c)

            "regionMatches" -> c.text("regionMatches", *a.toTypedArray())

            "commonPrefixWith" -> c.text("commonPrefixWith", a[0])

            "commonSuffixWith" -> c.text("commonSuffixWith", a[0])

            "format" -> TextFormat.format(c.site, c.self)

            else -> null
        }
    }

    /** A helper applied to the lower-cased receiver and argument. */
    private fun ignoreCaseCall(c: StringCall, helper: String): LuaExpr =
        LuaCall(c.site.ref("Strings", "__K2L_String$helper"), listOf(c.lower(c.self), c.lower(c.args[0])))

    private fun compareEnds(c: StringCall, helper: String): LuaExpr? = when {
        c.isInt(1) -> if (helper == "StartsWith") startsWithAt(c) else null
        c.literalIgnoreCase(1) -> ignoreCaseCall(c, helper)
        c.ignoreCase(1) != null -> dynamicIgnoreCase(c, helper)
        else -> c.helper(helper, c.args[0])
    }

    /**
     * `s.endsWith(x, ignoreCase = flag)`: `flag and <ignoring case> or <exact>`, which is right even when the first is false (an
     * exact match is also one ignoring case). Only for operands that can be evaluated twice.
     */
    private fun dynamicIgnoreCase(c: StringCall, helper: String): LuaExpr? {
        val flag = c.args[1]
        if (!c.self.isSimple() || !c.args[0].isSimple() || !flag.isSimple()) return null
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, flag, ignoreCaseCall(c, helper)), c.helper(helper, c.args[0]))
    }

    /** `startsWith(prefix, startIndex)` */
    private fun startsWithAt(c: StringCall): LuaExpr {
        val start = c.args[1]
        val from = LuaBinary(LuaBinOp.Add, start, LuaNumber("1"))
        val to = LuaBinary(LuaBinOp.Add, start, LuaUnary(LuaUnOp.Len, c.args[0]))
        return LuaBinary(LuaBinOp.Eq, LuaMethodCall(c.self, "sub", listOf(from, to)), c.args[0])
    }

    private fun compareTo(c: StringCall): LuaExpr {
        val compare = luaField(c.site.ref(TEXT_TABLE), "compare")
        return if (c.literalIgnoreCase(1)) {
            LuaCall(compare, listOf(c.lower(c.self), c.lower(c.args[0])))
        } else {
            LuaCall(compare, listOf(c.self, c.args[0]))
        }
    }

    /** `split(vararg delimiters, ignoreCase, limit)`: delimiters are the leading String or Char arguments. */
    private fun split(c: StringCall): LuaExpr? {
        if (c.args.size == 1 && c.site.isTextual(c.argType(0))) return c.helper("Split", c.args[0])
        val count = c.site.argTypes.indexOfFirst { !c.site.isTextual(it) }.let { if (it < 0) c.args.size else it }
        if (count == 0) return null
        val delimiters = LuaTable(c.args.take(count).map { LuaField.Positional(it) })
        return c.text("split", delimiters, c.args.getOrElse(count + 1) { LuaNil }, c.args.getOrElse(count) { LuaNil })
    }

    private fun trimming(name: String, c: StringCall): LuaExpr? {
        val mode = when (name) {
            "trim" -> 3
            "trimStart" -> 1
            "trimEnd" -> 2
            else -> return null
        }
        return when {
            c.args.isEmpty() -> c.helper(name.replaceFirstChar { it.uppercase() })
            c.isFunction(0) -> c.text("trimWith", LuaNumber("$mode"), c.args[0])
            else -> c.text("trimChars", LuaNumber("$mode"), *c.args.toTypedArray())
        }
    }

    private fun nullAndBlank(name: String, c: StringCall): LuaExpr? {
        val self = c.self
        return when (name) {
            "lines" -> c.helper("Lines")
            "lineSequence" -> LuaCall(c.site.ref(SEQUENCE_FEATURE, "__K2L_AsSequence"), listOf(c.helper("Lines")))
            "prependIndent" -> c.text("prependIndent", c.args.getOrElse(0) { LuaString("    ") })
            "isBlank" -> c.helper("IsBlank")
            "isNotBlank" -> LuaUnary(LuaUnOp.Not, c.helper("IsBlank"))
            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaBinary(LuaBinOp.Eq, self, LuaString("")))
            "isNullOrBlank" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), c.helper("IsBlank"))
            "orEmpty" -> LuaBinary(LuaBinOp.Or, self, LuaString(""))
            "padStart" -> c.helper("PadStart", *c.args.toTypedArray())
            "padEnd" -> c.helper("PadEnd", *c.args.toTypedArray())
            "ifEmpty" -> c.text("ifEmpty", c.args[0])
            "ifBlank" -> c.text("ifBlank", c.args[0])
            "trimIndent" -> c.text("trimIndent")
            "trimMargin" -> c.text("trimMargin", *c.args.toTypedArray())
            else -> null
        }
    }

    private fun conversion(name: String, c: StringCall): LuaExpr? {
        val radix = c.args.getOrElse(0) { LuaNil }
        return when (name) {
            "toInt" -> c.helper("ToInt", radix)
            "toLong" -> c.helper("ToInt", radix, LuaBool(true))
            "toIntOrNull" -> c.helper("ToIntOrNull", radix)
            "toLongOrNull" -> c.helper("ToIntOrNull", radix, LuaBool(true))
            "toDouble", "toFloat" -> c.helper("ToDouble")
            "toDoubleOrNull", "toFloatOrNull" -> c.helper("ToDoubleOrNull")
            "toBoolean" -> c.text("toBoolean")
            "toBooleanStrict" -> c.text("toBooleanStrict")
            "toBooleanStrictOrNull" -> c.text("toBooleanStrictOrNull")
            "toList" -> c.helper("ToList")
            "toCharArray" -> c.text("toCharArray")
            "toByteArray", "encodeToByteArray" -> c.text("toByteArray")
            "toRegex" -> RegexMappings.construct(c.site, c.self, c.args.getOrNull(0), isReceiver = true)
            else -> null
        }
    }

    /** String-valued transformations; the overloads taking Char or predicate arguments map to the same helpers. */
    private fun substrings(name: String, c: StringCall): LuaExpr? {
        val a = c.args
        return when (name) {
            "take", "drop", "takeLast", "dropLast", "takeWhile", "dropWhile", "takeLastWhile", "dropLastWhile",
            "removePrefix", "removeSuffix", "filter", "filterNot", "filterIndexed",
            -> c.text(name, a[0])

            "removeSurrounding" -> c.text(name, a[0], a.getOrElse(1) { LuaNil })

            "substringBefore", "substringAfter", "substringBeforeLast", "substringAfterLast" ->
                c.text(name, a[0], a.getOrElse(1) { LuaNil })

            "removeRange" -> if (c.isRange(0)) c.text("removeRangeOf", a[0]) else c.text("removeRange", a[0], a[1])

            "replaceRange" -> if (c.isRange(0)) c.text("replaceRangeOf", a[0], a[1]) else c.text("replaceRange", a[0], a[1], a[2])

            "replaceFirstChar" -> c.text("replaceFirstChar", a[0])

            "partition" -> c.text("partition", a[0])

            "chunked" -> c.text("chunked", a[0], a.getOrElse(1) { LuaNil })

            "windowed" -> c.text("windowed", *a.toTypedArray())

            else -> null
        }
    }

    /** Everything else is the `Iterable` operation over the string's characters. */
    private fun onChars(name: String, c: StringCall): LuaExpr? {
        if (name == "count" && c.args.isEmpty()) return c.length()
        if ((name == "first" || name == "last") && c.args.isEmpty()) return c.text(name)
        if (name == "single" && c.args.isEmpty()) return c.text("single")
        if (name !in ON_CHAR_LIST) return null
        return LuaMethodCall(c.listOfChars(), LIST_NAMES[name] ?: name, charListArguments(name, c))
    }

    /** The arguments of the list operation: a default Random, the other string's characters, the receiver's name in an error. */
    private fun charListArguments(name: String, c: StringCall): List<LuaExpr> = when {
        name == "random" || name == "randomOrNull" -> listOf(c.args.firstOrNull() ?: c.site.defaultRandom())
        name == "zip" && c.isString(0) -> listOf(c.helperOf(c.args[0])) + c.args.drop(1)
        name == "firstNotNullOf" -> c.args + LuaString("char sequence")
        else -> c.args
    }

    /** Members of `Char`: a Char is one byte, classified and case-mapped as ASCII. */
    internal fun charMember(name: String, site: CallSite): LuaExpr? {
        val c = site.self

        // a lookup in a table of the matching one-character strings, see CharClasses.lua
        fun matches(table: String) = LuaBinary(LuaBinOp.Eq, LuaIndex(site.ref("CharClasses", table), c), LuaBool(true))
        return when (name) {
            "code" -> LuaMethodCall(c, "byte", emptyList())
            "isDigit" -> matches("__K2L_IsDigit")
            "isLetter" -> matches("__K2L_IsLetter")
            "isLetterOrDigit" -> matches("__K2L_IsLetterOrDigit")
            "isWhitespace" -> matches("__K2L_IsWhitespace")
            "isUpperCase" -> matches("__K2L_IsUpperCase")
            "isLowerCase" -> matches("__K2L_IsLowerCase")
            "uppercaseChar", "uppercase", "titlecase", "titlecaseChar" -> LuaMethodCall(c, "upper", emptyList())
            "lowercaseChar", "lowercase" -> LuaMethodCall(c, "lower", emptyList())
            "digitToInt" -> site.libMember(NUM_TABLE, "digitToInt", c, *site.args.toTypedArray())
            "digitToIntOrNull" -> site.libMember(NUM_TABLE, "digitToIntOrNull", c, *site.args.toTypedArray())
            "equals" -> asciiCharEquals(site)
            "toString" -> c
            else -> null
        }
    }

    /** `c.equals(other, ignoreCase)` on ASCII chars. */
    private fun asciiCharEquals(site: CallSite): LuaExpr? {
        val (other, ignoreCase) = site.args.takeIf { it.size == 2 } ?: return null
        return when (ignoreCase) {
            LuaBool(false) -> LuaBinary(LuaBinOp.Eq, site.self, other)
            LuaBool(true) -> LuaCall(site.ref("Strings", "__K2L_StringEqualsIgnoreCase"), listOf(site.self, other))
            else -> site.text("charEquals", site.self, other, ignoreCase)
        }
    }
}
