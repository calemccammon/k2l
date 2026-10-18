package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType

/** What a mapping produces for a call, or null when it doesn't handle that overload. */
typealias Mapping = CallSite.() -> LuaExpr?

/** Stdlib callables by `CallableId` string; the `*Mappings` objects each register their own area. */
class MappingTable {
    val entries = mutableMapOf<String, Mapping>()

    fun def(vararg ids: String, mapping: Mapping) = ids.forEach { entries[it] = mapping }
}

internal fun method(target: LuaExpr, name: String, vararg args: LuaExpr) = LuaMethodCall(target, name, args.toList())

/** `lua("math.max", a, b)` is `math.max(a, b)`. */
internal fun lua(path: String, vararg args: LuaExpr): LuaExpr {
    val parts = path.split('.')
    return LuaCall(luaPath(parts[0], *parts.drop(1).toTypedArray()), args.toList())
}

internal fun List<LuaExpr>.dropTrailingNil(): List<LuaExpr> = dropLastWhile { it == LuaNil }

internal fun num(text: String) = LuaNumber(text)

/** A call to `member` of a lualib table such as `__K2L_Num`, e.g. `__K2L_Num.sinh(x)`. */
internal fun CallSite.libMember(feature: String, table: String, member: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(LuaIndex(ref(feature, table), LuaString(member)), args.toList())

/** Names and literals can be evaluated twice without changing the program. */
internal fun LuaExpr.isSimple(): Boolean = this is LuaName || this is LuaNumber || this is LuaString || this is LuaBool ||
    (this is LuaIndex && target.isSimple() && key.isSimple())

internal fun CallSite.isIntegral(type: KaType?): Boolean = type != null && with(session) { type.isIntegral }

internal fun CallSite.isFloating(type: KaType?): Boolean =
    type != null && with(session) { type.withoutFlexibility.let { it.isDoubleType || it.isFloatType } }

internal fun CallSite.isTextual(type: KaType?): Boolean = type != null && with(session) { type.isTextual }

internal fun CallSite.isChar(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isCharType }

internal fun CallSite.isString(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isStringType }
