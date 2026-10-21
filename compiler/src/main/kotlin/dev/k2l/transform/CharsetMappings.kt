package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** Charsets and the bytes of strings: `Charsets.UTF_8`, `bytes.toString(charset)`, `String(bytes)`, `decodeToString()`. */
internal object CharsetMappings {
    fun map(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
        "kotlin/text/Charsets.UTF_8" -> LuaString("UTF-8")

        // a charset is its name
        "java/nio/charset/Charset.name", "java/nio/charset/Charset.displayName" -> site.receiver?.takeIf { site.args.isEmpty() }

        // bytes.toString(charset)
        "kotlin/collections/toString" -> site.takeIf {
            it.receiver != null && it.args.size == 1 && it.isByteArray(it.receiverType)
        }?.let { it.decode(it.self) }

        // `String(bytes)`, `String(bytes, charset)`: the bytes are the UTF-8 of the string
        "kotlin/text/String" -> site.takeIf {
            it.receiver == null && it.isByteArray(it.argTypes.firstOrNull()) && it.args.size <= 2
        }?.let { it.decode(it.arg(0)) }

        "kotlin/text/decodeToString" -> site.takeIf {
            it.receiver != null && it.args.isEmpty() && it.isByteArray(it.receiverType)
        }?.let { it.decode(it.self) }

        else -> null
    }

    private fun CallSite.decode(bytes: LuaExpr): LuaExpr = extrasMember("decode", bytes)

    private fun CallSite.isByteArray(type: KaType?): Boolean =
        type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() } == "kotlin/ByteArray"
}
