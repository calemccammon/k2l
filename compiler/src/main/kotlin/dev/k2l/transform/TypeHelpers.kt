package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.types.Variance

context(s: KaSession)
val KaType.isIntegral: Boolean get() = with(s) {
    withoutFlexibility.let {
        it.isIntType || it.isLongType || it.isShortType || it.isByteType || it.isUIntType || it.isULongType || it.isUShortType ||
            it.isUByteType
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
