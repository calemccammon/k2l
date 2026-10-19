package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * The key of the object table that holds [p]'s backing field. Fields and methods share the table, so a private property
 * named like a method of its class (`private var next` next to `fun next()` in an iterator) keeps its value under
 * `____next`; only the class's own code reads a private property, always through this key.
 */
internal fun FileTransformer.fieldKey(p: KtNamedDeclaration): String {
    val name = props.fieldName(p)
    return if (isShadowedByMethod(p)) "____$name" else name
}

internal fun FileTransformer.isShadowedByMethod(p: KtNamedDeclaration): Boolean {
    if (!p.hasModifier(KtTokens.PRIVATE_KEYWORD)) return false
    val owner = PsiTreeUtil.getParentOfType(p, KtClassOrObject::class.java) ?: return false
    // a data class's toString/equals/copy read its constructor properties by name
    if (p is KtParameter && owner is KtClass && owner.isData()) return false
    return owner.declarations.any { it is KtNamedFunction && naming.function(it) == p.name }
}
