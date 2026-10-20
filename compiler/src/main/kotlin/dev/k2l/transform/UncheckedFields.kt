package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.getParentOfType

/**
 * Properties that hold an unchecked value (see [UncheckedCasts]): those initialized by a cast to a generic type, constructor
 * properties given an unchecked local or cast (`Box(l)` for `class Box(val items: List<String>)`), and properties assigned
 * one. Reading them is checked like reading the local (`box.items[0].length`, `for (s in box.items)`); a value stored in a
 * property by other means (through a parameter of a function, from another property) is not followed.
 */
internal class UncheckedFields(val fields: Set<KtNamedDeclaration>) {
    val names: Set<String> = fields.mapNotNullTo(HashSet()) { it.name }
}

/** The [UncheckedFields] of the module, resolved once (they hold only PSI). */
internal fun FileTransformer.uncheckedFields(unchecked: UncheckedCasts): UncheckedFields =
    classes.module.shared.getOrPut("uncheckedFields") {
        val fields = HashSet<KtNamedDeclaration>(unchecked.castFields)
        for (value in unchecked.passed) {
            if (isUncheckedLocalOrCast(value, unchecked)) fieldReceiving(value)?.let { fields += it }
        }
        UncheckedFields(fields)
    } as UncheckedFields

/** The property of the program that [value] initializes as a constructor argument or is assigned to, if it is one. */
private fun FileTransformer.fieldReceiving(value: KtExpression): KtNamedDeclaration? = with(session) {
    var child: KtExpression = value
    while (child.parent is KtParenthesizedExpression) child = child.parent as KtExpression
    val parent = child.parent
    if (parent is KtValueArgument) {
        val call = parent.getParentOfType<KtCallElement>(true)?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
        val parameter = call?.valueArgumentMapping?.get(value)?.symbol?.psi as? KtParameter
        return parameter?.takeIf { it.hasValOrVar() }
    }
    val left = (parent as? KtBinaryExpression)?.left?.let(KtPsiUtil::safeDeparenthesize) ?: return null
    val ref = ((left as? KtQualifiedExpression)?.selectorExpression ?: left) as? KtNameReferenceExpression ?: return null
    return when (val target = ref.mainReference.resolve()) {
        is KtProperty -> target.takeIf { !it.isLocal }
        is KtParameter -> target.takeIf { it.hasValOrVar() }
        else -> null
    }
}

/** Whether [e] reads a property of [uncheckedFields] (`items`, `box.items`). */
internal fun FileTransformer.readsUncheckedField(e: KtExpression, unchecked: UncheckedCasts): Boolean = with(session) {
    if (unchecked.passed.isEmpty() && unchecked.castFields.isEmpty()) return false
    val inner = KtPsiUtil.safeDeparenthesize(e)
    val ref = ((inner as? KtQualifiedExpression)?.selectorExpression ?: inner) as? KtNameReferenceExpression ?: return false
    val fields = uncheckedFields(unchecked)
    if (ref.getReferencedName() !in fields.names) return false
    return ref.mainReference.resolve() in fields.fields
}
