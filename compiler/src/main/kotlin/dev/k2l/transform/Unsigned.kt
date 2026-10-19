package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `UByte`, `UShort`, `UInt` and `ULong` are Lua numbers holding the unsigned value. The first three are always in
 * range and wrap like the JVM (`(a + b) & 0xFFFFFFFF`, or `% 2^32` before Lua 5.3), whatever `--int-overflow` says.
 * A `ULong` is a Lua integer holding the 64-bit pattern on 5.3/5.4 (so values from 2^63 look negative to anything
 * that does not know the static type: comparison uses `math.ult`, division and printing use [UnsignedMappings]'
 * helpers). On the other targets a `ULong` is a double and is exact only up to 2^53.
 */
internal enum class Unsigned(val bits: Int) {
    UByte(8),
    UShort(16),
    UInt(32),
    ULong(64),
}

private const val BITS_PER_HEX_DIGIT = 4
private const val HIGH_BIT = 63
private const val HEX = 16
private const val TWO_64 = "18446744073709551616"

internal fun KaSession.unsignedOf(t: KaType?): Unsigned? {
    val x = t?.withoutFlexibility ?: return null
    return when {
        x.isMarkedNullable -> null
        x.isUIntType -> Unsigned.UInt
        x.isULongType -> Unsigned.ULong
        x.isUByteType -> Unsigned.UByte
        x.isUShortType -> Unsigned.UShort
        else -> null
    }
}

/** The type of `lt op rt` when both operands are unsigned: `ULong` if either is, else `UInt` (`UByte + UByte` is `UInt`). */
private fun FileTransformer.unsignedResult(lt: KaType?, rt: KaType?): Unsigned? = with(session) {
    val l = unsignedOf(lt)
    val r = unsignedOf(rt)
    when {
        l == null || r == null -> null
        l == Unsigned.ULong || r == Unsigned.ULong -> Unsigned.ULong
        else -> Unsigned.UInt
    }
}

/** [e] reduced to the range of [kind]. */
internal fun FileTransformer.wrapUnsigned(kind: Unsigned, e: LuaExpr): LuaExpr = when {
    kind == Unsigned.ULong -> if (target.hasIntegers) e else LuaBinary(LuaBinOp.Mod, e, LuaNumber(TWO_64))
    target.hasIntegers -> LuaBinary(LuaBinOp.BAnd, e, LuaNumber("0x" + "F".repeat(kind.bits / BITS_PER_HEX_DIGIT)))
    else -> LuaBinary(LuaBinOp.Mod, e, LuaNumber((1L shl kind.bits).toString()))
}

/** `l op r` for `+`, `-` and `*` of unsigned operands, or null if they are not. */
internal fun FileTransformer.unsignedArithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    val kind = unsignedResult(lt, rt) ?: return null
    // a product of two 32-bit values can exceed 2^53
    val raw = if (op == LuaBinOp.Mul && kind != Unsigned.ULong && !target.hasIntegers) lualibCall("IMul", l, r) else LuaBinary(op, l, r)
    return wrapUnsigned(kind, raw)
}

/** `read + 1` / `read - 1` of an unsigned [type], or null when it is not one. */
internal fun FileTransformer.unsignedStep(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr? {
    val kind = with(session) { unsignedOf(type) } ?: return null
    return wrapUnsigned(kind, LuaBinary(op, read, LuaNumber("1")))
}

private fun FileTransformer.involvesULong(lt: KaType?, rt: KaType?): Boolean =
    with(session) { unsignedOf(lt) == Unsigned.ULong || unsignedOf(rt) == Unsigned.ULong }

/** Division and remainder of a `ULong` (5.3/5.4): values from 2^63 are negative Lua integers. */
internal fun FileTransformer.unsignedLongDivision(remainder: Boolean, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? =
    if (target.hasIntegers && involvesULong(lt, rt)) {
        LuaCall(LuaIndex(lualibRef("Unsigned", "__K2L_Unsigned"), LuaString(if (remainder) "urem" else "udiv")), listOf(l, r))
    } else {
        null
    }

/** `l < r` and friends for a `ULong` (5.3/5.4): `math.ult`. */
internal fun FileTransformer.unsignedLongComparison(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    if (!target.hasIntegers || !involvesULong(lt, rt)) return null
    fun ult(a: LuaExpr, b: LuaExpr) = luaCall(luaPath("math", "ult"), a, b)
    return when (op) {
        LuaBinOp.Lt -> ult(l, r)
        LuaBinOp.Gt -> ult(r, l)
        LuaBinOp.Le -> LuaUnary(LuaUnOp.Not, ult(r, l))
        LuaBinOp.Ge -> LuaUnary(LuaUnOp.Not, ult(l, r))
        else -> null
    }
}

/** The Lua literal for an unsigned constant; 64-bit values from 2^63 are hexadecimal so that Lua 5.3+ wraps them. */
internal fun FileTransformer.unsignedLiteral(value: ULong): LuaExpr =
    if (target.hasIntegers && value >= (1uL shl HIGH_BIT)) LuaNumber("0x" + value.toString(HEX)) else LuaNumber(value.toString())
