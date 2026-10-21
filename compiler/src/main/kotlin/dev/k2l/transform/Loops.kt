package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * A labeled statement: a loop that `break@label` and `continue@label` can name. Elsewhere a label only matters to
 * `return@label` in a lambda, see [lambdaLabels], so the expression is an ordinary statement.
 */
internal fun FileTransformer.labeled(e: KtLabeledExpression): Unit = with(session) {
    when (val base = e.baseExpression) {
        null -> Unit
        is KtLoopExpression -> loop(base, e.getLabelName())
        else -> statement(base)
    }
}

internal fun FileTransformer.loop(e: KtLoopExpression, label: String?): Unit = with(session) {
    val frame = LoopFrame(label)
    // On Lua 5.1 a break@thisLoop from an inner loop sets a flag declared before this loop.
    val flagAt = buffer.size
    when (e) {
        is KtWhileExpression -> {
            val (cond, pre) = withPreceding { expression(e.condition ?: return) }
            val body = loopBody(frame, e.body)
            if (pre.isEmpty()) {
                emit(LuaWhile(cond, body))
            } else {
                emit(LuaWhile(LuaBool(true), pre + LuaIf(negate(cond), listOf(LuaBreak)) + body))
            }
        }

        is KtDoWhileExpression -> {
            val body = loopBody(frame, e.body)
            val (cond, pre) = withPreceding { expression(e.condition ?: return) }
            emit(LuaRepeat(body + pre, negate(cond)))
        }

        is KtForExpression -> forLoop(e, frame)

        else -> unsupported(e, "Loop")
    }
    frame.breakFlag?.let { buffer.add(flagAt, LuaLocal(listOf(it), listOf(LuaBool(false)))) }
    frame.breakLabel?.let { emit(LuaLabel(it)) }
    emitAll(frame.checksAfter)
}

internal fun FileTransformer.loopBody(frame: LoopFrame, body: KtExpression?): List<LuaStmt> = with(session) {
    frame.owner = jumps.frames.lastOrNull()
    jumps.loops.addLast(frame)
    val collected = try {
        collect { body?.let { block(it) } }
    } finally {
        jumps.loops.removeLast()
    }
    val stmts = ownExits(frame, collected)
    val cont = frame.continueLabel ?: return stmts
    // The label sits outside a do-block so `goto` never jumps into the scope of a body local.
    if (target.hasGoto) return listOf(LuaDo(stmts), LuaLabel(cont))
    // Lua 5.1 has no goto: `continue` breaks out of a one-iteration repeat, and a real break sets a flag.
    val broke = ctx.temp("broke")
    var usesBreak = false
    val rewritten = stmts.flatMapStatements { s, depth ->
        when (s) {
            is LuaGoto -> if (s.label == cont && depth == 0) {
                listOf(LuaBreak)
            } else if (s.label in jumps.jumpLabels && s.label != cont) {
                listOf(s) // an enclosing loop's or inlined body's, lowered there
            } else {
                ctx.error(body ?: file, "continue to an outer loop needs goto, which Lua 5.1 lacks")
                listOf(s)
            }

            LuaBreak -> if (depth == 0) {
                usesBreak = true
                listOf(assign(broke, LuaBool(true)), LuaBreak)
            } else {
                listOf(s)
            }

            else -> listOf(s)
        }
    }
    val resetContinue = frame.continueFlag?.let { listOf(LuaLocal(listOf(it), listOf(LuaBool(false)))) }.orEmpty()
    val body = LuaRepeat(resetContinue + rewritten, LuaBool(true))
    if (!usesBreak) return listOf(body)
    return listOf(LuaLocal(listOf(broke), listOf(LuaBool(false))), body, LuaIf(LuaName(broke), listOf(LuaBreak)))
}

private fun FileTransformer.forLoop(e: KtForExpression, frame: LoopFrame): Unit = with(session) {
    val rangeExpr = e.loopRange ?: return
    val param = e.loopParameter ?: return
    val range = parseRange(rangeExpr)
    if (range != null) rangeLoop(e, frame, rangeExpr, param, range) else iterationLoop(e, frame, rangeExpr, param)
}

