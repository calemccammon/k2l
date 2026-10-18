package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.*

/**
 * Collection functions whose lambda may `return` from the enclosing function (they are `inline` in Kotlin). A call to one of
 * these with such a lambda is lowered to a loop with the lambda inlined, like `forEach`; without one it is an ordinary
 * method call of the lualib (see CollectionMappings).
 */
private val INLINED_COLLECTION_FUNCTIONS = setOf(
    "map", "mapNotNull", "filter", "filterNot", "takeWhile", "flatMap", "any", "all", "none", "count", "first", "firstOrNull",
    "find", "sumOf", "onEach", "fold", "associate", "associateBy", "associateWith", "groupBy",
)

/** The ones that exist for `Map` receivers and produce a plain list or value (`Map.filter` would produce a map). */
private val INLINED_MAP_FUNCTIONS = setOf("map", "mapNotNull", "flatMap", "any", "all", "none", "count")

private const val COLLECTIONS_PACKAGE = "kotlin/collections/"

/** What a loop iterates: a list-like value (maps iterate their entries), and whether its elements may be nil. */
private class Source(val collection: LuaExpr, val kind: CollectionKind, val elementNullable: Boolean)

internal fun FileTransformer.inlinedCollectionCall(
    callableId: String?,
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    full: KtExpression,
): LuaExpr? = with(session) {
    if (callableId == null || call !is KaFunctionCall<*> || !callableId.startsWith(COLLECTIONS_PACKAGE)) return null
    val name = callableId.removePrefix(COLLECTIONS_PACKAGE).takeIf { it in INLINED_COLLECTION_FUNCTIONS } ?: return null
    val args = callArguments(call)
    if (args.mapNotNull(::lambdaLiteral).none { hasNonLocalReturn(it) }) return null
    val type = receiverExpr?.expressionType ?: call.extensionReceiver?.type
    val kind = type?.collectionKind()?.takeIf { supports(name, it) } ?: return null
    val collection = cache(implicit ?: expression(receiverExpr ?: return null), "list")
    val source = Source(collection, kind, type.elementType?.isMarkedNullable != false)
    val lambda = args[0] ?: return null
    return when (name) {
        "map", "mapNotNull", "filter", "filterNot", "takeWhile", "flatMap" -> listing(name, source, lambda)

        "any", "all", "none", "count", "first", "firstOrNull", "find" -> searching(name, source, lambda)

        "sumOf" -> summing(source, lambda, full)

        "onEach" -> {
            eachElement(source, lambda, 0) { inlineLambda(lambda, listOf(it), null, null) }
            collection
        }

        "fold" -> folding(source, args)

        else -> grouping(name, source, args)
    }
}

private fun supports(name: String, kind: CollectionKind) =
    if (kind == CollectionKind.Map) name in INLINED_MAP_FUNCTIONS else kind in ITERATED_KINDS

private fun lambdaLiteral(arg: KtExpression?): KtLambdaExpression? =
    arg?.let { KtPsiUtil.safeDeparenthesize(it).let { e -> (e as? KtLabeledExpression)?.baseExpression ?: e } } as? KtLambdaExpression

/** Emits a loop over [source] whose body is what [step] emits for the element, named after parameter [paramIndex] of [lambda]. */
private fun FileTransformer.eachElement(source: Source, lambda: KtExpression, paramIndex: Int, step: (LuaName) -> Unit): Unit =
    with(session) {
        val params = lambdaLiteral(lambda)?.functionLiteral?.valueParameters.orEmpty()
        val item = if (params.isEmpty()) "it" else forEachVar(params, paramIndex, "it")
        val element = LuaName(item).also { stable += it }
        val body = collect { step(element) }
        if (source.kind == CollectionKind.Map) {
            val entries = LuaMethodCall(source.collection, "getEntries", emptyList())
            emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), entries)), body))
            return
        }
        val list = asList(source.kind, source.collection)
        if (!source.elementNullable) {
            emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), list)), body))
            return
        }
        val items = cache(list, "list")
        val i = ctx.temp("i")
        val element0 = LuaLocal(listOf(item), listOf(LuaIndex(items, LuaName(i))))
        emit(LuaNumericFor(i, LuaNumber("1"), LuaIndex(items, LuaString("size")), null, listOf(element0) + body))
    }

