package dev.k2l.transform

import com.intellij.psi.tree.IElementType
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

// Assignments: to locals, properties, fields and indexed elements, and increments.

private val AUGMENTED: Map<IElementType, LuaBinOp> = mapOf(
    KtTokens.PLUSEQ to LuaBinOp.Add,
    KtTokens.MINUSEQ to LuaBinOp.Sub,
    KtTokens.MULTEQ to LuaBinOp.Mul,
    KtTokens.DIVEQ to LuaBinOp.Div,
    KtTokens.PERCEQ to LuaBinOp.Mod,
)

internal fun FileTransformer.assignment(e: KtBinaryExpression): Unit = with(session) {
    val left = e.left ?: return
    val right = e.right ?: return
    if (e.operationToken != KtTokens.EQ && callsAssignOperator(e)) {
        // `list += x` calls plusAssign, also on a `val` or a parameter
        val value = call(e, e)
        if (value is LuaCall || value is LuaMethodCall) emit(LuaCallStmt(value))
        return
    }
    val target = assignTarget(left) ?: return
    if (e.operationToken == KtTokens.EQ) {
        emitAll(valueInto(right) { target.assignAll(it) })
        return
    }
    val op = AUGMENTED.getValue(e.operationToken)
    val leftType = left.expressionType
    if (leftType == null || !(leftType.isNumber || leftType.isStringType)) {
        // `readOnly += x` is `readOnly = readOnly + x`
        emit(target.write(compoundOperatorCall(e) ?: call(e, e)))
        return
    }
    val value = operator(op, target.read, leftType, expression(right), right.expressionType, e)
    emit(target.update(value))
}

/** Whether `a op= b` calls an `opAssign` operator (`plusAssign`) rather than assigning `a op b`. */
private fun FileTransformer.callsAssignOperator(e: KtBinaryExpression): Boolean = with(session) {
    val leftType = e.left?.expressionType
    if (leftType != null && (leftType.isNumber || leftType.isStringType)) return false
    val callee = e.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()?.partiallyAppliedSymbol?.symbol
    return callee?.callableId?.callableName?.asString()?.endsWith("Assign") == true
}

internal fun FileTransformer.assignTarget(e: KtExpression): Target? = with(session) {
    val ex = KtPsiUtil.safeDeparenthesize(e)
    if (ex is KtArrayAccessExpression) return indexTarget(ex)
    val ref = assignedReference(ex)
    val receiverExpr = (ex as? KtDotQualifiedExpression)?.receiverExpression
    if (ref != null && receiverExpr == null && ref.mainReference.resolveToSymbol() is KaBackingFieldSymbol) {
        val field = backingField(ref)
        return Target(field) { assign(field, it) }
    }
    val decl = ref?.mainReference?.resolve()
    if (ref == null || decl == null || !classes.isSource(decl)) return unsupported(e, "Assignment to this target").let { null }
    return when {
        decl is KtProperty && decl.containingClassOrObject == null -> variableTarget(decl, ref, receiverExpr)

        // `var (a, b) = pair` declares plain locals
        decl is KtDestructuringDeclarationEntry -> LuaName(naming.entry(decl)).let { name -> Target(name) { assign(name, it) } }

        isMemberProperty(decl) -> memberPropertyTarget(decl as KtNamedDeclaration, ref, receiverExpr)

        else -> unsupported(e, "Assignment to this target").let { null }
    }
}

private fun FileTransformer.assignedReference(ex: KtExpression) = when (ex) {
    is KtNameReferenceExpression -> ex
    is KtDotQualifiedExpression -> ex.selectorExpression as? KtNameReferenceExpression
    else -> null
}

private fun FileTransformer.memberPropertyTarget(
    property: KtNamedDeclaration,
    ref: KtNameReferenceExpression,
    receiverExpr: KtExpression?,
): Target? = with(session) {
    if (property is KtProperty && property.receiverTypeReference != null) return memberExtensionPropertyTarget(property, ref, receiverExpr)
    val receiver = if (receiverExpr != null) cache(expression(receiverExpr), "object") else implicitReceiverOf(ref) ?: return null
    return Target(propertyRead(receiver, property)) { propertyWrite(receiver, property, it) }
}

/** `xs[i] = v`, `map[k] = v`, or a user `operator fun set` (also with several indices: `m[i, j] = v`). */
private fun FileTransformer.indexTarget(e: KtArrayAccessExpression): Target? = with(session) {
    val arrayExpr = e.arrayExpression ?: return null
    if (e.indexExpressions.isEmpty()) return null
    val type = arrayExpr.expressionType
    val values = ordered(listOf(arrayExpr) + e.indexExpressions)
    val receiver = cache(values[0], "object")
    val keys = values.drop(1).map { cache(it, "key") }
    sourceIndexOperators(e)?.let { return sourceIndexTarget(e, it, receiver, keys) }
    return libraryIndexTarget(e, type, receiver, keys)
}

/** `xs[i] = v` and `map[k] = v` on a library type, whose index operators are mapped. */
private fun FileTransformer.libraryIndexTarget(e: KtArrayAccessExpression, type: KaType?, receiver: LuaExpr, keys: List<LuaExpr>): Target? =
    with(session) {
        if (keys.size > 1) return unsupported(e, "Multi-index access on '${type.pretty()}'").let { null }
        val key = keys[0]
        val userClass = type?.expandedSymbol?.psi as? KtClassOrObject
        val kind = type?.collectionKind()
        return when {
            // a class of the program without index operators (those are handled above)
            userClass != null && classes.isSource(userClass) && kind == null ->
                unsupported(e, "Index assignment without operator get/set").let { null }

            kind == CollectionKind.Map || kind == CollectionKind.StringBuilder ->
                Target(LuaMethodCall(receiver, "get", listOf(key))) { LuaCallStmt(LuaMethodCall(receiver, "set", listOf(key, it))) }

            kind == CollectionKind.LuaTable -> {
                val slot = LuaIndex(receiver, key)
                Target(slot) { assign(slot, it) }
            }

            kind?.isIndexable == true && isProvenIndex(e, type) -> {
                val slot = CollectionMappings.index(receiver, key)
                Target(slot) { assign(slot, it) }
            }

            // out-of-range reads and writes throw IndexOutOfBoundsException
            kind?.isIndexable == true -> checkedIndexTarget(type, receiver, key)

            else -> unsupported(e, "Index assignment on '${type.pretty()}'").let { null }
        }
    }

internal fun FileTransformer.increment(e: KtUnaryExpression, target: Target): Unit = with(session) {
    val op = if (e.operationToken == KtTokens.PLUSPLUS) LuaBinOp.Add else LuaBinOp.Sub
    val type = e.baseExpression?.expressionType
    emit(target.update(if (type?.isCharType == true) charStepped(op, target.read) else stepped(op, target.read)))
}

/** `c++` on a Char: the Char whose code is one more (or less). */
private fun charStepped(op: LuaBinOp, read: LuaExpr): LuaExpr =
    lua("string.char", LuaBinary(op, LuaMethodCall(read, "byte", emptyList()), LuaNumber("1")))