/** `for (i in a..b)`, `until`, `downTo` and `step` become a numeric `for`. */
private fun FileTransformer.rangeLoop(
    e: KtForExpression,
    frame: LoopFrame,
    rangeExpr: KtExpression,
    param: KtParameter,
    range: KRange,
): Unit = with(session) {
    val elementType = range.first.expressionType
    val isChar = elementType?.isCharType == true
    val rangeable = elementType != null && (elementType.isIntegral || isChar)
    if (param.destructuringDeclaration != null || !rangeable) {
        unsupported(rangeExpr, "Iterating over '${rangeExpr.expressionType.pretty()}'")
        return
    }
    val wide = if (emulatesLong) wideRangeType(range) else null
    if (wide != null) {
        long64RangeLoop(e, frame, param, range, wide)
        return
    }
    val values = ordered(listOfNotNull(range.first, range.last, range.step))
        .mapIndexed { i, value -> if (isChar && i < 2) charCode(value) else value } // a Char range's step is an Int
    val limit = if (range.inclusive) values[1] else plusConstant(values[1], -1)
    val step = loopStep(range, values.getOrNull(2))
    if (isChar) {
        // Chars are one-character strings: loop over their codes.
        val code = ctx.temp("code")
        val local = LuaLocal(listOf(naming.of(param)), listOf(charFromCode(LuaName(code))))
        emit(LuaNumericFor(code, values[0], limit, step, listOf(local) + loopBody(frame, e.body)))
    } else {
        emit(LuaNumericFor(naming.of(param), values[0], limit, step, loopBody(frame, e.body)))
    }
}

/** The step of the numeric `for` over [range]: its checked `step` [value] (negated for `downTo`), or null for 1. */
private fun FileTransformer.loopStep(range: KRange, value: LuaExpr?): LuaExpr? = when {
    range.step != null && value != null -> checkedStep(range.step, value).let { if (range.descending) LuaUnary(LuaUnOp.Neg, it) else it }
    range.descending -> LuaNumber("-1")
    else -> null
}

/** Loops over collections, maps, ranges held in values, and strings. */
private fun FileTransformer.iterationLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit =
    with(session) {
        val destructuring = param.destructuringDeclaration
        val type = rangeExpr.expressionType
        val qualified = KtPsiUtil.safeDeparenthesize(rangeExpr) as? KtDotQualifiedExpression
        val selector = qualified?.selectorExpression
        val noArgCallee = (selector as? KtCallExpression)?.takeIf { it.valueArguments.isEmpty() }?.calleeExpression
        val selectorName = ((selector as? KtNameReferenceExpression) ?: (noArgCallee as? KtNameReferenceExpression))?.getReferencedName()
        val receiverKind = qualified?.receiverExpression?.expressionType?.collectionKind()
        val indexable = receiverKind?.isIndexable == true
        val kind = type?.let { loopKind(it) }
        when {
            selectorName == "indices" && indexable && destructuring == null ->
                indicesLoop(e, frame, param, qualified.receiverExpression)

            selectorName == "withIndex" && indexable && destructuring?.entries?.size == 2 ->
                withIndexLoop(e, frame, destructuring, qualified.receiverExpression)

            kind == CollectionKind.Map -> mapLoop(e, frame, rangeExpr, param)

            kind == CollectionKind.Range && destructuring == null -> rangeObjectLoop(e, frame, rangeExpr, param)

            kind == CollectionKind.Sequence || kind == CollectionKind.Iterator -> sequenceLoop(e, frame, rangeExpr, param, kind)

            kind != null && kind in ITERATED_KINDS -> collectionLoop(e, frame, rangeExpr, param, kind)

            destructuring == null && isTextLoop(type, kind) -> textLoop(e, frame, rangeExpr, param)

            else -> unsupported(rangeExpr, "Iterating over '${type.pretty()}'")
        }
    }

private fun FileTransformer.isTextLoop(type: KaType?, kind: CollectionKind?): Boolean = with(session) {
    type?.isStringType == true || kind == CollectionKind.StringBuilder || isCharSequenceObject(type)
}

/** `for (c in s)` over a string, or over a value that may be another `CharSequence` (see [charSequenceLoop]). */
private fun FileTransformer.textLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit =
    with(session) {
        val text = expression(rangeExpr)
        if (rangeExpr.expressionType?.isStringType == true) {
            if (byteLoop(text, param, e.body) { loopBody(frame, e.body) }) return
            eachChar(text, naming.of(param), loopBody(frame, e.body))
        } else {
            charSequenceLoop(text, naming.of(param), loopBody(frame, e.body))
        }
    }

/** `for (i in range)` over a range held in a value: a numeric `for` over its `first`, `last` and `step`. */
private fun FileTransformer.rangeObjectLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit =
    with(session) {
        if (emulatesLong && isWideRange(rangeExpr.expressionType)) {
            long64RangeObjectLoop(e, frame, param, expression(rangeExpr))
            return
        }
        val r = cache(expression(rangeExpr), "range")
        emit(
            LuaNumericFor(
                naming.of(param),
                LuaIndex(r, LuaString("first")),
                LuaIndex(r, LuaString("last")),
                LuaIndex(r, LuaString("step")),
                loopBody(frame, e.body),
            ),
        )
    }

