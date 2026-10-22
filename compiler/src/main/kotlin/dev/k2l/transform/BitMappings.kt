package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * Rotations, single-bit and bit-count functions of `Long`, and `Double.withSign`. The runtime is `Bits.lua`; its `.float`
 * variant serves Lua 5.1, 5.2 and LuaJIT, where `Long` is a double (32-bit bit operations).
 */
internal object BitMappings {
    fun install(t: MappingTable) {
        rotations(t)
        bitCounts(t)
        t.def("kotlin/math/withSign") { bits("withSign", self, arg(0)) }
    }

    private fun CallSite.bits(member: String, vararg args: LuaExpr) = libMember("Bits", "__K2L_Bits", member, *args)

    private fun CallSite.isLong(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isLongType }

    private fun rotations(t: MappingTable) {
        for ((name, negate) in listOf("rotateLeft" to false, "rotateRight" to true)) {
            t.def("kotlin/$name") {
                val count = if (negate) LuaUnary(LuaUnOp.Neg, arg(0)) else arg(0)
                when {
                    isByte(receiverType) -> smallRotation(count, Byte.SIZE_BITS)
                    isShort(receiverType) -> smallRotation(count, Short.SIZE_BITS)
                    isLong(receiverType) -> bits("rotl64", self, count)
                    isIntLike(receiverType) -> bits("rotl32", self, count)
                    else -> null
                }
            }
        }
    }

    private fun CallSite.isIntLike(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isIntType }

    private fun bitCounts(t: MappingTable) {
        val long = mapOf("takeHighestOneBit" to "highest", "takeLowestOneBit" to "lowest")
        for ((name, member) in long) {
            t.def("kotlin/$name") {
                when {
                    isLong(receiverType) && hasIntegers -> bits(member + "64", self)
                    isLong(receiverType) -> bits(member + "32", self)
                    isIntLike(receiverType) -> bits(member + "32", self)
                    else -> null
                }
            }
        }
        val counts = mapOf("countOneBits" to "ones64", "countTrailingZeroBits" to "ctz64", "countLeadingZeroBits" to "clz64")
        for ((name, member) in counts) {
            t.def("kotlin/$name") {
                when {
                    isLong(receiverType) && hasIntegers -> bits(member, self)
                    else -> libMember(NUM_TABLE, name, self)
                }
            }
        }
    }
}

/** `Byte` and `Short` rotate within their own width (see `Numbers.lua`). */
private fun CallSite.smallRotation(count: LuaExpr, bits: Int): LuaExpr =
    libMember(NUM_TABLE, "rotateSmall", self, count, LuaNumber("$bits"))

private fun CallSite.isByte(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isByteType }

private fun CallSite.isShort(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isShortType }
