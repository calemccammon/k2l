package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** Lua feature implementing `kotlin.time`, see `Duration.lua`. */
internal const val DURATION_FEATURE = "Duration"

/**
 * `kotlin.time`: Duration, DurationUnit, measureTime/measureTimedValue and TimedValue, TimeSource.Monotonic and
 * TestTimeSource with their time marks (see `Duration.lua`).
 */
internal object TimeMappings {
    private const val PACKAGE = "kotlin/time/"

    /** The lambda of `toComponents { days, hours, minutes, seconds, nanoseconds -> }`. */
    private const val ALL_COMPONENTS = 5
    private val UNITS = listOf("NANOSECONDS", "MICROSECONDS", "MILLISECONDS", "SECONDS", "MINUTES", "HOURS", "DAYS")

    /** `Int.seconds` and friends: the unit of each `Duration.Companion` extension property. */
    private val UNIT_PROPERTIES = mapOf(
        "nanoseconds" to "NANOSECONDS",
        "microseconds" to "MICROSECONDS",
        "milliseconds" to "MILLISECONDS",
        "seconds" to "SECONDS",
        "minutes" to "MINUTES",
        "hours" to "HOURS",
        "days" to "DAYS",
    )

    private val IN_WHOLE = UNIT_PROPERTIES.mapKeys { (name, _) -> "inWhole" + name.replaceFirstChar { it.uppercase() } }

    /** Members of Duration, the time marks and the time sources that are methods of the same name in `Duration.lua`. */
    private val METHODS = setOf(
        "plus", "minus", "unaryMinus", "isNegative", "isPositive", "isInfinite", "isFinite", "toLong", "toInt", "toDouble",
        "toIsoString", "markNow", "elapsedNow", "hasPassedNow", "hasNotPassedNow", "plusAssign",
    )

    /** The classes whose members [METHODS] and [member] map. */
    private val CLASSES = setOf(
        "Duration", "TimeMark", "ComparableTimeMark", "TimeSource", "TimeSource.Monotonic", "TimeSource.Monotonic.ValueTimeMark",
        "TimeSource.WithComparableMarks", "TestTimeSource", "AbstractLongTimeSource", "TimedValue",
    ).map { PACKAGE + it }.toSet()

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId == null || !callableId.startsWith(PACKAGE)) return null
        // Long-valued members would need an emulated Long: not translated with --long64 emulate
        if (site.transformer.emulatesLong) return null
        return topLevel(callableId, site) ?: companion(callableId, site) ?: unit(callableId, site) ?: member(callableId, site)
    }

    /** `TestTimeSource()` and `TimedValue(value, duration)`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        val luaClass = when (classId) {
            "kotlin/time/TestTimeSource" -> "__K2L_TestTimeSource"
            "kotlin/time/TimedValue" -> "__K2L_TimedValue"
            else -> return null
        }
        return LuaCall(LuaIndex(site.ref(DURATION_FEATURE, luaClass), LuaString("new")), site.args)
    }

    private fun CallSite.duration(member: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(LuaIndex(ref(DURATION_FEATURE, "__K2L_Duration"), LuaString(member)), args.toList())

    private fun CallSite.unitValue(name: String): LuaExpr = LuaIndex(ref(DURATION_FEATURE, "__K2L_DurationUnit"), LuaString(name))

    /** `x.seconds`, `x.toDuration(unit)`: a whole number of units, or a Double rounded to the nanosecond. */
    private fun CallSite.durationOf(value: LuaExpr, type: KaType?, unit: LuaExpr): LuaExpr =
        duration(if (isFloating(type)) "ofDouble" else "ofWhole", value, unit)

    private fun topLevel(callableId: String, site: CallSite): LuaExpr? = with(site) {
        when (callableId.removePrefix(PACKAGE)) {
            "toDuration" -> durationOf(self, receiverType, arg(0))

            // 2 * duration, 1.5 * duration
            "times" -> LuaMethodCall(arg(0), if (isFloating(receiverType)) "timesDouble" else "times", listOf(self))

            "measureTime" -> LuaCall(ref(DURATION_FEATURE, "__K2L_MeasureTime"), listOfNotNull(arg(0), receiver))

            "measureTimedValue" -> LuaCall(ref(DURATION_FEATURE, "__K2L_MeasureTimedValue"), listOfNotNull(arg(0), receiver))

            else -> null
        }
    }

    private fun companion(callableId: String, site: CallSite): LuaExpr? = with(site) {
        val name = callableId.removePrefix("${PACKAGE}Duration.Companion.").takeIf { it != callableId } ?: return null
        val unit = UNIT_PROPERTIES[name]
        when {
            unit != null && receiver != null -> durationOf(self, receiverType, unitValue(unit))
            name == "ZERO" || name == "INFINITE" -> LuaIndex(ref(DURATION_FEATURE, "__K2L_Duration"), LuaString(name))
            name.startsWith("parse") -> duration("parse", arg(0), LuaBool("Iso" in name), LuaBool(name.endsWith("OrNull")))
            else -> null
        }
    }

    private fun unit(callableId: String, site: CallSite): LuaExpr? = with(site) {
        val name = callableId.removePrefix("${PACKAGE}DurationUnit.").takeIf { it != callableId } ?: return null
        when (name) {
            in UNITS -> unitValue(name)
            "values", "entries" -> LuaCall(LuaIndex(ref(DURATION_FEATURE, "__K2L_DurationUnit"), LuaString("values")), emptyList())
            "valueOf" -> LuaCall(LuaIndex(ref(DURATION_FEATURE, "__K2L_DurationUnit"), LuaString("valueOf")), listOf(arg(0)))
            else -> null
        }
    }

    private fun member(callableId: String, site: CallSite): LuaExpr? = with(site) {
        if (callableId.substringBeforeLast('.') !in CLASSES || receiver == null) return null
        val name = name ?: return null
        val unit = IN_WHOLE[name]
        when {
            unit != null -> LuaMethodCall(self, "toLong", listOf(unitValue(unit)))
            name == "times" -> LuaMethodCall(self, if (isFloating(argTypes[0])) "timesDouble" else "times", args)
            name == "div" -> LuaMethodCall(self, divMethod(argTypes[0]), args)
            name == "absoluteValue" -> LuaMethodCall(self, "absoluteValue", emptyList())
            name == "toString" && args.isNotEmpty() -> LuaMethodCall(self, "toUnitString", args.dropTrailingNil())
            name == "toComponents" -> LuaMethodCall(self, "toComponents", listOf(LuaNumber(arity(overloadType(0)).toString()), arg(0)))
            name == "equals" -> lualib("Equals", self, arg(0))
            name == "hashCode" -> lualib("Hash", self)
            name == "value" || name == "duration" -> LuaIndex(self, LuaString(name))
            name == "copy" -> LuaMethodCall(self, "copy", args)
            name in METHODS -> LuaMethodCall(self, name, args)
            else -> null
        }
    }

    private fun CallSite.divMethod(type: KaType?): String = when {
        isFloating(type) -> "divDouble"
        type != null && with(session) { type.expandedSymbol?.classId?.asString() } == "kotlin/time/Duration" -> "divDuration"
        else -> "div"
    }

    /** The number of parameters of the lambda passed to `toComponents`, which picks the overload. */
    private fun CallSite.arity(type: KaType?): Int =
        with(session) { (type?.withoutFlexibility as? KaFunctionType)?.parameterTypes?.size } ?: ALL_COMPONENTS
}
