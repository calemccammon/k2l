package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/**
 * The loop a `break` or `continue` targets: the innermost one (with its label) around it, also outside the lambdas it is
 * written in, but not outside a function.
 */
private fun FileTransformer.jumpTarget(e: KtExpressionWithLabel): LoopFrame? {
    val label = e.getLabelName()
    fun find(stack: ArrayDeque<LoopFrame>) = if (label != null) stack.lastOrNull { it.label == label } else stack.lastOrNull()
    var stack = loops
    var found = find(stack)
    // a lambda that is a Lua function starts with no loops: look in those around it, up to the function the jump is in
    var i = frames.lastIndex
    while (found == null && i >= 0) {
        val frame = frames[i--]
        val outer = frame.outerLoops
        if (outer != null && outer !== stack) {
            if (frame.kind == FunctionFrame.Kind.Lambda) {
                stack = outer
                found = find(stack)
            } else {
                i = -1
            }
        }
    }
    if (found == null) unsupported(e, "Jump outside of a loop")
    return found
}

internal fun FileTransformer.breakStatement(e: KtBreakExpression) {
    jumpTarget(e)?.let { jumpTo(JumpTarget.Break(it), null, e) }
}

internal fun FileTransformer.continueStatement(e: KtContinueExpression) {
    jumpTarget(e)?.let { jumpTo(JumpTarget.Continue(it), null, e) }
}

internal fun FileTransformer.breakLabel(frame: LoopFrame): String = frame.breakLabel ?: ctx.temp("break").also {
    frame.breakLabel = it
    jumpLabels += it
}

internal fun FileTransformer.continueLabel(frame: LoopFrame): String = frame.continueLabel ?: ctx.temp("continue").also {
    frame.continueLabel = it
    jumpLabels += it
}

/**
 * A `break` of [frame]. With [leavesLambda] it is in a lambda expanded in place, maybe inside the loops of the expansion, so it
 * is a `goto` (see [ownExits]).
 */
internal fun FileTransformer.breakLocally(frame: LoopFrame, leavesLambda: Boolean) {
    if (leavesLambda) {
        emit(LuaGoto(breakLabel(frame)))
    } else if (frame === loops.last()) {
        emit(LuaBreak)
    } else if (!target.hasGoto) {
        // break@outer without goto: set a flag, and have each loop in between break when it is set.
        val flag = frame.breakFlag ?: ctx.temp("break").also { frame.breakFlag = it }
        emit(assign(flag, LuaBool(true)))
        emit(LuaBreak)
        innerFrames(frame).forEach { inner -> inner.addCheck(LuaIf(LuaName(flag), listOf(LuaBreak))) }
    } else {
        emit(LuaGoto(breakLabel(frame)))
    }
}

/** A `continue` of [frame]; like [breakLocally]. */
internal fun FileTransformer.continueLocally(frame: LoopFrame, leavesLambda: Boolean) {
    val label = continueLabel(frame)
    if (leavesLambda || target.hasGoto || frame === loops.last()) {
        emit(LuaGoto(label))
        return
    }
    // continue@outer without goto: break out of the inner loops, then continue the outer one.
    val flag = frame.continueFlag ?: ctx.temp("continue").also { frame.continueFlag = it }
    emit(assign(flag, LuaBool(true)))
    emit(LuaBreak)
    val inner = innerFrames(frame)
    inner.dropLast(1).forEach { it.addCheck(LuaIf(LuaName(flag), listOf(LuaBreak))) }
    inner.last().addCheck(LuaIf(LuaName(flag), listOf(LuaGoto(label))))
}

/**
 * The `goto`s to the loop's own labels in its body that come from lambdas expanded in place: on Lua 5.1 those inside the
 * expansion's loops set a flag and break out of them, and at the top of the body a `goto` to the break label is a `break`
 * (the label is left out when nothing else jumps to it).
 */
internal fun FileTransformer.ownExits(frame: LoopFrame, stmts: List<LuaStmt>): List<LuaStmt> {
    val brk = frame.breakLabel
    var lowered = if (target.hasGoto) stmts else leaveNestedLoops(stmts, setOfNotNull(brk, frame.continueLabel))
    if (brk == null) return lowered
    lowered = lowered.mapStatements { s, depth -> if (s is LuaGoto && s.label == brk && depth == 0) LuaBreak else s }
    var used = false
    lowered.forEachLeafStatement { if (it is LuaGoto && it.label == brk) used = true }
    if (!used) frame.breakLabel = null
    return lowered
}

/**
 * Lua 5.1 has no `goto`: one to one of [labels] (the current loop's) from inside nested Lua loops sets a flag and breaks; after
 * each loop it leaves, the flag breaks again, and after the outermost one the `goto` is made at the top of the body.
 */
private fun FileTransformer.leaveNestedLoops(stmts: List<LuaStmt>, labels: Set<String>): List<LuaStmt> {
    if (labels.isEmpty()) return stmts
    val flags = LinkedHashMap<String, String>()
    fun flagOf(label: String) = flags.getOrPut(label) { ctx.temp("leave") }
    fun lower(list: List<LuaStmt>, inLoop: Boolean, used: MutableSet<String>): List<LuaStmt> = list.flatMap { s ->
        fun loop(rebuild: (List<LuaStmt>) -> LuaStmt, body: List<LuaStmt>): List<LuaStmt> {
            val inner = LinkedHashSet<String>()
            val lowered = lower(body, inLoop = true, used = inner)
            if (inner.isEmpty()) return listOf(s)
            used += inner
            return listOf(rebuild(lowered)) + inner.map { LuaIf(LuaName(flagOf(it)), listOf(if (inLoop) LuaBreak else LuaGoto(it))) }
        }
        when (s) {
            is LuaGoto -> if (inLoop && s.label in labels) {
                used += s.label
                listOf(assign(flagOf(s.label), LuaBool(true)), LuaBreak)
            } else {
                listOf(s)
            }

            is LuaIf -> listOf(LuaIf(s.cond, lower(s.then, inLoop, used), s.orElse?.let { lower(it, inLoop, used) }))

            is LuaDo -> listOf(LuaDo(lower(s.body, inLoop, used)))

            is LuaWhile -> loop({ LuaWhile(s.cond, it) }, s.body)

            is LuaRepeat -> loop({ LuaRepeat(it, s.until) }, s.body)

            is LuaNumericFor -> loop({ s.copy(body = it) }, s.body)

            is LuaGenericFor -> loop({ s.copy(body = it) }, s.body)

            else -> listOf(s)
        }
    }
    val lowered = lower(stmts, inLoop = false, used = LinkedHashSet())
    return flags.values.map { LuaLocal(listOf(it), listOf(LuaBool(false))) } + lowered
}

/** Loops nested inside [outer], innermost first. */
private fun FileTransformer.innerFrames(outer: LoopFrame): List<LoopFrame> = loops.toList().takeLastWhile { it !== outer }.reversed()
