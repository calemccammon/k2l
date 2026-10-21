package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtClass

/** Lua feature with the helpers below, see `Extras.lua`. */
private const val EXTRAS_FEATURE = "Extras"

private fun CallSite.helper(member: String, vararg args: LuaExpr): LuaExpr =
    libMember(EXTRAS_FEATURE, "__K2L_Extras", member, *args.toList().dropTrailingNil().toTypedArray())

private fun CallSite.decode(bytes: LuaExpr): LuaExpr = helper("decode", bytes)

private fun CallSite.isByteArray(type: KaType?): Boolean =
    type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() } == "kotlin/ByteArray"

private fun asSequence(site: CallSite, list: LuaExpr): LuaExpr = LuaCall(site.ref(SEQUENCE_FEATURE, "__K2L_AsSequence"), listOf(list))

/**
 * More of `kotlin` (`Boolean.and`/`or`, `lazyOf`, `enumValues`/`enumValueOf`, `setOfNotNull`, `reduceRightOrNull` and
 * friends) and, through [ExtraTextMappings], of `kotlin.text`.
 */
internal object ExtraMappings {
    fun map(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
        null -> null

        "kotlin/Boolean.and" -> site.libMember("JavaUtil", "__K2L_JavaUtil", "logicalAnd", site.self, site.arg(0))

        "kotlin/Boolean.or" -> site.libMember("JavaUtil", "__K2L_JavaUtil", "logicalOr", site.self, site.arg(0))

        "kotlin/lazyOf" -> site.helper("lazyOf", site.arg(0))

        "kotlin/enumValues", "kotlin/enumValueOf" -> enumOf(callableId, site)

        "kotlin/collections/setOfNotNull" -> setOfNotNull(site)

        "kotlin/text/Charsets.UTF_8" -> LuaString("UTF-8")

        // a charset is its name
        "java/nio/charset/Charset.name", "java/nio/charset/Charset.displayName" -> site.receiver?.takeIf { site.args.isEmpty() }

        // bytes.toString(charset)
        "kotlin/collections/toString" -> site.takeIf {
            it.receiver != null && it.args.size == 1 && it.isByteArray(it.receiverType)
        }?.let { it.decode(it.self) }

        "kotlin/collections/reduceRightOrNull", "kotlin/collections/reduceRightIndexed", "kotlin/collections/reduceRightIndexedOrNull" ->
            reduceRight(callableId, site)

        "kotlin/text/Regex.splitToSequence" -> asSequence(site, LuaMethodCall(site.self, "split", site.args.dropTrailingNil()))

        else -> if (callableId.startsWith("kotlin/text/")) ExtraTextMappings.map(callableId.removePrefix("kotlin/text/"), site) else null
    }

    private fun reduceRight(callableId: String, site: CallSite): LuaExpr? = with(site) {
        val kind = receiverType?.let { with(session) { it.collectionKind() } }
        if (receiver == null || (kind != CollectionKind.List && kind != CollectionKind.Array)) return null
        val indexed = LuaBool("Indexed" in callableId)
        val orNull = LuaBool(callableId.endsWith("OrNull"))
        helper("reduceRight", self, arg(0), indexed, orNull, LuaString(if (kind == CollectionKind.Array) "array" else "list"))
    }

    private fun setOfNotNull(site: CallSite): LuaExpr {
        val list = LuaCall(site.ref(featureOf("__K2L_ListOf"), "__K2L_ListOf"), site.args)
        return LuaMethodCall(LuaMethodCall(list, "filterNotNull", emptyList()), "toSet", emptyList())
    }

    /** `enumValues<E>()` and `enumValueOf<E>(name)` of an enum class of the program (a reified `E` included). */
    private fun enumOf(callableId: String, site: CallSite): LuaExpr? = with(site.session) {
        val call = site.element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val declared = call.typeArgumentsMapping.values.firstOrNull() ?: return null
        val enum = site.transformer.reifiedType(declared).expandedSymbol?.psi as? KtClass ?: return null
        if (!enum.isEnum() || !site.transformer.classes.isSource(enum)) return null
        val cls = site.transformer.classRef(enum)
        if (callableId == "kotlin/enumValues") site.lualib("EnumValues", cls) else site.lualib("EnumValueOf", cls, site.arg(0))
    }
}

