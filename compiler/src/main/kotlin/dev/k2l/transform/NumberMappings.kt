package dev.k2l.transform

import dev.k2l.LuaTarget
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

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

    private fun CallSite.n(member: String, vararg args: LuaExpr) = libMember(NUM_TABLE, member, *args)

    /** `atan2(y, x)`: `math.atan(y, x)` on Lua 5.3+, `math.atan2` before. */
    private fun CallSite.atan2(y: LuaExpr, x: LuaExpr) = if (hasIntegers) lua("math.atan", y, x) else lua("math.atan2", y, x)

    /** The logarithm of [x] in [base]: `math.log(x, base)` from Lua 5.2 on, `math.log(x) / math.log(base)` on 5.1 and LuaJIT. */
    private fun CallSite.logBase(x: LuaExpr, base: LuaExpr): LuaExpr = when {
        target != LuaTarget.Lua51 && target != LuaTarget.LuaJIT -> lua("math.log", x, base)
        base == num("10") -> lua("math.log10", x)
        else -> LuaBinary(LuaBinOp.Div, lua("math.log", x), lua("math.log", base))
    }

    private fun CallSite.arithmetic(op: LuaBinOp) = LuaBinary(op, self, arg(0))

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
        t.def("kotlin/math/atan2") { atan2(arg(0), arg(1)) }
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
            args.size == 2 -> libMember(NUM_TABLE, fn + "Of", arg(0), arg(1))
            else -> null
        }
    }

    private fun hyperbolicAndLogs(t: MappingTable) {
        t.def("kotlin/math/sinh") { n("sinh", arg(0)) }
        t.def("kotlin/math/cosh") { n("cosh", arg(0)) }
        t.def("kotlin/math/tanh") { n("tanh", arg(0)) }
        t.def("kotlin/math/ln") { lua("math.log", arg(0)) }
        t.def("kotlin/math/ln1p") { n("log1p", arg(0)) }
        t.def("kotlin/math/expm1") { n("expm1", arg(0)) }
        t.def("kotlin/math/log10") { logBase(arg(0), num("10")) }
        t.def("kotlin/math/log2") { logBase(arg(0), num("2")) }
        t.def("kotlin/math/log") { logBase(arg(0), arg(1)) }
        t.def("kotlin/math/hypot") { n("hypot", arg(0), arg(1)) }
        t.def("kotlin/math/cbrt") { n("cbrt", arg(0)) }
        t.def("kotlin/math/IEEErem") { n("IEEErem", self, arg(0)) }
    }

    /**
     * Lua's `math.floor` and `math.ceil` (integers on Lua 5.3+, where they fit), truncation toward zero, `round` half to even
     * and `roundToInt` half up, `floor(x + 0.5)`.
     */
    private fun rounding(t: MappingTable) {
        t.def("kotlin/math/floor") { lua("math.floor", arg(0)) }
        t.def("kotlin/math/ceil") { lua("math.ceil", arg(0)) }
        t.def("kotlin/math/truncate") { lualib("Truncate", arg(0)) }
        t.def("kotlin/math/round") { n("round", arg(0)) }
        t.def("kotlin/math/roundToInt", "kotlin/math/roundToLong") { roundHalfUp(self) }
    }

    private fun roundHalfUp(x: LuaExpr): LuaExpr = lua("math.floor", LuaBinary(LuaBinOp.Add, x, num("0.5")))

    private fun CallSite.isPrimitiveNumber(type: KaType?) =
        type != null && with(session) { type.isPrimitive && !type.isCharType && !type.isBooleanType }

    private fun coercions(t: MappingTable) {
        // math.max/min for numbers; Comparable objects go through compareTo
        t.def("kotlin/ranges/coerceAtLeast") {
            if (isPrimitiveNumber(receiverType)) lua("math.max", self, arg(0)) else n("coerceAtLeast", self, arg(0))
        }
        t.def("kotlin/ranges/coerceAtMost") {
            if (isPrimitiveNumber(receiverType)) lua("math.min", self, arg(0)) else n("coerceAtMost", self, arg(0))
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
            t.def("kotlin/$type.unaryMinus") { LuaUnary(LuaUnOp.Neg, self) }
            t.def("kotlin/$type.unaryPlus") { self }
            t.def("kotlin/$type.hashCode") { lualib("Hash", self) }
        }
        t.def("kotlin/Boolean.hashCode", "kotlin/String.hashCode") { lualib("Hash", self) }
        for (type in INTEGRAL) {
            t.def("kotlin/$type.div") {
                if (isFloating(argTypes[0])) LuaBinary(LuaBinOp.Div, self, arg(0)) else transformer.floorDivision(self, arg(0))
            }
        }
        for (type in FLOATING) {
            t.def("kotlin/$type.div") { LuaBinary(LuaBinOp.Div, self, arg(0)) }
        }
        for (type in INTEGRAL + FLOATING) {
            // Lua's %, whose result has the sign of the divisor: Kotlin's mod, not its rem
            t.def("kotlin/$type.rem") { LuaBinary(LuaBinOp.Mod, self, arg(0)) }
        }
        for (type in INTEGRAL) {
            t.def("kotlin/$type.inc") { stepped(LuaBinOp.Add, self) }
            t.def("kotlin/$type.dec") { stepped(LuaBinOp.Sub, self) }
            t.def("kotlin/$type.equals") { LuaBinary(LuaBinOp.Eq, self, arg(0)) }
        }
        t.def("kotlin/mod") { LuaBinary(LuaBinOp.Mod, self, arg(0)) }
        t.def("kotlin/floorDiv") { transformer.floorDivision(self, arg(0)) }
        t.def("kotlin/text/toString") { if (args.size == 1) n("toRadix", self, arg(0)) else null }
        t.def("kotlin/Any.hashCode") { lualib("Hash", self) }
        t.def("kotlin/Char.hashCode") { lualib("Hash", self) }
    }

    private fun floatingMembers(t: MappingTable) {
        for (type in FLOATING) {
            // Lua's `==`: NaN differs from itself, 0.0 equals -0.0
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

    /** The `java.lang.Math` functions that are Lua's math functions. */
    private fun javaStatics(t: MappingTable) {
        mathStatics(t)
        for (name in listOf("abs", "sqrt", "sin", "cos", "tan", "exp", "log")) {
            t.def("java/lang/Math.$name") { lua("math.$name", arg(0)) }
        }
        for (name in listOf("asin", "acos", "atan")) {
            t.def("java/lang/Math.$name") { lua("math.$name", arg(0)) }
        }
        for (name in listOf("expm1", "log1p", "sinh", "cosh", "tanh", "cbrt")) {
            t.def("java/lang/Math.$name") { n(name, arg(0)) }
        }
        t.def("java/lang/Math.atan2") { atan2(arg(0), arg(1)) }
        t.def("java/lang/Math.pow") { LuaBinary(LuaBinOp.Pow, arg(0), arg(1)) }
        t.def("java/lang/Math.max") { extreme("max") }
        t.def("java/lang/Math.min") { extreme("min") }
        t.def("java/lang/Math.random") { lua("math.random") }
    }

    private fun mathStatics(t: MappingTable) {
        t.def("java/lang/Math.floor") { lua("math.floor", arg(0)) }
        t.def("java/lang/Math.ceil") { lua("math.ceil", arg(0)) }
        t.def("java/lang/Math.round") { roundHalfUp(arg(0)) }
        t.def("java/lang/Math.rint") { n("round", arg(0)) }
        t.def("java/lang/Math.signum") { n("signDouble", arg(0)) }
        t.def("java/lang/Math.hypot") { n("hypot", arg(0), arg(1)) }
        t.def("java/lang/Math.IEEEremainder") { n("IEEErem", arg(0), arg(1)) }
        t.def("java/lang/Math.log10") { logBase(arg(0), num("10")) }
        t.def("java/lang/Math.floorMod") { LuaBinary(LuaBinOp.Mod, arg(0), arg(1)) }
        t.def("java/lang/Math.floorDiv") { transformer.floorDivision(arg(0), arg(1)) }
        t.def("java/lang/Math.toRadians") { LuaBinary(LuaBinOp.Mul, arg(0), num("0.017453292519943295")) }
        t.def("java/lang/Math.toDegrees") { LuaBinary(LuaBinOp.Mul, arg(0), num("57.29577951308232")) }
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
