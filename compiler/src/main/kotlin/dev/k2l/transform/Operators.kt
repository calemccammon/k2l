package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/** `a?.b`: `a and a.b`, or an `if a ~= nil` block when the access needs statements or `a` may be false. */
internal fun FileTransformer.safeCall(e: KtSafeQualifiedExpression): LuaExpr = with(session) {
    val receiver = cache(expression(e.receiverExpression), "receiver")
    val (value, pre) = withPreceding { withOverride(e.receiverExpression, receiver) { selector(e) } }
    if (pre.isEmpty() && e.receiverExpression.expressionType?.isBooleanType != true) {
        return LuaBinary(LuaBinOp.And, receiver, value)
    }
    val name = ctx.temp("result")
    emit(LuaLocal(listOf(name)))
    emit(LuaIf(LuaBinary(LuaBinOp.Ne, receiver, LuaNil), pre + assign(name, value)))
    return LuaName(name)
}

internal fun FileTransformer.safeCallStatement(e: KtSafeQualifiedExpression): Unit = with(session) {
    val receiver = cache(expression(e.receiverExpression), "receiver")
    val body = collect {
        val value = withOverride(e.receiverExpression, receiver) { selector(e) }
        if (value is LuaCall || value is LuaMethodCall) emit(LuaCallStmt(value))
    }
    emit(LuaIf(LuaBinary(LuaBinOp.Ne, receiver, LuaNil), body))
}

internal fun FileTransformer.selector(e: KtQualifiedExpression): LuaExpr = with(session) {
    when (val selector = e.selectorExpression) {
        is KtCallExpression -> call(selector, e)
        is KtNameReferenceExpression -> reference(selector, e)
        else -> unsupported(e, "This qualified expression")
    }
}

private inline fun <T> FileTransformer.withOverride(e: KtExpression, value: LuaExpr, block: () -> T): T {
    overrides[e] = value
    try {
        return block()
    } finally {
        overrides.remove(e)
    }
}

/** `a ?: b`: `a or b` unless `a` may be false or `b` needs statements; `a ?: return` becomes an `if`. */
internal fun FileTransformer.elvis(left: KtExpression, right: KtExpression): LuaExpr = with(session) {
    val l = expression(left)
    if (isJump(KtPsiUtil.safeDeparenthesize(right))) {
        val value = cache(l, "value")
        emit(LuaIf(LuaBinary(LuaBinOp.Eq, value, LuaNil), collect { statement(KtPsiUtil.safeDeparenthesize(right)) }))
        return value
    }
    val (r, pre) = withPreceding { expression(right) }
    if (pre.isEmpty() && left.expressionType?.isBooleanType != true) return LuaBinary(LuaBinOp.Or, l, r)
    val name = ctx.temp("value")
    emit(LuaLocal(listOf(name), listOf(l)))
    emit(LuaIf(LuaBinary(LuaBinOp.Eq, LuaName(name), LuaNil), pre + assign(name, r)))
    return LuaName(name)
}

/** Kotlin `==`: identity for primitives, enums and objects; `equals()` when a class may override it. */
internal fun FileTransformer.equality(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, negated: Boolean): LuaExpr = with(session) {
    val result = when {
        l is LuaNil || r is LuaNil || lt.isNullLiteral || rt.isNullLiteral -> LuaBinary(LuaBinOp.Eq, l, r)
        !classes.mayOverrideEquals(lt) && !classes.mayOverrideEquals(rt) -> LuaBinary(LuaBinOp.Eq, l, r)
        lt != null && !lt.isMarkedNullable && classes.knownEquals(lt) -> LuaMethodCall(l, "equals", listOf(r))
        else -> lualibCall("Equals", l, r)
    }
    return if (negated) negate(result) else result
}

internal fun FileTransformer.isPrimitiveOperand(t: KaType?): Boolean = with(session) {
    t == null || t.isNumber || t.isStringType || t.isCharType || t.isBooleanType ||
        (t.isMarkedNullable && (t.isStringType)) // String? + x is still string concatenation
}

context(s: KaSession)
private val KaType?.isNullLiteral get() = this != null && with(s) { isNothingType }

internal fun FileTransformer.cast(e: KtBinaryExpressionWithTypeRHS): LuaExpr = with(session) {
    val type = e.right?.type?.let { reifiedType(it) } ?: return LuaNil
    val value = expression(e.left)
    if (e.operationReference.getReferencedNameElementType() != KtTokens.AS_SAFE) return value // unchecked, as in TSTL
    val v = cache(value, "cast")
    if (type.isBooleanType) {
        val name = ctx.temp("cast")
        emit(LuaLocal(listOf(name)))
        emit(LuaIf(typeTest(v, type, e), listOf(assign(name, v))))
        return LuaName(name)
    }
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, typeTest(v, type, e), v), LuaNil)
}
