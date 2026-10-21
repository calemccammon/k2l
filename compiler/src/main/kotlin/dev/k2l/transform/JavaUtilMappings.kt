package dev.k2l.transform

import dev.k2l.codegen.*

/**
 * `java.util.Stack` (a list, with push/pop/peek/empty/search), `java.util.StringJoiner`, `java.util.Objects` and more
 * statics of `java.lang.Boolean`, `Character`, `Integer`, `Long` and `Double` (see `JavaUtil.lua`), and Kotlin's
 * `Boolean.and`/`or`.
 */
internal object JavaUtilMappings {
    private val STACK_HELPERS = setOf("push", "pop", "peek", "search")
    private val JOINER_METHODS = setOf("add", "setEmptyValue", "merge", "length", "toString")
    private val BOXES = listOf("Integer", "Long", "Double", "Boolean", "Character")
    private val COMPARING = setOf("comparingInt", "comparingLong", "comparingDouble")
    private val THEN_COMPARING = setOf("thenComparingInt", "thenComparingLong", "thenComparingDouble")

    /** `Stack()`, `StringJoiner(delimiter)` and `StringJoiner(delimiter, prefix, suffix)`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? = when (classId) {
        "java/util/Stack", "java/util/Vector" -> site.libNew(featureOf("__K2L_List"), "__K2L_List", emptyList())
        "java/util/StringJoiner" -> site.libNew(JAVA_UTIL_FEATURE, "__K2L_StringJoiner", site.args)
        "java/util/BitSet" -> BitSetMappings.construct(site)
        else -> null
    }

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        // Kotlin's `a and b`, `a or b` (no short-circuit) are Boolean.logicalAnd/logicalOr
        if (callableId == "kotlin/Boolean.and" || callableId == "kotlin/Boolean.or") {
            val member = if (callableId == "kotlin/Boolean.and") "logicalAnd" else "logicalOr"
            return site.libMember("JavaUtil", "__K2L_JavaUtil", member, site.self, site.arg(0))
        }
        val owner = callableId?.substringBeforeLast('.') ?: return null
        val name = site.name ?: return null
        return when (owner) {
            "java/util/Stack" -> stack(name, site)

            "java/util/StringJoiner" -> when {
                name !in JOINER_METHODS || site.receiver == null -> null

                // the UTF-16 length of the text with --strings utf16 (the joiner counts bytes)
                name == "length" && site.utf16 -> site.u16("len", LuaMethodCall(site.self, "toString", emptyList()))

                else -> LuaMethodCall(site.self, name, site.args)
            }

            "java/util/Objects" -> objects(name, site)

            "java/util/BitSet" -> BitSetMappings.map(name, site)

            "java/util/Comparator" -> comparators(name, site)

            "java/lang/Boolean" -> booleans(name, site)

            "java/lang/Character" -> characters(name, site)

            "java/lang/Double" -> doubles(name, site)

            else -> if (owner.startsWith("java/lang/") && owner.removePrefix("java/lang/") in BOXES && name == "hashCode") {
                hash(site)
            } else {
                null
            }
        }
    }

    private fun CallSite.helper(member: String, vararg args: LuaExpr): LuaExpr = libMember(JAVA_UTIL_TABLE, member, *args)

    private fun stack(name: String, site: CallSite): LuaExpr? = when {
        site.receiver == null -> null
        name in STACK_HELPERS -> site.helper(name, site.self, *site.args.toTypedArray())
        name == "empty" -> LuaMethodCall(site.self, "isEmpty", emptyList())
        else -> null
    }

    private fun objects(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "requireNonNull" -> helper("requireNonNull", *args.toTypedArray())

            "requireNonNullElse", "requireNonNullElseGet", "checkIndex", "checkFromToIndex", "checkFromIndexSize", "compare" ->
                helper(name, *args.toTypedArray())

            "deepEquals" -> libMember(JDK_COLLECTIONS_TABLE, "objectsDeepEquals", arg(0), arg(1))

            "isNull" -> LuaBinary(LuaBinOp.Eq, arg(0), LuaNil)

            "nonNull" -> LuaBinary(LuaBinOp.Ne, arg(0), LuaNil)

            "toString" -> if (args.size == 2) helper("toStringOr", arg(0), arg(1)) else str(arg(0), argTypes[0])

            else -> null
        }
    }

    /** `Comparator.comparingInt` and friends: the keys are numbers, so they are `comparing` and `thenComparing`. */
    private fun comparators(name: String, site: CallSite): LuaExpr? {
        fun comparators(fn: String, vararg args: LuaExpr): LuaExpr = LuaCall(site.ref("Comparators", fn), args.toList())
        return when {
            name in COMPARING && site.receiver == null && site.args.size == 1 -> comparators("__K2L_CompareBy", site.arg(0))
            name in THEN_COMPARING && site.receiver != null -> comparators("__K2L_ThenBy", site.self, site.arg(0))
            name == "nullsFirst" && site.receiver == null -> comparators("__K2L_NullsFirst", site.arg(0))
            name == "nullsLast" && site.receiver == null -> comparators("__K2L_NullsLast", site.arg(0))
            else -> null
        }
    }

    private fun booleans(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "compare" -> helper("compareBooleans", arg(0), arg(1))

            "logicalAnd", "logicalOr" -> helper(name, arg(0), arg(1))

            "logicalXor" -> LuaBinary(LuaBinOp.Ne, arg(0), arg(1))

            // valueOf(text) is parseBoolean(text)
            "valueOf" -> if (isTextual(argTypes[0])) {
                LuaBinary(LuaBinOp.Eq, lua("string.lower", LuaBinary(LuaBinOp.Or, arg(0), LuaString(""))), LuaString("true"))
            } else {
                arg(0)
            }

            "hashCode" -> hash(this)

            else -> null
        }
    }

    private fun characters(name: String, site: CallSite): LuaExpr? = with(site) {
        val isChar = isChar(argTypes.firstOrNull())
        when {
            // the code of the digit, as a Char
            name == "forDigit" -> StdlibMappings.map("kotlin/Int.toChar", withReceiver(helper("forDigit", arg(0), arg(1)), argTypes[0]))

            // Character.digit(c, radix) is c.digitToIntOrNull(radix) ?: -1
            name == "digit" && isChar -> asMember("kotlin/text/digitToIntOrNull")?.let { LuaBinary(LuaBinOp.Or, it, LuaNumber("-1")) }

            name == "hashCode" && isChar -> hash(this)

            else -> null
        }
    }

    private fun doubles(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "max", "min" -> StdlibMappings.map("java/lang/Math.$name", this)
            "sum" -> LuaBinary(LuaBinOp.Add, arg(0), arg(1))
            "hashCode" -> LuaCall(ref("Hash", "__K2L_DoubleHash"), listOf(arg(0)))
            else -> null
        }
    }

    /** `Integer.hashCode(x)` and the like: the hash of the value. */
    private fun hash(site: CallSite): LuaExpr? = if (site.args.size == 1) site.lualib("Hash", site.arg(0)) else null

    /** The mapping of the Kotlin member or extension [id], called on the first argument. */
    private fun CallSite.asMember(id: String): LuaExpr? = StdlibMappings.map(id, onFirstArgument(id.substringAfterLast('/')))
}
