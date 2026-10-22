package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaCapturedType
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeArgumentWithVariance
import org.jetbrains.kotlin.types.Variance

/**
 * Java platform types (`T!`) are flexible; their lower bound is the Kotlin type. An element read from an `out`-projected
 * container (`rows[0]` of a `vararg rows: DoubleArray`, an `Array<out IntArray>`) has a captured type, which stands for its bound.
 */
val KaType.withoutFlexibility: KaType get() = when (this) {
    is KaFlexibleType -> lowerBound

    is KaCapturedType -> (projection as? KaTypeArgumentWithVariance)?.takeIf { it.variance != Variance.IN_VARIANCE }?.type
        ?.withoutFlexibility ?: this

    else -> this
}

/** The first type argument: the element type of a collection, array or sequence. */
context(s: KaSession)
val KaType.elementType: KaType? get() = (withoutFlexibility as? KaClassType)?.typeArguments?.firstOrNull()?.type

context(s: KaSession)
val KaType.isIntegral: Boolean get() = with(s) {
    withoutFlexibility.let {
        it.isIntType || it.isLongType || it.isShortType || it.isByteType
    }
}

context(s: KaSession)
val KaType.isNumber: Boolean get() = with(s) {
    withoutFlexibility.let { !it.isMarkedNullable && (it.isIntegral || it.isDoubleType || it.isFloatType) }
}

context(s: KaSession)
val KaType?.isTextual: Boolean get() = with(s) {
    this@isTextual?.withoutFlexibility.let { it != null && !it.isMarkedNullable && (it.isStringType || it.isCharType) }
}

@OptIn(KaExperimentalApi::class)
context(s: KaSession)
fun KaType?.pretty(): String = with(s) { this@pretty?.render(position = Variance.INVARIANT) ?: "?" }

/** `Double` or `Float`. */
internal fun KaSession.isFloating(t: KaType?): Boolean = t != null && t.withoutFlexibility.let { it.isDoubleType || it.isFloatType }
