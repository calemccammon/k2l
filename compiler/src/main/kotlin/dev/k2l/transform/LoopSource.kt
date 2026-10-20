package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Where a `for` loop finds the elements it walks: [items] (an array read `items[i]` for `i = 1, count`) of the
 * collection [owner], or of nothing that can change ([owner] null: arrays). [countArg] is passed on to the collection's
 * `____comodified` (the number of elements the loop started with), see `Collections.lua`.
 */
internal class LoopSource(
    val items: LuaExpr,
    val count: LuaExpr,
    val owner: LuaExpr?,
    val countArg: LuaExpr?,
    /** The values of a map's keys [items], for `for ((k, v) in map)`. */
    val values: LuaExpr? = null,
)

/**
 * The elements of a list (or array) [list]: itself, by index up to the size it has when the loop starts. [checked]
 * makes the loop notice structural changes of the list made by its body, as the JVM's iterator does.
 */
internal fun FileTransformer.listSource(list: LuaExpr, checked: Boolean): LoopSource {
    val items = cache(list, "list")
    return LoopSource(items, LuaIndex(items, LuaString("size")), if (checked) items else null, null)
}

/**
 * The elements of [collection], which may be a `java.util.ArrayDeque`: `local items, n = __K2L_LoopItems(c)`, which reads
 * a java.util.ArrayDeque through its iterator as the JVM's loop does (it fails on reaching the slot of an element removed
 * under it, not on any change, see `Deques.lua`), and other collections like [arraySource].
 */
internal fun FileTransformer.dequeSource(collection: LuaExpr): LoopSource {
    val owner = cache(collection, "collection")
    val items = ctx.temp("items")
    val count = ctx.temp("n")
    emit(LuaLocal(listOf(items, count), listOf(LuaCall(lualibRef("Collections", "__K2L_LoopItems"), listOf(owner)))))
    return LoopSource(LuaName(items), LuaName(count), owner, LuaName(count))
}

/** Whether a value of this type may be a `java.util.ArrayDeque`: one (or a subclass), a `Deque`, `Queue`, `Collection` or `Iterable`. */
context(s: KaSession)
internal fun KaType.mayBeJavaArrayDeque(): Boolean = with(s) {
    val type = withoutFlexibility
    type.expandedSymbol?.classId?.asString() in ARRAY_DEQUE_TYPES ||
        type.allSupertypes.any { it.expandedSymbol?.classId?.asString() == JAVA_ARRAY_DEQUE }
}

private const val JAVA_ARRAY_DEQUE = "java/util/ArrayDeque"
private val ARRAY_DEQUE_TYPES = setOf(
    JAVA_ARRAY_DEQUE,
    "java/util/Deque",
    "java/util/Queue",
    "java/util/AbstractCollection",
    "kotlin/collections/Collection",
    "kotlin/collections/MutableCollection",
    "kotlin/collections/Iterable",
    "kotlin/collections/MutableIterable",
)

/**
 * The elements of [collection] (a set, collection, iterable, or a map with [arrayMethod] `____keyArray`,
 * `____valueArray` or `____entryArray`): `local items, n = c:____array()`.
 */
internal fun FileTransformer.arraySource(collection: LuaExpr, arrayMethod: String = "____array", checked: Boolean = true): LoopSource {
    val owner = cache(collection, "collection")
    val items = ctx.temp("items")
    val count = ctx.temp("n")
    emit(LuaLocal(listOf(items, count), listOf(LuaMethodCall(owner, arrayMethod, emptyList()))))
    return LoopSource(LuaName(items), LuaName(count), if (checked) owner else null, LuaName(count))
}

/** The keys and values of [map] (`local keys, values, n = map:____arrays()`), for `for ((k, v) in map)`. */
internal fun FileTransformer.mapPairsSource(map: LuaExpr, checked: Boolean): LoopSource {
    val owner = cache(map, "map")
    val keys = ctx.temp("keys")
    val values = ctx.temp("values")
    val count = ctx.temp("n")
    emit(LuaLocal(listOf(keys, values, count), listOf(LuaMethodCall(owner, "____arrays", emptyList()))))
    return LoopSource(LuaName(keys), LuaName(count), if (checked) owner else null, LuaName(count), LuaName(values))
}

