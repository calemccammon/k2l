package dev.k2l.transform

import dev.k2l.IntOverflow
import dev.k2l.LuaTarget
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * 32-bit `Int` arithmetic for `--int-overflow wrap`. Only operations whose result is `Int` are wrapped (`Short` and
 * `Byte` arithmetic promotes to `Int` in Kotlin too).
 *
 * A chain such as `31 * h + x` is wrapped once, around the whole chain: [wrapInt32] remembers the expression it wrapped
 * (in [TransformContext.int32Pending]) so that an enclosing `+`, `-` or `*` unwraps its operands again. That is exact on
 * 5.3/5.4 (64-bit integers wrap consistently modulo 2^32). On float targets a sum of 32-bit values is exact below 2^53,
 * so only products need care: `x * c` with a small constant `c` stays in the chain, other products go through
 * `__K2L_IMul`, which multiplies exactly in 16-bit halves.
 */
internal val FileTransformer.wrapsInt: Boolean get() = ctx.options.intOverflow == IntOverflow.Wrap

private const val TWO_31 = "0x80000000"
private const val MASK_32 = "0xFFFFFFFF"
private const val SMALL_FACTOR = 65536L
private const val NEGATIVE_ZERO = -0.0

private fun KaSession.isInt32(t: KaType?): Boolean =
    t != null && t.withoutFlexibility.let { it.isIntType || it.isShortType || it.isByteType }

private fun KaSession.isNarrow(t: KaType?): Boolean = t != null && t.withoutFlexibility.let { it.isShortType || it.isByteType }

/** Both operands are `Int`, `Short` or `Byte`: the Kotlin result is `Int`. */
internal fun FileTransformer.isInt32Arithmetic(lt: KaType?, rt: KaType?): Boolean = wrapsInt && with(session) { isInt32(lt) && isInt32(rt) }

/** [value] reduced to the signed 32-bit range. */
internal fun FileTransformer.wrapInt32(value: LuaExpr): LuaExpr {
    val wrapped = if (target.hasIntegers) {
        // ((x + 2^31) & 0xFFFFFFFF) - 2^31
        LuaBinary(
            LuaBinOp.Sub,
            LuaBinary(LuaBinOp.BAnd, LuaBinary(LuaBinOp.Add, value, LuaNumber(TWO_31)), LuaNumber(MASK_32)),
            LuaNumber(TWO_31),
        )
    } else {
        jitWrap(value) ?: lualibCall("ToInt32", value)
    }
    ctx.int32Pending[wrapped] = value
    return wrapped
}

/** The unwrapped sum or product inside [e] when it is a [wrapInt32] result of this file, else [e]. */
private fun FileTransformer.unwrapInt32(e: LuaExpr): LuaExpr = ctx.int32Pending[e] ?: e

/** `l op r` for `+`, `-` and `*`, wrapped to 32 bits when both operands are `Int`-like and wrapping is on. */
internal fun FileTransformer.arithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr =
    long64Arithmetic(op, l, lt, r, rt) ?: long64Widen(l, lt, r, rt).let { (a, b) -> narrowArithmetic(op, a, lt, b, rt) }

private fun FileTransformer.narrowArithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr {
    val typed = if (floatResult(lt, rt)) fround(LuaBinary(op, l, r)) else unsignedArithmetic(op, l, lt, r, rt)
    if (typed != null) return typed
    if (!isInt32Arithmetic(lt, rt)) return LuaBinary(op, l, r)
    if (op == LuaBinOp.Mul && !target.hasIntegers) {
        val small = listOf(l, r).any { (it as? LuaNumber)?.text?.toLongOrNull()?.let { n -> n in -SMALL_FACTOR..SMALL_FACTOR } == true }
        return if (small) wrapInt32(LuaBinary(op, l, r)) else jitMultiply(l, r) ?: lualibCall("IMul", l, r)
    }
    return wrapInt32(LuaBinary(op, unwrapInt32(l), unwrapInt32(r)))
}

internal fun FileTransformer.negation(value: LuaExpr, type: KaType?): LuaExpr =
    long64Negation(value, type) ?: negativeZero(value, type) ?: ordinaryNegation(value, type)

/** `-0.0` of a floating literal: Lua 5.1 would merge the constant with 0.0, see [floatingLiteral]. */
private fun FileTransformer.negativeZero(value: LuaExpr, type: KaType?): LuaExpr? {
    val zero = value is LuaNumber && value.text.toDoubleOrNull() == 0.0
    return if (zero && with(session) { type?.withoutFlexibility?.let { it.isDoubleType || it.isFloatType } == true }) {
        floatingLiteral(NEGATIVE_ZERO)
    } else {
        null
    }
}

private fun FileTransformer.ordinaryNegation(value: LuaExpr, type: KaType?): LuaExpr {
    val wrap = wrapsInt && with(session) { isInt32(type) } && value !is LuaNumber
    return if (wrap) wrapInt32(LuaUnary(LuaUnOp.Neg, unwrapInt32(value))) else LuaUnary(LuaUnOp.Neg, value)
}

