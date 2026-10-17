package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

internal fun FileTransformer.labeled(e: KtLabeledExpression): Unit = with(session) {
    val base = e.baseExpression
    if (base is KtLoopExpression) loop(base, e.getLabelName())
    else unsupported(e, "Labeled expression")
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

private fun FileTransformer.loopBody(frame: LoopFrame, body: KtExpression?): List<LuaStmt> = with(session) {
    loops.addLast(frame)
    val stmts = try {
        collect { body?.let { block(it) } }
    } finally {
        loops.removeLast()
    }
    val cont = frame.continueLabel ?: return stmts
    // The label sits outside a do-block so `goto` never jumps into the scope of a body local.
    if (target.hasGoto) return listOf(LuaDo(stmts), LuaLabel(cont))
    // Lua 5.1 has no goto: `continue` breaks out of a one-iteration repeat, and a real break sets a flag.
    val broke = ctx.temp("broke")
    var usesBreak = false
    val rewritten = stmts.flatMapStatements { s, depth ->
        when (s) {
            is LuaGoto -> if (s.label == cont && depth == 0) listOf(LuaBreak) else {
                ctx.error(file, "continue to an outer loop needs goto, which Lua 5.1 lacks")
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
private fun FileTransformer.rangeLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter, range: KRange): Unit = with(session) {
    val elementType = range.first.expressionType
    val isChar = elementType?.isCharType == true
    if (param.destructuringDeclaration != null || elementType == null || !(elementType.isIntegral || isChar)) {
        unsupported(rangeExpr, "Iterating over '${rangeExpr.expressionType.pretty()}'")
        return
    }
    val values = ordered(listOfNotNull(range.first, range.last, range.step))
        .map { if (isChar) LuaMethodCall(it, "byte", emptyList()) else it }
    val limit = if (range.inclusive) values[1] else plusConstant(values[1], -1)
    val step = when {
        range.step != null -> if (range.descending) LuaUnary(LuaUnOp.Neg, values[2]) else values[2]
        range.descending -> LuaNumber("-1")
        else -> null
    }
    if (isChar) {
        // Chars are one-character strings: loop over their codes.
        val code = ctx.temp("code")
        val local = LuaLocal(listOf(naming.of(param)), listOf(luaCall(luaPath("string", "char"), LuaName(code))))
        emit(LuaNumericFor(code, values[0], limit, step, listOf(local) + loopBody(frame, e.body)))
    } else {
        emit(LuaNumericFor(naming.of(param), values[0], limit, step, loopBody(frame, e.body)))
    }
}

/** Loops over collections, maps, ranges held in values, and strings. */
private fun FileTransformer.iterationLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit = with(session) {
    val destructuring = param.destructuringDeclaration
    val type = rangeExpr.expressionType
    val qualified = KtPsiUtil.safeDeparenthesize(rangeExpr) as? KtDotQualifiedExpression
    val selector = qualified?.selectorExpression
    val selectorName = (selector as? KtNameReferenceExpression)?.getReferencedName()
        ?: ((selector as? KtCallExpression)?.takeIf { it.valueArguments.isEmpty() }?.calleeExpression as? KtNameReferenceExpression)?.getReferencedName()
    val receiverKind = qualified?.receiverExpression?.expressionType?.collectionKind()
    val indexable = receiverKind?.isIndexable == true
    val kind = type?.collectionKind()
    when {
        selectorName == "indices" && indexable && destructuring == null ->
            indicesLoop(e, frame, param, qualified.receiverExpression)
        selectorName == "withIndex" && indexable && destructuring?.entries?.size == 2 ->
            withIndexLoop(e, frame, destructuring, qualified.receiverExpression)
        kind == CollectionKind.Map -> mapLoop(e, frame, rangeExpr, param)
        kind == CollectionKind.Range && destructuring == null -> {
            val r = cache(expression(rangeExpr), "range")
            emit(
                LuaNumericFor(
                    naming.of(param), LuaIndex(r, LuaString("first")), LuaIndex(r, LuaString("last")),
                    LuaIndex(r, LuaString("step")), loopBody(frame, e.body),
                ),
            )
        }
        kind != null && kind in ITERATED_KINDS -> collectionLoop(e, frame, rangeExpr, param, kind)
        type?.isStringType == true && destructuring == null -> {
            val text = expression(rangeExpr)
            emit(LuaGenericFor(listOf(naming.of(param)), listOf(LuaMethodCall(text, "gmatch", listOf(LuaString(".")))), loopBody(frame, e.body)))
        }
        else -> unsupported(rangeExpr, "Iterating over '${type.pretty()}'")
    }
}

/** `for (i in xs.indices)` */
private fun FileTransformer.indicesLoop(e: KtForExpression, frame: LoopFrame, param: KtParameter, receiver: KtExpression): Unit = with(session) {
    val list = expression(receiver)
    val last = lastIndex(list)
    emit(LuaNumericFor(naming.of(param), LuaNumber("0"), last, null, loopBody(frame, e.body)))
}

/** `for ((i, x) in xs.withIndex())` */
private fun FileTransformer.withIndexLoop(e: KtForExpression, frame: LoopFrame, destructuring: KtDestructuringDeclaration, receiver: KtExpression): Unit = with(session) {
    val list = cache(expression(receiver), "list")
    val (indexEntry, valueEntry) = destructuring.entries
    val index = if (indexEntry.name == "_") ctx.temp("i") else naming.of(indexEntry)
    val value = LuaLocal(listOf(naming.of(valueEntry)), listOf(CollectionMappings.index(list, LuaName(index))))
    val last = lastIndex(list)
    emit(LuaNumericFor(index, LuaNumber("0"), last, null, listOf(value) + loopBody(frame, e.body)))
}

private fun FileTransformer.mapLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter): Unit = with(session) {
    val destructuring = param.destructuringDeclaration
    val map = expression(rangeExpr)
    if (destructuring != null && destructuring.entries.size == 2) {
        val names = destructuring.entries.map { naming.entry(it) }
        emit(LuaGenericFor(names, listOf(LuaMethodCall(map, "iter", emptyList())), loopBody(frame, e.body)))
    } else {
        val entries = LuaMethodCall(map, "getEntries", emptyList())
        emit(LuaGenericFor(listOf("_", naming.of(param)), listOf(luaCall(LuaName("ipairs"), entries)), loopBody(frame, e.body)))
    }
}

private fun FileTransformer.collectionLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter, kind: CollectionKind): Unit = with(session) {
    val destructuring = param.destructuringDeclaration
    val collection = expression(rangeExpr)
    val list = asList(kind, collection)
    val variable = if (destructuring != null) ctx.temp("item") else naming.of(param)
    val prologue = destructuring?.let { listOf(destructure(it.entries, LuaName(variable).also { v -> stable += v })) }.orEmpty()
    val nullable = rangeExpr.expressionType?.elementType?.isMarkedNullable != false
    if (!nullable) {
        // ipairs stops at the first nil, so it is only used when elements can't be null.
        emit(LuaGenericFor(listOf("_", variable), listOf(luaCall(LuaName("ipairs"), list)), prologue + loopBody(frame, e.body)))
    } else {
        val items = cache(list, "list")
        val i = ctx.temp("i")
        val element = LuaLocal(listOf(variable), listOf(LuaIndex(items, LuaName(i))))
        emit(LuaNumericFor(i, LuaNumber("1"), LuaIndex(items, LuaString("size")), null, listOf(element) + prologue + loopBody(frame, e.body)))
    }
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
    return when (receiverType?.collectionKind()) {
        CollectionKind.Pair, CollectionKind.Triple -> LuaIndex(value, LuaString(listOf("first", "second", "third")[n - 1]))
        CollectionKind.Entry -> LuaIndex(value, LuaString(if (n == 1) "key" else "value"))
        CollectionKind.IndexedValue -> LuaIndex(value, LuaString(if (n == 1) "index" else "value"))
        CollectionKind.List, CollectionKind.Array -> LuaIndex(value, LuaNumber(n.toString()))
        else -> unsupported(entry, "Destructuring '${receiverType.pretty()}'")
    }
}

/** [collection] itself when it is already a `List`/`Array`, else a list copy of it. */
private fun FileTransformer.asList(kind: CollectionKind?, collection: LuaExpr): LuaExpr =
    if (kind?.isIndexable == true) collection else LuaMethodCall(collection, "toList", emptyList())

private fun FileTransformer.jumpTarget(e: KtExpressionWithLabel): LoopFrame? = with(session) {
    val label = e.getLabelName()
    val frame = if (label != null) loops.lastOrNull { it.label == label } else loops.lastOrNull()
    if (frame == null) unsupported(e, "Jump outside of a loop")
    return frame
}

internal fun FileTransformer.breakStatement(e: KtBreakExpression): Unit = with(session) {
    val frame = jumpTarget(e) ?: return
    if (frame === loops.last()) {
        emit(LuaBreak)
    } else if (!target.hasGoto) {
        // break@outer without goto: set a flag, and have each loop in between break when it is set.
        val flag = frame.breakFlag ?: ctx.temp("break").also { frame.breakFlag = it }
        emit(assign(flag, LuaBool(true)))
        emit(LuaBreak)
        innerFrames(frame).forEach { inner -> inner.addCheck(LuaIf(LuaName(flag), listOf(LuaBreak))) }
    } else {
        val label = frame.breakLabel ?: ctx.temp("break").also { frame.breakLabel = it }
        emit(LuaGoto(label))
    }
}

internal fun FileTransformer.continueStatement(e: KtContinueExpression): Unit = with(session) {
    val frame = jumpTarget(e) ?: return
    val label = frame.continueLabel ?: ctx.temp("continue").also { frame.continueLabel = it }
    if (target.hasGoto || frame === loops.last()) {
        emit(LuaGoto(label))
        return
    }
    // continue@outer without goto: break out of the inner loops, then continue the outer one.
    val flag = frame.continueFlag ?: ctx.temp("continue").also { frame.continueFlag = it }
    emit(assign(flag, LuaBool(true)))
    emit(LuaBreak)
    val inner = innerFrames(frame)
    inner.dropLast(1).forEach { it.addCheck(LuaIf(LuaName(flag), listOf(LuaBreak))) }
    inner.last().addCheck(LuaIf(LuaName(flag), listOf(LuaGoto(label))))
}

/** Loops nested inside [outer], innermost first. */
private fun FileTransformer.innerFrames(outer: LoopFrame): List<LoopFrame> = loops.toList().takeLastWhile { it !== outer }.reversed()

/** `x in range` for ranges without a step. */
internal fun FileTransformer.rangeContains(value: LuaExpr, range: KRange, element: KtElement): LuaExpr = with(session) {
    if (range.step != null) return unsupported(element, "'in' with a stepped range")
    val (first, last) = ordered(listOf(range.first, range.last)).let { it[0] to it[1] }
    val x = cache(value, "value")
    val lo = if (range.descending) last else first
    val hi = if (range.descending) first else last
    val upper = LuaBinary(if (range.inclusive) LuaBinOp.Le else LuaBinOp.Lt, x, hi)
    return LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Ge, x, lo), upper)
}

