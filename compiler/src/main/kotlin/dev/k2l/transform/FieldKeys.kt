package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * The key of the object table that holds [p]'s backing field. Fields and methods share the table, so a private property
 * named like a method of its class (`private var next` next to `fun next()` in an iterator) keeps its value under
 * `____next`; only the class's own code reads a private property, always through this key. So does a final property named
 * like an override of a library member, which keeps the library's name (`val hashCode: Int` next to `override fun hashCode()`):
 * no override can change where its value is, so every read goes through this key too.
 */
internal fun FileTransformer.fieldKey(p: KtNamedDeclaration): String {
    val name = props.fieldName(p)
    return if (isShadowedByMethod(p) || readsThroughPropertyOverride(p)) "____$name" else name
}

/**
 * A property overriding a library one through accessors (`override var size = 0` with a setter, in an AbstractMutableMap):
 * reads of the field `size` go to the getter (see [propertyOverride]) and writes to `____size`, so the accessors keep the
 * backing field there.
 */
internal fun FileTransformer.readsThroughPropertyOverride(p: KtNamedDeclaration): Boolean {
    if (!props.overridesLibraryWithAccessor(p)) return false
    val owner = PsiTreeUtil.getParentOfType(p, KtClassOrObject::class.java) ?: return false
    return !(p.name == "size" && classes.collectionBaseOf(owner) in CONCRETE_COLLECTION_BASES)
}

internal fun FileTransformer.isShadowedByMethod(p: KtNamedDeclaration): Boolean {
    val isPrivate = p.hasModifier(KtTokens.PRIVATE_KEYWORD)
    if (!isPrivate && !isFinalMember(p)) return false
    val owner = PsiTreeUtil.getParentOfType(p, KtClassOrObject::class.java) ?: return false
    // a data class's toString/equals/copy read its constructor properties by name
    if (p is KtParameter && owner is KtClass && owner.isData()) return false
    return owner.declarations.any {
        it is KtNamedFunction && naming.function(it) == p.name && (isPrivate || it.hasModifier(KtTokens.OVERRIDE_KEYWORD))
    }
}

/** A member property no subclass can override, declared in a class (not an interface). */
private fun isFinalMember(p: KtNamedDeclaration): Boolean {
    if (p is KtParameter && !p.hasValOrVar()) return false
    val owner = PsiTreeUtil.getParentOfType(p, KtClassOrObject::class.java)
    if (owner == null || (owner is KtClass && owner.isInterface())) return false
    return listOf(KtTokens.OPEN_KEYWORD, KtTokens.ABSTRACT_KEYWORD, KtTokens.OVERRIDE_KEYWORD).none { p.hasModifier(it) }
}

/**
 * Whether a class of [p]'s family declares a method called [name] in Lua: `override var value` in a `MutableMap.MutableEntry`
 * next to `override fun setValue(newValue)`, whose name the library fixes. The accessor gives way then (see [accessorName]).
 */
internal fun FileTransformer.accessorTaken(p: KtNamedDeclaration, name: String): Boolean =
    props.members(p).mapNotNull { PsiTreeUtil.getParentOfType(it, KtClassOrObject::class.java) }.flatMap { classes.hierarchy(it) }
        .any { c -> c.declarations.any { it is KtNamedFunction && it.name == name && naming.function(it) == name } }