/** `for (i in xs.indices)` */
private fun FileTransformer.indicesLoop(e: KtForExpression, frame: LoopFrame, param: KtParameter, receiver: KtExpression): Unit =
    with(session) {
        val list = expression(receiver)
        val last = lastIndex(list)
        emit(LuaNumericFor(naming.of(param), LuaNumber("0"), last, null, loopBody(frame, e.body)))
    }

/** `for ((i, x) in xs.withIndex())` */
private fun FileTransformer.withIndexLoop(
    e: KtForExpression,
    frame: LoopFrame,
    destructuring: KtDestructuringDeclaration,
    receiver: KtExpression,
): Unit = with(session) {
    val list = cache(expression(receiver), "list")
    val (indexEntry, valueEntry) = destructuring.entries
    val index = if (indexEntry.name == "_") ctx.temp("i") else naming.of(indexEntry)
    val value = LuaLocal(listOf(naming.of(valueEntry)), listOf(CollectionMappings.index(list, LuaName(index))))
    val last = lastIndex(list)
    emit(LuaNumericFor(index, LuaNumber("0"), last, null, listOf(value) + loopBody(frame, e.body)))
}

/**
 * `for ((k, v) in map)` walks the map's keys and values arrays, `for (e in map)` its entries array, checked like
 * [collectionLoop].
 */
private fun FileTransformer.mapLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit =
    with(session) {
        val destructuring = param.destructuringDeclaration
        val map = expression(rangeExpr)
        if (destructuring != null && destructuring.entries.size == 2) {
            val names = destructuring.entries.map { naming.entry(it) }
            elementsLoop(mapPairsSource(map, loopChecked(e, rangeExpr)), names, null, loopBody(frame, e.body))
        } else {
            val source = arraySource(map, "____entryArray", loopChecked(e, rangeExpr))
            val variable = if (destructuring != null) ctx.temp("item") else naming.of(param)
            val prologue = destructuring?.let { listOf(destructure(it.entries, LuaName(variable).also { v -> stable += v })) }.orEmpty()
            elementsLoop(source, variable, null, prologue + loopBody(frame, e.body))
        }
    }

/**
 * `for (x in xs)` over a list or array: by index up to its size at the start; over other collections: their elements'
 * array (`____array()`, a map's `keys`, `values` and `entries` read from the map). Unless the body cannot change a
 * collection, the loop checks the collection's `____modCount` after each pass, see [elementsLoop] (arrays never change
 * size).
 */
private fun FileTransformer.collectionLoop(
    e: KtForExpression,
    frame: LoopFrame,
    rangeExpr: KtExpression,
    param: KtParameter,
    kind: CollectionKind,
): Unit = with(session) {
    val destructuring = param.destructuringDeclaration
    val checked = loopChecked(e, rangeExpr)
    val source = mapViewSource(rangeExpr, checked) ?: enumEntriesSource(rangeExpr) ?: run {
        val collection = expression(rangeExpr)
        when {
            kind == CollectionKind.Array -> listSource(collection, false)
            checked && rangeExpr.expressionType?.mayBeJavaArrayDeque() == true -> dequeSource(collection)
            kind.isIndexable -> listSource(collection, checked)
            else -> arraySource(collection, checked = checked)
        }
    }
    val variable = if (destructuring != null) ctx.temp("item") else naming.of(param)
    val prologue = destructuring?.let { listOf(destructure(it.entries, LuaName(variable).also { v -> stable += v })) }
        ?: uncheckedElementCheck(rangeExpr, param, variable)
    elementsLoop(source, variable, null, prologue + loopBody(frame, e.body))
}

/** `map.keys`, `map.values` or `map.entries` of a library map: the map's arrays, without making the view. */
internal fun FileTransformer.mapViewSource(rangeExpr: KtExpression, checked: Boolean): LoopSource? = with(session) {
    val qualified = KtPsiUtil.safeDeparenthesize(rangeExpr) as? KtDotQualifiedExpression ?: return null
    val name = (qualified.selectorExpression as? KtNameReferenceExpression)?.getReferencedName() ?: return null
    val method = MAP_VIEW_ARRAYS[name] ?: return null
    val receiverType = qualified.receiverExpression.expressionType ?: return null
    if (receiverType.collectionKind() != CollectionKind.Map || receiverType.isMarkedNullable) return null
    // a class of the program may override the view (or its iterator)
    val psi = receiverType.expandedSymbol?.psi as? KtClassOrObject
    if (psi != null && classes.isSource(psi)) return null
    val call = qualified.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    if (call.partiallyAppliedSymbol.symbol.callableId?.callableName?.asString() != name) return null
    return arraySource(expression(qualified.receiverExpression), method, checked)
}

