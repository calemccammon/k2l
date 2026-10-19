package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/** `x in range` with a range expression: as in Kotlin, the operands of the range are evaluated before `x`. */
internal fun FileTransformer.rangeContains(value: KtExpression, range: KRange): LuaExpr = with(session) {
    val values = ordered(rangeOperands(range) + value)
    return containsValue(values.last(), range, boundValues(values.dropLast(1)))
}

/** `in range` as a `when` condition, testing the [subject] (evaluated already). */
internal fun FileTransformer.rangeContains(subject: LuaExpr, range: KRange): LuaExpr = with(session) {
    containsValue(subject, range, boundValues(ordered(rangeOperands(range))))
}

private fun rangeOperands(range: KRange) = listOfNotNull(range.first, range.last, range.step)

/** The comparisons may skip a bound or read it twice, so bounds that call something are kept in locals. */
private fun FileTransformer.boundValues(values: List<LuaExpr>) = values.map { if (hasCall(it)) cache(it, "bound") else it }

private fun hasCall(e: LuaExpr): Boolean = when (e) {
    is LuaCall, is LuaMethodCall -> true
    is LuaIndex -> hasCall(e.target) || hasCall(e.key)
    is LuaBinary -> hasCall(e.left) || hasCall(e.right)
    is LuaUnary -> hasCall(e.operand)
    else -> false
}

/** Between the bounds, and for a stepped range one of the elements it reaches. */
private fun FileTransformer.containsValue(value: LuaExpr, range: KRange, operands: List<LuaExpr>): LuaExpr {
    if (range.step != null) return steppedRangeContains(value, range, operands)
    return rangeBounds(cache(value, "value"), operands[0], operands[1], range)
}

private fun FileTransformer.rangeBounds(x: LuaExpr, first: LuaExpr, last: LuaExpr, range: KRange): LuaExpr {
    val lo = if (range.descending) last else first
    val hi = if (range.descending) first else last
    val upperOp = if (range.inclusive) LuaBinOp.Le else LuaBinOp.Lt
    return LuaBinary(LuaBinOp.And, compare(LuaBinOp.Ge, x, lo, range), compare(upperOp, x, hi, range))
}

/** `l op r` on elements of [range]: boxes with `--long64 emulate`, `math.ult` for a `ULong` on 5.3/5.4. */
private fun FileTransformer.compare(op: LuaBinOp, l: LuaExpr, r: LuaExpr, range: KRange): LuaExpr {
    val wide = if (emulatesLong) wideRangeType(range) else null
    if (wide != null) return long64Comparison(op, l, wide, r, wide)!!
    val type = with(session) { range.first.expressionType }
    // a range of Comparable objects (`e in Level.LOW..Level.HIGH`, `"b" in "a".."c"` with `--strings utf16`) calls compareTo
    if (type != null && with(session) { !type.isNumber && !comparesNatively(type, type) }) {
        return LuaBinary(op, lualibCall("Compare", l, r), LuaNumber("0"))
    }
    return unsignedLongComparison(op, l, type, r, type) ?: LuaBinary(op, l, r)
}

/**
 * `x in a..b step s` (also `downTo` and `until`): within the bounds and a whole number of steps from the first element,
 * so a value past the progression's last element is not in it. A step that is not a positive constant is checked the
 * way `step` checks it (`IllegalArgumentException`); Char ranges compare codes.
 */
private fun FileTransformer.steppedRangeContains(value: LuaExpr, range: KRange, operands: List<LuaExpr>): LuaExpr = with(session) {
    val elementType = range.first.expressionType
    val isChar = elementType?.isCharType == true
    val first = cache(if (isChar) charCode(operands[0]) else operands[0], "first")
    val last = if (isChar) charCode(operands[1]) else operands[1]
    // the progression is created (and its step checked) before `x` is evaluated
    val step = cache(checkedStep(range.step!!, operands[2]), "step")
    val x = cache(if (isChar) charCode(value) else value, "value")
    val (from, to) = if (range.descending) first to x else x to first
    val wide = if (emulatesLong) wideRangeType(range) else null
    // a ULong difference is the right bit pattern even when it wraps, and its remainder is unsigned
    val remainder = when {
        wide != null && isULongType(wide) -> l64Member("urem", l64("Sub", from, to), step)

        wide != null -> l64("Rem", l64("Sub", from, to), step)

        else -> LuaBinary(LuaBinOp.Sub, from, to).let {
            unsignedLongDivision(true, it, elementType, step, elementType)
                ?: LuaBinary(LuaBinOp.Mod, it, step)
        }
    }
    return LuaBinary(LuaBinOp.And, rangeBounds(x, first, last, range), LuaBinary(LuaBinOp.Eq, remainder, LuaNumber("0")))
}

/** [value] of the step [e], checked to be positive (as `step` does) unless it is a positive constant. */
internal fun FileTransformer.checkedStep(e: KtExpression, value: LuaExpr): LuaExpr = with(session) {
    val positive = (e.evaluate()?.value as? Number)?.let { it.toLong() > 0 } == true
    if (positive) value else lualibCall("CheckStep", value)
}
