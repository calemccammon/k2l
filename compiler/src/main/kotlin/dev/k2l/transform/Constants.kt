package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

// Compile-time constants as Lua literals.

/** A compile-time constant as a Lua literal; [e] is where an unsupported one is reported. */
internal fun FileTransformer.constantValue(c: KaConstantValue?, e: KtElement): LuaExpr = when (c) {
    is KaConstantValue.IntValue -> LuaNumber(c.value.toString())

    // 9223372036854775808 does not fit a Lua integer, so Long.MIN_VALUE is spelled as a subtraction
    is KaConstantValue.LongValue ->
        if (c.value == Long.MIN_VALUE) {
            LuaBinary(LuaBinOp.Sub, LuaNumber("-9223372036854775807"), LuaNumber("1"))
        } else {
            LuaNumber(c.value.toString())
        }

    is KaConstantValue.ShortValue -> LuaNumber(c.value.toString())

    is KaConstantValue.ByteValue -> LuaNumber(c.value.toString())

    is KaConstantValue.DoubleValue -> doubleLiteral(c.value)

    // a Float is a Lua number like a Double: `0.1f` is the literal 0.1, not the double value of the float
    is KaConstantValue.FloatValue -> doubleLiteral(c.value.toString().toDouble())

    is KaConstantValue.BooleanValue -> LuaBool(c.value)

    is KaConstantValue.CharValue -> LuaString(c.value.toString())

    is KaConstantValue.StringValue -> LuaString(c.value)

    is KaConstantValue.NullValue -> LuaNil

    null -> unsupported(e, "Non-constant literal")

    else -> unsupported(e, "Constant of type ${c.javaClass.simpleName}")
}

internal fun FileTransformer.constant(e: KtExpression): LuaExpr = with(session) {
    constantValue(e.evaluate(), e)
}

/** The initializer of a `const val`, which is written as its value: `const val B = A / 2` is `B = 10`. */
internal fun isConstInitializer(e: KtExpression): Boolean {
    val p = generateSequence(e.parent) { it.parent }.firstOrNull { it !is KtParenthesizedExpression } as? KtProperty ?: return false
    return p.hasModifier(KtTokens.CONST_KEYWORD) && p.initializer?.let { KtPsiUtil.safeDeparenthesize(it) } === e
}
