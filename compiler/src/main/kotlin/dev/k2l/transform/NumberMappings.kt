package dev.k2l.transform

import dev.k2l.codegen.*

/** kotlin.math, numeric members, `Char` members and the `java.lang` statics Kotlin code reaches for. */
@Suppress("TooManyFunctions") // one small installer per group of numeric members
internal object NumberMappings {
    private val INTEGRAL = listOf("Int", "Long", "Short", "Byte")
    private val FLOATING = listOf("Double", "Float")
    private val MIN_MAX_ARITY = 2..Int.MAX_VALUE

    fun install(t: MappingTable) {
        elementary(t)
        hyperbolicAndLogs(t)
        rounding(t)
        coercions(t)
        integerMembers(t)
        floatingMembers(t)
        charMembers(t)
        javaStatics(t)
        system(t)
    }

    private fun CallSite.n(member: String, vararg args: LuaExpr) = libMember("Numbers", "__K2L_Num", member, *args)

    private fun CallSite.arithmetic(op: LuaBinOp) = transformer.arithmetic(op, self, receiverType, arg(0), argTypes[0])

    private fun floatPlusZero(e: LuaExpr) = LuaBinary(LuaBinOp.Add, e, num("0.0"))

    private fun elementary(t: MappingTable) {
        t.def("kotlin/comparisons/maxOf", "kotlin/math/max") { extreme("max") }
        t.def("kotlin/comparisons/minOf", "kotlin/math/min") { extreme("min") }
        t.def("kotlin/math/abs") { lua("math.abs", arg(0)) }
        t.def("kotlin/math/absoluteValue") { lua("math.abs", self) }
        t.def("kotlin/math/sqrt") { lua("math.sqrt", arg(0)) }
        t.def("kotlin/math/sin") { lua("math.sin", arg(0)) }
        t.def("kotlin/math/cos") { lua("math.cos", arg(0)) }
        t.def("kotlin/math/tan") { lua("math.tan", arg(0)) }
        t.def("kotlin/math/asin") { lua("math.asin", arg(0)) }
        t.def("kotlin/math/acos") { lua("math.acos", arg(0)) }
        t.def("kotlin/math/atan") { lua("math.atan", arg(0)) }
        t.def("kotlin/math/atan2") { n("atan2", arg(0), arg(1)) }
        t.def("kotlin/math/exp") { lua("math.exp", arg(0)) }
        t.def("kotlin/math/pow") { LuaBinary(LuaBinOp.Pow, self, arg(0)) }
        t.def("kotlin/math/PI") { luaPath("math", "pi") }
        t.def("kotlin/math/E") { lua("math.exp", num("1")) }
        t.def("kotlin/math/sign") {
            val type = receiverType ?: argTypes.firstOrNull()
            n(if (isIntegral(type)) "signInt" else "signDouble", receiver ?: arg(0))
        }
    }

    /** `maxOf(a, b)` of numbers is `math.max`; other comparables go through `compareTo`. */
    private fun CallSite.extreme(fn: String): LuaExpr? {
        if (args.size !in MIN_MAX_ARITY) return null
        val numeric = argTypes.all { it != null && (isIntegral(it) || isFloating(it)) }
        return when {
            numeric -> lua("math.$fn", *args.toTypedArray())
            args.size == 2 -> libMember("Numbers", "__K2L_Num", fn + "Of", arg(0), arg(1))
            else -> null
        }
    }

    private fun hyperbolicAndLogs(t: MappingTable) {
        t.def("kotlin/math/sinh") { n("sinh", arg(0)) }
        t.def("kotlin/math/cosh") { n("cosh", arg(0)) }
        t.def("kotlin/math/tanh") { n("tanh", arg(0)) }
        t.def("kotlin/math/ln") { lua("math.log", arg(0)) }
        t.def("kotlin/math/ln1p") { n("ln1p", arg(0)) }
        t.def("kotlin/math/expm1") { n("expm1", arg(0)) }
        t.def("kotlin/math/log10") { n("log10", arg(0)) }
        t.def("kotlin/math/log2") { n("log2", arg(0)) }
        t.def("kotlin/math/log") { n("log", arg(0), arg(1)) }
        t.def("kotlin/math/hypot") { n("hypot", arg(0), arg(1)) }
        t.def("kotlin/math/cbrt") { n("cbrt", arg(0)) }
    }

    private fun rounding(t: MappingTable) {
        // Lua's floor/ceil return integers; Kotlin's return Double.
        t.def("kotlin/math/floor") { floatPlusZero(lua("math.floor", arg(0))) }
        t.def("kotlin/math/ceil") { n("ceil", arg(0)) }
        t.def("kotlin/math/truncate") { n("truncate", arg(0)) }
        t.def("kotlin/math/round") { n("round", arg(0)) }
        t.def("kotlin/math/roundToInt") { n("roundToInt", self) }
        t.def("kotlin/math/roundToLong") { n("roundToLong", self) }
    }

