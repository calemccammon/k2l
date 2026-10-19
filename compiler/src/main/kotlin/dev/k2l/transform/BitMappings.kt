package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `Math.*Exact`, rotations, single-bit and bit-count functions of `Long`, and the IEEE 754 helpers (`withSign`, `ulp`,
 * `nextUp`, `toBits` ...). The runtime is `Exact.lua` and `Bits.lua`; their `.float` variants serve Lua 5.1, 5.2 and
 * LuaJIT, where `Long` is a double (32-bit bit operations, and a `Double`'s 64-bit pattern is rounded to 53 bits).
 */
internal object BitMappings {
    fun install(t: MappingTable) {
        exact(t)
        rotations(t)
        bitCounts(t)
        ieee(t)
    }

    private fun CallSite.bits(member: String, vararg args: LuaExpr) = libMember("Bits", "__K2L_Bits", member, *args)

    private fun CallSite.exactMath(member: String, vararg args: LuaExpr) = libMember("Exact", "__K2L_Exact", member, *args)

    private fun CallSite.isLong(type: KaType?) =
        type != null && with(session) { type.withoutFlexibility.let { it.isLongType || it.isULongType } }

    private fun CallSite.isFloat(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isFloatType }

    private fun exact(t: MappingTable) {
        val binary = mapOf("addExact" to "add", "subtractExact" to "sub", "multiplyExact" to "mul")
        for ((name, member) in binary) {
            t.def("java/lang/Math.$name") { exactMath(if (argTypes.any { isLong(it) }) member + "Long" else member, arg(0), arg(1)) }
        }
        val unary = mapOf("negateExact" to "neg", "incrementExact" to "inc", "decrementExact" to "dec", "absExact" to "abs")
        for ((name, member) in unary) {
            t.def("java/lang/Math.$name") { exactMath(if (isLong(argTypes[0])) member + "Long" else member, arg(0)) }
        }
        t.def("java/lang/Math.toIntExact") { exactMath("toInt", arg(0)) }
    }

    private fun rotations(t: MappingTable) {
        for ((name, negate) in listOf("rotateLeft" to false, "rotateRight" to true)) {
            t.def("kotlin/$name", "kotlin/UInt.$name", "kotlin/ULong.$name", "kotlin/UByte.$name", "kotlin/UShort.$name") {
                val count = if (negate) LuaUnary(LuaUnOp.Neg, arg(0)) else arg(0)
                val unsigned = with(session) { unsignedOf(receiverType) }
                when {
                    unsigned == Unsigned.UInt -> transformer.wrapUnsigned(Unsigned.UInt, bits("rotl32", self, count))
                    unsigned == Unsigned.UByte || unsigned == Unsigned.UShort -> smallRotation(count, unsigned.bits, false)
                    unsigned != null && unsigned != Unsigned.ULong -> null
                    isByte(receiverType) -> smallRotation(count, Byte.SIZE_BITS, true)
                    isShort(receiverType) -> smallRotation(count, Short.SIZE_BITS, true)
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
                    isLong(receiverType) -> bits(member + "64", self)
                    isIntLike(receiverType) -> bits(member + "32", self)
                    else -> null
                }
            }
        }
        val counts = mapOf("countOneBits" to "ones64", "countTrailingZeroBits" to "ctz64", "countLeadingZeroBits" to "clz64")
        for ((name, member) in counts) {
            t.def("kotlin/$name") {
                if (isLong(receiverType) && transformer.ctx.options.luaTarget.hasIntegers) {
                    bits(member, self)
                } else {
                    libMember("Numbers", "__K2L_Num", name, self)
                }
            }
        }
    }

    private fun ieee(t: MappingTable) {
        t.def("kotlin/math/withSign") { bits("withSign", self, arg(0)) }
        t.def("kotlin/math/ulp") { bits(if (isFloat(receiverType)) "ulpF" else "ulp", self) }
        t.def("kotlin/math/nextUp") { bits(if (isFloat(receiverType)) "nextUpF" else "nextUp", self) }
        t.def("kotlin/math/nextDown") { bits(if (isFloat(receiverType)) "nextDownF" else "nextDown", self) }
        t.def("kotlin/math/nextTowards") { bits(if (isFloat(receiverType)) "nextTowardsF" else "nextTowards", self, arg(0)) }
        t.def("kotlin/toBits") { bits(if (isFloat(receiverType)) "floatBits" else "doubleBits", self) }
        t.def("kotlin/toRawBits") { bits(if (isFloat(receiverType)) "floatRawBits" else "doubleRawBits", self) }
        t.def("kotlin/fromBits") { bits(if (isLong(argTypes[0])) "doubleFromBits" else "floatFromBits", arg(0)) }
        t.def("java/lang/Double.doubleToLongBits") { bits("doubleBits", arg(0)) }
        t.def("java/lang/Double.doubleToRawLongBits") { bits("doubleRawBits", arg(0)) }
        t.def("java/lang/Double.longBitsToDouble") { bits("doubleFromBits", arg(0)) }
        t.def("java/lang/Float.floatToIntBits") { bits("floatBits", arg(0)) }
        t.def("java/lang/Float.floatToRawIntBits") { bits("floatRawBits", arg(0)) }
        t.def("java/lang/Float.intBitsToFloat") { bits("floatFromBits", arg(0)) }
        t.def("java/lang/Math.copySign") { bits("withSign", arg(0), arg(1)) }
        t.def("java/lang/Math.ulp") { bits(if (isFloat(argTypes[0])) "ulpF" else "ulp", arg(0)) }
        t.def("java/lang/Math.nextUp") { bits(if (isFloat(argTypes[0])) "nextUpF" else "nextUp", arg(0)) }
        t.def("java/lang/Math.nextDown") { bits(if (isFloat(argTypes[0])) "nextDownF" else "nextDown", arg(0)) }
        t.def("java/lang/Math.nextAfter") { bits(if (isFloat(argTypes[0])) "nextTowardsF" else "nextTowards", arg(0), arg(1)) }
    }
}

/** `Byte`, `Short`, `UByte` and `UShort` rotate within their own width (see `Numbers.lua`). */
private fun CallSite.smallRotation(count: LuaExpr, bits: Int, signed: Boolean): LuaExpr =
    libMember("Numbers", "__K2L_Num", "rotateSmall", self, count, LuaNumber("$bits"), LuaBool(signed))

private fun CallSite.isByte(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isByteType }

private fun CallSite.isShort(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isShortType }
