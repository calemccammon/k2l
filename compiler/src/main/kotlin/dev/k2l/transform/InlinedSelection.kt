package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.KtExpression

/** Collection functions that pick, order or split elements by a lambda; see [selecting]. */
internal val SELECTING_FUNCTIONS = setOf(
    "partition", "maxByOrNull", "minByOrNull", "maxBy", "minBy", "maxOf", "minOf", "maxOfOrNull", "minOfOrNull", "reduce",
    "reduceOrNull", "distinctBy", "filterIndexed", "mapIndexed", "indexOfFirst", "indexOfLast",
    "last", "lastOrNull", "findLast", "single", "singleOrNull", "takeLastWhile", "dropLastWhile", "dropWhile", "zip",
)

/** Functions that exist on `Map` and produce a map (or, `onEach`, the map itself); `filter`, `filterNot` and `onEach` also on lists. */
internal val MAP_RESULT_FUNCTIONS = setOf("filter", "filterNot", "onEach", "mapValues", "mapKeys", "filterKeys", "filterValues")

private const val PAIR_FEATURE = "Pair"

/** An index the lambda does not name: parameter 1 of a one-parameter lambda, parameter 2 of a two-parameter one. */
private const val FIRST_FREE_PARAM = 1
private const val SECOND_FREE_PARAM = 2

private fun FileTransformer.newPair(first: LuaExpr, second: LuaExpr): LuaExpr =
    LuaCall(LuaIndex(lualibRef(PAIR_FEATURE, "__K2L_Pair"), LuaString("new")), listOf(first, second))

private fun field(target: LuaExpr, name: String): LuaExpr = LuaIndex(target, LuaString(name))

private fun setTrue(flag: LuaName): LuaStmt = assign(flag.name, LuaBool(true))

/** Lowers the [SELECTING_FUNCTIONS] to a loop over [source] with the lambda inlined, like `listing` does for `map`. */
internal fun FileTransformer.selecting(name: String, source: Source, args: List<KtExpression?>, full: KtExpression): LuaExpr {
    val lambda = (if (name == "zip") args.getOrNull(1) else args[0]) ?: return LuaNil
    return when (name) {
        "partition" -> partitioning(source, lambda)
        "maxByOrNull", "minByOrNull", "maxBy", "minBy", "maxOf", "minOf", "maxOfOrNull", "minOfOrNull" -> extreme(name, source, lambda)
        "reduce", "reduceOrNull" -> reducing(name, source, lambda)
        "distinctBy" -> distinctBy(source, lambda)
        "filterIndexed", "mapIndexed" -> indexed(name, source, lambda)
        "indexOfFirst", "indexOfLast" -> indexSearch(name == "indexOfLast", source, lambda)
        "last", "lastOrNull", "findLast", "single", "singleOrNull" -> lastOrSingle(name, source, lambda)
        "takeLastWhile", "dropLastWhile", "dropWhile" -> trimming(name, source, lambda)
        else -> zipping(source, args, full)
    }
}

private fun FileTransformer.partitioning(source: Source, lambda: KtExpression): LuaExpr {
    val yes = declare("yes", newList())
    val no = declare("no", newList())
    eachElement(source, lambda, 0) { item, _ ->
        emit(LuaIf(inlineValue(lambda, listOf(item), null), listOf(add(yes, item)), listOf(add(no, item))))
    }
    return newPair(yes, no)
}

/** `maxByOrNull { }`, `minBy { }`, `maxOf { }`, ...: the first element with the greatest (smallest) key, or that key. */
private fun FileTransformer.extreme(name: String, source: Source, lambda: KtExpression): LuaExpr {
    val orNull = name.endsWith("OrNull")
    val order = if (name.startsWith("max")) LuaBinOp.Gt else LuaBinOp.Lt
    val keyOnly = name.contains("Of")
    val best = declare("best")
    val bestKey = declare("bestKey")
    val has = declare("has", LuaBool(false))
    eachElement(source, lambda, 0) { item, _ ->
        val key = cache(inlineValue(lambda, listOf(item), null), "key")
        val compare = LuaBinary(order, LuaCall(lualibRef("Compare", "__K2L_Compare"), listOf(key, bestKey)), LuaNumber("0"))
        val update = listOf(assign(best.name, item), assign(bestKey.name, key), setTrue(has))
        emit(LuaIf(LuaBinary(LuaBinOp.Or, negate(has), compare), update))
    }
    if (!orNull) emit(LuaIf(negate(has), listOf(throwNew("__K2L_NoSuchElementException", LuaNil))))
    return if (keyOnly) bestKey else best
}

