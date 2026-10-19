package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `java.math.BigInteger`, `BigDecimal`, `RoundingMode` and `MathContext`, plus Kotlin's operator and conversion extensions
 * for them (`a + b`, `5.toBigInteger()`, `"1.5".toBigDecimal()`). The classes are in the `BigInteger` and `BigDecimal`
 * lualib features; their Lua methods have the Java names, except that `and`, `or`, `xor` and `not` (Lua keywords) are
 * `band`, `bor`, `bxor` and `bnot`.
 */
@Suppress("TooManyFunctions") // one small mapper per kind of call
internal object BigNumberMappings {
    private const val BIG_INTEGER = "java/math/BigInteger"
    private const val BIG_DECIMAL = "java/math/BigDecimal"
    private const val ROUNDING_MODE = "java/math/RoundingMode"
    private const val MATH_CONTEXT = "java/math/MathContext"

    private val KEYWORD_METHODS = mapOf("and" to "band", "or" to "bor", "xor" to "bxor", "not" to "bnot")

    /** Kotlin's operator extensions on BigInteger and BigDecimal, as Java method names. */
    private val OPERATORS = mapOf(
        "plus" to "add", "minus" to "subtract", "times" to "multiply", "rem" to "remainder", "unaryMinus" to "negate",
        "inc" to "inc", "dec" to "dec", "inv" to "bnot", "and" to "band", "or" to "bor", "xor" to "bxor",
        "shl" to "shiftLeft", "shr" to "shiftRight",
    )

