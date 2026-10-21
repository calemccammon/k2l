package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

private fun CallSite.jn(member: String, vararg args: LuaExpr) = libMember(JAVA_NUMBERS_TABLE, member, *args)

private fun CallSite.jl(member: String, vararg args: LuaExpr) = libMember(JAVA_LONGS_TABLE, member, *args)

private fun CallSite.isLongType(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isLongType }

private fun CallSite.isFloatType(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isFloatType }

private fun CallSite.anyLong() = argTypes.any { isLongType(it) } || parameterTypes.any { isLongType(it) }

/**
 * The less common statics of `java.lang.Integer` and `Long` (see `JavaNumbers.lua` and `JavaLongs.lua`):
 * unsigned arithmetic, `decode`, the bit permutations and system properties, which Lua has none of.
 */
internal object JavaIntegerStatics {
    private val INT_UNSIGNED = listOf("compareUnsigned", "divideUnsigned", "remainderUnsigned", "toUnsignedLong")
    private val LONG_UNSIGNED = listOf("compareUnsigned", "divideUnsigned", "remainderUnsigned", "toUnsignedString")

    fun install(t: MappingTable) {
        integers(t)
        longs(t)
        t.def("java/lang/Double.toHexString") { jn("toHexString", arg(0)) }
        t.def("java/lang/Boolean.getBoolean") { jn("property", arg(0), LuaBool(false)) }
    }

    private fun integers(t: MappingTable) {
        for (name in INT_UNSIGNED) t.def("java/lang/Integer.$name") { jn(name, *args.toTypedArray()) }
        t.def("java/lang/Integer.parseUnsignedInt") { if (args.size <= 2) jn("parseUnsignedInt", *args.toTypedArray()) else null }
        t.def("java/lang/Integer.decode") { jn("decode", arg(0)) }
        for (name in listOf("reverseBytes", "compress", "expand")) t.def("java/lang/Integer.$name") { jn(name, *args.toTypedArray()) }
        t.def("java/lang/Integer.sum") { transformer.arithmetic(LuaBinOp.Add, arg(0), argTypes[0], arg(1), argTypes[1]) }
        t.def("java/lang/Integer.getInteger") { jn("property", arg(0), args.getOrElse(1) { LuaNil }) }
    }

    /** With `--long64 emulate` the unsigned functions are mapped in [Long64Mappings] first. */
    private fun longs(t: MappingTable) {
        for (name in LONG_UNSIGNED) t.def("java/lang/Long.$name") { jl(name, *args.toTypedArray()) }
        t.def("java/lang/Long.parseUnsignedLong") { if (args.size <= 2) jl("parseUnsigned", *args.toTypedArray()) else null }
        t.def("java/lang/Long.decode") {
            if (transformer.emulatesLong) {
                transformer.l64x(
                    "parseOrThrow",
                    jn("decodePrep", arg(0)),
                )
            } else {
                jn("decode", arg(0), LuaBool(true))
            }
        }
        val bits = mapOf(
            "reverse" to "reverseLong",
            "reverseBytes" to "reverseBytesLong",
            "compress" to "compressLong",
            "expand" to "expandLong",
        )
        for ((name, member) in bits) t.def("java/lang/Long.$name") { jn(member, *args.toTypedArray()) }
        t.def("java/lang/Long.sum") { transformer.arithmetic(LuaBinOp.Add, arg(0), argTypes[0], arg(1), argTypes[1]) }
        t.def("java/lang/Long.getLong") { jn("property", arg(0), args.getOrElse(1) { LuaNil }) }
    }
}

/**
 * `java.lang.Math`'s `ceilDiv`, `ceilMod`, the `*Exact` divisions, `clamp`, `fma`, `scalb`, `getExponent`, `multiplyFull` and
 * `multiplyHigh`: Int ones in `JavaNumbers.lua`, Long ones in `JavaLongs.lua` (or its `.float` and `.l64` variants).
 */
internal object JavaMathStatics {
    private val DIVISIONS = listOf("ceilDiv", "ceilMod", "divideExact", "floorDivExact", "ceilDivExact")

    fun install(t: MappingTable) {
        for (name in DIVISIONS) {
            t.def("java/lang/Math.$name", "java/lang/StrictMath.$name") {
                if (anyLong()) jl(name, arg(0), arg(1)) else jn(name, arg(0), arg(1))
            }
        }
        t.def("java/lang/Math.clamp", "java/lang/StrictMath.clamp") { clamp() }
        t.def("java/lang/Math.fma", "java/lang/StrictMath.fma") {
            val result = jn("fma", *args.toTypedArray())
            if (isFloatType(argTypes[0])) transformer.fround(result) else result
        }
        t.def("java/lang/Math.getExponent", "java/lang/StrictMath.getExponent") {
            if (isFloatType(argTypes[0])) jn("getExponent", arg(0), LuaBool(true)) else jn("getExponent", arg(0))
        }
        t.def("java/lang/Math.scalb", "java/lang/StrictMath.scalb") {
            if (isFloatType(argTypes[0])) transformer.fround(jn("scalbF", arg(0), arg(1))) else jn("scalb", arg(0), arg(1))
        }
        t.def("java/lang/Math.multiplyFull", "java/lang/StrictMath.multiplyFull") {
            if (transformer.emulatesLong) transformer.l64("Mul", arg(0), arg(1)) else LuaBinary(LuaBinOp.Mul, arg(0), arg(1))
        }
        for (name in listOf("multiplyHigh", "unsignedMultiplyHigh")) {
            t.def("java/lang/Math.$name", "java/lang/StrictMath.$name") { jn(name, arg(0), arg(1)) }
        }
    }

    /** `clamp(value, min, max)`: of Doubles or Floats (the message prints the bounds as such), or of a Long within Ints or Longs. */
    private fun CallSite.clamp(): LuaExpr = when {
        isFloatType(argTypes[0]) || isFloatType(parameterTypes.getOrNull(0)) ->
            jn("clampD", arg(0), arg(1), arg(2), ref("FloatToString", "__K2L_FloatToString"))

        isFloating(parameterTypes.getOrNull(0) ?: argTypes[0]) ->
            jn("clampD", arg(0), arg(1), arg(2), ref("DoubleToString", "__K2L_DoubleToString"))

        else -> jl("clamp", arg(0), arg(1), arg(2))
    }
}
