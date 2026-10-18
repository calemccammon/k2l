package dev.k2l.transform

import dev.k2l.IntOverflow
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
        lualibCall("ToInt32", value)
    }
    ctx.int32Pending[wrapped] = value
    return wrapped
}

/** The unwrapped sum or product inside [e] when it is a [wrapInt32] result of this file, else [e]. */
private fun FileTransformer.unwrapInt32(e: LuaExpr): LuaExpr = ctx.int32Pending[e] ?: e

/** `l op r` for `+`, `-` and `*`, wrapped to 32 bits when both operands are `Int`-like and wrapping is on. */
internal fun FileTransformer.arithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr {
    if (!isInt32Arithmetic(lt, rt)) return LuaBinary(op, l, r)
    if (op == LuaBinOp.Mul && !target.hasIntegers) {
        val small = listOf(l, r).any { (it as? LuaNumber)?.text?.toLongOrNull()?.let { n -> n in -SMALL_FACTOR..SMALL_FACTOR } == true }
        return if (small) wrapInt32(LuaBinary(op, l, r)) else lualibCall("IMul", l, r)
    }
    return wrapInt32(LuaBinary(op, unwrapInt32(l), unwrapInt32(r)))
}

internal fun FileTransformer.negation(value: LuaExpr, type: KaType?): LuaExpr {
    val wrap = wrapsInt && with(session) { isInt32(type) } && value !is LuaNumber
    return if (wrap) wrapInt32(LuaUnary(LuaUnOp.Neg, unwrapInt32(value))) else LuaUnary(LuaUnOp.Neg, value)
}

/** `x + 1` / `x - 1` of `++` and `--`: wrapped to 32 bits for `Int`, to 16 or 8 bits for `Short` and `Byte`. */
internal fun FileTransformer.stepped(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr {
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

/** `a % b`: `math.fmod`, or `__K2L_IRem` (which throws on zero) for integers whose divisor is not a nonzero literal. */
internal fun FileTransformer.remainder(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr {
    val integral = with(session) { lt != null && rt != null && lt.isIntegral && rt.isIntegral }
    val literal = (r as? LuaNumber)?.text?.toDoubleOrNull()?.let { it != 0.0 } == true
    return if (integral && !literal) lualibCall("IRem", l, r) else luaCall(luaPath("math", "fmod"), l, r)
}
