package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/** A Kotlin `..`/`until`/`downTo` range, optionally with a `step`. */
internal class KRange(
    val first: KtExpression,
    val last: KtExpression,
    val inclusive: Boolean,
    val descending: Boolean,
    val step: KtExpression? = null,
)

/** The range [e] spells out, or null if it is not a range expression. */
internal fun KaSession.parseRange(e: KtExpression): KRange? {
    val ex = KtPsiUtil.safeDeparenthesize(e) as? KtBinaryExpression ?: return null
    val left = ex.left ?: return null
    val right = ex.right ?: return null
    return when (ex.operationToken) {
        KtTokens.RANGE -> KRange(left, right, inclusive = true, descending = false)
        KtTokens.RANGE_UNTIL -> KRange(left, right, inclusive = false, descending = false)
        KtTokens.IDENTIFIER -> {
            val id = (ex.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>())
                ?.partiallyAppliedSymbol?.symbol?.callableId?.toString() ?: return null
            if (!id.startsWith("kotlin/ranges/")) return null
            when (ex.operationReference.getReferencedName()) {
                "until" -> KRange(left, right, inclusive = false, descending = false)
                "downTo" -> KRange(left, right, inclusive = true, descending = true)
                "step" -> parseRange(left)?.takeIf { it.step == null }
                    ?.let { KRange(it.first, it.last, it.inclusive, it.descending, right) }
                else -> null
            }
        }
        else -> null
    }
}
