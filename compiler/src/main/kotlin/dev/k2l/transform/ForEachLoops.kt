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

        kind == CollectionKind.Map && params.size == 2 -> {
            val k = varName(0, "key")
            val v = varName(1, "value")
            emit(LuaGenericFor(listOf(k, v), listOf(LuaMethodCall(collection, "iter", emptyList())), body(k, v)))
        }

        kind == CollectionKind.Map -> {
            val entry = varName(0, "entry")
            val entries = LuaMethodCall(collection, "getEntries", emptyList())
            emit(LuaGenericFor(listOf("_", entry), listOf(luaCall(LuaName("ipairs"), entries)), body(entry)))
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
        emit(LuaGenericFor(listOf(c), listOf(stringChars(collection)), forEachBody(lambda, c)))
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

/** `forEach` over a list-like value, with an index when [indexed] (`forEachIndexed`). */
private fun FileTransformer.forEachList(
    collection: LuaExpr,
    type: KaType?,
    lambda: KtExpression,
    indexed: Boolean,
    params: List<KtParameter>,
): Unit = with(session) {
    val kind = type?.let { loopKind(it) }
    fun varName(i: Int, default: String) = forEachVar(params, i, default)
    fun body(vararg vars: String) = forEachBody(lambda, *vars)
    if (indexed) {
        val list = cache(asList(kind, collection), "list")
        val index = varName(0, "index")
        val value = varName(1, "value")
        val element = LuaLocal(listOf(value), listOf(CollectionMappings.index(list, LuaName(index))))
        val last = lastIndex(list)
        emit(LuaNumericFor(index, LuaNumber("0"), last, null, listOf(element) + body(index, value)))
        return
    }
    val list = asList(kind, collection)
    val item = varName(0, "it").let { if (params.isEmpty()) "it" else it }
    if (type?.elementType?.isMarkedNullable == false && !usesListViews) {
        emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), list)), body(item)))
    } else {
        val items = cache(list, "list")
        val i = ctx.temp("i")
        val element = LuaLocal(listOf(item), listOf(LuaIndex(items, LuaName(i))))
        emit(LuaNumericFor(i, LuaNumber("1"), LuaIndex(items, LuaString("size")), null, listOf(element) + body(item)))
    }
}