/**
 * `for i = 1, count do local variable = items[i] ... end` over [source] (`local k, v = keys[i], values[i]` with two
 * [variables] for a map's pairs), with `local index = i - 1` when [index] is
 * given. A checked source reads the collection's `____modCount` before the loop and after each pass of the body (after
 * `continue`, not after `break` or `return`); when it changed, the collection's `____comodified` throws
 * ConcurrentModificationException or ends the loop, as the JVM's iterator would on its next hasNext()/next().
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
    val check = source.owner?.let { owner ->
        val mod = ctx.temp("mod")
        emit(LuaLocal(listOf(mod), listOf(LuaIndex(owner, LuaString("____modCount")))))
        val changed = LuaBinary(LuaBinOp.Ne, LuaIndex(owner, LuaString("____modCount")), LuaName(mod))
        val decide = LuaMethodCall(owner, "____comodified", listOfNotNull(LuaName(i), source.countArg))
        LuaIf(LuaBinary(LuaBinOp.And, changed, decide), listOf(LuaBreak))
    }
    emit(LuaNumericFor(i, LuaNumber("1"), source.count, null, header + body + listOfNotNull(check)))
}

/**
 * Whether the loop [body] may change a collection: false only for bodies made of local variables, literals, string
 * templates and operators on numbers, booleans, chars and strings, and `print`/`println` of those (no other calls,
 * member reads or code of the program), whose loops need no ConcurrentModificationException check.
 */
internal fun FileTransformer.mayChangeCollections(body: KtExpression?): Boolean = with(session) {
    body != null && !inertTree(body)
}

/**
 * Whether [collection] is made by a call whose result nothing else can change (`listOf(...)`, `setOf(...)`, an enum's
 * `entries`): a loop over it needs no check.
 */
internal fun FileTransformer.isFreshReadOnly(collection: KtExpression): Boolean = with(session) {
    val e = KtPsiUtil.safeDeparenthesize(collection)
    if (e.expressionType?.expandedSymbol?.classId?.asString() == "kotlin/enums/EnumEntries") return true
    val call = (e as? KtCallExpression) ?: ((e as? KtDotQualifiedExpression)?.selectorExpression as? KtCallExpression) ?: return false
    val id = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol?.callableId?.asSingleFqName()?.asString()
    return id in FRESH_READ_ONLY
}

private val FRESH_READ_ONLY = setOf(
    "kotlin.collections.listOf",
    "kotlin.collections.setOf",
    "kotlin.collections.mapOf",
    "kotlin.collections.emptyList",
    "kotlin.collections.emptySet",
    "kotlin.collections.emptyMap",
    "kotlin.collections.listOfNotNull",
)

private enum class Inertness { Inert, InertLeaf, Changes }

/** Whether nothing in [root] runs code that could change a collection. */
private fun KaSession.inertTree(root: PsiElement): Boolean {
    var inert = true
    root.accept(object : KtTreeVisitorVoid() {
        override fun visitElement(element: PsiElement) {
            if (!inert || element is KtTypeReference) return
            when (inertness(element)) {
                Inertness.Changes -> inert = false
                Inertness.Inert -> super.visitElement(element)
                Inertness.InertLeaf -> Unit
            }
        }
    })
    return inert
}

