package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.types.Variance

context(s: KaSession)
val KaType.isIntegral: Boolean get() = with(s) { isIntType || isLongType || isShortType || isByteType }

context(s: KaSession)
val KaType.isNumber: Boolean get() = with(s) { !isMarkedNullable && (isIntegral || isDoubleType || isFloatType) }

context(s: KaSession)
val KaType?.isTextual: Boolean get() = with(s) { this@isTextual != null && !isMarkedNullable && (isStringType || isCharType) }

@OptIn(KaExperimentalApi::class)
context(s: KaSession)
fun KaType?.pretty(): String = with(s) { this@pretty?.render(position = Variance.INVARIANT) ?: "?" }