/**
 * More of `kotlin.text`: `replaceAfter` and friends, `toByte`/`toShort`, `splitToSequence`, `windowedSequence`/
 * `chunkedSequence`, the default `HexFormat`'s `toHexString`/`hexToInt`/..., `Char.isISOControl`, Kotlin's StringBuilder
 * extensions and decoding a ByteArray.
 */
private object ExtraTextMappings {
    private val REPLACE_AROUND = setOf("replaceAfter", "replaceBefore", "replaceAfterLast", "replaceBeforeLast")
    private val SMALL_PARSERS = mapOf("toByte" to 8, "toShort" to 16, "toByteOrNull" to 8, "toShortOrNull" to 16)
    private val HEX_PARSERS = mapOf("hexToInt" to 32, "hexToLong" to 64, "hexToShort" to 16, "hexToByte" to 8)
    private val BITS = mapOf("kotlin/Int" to 32, "kotlin/Long" to 64, "kotlin/Short" to 16, "kotlin/Byte" to 8)

    /** Kotlin's StringBuilder extensions that are a Java method under another name. */
    private val BUILDER_RENAMED = mapOf("deleteAt" to "deleteCharAt", "deleteRange" to "delete", "setRange" to "replace")

    fun map(name: String, site: CallSite): LuaExpr? = with(site) {
        if (receiver == null) return bytesString(name, site)
        val kind = receiverType?.let { with(session) { it.collectionKind() } }
        when {
            isTextual(receiverType) && !isChar(receiverType) -> stringMember(name, site)
            name == "toHexString" && args.isEmpty() -> toHex(this)
            name in BUILDER_RENAMED && kind == CollectionKind.StringBuilder -> LuaMethodCall(self, BUILDER_RENAMED.getValue(name), args)
            name == "isISOControl" && isChar(receiverType) -> TextMappings.charMember("code", this)?.let { helper("isISOControl", it) }
            name == "decodeToString" && args.isEmpty() && isByteArray(receiverType) -> decode(self)
            else -> null
        }
    }

    /** `String(bytes)`, `String(bytes, charset)`: the bytes are the UTF-8 of the string. */
    private fun bytesString(name: String, site: CallSite): LuaExpr? =
        if (name == "String" && site.isByteArray(site.argTypes.firstOrNull()) && site.args.size <= 2) site.decode(site.arg(0)) else null

    /** `x.toHexString()` of an Int, Long, Short, Byte or ByteArray. */
    private fun toHex(site: CallSite): LuaExpr? = with(site) {
        val classId = receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } }
        val bits = BITS[classId]
        when {
            bits != null -> helper("toHex", self, LuaNumber("$bits"))
            classId == "kotlin/ByteArray" -> helper("bytesToHex", self)
            else -> null
        }
    }

    /** Extensions of a String receiver. */
    private fun stringMember(name: String, site: CallSite): LuaExpr? = with(site) {
        val bits = SMALL_PARSERS[name]
        when {
            name in REPLACE_AROUND -> helper(name, self, *args.toTypedArray())

            bits != null -> {
                requireUtf16Case()
                helper(if (name.endsWith("OrNull")) "toSmallOrNull" else "toSmall", self, LuaNumber("$bits"), args.getOrElse(0) { LuaNil })
            }

            name == "splitToSequence" -> StdlibMappings.map("kotlin/text/split", renamed("split"))?.let { asSequence(this, it) }

            // the list of windowed/chunked as a Sequence
            name == "windowedSequence" || name == "chunkedSequence" -> {
                val eager = name.removeSuffix("Sequence")
                StdlibMappings.map("kotlin/text/$eager", renamed(eager))?.let { asSequence(this, it) }
            }

            // with the default HexFormat
            name in HEX_PARSERS && args.isEmpty() -> helper("hexTo", self, LuaNumber("${HEX_PARSERS[name]}"))

            name == "hexToByteArray" && args.isEmpty() -> helper("hexToBytes", self)

            else -> null
        }
    }

    private fun CallSite.renamed(newName: String) =
        CallSite(session, transformer, element, newName, receiver, receiverType, args, argTypes, parameterTypes)
}