    private const val KOTLIN_PREFIX = "kotlin/"
    private val FIELDS = setOf("precision", "roundingMode", "getPrecision", "getRoundingMode")

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        callableId ?: return null
        return when {
            callableId.startsWith("$BIG_INTEGER.") -> bigInteger(site)
            callableId.startsWith("$BIG_DECIMAL.") -> bigDecimal(site)
            callableId.startsWith("$ROUNDING_MODE.") -> roundingMode(site)
            callableId.startsWith("$MATH_CONTEXT.") -> mathContext(site)
            callableId.startsWith(KOTLIN_PREFIX) -> kotlinExtension(callableId, site)
            else -> null
        }
    }

    private fun classOf(site: CallSite, type: KaType?): String? =
        type?.let { with(site.session) { it.withoutFlexibility.expandedSymbol?.classId?.asString() } }

    private fun CallSite.bigInteger(member: String, vararg args: LuaExpr): LuaExpr =
        libMember("BigInteger", "__K2L_BigInteger", member, *args)

    private fun CallSite.bigDecimal(member: String, vararg args: LuaExpr): LuaExpr =
        libMember("BigDecimal", "__K2L_BigDecimal", member, *args)

    private fun CallSite.constant(feature: String, table: String, field: String? = name): LuaExpr =
        LuaIndex(ref(feature, table), LuaString(field ?: return unsupported("constant")))

    private fun isConstant(name: String?) = name != null && name.all { it.isUpperCase() || it == '_' || it.isDigit() }

    private fun bigInteger(site: CallSite): LuaExpr? {
        val name = site.name ?: return null
        return when {
            site.receiver != null -> method(site.self, KEYWORD_METHODS[name] ?: name, *site.args.toTypedArray())
            isConstant(name) -> site.constant("BigInteger", "__K2L_BigInteger")
            name == "valueOf" -> site.bigInteger("valueOf", site.arg(0))
            else -> null
        }
    }

    private fun bigDecimal(site: CallSite): LuaExpr? {
        val name = site.name ?: return null
        return when {
            site.receiver != null -> method(site.self, KEYWORD_METHODS[name] ?: name, *site.args.toTypedArray())

            isConstant(name) -> site.constant("BigDecimal", "__K2L_BigDecimal")

            name == "valueOf" ->
                if (site.isFloating(site.argTypes.firstOrNull())) {
                    site.bigDecimal("valueOfDouble", site.arg(0))
                } else {
                    site.bigDecimal("valueOf", *site.args.toTypedArray())
                }

            else -> null
        }
    }

    private fun roundingMode(site: CallSite): LuaExpr? {
        val name = site.name ?: return null
        val table = site.ref("BigDecimal", "__K2L_RoundingMode")
        return when {
            isConstant(name) -> LuaIndex(table, LuaString(name))
            name == "valueOf" || name == "values" -> LuaCall(LuaIndex(table, LuaString(name)), site.args)
            else -> null
        }
    }

    private fun mathContext(site: CallSite): LuaExpr? {
        val name = site.name ?: return null
        return when {
            site.receiver != null && name in FIELDS ->
                LuaIndex(site.self, LuaString(name.removePrefix("get").replaceFirstChar { it.lowercase() }))

            site.receiver == null && isConstant(name) -> site.constant("BigDecimal", "__K2L_MathContext")

            else -> null
        }
    }

    /** Operators and conversions defined as Kotlin extensions on the big number types and on Int, Long, Double and String. */
    private fun kotlinExtension(callableId: String, site: CallSite): LuaExpr? {
        val receiverClass = classOf(site, site.receiverType)
        val name = site.name
        return when {
            receiverClass == BIG_INTEGER || receiverClass == BIG_DECIMAL -> operator(receiverClass, name, site)
            callableId == "kotlin/toBigInteger" -> site.bigInteger("valueOf", site.self)
            callableId == "kotlin/text/toBigInteger" -> site.bigInteger("parse", site.self, *site.args.toTypedArray())
            callableId == "kotlin/text/toBigIntegerOrNull" -> site.bigInteger("parseOrNull", site.self, *site.args.toTypedArray())
            callableId == "kotlin/toBigDecimal" -> numberToBigDecimal(site)
            callableId == "kotlin/text/toBigDecimal" -> withContext(site, site.bigDecimal("parse", site.self))
            callableId == "kotlin/text/toBigDecimalOrNull" -> site.bigDecimal("parseOrNull", site.self)
            else -> null
        }
    }

    private fun operator(receiverClass: String, name: String?, site: CallSite): LuaExpr? {
        val method = when {
            name == "div" -> if (receiverClass == BIG_INTEGER) "divide" else "div"
            name == "toBigDecimal" -> return bigIntegerToBigDecimal(site)
            else -> OPERATORS[name] ?: return null
        }
        return method(site.self, method, *site.args.toTypedArray())
    }

    private fun bigIntegerToBigDecimal(site: CallSite): LuaExpr {
        val scale = site.args.getOrNull(0)?.takeIf { site.isIntegral(site.argTypes.getOrNull(0)) }
        val converted = site.bigDecimal("fromBigInteger", *listOfNotNull(site.self, scale).toTypedArray())
        return withContext(site, converted)
    }

    private fun numberToBigDecimal(site: CallSite): LuaExpr {
        val converted = if (site.isFloating(site.receiverType)) {
            site.bigDecimal("valueOfDouble", site.self)
        } else {
            site.bigDecimal("fromLong", site.self)
        }
        return withContext(site, converted)
    }

    /** A trailing `MathContext` argument rounds the converted value. */
    private fun withContext(site: CallSite, value: LuaExpr): LuaExpr {
        val last = site.args.lastOrNull() ?: return value
        return if (classOf(site, site.argTypes.last()) == MATH_CONTEXT) method(value, "round", last) else value
    }

    /** The zero a `sumOf` over BigIntegers or BigDecimals starts from, or null for other types. */
    fun zero(site: CallSite, type: KaType?): LuaExpr? = when (classOf(site, type)) {
        BIG_INTEGER -> site.constant("BigInteger", "__K2L_BigInteger", "ZERO")
        BIG_DECIMAL -> site.constant("BigDecimal", "__K2L_BigDecimal", "ZERO")
        else -> null
    }

    /** Constructors of BigInteger, BigDecimal and MathContext, or null. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        val first = site.argTypes.firstOrNull()
        return when (classId) {
            BIG_INTEGER -> if (site.isString(first)) site.bigInteger("parse", *site.args.toTypedArray()) else null

            BIG_DECIMAL -> constructDecimal(site, first)

            MATH_CONTEXT ->
                LuaCall(LuaIndex(site.ref("BigDecimal", "__K2L_MathContext"), LuaString("new")), site.args)

            else -> null
        }
    }

    private fun constructDecimal(site: CallSite, first: KaType?): LuaExpr? {
        val value = when {
            site.isString(first) -> site.bigDecimal("parse", site.arg(0))

            site.isFloating(first) -> site.bigDecimal("fromDouble", site.arg(0))

            site.isIntegral(first) -> site.bigDecimal("fromLong", site.arg(0))

            classOf(site, first) == BIG_INTEGER ->
                site.bigDecimal(
                    "fromBigInteger",
                    *site.args.take(2).filterIndexed { i, _ ->
                        i == 0 || site.isIntegral(site.argTypes[i])
                    }.toTypedArray(),
                )

            else -> return null
        }
        return withContext(site, value)
    }
}

/** `x++` and `x--` on a BigInteger or BigDecimal are `x.inc()` and `x.dec()`; null for other types. */
internal fun FileTransformer.bigNumberStep(op: LuaBinOp, read: LuaExpr, type: org.jetbrains.kotlin.analysis.api.types.KaType?): LuaExpr? {
    val classId = with(session) { type?.withoutFlexibility?.expandedSymbol?.classId?.asString() }
    if (classId != "java/math/BigInteger" && classId != "java/math/BigDecimal") return null
    return LuaMethodCall(read, if (op == LuaBinOp.Add) "inc" else "dec", emptyList())
}
