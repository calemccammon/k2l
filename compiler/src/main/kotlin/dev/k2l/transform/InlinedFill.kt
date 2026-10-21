package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtExpression

/** `mapTo(destination) { }` and the other functions that add their results to a collection given by the caller. */
internal val FILLING_FUNCTIONS = setOf(
    "mapValuesTo", "mapKeysTo", "mapTo", "filterTo", "filterNotTo", "mapNotNullTo", "flatMapTo", "associateTo", "associateByTo",
    "associateWithTo", "groupByTo", "filterIndexedTo", "mapIndexedTo",
)

/** Folds whose lambda also takes the index, and the running ones. */
internal val ACCUMULATING_FUNCTIONS = setOf(
    "reduceIndexed",
    "foldIndexed",
    "runningFold",
    "scan",
    "runningReduce",
    "foldRight",
    "reduceRight",
)

internal val INDEXED_LISTING = setOf("mapIndexedNotNull", "flatMapIndexed")

/** The ones that stop at the first result that is not null, and `onEachIndexed`. */
internal val OTHER_EXPANDED = setOf("firstNotNullOf", "firstNotNullOfOrNull", "onEachIndexed", "mapValuesTo", "mapKeysTo")

/** Lookups with a fallback lambda: `getOrPut`, `getOrElse` and `ifEmpty`. */
internal val KEYED_FUNCTIONS = setOf("getOrPut", "getOrElse", "elementAtOrElse", "ifEmpty", "ifBlank")

/** Expanded even when the lambda has no non-local `return`: the lualib has no method for them. */
internal val EXPANDED_ALWAYS = setOf(
    "mapNotNullTo", "associateTo", "groupByTo", "flatMapTo", "filterNotTo", "filterIndexedTo", "sumBy", "sumByDouble",
    "onEachIndexed",
)

/** The chars of a String as a list. */
internal fun FileTransformer.charList(text: LuaExpr): LuaExpr = if (utf16) {
    libCall(TEXT_TABLE, "toList", listOf(text))
} else {
    LuaCall(lualibRef("Strings", "__K2L_StringToList"), listOf(text))
}

/** A list of chars as the String they spell. */
internal fun FileTransformer.joinChars(chars: LuaExpr): LuaExpr =
    LuaMethodCall(chars, "joinToString", listOf(LuaString(""))).let { if (utf16) u16Norm(it) else it }

/** `mapTo`, `filterTo`, ...: the same loops as `map`, `filter`, ..., but filling the destination, which is the result. */
internal fun FileTransformer.filling(name: String, source: Source, args: List<KtExpression?>): LuaExpr = with(session) {
    val destination = cache(arguments(emptyList(), listOf(args[0]))[0], "destination")
    val rest = args.drop(1)
    val lambda = rest[0]!!
    when (val base = name.removeSuffix("To")) {
        "mapValues", "mapKeys" -> mapResult(base, source, lambda, destination)

        "filter" -> if (source.kind == CollectionKind.Map) {
            mapResult(base, source, lambda, destination)
        } else {
            listing(base, source, lambda, destination)
        }

        "map", "mapNotNull", "flatMap", "filterNot" -> listing(base, source, lambda, destination)

        "filterIndexed", "mapIndexed" -> indexed(base, source, lambda, destination)

        else -> grouping(base, source, rest, destination)
    }
    return destination
}

/** What a fold passes to its lambda and how it walks the elements. */
private class FoldShape(name: String) {
    val reducing = name == "reduceIndexed" || name == "runningReduce" || name == "reduceRight"
    val right = name == "foldRight" || name == "reduceRight"
    val running = name == "runningReduce" || name == "runningFold" || name == "scan"
    val indexed = name == "foldIndexed" || name == "reduceIndexed"

    /** The lambda parameter that names the element. */
    val elementParam = if (right) {
        0
    } else if (indexed) {
        2
    } else {
        1
    }
}

/** `foldIndexed`, `reduceIndexed`, `foldRight`, `reduceRight`, `runningFold`/`scan` and `runningReduce`. */
internal fun FileTransformer.accumulating(name: String, source: Source, args: List<KtExpression?>): LuaExpr = with(session) {
    val shape = FoldShape(name)
    val lambda = args.last()!!
    val acc = declare("acc", if (shape.reducing) null else arguments(emptyList(), listOf(args[0]))[0])
    val result = if (shape.running) declare("result", newList()) else null
    if (name == "runningFold" || name == "scan") emit(add(result!!, LuaName(acc.name)))
    val started = if (shape.reducing) declare("started", LuaBool(false)) else null
    val indexParam = if (shape.indexed) 0 else null
    eachElement(source, lambda, shape.elementParam, indexParam = indexParam, backwards = shape.right) { item, index ->
        foldElement(shape, lambda, Triple(acc, started, result), item, index)
    }
    if (started != null && !shape.running) {
        val what = if (source.kind == CollectionKind.Array) {
            "array"
        } else if (shape.right) {
            "list"
        } else {
            "collection"
        }
        val message = LuaString("Empty $what can't be reduced.")
        emit(LuaIf(negate(started), listOf(throwNew("__K2L_UnsupportedOperationException", message))))
    }
    return result ?: acc
}

