package dev.k2l.transform

import com.intellij.psi.tree.IElementType
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

// Binary, prefix and postfix operators on primitives: arithmetic, comparisons, concatenation and the logical operators.

private val ARITHMETIC: Set<IElementType> = setOf(KtTokens.PLUS, KtTokens.MINUS, KtTokens.MUL, KtTokens.DIV, KtTokens.PERC)

private val BINARY_OPERATORS: Map<IElementType, LuaBinOp> = mapOf(
    KtTokens.PLUS to LuaBinOp.Add, KtTokens.MINUS to LuaBinOp.Sub, KtTokens.MUL to LuaBinOp.Mul,
    KtTokens.DIV to LuaBinOp.Div, KtTokens.PERC to LuaBinOp.Mod,
    KtTokens.EQEQEQ to LuaBinOp.Eq, KtTokens.EXCLEQEQEQ to LuaBinOp.Ne,
    KtTokens.LT to LuaBinOp.Lt, KtTokens.GT to LuaBinOp.Gt, KtTokens.LTEQ to LuaBinOp.Le, KtTokens.GTEQ to LuaBinOp.Ge,
)

internal fun FileTransformer.binary(e: KtBinaryExpression): LuaExpr = with(session) {
    val token = e.operationToken
    val left = e.left ?: return LuaNil
    val right = e.right ?: return LuaNil
    return when (token) {
        KtTokens.ELVIS -> elvis(left, right)

        KtTokens.ANDAND -> shortCircuit(LuaBinOp.And, expression(left)) { expression(right) }

        KtTokens.OROR -> shortCircuit(LuaBinOp.Or, expression(left)) { expression(right) }

        KtTokens.IN_KEYWORD, KtTokens.NOT_IN -> {
            val range = parseRange(right)
            val contains = if (range != null) rangeContains(left, range) else call(e, e)
            if (token == KtTokens.NOT_IN) negate(contains) else contains
        }

        KtTokens.RANGE, KtTokens.RANGE_UNTIL -> call(e, e)

        KtTokens.IDENTIFIER -> call(e, e)

        KtTokens.EQEQ, KtTokens.EXCLEQ -> {
            val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
            byteComparison(equality(l, left.expressionType, r, right.expressionType, negated = token == KtTokens.EXCLEQ))
        }

        in BINARY_OPERATORS -> {
            if (token in ARITHMETIC && callsOperator(e, left, right)) return call(e, e)
            val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
            operator(BINARY_OPERATORS.getValue(token), l, left.expressionType, r, right.expressionType, e)
        }

        else -> unsupported(e, "Operator '${e.operationReference.text}'")
    }
}

/**
 * An arithmetic operator that is a call: `operator fun plus` etc., including extensions such as Int.times(String).
 */
private fun FileTransformer.callsOperator(e: KtBinaryExpression, left: KtExpression, right: KtExpression): Boolean = with(session) {
    val numberOperator = left.expressionType?.isNumber == true && !isPrimitiveOperand(right.expressionType)
    return !isPrimitiveOperand(left.expressionType) || numberOperator || isSourceOperator(e)
}

/** `left op right` for `and`/`or`, keeping [right]'s preceding statements behind the short circuit. */
internal fun FileTransformer.shortCircuit(op: LuaBinOp, left: LuaExpr, right: () -> LuaExpr): LuaExpr {
    val (r, pre) = withPreceding(right)
    if (pre.isEmpty()) return LuaBinary(op, left, r)
    val name = ctx.temp("cond")
    emit(LuaLocal(listOf(name), listOf(left)))
    val test = if (op == LuaBinOp.And) LuaName(name) else LuaUnary(LuaUnOp.Not, LuaName(name))
    emit(LuaIf(test, pre + assign(name, r)))
    return LuaName(name)
}

/**
 * A Kotlin operator applied to primitive/String operands. [op] is the Lua operator the Kotlin token
 * maps to: Lua's arithmetic, except that `/` of integers is floor division (see Arithmetic.kt).
 */
internal fun FileTransformer.operator(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, element: KtElement): LuaExpr =
    with(session) {
        val numeric = both(lt, rt) { it.isNumber }
        return charArithmetic(op, l, lt, r, rt) ?: when (op) {
            LuaBinOp.Add -> when {
                lt?.isStringType == true -> LuaBinary(LuaBinOp.Concat, str(l, lt, forConcat = true), str(r, rt, forConcat = true))
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'+' on '${lt.pretty()}'")
            }

            LuaBinOp.Sub, LuaBinOp.Mul ->
                if (numeric) LuaBinary(op, l, r) else unsupported(element, "Arithmetic on '${lt.pretty()}'")

            LuaBinOp.Div -> when {
                numeric && both(lt, rt) { it.isIntegral } -> floorDivision(l, r)
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'/' on '${lt.pretty()}'")
            }

            LuaBinOp.Mod -> if (numeric) LuaBinary(op, l, r) else unsupported(element, "'%' on '${lt.pretty()}'")

            LuaBinOp.Eq, LuaBinOp.Ne -> LuaBinary(op, l, r)

            LuaBinOp.Lt, LuaBinOp.Gt, LuaBinOp.Le, LuaBinOp.Ge ->
                if (numeric || comparesNatively(lt, rt)) {
                    LuaBinary(op, l, r)
                } else {
                    LuaBinary(op, lualibCall("Compare", l, r), LuaNumber("0"))
                }

            // Comparable.compareTo
            else -> LuaBinary(op, l, r)
        }
    }

