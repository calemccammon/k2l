package dev.k2l.transform

import dev.k2l.codegen.*

/**
 * The `java.lang` box statics (`Integer.bitCount(x)`, `Long.toHexString(x)`, `Double.isNaN(x)`,
 * `String.join(...)`) that ported Java code uses. Most are a Kotlin member under another name, so they reuse its mapping with
 * the first argument as the receiver; with `--long64 emulate` the `Long` ones are mapped in [Long64Mappings] first.
 */
internal object JavaStaticMappings {
    private val AS_EXTENSION = mapOf(
        "bitCount" to "kotlin/countOneBits",
        "numberOfTrailingZeros" to "kotlin/countTrailingZeroBits",
        "numberOfLeadingZeros" to "kotlin/countLeadingZeroBits",
        "highestOneBit" to "kotlin/takeHighestOneBit",
        "lowestOneBit" to "kotlin/takeLowestOneBit",
        "rotateLeft" to "kotlin/rotateLeft",
        "rotateRight" to "kotlin/rotateRight",
        "signum" to "kotlin/math/sign",
    )

    private val LONG_RADIX = mapOf("toBinaryString" to 1, "toOctalString" to 3, "toHexString" to 4)

    fun install(t: MappingTable) {
        for (box in listOf("Integer", "Long")) {
            for ((java, kotlin) in AS_EXTENSION) t.def("java/lang/$box.$java") { asExtension(kotlin) }
            for (fn in listOf("max", "min")) t.def("java/lang/$box.$fn") { StdlibMappings.map("java/lang/Math.$fn", this) }
        }
        t.def("java/lang/Integer.reverse") { n("reverseInt", arg(0)) }
        t.def("java/lang/Integer.toUnsignedString") { n("toRadixUnsigned", arg(0), args.getOrElse(1) { num("10") }) }
        for ((name, shift) in LONG_RADIX) {
            t.def("java/lang/Long.$name") {
                if (hasIntegers) {
                    libCall(UNSIGNED_TABLE, "toRadix", listOf(arg(0), num("${1 shl shift}")))
                } else {
                    n("longToUnsignedRadix", arg(0), num("$shift"))
                }
            }
        }
        for (name in listOf("isNaN", "isInfinite", "isFinite")) {
            t.def("java/lang/Double.$name", "java/lang/Float.$name") { asExtension("kotlin/$name") }
        }
        t.def("java/lang/Double.valueOf") {
            if (isTextual(argTypes.firstOrNull())) LuaCall(ref("Strings", "__K2L_StringToDouble"), listOf(arg(0))) else arg(0)
        }
        t.def("java/lang/Double.toString", "java/lang/Boolean.toString") {
            if (args.size == 1) str(arg(0), overloadType(0)) else null
        }
        t.def("java/lang/Boolean.parseBoolean") {
            LuaBinary(LuaBinOp.Eq, lua("string.lower", LuaBinary(LuaBinOp.Or, arg(0), LuaString(""))), LuaString("true"))
        }
        textStatics(t)
        JavaIntegerStatics.install(t)
        JavaMathStatics.install(t)
    }

    private fun textStatics(t: MappingTable) {
        // String.valueOf(char[]) is the text of the array, everything else prints like toString()
        t.def("java/lang/String.valueOf") {
            when {
                args.size != 1 -> null
                with(session) { overloadType(0)?.expandedSymbol?.classId?.asString() == "kotlin/CharArray" } -> null
                else -> str(arg(0), argTypes[0])
            }
        }
        t.def("java/lang/String.join") {
            val elements = args.drop(1)
            val single = elements.singleOrNull()
            if (single != null && !isTextual(argTypes[1])) {
                method(single, "joinToString", arg(0))
            } else {
                lua("table.concat", LuaTable(elements.map { LuaField.Positional(it) }), arg(0))
            }
        }
    }

    private fun CallSite.n(member: String, vararg args: LuaExpr) = libMember(NUM_TABLE, member, *args)

    /** The mapping of the Kotlin extension [id], called on the first argument. */
    private fun CallSite.asExtension(id: String): LuaExpr? {
        if (args.isEmpty()) return null
        val site = CallSite(
            session,
            transformer,
            element,
            name,
            arg(0),
            overloadType(0),
            args.drop(1),
            argTypes.drop(1),
            parameterTypes.drop(1),
        )
        return StdlibMappings.map(id, site)
    }
}
