package dev.k2l.transform

import dev.k2l.codegen.*

/** Members of `UByte`, `UShort`, `UInt` and `ULong` and the conversions to and from them; see [Unsigned]. */
internal object UnsignedMappings {
    private val KINDS = Unsigned.entries
    private const val SHIFT_MASK = 31

    fun install(t: MappingTable) {
        for (kind in KINDS) {
            arithmetic(t, kind.name)
            bitwise(t, kind)
            conversions(t, kind)
        }
        for (kind in KINDS) {
            t.def("kotlin/to${kind.name}", "kotlin/numbers/to${kind.name}") { toUnsigned(kind) }
        }
    }

    private fun CallSite.unsignedTable(member: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(LuaIndex(ref("Unsigned", "__K2L_Unsigned"), LuaString(member)), args.toList())

    /** `sum()` of unsigned numbers wraps (to `UInt`, whose sum is the result type for the narrower types too). */
    fun post(callableId: String?, site: CallSite, result: LuaExpr?): LuaExpr? {
        if (result == null || callableId == null || site.name != "sum") return result
        if (!callableId.startsWith("kotlin/collections/") && !callableId.startsWith("kotlin/sequences/")) return result
        val kind = with(site.session) { unsignedOf(site.element.expressionType) }
        return if (kind != null) site.transformer.wrapUnsigned(kind, result) else result
    }

    /** `a.compareTo(b)`: a `ULong` on 5.3/5.4 compares with `math.ult`; everything else is the generic comparison (null). */
    fun compareTo(site: CallSite): LuaExpr? = with(site) {
        val ulong = with(session) { unsignedOf(receiverType) == Unsigned.ULong || unsignedOf(argTypes.getOrNull(0)) == Unsigned.ULong }
        if (ulong && (transformer.ctx.options.luaTarget.hasIntegers || transformer.emulatesLong)) {
            unsignedTable("compare", self, arg(0))
        } else {
            null
        }
    }

    private fun arithmetic(t: MappingTable, name: String) {
        t.def("kotlin/$name.plus") { transformer.arithmetic(LuaBinOp.Add, self, receiverType, arg(0), argTypes[0]) }
        t.def("kotlin/$name.minus") { transformer.arithmetic(LuaBinOp.Sub, self, receiverType, arg(0), argTypes[0]) }
        t.def("kotlin/$name.times") { transformer.arithmetic(LuaBinOp.Mul, self, receiverType, arg(0), argTypes[0]) }
        t.def("kotlin/$name.div") { transformer.integerDivision(self, receiverType, arg(0), argTypes[0]) }
        t.def("kotlin/$name.rem") { transformer.remainder(self, receiverType, arg(0), argTypes[0]) }
        t.def("kotlin/$name.inc") { transformer.stepped(LuaBinOp.Add, self, receiverType) }
        t.def("kotlin/$name.dec") { transformer.stepped(LuaBinOp.Sub, self, receiverType) }
        t.def("kotlin/$name.equals") { LuaBinary(LuaBinOp.Eq, self, arg(0)) }
        t.def("kotlin/$name.hashCode") { lualib("Hash", self) }
    }

    private fun bitwise(t: MappingTable, kind: Unsigned) {
        val name = kind.name
        val wide = kind == Unsigned.UInt || kind == Unsigned.ULong
        fun CallSite.native(helper: String, op: LuaBinOp): LuaExpr = if (transformer.ctx.options.luaTarget.hasIntegers) {
            LuaBinary(op, self, arg(0))
        } else {
            wrap(kind, LuaCall(ref("Bit", helper), listOf(self, arg(0))))
        }
        t.def("kotlin/$name.and") { native("__K2L_BAnd", LuaBinOp.BAnd) }
        t.def("kotlin/$name.or") { native("__K2L_BOr", LuaBinOp.BOr) }
        t.def("kotlin/$name.xor") { native("__K2L_BXor", LuaBinOp.BXor) }
        // all ones minus the value: the complement within the type's width
        t.def("kotlin/$name.inv") {
            val ones = when {
                kind == Unsigned.ULong -> if (transformer.ctx.options.luaTarget.hasIntegers) "-1" else "18446744073709551615"
                else -> ((1L shl kind.bits) - 1).toString()
            }
            LuaBinary(LuaBinOp.Sub, LuaNumber(ones), self)
        }
        if (!wide) return
        t.def("kotlin/$name.shl") {
            val shift = shiftCount(kind, arg(0))
            if (transformer.ctx.options.luaTarget.hasIntegers) {
                wrap(kind, LuaBinary(LuaBinOp.Shl, self, shift))
            } else {
                wrap(kind, LuaBinary(LuaBinOp.Mul, self, LuaBinary(LuaBinOp.Pow, LuaNumber("2"), shift)))
            }
        }
        t.def("kotlin/$name.shr") {
            val shift = shiftCount(kind, arg(0))
            if (transformer.ctx.options.luaTarget.hasIntegers) {
                LuaBinary(LuaBinOp.Shr, self, shift)
            } else {
                luaCall(luaPath("math", "floor"), LuaBinary(LuaBinOp.Div, self, LuaBinary(LuaBinOp.Pow, LuaNumber("2"), shift)))
            }
        }
    }

    private fun CallSite.wrap(kind: Unsigned, e: LuaExpr) = transformer.wrapUnsigned(kind, e)

    /** The JVM uses only the low 5 (6 for `ULong`) bits of a shift count. */
    private fun shiftCount(kind: Unsigned, count: LuaExpr): LuaExpr {
        val mask = if (kind == Unsigned.ULong) 2 * SHIFT_MASK + 1 else SHIFT_MASK
        return if (count is LuaNumber) count else LuaBinary(LuaBinOp.BAnd, count, LuaNumber(mask.toString()))
    }

    /** Conversions from an unsigned type to the other number types. */
    private fun conversions(t: MappingTable, kind: Unsigned) {
        val name = kind.name
        val wide = kind == Unsigned.UInt || kind == Unsigned.ULong
        t.def("kotlin/$name.toInt") { if (wide) lualib("ToInt32", self) else self }
        t.def("kotlin/$name.toLong") { self }
        t.def("kotlin/$name.toShort") { libMember("Numbers", "__K2L_Num", "toShort", self) }
        t.def("kotlin/$name.toByte") { libMember("Numbers", "__K2L_Num", "toByte", self) }
        t.def("kotlin/$name.toDouble") { toDouble(kind) }
        t.def("kotlin/$name.toFloat") { transformer.fround(toDouble(kind)) }
        for (to in KINDS) {
            t.def("kotlin/$name.to${to.name}") { toUnsigned(to) }
        }
        t.def("kotlin/$name.toString") {
            if (args.isEmpty()) str(self, receiverType) else libMember("Numbers", "__K2L_Num", "toRadix", self, arg(0))
        }
    }

    private fun CallSite.toDouble(kind: Unsigned): LuaExpr =
        if (kind == Unsigned.ULong) unsignedTable("toDouble", self) else LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0"))

    /** `x.toUInt()` and friends, from whatever number type the receiver is. */
    private fun CallSite.toUnsigned(to: Unsigned): LuaExpr {
        val from = with(session) { unsignedOf(receiverType) }
        val floating = isFloating(receiverType)
        // a wide value is a box beyond 2^53: narrow it through toInt() first (the low bits are the same)
        if (transformer.emulatesLong && to != Unsigned.ULong && with(session) { isWide(receiverType) }) {
            return transformer.wrapUnsigned(to, transformer.l64("Int", self))
        }
        return when {
            from != null -> if (to.bits >= from.bits) self else transformer.wrapUnsigned(to, self)
            floating && to == Unsigned.UInt -> unsignedTable("fromDouble32", self)
            floating && to == Unsigned.ULong -> unsignedTable("fromDouble64", self)
            floating -> transformer.wrapUnsigned(to, lualib("DoubleToInt", self))
            else -> transformer.wrapUnsigned(to, self)
        }
    }
}
