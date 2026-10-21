package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/** The classes whose properties are fields of the Lua tables (and are assigned in a builder). */
internal val HEX_FORMAT_CLASSES = setOf(
    "kotlin/text/HexFormat",
    "kotlin/text/HexFormat.Builder",
    "kotlin/text/HexFormat.BytesHexFormat",
    "kotlin/text/HexFormat.BytesHexFormat.Builder",
    "kotlin/text/HexFormat.NumberHexFormat",
    "kotlin/text/HexFormat.NumberHexFormat.Builder",
)

/**
 * `HexFormat { }` with its builders, `HexFormat.Default`/`UpperCase`, and formatting or parsing numbers and byte arrays
 * with a format: `toHexString(format)`, `hexToInt(format)` and friends, `hexToByteArray(format)`.
 */
internal object HexFormatMappings {
    private val BITS = mapOf(
        "kotlin/Int" to 32,
        "kotlin/Long" to 64,
        "kotlin/Short" to 16,
        "kotlin/Byte" to 8,
        "kotlin/UInt" to 32,
        "kotlin/ULong" to 64,
        "kotlin/UShort" to 16,
        "kotlin/UByte" to 8,
    )
    private val PARSERS = mapOf("hexToInt" to 32, "hexToLong" to 64, "hexToShort" to 16, "hexToByte" to 8)
    private val UNSIGNED_CLASSES = setOf("kotlin/UInt", "kotlin/ULong", "kotlin/UShort", "kotlin/UByte")
    private val UNSIGNED_PARSERS = mapOf(
        "hexToUInt" to Unsigned.UInt,
        "hexToULong" to Unsigned.ULong,
        "hexToUShort" to Unsigned.UShort,
        "hexToUByte" to Unsigned.UByte,
    )

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId == null || !callableId.startsWith("kotlin/text/")) return null
        val owner = callableId.substringBeforeLast('.')
        val name = callableId.substringAfterLast('.').substringAfterLast('/')
        return when {
            callableId == "kotlin/text/HexFormat" && site.receiver == null && site.args.size == 1 -> site.hex("build", site.arg(0))

            owner == "kotlin/text/HexFormat.Companion" && (name == "Default" || name == "UpperCase") ->
                luaField(site.ref(HEX_FORMAT, "__K2L_HexFormat"), name)

            owner in HEX_FORMAT_CLASSES -> member(name, site)

            else -> formatted(name, site)
        }
    }

    private fun CallSite.hex(member: String, vararg args: LuaExpr): LuaExpr = libMember(HEX_FORMAT, "__K2L_HexFormat", member, *args)

    /** A property is a field; `bytes { }` and `number { }` configure that field. */
    private fun member(name: String, site: CallSite): LuaExpr? = with(site) {
        val receiver = receiver ?: return null
        when {
            args.isEmpty() -> LuaIndex(receiver, LuaString(name))
            (name == "bytes" || name == "number") && args.size == 1 -> hex("configure", LuaIndex(receiver, LuaString(name)), arg(0))
            else -> null
        }
    }

    /** `toHexString(startIndex, endIndex, format)` of a ByteArray. */
    private const val RANGE_ARGUMENTS = 3

    /** The functions that take a HexFormat. */
    private val FORMATTED = setOf("toHexString", "hexToByteArray") + PARSERS.keys + UNSIGNED_PARSERS.keys

    private fun formatted(name: String, site: CallSite): LuaExpr? = with(site) {
        val receiver = receiver ?: return null
        if (name !in FORMATTED) return null
        val classId = receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } }
        val unsigned = UNSIGNED_PARSERS[name]
        val format = format(unsigned != null || classId in UNSIGNED_CLASSES) ?: return null
        if (isString(receiverType)) return parse(name, receiver, format, unsigned)
        val bits = BITS[classId]
        when {
            name != "toHexString" -> null
            bits != null && args.size <= 1 -> hex("number", receiver, LuaNumber("$bits"), format)
            classId == "kotlin/ByteArray" && args.size == 1 -> hex("bytes", receiver, LuaNil, LuaNil, format)
            classId == "kotlin/ByteArray" && args.size == RANGE_ARGUMENTS -> hex("bytes", receiver, arg(0), arg(1), format)
            else -> null
        }
    }

    /** The format argument, or for the unsigned types (whose default format has no mapping in TextExtrasMappings) the default. */
    private fun CallSite.format(unsigned: Boolean): LuaExpr? = args.lastOrNull()?.takeIf { it != LuaNil }
        ?: if (unsigned) luaField(ref(HEX_FORMAT, "__K2L_HexFormat"), "Default") else null

    /** `hexToInt(format)` and friends, `hexToByteArray(format)`, and the unsigned parsers with or without a format. */
    private fun CallSite.parse(name: String, receiver: LuaExpr, format: LuaExpr, unsigned: Unsigned?): LuaExpr? = when {
        args.size > 1 -> null
        unsigned != null -> transformer.wrapUnsigned(unsigned, hex("parseNumber", receiver, LuaNumber("${unsigned.bits}"), format))
        name in PARSERS -> hex("parseNumber", receiver, LuaNumber("${PARSERS[name]}"), format)
        name == "hexToByteArray" -> hex("parseBytes", receiver, format)
        else -> null
    }
}
