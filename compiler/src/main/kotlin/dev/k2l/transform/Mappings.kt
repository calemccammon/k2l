package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtQualifiedExpression

/** What a mapping produces for a call, or null when it doesn't handle that overload. */
typealias Mapping = CallSite.() -> LuaExpr?

/** One area of mappings (an object's `map`): what it produces for the call to [callableId], or null when it doesn't handle it. */
typealias MappingArea = (callableId: String?, site: CallSite) -> LuaExpr?

/** Stdlib callables by `CallableId` string; the `*Mappings` objects each register their own area. */
class MappingTable {
    val entries = mutableMapOf<String, Mapping>()

    /** The ids defined again after they were already defined, in order; the later definition wins (see MappingTableTest). */
    val overwrites = mutableListOf<String>()

    fun def(vararg ids: String, mapping: Mapping) = ids.forEach { id ->
        if (entries.put(id, mapping) != null) overwrites += id
    }
}

internal fun method(target: LuaExpr, name: String, vararg args: LuaExpr) = LuaMethodCall(target, name, args.toList())

/** `lua("math.max", a, b)` is `math.max(a, b)`. */
internal fun lua(path: String, vararg args: LuaExpr): LuaExpr {
    val parts = path.split('.')
    return LuaCall(luaPath(parts[0], *parts.drop(1).toTypedArray()), args.toList())
}

internal fun List<LuaExpr>.dropTrailingNil(): List<LuaExpr> = dropLastWhile { it == LuaNil }

internal fun num(text: String) = LuaNumber(text)

/** Names and literals can be evaluated twice without changing the program. */
internal fun LuaExpr.isSimple(): Boolean = this is LuaName || this is LuaNumber || this is LuaString || this is LuaBool ||
    (this is LuaIndex && target.isSimple() && key.isSimple())

internal fun CallSite.isIntegral(type: KaType?): Boolean = type != null && with(session) { type.isIntegral }

internal fun CallSite.isFloating(type: KaType?): Boolean =
    type != null && with(session) { type.withoutFlexibility.let { it.isDoubleType || it.isFloatType } }

internal fun CallSite.isTextual(type: KaType?): Boolean = type != null && with(session) { type.isTextual }

internal fun CallSite.isChar(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isCharType }

internal fun CallSite.isString(type: KaType?): Boolean = type != null && with(session) { type.withoutFlexibility.isStringType }

/** Whether the call is written as a function call (`range.first()`), not a property access (`range.first`). */
internal fun CallSite.isFunctionCall(): Boolean =
    element is KtCallExpression || (element as? KtQualifiedExpression)?.selectorExpression is KtCallExpression
