package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * Collection functions whose lambda may `return` from the enclosing function (they are `inline` in Kotlin). A call to one of
 * these with such a lambda is lowered to a loop with the lambda inlined, like `forEach`; without one it is an ordinary
 * method call of the lualib (see CollectionMappings).
 */
private val INLINED_COLLECTION_FUNCTIONS = setOf(
    "map", "mapNotNull", "filter", "filterNot", "takeWhile", "flatMap", "any", "all", "none", "count", "first", "firstOrNull",
    "find", "sumOf", "onEach", "fold", "associate", "associateBy", "associateWith", "groupBy",
) + SELECTING_FUNCTIONS + MAP_RESULT_FUNCTIONS + FILLING_FUNCTIONS + ACCUMULATING_FUNCTIONS + INDEXED_LISTING +
    KEYED_FUNCTIONS + EXPANDED_ALWAYS + OTHER_EXPANDED

/** The `CharSequence` functions expanded for a `String`: it is walked as the list of its chars. */
private val INLINED_TEXT_FUNCTIONS = setOf(
    "map", "mapNotNull", "flatMap", "filter", "filterNot", "takeWhile", "dropWhile", "takeLastWhile", "dropLastWhile", "any", "all",
    "none", "count", "first", "firstOrNull", "find", "last", "lastOrNull", "findLast", "single", "singleOrNull", "sumOf", "fold",
    "associate", "associateBy", "associateWith", "groupBy", "indexOfFirst", "indexOfLast", "mapIndexed", "filterIndexed", "reduce",
    "reduceOrNull", "mapIndexedNotNull", "foldIndexed", "reduceIndexed", "ifEmpty", "ifBlank",
) + FILLING_FUNCTIONS

/** The ones whose result is a String again. */
private val TEXT_RESULT_FUNCTIONS = setOf("filter", "filterNot", "takeWhile", "dropWhile", "takeLastWhile", "dropLastWhile")

/** The ones that exist for `Map` receivers. */
private val INLINED_MAP_FUNCTIONS = setOf(
    "map", "mapNotNull", "flatMap", "any", "all", "none", "count", "mapTo", "mapNotNullTo", "flatMapTo", "mapValuesTo", "mapKeysTo",
    "filterTo",
) + MAP_RESULT_FUNCTIONS +
    setOf("maxByOrNull", "minByOrNull", "maxBy", "minBy", "maxOf", "minOf", "maxOfOrNull", "minOfOrNull")

private const val COLLECTIONS_PACKAGE = "kotlin/collections/"
private const val TEXT_PACKAGE = "kotlin/text/"

/**
 * What a loop iterates: a list-like value (maps iterate their entries), and whether its elements may be nil. A [snapshot]
 * is walked as the lualib's methods walk it, see [snapshotLoop].
 */
internal class Source(
    val collection: LuaExpr,
    val kind: CollectionKind,
    val elementNullable: Boolean,
    val snapshot: Boolean = false,
    /** A plain 1-based table walked up to `#collection` (an enum's `____values`), for a [snapshot]. */
    val plainArray: Boolean = false,
)

/** The name of the function a library call is, when it is one of those expanded for its package. */
private fun expandedName(callableId: String?): String? {
    val (prefix, names) = when {
        callableId == null -> return null
        callableId.startsWith(TEXT_PACKAGE) -> TEXT_PACKAGE to INLINED_TEXT_FUNCTIONS
        callableId.startsWith(COLLECTIONS_PACKAGE) -> COLLECTIONS_PACKAGE to INLINED_COLLECTION_FUNCTIONS
        else -> return null
    }
    return callableId.substringAfter(prefix).takeIf { it in names }
}

/** What the loop walks: the chars of a String, or a collection the function exists for. */
private fun FileTransformer.sourceKind(name: String, inText: Boolean, type: KaType?): CollectionKind? = with(session) {
    when {
        !inText -> type?.collectionKind()?.takeIf { supports(name, it) }
        type != null && (type.isStringType || type.isCharSequenceType) -> CollectionKind.List
        else -> null
    }
}

/** Whether the call is expanded: always for the functions the lualib lacks, else when a lambda returns from the caller. */
private fun FileTransformer.needsExpansion(name: String, args: List<KtExpression?>): Boolean =
    name in EXPANDED_ALWAYS || args.mapNotNull(::lambdaLiteral).any { hasNonLocalJump(it) }

