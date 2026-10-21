package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `a % c` and `a / c` by a positive integer literal, without `math.fmod` or `__K2L_IDiv` calls. Kotlin truncates toward
 * zero, Lua's `%` and `//` floor, which agree for a non-negative dividend:
 * - an `Int` (or `Short`, `Byte`): `a >= 0 and a % c or 0 - -a % c` (`-a` cannot overflow for 32-bit values, and `0 - x`
 *   is never -0 on float targets);
 * - a `Long` where it is a 64-bit integer (5.3/5.4): `a >= 0 and a % c or (a % c - c) % -c` and
 *   `a >= 0 and a // c or (a + (c - 1)) // c`, which do not negate `a` (`-Long.MIN_VALUE` overflows).
 * Null for other operands.
 */
internal fun FileTransformer.divisionByConstant(remainder: Boolean, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    val divisor = (r as? LuaNumber)?.text?.toLongOrNull()?.takeIf { it > 0 } ?: return null
    val wide = when {
        l is LuaNumber -> return null
        isNarrowInt(lt) && isNarrowInt(rt) -> false
        isWideDivision(lt, rt) -> true
        else -> return null
    }
    // read up to three times: a local, or a field of one, else cached
    val simple = l is LuaName || (l is LuaIndex && l.target is LuaName && l.key is LuaString)
    val a = if (simple) l else cache(l, "dividend")
    val positive = when {
        remainder -> LuaBinary(LuaBinOp.Mod, a, r)
        target.hasIntegers -> LuaBinary(LuaBinOp.IDiv, a, r)
        else -> floor(LuaBinary(LuaBinOp.Div, a, r))
    }
    val negative = if (wide) wideNegative(remainder, a, r, divisor) else narrowNegative(remainder, a, r)
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Ge, a, LuaNumber("0")), positive), negative)
}

private fun FileTransformer.isNarrowInt(t: KaType?): Boolean = with(session) {
    t != null && t.withoutFlexibility.let { it.isIntType || it.isShortType || it.isByteType }
}

/** A Long divided by an Int or Long, where Longs are 64-bit integers. */
private fun FileTransformer.isWideDivision(lt: KaType?, rt: KaType?): Boolean = with(session) {
    val long = lt?.withoutFlexibility?.isLongType == true && (isNarrowInt(rt) || rt?.withoutFlexibility?.isLongType == true)
    long && target.hasIntegers && !emulatesLong
}

private fun FileTransformer.narrowNegative(remainder: Boolean, a: LuaExpr, r: LuaExpr): LuaExpr {
    val negated = LuaUnary(LuaUnOp.Neg, a)
    val value = when {
        remainder -> LuaBinary(LuaBinOp.Mod, negated, r)
        target.hasIntegers -> LuaBinary(LuaBinOp.IDiv, negated, r)
        else -> floor(LuaBinary(LuaBinOp.Div, negated, r))
    }
    return LuaBinary(LuaBinOp.Sub, LuaNumber("0"), value)
}

private fun wideNegative(remainder: Boolean, a: LuaExpr, r: LuaExpr, divisor: Long): LuaExpr = if (remainder) {
    LuaBinary(LuaBinOp.Mod, LuaBinary(LuaBinOp.Sub, LuaBinary(LuaBinOp.Mod, a, r), r), LuaNumber("-$divisor"))
} else {
    LuaBinary(LuaBinOp.IDiv, LuaBinary(LuaBinOp.Add, a, LuaNumber("${divisor - 1}")), r)
}

private fun floor(x: LuaExpr): LuaExpr = lua("math.floor", x)
