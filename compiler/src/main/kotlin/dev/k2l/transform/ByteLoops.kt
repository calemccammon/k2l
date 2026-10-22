package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * `for (c in s)` whose body uses `c` only as `c.code` and in `c == 'x'` / `c != 'x'` with ASCII literals:
 * the loop reads `local c = byte(s, i)` (a number, no one-character string) and those uses become `c` and `c == 120`.
 * Returns false (registering nothing) when the body uses `c` otherwise.
 */
internal fun FileTransformer.byteLoop(text: LuaExpr, param: KtParameter, body: KtExpression?, translate: () -> List<LuaStmt>): Boolean =
    with(session) {
        if (body == null) return false
        val variable = naming.of(param)
        val uses = HashMap<KtExpression, LuaExpr>()
        var other = false
        body.accept(object : KtTreeVisitorVoid() {
            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (other || expression.mainReference.resolve() != param) return
                val use = byteUse(expression, LuaName(variable))
                if (use == null) other = true else uses[use.first] = use.second
            }
        })
        if (other || uses.isEmpty()) return false
        callState.overrides += uses
        val s = cache(text, "text")
        val i = LuaName(ctx.temp("i"))
        val loopBody = try {
            translate()
        } finally {
            uses.keys.forEach(callState.overrides::remove)
        }
        val byte = LuaLocal(listOf(variable), listOf(LuaCall(lualibRef("Natives", "__K2L_StrByte"), listOf(s, i))))
        emit(LuaNumericFor(i.name, LuaNumber("1"), LuaUnary(LuaUnOp.Len, s), null, listOf(byte) + loopBody))
        true
    }

/** The expression around a reference to the loop's Char that a byte can stand for, with its Lua form; else null. */
private fun FileTransformer.byteUse(reference: KtSimpleNameExpression, byte: LuaExpr): Pair<KtExpression, LuaExpr>? =
    when (val parent = reference.parent) {
        is KtDotQualifiedExpression -> codeUse(parent, reference)?.let { it to byte }
        is KtBinaryExpression -> literalComparison(parent, reference, byte)?.let { parent to it }
        else -> null
    }

/** `c.code` */
private fun FileTransformer.codeUse(parent: KtDotQualifiedExpression, reference: KtSimpleNameExpression): KtExpression? = with(session) {
    val selector = parent.selectorExpression as? KtNameReferenceExpression
    parent.takeIf { it.receiverExpression == reference && selector?.getReferencedName() == "code" && it.expressionType?.isIntType == true }
}

/** `c == 'x'` or `c != 'x'` with an ASCII literal, as `byte == 120`. */
private fun FileTransformer.literalComparison(parent: KtBinaryExpression, reference: KtSimpleNameExpression, byte: LuaExpr): LuaExpr? =
    with(session) {
        val op = when (parent.operationToken) {
            KtTokens.EQEQ -> LuaBinOp.Eq
            KtTokens.EXCLEQ -> LuaBinOp.Ne
            else -> return null
        }
        val other = (if (parent.left == reference) parent.right else parent.left) ?: return null
        val code = ((other.evaluate() as? KaConstantValue.CharValue)?.value)?.code ?: return null
        if (code >= ASCII_LIMIT || other.expressionType?.isCharType != true) return null
        LuaBinary(op, byte, LuaNumber(code.toString()))
    }

private const val ASCII_LIMIT = 128

/**
 * `s[i] == 'x'` as [inlineCharAt] reads `s[i]`, compared with an ASCII literal: the byte instead of the
 * one-character string, `(i >= 0 and byte(s, i + 1) or __K2L_IndexError(...)) == 120` (`byte` gives nil past the end, so
 * the length test goes); other comparisons are returned as they are.
 */
internal fun FileTransformer.byteComparison(comparison: LuaExpr): LuaExpr {
    val c = comparison as? LuaBinary ?: return comparison
    if (c.op != LuaBinOp.Eq && c.op != LuaBinOp.Ne) return comparison
    val literal = c.right as? LuaString ?: c.left as? LuaString ?: return comparison
    val read = if (literal === c.right) c.left else c.right
    val code = literal.value.singleOrNull()?.code?.takeIf { it < ASCII_LIMIT } ?: return comparison
    val byte = charAtAsByte(read) ?: return comparison
    return LuaBinary(c.op, byte, LuaNumber(code.toString()))
}

/** `(i >= 0 and i < #s and s:sub(i + 1, i + 1)) or fail` as `(i >= 0 and byte(s, i + 1)) or fail`; else null. */
private fun FileTransformer.charAtAsByte(read: LuaExpr): LuaExpr? {
    val or = read.binary(LuaBinOp.Or) ?: return null
    val and = or.left.binary(LuaBinOp.And) ?: return null
    val inRange = and.left.binary(LuaBinOp.And) ?: return null
    val sub = (and.right as? LuaMethodCall)?.takeIf { it.method == "sub" && it.args.size == 2 && it.args[0] == it.args[1] } ?: return null
    val nonNegative = inRange.left.binary(LuaBinOp.Ge) ?: return null
    val belowLength = inRange.right.binary(LuaBinOp.Lt)?.takeIf { it.right == LuaUnary(LuaUnOp.Len, sub.target) }
    val fails = ((or.right as? LuaCall)?.fn as? LuaName)?.name == "__K2L_IndexError"
    if (belowLength == null || !fails) return null
    val byte = LuaCall(lualibRef("Natives", "__K2L_StrByte"), listOf(sub.target, sub.args[0]))
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, nonNegative, byte), or.right)
}

private fun LuaExpr.binary(op: LuaBinOp): LuaBinary? = (this as? LuaBinary)?.takeIf { it.op == op }
