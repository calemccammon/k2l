package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

internal fun isLateinit(p: PsiElement?): Boolean = p is KtProperty && p.hasModifier(KtTokens.LATEINIT_KEYWORD)

/**
 * A read of a `lateinit` property or variable: its value, or `UninitializedPropertyAccessException` while it is unset. A lateinit
 * value is never nil or false (primitive types cannot be lateinit), so the check is `value or __K2L_Uninitialized("name")`.
 */
internal fun FileTransformer.lateinitRead(p: PsiElement?, value: LuaExpr): LuaExpr {
    if (!isLateinit(p)) return value
    val error = LuaCall(lualibRef(EXCEPTIONS_FEATURE, "__K2L_Uninitialized"), listOf(LuaString((p as KtProperty).name!!)))
    return LuaBinary(LuaBinOp.Or, value, error)
}

/** `::name.isInitialized`, `this::name.isInitialized`, `other::name.isInitialized`: the raw slot is not nil. */
internal fun FileTransformer.lateinitIsInitialized(call: KtExpression): LuaExpr? = with(session) {
    val ref = (call as? KtQualifiedExpression)?.receiverExpression?.let(KtPsiUtil::safeDeparenthesize) as? KtCallableReferenceExpression
        ?: return null
    val property = ref.callableReference.mainReference.resolve() as? KtProperty ?: return null
    if (!isLateinit(property) || !classes.isSource(property)) return null
    val slot = when {
        property.isLocal -> LuaName(naming.renamed(property) ?: LuaNames.of(property.name!!))

        property.isTopLevel -> topLevelRef(property)

        else -> {
            val receiver = ref.receiverExpression?.let { expression(it) } ?: implicitReferenceReceiver(ref) ?: return null
            LuaIndex(receiver, LuaString(fieldKey(property)))
        }
    }
    LuaBinary(LuaBinOp.Ne, slot, LuaNil)
}