    private fun coercions(t: MappingTable) {
        t.def("kotlin/ranges/coerceAtLeast") { lua("math.max", self, arg(0)) }
        t.def("kotlin/ranges/coerceAtMost") { lua("math.min", self, arg(0)) }
        t.def("kotlin/ranges/coerceIn") {
            if (args.size == 2) n("coerceIn", self, arg(0), arg(1)) else n("coerceInRange", self, arg(0))
        }
    }

    private fun integerMembers(t: MappingTable) {
        for (type in INTEGRAL + FLOATING) {
            t.def("kotlin/$type.plus") { arithmetic(LuaBinOp.Add) }
            t.def("kotlin/$type.minus") { arithmetic(LuaBinOp.Sub) }
            t.def("kotlin/$type.times") { arithmetic(LuaBinOp.Mul) }
            t.def("kotlin/$type.unaryMinus") { transformer.negation(self, receiverType) }
            t.def("kotlin/$type.unaryPlus") { self }
            t.def("kotlin/$type.hashCode") { lualib("Hash", self) }
        }
        t.def("kotlin/Boolean.hashCode", "kotlin/String.hashCode") { lualib("Hash", self) }
        for (type in INTEGRAL) {
            t.def("kotlin/$type.div") {
                if (isFloating(
                        argTypes[0],
                    )
                ) {
                    transformer.floatDivision(
                        self,
                        receiverType,
                        arg(0),
                        argTypes[0],
                    )
                } else {
                    transformer.integerDivision(self, receiverType, arg(0), argTypes[0])
                }
            }
        }
        for (type in FLOATING) {
            t.def("kotlin/$type.div") { transformer.floatDivision(self, receiverType, arg(0), argTypes[0]) }
        }
        for (type in INTEGRAL) {
            t.def("kotlin/$type.inc") { transformer.stepped(LuaBinOp.Add, self, receiverType) }
            t.def("kotlin/$type.dec") { transformer.stepped(LuaBinOp.Sub, self, receiverType) }
            t.def("kotlin/$type.toByte") { n("toByte", self) }
            t.def("kotlin/$type.toShort") { n("toShort", self) }
            t.def("kotlin/$type.rem") { transformer.remainder(self, receiverType, arg(0), argTypes[0]) }
            t.def("kotlin/$type.equals") { LuaBinary(LuaBinOp.Eq, self, arg(0)) }
        }
        t.def("kotlin/mod") {
            if (isFloating(receiverType)) LuaBinary(LuaBinOp.Mod, self, arg(0)) else n("mod", self, arg(0))
        }
        t.def("kotlin/floorDiv") { lualib("FloorDiv", self, arg(0)) }
        t.def("kotlin/countOneBits") { n("countOneBits", self) }
        t.def("kotlin/countTrailingZeroBits") { n("countTrailingZeroBits", self) }
        t.def("kotlin/countLeadingZeroBits") { n("countLeadingZeroBits", self) }
        t.def("kotlin/text/toString") { if (args.size == 1) n("toRadix", self, arg(0)) else null }
        t.def("kotlin/Any.hashCode") { lualib("Hash", self) }
        t.def("kotlin/Char.hashCode") { lualib("Hash", self) }
    }

    private fun floatingMembers(t: MappingTable) {
        for (type in FLOATING) {
            t.def("kotlin/$type.rem") { lua("math.fmod", self, arg(0)) }
            t.def("kotlin/$type.equals") { LuaBinary(LuaBinOp.Eq, self, arg(0)) }
        }
        t.def("kotlin/isNaN") { if (self.isSimple()) LuaBinary(LuaBinOp.Ne, self, self) else n("isNaN", self) }
        t.def("kotlin/isInfinite") { n("isInfinite", self) }
        t.def("kotlin/isFinite") { n("isFinite", self) }
    }

    private fun charMembers(t: MappingTable) {
        t.def("kotlin/Char.plus") { charFromCode(LuaBinary(LuaBinOp.Add, charCode(self), arg(0))) }
        t.def("kotlin/Char.minus") {
            if (isChar(argTypes.firstOrNull())) {
                LuaBinary(LuaBinOp.Sub, charCode(self), charCode(arg(0)))
            } else {
                charFromCode(LuaBinary(LuaBinOp.Sub, charCode(self), arg(0)))
            }
        }
        t.def("kotlin/Char.inc") { charFromCode(LuaBinary(LuaBinOp.Add, charCode(self), num("1"))) }
        t.def("kotlin/Char.dec") { charFromCode(LuaBinary(LuaBinOp.Sub, charCode(self), num("1"))) }
        t.def("kotlin/Char.equals") { LuaBinary(LuaBinOp.Eq, self, arg(0)) }
        t.def("kotlin/Char") { charFromCode(arg(0)) }
        t.def("kotlin/text/digitToChar") { n("digitToChar", self, *args.toTypedArray()) }
    }

