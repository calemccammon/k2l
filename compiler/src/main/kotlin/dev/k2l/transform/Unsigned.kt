package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * The unsigned types (`UInt`, `ULong`, `UByte`, `UShort`, their arrays and ranges) are not supported: Lua has no unsigned
 * numbers, and k2l does not emulate them. An expression of one of these types is reported, see [unsignedTypeName].
 */
private val UNSIGNED_CLASSES = setOf(
    "kotlin/UInt", "kotlin/ULong", "kotlin/UByte", "kotlin/UShort",
    "kotlin/UIntArray", "kotlin/ULongArray", "kotlin/UByteArray", "kotlin/UShortArray",
    "kotlin/ranges/UIntRange", "kotlin/ranges/ULongRange", "kotlin/ranges/UIntProgression", "kotlin/ranges/ULongProgression",
)

/** The name of the unsigned type [t] (`UInt`), or null when it is not one. */
internal fun KaSession.unsignedTypeName(t: KaType?): String? {
    val classId = (t?.withoutFlexibility as? KaClassType)?.classId ?: return null
    return classId.shortClassName.asString().takeIf { classId.asString() in UNSIGNED_CLASSES }
}
