package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.psi.*

// Compile-time constants as Lua literals.

/** A compile-time constant as a Lua literal; [e] is where an unsupported one is reported. */
internal fun FileTransformer.constantValue(c: KaConstantValue?, e: KtElement): LuaExpr = when (c) {
    is KaConstantValue.IntValue -> LuaNumber(c.value.toString())

    // 9223372036854775808 does not fit a Lua integer, so Long.MIN_VALUE is spelled as a subtraction
    is KaConstantValue.LongValue ->
        if (emulatesLong) {
            long64Literal(c.value)
        } else if (c.value == Long.MIN_VALUE) {
            LuaBinary(LuaBinOp.Sub, LuaNumber("-9223372036854775807"), LuaNumber("1"))
        } else {
            LuaNumber(c.value.toString())
        }

    is KaConstantValue.ShortValue -> LuaNumber(c.value.toString())

    is KaConstantValue.ByteValue -> LuaNumber(c.value.toString())

    is KaConstantValue.DoubleValue -> floatingLiteral(c.value)

    is KaConstantValue.FloatValue -> floatingLiteral(c.value.toDouble())

    is KaConstantValue.UIntValue -> unsignedLiteral(c.value.toULong())

    is KaConstantValue.ULongValue -> unsignedLiteral(c.value)

    is KaConstantValue.UShortValue -> unsignedLiteral(c.value.toULong())

    is KaConstantValue.UByteValue -> unsignedLiteral(c.value.toULong())

    is KaConstantValue.BooleanValue -> LuaBool(c.value)

    is KaConstantValue.CharValue -> LuaString(c.value.toString())

    is KaConstantValue.StringValue -> LuaString(c.value)

    is KaConstantValue.NullValue -> LuaNil

    null -> unsupported(e, "Non-constant literal")

    else -> unsupported(e, "Constant of type ${c.javaClass.simpleName}")
}

/** Lua 5.1 merges the constants 0.0 and -0.0 of a function, so a negative zero is computed there. */
internal fun FileTransformer.floatingLiteral(d: Double): LuaExpr = if (target.mergesSignedZeros && d == 0.0 && 1 / d < 0) {
    LuaBinary(LuaBinOp.Div, LuaNumber("1"), LuaUnary(LuaUnOp.Neg, luaPath("math", "huge")))
} else {
    doubleLiteral(d)
}

internal fun FileTransformer.constant(e: KtExpression): LuaExpr = with(session) {
    constantValue(e.evaluate(), e)
}