/** Texts (Strings and Chars) compare with Lua's `<`, which orders bytes. */
internal fun FileTransformer.comparesNatively(lt: KaType?, rt: KaType?): Boolean = with(session) { lt.isTextual && rt.isTextual }

private fun FileTransformer.both(lt: KaType?, rt: KaType?, test: (KaType) -> Boolean) = listOfNotNull(lt, rt).let {
    it.size == 2 &&
        it.all(test)
}

/** Chars are one-character strings: 'c' - 'a' is an Int, 'a' + 1 is a Char. */
private fun FileTransformer.charArithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? = with(session) {
    val addOrSub = op == LuaBinOp.Add || op == LuaBinOp.Sub
    if (lt?.isCharType != true || lt.isMarkedNullable || !addOrSub) return null
    if (op == LuaBinOp.Add && rt?.isStringType == true) return LuaBinary(LuaBinOp.Concat, l, r) // 'a' + "bc" is a String
    val code = LuaMethodCall(l, "byte", emptyList())
    return if (rt?.isCharType == true) {
        LuaBinary(LuaBinOp.Sub, code, LuaMethodCall(r, "byte", emptyList()))
    } else {
        lua("string.char", LuaBinary(op, code, r))
    }
}

internal fun FileTransformer.prefix(e: KtPrefixExpression): LuaExpr = with(session) {
    val base = e.baseExpression ?: return LuaNil
    return when (e.operationToken) {
        KtTokens.MINUS, KtTokens.PLUS, KtTokens.EXCL ->
            if (isPrimitiveOperand(base.expressionType) && !isSourceOperator(e)) primitivePrefix(e, base) else call(e, e)

        KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
            val target = assignTarget(base) ?: return LuaNil
            increment(e, target)
            target.read
        }

        else -> unsupported(e, "Prefix operator '${e.operationReference.text}'")
    }
}

/** Whether an operator expression calls an `operator fun` of this program, e.g. an extension `Int.times(String)`. */
private fun FileTransformer.isSourceOperator(e: KtExpression): Boolean = with(session) {
    e.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol?.psi.let { it is KtNamedFunction && classes.isSource(it) }
}

private fun FileTransformer.primitivePrefix(e: KtPrefixExpression, base: KtExpression): LuaExpr = with(session) {
    negativeLiteral(e, base)
        ?: when (e.operationToken) {
            KtTokens.MINUS -> LuaUnary(LuaUnOp.Neg, expression(base))
            KtTokens.PLUS -> expression(base)
            else -> negate(expression(base))
        }
}

/**
 * `-2147483648` and `-9223372036854775808` (and -128 and -32768 as a Byte or Short): the literal after the minus does not
 * fit its type and evaluates to the negative value already, so the whole expression is the literal (negating it again
 * would give +2147483648).
 */
private fun FileTransformer.negativeLiteral(e: KtPrefixExpression, base: KtExpression): LuaExpr? = with(session) {
    if (e.operationToken != KtTokens.MINUS || base !is KtConstantExpression) return null
    return when (val v = e.evaluate()) {
        is KaConstantValue.IntValue -> v.value.takeIf { it == Int.MIN_VALUE }?.let { constantValue(v, e) }

        is KaConstantValue.LongValue -> v.value.takeIf { it == Long.MIN_VALUE }?.let { constantValue(v, e) }

        // byteArrayOf(-128), shortArrayOf(-32768)
        is KaConstantValue.ByteValue -> v.value.takeIf { it == Byte.MIN_VALUE }?.let { constantValue(v, e) }

        is KaConstantValue.ShortValue -> v.value.takeIf { it == Short.MIN_VALUE }?.let { constantValue(v, e) }

        else -> null
    }
}

internal fun FileTransformer.postfix(e: KtPostfixExpression): LuaExpr = with(session) {
    val base = e.baseExpression ?: return LuaNil
    return when (e.operationToken) {
        KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
            val target = assignTarget(base) ?: return LuaNil
            val old = ctx.temp("old")
            emit(LuaLocal(listOf(old), listOf(target.read)))
            increment(e, target)
            LuaName(old)
        }

        KtTokens.EXCLEXCL -> lualibCall("NotNull", expression(base))

        else -> unsupported(e, "Postfix operator '${e.operationReference.text}'")
    }
}
