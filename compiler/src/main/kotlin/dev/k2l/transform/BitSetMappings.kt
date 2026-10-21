package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/** `java.util.BitSet`, as in `BitSet.lua`: the JDK's members, messages, `size()` and `hashCode()`. */
internal object BitSetMappings {

    /** The members that are the Lua method of the same name; `and` and `or` are Lua keywords, so their methods are capitalized. */
    private val METHODS = setOf(
        "get", "set", "clear", "flip", "cardinality", "length", "size", "isEmpty", "nextSetBit", "nextClearBit", "previousSetBit",
        "previousClearBit", "intersects", "xor", "andNot", "clone", "equals", "hashCode", "toString", "toLongArray", "toByteArray",
    )

    fun construct(site: CallSite): LuaExpr = site.libNew(BITSET_TABLE, site.args)

    fun map(name: String, site: CallSite): LuaExpr? = when {
        site.receiver == null -> if (name == "valueOf") valueOf(site) else null

        name in METHODS -> method(site.self, name, *site.args.toTypedArray())

        name == "and" -> method(site.self, "And", site.arg(0))

        name == "or" -> method(site.self, "Or", site.arg(0))

        name == "stream" -> site.libCall(
            STREAMS_TABLE,
            "ofArray",
            listOf(site.ref("Streams", "__K2L_IntStream"), method(site.self, "____bits")),
        )

        else -> null
    }

    /** `BitSet.valueOf(longs)` and `valueOf(bytes)`; the `LongBuffer` and `ByteBuffer` overloads are not supported. */
    private fun valueOf(site: CallSite): LuaExpr? {
        val classId = with(site.session) { (site.argTypes.firstOrNull()?.withoutFlexibility as? KaClassType)?.classId?.asString() }
        val bytes = when (classId) {
            "kotlin/LongArray" -> false
            "kotlin/ByteArray" -> true
            else -> return null
        }
        return site.libCall(BITSET_TABLE, "valueOf", listOf(site.arg(0), LuaBool(bytes)))
    }
}
