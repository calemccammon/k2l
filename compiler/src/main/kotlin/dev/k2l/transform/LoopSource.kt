package dev.k2l.transform

import dev.k2l.codegen.*

/**
 * Where a `for` loop finds the elements it walks: [items] (an array read `items[i]` for `i = 1, count`). The count is read
 * once, when the loop starts; a change of the collection made by the loop's body is not detected.
 */
internal class LoopSource(
    val items: LuaExpr,
    val count: LuaExpr,
    /** The values of a map's keys [items], for `for ((k, v) in map)`. */
    val values: LuaExpr? = null,
)

/** The elements of a list (or array) [list]: itself, by index up to the size it has when the loop starts. */
internal fun FileTransformer.listSource(list: LuaExpr): LoopSource {
    val items = cache(list, "list")
    return LoopSource(items, LuaIndex(items, LuaString("size")))
}

/**
 * The elements of [collection] (a set, collection, iterable, or a map with [arrayMethod] `____keyArray`,
 * `____valueArray` or `____entryArray`): `local items, n = c:____array()`.
 */
internal fun FileTransformer.arraySource(collection: LuaExpr, arrayMethod: String = "____array"): LoopSource {
    val owner = cache(collection, "collection")
    val items = ctx.temp("items")
    val count = ctx.temp("n")
    emit(LuaLocal(listOf(items, count), listOf(LuaMethodCall(owner, arrayMethod, emptyList()))))
    return LoopSource(LuaName(items), LuaName(count))
}

/** The keys and values of [map] (`local keys, values, n = map:____arrays()`), for `for ((k, v) in map)`. */
internal fun FileTransformer.mapPairsSource(map: LuaExpr): LoopSource {
    val owner = cache(map, "map")
    val keys = ctx.temp("keys")
    val values = ctx.temp("values")
    val count = ctx.temp("n")
    emit(LuaLocal(listOf(keys, values, count), listOf(LuaMethodCall(owner, "____arrays", emptyList()))))
    return LoopSource(LuaName(keys), LuaName(count), LuaName(values))
}

/**
 * `for i = 1, count do local variable = items[i] ... end` over [source] (`local k, v = keys[i], values[i]` with two
 * [variables] for a map's pairs), with `local index = i - 1` when [index] is given.
 */
internal fun FileTransformer.elementsLoop(source: LoopSource, variable: String, index: String?, body: List<LuaStmt>) =
    elementsLoop(source, listOf(variable), index, body)

internal fun FileTransformer.elementsLoop(source: LoopSource, variables: List<String>, index: String?, body: List<LuaStmt>) {
    val i = ctx.temp("i")
    val element = listOfNotNull(source.items, source.values).map { LuaIndex(it, LuaName(i)) }
    val header = listOfNotNull(
        LuaLocal(variables, element),
        index?.let { LuaLocal(listOf(it), listOf(LuaBinary(LuaBinOp.Sub, LuaName(i), LuaNumber("1")))) },
    )
    emit(LuaNumericFor(i, LuaNumber("1"), source.count, null, header + body))
}