/** The loop body of a fold: the accumulator takes the lambda's value; a reduce starts from the first element. */
private fun FileTransformer.foldElement(
    shape: FoldShape,
    lambda: KtExpression,
    state: Triple<LuaName, LuaName?, LuaName?>,
    item: LuaName,
    index: LuaName?,
) {
    val (acc, started, result) = state
    // The accumulator is reassigned, so the lambda's parameter gets a copy rather than standing for it.
    val current = LuaName(acc.name)
    // the right folds pass the element first
    val arguments = if (shape.right) listOf(item, current) else listOfNotNull(index, current, item)
    val record = result?.let { listOf(add(it, current)) }.orEmpty()
    val step = collect { emit(assign(acc.name, inlineValue(lambda, arguments, null))) } + record
    if (started == null) {
        emitAll(step)
    } else {
        val first = listOf(assign(acc.name, item), assign(started.name, LuaBool(true))) + record
        emit(LuaIf(negate(started), first, step))
    }
}

/** `firstNotNullOf { }` and `firstNotNullOfOrNull { }`: the first result that is not null. */
internal fun FileTransformer.firstNotNull(name: String, source: Source, lambda: KtExpression): LuaExpr {
    val result = declare("result")
    eachElement(source, lambda, 0) { item, _ ->
        val value = cache(inlineValue(lambda, listOf(item), null), "value")
        emit(LuaIf(LuaBinary(LuaBinOp.Ne, value, LuaNil), listOf(assign(result.name, value), LuaBreak)))
    }
    if (name == "firstNotNullOf") {
        val message = LuaString("No element of the collection was transformed to a non-null value.")
        emit(LuaIf(LuaBinary(LuaBinOp.Eq, result, LuaNil), listOf(throwNew("__K2L_NoSuchElementException", message))))
    }
    return result
}

/** `onEachIndexed { index, e -> }`: the collection itself. */
internal fun FileTransformer.eachIndexed(source: Source, lambda: KtExpression): LuaExpr {
    eachElement(source, lambda, 1, indexParam = 0) { item, index -> inlineLambda(lambda, listOf(index!!, item), null, null) }
    return source.collection
}

/** `getOrPut`, `getOrElse`, `elementAtOrElse`, `ifEmpty` and `ifBlank`: the fallback lambda is only evaluated when needed. */
internal fun FileTransformer.keyedCall(name: String, type: KaType?, args: List<KtExpression?>, receiver: LuaExpr): LuaExpr = with(session) {
    val self = cache(receiver, "receiver")
    val kind = type?.collectionKind()
    val lambda = args.last()!!
    val result = declare("value")
    fun fallback(vararg params: LuaExpr) = collect { emit(assign(result.name, inlineValue(lambda, params.toList(), null))) }
    when {
        name == "ifEmpty" || name == "ifBlank" -> {
            val text = type?.isStringType == true || type?.isCharSequenceType == true
            val empty = when {
                name == "ifBlank" -> isBlankText(self)
                text -> LuaBinary(LuaBinOp.Eq, self, LuaString(""))
                else -> LuaMethodCall(self, "isEmpty", emptyList())
            }
            emit(LuaIf(empty, fallback(), listOf(assign(result.name, self))))
        }

        kind == CollectionKind.Map -> {
            val key = cache(arguments(emptyList(), listOf(args[0]))[0], "key")
            emit(assign(result.name, LuaMethodCall(self, "get", listOf(key))))
            val body = fallback() + if (name == "getOrPut") listOf(put(self, key, result)) else emptyList()
            emit(LuaIf(LuaBinary(LuaBinOp.Eq, result, LuaNil), body))
        }

        else -> {
            val index = cache(arguments(emptyList(), listOf(args[0]))[0], "index")
            val inRange = LuaBinary(
                LuaBinOp.And,
                LuaBinary(LuaBinOp.Ge, index, LuaNumber("0")),
                LuaBinary(LuaBinOp.Lt, index, LuaIndex(self, LuaString("size"))),
            )
            emit(LuaIf(inRange, listOf(assign(result.name, CollectionMappings.index(self, index))), fallback(index)))
        }
    }
    return result
}

private fun FileTransformer.isBlankText(text: LuaExpr): LuaExpr = if (utf16) {
    libCall(TEXT_TABLE, "isBlank", listOf(text))
} else {
    LuaCall(lualibRef("Strings", "__K2L_StringIsBlank"), listOf(text))
}