private fun KaSession.inertness(element: PsiElement): Inertness = when (element) {
    is KtBlockExpression, is KtParenthesizedExpression, is KtConstantExpression, is KtIfExpression, is KtContainerNode,
    is KtOperationReferenceExpression, is KtBreakExpression, is KtContinueExpression, is KtLabelReferenceExpression,
    is KtContainerNodeForControlStructureBody, is KtLabeledExpression, is KtStringTemplateExpression,
    is KtLiteralStringTemplateEntry, is KtEscapeStringTemplateEntry,
    -> Inertness.Inert

    is KtStringTemplateEntryWithExpression -> inertIf(element.expression?.let { isPlainValue(it) } == true)

    is KtProperty -> inertIf(element.isLocal && !element.hasDelegate())

    is KtNameReferenceExpression -> element.mainReference.resolveToSymbol().let {
        val local = (it is KaLocalVariableSymbol || it is KaValueParameterSymbol) && (it.psi as? KtProperty)?.hasDelegate() != true
        inertIf(local || (it is KaPropertySymbol && isPlainProperty(it)))
    }

    // `p.x`: a plain property of an inert receiver
    is KtDotQualifiedExpression -> {
        val selector = element.selectorExpression as? KtNameReferenceExpression
        val symbol = selector?.mainReference?.resolveToSymbol() as? KaPropertySymbol
        if (symbol != null && isPlainProperty(symbol) && inertTree(element.receiverExpression)) Inertness.InertLeaf else Inertness.Changes
    }

    is KtBinaryExpression -> inertIf(listOfNotNull(element.left, element.right).all { isPlainValue(it) })

    is KtUnaryExpression -> inertIf(element.baseExpression?.let { isPlainValue(it) } == true)

    is KtCallExpression -> printing(element)

    is KtElement -> Inertness.Changes

    else -> Inertness.Inert // whitespace, comments and tokens
}

private fun inertIf(inert: Boolean) = if (inert) Inertness.Inert else Inertness.Changes

/** `println(x)` and `print(x)` of a plain value: only the arguments are looked into, the callee is the library's. */
private fun KaSession.printing(call: KtCallExpression): Inertness {
    val symbol = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol
    val id = symbol?.callableId?.asSingleFqName()?.asString()
    if (id != "kotlin.io.println" && id != "kotlin.io.print") return Inertness.Changes
    val args = call.valueArguments.mapNotNull { it.getArgumentExpression() }
    val inert = call.lambdaArguments.isEmpty() && args.all { isPlainValue(it) && inertTree(it) }
    return if (inert) Inertness.InertLeaf else Inertness.Changes
}

/**
 * A property read (or written) without running code: a final property of the program without a custom getter or setter
 * or delegate (a constructor `val`/`var` included), or a size, length or component of the library's.
 */
private fun isPlainProperty(symbol: KaPropertySymbol): Boolean = when (val psi = symbol.psi) {
    is KtParameter -> psi.hasValOrVar() && !psi.hasModifier(KtTokens.OPEN_KEYWORD)

    is KtProperty -> !psi.hasDelegate() && psi.getter?.hasBody() != true && psi.setter?.hasBody() != true &&
        !psi.hasModifier(KtTokens.OPEN_KEYWORD) && !psi.hasModifier(KtTokens.ABSTRACT_KEYWORD) &&
        (psi.containingClassOrObject as? KtClass)?.isInterface() != true

    null -> symbol.callableId?.toString().let { id ->
        id != null && (id in PLAIN_LIBRARY_PROPERTIES || (id.startsWith("kotlin/") && id.endsWith("Array.size")))
    }

    else -> false
}

private val PLAIN_LIBRARY_PROPERTIES = setOf(
    "kotlin/collections/List.size", "kotlin/collections/Collection.size", "kotlin/collections/Set.size",
    "kotlin/collections/Map.size", "kotlin/String.length", "kotlin/Pair.first", "kotlin/Pair.second", "kotlin/Triple.first",
    "kotlin/Triple.second", "kotlin/Triple.third", "kotlin/collections/Map.Entry.key", "kotlin/collections/Map.Entry.value",
    "kotlin/collections/IndexedValue.index", "kotlin/collections/IndexedValue.value", "kotlin/collections/lastIndex",
)

/** A number, boolean, char or string, whose operators and string conversion run no code of the program. */
private fun KaSession.isPlainValue(e: KtExpression): Boolean {
    val type = e.expressionType ?: return false
    return !type.isMarkedNullable &&
        (type.isStringType || type.isCharType || type.isBooleanType || type.isIntegral || type.isDoubleType || type.isFloatType)
}
