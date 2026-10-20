package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * Collection functions compiled to a loop with their lambda literal inlined even without a non-local `return`: a call of
 * the lualib method would create a closure per call and call it per element (and LuaJIT cannot compile closure creation).
 * Each loop does what its method in `Collections.lua` does: it walks `local items, n = c:____array()` (the elements, as
 * many as there were when it started, with no check for changes) and builds the same result.
 */
private val LOOPED_FUNCTIONS = setOf(
    "map", "mapIndexed", "mapNotNull", "filter", "filterNot", "filterIndexed", "flatMap", "count", "any", "all", "none", "sumOf",
    "first", "firstOrNull", "find", "maxOf", "minOf", "groupBy", "associateBy", "associateWith",
)

/**
 * The receivers walked with `____array()`: lists, arrays, sets and other collections (maps, sequences, ranges and strings have
 * methods of their own; an Iterable may be endless, and `first { }` on it stops early).
 */
private val LOOPED_KINDS = setOf(CollectionKind.List, CollectionKind.Array, CollectionKind.Set)
private val LOOPED_COLLECTIONS = setOf("kotlin/collections/Collection", "kotlin/collections/MutableCollection", "java/util/Collection")

private fun FileTransformer.isLooped(type: KaType?): Boolean = with(session) {
    type?.collectionKind() in LOOPED_KINDS || type?.expandedSymbol?.classId?.asString() in LOOPED_COLLECTIONS
}

/**
 * The loop for `name` (of [LOOPED_FUNCTIONS]) when its receiver (of type [type], translated by [receiver]) is walked with
 * `____array()` and every function argument is a lambda literal, else null (the call stays a method call).
 */
internal fun FileTransformer.loopedCollectionCall(
    name: String,
    args: List<KtExpression?>,
    type: KaType?,
    full: KtExpression,
    receiverExpr: KtExpression?,
    receiver: () -> LuaExpr?,
): LuaExpr? = with(session) {
    if (name !in LOOPED_FUNCTIONS || implementsCollections || !isLooped(type)) return null
    if (args.isEmpty() || args.any { lambdaLiteral(it) == null }) return null
    val numbers = name == "sumOf" || name == "maxOf" || name == "minOf"
    if (numbers && !isPlainNumber(full.expressionType)) return null
    val source = loopedSource(type!!, receiverExpr, receiver) ?: return null
    val lambda = args[0]!!
    when (name) {
        "map", "mapIndexed", "mapNotNull", "filter", "filterNot", "filterIndexed", "flatMap" -> loopedListing(name, source, lambda)
        "count", "any", "all", "none", "first", "firstOrNull", "find" -> searching(name, source, lambda)
        "sumOf" -> summing(source, lambda, full)
        "maxOf", "minOf" -> loopedExtreme(name == "maxOf", source, lambda, full.expressionType!!.isDoubleType)
        else -> loopedGrouping(name, source, args)
    }
}

/** An Int, a Double, or a Long that is a Lua number: summed and compared with Lua's operators. */
private fun FileTransformer.isPlainNumber(t: KaType?): Boolean = with(session) {
    t != null && (t.isIntType || t.isDoubleType || (t.isLongType && !emulatesLong))
}

/** What the loop walks: an enum's `____values` for `E.entries`, else the receiver's `____array()`. */
private fun FileTransformer.loopedSource(type: KaType, receiverExpr: KtExpression?, receiver: () -> LuaExpr?): Source? = with(session) {
    val entries = enumEntriesOf(receiverExpr)
    if (entries != null) {
        Source(enumValuesTable(entries), CollectionKind.List, false, snapshot = true, plainArray = true)
    } else {
        Source(cache(receiver() ?: return null, "list"), type.collectionKind()!!, true, snapshot = true)
    }
}

/** `local items, n = c:____array()` and `for i = 1, n do local it = items[i] ... end`, see [eachElement]. */
internal fun FileTransformer.snapshotLoop(source: Source, item: String, index: LuaName?, body: List<LuaStmt>) {
    val (items, count) = if (source.plainArray) {
        source.collection to LuaUnary(LuaUnOp.Len, source.collection)
    } else {
        val names = listOf(ctx.temp("items"), ctx.temp("n"))
        emit(LuaLocal(names, listOf(LuaMethodCall(source.collection, "____array", emptyList()))))
        LuaName(names[0]) to LuaName(names[1])
    }
    val i = ctx.temp("i")
    val header = listOfNotNull(
        LuaLocal(listOf(item), listOf(LuaIndex(items, LuaName(i)))),
        index?.let { LuaLocal(listOf(it.name), listOf(LuaBinary(LuaBinOp.Sub, LuaName(i), LuaNumber("1")))) },
    )
    emit(LuaNumericFor(i, LuaNumber("1"), count, null, header + body))
}

