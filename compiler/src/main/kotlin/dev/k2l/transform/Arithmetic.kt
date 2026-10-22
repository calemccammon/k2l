package dev.k2l.transform

import dev.k2l.codegen.*

// Arithmetic on numbers is Lua's own: Int, Long, Short, Byte, Double and Float are Lua numbers, and nothing wraps to 32 or
// 64 bits. What the types require is that `Int / Int` is an integer: floor division (`//`, or `math.floor(a / b)` before
// Lua 5.3), so a negative quotient rounds down. `%` is Lua's, whose result has the sign of the divisor.

private const val TWO_31 = "0x80000000"
private const val MASK_32 = "0xFFFFFFFF"

/** [value] reduced to the signed 32-bit range: for hash codes and bit patterns, not for arithmetic. */
internal fun FileTransformer.wrapInt32(value: LuaExpr): LuaExpr = if (target.hasIntegers) {
    // ((x + 2^31) & 0xFFFFFFFF) - 2^31
    LuaBinary(
        LuaBinOp.Sub,
        LuaBinary(LuaBinOp.BAnd, LuaBinary(LuaBinOp.Add, value, LuaNumber(TWO_31)), LuaNumber(MASK_32)),
        LuaNumber(TWO_31),
    )
} else {
    lualibCall("ToInt32", value)
}

/** `x + 1` / `x - 1` of `++` and `--`. */
internal fun stepped(op: LuaBinOp, read: LuaExpr): LuaExpr = LuaBinary(op, read, LuaNumber("1"))

/** `l / r` of integers: floor division. */
internal fun FileTransformer.floorDivision(l: LuaExpr, r: LuaExpr): LuaExpr =
    if (target.hasIntegers) LuaBinary(LuaBinOp.IDiv, l, r) else lua("math.floor", LuaBinary(LuaBinOp.Div, l, r))
