package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/** `xs.forEach { ... }` as a loop with the lambda inlined, so `return` and `return@forEach` work. */
internal fun FileTransformer.forEachLoop(collection: LuaExpr, type: KaType?, lambda: KtExpression, indexed: Boolean): Unit = with(session) {
    val literal = (KtPsiUtil.safeDeparenthesize(lambda) as? KtLambdaExpression)?.functionLiteral
    val params = literal?.valueParameters.orEmpty()
    fun varName(i: Int, default: String) = forEachVar(params, i, default)
    fun body(vararg vars: String) = forEachBody(lambda, *vars)
    val kind = type?.collectionKind()
    when {
        kind == CollectionKind.LuaTable -> {
            val k = varName(0, "key")
            val v = varName(1, "value")
            emit(LuaGenericFor(listOf(k, v), listOf(luaCall(LuaName("pairs"), collection)), body(k, v)))
        }

        // Map.forEach(BiConsumer) runs over the whole map, then throws if the action changed it (`iter(true)`)
        kind == CollectionKind.Map && params.size == 2 -> {
            val k = varName(0, "key")
            val v = varName(1, "value")
            emit(LuaGenericFor(listOf(k, v), listOf(LuaMethodCall(collection, "iter", listOf(LuaBool(true)))), body(k, v)))
        }

        kind == CollectionKind.Map -> {
            val entry = varName(0, "entry")
            val source = arraySource(collection, "____entryArray", mayChangeCollections(lambdaBody(lambda)))
            elementsLoop(source, entry, null, body(entry))
        }

        (kind == CollectionKind.Sequence || kind == CollectionKind.Iterator) && !indexed -> {
            val item = if (params.isEmpty()) "it" else varName(0, "it")
            emit(LuaGenericFor(listOf("_", item), listOf(generator(kind, collection)), body(item)))
        }

        type?.isStringType == true -> forEachChar(collection, lambda, indexed, params)

        else -> forEachList(collection, type, lambda, indexed, params)
    }
}

/** `s.forEach { c -> }` and `s.forEachIndexed { i, c -> }`: over the chars of a String. */
private fun FileTransformer.forEachChar(collection: LuaExpr, lambda: KtExpression, indexed: Boolean, params: List<KtParameter>) {
    if (!indexed) {
        val c = forEachVar(params, 0, "char")
        eachChar(collection, c, forEachBody(lambda, c))
        return
    }
    val list = cache(charList(collection), "chars")
    val index = forEachVar(params, 0, "index")
    val value = forEachVar(params, 1, "value")
    val element = LuaLocal(listOf(value), listOf(CollectionMappings.index(list, LuaName(index))))
    emit(LuaNumericFor(index, LuaNumber("0"), lastIndex(list), null, listOf(element) + forEachBody(lambda, index, value)))
}

internal fun FileTransformer.forEachVar(params: List<KtParameter>, i: Int, default: String): String = with(session) {
    params.getOrNull(i)?.takeIf { it.destructuringDeclaration == null && it.name != null }?.let { naming.of(it) } ?: ctx.temp(default)
}

private fun FileTransformer.forEachBody(lambda: KtExpression, vararg vars: String) = collect {
    inlineLambda(lambda, vars.map { LuaName(it).also { v -> stable += v } }, null, null)
}

/**
 * `forEach` over a list-like value, with an index when [indexed] (`forEachIndexed`): Kotlin's forEach is a `for` loop
 * over the collection's iterator, so it is checked for changes of the collection like one (see [elementsLoop]).
 */
private fun FileTransformer.forEachList(
    collection: LuaExpr,
    type: KaType?,
    lambda: KtExpression,
    indexed: Boolean,
    params: List<KtParameter>,
): Unit = with(session) {
    val kind = type?.let { loopKind(it) }
    val checked = mayChangeCollections(lambdaBody(lambda))
    val source = when {
        kind == CollectionKind.Array -> listSource(collection, false)
        checked && type?.mayBeJavaArrayDeque() == true -> dequeSource(collection)
        kind?.isIndexable == true -> listSource(collection, checked)
        else -> arraySource(collection, checked = checked)
    }
    if (indexed) {
        val index = forEachVar(params, 0, "index")
        val value = forEachVar(params, 1, "value")
        elementsLoop(source, value, index, forEachBody(lambda, index, value))
        return
    }
    val item = forEachVar(params, 0, "it").let { if (params.isEmpty()) "it" else it }
    elementsLoop(source, item, null, forEachBody(lambda, item))
}

/** The body of a lambda literal (null for other function values, which may do anything). */
internal fun lambdaBody(lambda: KtExpression): KtExpression? =
    (KtPsiUtil.safeDeparenthesize(lambda) as? KtLambdaExpression)?.bodyExpression ?: lambda