/** `xs.forEach { ... }` as a loop with the lambda inlined, so `return` and `return@forEach` work. */
internal fun FileTransformer.forEachLoop(collection: LuaExpr, type: KaType?, lambda: KtExpression, indexed: Boolean): Unit = with(session) {
    val literal = (KtPsiUtil.safeDeparenthesize(lambda) as? KtLambdaExpression)?.functionLiteral
    val params = literal?.valueParameters.orEmpty()
    fun varName(i: Int, default: String) =
        params.getOrNull(i)?.takeIf { it.destructuringDeclaration == null && it.name != null }?.let { naming.of(it) } ?: ctx.temp(default)
    fun body(vararg vars: String) = collect {
        inlineLambda(lambda, vars.map { LuaName(it).also { v -> stable += v } }, null, null)
    }
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
        type?.isStringType == true -> {
            val c = varName(0, "char")
            emit(LuaGenericFor(listOf(c), listOf(LuaMethodCall(collection, "gmatch", listOf(LuaString(".")))), body(c)))
        }
        indexed -> {
            val list = cache(asList(kind, collection), "list")
            val index = varName(0, "index")
            val value = varName(1, "value")
            val element = LuaLocal(listOf(value), listOf(CollectionMappings.index(list, LuaName(index))))
            val last = lastIndex(list)
            emit(LuaNumericFor(index, LuaNumber("0"), last, null, listOf(element) + body(index, value)))
        }
        else -> {
            val list = asList(kind, collection)
            val item = varName(0, "it").let { if (params.isEmpty()) "it" else it }
            if (type?.elementType?.isMarkedNullable == false) {
                emit(LuaGenericFor(listOf("_", item), listOf(luaCall(LuaName("ipairs"), list)), body(item)))
            } else {
                val items = cache(list, "list")
                val i = ctx.temp("i")
                val element = LuaLocal(listOf(item), listOf(LuaIndex(items, LuaName(i))))
                emit(LuaNumericFor(i, LuaNumber("1"), LuaIndex(items, LuaString("size")), null, listOf(element) + body(item)))
            }
        }
    }
}
