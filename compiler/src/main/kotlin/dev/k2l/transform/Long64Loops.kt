package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtForExpression
import org.jetbrains.kotlin.psi.KtParameter

/** The wide type of the bounds or step of [range] (`Long` or `ULong`), or null when none of them is wide. */
internal fun FileTransformer.wideRangeType(range: KRange): KaType? = with(session) {
    listOfNotNull(range.first, range.last, range.step).map { it.expressionType }.firstOrNull { isWide(it) }
}

/** `for (i in range)` over a `LongRange` held in a value: the same counting loop, with the bounds read from the object. */
internal fun FileTransformer.long64RangeObjectLoop(e: KtForExpression, frame: LoopFrame, param: KtParameter, range: LuaExpr): Unit =
    with(session) {
        val first = ctx.temp("first")
        val count = ctx.temp("count")
        val step = ctx.temp("step")
        val k = ctx.temp("k")
        emit(LuaLocal(listOf(first, count, step), listOf(l64x("rangeOf", range))))
        val value = l64("Add", LuaName(first), l64("Mul", LuaName(k), LuaName(step)))
        val variable = LuaLocal(listOf(naming.of(param)), listOf(value))
        val limit = LuaBinary(LuaBinOp.Sub, LuaName(count), LuaNumber("1"))
        emit(LuaNumericFor(k, LuaNumber("0"), limit, null, listOf(variable) + loopBody(frame, e.body)))
    }

/**
 * `for (i in a..b)` over `Long`s or `ULong`s with `--long64 emulate`. A numeric `for` cannot count boxes, so the loop
 * counts iterations: `__K2L_Long64X.range` returns the first value and the number of elements (clamped to 2^53, which no
 * loop reaches), and the loop variable is `first + k * step`. With numbers on both ends that is plain arithmetic.
 */
internal fun FileTransformer.long64RangeLoop(e: KtForExpression, frame: LoopFrame, param: KtParameter, range: KRange, wide: KaType): Unit =
    with(session) {
        val values = ordered(listOfNotNull(range.first, range.last, range.step))
        val first = ctx.temp("first")
        val count = ctx.temp("count")
        val k = ctx.temp("k")
        val step = values.getOrNull(2)?.let { cache(it, "step") }
        val flags = listOf(range.inclusive, range.descending, isULongType(wide)).map { LuaBool(it) }
        val call = l64x("range", values[0], values[1], step ?: LuaNil, *flags.toTypedArray())
        emit(LuaLocal(listOf(first, count), listOf(call)))
        val op = if (range.descending) LuaBinOp.Sub else LuaBinOp.Add
        val value = if (step == null) {
            LuaBinary(op, LuaName(first), LuaName(k))
        } else {
            l64(if (range.descending) "Sub" else "Add", LuaName(first), l64("Mul", LuaName(k), step))
        }
        val variable = LuaLocal(listOf(naming.of(param)), listOf(value))
        val limit = LuaBinary(LuaBinOp.Sub, LuaName(count), LuaNumber("1"))
        emit(LuaNumericFor(k, LuaNumber("0"), limit, null, listOf(variable) + loopBody(frame, e.body)))
    }