/** What the loop walks: a collection the function exists for (or the list of chars of a String) and the receiver's elements. */
private fun FileTransformer.loopSource(
    name: String,
    inText: Boolean,
    type: KaType?,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
): Source? = with(session) {
    val kind = sourceKind(name, inText, type) ?: return null
    val collection = cache(implicit ?: expression(receiverExpr ?: return null), "list")
    if (inText) {
        Source(cache(charList(collection), "chars"), kind, false)
    } else {
        Source(collection, kind, type?.elementType?.isMarkedNullable != false)
    }
}

internal fun FileTransformer.inlinedCollectionCall(
    callableId: String?,
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    full: KtExpression,
): LuaExpr? = with(session) {
    val name = expandedName(callableId) ?: return null
    if (call !is KaFunctionCall<*>) return null
    val args = callArguments(call)
    val type = receiverExpr?.expressionType ?: call.extensionReceiver?.type
    val inText = callableId!!.startsWith(TEXT_PACKAGE)
    if (!needsExpansion(name, args)) {
        if (inText) return null
        return loopedCollectionCall(name, args, type, full, receiverExpr) { implicit ?: receiverExpr?.let { expression(it) } }
    }
    expand(name, args, Triple(type, receiverExpr, implicit), inText, full)
}

/** The loop for call of [name] on a receiver given as its type, expression and implicit value. */
private fun FileTransformer.expand(
    name: String,
    args: List<KtExpression?>,
    receiver: Triple<KaType?, KtExpression?, LuaExpr?>,
    inText: Boolean,
    full: KtExpression,
): LuaExpr? = with(session) {
    val (type, receiverExpr, implicit) = receiver
    if (name in KEYED_FUNCTIONS) return keyedCall(name, type, args, implicit ?: receiverExpr?.let { expression(it) } ?: return null)
    val source = loopSource(name, inText, type, receiverExpr, implicit) ?: return null
    val lambda = (if (name == "zip") args.getOrNull(1) else args[0]) ?: return null
    val result = lowered(name, source, args, lambda, full)
    if (inText && name in TEXT_RESULT_FUNCTIONS) joinChars(result) else result
}

private fun FileTransformer.lowered(
    name: String,
    source: Source,
    args: List<KtExpression?>,
    lambda: KtExpression,
    full: KtExpression,
): LuaExpr = when (name) {
    in FILLING_FUNCTIONS -> filling(name, source, args)

    in ACCUMULATING_FUNCTIONS -> accumulating(name, source, args)

    in INDEXED_LISTING -> indexed(name, source, lambda)

    "firstNotNullOf", "firstNotNullOfOrNull" -> firstNotNull(name, source, lambda)

    "onEachIndexed" -> eachIndexed(source, lambda)

    in MAP_RESULT_FUNCTIONS -> if (source.kind == CollectionKind.Map) {
        mapResult(name, source, lambda)
    } else {
        listingOrEach(name, source, lambda)
    }

    in SELECTING_FUNCTIONS -> selecting(name, source, args, full)

    "map", "mapNotNull", "filter", "filterNot", "takeWhile", "flatMap" -> listing(name, source, lambda)

    "any", "all", "none", "count", "first", "firstOrNull", "find" -> searching(name, source, lambda)

    "sumOf", "sumBy", "sumByDouble" -> summing(source, lambda, full)

    "onEach" -> listingOrEach(name, source, lambda)

    "fold" -> folding(source, args)

    else -> grouping(name, source, args)
}

private fun supports(name: String, kind: CollectionKind) =
    if (kind == CollectionKind.Map) name in INLINED_MAP_FUNCTIONS else kind in ITERATED_KINDS

private fun FileTransformer.listingOrEach(name: String, source: Source, lambda: KtExpression): LuaExpr = when (name) {
    "onEach" -> {
        eachElement(source, lambda, 0) { item, _ -> inlineLambda(lambda, listOf(item), null, null) }
        source.collection
    }

    else -> listing(name, source, lambda)
}

internal fun lambdaLiteral(arg: KtExpression?): KtLambdaExpression? =
    arg?.let { KtPsiUtil.safeDeparenthesize(it).let { e -> (e as? KtLabeledExpression)?.baseExpression ?: e } } as? KtLambdaExpression

