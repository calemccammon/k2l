package dev.k2l.transform

import dev.k2l.LuaTarget
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * Exact `Long` and `ULong` on targets without 64-bit integers (`--long64 emulate`, Lua 5.1, 5.2 and LuaJIT).
 *
 * A value is a Lua number while it is a safe integer (|v| < 2^53) and a box beyond: an `int64_t` cdata on LuaJIT, a
 * `{hi, lo}` table with arithmetic metamethods elsewhere. A value always has exactly one form, so `==` stays exact
 * and numbers produced by the rest of the runtime (sizes, counts, `Int.toLong()`) are already valid `Long`s. The
 * operations on wide types call `__K2L_LAdd` and friends (`Long64.l64*.lua`), which return the canonical form.
 * A `ULong` is the two's complement bit pattern of a `Long` (`ULong.MAX_VALUE` is -1); only division, remainder,
 * comparison, shifts to the right and printing are told apart by the static type, as on Lua 5.3.
 */
internal val FileTransformer.emulatesLong: Boolean get() = ctx.options.emulatesLong64

private const val SAFE_LIMIT = 9007199254740992L
private const val TWO_32 = 4294967296L
private const val MAX_HOISTED = 40

/** `Long` or `ULong`: the types whose values can be boxes (a smart-cast `Long?` operand counts too). */
internal fun KaSession.isWide(t: KaType?): Boolean = t != null && t.withoutFlexibility.let { it.isLongType || it.isULongType }

internal fun KaSession.isULongType(t: KaType?): Boolean = t != null && t.withoutFlexibility.isULongType

/** `LongRange`, `LongProgression`, `ULongRange` or `ULongProgression`: ranges whose bounds can be boxes. */
internal fun KaSession.isWideRange(t: KaType?): Boolean =
    (t?.withoutFlexibility as? org.jetbrains.kotlin.analysis.api.types.KaClassType)?.classId?.asString() in WIDE_RANGES

private val WIDE_RANGES =
    setOf("kotlin/ranges/LongRange", "kotlin/ranges/LongProgression", "kotlin/ranges/ULongRange", "kotlin/ranges/ULongProgression")

internal fun KaSession.isFloating(t: KaType?): Boolean = t != null && t.withoutFlexibility.let { it.isDoubleType || it.isFloatType }

/** `__K2L_LAdd(a, b)`: the hot operations are separate lualib locals. */
internal fun FileTransformer.l64(op: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(lualibRef(LONG64_FEATURE, "__K2L_L$op"), args.toList())

/** `__K2L_Long64.member(...)`, the table of the less common core operations. */
internal fun FileTransformer.l64Member(member: String, vararg args: LuaExpr): LuaExpr = libCall(LONG64_TABLE, member, args.toList())

/** `__K2L_Long64X.member(...)`: parsing, bit counts, exact arithmetic and the like (`Long64Ext.l64.lua`). */
internal fun FileTransformer.l64x(member: String, vararg args: LuaExpr): LuaExpr = libCall(LONG64_EXT_TABLE, member, args.toList())

/** The `Long` constant [value] (or the bit pattern of a `ULong`) as an expression. */
internal fun FileTransformer.long64Literal(value: Long): LuaExpr {
    if (value > -SAFE_LIMIT && value < SAFE_LIMIT) return LuaNumber(value.toString())
    if (target.hasInt64Literals) return LuaNumber(if (value == Long.MIN_VALUE) "-9223372036854775808LL" else "${value}LL")
    val hi = Math.floorDiv(value, TWO_32)
    val lo = value - hi * TWO_32
    // A box is a table, so a constant used in a loop is created once, in a local at the top of the file.
    val hoisted =
        ctx.longLiterals[hi to lo]
            ?: ctx.temp("long").takeIf { ctx.longLiterals.size < MAX_HOISTED }?.also { ctx.longLiterals[hi to lo] = it }
    return hoisted?.let { LuaName(it) } ?: l64("Lit", LuaNumber(hi.toString()), LuaNumber(lo.toString()))
}

/** The locals holding the hoisted `Long` constants, declared before the first declaration of the file. */
internal fun FileTransformer.hoistedLongs(): List<LuaStmt> = ctx.longLiterals.map { (parts, name) ->
    LuaLocal(listOf(name), listOf(l64("Lit", LuaNumber(parts.first.toString()), LuaNumber(parts.second.toString()))))
}

/** A wide operand next to a floating one is converted to a double first. */
internal fun FileTransformer.long64Widen(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): Pair<LuaExpr, LuaExpr> {
    if (!emulatesLong) return l to r
    return with(session) {
        val left = if (isWide(lt) && isFloating(rt)) toDouble(l, lt) else l
        val right = if (isWide(rt) && isFloating(lt)) toDouble(r, rt) else r
        left to right
    }
}

internal fun FileTransformer.toDouble(value: LuaExpr, type: KaType?): LuaExpr = if (with(session) { isULongType(type) }) {
    libCall(UNSIGNED_TABLE, "toDouble", listOf(value))
} else {
    l64("Double", value)
}

/** `l op r` for `+ - *` when an operand is a `Long` or `ULong` and none is floating; null otherwise. */
internal fun FileTransformer.long64Arithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    if (!emulatesLong || !integralPair(lt, rt)) return null
    val name = when (op) {
        LuaBinOp.Add -> "Add"
        LuaBinOp.Sub -> "Sub"
        LuaBinOp.Mul -> "Mul"
        else -> return null
    }
    return l64(name, l, r)
}