private fun FileTransformer.reducing(name: String, source: Source, lambda: KtExpression): LuaExpr {
    val acc = declare("acc")
    val started = declare("started", LuaBool(false))
    // The accumulator is reassigned, so the lambda's parameter gets a copy rather than standing for it.
    val current = LuaName(acc.name)
    eachElement(source, lambda, 1) { item, _ ->
        val first = listOf(assign(acc.name, item), setTrue(started))
        val rest = collect { emit(assign(acc.name, inlineValue(lambda, listOf(current, item), null))) }
        emit(LuaIf(negate(started), first, rest))
    }
    if (name == "reduce") {
        val message = LuaString("Empty collection can't be reduced.")
        emit(LuaIf(negate(started), listOf(throwNew("__K2L_UnsupportedOperationException", message))))
    }
    return acc
}

private fun FileTransformer.distinctBy(source: Source, lambda: KtExpression): LuaExpr {
    val seen = declare("seen", LuaCall(lualibRef("Collections", "__K2L_SetOf"), emptyList()))
    val result = declare("result", newList())
    eachElement(source, lambda, 0) { item, _ ->
        emit(LuaIf(LuaMethodCall(seen, "add", listOf(inlineValue(lambda, listOf(item), null))), listOf(add(result, item))))
    }
    return result
}

/** `filterIndexed { index, e -> }`, `mapIndexed { index, e -> }` and their relatives; the result goes to [into] if given. */
internal fun FileTransformer.indexed(name: String, source: Source, lambda: KtExpression, into: LuaExpr? = null): LuaExpr = with(session) {
    val result = into ?: declare("result", newList())
    val flatKind = (lambdaLiteral(lambda)?.expressionType as? KaFunctionType)?.returnType?.collectionKind()
    eachElement(source, lambda, 1, indexParam = 0) { item, index ->
        val value = inlineValue(lambda, listOf(index!!, item), null)
        when (name) {
            "mapIndexed", "mapIndexedTo" -> emit(add(result, value))

            "mapIndexedNotNull" -> {
                val cached = cache(value, "value")
                emit(LuaIf(LuaBinary(LuaBinOp.Ne, cached, LuaNil), listOf(add(result, cached))))
            }

            "flatMapIndexed" -> {
                val elements = if (flatKind == CollectionKind.Sequence) LuaMethodCall(value, "toList", emptyList()) else value
                emit(LuaCallStmt(LuaMethodCall(result, "addAll", listOf(elements))))
            }

            else -> emit(LuaIf(value, listOf(add(result, item))))
        }
    }
    return result
}

/** The JVM walks lists and arrays from the end for `last { }`, `indexOfLast { }` and the like, and other collections forwards. */
private fun Source.fromEnd() = kind.isIndexable

private fun FileTransformer.indexSearch(last: Boolean, source: Source, lambda: KtExpression): LuaExpr {
    val result = declare("index", LuaNumber("-1"))
    val backwards = last && source.fromEnd()
    eachElement(source, lambda, 0, indexParam = FIRST_FREE_PARAM, backwards = backwards) { item, index ->
        val found = listOf(assign(result.name, index!!)) + if (!last || backwards) listOf(LuaBreak) else emptyList()
        emit(LuaIf(inlineValue(lambda, listOf(item), null), found))
    }
    return result
}

private fun containerWord(source: Source, list: String) = when (source.kind) {
    CollectionKind.Array -> "Array"
    CollectionKind.List -> list
    else -> "Collection"
}