/**
 * Emits a loop over [source] whose body is what [step] emits for the element, named after parameter [paramIndex] of [lambda],
 * and for the 0-based index, named after parameter [indexParam] if there is one. A list or array is walked from the end
 * when [backwards] (for `last { }` and the like). [itemName] names the element variable when
 * the lambda's parameters are not the elements.
 */
internal fun FileTransformer.eachElement(
    source: Source,
    lambda: KtExpression,
    paramIndex: Int,
    indexParam: Int? = null,
    backwards: Boolean = false,
    itemName: String? = null,
    step: (LuaName, LuaName?) -> Unit,
): Unit = with(session) {
    val params = lambdaLiteral(lambda)?.functionLiteral?.valueParameters.orEmpty()
    val item = itemName ?: if (params.isEmpty()) "it" else forEachVar(params, paramIndex, "it")
    val element = LuaName(item).also { stable += it }
    val index = indexParam?.let { LuaName(forEachVar(params, it, "index")).also { n -> stable += n } }
    val body = collect { step(element, index) }
    if (snapshotOrEntriesLoop(source, item, index, body)) return
    val list = asList(source.kind, source.collection)
    val plain = index == null && !backwards && !implementsLists
    if (!source.elementNullable && plain) {
        emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), list)), body))
        return
    }
    val items = cache(list, "list")
    val i = ctx.temp("i")
    val element0 = LuaLocal(listOf(item), listOf(LuaIndex(items, LuaName(i))))
    val index0 = index?.let { LuaLocal(listOf(it.name), listOf(LuaBinary(LuaBinOp.Sub, LuaName(i), LuaNumber("1")))) }
    val header = listOfNotNull(element0, index0)
    val size = LuaIndex(items, LuaString("size"))
    emit(
        if (backwards) {
            LuaNumericFor(i, size, LuaNumber("1"), LuaNumber("-1"), header + body)
        } else {
            LuaNumericFor(i, LuaNumber("1"), size, null, header + body)
        },
    )
}

/** The loop over a [Source.snapshot] (see [snapshotLoop]) or a map's entries; false for other sources. */
private fun FileTransformer.snapshotOrEntriesLoop(source: Source, item: String, index: LuaName?, body: List<LuaStmt>): Boolean {
    when {
        source.snapshot -> snapshotLoop(source, item, index, body)

        source.kind == CollectionKind.Map -> {
            val entries = LuaMethodCall(source.collection, "____entryArray", emptyList())
            emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), entries)), body))
        }

        else -> return false
    }
    return true
}

internal fun FileTransformer.newList(): LuaExpr = LuaCall(lualibRef("Collections", "__K2L_ListOf"), emptyList())

internal fun FileTransformer.newMap(): LuaExpr = LuaCall(lualibRef("Collections", "__K2L_MapOf"), emptyList())

internal fun FileTransformer.declare(hint: String, value: LuaExpr? = null): LuaName {
    val name = ctx.temp(hint)
    emit(LuaLocal(listOf(name), listOfNotNull(value)))
    return LuaName(name).also { stable += it }
}

internal fun put(map: LuaExpr, key: LuaExpr, value: LuaExpr): LuaStmt = LuaCallStmt(LuaMethodCall(map, "put", listOf(key, value)))

internal fun add(list: LuaExpr, value: LuaExpr): LuaStmt = LuaCallStmt(LuaMethodCall(list, "add", listOf(value)))

/** `map`, `mapNotNull`, `filter`, `filterNot`, `takeWhile` and `flatMap` (of lists or sequences): a new list filled in one pass. */
internal fun FileTransformer.listing(name: String, source: Source, lambda: KtExpression, into: LuaExpr? = null): LuaExpr = with(session) {
    val flatKind = (lambdaLiteral(lambda)?.expressionType as? KaFunctionType)?.returnType?.collectionKind()
    if (name == "flatMap" && flatKind !in ITERATED_KINDS && flatKind != CollectionKind.Sequence) {
        return unsupported(lambda, "A non-local return in 'flatMap' returning '$flatKind'")
    }
    val result = into ?: declare("result", newList())
    eachElement(source, lambda, 0) { item, _ ->
        val value = inlineValue(lambda, listOf(item), null)
        when (name) {
            "map" -> emit(add(result, value))

            "mapNotNull" -> emit(LuaIf(LuaBinary(LuaBinOp.Ne, cache(value, "value"), LuaNil), listOf(add(result, value))))

            "filter" -> emit(LuaIf(value, listOf(add(result, item))))

            "filterNot" -> emit(LuaIf(negate(value), listOf(add(result, item))))

            "takeWhile" -> {
                emit(LuaIf(negate(value), listOf(LuaBreak)))
                emit(add(result, item))
            }

            else -> {
                val elements = if (flatKind == CollectionKind.Sequence) LuaMethodCall(value, "toList", emptyList()) else value
                emit(LuaCallStmt(LuaMethodCall(result, "addAll", listOf(elements))))
            }
        }
    }
    return result
}

