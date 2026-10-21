package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtDotQualifiedExpression
import org.jetbrains.kotlin.psi.KtNameReferenceExpression
import org.jetbrains.kotlin.psi.KtQualifiedExpression

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
        strictMath(t)
        system(t)
    }

    private fun CallSite.n(member: String, vararg args: LuaExpr) = libMember("Numbers", "__K2L_Num", member, *args)

    /** The JVM's StrictMath algorithms (see FdLibm.lua), where C's libm rounds differently. */
    private fun CallSite.fd(member: String, vararg args: LuaExpr) = libMember("FdLibm", "__K2L_FdLibm", member, *args)

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
        t.def("kotlin/math/asin") { fd("asin", arg(0)) }
        t.def("kotlin/math/acos") { fd("acos", arg(0)) }
        t.def("kotlin/math/atan") { fd("atan", arg(0)) }
        t.def("kotlin/math/atan2") { fd("atan2", arg(0), arg(1)) }
        t.def("kotlin/math/exp") { lua("math.exp", arg(0)) }
        t.def("kotlin/math/pow") { pow(self, 0) }
        t.def("kotlin/math/PI") { luaPath("math", "pi") }
        t.def("kotlin/math/E") { lua("math.exp", num("1")) }
        t.def("kotlin/math/sign") {
            val type = receiverType ?: argTypes.firstOrNull()
            n(if (isIntegral(type)) "signInt" else "signDouble", receiver ?: arg(0))
        }
    }

    /**
     * `x.pow(y)` (argument [i] is `y`) is `x ^ y`, except for a `Double` exponent that may be NaN or infinite: the JVM's
     * `1.0.pow(NaN)` and `(-1.0).pow(Infinity)` are NaN, C's are 1. A literal or an integer's `toDouble()` is neither.
     */
    private fun CallSite.pow(base: LuaExpr, i: Int): LuaExpr {
        val exponent = arg(i)
        val finite = exponent is LuaNumber || !isFloating(argTypes[i]) || isIntegerToDouble(i)
        return if (finite) LuaBinary(LuaBinOp.Pow, base, exponent) else n("pow", base, exponent)
    }

    /** Whether argument [i] of the call is written `n.toDouble()` of an integer `n`. */
    private fun CallSite.isIntegerToDouble(i: Int): Boolean {
        val call = element as? KtCallExpression ?: (element as? KtQualifiedExpression)?.selectorExpression as? KtCallExpression
        val argument = call?.valueArguments?.getOrNull(i)?.getArgumentExpression() as? KtDotQualifiedExpression ?: return false
        val selector = argument.selectorExpression as? KtCallExpression
        return (selector?.calleeExpression as? KtNameReferenceExpression)?.getReferencedName() == "toDouble" &&
            with(session) { argument.receiverExpression.expressionType?.isIntegral == true }
    }

    /**
     * `maxOf(a, b)` of integers is `math.max`, of `Double`s `__K2L_Num.maxD` (NaN wins and `0.0` is above `-0.0`, as on the JVM);
     * other comparables go through `compareTo`.
     */
    private fun CallSite.extreme(fn: String): LuaExpr? {
        if (args.size !in MIN_MAX_ARITY) return null
        val numeric = argTypes.all { it != null && (isIntegral(it) || isFloating(it)) }
        return when {
            numeric && argTypes.any { isFloating(it) } -> args.reduce { acc, x -> n(fn + "D", acc, x) }
            numeric -> lua("math.$fn", *args.toTypedArray())
            args.size == 2 -> libMember("Numbers", "__K2L_Num", fn + "Of", arg(0), arg(1))
            else -> null
        }
    }

    private fun hyperbolicAndLogs(t: MappingTable) {
        t.def("kotlin/math/sinh") { fd("sinh", arg(0)) }
        t.def("kotlin/math/cosh") { fd("cosh", arg(0)) }
        t.def("kotlin/math/tanh") { fd("tanh", arg(0)) }
        t.def("kotlin/math/ln") { lua("math.log", arg(0)) }
        t.def("kotlin/math/ln1p") { fd("log1p", arg(0)) }
        t.def("kotlin/math/expm1") { fd("expm1", arg(0)) }
        t.def("kotlin/math/log10") { n("log10", arg(0)) }
        t.def("kotlin/math/log2") { n("log2", arg(0)) }
        t.def("kotlin/math/log") { n("log", arg(0), arg(1)) }
        t.def("kotlin/math/hypot") { fd("hypot", arg(0), arg(1)) }
        t.def("kotlin/math/cbrt") { fd("cbrt", arg(0)) }
        t.def("kotlin/math/IEEErem") { n("IEEErem", self, arg(0)) }
    }

    private fun rounding(t: MappingTable) {
        // Lua's floor/ceil return integers; Kotlin's return Double.
        t.def("kotlin/math/floor") { floor(arg(0)) }
        t.def("kotlin/math/ceil") { n("ceil", arg(0)) }
        t.def("kotlin/math/truncate") { n("truncate", arg(0)) }
        t.def("kotlin/math/round") { n("round", arg(0)) }
        t.def("kotlin/math/roundToInt") { n("roundToInt", self) }
        t.def("kotlin/math/roundToLong") { n("roundToLong", self) }
    }

    /**
     * `floor(x)`: `math.floor(x) + 0.0`, a Double, except that the floor of -0.0 is -0.0 (`+ 0.0` makes it 0.0, and
     * 5.3+'s `math.floor` returns the integer 0): `x == 0 and x * 1.0 or ...` for a simple `x`, else `__K2L_Num.floor`.
     */
    private fun CallSite.floor(x: LuaExpr): LuaExpr = if (isNonZeroLiteral(x)) {
        floatPlusZero(lua("math.floor", x))
    } else if (x.isSimple()) {
        val zero = LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Eq, x, num("0")), LuaBinary(LuaBinOp.Mul, x, num("1.0")))
        LuaBinary(LuaBinOp.Or, zero, floatPlusZero(lua("math.floor", x)))
    } else {
        n("floor", x)
    }

    private fun isNonZeroLiteral(x: LuaExpr): Boolean = when (x) {
        is LuaNumber -> x.text.toDoubleOrNull()?.let { it != 0.0 } == true
        is LuaUnary -> x.op == LuaUnOp.Neg && isNonZeroLiteral(x.operand)
        else -> false
    }

    private fun CallSite.isNumber(type: KaType?) =
        type != null && with(session) { type.isPrimitive && !type.isCharType && !type.isBooleanType }

    private fun coercions(t: MappingTable) {
        // math.max/min for numbers; Comparable objects go through compareTo
        t.def("kotlin/ranges/coerceAtLeast") {
            if (isNumber(receiverType)) lua("math.max", self, arg(0)) else n("coerceAtLeast", self, arg(0))
        }
        t.def("kotlin/ranges/coerceAtMost") {
            if (isNumber(receiverType)) lua("math.min", self, arg(0)) else n("coerceAtMost", self, arg(0))
        }
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
        t.def("kotlin/text/toString") {
            when {
                args.size != 1 -> null

                with(session) { unsignedOf(receiverType) } == Unsigned.ULong ->
                    LuaCall(LuaIndex(ref("Unsigned", "__K2L_Unsigned"), LuaString("toRadix")), listOf(self, arg(0)))

                else -> n("toRadix", self, arg(0))
            }
        }
        t.def("kotlin/Any.hashCode") { lualib("Hash", self) }
        t.def("kotlin/Char.hashCode") { lualib("Hash", self) }
    }

    private fun floatingMembers(t: MappingTable) {
        for (type in FLOATING) {
            t.def("kotlin/$type.rem") { lua("math.fmod", self, arg(0)) }
            // Double.equals boxes: NaN equals NaN, 0.0 and -0.0 differ (`==` of two Doubles is IEEE)
            t.def("kotlin/$type.equals") { LuaCall(ref("Equals", "__K2L_DoubleEquals"), listOf(self, arg(0))) }
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
        for (name in listOf("abs", "sqrt", "sin", "cos", "tan", "exp", "log")) {
            t.def("java/lang/Math.$name") { lua("math.$name", arg(0)) }
        }
        for (name in listOf("asin", "acos", "atan", "expm1", "log1p")) {
            t.def("java/lang/Math.$name") { fd(name, arg(0)) }
        }
        t.def("java/lang/Math.atan2") { fd("atan2", arg(0), arg(1)) }
        t.def("java/lang/Math.pow") { pow(arg(0), 1) }
        t.def("java/lang/Math.max") { extreme("max") }
        t.def("java/lang/Math.min") { extreme("min") }
        t.def("java/lang/Math.random") { lua("math.random") }
        t.def("java/lang/Integer.parseInt") { stringToInt(arg(0), args.getOrNull(1), long = false) }
        t.def("java/lang/Long.parseLong") { stringToInt(arg(0), args.getOrNull(1), long = true) }
        t.def("java/lang/Double.parseDouble") { LuaCall(ref("Strings", "__K2L_StringToDouble"), listOf(arg(0))) }
        // valueOf(Int) is the number itself, valueOf(String[, radix]) parses it
        t.def("java/lang/Integer.valueOf") {
            if (isTextual(argTypes.firstOrNull())) stringToInt(arg(0), args.getOrNull(1), long = false) else arg(0)
        }
        t.def("java/lang/Long.valueOf") {
            if (isTextual(argTypes.firstOrNull())) stringToInt(arg(0), args.getOrNull(1), long = true) else arg(0)
        }
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

    private fun CallSite.stringToInt(text: LuaExpr, radix: LuaExpr?, long: Boolean): LuaExpr {
        requireUtf16Case()
        return LuaCall(
            ref("Strings", "__K2L_StringToInt"),
            if (long) listOf(text, radix ?: LuaNil, LuaBool(true)) else listOfNotNull(text, radix),
        )
    }

    private fun mathStatics(t: MappingTable) {
        t.def("java/lang/Math.floor") { floor(arg(0)) }
        t.def("java/lang/Math.ceil") { n("ceil", arg(0)) }
        t.def("java/lang/Math.round") { n("roundToLong", arg(0)) }
        t.def("java/lang/Math.rint") { n("round", arg(0)) }
        t.def("java/lang/Math.signum") { n("signDouble", arg(0)) }
        t.def("java/lang/Math.hypot") { fd("hypot", arg(0), arg(1)) }
        t.def("java/lang/Math.cbrt") { fd("cbrt", arg(0)) }
        t.def("java/lang/Math.IEEEremainder") { n("IEEErem", arg(0), arg(1)) }
        t.def("java/lang/Math.log10") { n("log10", arg(0)) }
        t.def("java/lang/Math.sinh") { fd("sinh", arg(0)) }
        t.def("java/lang/Math.cosh") { fd("cosh", arg(0)) }
        t.def("java/lang/Math.tanh") { fd("tanh", arg(0)) }
        t.def("java/lang/Math.floorMod") { n("mod", arg(0), arg(1)) }
        t.def("java/lang/Math.floorDiv") { lualib("FloorDiv", arg(0), arg(1)) }
        t.def("java/lang/Math.toRadians") { LuaBinary(LuaBinOp.Mul, arg(0), num("0.017453292519943295")) }
        t.def("java/lang/Math.toDegrees") { LuaBinary(LuaBinOp.Mul, arg(0), num("57.29577951308232")) }
    }

    /**
     * The `StrictMath` functions whose results the JVM's `Math` may not give (the others are `Math`'s, see
     * `StdlibMappings.map`): fdlibm ports, bit for bit what StrictMath specifies (`StrictMath.lua`, `FdLibm.lua`).
     */
    private fun strictMath(t: MappingTable) {
        for (name in listOf("sin", "cos", "tan", "log", "log10", "pow")) {
            t.def("java/lang/StrictMath.$name") { libMember("StrictMath", "__K2L_StrictMath", name, *args.toTypedArray()) }
        }
        t.def("java/lang/StrictMath.exp") { fd("exp", arg(0)) }
    }

    private fun system(t: MappingTable) {
        t.def("java/lang/System.currentTimeMillis") { n("currentTimeMillis") }
        t.def("java/lang/System.nanoTime") { n("nanoTime") }
        t.def("java/lang/System.lineSeparator") { LuaString("\n") }
        t.def("java/io/Closeable.close", "java/lang/AutoCloseable.close") { method(self, "close") }
        t.def("kotlin/system/measureTimeMillis") { n("measureTimeMillis", arg(0)) }
        t.def("kotlin/system/measureNanoTime") { n("measureNanoTime", arg(0)) }
    }
}
