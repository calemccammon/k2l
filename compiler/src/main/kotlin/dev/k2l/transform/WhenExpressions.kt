package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

// when: as a statement or a value, with or without a subject, and its conditions.

internal fun FileTransformer.whenInto(e: KtWhenExpression, sink: ValueSink?): Unit = with(session) {
    val subjectVar = e.subjectVariable
    val subjectExpr = e.subjectExpression
    val subject: LuaExpr? = when {
        subjectVar != null -> {
            val name = naming.of(subjectVar)
            emit(LuaLocal(listOf(name), listOf(expression(subjectVar.initializer ?: return))))
            LuaName(name).also { stable += it }
        }

        subjectExpr != null -> cache(expression(subjectExpr), "subject")

        else -> null
    }
    val subjectType = (subjectVar?.initializer ?: subjectExpr)?.expressionType
    hoistSubjectMetatable(e, subject)

    var tail: List<LuaStmt>? = null
    for (entry in e.entries.reversed()) {
        val bodyExpr = entry.expression ?: continue
        val body = if (sink == null) collect { block(bodyExpr) } else valueInto(bodyExpr, sink)
        // a guard (`is Int if x > 0 ->`, `else if ready ->`) is evaluated only when the conditions hold
        val guard = entry.guard?.getExpression()
        if (entry.isElse && guard == null) {
            tail = body
        } else {
            val (cond, pre) = withPreceding { entryCondition(entry, guard, subject, subjectType) }
            tail = pre + LuaIf(cond, body, tail?.takeIf { it.isNotEmpty() })
        }
    }
    subject?.let(subjectMetatables::remove)
    tail?.let { emitAll(it) }
}

/** Whether [entry] matches: its conditions, then its [guard]. */
private fun FileTransformer.entryCondition(entry: KtWhenEntry, guard: KtExpression?, subject: LuaExpr?, subjectType: KaType?): LuaExpr =
    with(session) {
        val conditions = entry.conditions.map { c -> { condition(c, subject, subjectType) } }
        val matched = if (conditions.isEmpty()) null else reduceOr(conditions)
        when {
            guard == null -> matched!!
            matched == null -> expression(guard)
            else -> shortCircuit(LuaBinOp.And, matched) { expression(guard) }
        }
    }

private fun FileTransformer.reduceOr(conditions: List<() -> LuaExpr>): LuaExpr =
    conditions.drop(1).fold(conditions.first()()) { acc, next -> shortCircuit(LuaBinOp.Or, acc, next) }

private fun FileTransformer.condition(c: KtWhenCondition, subject: LuaExpr?, subjectType: KaType?): LuaExpr = with(session) {
    when (c) {
        is KtWhenConditionWithExpression -> {
            val expr = c.expression ?: return LuaNil
            if (subject == null) {
                expression(expr)
            } else {
                equality(subject, subjectType, expression(expr), expr.expressionType, negated = false)
            }
        }

        is KtWhenConditionInRange -> inRangeCondition(c, subject)

        is KtWhenConditionIsPattern -> isPatternCondition(c, subject)

        else -> unsupported(c, "This 'when' condition")
    }
}

private fun FileTransformer.inRangeCondition(c: KtWhenConditionInRange, subject: LuaExpr?): LuaExpr = with(session) {
    val range = c.rangeExpression?.let { parseRange(it) }
    if (subject != null && range == null) containsCondition(c, subject)?.let { return it }
    if (subject == null || range == null) return unsupported(c, "This 'in' condition")
    return rangeContains(subject, range).let { if (c.isNegated) negate(it) else it }
}

/**
 * `in collection ->`, `in "aeiou" ->`: the `contains` call the condition resolves to, with the cached subject as its
 * argument, like `x in collection`.
 */
private fun FileTransformer.containsCondition(c: KtWhenConditionInRange, subject: LuaExpr): LuaExpr? = with(session) {
    val op = c.operationReference
    val call = op.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return null
    val argument = call.valueArgumentMapping.keys.singleOrNull() ?: unmappedWhenSubject(op) ?: return null
    callState.overrides[argument] = subject
    val contains = call(op, c.rangeExpression ?: return null)
    return if (c.isNegated) negate(contains) else contains
}

/**
 * The subject of the `when` whose `in` condition [op] belongs to, when the Analysis API leaves the condition's `contains`
 * call without an argument mapping (an enum subject after an equality branch).
 */
internal fun FileTransformer.unmappedWhenSubject(op: KtExpression): KtExpression? {
    val condition = op.parent as? KtWhenConditionInRange ?: return null
    if (condition.operationReference != op) return null
    val whenExpr = PsiTreeUtil.getParentOfType(condition, KtWhenExpression::class.java) ?: return null
    return whenExpr.subjectExpression
}

private fun FileTransformer.isPatternCondition(c: KtWhenConditionIsPattern, subject: LuaExpr?): LuaExpr = with(session) {
    val type = c.typeReference?.type
    if (subject == null || type == null) return LuaNil
    return typeTest(subject, type, c).let { if (c.isNegated) negate(it) else it }
}