/** `any`, `all`, `none`, `count`, `first`, `firstOrNull` and `find`: a loop that stops at the deciding element. */
internal fun FileTransformer.searching(name: String, source: Source, lambda: KtExpression): LuaExpr = with(session) {
    val initial = when (name) {
        "any" -> LuaBool(false)
        "all", "none" -> LuaBool(true)
        "count" -> LuaNumber("0")
        else -> null
    }
    val result = declare("result", initial)
    val found = if (name == "first") declare("found", LuaBool(false)) else null
    eachElement(source, lambda, 0) { item, _ ->
        val test = inlineValue(lambda, listOf(item), null)
        val stop = { value: Boolean -> listOf(assign(result.name, LuaBool(value)), LuaBreak) }
        emit(
            when (name) {
                "any" -> LuaIf(test, stop(true))
                "all" -> LuaIf(negate(test), stop(false))
                "none" -> LuaIf(test, stop(false))
                "count" -> LuaIf(test, listOf(assign(result.name, LuaBinary(LuaBinOp.Add, result, LuaNumber("1")))))
                else -> LuaIf(test, listOfNotNull(assign(result.name, item), found?.let { assign(it.name, LuaBool(true)) }, LuaBreak))
            },
        )
    }
    if (found != null) {
        val message = LuaString("Collection contains no element matching the predicate.")
        emit(LuaIf(negate(found), listOf(throwNew("__K2L_NoSuchElementException", message))))
    }
    return result
}

internal fun FileTransformer.summing(source: Source, lambda: KtExpression, full: KtExpression): LuaExpr = with(session) {
    val isDouble = full.expressionType?.let { it.isDoubleType || it.isFloatType } == true
    val result = declare("sum", LuaNumber(if (isDouble) "0.0" else "0"))
    eachElement(source, lambda, 0) { item, _ ->
        val term = inlineValue(lambda, listOf(item), null)
        emit(assign(result.name, LuaBinary(LuaBinOp.Add, result, term)))
    }
    return result
}

private fun FileTransformer.folding(source: Source, args: List<KtExpression?>): LuaExpr = with(session) {
    val lambda = args[1]!!
    val acc = declare("acc", arguments(emptyList(), listOf(args[0]))[0])
    // The accumulator is reassigned, so the lambda's parameter gets a copy rather than standing for it.
    val current = LuaName(acc.name)
    eachElement(source, lambda, 1) { item, _ -> emit(assign(acc.name, inlineValue(lambda, listOf(current, item), null))) }
    return acc
}

/** `associate`, `associateBy`, `associateWith` and `groupBy`: a map filled in one pass. */
internal fun FileTransformer.grouping(name: String, source: Source, args: List<KtExpression?>, into: LuaExpr? = null): LuaExpr =
    with(session) {
        val result = into ?: declare("result", newMap())
        val first = args[0]!!
        val second = args.getOrNull(1)
        eachElement(source, first, 0) { item, _ ->
            val value = cache(inlineValue(first, listOf(item), null), "value")
            val other = second?.let { cache(inlineValue(it, listOf(item), null), "value") }
            when (name) {
                "associate" -> emit(put(result, LuaIndex(value, LuaString("first")), LuaIndex(value, LuaString("second"))))

                "associateBy" -> emit(put(result, value, other ?: item))

                "associateWith" -> emit(put(result, item, value))

                else -> {
                    val group = declare("group", LuaMethodCall(result, "get", listOf(value)))
                    val create = listOf(assign(group.name, newList()), put(result, value, group))
                    emit(LuaIf(LuaBinary(LuaBinOp.Eq, group, LuaNil), create))
                    emit(add(group, other ?: item))
                }
            }
        }
        return result
    }