    private fun CallSite.charCode(c: LuaExpr): LuaExpr = if (utf16) u16("code", c) else LuaMethodCall(c, "byte", emptyList())

    private fun CallSite.charFromCode(code: LuaExpr): LuaExpr = if (utf16) u16("char", code) else lua("string.char", code)

    /** `java.lang.Math`, `Integer`, `Long` and `Double` statics. */
    private fun javaStatics(t: MappingTable) {
        mathStatics(t)
        for (name in listOf("abs", "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "exp", "log")) {
            t.def("java/lang/Math.$name") { lua("math.$name", arg(0)) }
        }
        t.def("java/lang/Math.atan2") { n("atan2", arg(0), arg(1)) }
        t.def("java/lang/Math.pow") { LuaBinary(LuaBinOp.Pow, arg(0), arg(1)) }
        t.def("java/lang/Math.max") { extreme("max") }
        t.def("java/lang/Math.min") { extreme("min") }
        t.def("java/lang/Math.random") { lua("math.random") }
        t.def("java/lang/Integer.parseInt") { stringToInt(arg(0), args.getOrNull(1), long = false) }
        t.def("java/lang/Long.parseLong") { stringToInt(arg(0), args.getOrNull(1), long = true) }
        t.def("java/lang/Double.parseDouble") { LuaCall(ref("Strings", "__K2L_StringToDouble"), listOf(arg(0))) }
        t.def("java/lang/Integer.valueOf", "java/lang/Long.valueOf") { arg(0) }
        t.def("java/lang/Integer.compare", "java/lang/Long.compare", "java/lang/Double.compare") {
            LuaCall(ref("Compare", "__K2L_Compare"), listOf(arg(0), arg(1)))
        }
        t.def("java/lang/Integer.toBinaryString") { n("toRadixUnsigned", arg(0), num("2")) }
        t.def("java/lang/Integer.toHexString") { n("toRadixUnsigned", arg(0), num("16")) }
        t.def("java/lang/Integer.toOctalString") { n("toRadixUnsigned", arg(0), num("8")) }
        t.def("java/lang/Integer.toString", "java/lang/Long.toString") {
            if (args.size ==
                2
            ) {
                n("toRadix", arg(0), arg(1))
            } else {
                str(arg(0), argTypes[0])
            }
        }
    }

    private fun CallSite.stringToInt(text: LuaExpr, radix: LuaExpr?, long: Boolean): LuaExpr =
        LuaCall(ref("Strings", "__K2L_StringToInt"), if (long) listOf(text, radix ?: LuaNil, LuaBool(true)) else listOfNotNull(text, radix))

    private fun mathStatics(t: MappingTable) {
        t.def("java/lang/Math.floor") { floatPlusZero(lua("math.floor", arg(0))) }
        t.def("java/lang/Math.ceil") { n("ceil", arg(0)) }
        t.def("java/lang/Math.round") { n("roundToLong", arg(0)) }
        t.def("java/lang/Math.rint") { n("round", arg(0)) }
        t.def("java/lang/Math.signum") { n("signDouble", arg(0)) }
        t.def("java/lang/Math.hypot") { n("hypot", arg(0), arg(1)) }
        t.def("java/lang/Math.cbrt") { n("cbrt", arg(0)) }
        t.def("java/lang/Math.log10") { n("log10", arg(0)) }
        t.def("java/lang/Math.sinh") { n("sinh", arg(0)) }
        t.def("java/lang/Math.cosh") { n("cosh", arg(0)) }
        t.def("java/lang/Math.tanh") { n("tanh", arg(0)) }
        t.def("java/lang/Math.floorMod") { n("mod", arg(0), arg(1)) }
        t.def("java/lang/Math.floorDiv") { lualib("FloorDiv", arg(0), arg(1)) }
        t.def("java/lang/Math.toRadians") { LuaBinary(LuaBinOp.Mul, arg(0), num("0.017453292519943295")) }
        t.def("java/lang/Math.toDegrees") { LuaBinary(LuaBinOp.Mul, arg(0), num("57.29577951308232")) }
    }

    private fun system(t: MappingTable) {
        t.def("java/lang/System.currentTimeMillis") { n("currentTimeMillis") }
        t.def("java/lang/System.nanoTime") { n("nanoTime") }
        t.def("java/lang/System.lineSeparator") { LuaString("\n") }
        t.def("kotlin/system/measureTimeMillis") { n("measureTimeMillis", arg(0)) }
        t.def("kotlin/system/measureNanoTime") { n("measureNanoTime", arg(0)) }
    }
}
