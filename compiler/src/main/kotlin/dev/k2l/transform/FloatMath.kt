package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `Float` is a Lua double that is rounded to IEEE single precision (`__K2L_Fround`) after every arithmetic operation,
 * conversion and library call that can produce a value that is not already a float. Literals are emitted as the exact
 * double value of the float. Printing a statically typed `Float` uses `__K2L_FloatToString`.
 */
private fun KaSession.isFloat(t: KaType?): Boolean = t != null && t.withoutFlexibility.let { !it.isMarkedNullable && it.isFloatType }

/** The Kotlin result of an arithmetic operator with these operand types is `Float`: a `Float` and `Float` or integer operands. */
internal fun FileTransformer.floatResult(lt: KaType?, rt: KaType?): Boolean = with(session) {
    (isFloat(lt) || isFloat(rt)) && listOf(lt, rt).all { it != null && !it.isMarkedNullable && (isFloat(it) || it.isIntegral) }
}

internal fun FileTransformer.fround(e: LuaExpr): LuaExpr = lualibCall("Fround", e)

/** [e], rounded to single precision when `lt op rt` is a `Float`. */
internal fun FileTransformer.roundedFloat(e: LuaExpr, lt: KaType?, rt: KaType?): LuaExpr = if (floatResult(lt, rt)) fround(e) else e

/** `l / r` for numbers that are not both integral. */
internal fun FileTransformer.floatDivision(left: LuaExpr, lt: KaType?, right: LuaExpr, rt: KaType?): LuaExpr {
    val (l, r) = long64Widen(left, lt, right, rt)
    return roundedFloat(LuaBinary(LuaBinOp.Div, l, r), lt, rt)
}

/** Library calls whose `Float` overload computes in double precision on the JVM too, then narrows. */
internal object FloatMappings {
    private val INEXACT = setOf(
        "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "atan2", "exp", "pow", "sinh", "cosh", "tanh",
        "ln", "ln1p", "expm1", "log10", "log2", "log", "hypot", "cbrt",
    )

    /** `sum()` of `Float`s accumulates in single precision, as on the JVM (there is no `sumOf` returning `Float`). */
    fun sum(site: CallSite): LuaExpr? = with(site.session) {
        if (isFloat(site.receiverType?.elementType)) site.lualib("FloatSum", site.self) else null
    }

    /**
     * `joinToString()` of `Double`s or `Float`s without a transform prints each element by its static type, which the untyped
     * printer cannot tell: an integral Double looks like an Int without integers, and one that is exactly a float like a Float.
     */
    fun joinToString(site: CallSite): LuaExpr? = with(site.session) {
        if (site.args.size >= JOIN_TRANSFORM) return null
        val receiver = site.receiverType?.withoutFlexibility ?: return null
        val element = receiver.elementType?.withoutFlexibility
        val classId = (receiver as? KaClassType)?.classId?.asString()
        val printer = when {
            classId == "kotlin/FloatArray" || element?.isFloatType == true -> "FloatToString"

            !site.hasIntegers || site.transformer.usesFloat ->
                if (classId == "kotlin/DoubleArray" || element?.isDoubleType == true) "DoubleToString" else return null

            else -> return null
        }
        val args = site.args + List(JOIN_TRANSFORM - 1 - site.args.size) { LuaNil } + site.ref(printer, "__K2L_$printer")
        LuaMethodCall(site.self, "joinToString", args)
    }

    /** The position of `transform` among `joinToString`'s parameters, counted from 1. */
    private const val JOIN_TRANSFORM = 6

    /** [result] of the mapping for [callableId], rounded to a float when the call returns one. */
    fun post(callableId: String?, site: CallSite, result: LuaExpr?): LuaExpr? {
        if (result == null || callableId == null) return result
        val inexactMath = callableId.startsWith("kotlin/math/") && callableId.removePrefix("kotlin/math/") in INEXACT
        val textual = callableId == "kotlin/text/toFloat" || callableId == "kotlin/text/toFloatOrNull"
        if (!inexactMath && !textual) return result
        val returnsFloat = textual || with(site.session) { isFloat(site.element.expressionType) }
        return if (returnsFloat) site.transformer.fround(result) else result
    }
}