/** `x + 1` / `x - 1` of `++` and `--`: wrapped to 32 bits for `Int`, to 16 or 8 bits for `Short` and `Byte`. */
internal fun FileTransformer.stepped(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr =
    long64Step(op, read, type) ?: bigNumberStep(op, read, type) ?: floatOrUnsignedStep(op, read, type) ?: integralStep(op, read, type)

/** `++`/`--` of a `Float` (rounded to single precision) or an unsigned type (wrapped); null for other types. */
private fun FileTransformer.floatOrUnsignedStep(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr? =
    if (with(session) { type != null && type.withoutFlexibility.isFloatType }) {
        fround(LuaBinary(op, read, LuaNumber("1")))
    } else {
        unsignedStep(op, read, type)
    }

private fun FileTransformer.integralStep(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr {
    val one = LuaNumber("1")
    if (!wrapsInt) return LuaBinary(op, read, one)
    return with(session) {
        when {
            isNarrow(type) -> {
                val narrow = if (type!!.withoutFlexibility.isShortType) "toShort" else "toByte"
                LuaCall(LuaIndex(lualibRef("Numbers", "__K2L_Num"), LuaString(narrow)), listOf(LuaBinary(op, read, one)))
            }

            isInt32(type) -> wrapInt32(LuaBinary(op, unwrapInt32(read), one))

            else -> LuaBinary(op, read, one)
        }
    }
}

/** `l / r` of integers. With wrapping, `Int.MIN_VALUE / -1` is `Int.MIN_VALUE`, so only a positive literal divisor skips the wrap. */
internal fun FileTransformer.integerDivision(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr {
    (
        long64Division(remainder = false, l, lt, r, rt) ?: unsignedLongDivision(remainder = false, l, lt, r, rt)
            ?: divisionByConstant(remainder = false, l, lt, r, rt)
        )?.let { return it }
    val quotient = lualibCall("IDiv", l, r)
    val safe = (r as? LuaNumber)?.text?.toLongOrNull()?.let { it > 0 } == true
    return if (isInt32Arithmetic(lt, rt) && !safe) wrapInt32(quotient) else quotient
}

/** Library calls that can leave the `Int` range: `abs(Int.MIN_VALUE)`, and `sum()` / `sumOf` of `Int`s (wrapped once at the end). */
internal object IntOverflowMappings {
    private val ABS = setOf("kotlin/math/abs", "kotlin/math/absoluteValue", "java/lang/Math.abs")

    fun post(callableId: String?, site: CallSite, result: LuaExpr?): LuaExpr? {
        val transformer = site.transformer
        if (result == null || callableId == null || !transformer.wrapsInt) return result
        val sums =
            site.name in setOf("sum", "sumOf") &&
                (callableId.startsWith("kotlin/collections/") || callableId.startsWith("kotlin/sequences/"))
        if (!sums && callableId !in ABS) return result
        val returnsInt = with(site.session) { site.element.expressionType?.let { !it.isMarkedNullable && it.isIntType } == true }
        return if (returnsInt) transformer.wrapInt32(result) else result
    }
}

/** `a % b`: `math.fmod`, or `__K2L_IRem` (which throws on zero) for integers whose divisor is not a nonzero literal. */
internal fun FileTransformer.remainder(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr =
    long64Division(remainder = true, l, lt, r, rt) ?: long64Widen(l, lt, r, rt).let { (a, b) -> narrowRemainder(a, lt, b, rt) }

private fun FileTransformer.narrowRemainder(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr {
    (unsignedLongDivision(remainder = true, l, lt, r, rt) ?: divisionByConstant(remainder = true, l, lt, r, rt))?.let { return it }
    val integral = with(session) { lt != null && rt != null && lt.isIntegral && rt.isIntegral }
    val literal = (r as? LuaNumber)?.text?.toDoubleOrNull()?.let { it != 0.0 } == true
    if (integral && !literal) return inlineRemainder(l, r) ?: lualibCall("IRem", l, r)
    val fmod = luaCall(luaPath("math", "fmod"), l, r)
    // fmod(-4, 2) is -0 when numbers are floats, and an Int must print as 0
    return if (integral && !target.hasIntegers) LuaBinary(LuaBinOp.Add, fmod, LuaNumber("0")) else fmod
}

/**
 * `a % b` of integers, which `__K2L_IRem` computes after a zero check (as `fmod(a, b) + 0` on Lua 5.1/5.2; on 5.3/5.4
 * `math.fmod` of integers truncates like Kotlin): inline, `b ~= 0 and fmod(a, b) + 0 or __K2L_IRem(a, b)` (the call only
 * throws; `+ 0` turns the -0.0 of a float dividend into 0.0, as IRem's `%` gives), when reading `a` and `b` again is
 * harmless. Not on LuaJIT, which compiles `%` but not `fmod`.
 */
private fun FileTransformer.inlineRemainder(l: LuaExpr, r: LuaExpr): LuaExpr? {
    if (target == LuaTarget.LuaJIT || !isPureRead(l) || !isPureRead(r)) return null
    val fmod = LuaBinary(LuaBinOp.Add, LuaCall(lualibRef("Natives", "__K2L_Fmod"), listOf(l, r)), LuaNumber("0"))
    val nonZero = LuaBinary(LuaBinOp.Ne, r, LuaNumber("0"))
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, nonZero, fmod), lualibCall("IRem", l, r))
}
