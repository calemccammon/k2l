package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType

/**
 * The library members that take or return a `Long` or `ULong` with `--long64 emulate` (see [long64Arithmetic]); they
 * take precedence over the `Double`-based mappings and answer null for calls that involve no wide type.
 */
@Suppress("TooManyFunctions") // one small installer per group of members
internal object Long64Mappings {
    private val table = MappingTable()
    private val WIDE = listOf("Long", "ULong")
    private const val BIT_OPS = "and,or,xor"

    init {
        conversions()
        bitwise()
        math()
        counting()
        exact()
        javaStatics()
        text()
        bitsAndBigNumbers()
        ranges()
    }

    /** `a..b`, `until` and `downTo` between wide values are `LongRange` objects (`Long64Range.l64.lua`). */
    private fun ranges() {
        def("kotlin/Long.rangeTo", "kotlin/Int.rangeTo", "kotlin/ULong.rangeTo", "kotlin/UInt.rangeTo") {
            if (anyWide()) longRange("new", self, arg(0), LuaNil) else null
        }
        def("kotlin/Int.rangeUntil", "kotlin/ranges/until") {
            if (anyWide()) longRange("untilOf", self, arg(0)) else null
        }
        def("kotlin/ranges/downTo") { if (anyWide()) longRange("new", self, arg(0), LuaNumber("-1")) else null }
    }

