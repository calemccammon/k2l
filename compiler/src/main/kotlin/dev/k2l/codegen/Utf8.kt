package dev.k2l.codegen

private const val SURROGATE_LEAD = 0xED
private const val SURROGATE_SECOND_MIN = 0xA0
private const val BYTE_MASK = 0xFF
private const val SURROGATE_BYTES = 3
private const val SIX_BITS = 0x3F
private const val CONTINUATION = 0x80
private const val THREE_BYTE_LEAD = 0xE0
private const val SHIFT_HIGH = 12
private const val SHIFT_MID = 6

/** UTF-8, except that a lone surrogate gets its 3-byte generalized form (Java would write `?`). */
internal fun utf8(s: String): ByteArray {
    if (s.none { it.isSurrogate() }) return s.toByteArray(Charsets.UTF_8)
    val out = java.io.ByteArrayOutputStream()
    var i = 0
    while (i < s.length) {
        val c = s[i]
        val paired = c.isHighSurrogate() && i + 1 < s.length && s[i + 1].isLowSurrogate()
        when {
            paired -> out.write(s.substring(i, i + 2).toByteArray(Charsets.UTF_8))

            c.isSurrogate() -> {
                out.write(THREE_BYTE_LEAD or (c.code shr SHIFT_HIGH))
                out.write(CONTINUATION or ((c.code shr SHIFT_MID) and SIX_BITS))
                out.write(CONTINUATION or (c.code and SIX_BITS))
            }

            else -> out.write(c.toString().toByteArray(Charsets.UTF_8))
        }
        i += if (paired) 2 else 1
    }
    return out.toByteArray()
}

/** Is there the 3-byte form of a surrogate (not valid UTF-8) at [i]? */
internal fun isLoneSurrogate(bytes: ByteArray, i: Int): Boolean =
    i + SURROGATE_BYTES <= bytes.size && (bytes[i].toInt() and BYTE_MASK) == SURROGATE_LEAD &&
        (bytes[i + 1].toInt() and BYTE_MASK) >= SURROGATE_SECOND_MIN