private val MAP_VIEW_ARRAYS = mapOf("keys" to "____keyArray", "values" to "____valueArray", "entries" to "____entryArray")

/** `for (x in sequence)` and `for (x in iterator)`: a generic `for` over the lazy generator, see `Sequence.lua`. */
private fun FileTransformer.sequenceLoop(
    e: KtForExpression,
    frame: LoopFrame,
    rangeExpr: KtExpression,
    param: KtParameter,
    kind: CollectionKind,
): Unit = with(session) {
    val destructuring = param.destructuringDeclaration
    val source = expression(rangeExpr)
    val variable = if (destructuring != null) ctx.temp("item") else naming.of(param)
    val prologue = destructuring?.let { listOf(destructure(it.entries, LuaName(variable).also { v -> stable += v })) }.orEmpty()
    emit(LuaGenericFor(listOf("_", variable), listOf(generator(kind, source)), prologue + loopBody(frame, e.body)))
}

/** A Lua generator (`true, element` per call) for a sequence, or for any iterator via its hasNext()/next(). */
internal fun FileTransformer.generator(kind: CollectionKind, source: LuaExpr): LuaExpr = if (kind == CollectionKind.Sequence) {
    LuaMethodCall(source, "iter", emptyList())
} else {
    libCall(SEQUENCE_FEATURE, "__K2L_Iterator", "iter", listOf(source))
}

/** `local a, b = <component1>, <component2>`; `_` entries are skipped. */
internal fun FileTransformer.destructure(entries: List<KtDestructuringDeclarationEntry>, value: LuaExpr): LuaStmt = with(session) {
    val names = mutableListOf<String>()
    val values = mutableListOf<LuaExpr>()
    entries.forEachIndexed { i, entry ->
        if (entry.name == "_") return@forEachIndexed
        names += naming.of(entry)
        values += component(entry, value, i + 1)
    }
    return LuaLocal(names, values)
}

internal fun FileTransformer.component(entry: KtDestructuringDeclarationEntry, value: LuaExpr, n: Int): LuaExpr = with(session) {
    val call = entry.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
        ?: return unsupported(entry, "This destructuring")
    val symbol = call.partiallyAppliedSymbol.symbol
    val psi = symbol.psi
    if (psi is KtNamedFunction && classes.isSource(psi)) return LuaMethodCall(value, naming.function(psi), emptyList())
    val cls = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass
    if (cls != null && cls.isData()) return propertyRead(value, cls.primaryConstructorParameters[n - 1])
    val receiverType = (call.partiallyAppliedSymbol.extensionReceiver ?: call.partiallyAppliedSymbol.dispatchReceiver)?.type
    if (receiverType?.expandedSymbol?.classId?.asString() == "kotlin/time/TimedValue") {
        return LuaIndex(value, LuaString(if (n == 1) "value" else "duration"))
    }
    return when (receiverType?.collectionKind()) {
        CollectionKind.Pair, CollectionKind.Triple -> LuaIndex(value, LuaString(listOf("first", "second", "third")[n - 1]))
        CollectionKind.Entry -> LuaIndex(value, LuaString(if (n == 1) "key" else "value"))
        CollectionKind.IndexedValue -> LuaIndex(value, LuaString(if (n == 1) "index" else "value"))
        CollectionKind.List, CollectionKind.Array -> LuaIndex(value, LuaNumber(n.toString()))
        else -> unsupported(entry, "Destructuring '${receiverType.pretty()}'")
    }
}

/**
 * The collection kind a loop over a value of [type] walks: a class of the program implementing `List` itself (or by
 * delegation), or extending a library list and overriding iterator(), is walked with its iterator(), as on the JVM,
 * rather than read by index.
 */
internal fun FileTransformer.loopKind(type: KaType): CollectionKind? = with(session) {
    val kind = type.collectionKind()
    val psi = type.expandedSymbol?.psi as? KtClassOrObject
    val implementsList = psi != null && classes.isSource(psi) && (classes.collectionBaseOf(psi) == "__K2L_ListBase" || iteratesItself(psi))
    if (kind == CollectionKind.List && implementsList) CollectionKind.Iterable else kind
}

/** [collection] itself when it is already a `List`/`Array`, else a list copy of it. */
internal fun FileTransformer.asList(kind: CollectionKind?, collection: LuaExpr): LuaExpr =
    if (kind?.isIndexable == true) collection else LuaMethodCall(collection, "toList", emptyList())

/** Whether the loop [e] over [rangeExpr] checks for changes of the collection (see [elementsLoop]). */
private fun FileTransformer.loopChecked(e: KtForExpression, rangeExpr: KtExpression): Boolean =
    mayChangeCollections(e.body) && !isFreshReadOnly(rangeExpr)