    private fun CallSite.longRange(constructor: String, vararg args: LuaExpr): LuaExpr {
        val unsigned = with(session) { isULongType(receiverType) || argTypes.any { isULongType(it) } }
        val target = LuaIndex(ref("Long64Range", "__K2L_LongRange"), LuaString(constructor))
        return LuaCall(target, args.toList() + LuaBool(unsigned))
    }

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId == null || !site.transformer.emulatesLong) return null
        return table.entries[callableId]?.invoke(site) ?: sums(callableId, site)
    }

    private fun CallSite.wide(type: org.jetbrains.kotlin.analysis.api.types.KaType?) = with(session) { isWide(type) }

    /** The `ULong` variant ("umax") of an extreme when an operand is a `ULong`. */
    private fun CallSite.unsignedOr(member: String) =
        if (with(session) { isULongType(receiverType) || argTypes.any { isULongType(it) } }) "u$member" else member

    /** The call [site] with the `Long` arguments of `String.format` boxed, so that `%x` shows 64 bits for a negative number. */
    fun prepare(callableId: String?, site: CallSite): CallSite {
        if (callableId != "kotlin/text/format" || !site.transformer.emulatesLong) return site
        val args = site.args.mapIndexed { i, a -> if (site.wide(site.argTypes.getOrNull(i))) site.l64Member("boxed", a) else a }
        return CallSite(site.session, site.transformer, site.element, site.name, site.receiver, site.receiverType, args, site.argTypes)
    }

    private fun CallSite.anyWide() = wide(receiverType) || argTypes.any { wide(it) }

    private fun CallSite.l64(op: String, vararg args: LuaExpr) = transformer.l64(op, *args)

    private fun CallSite.x(member: String, vararg args: LuaExpr) = transformer.l64x(member, *args)

    /** [LuaExpr] of the call when its receiver (or first argument, for statics) is wide. */
    private fun def(vararg ids: String, mapping: Mapping) = table.def(*ids, mapping = mapping)

    private fun conversions() {
        for (t in WIDE) {
            def("kotlin/$t.toInt") { l64("Int", self) }
            def("kotlin/$t.toShort") { libMember("Numbers", "__K2L_Num", "toShort", l64("Int", self)) }
            def("kotlin/$t.toByte") { libMember("Numbers", "__K2L_Num", "toByte", l64("Int", self)) }
        }
        // the hash of a Long differs from the hash of an Int with the same value for negative numbers
        def("kotlin/Long.hashCode", "kotlin/ULong.hashCode", "kotlin/Any.hashCode") {
            if (wide(receiverType)) l64Member("hash", self) else null
        }
        def("kotlin/Long.toDouble") { l64("Double", self) }
        def("kotlin/Long.toFloat") { transformer.fround(l64("Double", self)) }
        def("kotlin/text/toString", "kotlin/ULong.toString", "kotlin/Long.toString") {
            if (args.size != 1 || !wide(receiverType)) {
                null
            } else {
                x(if (with(session) { isULongType(receiverType) }) "ustrRadix" else "strRadix", self, arg(0))
            }
        }
    }

    private fun bitwise() {
        for (t in WIDE) {
            for (op in BIT_OPS.split(',')) def("kotlin/$t.$op") { l64(op.replaceFirstChar { it.uppercase() }, self, arg(0)) }
            def("kotlin/$t.inv") { l64("Not", self) }
            def("kotlin/$t.shl") { l64("Shl", self, arg(0)) }
        }
        def("kotlin/Long.shr") { l64("Shr", self, arg(0)) }
        def("kotlin/Long.ushr", "kotlin/ULong.shr") { l64("Ushr", self, arg(0)) }
    }

    private fun math() {
        def("kotlin/math/abs", "java/lang/Math.abs") { if (wide(argTypes.firstOrNull())) x("abs", arg(0)) else null }
        def("kotlin/math/absoluteValue") { if (wide(receiverType)) x("abs", self) else null }
        def("kotlin/math/sign") { if (wide(receiverType ?: argTypes.firstOrNull())) x("sign", receiver ?: arg(0)) else null }
        extremes()
    }

    private fun extremes() {
        for (member in listOf("max", "min")) {
            def("kotlin/comparisons/${member}Of", "kotlin/math/$member", "java/lang/Math.$member") {
                if (anyWide() && args.size >= 2) args.reduce { a, b -> x(unsignedOr(member), a, b) } else null
            }
        }
        def("kotlin/ranges/coerceAtLeast") { if (anyWide()) x(unsignedOr("max"), self, arg(0)) else null }
        def("kotlin/ranges/coerceAtMost") { if (anyWide()) x(unsignedOr("min"), self, arg(0)) else null }
        def("kotlin/ranges/coerceIn") {
            if (args.size == 2 && with(session) { isULongType(receiverType) }) x("ucoerceIn", self, arg(0), arg(1)) else null
        }
        def("kotlin/mod") { if (anyWide()) x("floorMod", self, arg(0)) else null }
        def("kotlin/floorDiv") { if (anyWide()) x("floorDiv", self, arg(0)) else null }
        def("java/lang/Math.floorMod") { if (anyWide()) x("floorMod", arg(0), arg(1)) else null }
        def("java/lang/Math.floorDiv") { if (anyWide()) x("floorDiv", arg(0), arg(1)) else null }
    }

    private fun counting() {
        val unary = mapOf(
            "countOneBits" to "ones",
            "countTrailingZeroBits" to "ctz",
            "countLeadingZeroBits" to "clz",
            "takeHighestOneBit" to "highest",
            "takeLowestOneBit" to "lowest",
        )
        for ((name, member) in unary) def("kotlin/$name", "kotlin/ULong.$name") { if (wide(receiverType)) x(member, self) else null }
        def("kotlin/rotateLeft", "kotlin/ULong.rotateLeft") { if (wide(receiverType)) x("rotl", self, arg(0)) else null }
        def("kotlin/rotateRight", "kotlin/ULong.rotateRight") { if (wide(receiverType)) x("rotr", self, arg(0)) else null }
    }

    private fun exact() {
        val binary = mapOf("addExact" to "addExact", "subtractExact" to "subExact", "multiplyExact" to "mulExact")
        for ((name, member) in binary) def("java/lang/Math.$name") { if (anyWide()) x(member, arg(0), arg(1)) else null }
        val unary = mapOf(
            "negateExact" to "negExact",
            "incrementExact" to "incExact",
            "decrementExact" to "decExact",
            "absExact" to "absExact",
        )
        for ((name, member) in unary) def("java/lang/Math.$name") { if (anyWide()) x(member, arg(0)) else null }
        def("java/lang/Math.toIntExact") { x("toIntExact", arg(0)) }
    }

    private fun javaStatics() {
        def("java/lang/Long.parseLong") { x("parseOrThrow", arg(0), args.getOrElse(1) { LuaNil }) }
        def("java/lang/Long.toHexString") { x("ustrRadix", arg(0), LuaNumber("16")) }
        def("java/lang/Long.toBinaryString") { x("ustrRadix", arg(0), LuaNumber("2")) }
        def("java/lang/Long.toOctalString") { x("ustrRadix", arg(0), LuaNumber("8")) }
        def("java/lang/Long.toString") { if (args.size == 2) x("strRadix", arg(0), arg(1)) else null }
        def("java/lang/Long.bitCount") { x("ones", arg(0)) }
        def("java/lang/Long.signum") { x("sign", arg(0)) }
        def("java/lang/Long.numberOfLeadingZeros") { x("clz", arg(0)) }
        def("java/lang/Long.numberOfTrailingZeros") { x("ctz", arg(0)) }
        def("java/lang/Long.highestOneBit") { x("highest", arg(0)) }
        def("java/lang/Long.lowestOneBit") { x("lowest", arg(0)) }
        def("java/lang/Long.max") { x("max", arg(0), arg(1)) }
        def("java/lang/Long.min") { x("min", arg(0), arg(1)) }
        def("java/lang/Long.sum") { l64("Add", arg(0), arg(1)) }
        def("java/lang/Long.compareUnsigned") { l64Member("ucmp", arg(0), arg(1)) }
        def("java/lang/Long.divideUnsigned") { l64Member("udiv", arg(0), arg(1)) }
        def("java/lang/Long.remainderUnsigned") { l64Member("urem", arg(0), arg(1)) }
        def("java/lang/Long.toUnsignedString") { x("ustrRadix", arg(0), args.getOrElse(1) { LuaNumber("10") }) }
        def("java/lang/Long.parseUnsignedLong") { x("parseOrThrow", arg(0), args.getOrElse(1) { LuaNil }, LuaBool(true)) }
        def("java/lang/Long.rotateLeft") { x("rotl", arg(0), arg(1)) }
        def("java/lang/Long.rotateRight") { x("rotr", arg(0), arg(1)) }
    }

    private fun CallSite.l64Member(member: String, vararg args: LuaExpr) = transformer.l64Member(member, *args)

    private fun CallSite.isDouble(type: org.jetbrains.kotlin.analysis.api.types.KaType?) =
        type != null && with(session) { type.withoutFlexibility.isDoubleType }

    /** `Double.toBits()` and `fromBits`, and the conversions between `Long` and `BigInteger`/`BigDecimal`. */
    private fun bitsAndBigNumbers() {
        def("kotlin/toBits", "kotlin/toRawBits") { if (isDouble(receiverType)) x("doubleBits", self) else null }
        def("kotlin/fromBits") { if (wide(argTypes.firstOrNull())) x("doubleFromBits", arg(0)) else null }
        def("java/lang/Double.doubleToLongBits", "java/lang/Double.doubleToRawLongBits") { x("doubleBits", arg(0)) }
        def("java/lang/Double.longBitsToDouble") { x("doubleFromBits", arg(0)) }
        def("kotlin/math/roundToLong") { x("roundToLong", self) }
        def("java/lang/Math.round") { if (isDouble(argTypes.firstOrNull())) x("round", arg(0)) else null }
        def("java/math/BigInteger.toLong", "java/math/BigInteger.longValue") { x("bigToLong", self) }
        def("java/math/BigInteger.longValueExact") { x("bigToLongExact", self) }
        def("java/math/BigInteger.valueOf") { if (wide(argTypes.firstOrNull())) parsed("BigInteger", "__K2L_BigInteger", arg(0)) else null }
        def("kotlin/toBigInteger") { if (wide(receiverType)) parsed("BigInteger", "__K2L_BigInteger", self) else null }
        def("java/math/BigDecimal.valueOf") {
            if (wide(argTypes.firstOrNull()) && args.size == 1) parsed("BigDecimal", "__K2L_BigDecimal", arg(0)) else null
        }
        def("kotlin/toBigDecimal") { if (wide(receiverType)) parsed("BigDecimal", "__K2L_BigDecimal", self) else null }
    }

    /** `BigInteger.parse(long.toString())`: a box cannot go through the number conversions. */
    private fun CallSite.parsed(feature: String, table: String, value: LuaExpr) =
        libMember(feature, table, "parse", l64Member("str", value))

    private fun text() {
        def("kotlin/text/toLong") { x("parseOrThrow", self, args.getOrElse(0) { LuaNil }) }
        def("kotlin/text/toLongOrNull") { x("parse", self, args.getOrElse(0) { LuaNil }) }
        def("kotlin/text/toULong") { x("parseOrThrow", self, args.getOrElse(0) { LuaNil }, LuaBool(true)) }
        def("kotlin/text/toULongOrNull") { x("parse", self, args.getOrElse(0) { LuaNil }, LuaBool(true)) }
    }

    private fun CallSite.wideElements(type: org.jetbrains.kotlin.analysis.api.types.KaType?): Boolean = with(session) {
        val classId = (type?.withoutFlexibility as? org.jetbrains.kotlin.analysis.api.types.KaClassType)?.classId?.asString()
        classId == "kotlin/LongArray" || classId == "kotlin/ULongArray" || isWideRange(type) || isWide(type?.elementType)
    }

    /** `sum()` of `Long`s and `ULong`s adds with `__K2L_LAdd`; `sumOf` maps first; `average()` converts to doubles first. */
    private fun sums(callableId: String, site: CallSite): LuaExpr? = with(site) {
        val collection = callableId.startsWith("kotlin/collections/") || callableId.startsWith("kotlin/sequences/")
        if (!collection || receiver == null) return null
        val add = ref(LONG64_FEATURE, "__K2L_LAdd")
        return when (name) {
            "sum" -> if (wideElements(receiverType)) LuaMethodCall(self, "fold", listOf(LuaNumber("0"), add)) else null

            "sumOf" ->
                if (wide((argTypes.firstOrNull() as? KaFunctionType)?.returnType)) {
                    LuaMethodCall(LuaMethodCall(self, "map", args), "fold", listOf(LuaNumber("0"), add))
                } else {
                    null
                }

            "average" -> if (wideElements(receiverType)) {
                LuaMethodCall(LuaMethodCall(self, "map", listOf(ref(LONG64_FEATURE, "__K2L_LDouble"))), "average", emptyList())
            } else {
                null
            }

            else -> null
        }
    }
}
