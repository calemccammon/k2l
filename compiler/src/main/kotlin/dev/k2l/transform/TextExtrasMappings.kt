package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/** A member of the lualib's `__K2L_Extras` (`Extras.lua`), with trailing nil arguments dropped. */
internal fun CallSite.extrasMember(member: String, vararg args: LuaExpr): LuaExpr =
    libMember(EXTRAS_TABLE, member, *args.toList().dropTrailingNil().toTypedArray())

private fun asSequence(site: CallSite, list: LuaExpr): LuaExpr = LuaCall(site.ref(SEQUENCE_FEATURE, "__K2L_AsSequence"), listOf(list))

/**
 * More of `kotlin.text`: `replaceAfter` and friends, `toByte`/`toShort`, `splitToSequence`, `windowedSequence`/
 * `chunkedSequence`, the default `HexFormat`'s `toHexString`/`hexToInt`/..., `Char.isISOControl` and Kotlin's StringBuilder
 * extensions.
 */
internal object TextExtrasMappings {
    private val REPLACE_AROUND = setOf("replaceAfter", "replaceBefore", "replaceAfterLast", "replaceBeforeLast")
    private val SMALL_PARSERS = mapOf("toByte" to 8, "toShort" to 16, "toByteOrNull" to 8, "toShortOrNull" to 16)
    private val HEX_PARSERS = mapOf("hexToInt" to 32, "hexToLong" to 64, "hexToShort" to 16, "hexToByte" to 8)
    private val BITS = mapOf("kotlin/Int" to 32, "kotlin/Long" to 64, "kotlin/Short" to 16, "kotlin/Byte" to 8)

    /** Kotlin's StringBuilder extensions that are a Java method under another name. */
    private val BUILDER_RENAMED = mapOf("deleteAt" to "deleteCharAt", "deleteRange" to "delete", "setRange" to "replace")

    fun map(callableId: String?, site: CallSite): LuaExpr? = when {
        callableId == "kotlin/text/Regex.splitToSequence" ->
            asSequence(site, LuaMethodCall(site.self, "split", site.args.dropTrailingNil()))

        callableId?.startsWith("kotlin/text/") == true -> member(callableId.removePrefix("kotlin/text/"), site)

        else -> null
    }

    private fun member(name: String, site: CallSite): LuaExpr? = with(site) {
        if (receiver == null) return null
        val kind = receiverKind
        when {
            isTextual(receiverType) && !isChar(receiverType) -> stringMember(name, site)

            name == "toHexString" && args.isEmpty() -> toHex(this)

            name in BUILDER_RENAMED && kind == CollectionKind.StringBuilder -> LuaMethodCall(self, BUILDER_RENAMED.getValue(name), args)

            name == "isISOControl" && isChar(receiverType) -> TextMappings.charMember("code", this)?.let {
                extrasMember("isISOControl", it)
            }

            else -> null
        }
    }

    /** `x.toHexString()` of an Int, Long, Short, Byte or ByteArray. */
    private fun toHex(site: CallSite): LuaExpr? = with(site) {
        val classId = receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } }
        val bits = BITS[classId]
        when {
            bits != null -> extrasMember("toHex", self, LuaNumber("$bits"))
            classId == "kotlin/ByteArray" -> extrasMember("bytesToHex", self)
            else -> null
        }
    }

    /** Extensions of a String receiver. */
    private fun stringMember(name: String, site: CallSite): LuaExpr? = with(site) {
        val bits = SMALL_PARSERS[name]
        when {
            name in REPLACE_AROUND -> extrasMember(name, self, *args.toTypedArray())

            bits != null -> {
                requireUtf16Case()
                extrasMember(
                    if (name.endsWith("OrNull")) "toSmallOrNull" else "toSmall",
                    self,
                    LuaNumber("$bits"),
                    args.getOrElse(0) { LuaNil },
                )
            }

            name == "splitToSequence" -> StdlibMappings.map("kotlin/text/split", renamed("split"))?.let { asSequence(this, it) }

            // the list of windowed/chunked as a Sequence
            name == "windowedSequence" || name == "chunkedSequence" -> {
                val eager = name.removeSuffix("Sequence")
                StdlibMappings.map("kotlin/text/$eager", renamed(eager))?.let { asSequence(this, it) }
            }

            // with the default HexFormat
            name in HEX_PARSERS && args.isEmpty() -> extrasMember("hexTo", self, LuaNumber("${HEX_PARSERS[name]}"))

            name == "hexToByteArray" && args.isEmpty() -> extrasMember("hexToBytes", self)

            else -> null
        }
    }

    private fun CallSite.renamed(newName: String) = copy(name = newName)
}