/** `map`, `filter` and the like: a plain table filled in the loop, made a list at the end (`__K2L_ListWrap`). */
private fun FileTransformer.loopedListing(name: String, source: Source, lambda: KtExpression): LuaExpr = with(session) {
    val out = declare("out", LuaTable(emptyList()))
    val count = declare("count", LuaNumber("0"))
    fun append(value: LuaExpr): List<LuaStmt> = listOf(
        assign(count.name, LuaBinary(LuaBinOp.Add, count, LuaNumber("1"))),
        assign(LuaIndex(out, count), value),
    )
    val indexed = name.endsWith("Indexed")
    eachElement(source, lambda, if (indexed) 1 else 0, indexParam = if (indexed) 0 else null) { item, index ->
        val value = inlineValue(lambda, listOfNotNull(index, item), null)
        when (name) {
            "map", "mapIndexed" -> emitAll(append(value))

            "mapNotNull" -> {
                val v = cache(value, "value")
                emit(LuaIf(LuaBinary(LuaBinOp.Ne, v, LuaNil), append(v)))
            }

            "filter", "filterIndexed" -> emit(LuaIf(value, append(item)))

            "filterNot" -> emit(LuaIf(negate(value), append(item)))

            else -> {
                val inner = ctx.temp("inner")
                val size = ctx.temp("m")
                val j = ctx.temp("j")
                emit(LuaLocal(listOf(inner, size), listOf(LuaMethodCall(value, "____array", emptyList()))))
                emit(LuaNumericFor(j, LuaNumber("1"), LuaName(size), null, append(LuaIndex(LuaName(inner), LuaName(j)))))
            }
        }
    }
    return lualibCall("ListWrap", out, count)
}

/**
 * `maxOf { }` and `minOf { }` of numbers: the first greatest (smallest) key, comparing as the lualib does (`__K2L_Compare`
 * for doubles, for NaN and -0.0; Ints and Longs compare with `<`). An empty collection throws NoSuchElementException.
 */
private fun FileTransformer.loopedExtreme(max: Boolean, source: Source, lambda: KtExpression, isDouble: Boolean): LuaExpr {
    val best = declare("best")
    val has = declare("has", LuaBool(false))
    eachElement(source, lambda, 0) { item, _ ->
        val key = cache(inlineValue(lambda, listOf(item), null), "key")
        val better = if (isDouble) {
            val compare = LuaCall(lualibRef("Compare", "__K2L_Compare"), listOf(best, key))
            LuaBinary(if (max) LuaBinOp.Lt else LuaBinOp.Gt, compare, LuaNumber("0"))
        } else {
            LuaBinary(if (max) LuaBinOp.Lt else LuaBinOp.Gt, best, key)
        }
        emit(LuaIf(LuaBinary(LuaBinOp.Or, negate(has), better), listOf(assign(best.name, key), assign(has.name, LuaBool(true)))))
    }
    emit(LuaIf(negate(has), listOf(throwNew("__K2L_NoSuchElementException", LuaNil))))
    return best
}

/** `groupBy`, `associateBy` (with or without a value transform) and `associateWith` into a new `__K2L_Map`. */
private fun FileTransformer.loopedGrouping(name: String, source: Source, args: List<KtExpression?>): LuaExpr {
    val newOf = { cls: String -> LuaCall(LuaIndex(lualibRef("Collections", cls), LuaString("new")), emptyList()) }
    val result = declare("result", newOf("__K2L_Map"))
    val first = args[0]!!
    val second = args.getOrNull(1)
    eachElement(source, first, 0) { item, _ ->
        val value = cache(inlineValue(first, listOf(item), null), "value")
        when (name) {
            "associateWith" -> emit(put(result, item, value))

            "associateBy" -> emit(put(result, value, second?.let { inlineValue(it, listOf(item), null) } ?: item))

            else -> {
                val group = declare("group", LuaMethodCall(result, "get", listOf(value)))
                val create = listOf(assign(group.name, newOf("__K2L_List")), put(result, value, group))
                emit(LuaIf(LuaBinary(LuaBinOp.Eq, group, LuaNil), create))
                emit(add(group, second?.let { inlineValue(it, listOf(item), null) } ?: item))
            }
        }
    }
    return result
}