private fun FileTransformer.newList(): LuaExpr = LuaCall(lualibRef("Collections", "__K2L_ListOf"), emptyList())

private fun FileTransformer.newMap(): LuaExpr = LuaCall(lualibRef("Collections", "__K2L_MapOf"), emptyList())

private fun FileTransformer.declare(hint: String, value: LuaExpr? = null): LuaName {
    val name = ctx.temp(hint)
    emit(LuaLocal(listOf(name), listOfNotNull(value)))
    return LuaName(name).also { stable += it }
}

private fun put(map: LuaExpr, key: LuaExpr, value: LuaExpr): LuaStmt = LuaCallStmt(LuaMethodCall(map, "put", listOf(key, value)))

private fun add(list: LuaExpr, value: LuaExpr): LuaStmt = LuaCallStmt(LuaMethodCall(list, "add", listOf(value)))

/** `map`, `mapNotNull`, `filter`, `filterNot`, `takeWhile` and `flatMap`: a new list filled in one pass. */
private fun FileTransformer.listing(name: String, source: Source, lambda: KtExpression): LuaExpr = with(session) {
    val flatKind = (lambdaLiteral(lambda)?.expressionType as? KaFunctionType)?.returnType?.collectionKind()
    if (name == "flatMap" &&
        flatKind !in ITERATED_KINDS
    ) {
        return unsupported(lambda, "A non-local return in 'flatMap' returning '$flatKind'")
    }
    val result = declare("result", newList())
    eachElement(source, lambda, 0) { item ->
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

            else -> emit(LuaCallStmt(LuaMethodCall(result, "addAll", listOf(value))))
        }
    }
    return result
}

/** `any`, `all`, `none`, `count`, `first`, `firstOrNull` and `find`: a loop that stops at the deciding element. */
private fun FileTransformer.searching(name: String, source: Source, lambda: KtExpression): LuaExpr = with(session) {
    val initial = when (name) {
        "any" -> LuaBool(false)
        "all", "none" -> LuaBool(true)
        "count" -> LuaNumber("0")
        else -> null
    }
    val result = declare("result", initial)
    val found = if (name == "first") declare("found", LuaBool(false)) else null
    eachElement(source, lambda, 0) { item ->
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

private fun FileTransformer.summing(source: Source, lambda: KtExpression, full: KtExpression): LuaExpr = with(session) {
    val isDouble = full.expressionType?.let { it.isDoubleType || it.isFloatType } == true
    val result = declare("sum", LuaNumber(if (isDouble) "0.0" else "0"))
    eachElement(source, lambda, 0) { item ->
        emit(assign(result.name, LuaBinary(LuaBinOp.Add, result, inlineValue(lambda, listOf(item), null))))
    }
    return result
}

private fun FileTransformer.folding(source: Source, args: List<KtExpression?>): LuaExpr = with(session) {
    val lambda = args[1]!!
    val acc = declare("acc", arguments(emptyList(), listOf(args[0]))[0])
    // The accumulator is reassigned, so the lambda's parameter gets a copy rather than standing for it.
    val current = LuaName(acc.name)
    eachElement(source, lambda, 1) { item -> emit(assign(acc.name, inlineValue(lambda, listOf(current, item), null))) }
    return acc
}

/** `associate`, `associateBy`, `associateWith` and `groupBy`: a map filled in one pass. */
private fun FileTransformer.grouping(name: String, source: Source, args: List<KtExpression?>): LuaExpr = with(session) {
    val result = declare("result", newMap())
    val first = args[0]!!
    val second = args.getOrNull(1)
    eachElement(source, first, 0) { item ->
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
