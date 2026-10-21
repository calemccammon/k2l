package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

// Statements other than assignments: expressions as statements, local properties, return and if.

internal fun FileTransformer.expressionStatement(e: KtExpression): Unit = with(session) {
    if (isUnitObject(e)) return // `else -> Unit`
    val value = asStatement(e) { expression(e) }
    when {
        value is LuaCall || value is LuaMethodCall -> emit(LuaCallStmt(value))

        isStable(value) || value is LuaName -> Unit

        // a bare value has no effect
        else -> emit(LuaLocal(listOf("_"), listOf(value)))
    }
}

internal fun FileTransformer.property(p: KtProperty, isLocal: Boolean): Unit = with(session) {
    if (p.delegate != null) {
        delegatedVariable(p, isLocal)
        return
    }
    val name = naming.of(p)
    val init = p.initializer
    when {
        init == null -> if (isLocal) emit(LuaLocal(listOf(name)))

        isLocal && needsBranching(init) -> {
            emit(LuaLocal(listOf(name)))
            emitAll(valueInto(init) { listOf(assign(name, it)) })
        }

        isLocal -> emit(LuaLocal(listOf(name), listOf(expression(init))))

        else -> emitAll(valueInto(init) { listOf(assign(name, it)) })
    }
}

internal fun FileTransformer.returnStatement(e: KtReturnExpression): Unit = with(session) {
    val label = e.getLabelName()
    val target = if (label == null) bareReturnTarget(e) else jumps.frames.lastOrNull { label in it.labels }
    if (target == null) {
        unsupported(e, "This return")
        return
    }
    jumpTo(JumpTarget.Return(target), e.returnedExpression?.asOperand(), e)
}

/** A `return` of [target], with no Lua function between here and it: a `goto` out of an inlined body, or a Lua `return`. */
internal fun FileTransformer.returnLocally(target: FunctionFrame, value: Operand?): Unit = with(session) {
    if (target.kind == FunctionFrame.Kind.Inline || target.kind == FunctionFrame.Kind.InlineFunction) {
        val sink = target.sink
        when (value) {
            is Operand.Source -> if (sink != null) emitAll(valueInto(value.expr, sink)) else statement(value.expr)
            is Operand.Value -> if (sink != null) emitAll(sink(value.lua))
            null -> Unit
        }
        val end = target.endLabel ?: ctx.temp("inline_end").also {
            target.endLabel = it
            jumps.jumpLabels += it
        }
        emit(LuaGoto(end))
        return
    }
    when (value) {
        null -> emit(LuaReturn(listOfNotNull(if (target.unitResult) unitObject() else null)))

        is Operand.Source -> {
            val returned = KtPsiUtil.safeDeparenthesize(value.expr)
            val result = { valueInto(returned) { listOf(LuaReturn(listOf(it))) } }
            // `return unitCall()` where the result is not used stays a tail call
            emitAll(if (returnsNothing(target)) asStatement(returned, result) else result())
        }

        is Operand.Value -> emit(LuaReturn(listOf(value.lua)))
    }
}

/**
 * What a `return` without a label leaves: the innermost function it is written in, which can be an inlined
 * function when this is the body of one (or a lambda passed to it, written in the function that called it).
 */
private fun FileTransformer.bareReturnTarget(e: KtReturnExpression): FunctionFrame? {
    val owner = generateSequence<PsiElement>(e) { it.parent }.firstOrNull { it is KtNamedFunction || it is KtPropertyAccessor }
    return jumps.frames.lastOrNull { it.isFunctionBody && it.psi != null && it.psi === owner }
        ?: jumps.frames.lastOrNull { it.kind == FunctionFrame.Kind.Function }
}

internal fun FileTransformer.ifStatement(e: KtIfExpression): Unit = with(session) {
    val cond = expression(e.condition ?: return)
    val then = collect { e.then?.let { block(it) } }
    val orElse = e.`else`?.let { collect { block(it) } }
    emit(LuaIf(cond, then, orElse?.takeIf { it.isNotEmpty() }))
}

internal fun FileTransformer.block(e: KtExpression): Unit = with(session) {
    if (e is KtBlockExpression) e.statements.forEach { statement(it) } else statement(e)
}