private fun FileTransformer.lastOrSingle(name: String, source: Source, lambda: KtExpression): LuaExpr {
    val single = name.startsWith("single")
    val result = declare("result")
    val found = declare("found", LuaBool(false))
    val backwards = !single && source.fromEnd()
    eachElement(source, lambda, 0, backwards = backwards) { item, _ ->
        val hit = when {
            !single -> listOf(assign(result.name, item), setTrue(found)) + if (backwards) listOf(LuaBreak) else emptyList()

            name == "singleOrNull" -> listOf(
                LuaIf(found, listOf(assign(result.name, LuaNil), LuaBreak)),
                assign(result.name, item),
                setTrue(found),
            )

            else -> {
                val many = LuaString("${containerWord(source, "Collection")} contains more than one matching element.")
                listOf(LuaIf(found, listOf(throwNew("__K2L_IllegalArgumentException", many))), assign(result.name, item), setTrue(found))
            }
        }
        emit(LuaIf(inlineValue(lambda, listOf(item), null), hit))
    }
    if (name == "last" || name == "single") {
        val message =
            LuaString("${containerWord(source, if (single) "Collection" else "List")} contains no element matching the predicate.")
        emit(LuaIf(negate(found), listOf(throwNew("__K2L_NoSuchElementException", message))))
    }
    return result
}

/** `takeLastWhile`, `dropLastWhile` (from the end of the list) and `dropWhile`. */
private fun FileTransformer.trimming(name: String, source: Source, lambda: KtExpression): LuaExpr {
    val fromEnd = name.endsWith("LastWhile")
    val result = declare("result", newList())
    val dropping = declare("dropping", LuaBool(true))
    eachElement(source, lambda, 0, backwards = fromEnd) { item, _ ->
        if (name == "takeLastWhile") {
            emit(LuaIf(negate(inlineValue(lambda, listOf(item), null)), listOf(LuaBreak)))
            emit(add(result, item))
        } else {
            val check = collect {
                emit(LuaIf(negate(inlineValue(lambda, listOf(item), null)), listOf(assign(dropping.name, LuaBool(false)))))
            }
            emit(LuaIf(dropping, check))
            emit(LuaIf(negate(dropping), listOf(add(result, item))))
        }
    }
    return if (fromEnd) LuaMethodCall(result, "reversed", emptyList()) else result
}

/** `zip(other) { a, b -> }`: as many elements as the shorter of the two. */
private fun FileTransformer.zipping(source: Source, args: List<KtExpression?>, full: KtExpression): LuaExpr = with(session) {
    val lambda = args[1]!!
    val otherExpr = args[0]!!
    val otherKind = otherExpr.expressionType?.collectionKind()
    if (otherKind !in ITERATED_KINDS) return unsupported(full, "A non-local return in 'zip' with '$otherKind'")
    val other = cache(asList(otherKind, expression(otherExpr)), "other")
    val result = declare("result", newList())
    eachElement(source, lambda, 0, indexParam = SECOND_FREE_PARAM) { item, index ->
        emit(LuaIf(LuaBinary(LuaBinOp.Ge, index!!, field(other, "size")), listOf(LuaBreak)))
        val second = LuaIndex(other, LuaBinary(LuaBinOp.Add, index, LuaNumber("1")))
        emit(add(result, inlineValue(lambda, listOf(item, second), null)))
    }
    return result
}

/** The `Map` functions that produce a map: `filter`, `mapValues`, ...; the loop runs over the entries. */
internal fun FileTransformer.mapResult(name: String, source: Source, lambda: KtExpression, into: LuaExpr? = null): LuaExpr {
    if (name == "onEach") {
        eachElement(source, lambda, 0) { entry, _ -> inlineLambda(lambda, listOf(entry), null, null) }
        return source.collection
    }
    val result = into ?: declare("result", newMap())
    // filterKeys and filterValues take the key or the value, so the entry needs a name of its own.
    val byPart = name == "filterKeys" || name == "filterValues"
    eachElement(source, lambda, 0, itemName = if (byPart) ctx.temp("entry") else null) { entry, _ ->
        val key = field(entry, "key")
        val value = field(entry, "value")
        when (name) {
            "filter", "filterNot" -> {
                val test = inlineValue(lambda, listOf(entry), null)
                emit(LuaIf(if (name == "filter") test else negate(test), listOf(put(result, key, value))))
            }

            "filterKeys", "filterValues" -> {
                val test = inlineValue(lambda, listOf(if (name == "filterKeys") key else value), null)
                emit(LuaIf(test, listOf(put(result, key, value))))
            }

            "mapValues" -> emit(put(result, key, inlineValue(lambda, listOf(entry), null)))

            else -> emit(put(result, inlineValue(lambda, listOf(entry), null), value))
        }
    }
    return result
}
