package dev.k2l.transform

import dev.k2l.LuaTarget
import dev.k2l.codegen.*

/** `bit.tobit(x)` gives the 32-bit wrap of any integral `x` with `|x| < 2^51` (it adds 2^52 + 2^51 to read the low bits). */
private const val TOBIT_BITS = 51
private const val INT_BITS = 32
private const val HALF = 65536L
private const val LONG_BITS = 64

private fun tobit(x: LuaExpr): LuaExpr = lua("bit.tobit", x)

/**
 * On LuaJIT, `--int-overflow wrap` of [value] as `bit.tobit(value)` (compiled to one instruction, where `__K2L_ToInt32`
 * is a call with a floored modulo) when [value] is provably below 2^51 in magnitude; null otherwise.
 */
internal fun FileTransformer.jitWrap(value: LuaExpr): LuaExpr? =
    if (target.compilesBitOps && magnitudeBits(value) <= TOBIT_BITS) tobit(value) else null

/**
 * On LuaJIT, `a * c` of Ints with a constant `c` (either side), wrapped: `tobit(a * lo + tobit(a * hi) * 65536)` with
 * `c = hi * 65536 + lo` (`0 <= lo < 65536`): every partial result is below 2^48. Null otherwise.
 */
internal fun FileTransformer.jitMultiply(l: LuaExpr, r: LuaExpr): LuaExpr? {
    if (!target.compilesBitOps) return null
    val (value, constant) = constantOf(r)?.let { l to it } ?: constantOf(l)?.let { r to it } ?: return null
    val lo = Math.floorMod(constant, HALF)
    val hi = (constant - lo) / HALF
    val low = LuaBinary(LuaBinOp.Mul, value, LuaNumber(lo.toString()))
    val high = LuaBinary(LuaBinOp.Mul, tobit(LuaBinary(LuaBinOp.Mul, value, LuaNumber(hi.toString()))), LuaNumber(HALF.toString()))
    return tobit(LuaBinary(LuaBinOp.Add, low, high))
}

private val ZERO = LuaNumber("0")

private fun constantOf(e: LuaExpr): Long? = (e as? LuaNumber)?.text?.toLongOrNull()?.takeIf { it in Int.MIN_VALUE..Int.MAX_VALUE }

/**
 * An upper bound of `log2 |e|` for the Int arithmetic [wrapInt32] wraps: leaves are Int values (32 bits) or literals,
 * sums add a bit, products add their operands' bits.
 */
private fun magnitudeBits(e: LuaExpr): Int = when (e) {
    is LuaNumber -> e.text.toLongOrNull()?.let { if (it == 0L) 0 else LONG_BITS - java.lang.Long.numberOfLeadingZeros(Math.abs(it)) }
        ?: Int.MAX_VALUE / 2

    is LuaBinary -> when (e.op) {
        // `0 - x` (a negation) and `x * y + 0` (see integralArithmetic) are no larger than x and the product
        LuaBinOp.Add, LuaBinOp.Sub -> if (e.left == ZERO || e.right == ZERO) {
            maxOf(magnitudeBits(e.left), magnitudeBits(e.right))
        } else {
            maxOf(magnitudeBits(e.left), magnitudeBits(e.right)) + 1
        }

        LuaBinOp.Mul -> magnitudeBits(e.left) + magnitudeBits(e.right)

        else -> INT_BITS
    }

    is LuaUnary -> if (e.op == LuaUnOp.Neg) magnitudeBits(e.operand) else INT_BITS

    else -> INT_BITS
}