/** Whether `lt op rt` has a wide operand and the other one is an integer type too. */
private fun FileTransformer.integralPair(lt: KaType?, rt: KaType?): Boolean = with(session) {
    (isWide(lt) || isWide(rt)) && !isFloating(lt) && !isFloating(rt) && lt != null && rt != null && lt.isIntegral && rt.isIntegral
}

internal fun FileTransformer.long64Division(remainder: Boolean, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    if (!emulatesLong || !integralPair(lt, rt)) return null
    val unsigned = with(session) { isULongType(lt) || isULongType(rt) }
    return when {
        unsigned -> l64Member(if (remainder) "urem" else "udiv", l, r)
        remainder -> l64("Rem", l, r)
        else -> l64("Div", l, r)
    }
}

internal fun FileTransformer.long64Negation(value: LuaExpr, type: KaType?): LuaExpr? =
    if (emulatesLong && with(session) { isWide(type) }) l64("Neg", value) else null

/** `read + 1` / `read - 1` of `++` and `--` on a wide variable. */
internal fun FileTransformer.long64Step(op: LuaBinOp, read: LuaExpr, type: KaType?): LuaExpr? =
    if (emulatesLong && with(session) { isWide(type) }) l64(if (op == LuaBinOp.Add) "Add" else "Sub", read, LuaNumber("1")) else null

/**
 * `l < r` and friends when an operand is wide. `ULong`s compare as unsigned; on Lua 5.1 a mixed number and box cannot be
 * compared with `<`, so `__K2L_LLt` is used (and `__K2L_LCmp` when swapping the operands would reorder side effects).
 */
internal fun FileTransformer.long64Comparison(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
    if (!emulatesLong || !with(session) { isWide(lt) || isWide(rt) }) return null
    val zero = LuaNumber("0")
    return when {
        with(session) { isFloating(lt) || isFloating(rt) } -> long64Widen(l, lt, r, rt).let { (a, b) -> LuaBinary(op, a, b) }
        with(session) { isULongType(lt) || isULongType(rt) } -> LuaBinary(op, l64Member("ucmp", l, r), zero)
        !target.comparesMixedTypes -> lua51Comparison(op, l, r)
        else -> LuaBinary(op, l, r)
    }
}

private fun FileTransformer.lua51Comparison(op: LuaBinOp, l: LuaExpr, r: LuaExpr): LuaExpr? {
    val simple = l.isSimple() && r.isSimple()
    return when (op) {
        LuaBinOp.Lt -> l64("Lt", l, r)
        LuaBinOp.Le -> l64("Le", l, r)
        LuaBinOp.Gt -> if (simple) l64("Lt", r, l) else LuaBinary(op, l64("Cmp", l, r), LuaNumber("0"))
        LuaBinOp.Ge -> if (simple) l64("Le", r, l) else LuaBinary(op, l64("Cmp", l, r), LuaNumber("0"))
        else -> null
    }
}
