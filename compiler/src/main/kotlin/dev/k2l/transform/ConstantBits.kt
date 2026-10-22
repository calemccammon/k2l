package dev.k2l.transform

import dev.k2l.LuaTarget
import dev.k2l.codegen.*

private const val INT_SHIFTS = 31
private const val LONG_SHIFTS = 52
private const val TWO_32 = "4294967296"

/**
 * Bitwise operations with a constant operand where numbers are doubles, as arithmetic instead of the bit helpers (a call,
 * and on Lua 5.1 a loop over the bits): `x and (2^k - 1)` is `x % 2^k` (a floored modulo keeps the low bits of a
 * two's-complement value), `x shr n` is `floor(x / 2^n)` and an Int's `x ushr n` is `floor(x % 2^32 / 2^n)`. Exact for
 * Ints and for Longs below 2^53 (beyond that a Long held in a double has lost its low bits anyway). Ints keep LuaJIT's
 * native `bit` operations; Longs there are doubles, so they use these too. Null when not applicable.
 */
internal object ConstantBits {
    private fun CallSite.applies(isLong: Boolean): Boolean {
        if (hasIntegers) return false
        return isLong || !target.compilesBitOps
    }

    private fun constant(e: LuaExpr): Long? = (e as? LuaNumber)?.text?.toLongOrNull()

    /** `x and m` with `m = 2^k - 1` (either operand). */
    fun mask(site: CallSite, isLong: Boolean): LuaExpr? = with(site) {
        if (!applies(isLong)) return null
        val limit = if (isLong) LONG_SHIFTS else INT_SHIFTS
        val (value, m) = constant(arg(0))?.let { self to it } ?: constant(self)?.let { arg(0) to it } ?: return null
        val k = java.lang.Long.numberOfTrailingZeros(m + 1)
        if (m <= 0 || (m + 1) != 1L shl k || k > limit) return null
        LuaBinary(LuaBinOp.Mod, value, LuaNumber((m + 1).toString()))
    }

    /**
     * An Int's `x shl n`, `x shr n` and `x ushr n` on 5.3/5.4 with a constant `n` (0..31; 1..31 for `ushr`), as the
     * operators `Bit.lua` applies: `x << n` wrapped to 32 bits, `x // 2^n`, `(x & 0xFFFFFFFF) >> n`.
     */
    fun integerShift(site: CallSite, name: String): LuaExpr? = with(site) {
        val n = constant(arg(0)) ?: return null
        val lowest = if (name == "ushr") 1 else 0
        if (!hasIntegers || n < lowest || n > INT_SHIFTS) return null
        when (name) {
            "shl" -> transformer.wrapInt32(LuaBinary(LuaBinOp.Shl, self, arg(0)))
            "shr" -> LuaBinary(LuaBinOp.IDiv, self, LuaNumber((1L shl n.toInt()).toString()))
            else -> LuaBinary(LuaBinOp.Shr, LuaBinary(LuaBinOp.BAnd, self, LuaNumber("0xFFFFFFFF")), arg(0))
        }
    }

    /** `x shr n` and, for an Int, `x ushr n` with a constant `n` (1..31, or 1..52 for a Long's `shr`). */
    fun shift(site: CallSite, isLong: Boolean, unsigned: Boolean): LuaExpr? = with(site) {
        if (!applies(isLong) || (isLong && unsigned)) return null
        val n = constant(arg(0)) ?: return null
        if (n < 1 || n > if (isLong) LONG_SHIFTS else INT_SHIFTS) return null
        val value = if (unsigned) LuaBinary(LuaBinOp.Mod, self, LuaNumber(TWO_32)) else self
        lua("math.floor", LuaBinary(LuaBinOp.Div, value, LuaNumber((1L shl n.toInt()).toString())))
    }
}
