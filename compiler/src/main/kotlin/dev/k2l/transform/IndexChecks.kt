package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaVariableSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

/**
 * `xs[i]` and `s[i]` are bounds-checked (`xs:get(i)`, `__K2L_StringCharAt(s, i)`), except where the
 * index is provably in range: the variable of a loop over exactly that collection's indices,
 * `for (i in xs.indices)`, `for (i in 0 until xs.size)`, `for (i in xs.size - 1 downTo 0)` and the like. Those keep the
 * direct `xs[i + 1]` access, so index loops over arrays and strings stay fast.
 */
internal fun FileTransformer.isProvenIndex(element: KtExpression?, type: KaType?): Boolean = with(session) {
    val access = element as? KtArrayAccessExpression ?: return false
    val array = KtPsiUtil.safeDeparenthesize(access.arrayExpression ?: return false) as? KtNameReferenceExpression ?: return false
    val index = KtPsiUtil.safeDeparenthesize(access.indexExpressions.singleOrNull() ?: return false) as? KtNameReferenceExpression
        ?: return false
    if (!isFixedSize(array, type)) return false
    val loop = (index.mainReference.resolve() as? KtParameter)?.let { p ->
        (p.parent as? KtForExpression)?.takeIf { it.loopParameter == p }
    }
    val range = loop?.loopRange?.let { KtPsiUtil.safeDeparenthesize(it) } ?: return false
    return coversIndicesOf(range, array)
}

/** A `val` (or parameter) of array, `List` (not `MutableList`) or `String` type: its size cannot change in the loop. */
private fun KaSession.isFixedSize(array: KtNameReferenceExpression, type: KaType?): Boolean {
    val symbol = array.mainReference.resolveToSymbol()
    val stable = symbol is KaVariableSymbol && symbol.isVal
    val kind = type?.collectionKind()
    val fixedType = type?.isStringType == true || kind == CollectionKind.Array ||
        (kind == CollectionKind.List && type.expandedSymbol?.classId?.asString() == "kotlin/collections/List")
    return stable && fixedType
}

private fun KaSession.coversIndicesOf(range: KtExpression, array: KtNameReferenceExpression): Boolean {
    val qualified = range as? KtDotQualifiedExpression
    if (qualified != null) {
        val selector = (qualified.selectorExpression as? KtNameReferenceExpression)?.getReferencedName()
        return selector == "indices" && isSameVariable(qualified.receiverExpression, array)
    }
    val r = parseRange(range) ?: return false
    return when {
        r.step != null -> false
        r.descending -> isZero(r.last) && isLength(r.first, array, minusOne = true)
        r.inclusive -> isZero(r.first) && isLength(r.last, array, minusOne = true)
        else -> isZero(r.first) && isLength(r.last, array, minusOne = false)
    }
}

private fun isSameVariable(e: KtExpression?, array: KtNameReferenceExpression): Boolean =
    (e as? KtNameReferenceExpression)?.mainReference?.resolve()?.let { it == array.mainReference.resolve() } == true

private fun KaSession.isZero(e: KtExpression) = e.evaluate()?.value == 0

/** `xs.size`, `xs.length` (when [minusOne] is false) or `xs.lastIndex` / `xs.size - 1` (when true). */
private fun KaSession.isLength(e: KtExpression, array: KtNameReferenceExpression, minusOne: Boolean): Boolean {
    val ex = KtPsiUtil.safeDeparenthesize(e)
    if (minusOne && ex is KtBinaryExpression && ex.operationReference.text == "-") {
        return ex.right?.evaluate()?.value == 1 && ex.left?.let { isLength(it, array, false) } == true
    }
    val q = ex as? KtDotQualifiedExpression ?: return false
    val name = (q.selectorExpression as? KtNameReferenceExpression)?.getReferencedName()
    val expected = if (minusOne) listOf("lastIndex") else listOf("size", "length")
    return name in expected && isSameVariable(q.receiverExpression, array)
}
