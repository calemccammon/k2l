package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaImplementationDetail
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaExplicitReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.KaReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaSmartCastedReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import com.intellij.psi.tree.IElementType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.isPrivate
import org.jetbrains.kotlin.types.Variance
import java.util.Collections
import java.util.IdentityHashMap

/**
 * Translates one Kotlin file into a Lua chunk. Expressions may need statements to run before them
 * (e.g. an `if` used as a value); those are emitted into the current statement buffer, see [collect].
 */
@OptIn(KaImplementationDetail::class)
class FileTransformer(
    session: KaSession,
    private val file: KtFile,
    val ctx: TransformContext,
) : KaSession by session {

    // ---- statement buffers ----

    private var buffer = mutableListOf<LuaStmt>()

    fun emit(stmt: LuaStmt) {
        buffer += stmt
    }

    private fun emitAll(stmts: List<LuaStmt>) {
        buffer += stmts
    }

    /** Runs [block] with a fresh statement buffer and returns what it emitted. */
    private inline fun collect(block: () -> Unit): List<LuaStmt> {
        val saved = buffer
        val mine = mutableListOf<LuaStmt>()
        buffer = mine
        try {
            block()
        } finally {
            buffer = saved
        }
        return mine
    }

    private inline fun <T> withPreceding(block: () -> T): Pair<T, List<LuaStmt>> {
        var result: T? = null
        val stmts = collect { result = block() }
        @Suppress("UNCHECKED_CAST")
        return (result as T) to stmts
    }

    /** Lua expressions known not to change if evaluated later (literals, `val`s and parameters). */
    private val stable: MutableSet<LuaExpr> = Collections.newSetFromMap(IdentityHashMap())

    private fun isStable(e: LuaExpr) =
        e is LuaNil || e is LuaBool || e is LuaNumber || e is LuaString || e in stable

    fun unsupported(element: KtElement, what: String): LuaExpr {
        ctx.error(element, "$what is not supported yet")
        return LuaNil
    }

    // ---- file ----

    fun transformFile(): LuaChunk {
        val body = mutableListOf<LuaStmt>()
        val topLevel = file.declarations.filter { it is KtNamedFunction || it is KtProperty }
        val forward = forwardReferenced(topLevel.toSet())
        if (forward.isNotEmpty()) body += LuaLocal(forward.map { nameOf(it as KtNamedDeclaration) })

        for (decl in file.declarations) {
            body += collect { topLevelDeclaration(decl, decl in forward) }
        }

        val main = topLevel.filterIsInstance<KtNamedFunction>().firstOrNull(::isMain)
        if (main != null) {
            val args = if (main.valueParameters.isEmpty()) emptyList() else listOf(LuaTable(listOf(LuaField.Positional(LuaName("...")))))
            body += LuaCallStmt(LuaCall(LuaName(nameOf(main)), args))
        }

        val exported = topLevel.filter { !it.isPrivate() && it != main }
        if (exported.isNotEmpty()) {
            body += LuaReturn(
                listOf(LuaTable(exported.map { nameOf(it as KtNamedDeclaration).let { n -> LuaField.Named(n, LuaName(n)) } })),
            )
        }
        return LuaChunk(body)
    }

    private fun isMain(fn: KtNamedFunction) =
        fn.name == "main" && fn.receiverTypeReference == null && fn.valueParameters.size <= 1

    /** Top-level declarations referenced textually before they are declared need a forward `local`. */
    private fun forwardReferenced(candidates: Set<KtDeclaration>): Set<KtDeclaration> {
        val result = LinkedHashSet<KtDeclaration>()
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitReferenceExpression(expression: KtReferenceExpression) {
                super.visitReferenceExpression(expression)
                if (expression !is KtNameReferenceExpression) return
                val target = expression.mainReference.resolve() as? KtDeclaration ?: return
                if (target in candidates && expression.textRange.startOffset < target.textRange.startOffset) result += target
            }
        })
        return candidates.filter { it in result }.toCollection(LinkedHashSet())
    }

    private fun topLevelDeclaration(decl: KtDeclaration, forwardDeclared: Boolean) {
        when (decl) {
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(nameOf(decl)), function(decl), isLocal = !forwardDeclared))
            is KtProperty -> property(decl, isLocal = !forwardDeclared)
            else -> unsupported(decl, "Declaration '${decl.javaClass.simpleName.removePrefix("Kt")}'")
        }
    }

    private fun nameOf(decl: KtNamedDeclaration): String = LuaNames.of(decl.name ?: "_")

    // ---- functions ----

    private class LoopFrame(val label: String?) {
        var continueLabel: String? = null
        var breakLabel: String? = null
    }

    private var loops = ArrayDeque<LoopFrame>()

    private fun function(fn: KtNamedFunction): LuaFunction {
        if (fn.receiverTypeReference != null) unsupported(fn, "Extension function")
        val params = fn.valueParameters.map { p ->
            if (p.hasDefaultValue()) unsupported(p, "Default parameter value")
            if (p.isVarArg) unsupported(p, "vararg parameter")
            nameOf(p)
        }
        val savedLoops = loops
        loops = ArrayDeque()
        try {
            return LuaFunction(params, collect { functionBody(fn) })
        } finally {
            loops = savedLoops
        }
    }

    private fun functionBody(fn: KtDeclarationWithBody) {
        val body = fn.bodyExpression ?: return
        if (fn.hasBlockBody()) {
            block(body)
            return
        }
        val returnType = (fn as? KtNamedFunction)?.returnType
        if (returnType == null || returnType.isUnitType || returnType.isNothingType) statement(body)
        else emitAll(valueInto(body) { listOf(LuaReturn(listOf(it))) })
    }

    // ---- statements ----

    private fun block(e: KtExpression) {
        if (e is KtBlockExpression) e.statements.forEach(::statement) else statement(e)
    }

    private fun statement(e: KtExpression) {
        when (e) {
            is KtParenthesizedExpression -> e.expression?.let(::statement)
            is KtProperty -> property(e, isLocal = true)
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(nameOf(e)), function(e), isLocal = true))
            is KtBinaryExpression -> if (e.operationToken in ASSIGNMENTS) assignment(e) else expressionStatement(e)
            is KtUnaryExpression -> if (e.operationToken == KtTokens.PLUSPLUS || e.operationToken == KtTokens.MINUSMINUS) {
                increment(e)
            } else {
                expressionStatement(e)
            }
            is KtIfExpression -> ifStatement(e)
            is KtWhenExpression -> whenInto(e, sink = null)
            is KtLabeledExpression -> labeled(e)
            is KtLoopExpression -> loop(e, label = null)
            is KtReturnExpression -> returnStatement(e)
            is KtBreakExpression -> breakStatement(e)
            is KtContinueExpression -> continueStatement(e)
            else -> expressionStatement(e)
        }
    }

    private fun expressionStatement(e: KtExpression) {
        val value = expression(e)
        when {
            value is LuaCall || value is LuaMethodCall -> emit(LuaCallStmt(value))
            isStable(value) || value is LuaName -> Unit // a bare value has no effect
            else -> emit(LuaLocal(listOf("_"), listOf(value)))
        }
    }

    private fun property(p: KtProperty, isLocal: Boolean) {
        if (p.delegate != null) {
            unsupported(p, "Delegated property")
            return
        }
        if (p.getter != null || p.setter != null) unsupported(p, "Property accessor")
        val name = nameOf(p)
        val init = p.initializer
        when {
            init == null -> if (isLocal) emit(LuaLocal(listOf(name)))
            isLocal && needsBranching(init) -> {
                emit(LuaLocal(listOf(name)))
                emitAll(valueInto(init) { listOf(LuaAssign(listOf(LuaName(name)), listOf(it))) })
            }
            isLocal -> emit(LuaLocal(listOf(name), listOf(expression(init))))
            else -> emitAll(valueInto(init) { listOf(LuaAssign(listOf(LuaName(name)), listOf(it))) })
        }
    }

    private fun assignment(e: KtBinaryExpression) {
        val left = e.left ?: return
        val right = e.right ?: return
        val target = assignTarget(left) ?: return
        if (e.operationToken == KtTokens.EQ) {
            emitAll(valueInto(right) { listOf(LuaAssign(listOf(target), listOf(it))) })
            return
        }
        val op = AUGMENTED.getValue(e.operationToken)
        val leftType = left.expressionType
        if (leftType == null || !(leftType.isNumber || leftType.isStringType)) {
            unsupported(e, "Compound assignment on '${leftType.pretty()}'")
            return
        }
        val value = operator(op, target, leftType, expression(right), right.expressionType, e)
        emit(LuaAssign(listOf(target), listOf(value)))
    }

    private fun assignTarget(e: KtExpression): LuaExpr? {
        val ref = KtPsiUtil.safeDeparenthesize(e) as? KtNameReferenceExpression
        val decl = ref?.mainReference?.resolve()
        if (ref == null || decl !is KtProperty || decl.containingFile != file) {
            unsupported(e, "Assignment to this target")
            return null
        }
        return LuaName(nameOf(decl))
    }

    private fun increment(e: KtUnaryExpression) {
        val base = e.baseExpression ?: return
        val target = assignTarget(base) ?: return
        val op = if (e.operationToken == KtTokens.PLUSPLUS) LuaBinOp.Add else LuaBinOp.Sub
        emit(LuaAssign(listOf(target), listOf(LuaBinary(op, target, LuaNumber("1")))))
    }

    private fun returnStatement(e: KtReturnExpression) {
        if (e.getLabelName() != null) {
            unsupported(e, "Labeled return")
            return
        }
        val value = e.returnedExpression
        if (value == null) emit(LuaReturn())
        else emitAll(valueInto(value) { listOf(LuaReturn(listOf(it))) })
    }

    private fun ifStatement(e: KtIfExpression) {
        val cond = expression(e.condition ?: return)
        val then = collect { e.then?.let(::block) }
        val orElse = e.`else`?.let { collect { block(it) } }
        emit(LuaIf(cond, then, orElse?.takeIf { it.isNotEmpty() }))
    }

    // ---- loops ----

    private fun labeled(e: KtLabeledExpression) {
        val base = e.baseExpression
        if (base is KtLoopExpression) loop(base, e.getLabelName())
        else unsupported(e, "Labeled expression")
    }

    private fun loop(e: KtLoopExpression, label: String?) {
        val frame = LoopFrame(label)
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
        frame.breakLabel?.let { emit(LuaLabel(it)) }
    }

    private fun loopBody(frame: LoopFrame, body: KtExpression?): List<LuaStmt> {
        loops.addLast(frame)
        val stmts = try {
            collect { body?.let(::block) }
        } finally {
            loops.removeLast()
        }
        val cont = frame.continueLabel ?: return stmts
        // The label sits outside a do-block so `goto` never jumps into the scope of a body local.
        return listOf(LuaDo(stmts), LuaLabel(cont))
    }

    private fun forLoop(e: KtForExpression, frame: LoopFrame) {
        val rangeExpr = e.loopRange ?: return
        val param = e.loopParameter
        if (param == null || param.destructuringDeclaration != null) {
            unsupported(e, "Destructuring in for loops")
            return
        }
        val range = parseRange(rangeExpr)
        val elementType = range?.first?.expressionType
        if (range == null || elementType == null || !elementType.isIntegral) {
            unsupported(rangeExpr, "Iterating over '${rangeExpr.expressionType.pretty()}'")
            return
        }
        val parts = listOfNotNull(range.first, range.last, range.step)
        val values = ordered(parts)
        val start = values[0]
        var limit = values[1]
        if (!range.inclusive) limit = plusConstant(limit, -1)
        val step = when {
            range.step != null -> if (range.descending) LuaUnary(LuaUnOp.Neg, values[2]) else values[2]
            range.descending -> LuaNumber("-1")
            else -> null
        }
        emit(LuaNumericFor(nameOf(param), start, limit, step, loopBody(frame, e.body)))
    }

    private fun plusConstant(e: LuaExpr, delta: Long): LuaExpr {
        val n = (e as? LuaNumber)?.text?.toLongOrNull()
        return when {
            n != null -> LuaNumber((n + delta).toString())
            delta < 0 -> LuaBinary(LuaBinOp.Sub, e, LuaNumber((-delta).toString()))
            else -> LuaBinary(LuaBinOp.Add, e, LuaNumber(delta.toString()))
        }
    }

    private fun jumpTarget(e: KtExpressionWithLabel): LoopFrame? {
        val label = e.getLabelName()
        val frame = if (label != null) loops.lastOrNull { it.label == label } else loops.lastOrNull()
        if (frame == null) unsupported(e, "Jump outside of a loop")
        return frame
    }

    private fun breakStatement(e: KtBreakExpression) {
        val frame = jumpTarget(e) ?: return
        if (frame === loops.last()) {
            emit(LuaBreak)
        } else {
            val label = frame.breakLabel ?: ctx.temp("break").also { frame.breakLabel = it }
            emit(LuaGoto(label))
        }
    }

    private fun continueStatement(e: KtContinueExpression) {
        val frame = jumpTarget(e) ?: return
        val label = frame.continueLabel ?: ctx.temp("continue").also { frame.continueLabel = it }
        emit(LuaGoto(label))
    }

    // ---- ranges ----

    private class KRange(
        val first: KtExpression,
        val last: KtExpression,
        val inclusive: Boolean,
        val descending: Boolean,
        val step: KtExpression? = null,
    )

    private fun parseRange(e: KtExpression): KRange? {
        val ex = KtPsiUtil.safeDeparenthesize(e) as? KtBinaryExpression ?: return null
        val left = ex.left ?: return null
        val right = ex.right ?: return null
        return when (ex.operationToken) {
            KtTokens.RANGE -> KRange(left, right, inclusive = true, descending = false)
            KtTokens.RANGE_UNTIL -> KRange(left, right, inclusive = false, descending = false)
            KtTokens.IDENTIFIER -> {
                val id = (ex.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>())
                    ?.partiallyAppliedSymbol?.symbol?.callableId?.toString() ?: return null
                if (!id.startsWith("kotlin/ranges/")) return null
                when (ex.operationReference.getReferencedName()) {
                    "until" -> KRange(left, right, inclusive = false, descending = false)
                    "downTo" -> KRange(left, right, inclusive = true, descending = true)
                    "step" -> parseRange(left)?.takeIf { it.step == null }
                        ?.let { KRange(it.first, it.last, it.inclusive, it.descending, right) }
                    else -> null
                }
            }
            else -> null
        }
    }

    /** `x in range` for ranges without a step. */
    private fun rangeContains(value: LuaExpr, range: KRange, element: KtElement): LuaExpr {
        if (range.step != null) return unsupported(element, "'in' with a stepped range")
        val (first, last) = ordered(listOf(range.first, range.last)).let { it[0] to it[1] }
        val x = cache(value, "value")
        val lo = if (range.descending) last else first
        val hi = if (range.descending) first else last
        val upper = LuaBinary(if (range.inclusive) LuaBinOp.Le else LuaBinOp.Lt, x, hi)
        return LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Ge, x, lo), upper)
    }

    /** Stores [value] in a local unless it is stable, so it can be read more than once. */
    private fun cache(value: LuaExpr, hint: String): LuaExpr {
        if (isStable(value)) return value
        val name = ctx.temp(hint)
        emit(LuaLocal(listOf(name), listOf(value)))
        return LuaName(name).also { stable += it }
    }

    // ---- branching values ----

    private fun needsBranching(e: KtExpression): Boolean {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        return ex is KtWhenExpression || (ex is KtIfExpression && !canTernary(ex))
    }

    /**
     * Emits statements that compute [e] and hand its value to [sink], pushing the sink into the
     * branches of `if`/`when` so no temporary is needed.
     */
    private fun valueInto(e: KtExpression, sink: (LuaExpr) -> List<LuaStmt>): List<LuaStmt> = collect {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        when {
            ex is KtIfExpression && !canTernary(ex) -> ifInto(ex, sink)
            ex is KtWhenExpression -> whenInto(ex, sink)
            ex is KtBlockExpression -> {
                ex.statements.dropLast(1).forEach(::statement)
                ex.statements.lastOrNull()?.let { emitAll(valueInto(it, sink)) }
            }
            isJump(ex) -> statement(ex)
            else -> emitAll(sink(expression(ex)))
        }
    }

    private fun isJump(e: KtExpression) =
        e is KtReturnExpression || e is KtBreakExpression || e is KtContinueExpression || e is KtThrowExpression ||
            e.expressionType.let { it != null && it.isNothingType && !it.isMarkedNullable }

    private fun ifInto(e: KtIfExpression, sink: (LuaExpr) -> List<LuaStmt>) {
        val cond = expression(e.condition ?: return)
        val then = e.then?.let { valueInto(it, sink) }.orEmpty()
        val orElse = e.`else`?.let { valueInto(it, sink) }
        emit(LuaIf(cond, then, orElse))
    }

    /**
     * `c and a or b` is only equivalent to `if (c) a else b` when `a` can never be nil or false, and
     * when no operand needs preceding statements (checked syntactically, so this has no side effects).
     */
    private fun canTernary(e: KtIfExpression): Boolean {
        val cond = e.condition ?: return false
        val then = e.then?.let(::singleExpression) ?: return false
        val orElse = e.`else`?.let(::singleExpression) ?: return false
        val thenType = then.expressionType ?: return false
        if (thenType.isMarkedNullable || thenType.isBooleanType || thenType.isNothingType || thenType.isUnitType) return false
        return !isJump(orElse) && listOf(cond, then, orElse).none(::mayNeedStatements)
    }

    private fun ternary(e: KtIfExpression): LuaExpr {
        val parts = listOf(e.condition!!, singleExpression(e.then!!)!!, singleExpression(e.`else`!!)!!).map(::expression)
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, parts[0], parts[1]), parts[2])
    }

    private fun mayNeedStatements(e: KtExpression): Boolean {
        var found = false
        e.accept(object : KtTreeVisitorVoid() {
            override fun visitElement(element: com.intellij.psi.PsiElement) {
                if (found) return
                if (element is KtIfExpression || element is KtWhenExpression ||
                    (element is KtUnaryExpression && (element.operationToken == KtTokens.PLUSPLUS || element.operationToken == KtTokens.MINUSMINUS))
                ) {
                    found = true
                    return
                }
                super.visitElement(element)
            }
        })
        return found
    }

    private fun singleExpression(e: KtExpression): KtExpression? =
        if (e is KtBlockExpression) e.statements.singleOrNull()?.takeIf { it !is KtDeclaration } else e

    private fun branchingValue(e: KtExpression): LuaExpr {
        val name = ctx.temp("temp")
        emit(LuaLocal(listOf(name)))
        emitAll(valueInto(e) { listOf(LuaAssign(listOf(LuaName(name)), listOf(it))) })
        return LuaName(name)
    }

    // ---- when ----

    private fun whenInto(e: KtWhenExpression, sink: ((LuaExpr) -> List<LuaStmt>)?) {
        val subjectVar = e.subjectVariable
        val subjectExpr = e.subjectExpression
        val subject: LuaExpr? = when {
            subjectVar != null -> {
                val name = nameOf(subjectVar)
                emit(LuaLocal(listOf(name), listOf(expression(subjectVar.initializer ?: return))))
                LuaName(name).also { stable += it }
            }
            subjectExpr != null -> cache(expression(subjectExpr), "subject")
            else -> null
        }
        val subjectType = (subjectVar?.initializer ?: subjectExpr)?.expressionType

        var tail: List<LuaStmt>? = null
        for (entry in e.entries.reversed()) {
            val bodyExpr = entry.expression ?: continue
            val body = if (sink == null) collect { block(bodyExpr) } else valueInto(bodyExpr, sink)
            if (entry.isElse) {
                tail = body
                continue
            }
            val (cond, pre) = withPreceding {
                entry.conditions.map { c -> { condition(c, subject, subjectType) } }.reduceOr()
            }
            tail = pre + LuaIf(cond, body, tail?.takeIf { it.isNotEmpty() })
        }
        tail?.let(::emitAll)
    }

    private fun List<() -> LuaExpr>.reduceOr(): LuaExpr =
        drop(1).fold(first()()) { acc, next -> shortCircuit(LuaBinOp.Or, acc, next) }

    private fun condition(c: KtWhenCondition, subject: LuaExpr?, subjectType: KaType?): LuaExpr = when (c) {
        is KtWhenConditionWithExpression -> {
            val expr = c.expression ?: return LuaNil
            if (subject == null) expression(expr)
            else operator(LuaBinOp.Eq, subject, subjectType, expression(expr), expr.expressionType, c)
        }
        is KtWhenConditionInRange -> {
            val range = c.rangeExpression?.let(::parseRange)
            if (subject == null || range == null) {
                unsupported(c, "This 'in' condition")
            } else {
                rangeContains(subject, range, c).let { if (c.isNegated) negate(it) else it }
            }
        }
        is KtWhenConditionIsPattern -> {
            val type = c.typeReference?.type
            if (subject == null || type == null) LuaNil
            else typeTest(subject, type, c).let { if (c.isNegated) negate(it) else it }
        }
        else -> unsupported(c, "This 'when' condition")
    }

    private fun typeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr {
        val luaType = when {
            type.isStringType || type.isCharType -> "string"
            type.isBooleanType -> "boolean"
            type.isIntegral -> return LuaBinary(LuaBinOp.Eq, luaCall(luaPath("math", "type"), value), LuaString("integer"))
            type.isDoubleType || type.isFloatType -> return LuaBinary(LuaBinOp.Eq, luaCall(luaPath("math", "type"), value), LuaString("float"))
            else -> return unsupported(element, "Type check against '${type.pretty()}'")
        }
        return LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString(luaType))
    }

    // ---- expressions ----

    fun expression(e: KtExpression): LuaExpr = when (e) {
        is KtParenthesizedExpression -> e.expression?.let(::expression) ?: LuaNil
        is KtConstantExpression -> constant(e)
        is KtStringTemplateExpression -> template(e)
        is KtNameReferenceExpression -> reference(e)
        is KtBinaryExpression -> binary(e)
        is KtPrefixExpression -> prefix(e)
        is KtPostfixExpression -> postfix(e)
        is KtCallExpression -> call(e, e)
        is KtDotQualifiedExpression -> when (val selector = e.selectorExpression) {
            is KtCallExpression -> call(selector, e)
            is KtNameReferenceExpression -> reference(selector, e)
            else -> unsupported(e, "This qualified expression")
        }
        is KtIfExpression -> if (canTernary(e)) ternary(e) else branchingValue(e)
        is KtWhenExpression -> branchingValue(e)
        else -> unsupported(e, "Expression '${e.javaClass.simpleName.removePrefix("Kt")}'")
    }

    private fun constant(e: KtExpression): LuaExpr = when (val c = e.evaluate()) {
        is KaConstantValue.IntValue -> LuaNumber(c.value.toString())
        is KaConstantValue.LongValue -> LuaNumber(c.value.toString())
        is KaConstantValue.ShortValue -> LuaNumber(c.value.toString())
        is KaConstantValue.ByteValue -> LuaNumber(c.value.toString())
        is KaConstantValue.DoubleValue -> doubleLiteral(c.value)
        is KaConstantValue.FloatValue -> doubleLiteral(c.value.toString().toDouble())
        is KaConstantValue.BooleanValue -> LuaBool(c.value)
        is KaConstantValue.CharValue -> LuaString(c.value.toString())
        is KaConstantValue.StringValue -> LuaString(c.value)
        is KaConstantValue.NullValue -> LuaNil
        null -> unsupported(e, "Non-constant literal")
        else -> unsupported(e, "Constant of type ${c.javaClass.simpleName}")
    }

    private fun doubleLiteral(d: Double): LuaExpr = when {
        d.isNaN() -> LuaBinary(LuaBinOp.Div, LuaNumber("0.0"), LuaNumber("0.0"))
        d == Double.POSITIVE_INFINITY -> luaPath("math", "huge")
        d == Double.NEGATIVE_INFINITY -> LuaUnary(LuaUnOp.Neg, luaPath("math", "huge"))
        else -> LuaNumber(d.toString())
    }

    private fun template(e: KtStringTemplateExpression): LuaExpr {
        val parts = mutableListOf<LuaExpr>()
        var lone: Pair<KtExpression, LuaExpr>? = null
        val pending = StringBuilder()
        fun flush() {
            if (pending.isNotEmpty()) parts += LuaString(pending.toString())
            pending.clear()
        }
        for (entry in e.entries) {
            when (entry) {
                is KtLiteralStringTemplateEntry -> pending.append(entry.text)
                is KtEscapeStringTemplateEntry -> pending.append(entry.unescapedValue)
                is KtStringTemplateEntryWithExpression -> {
                    val expr = entry.expression ?: continue
                    flush()
                    val value = expression(expr)
                    lone = expr to value
                    parts += str(value, expr.expressionType, forConcat = true)
                }
            }
        }
        flush()
        return when (parts.size) {
            0 -> LuaString("")
            // "$x" on its own still has to produce a string.
            1 -> lone?.let { (expr, value) -> str(value, expr.expressionType) } ?: parts[0]
            else -> parts.reduceRight { part, acc -> LuaBinary(LuaBinOp.Concat, part, acc) }
        }
    }

    /**
     * Converts [value] to a string the way Kotlin's `toString()` would. With [forConcat], numbers that
     * Lua's `..` already formats identically are left alone.
     */
    fun str(value: LuaExpr, type: KaType?, forConcat: Boolean = false): LuaExpr {
        if (type != null && !type.isMarkedNullable) {
            when {
                type.isStringType || type.isCharType -> return value
                type.isIntegral -> return if (forConcat) value else luaCall(LuaName("tostring"), value)
                type.isBooleanType -> return luaCall(LuaName("tostring"), value)
            }
        }
        return lualibCall("Str", value)
    }

    fun lualibCall(feature: String, vararg args: LuaExpr): LuaExpr {
        ctx.lualib += feature
        return LuaCall(LuaName(Lualib.functionName(feature)), args.toList())
    }

    private fun reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr {
        val symbol = e.mainReference.resolveToSymbol()
        val psi = symbol?.psi
        return when {
            symbol is KaLocalVariableSymbol || symbol is KaValueParameterSymbol -> {
                val name = LuaName(LuaNames.of(symbol.name.asString()))
                if (symbol is KaValueParameterSymbol || (symbol as KaLocalVariableSymbol).isVal) stable += name
                name
            }
            symbol is KaPropertySymbol && psi is KtProperty && psi.containingFile == file && psi.isTopLevel ->
                LuaName(nameOf(psi))
            else -> call(e, full)
        }
    }

    private fun binary(e: KtBinaryExpression): LuaExpr {
        val token = e.operationToken
        val left = e.left ?: return LuaNil
        val right = e.right ?: return LuaNil
        return when (token) {
            KtTokens.ANDAND -> shortCircuit(LuaBinOp.And, expression(left)) { expression(right) }
            KtTokens.OROR -> shortCircuit(LuaBinOp.Or, expression(left)) { expression(right) }
            KtTokens.IN_KEYWORD, KtTokens.NOT_IN -> {
                val range = parseRange(right) ?: return unsupported(e, "'in' on '${right.expressionType.pretty()}'")
                val contains = rangeContains(expression(left), range, e)
                if (token == KtTokens.NOT_IN) negate(contains) else contains
            }
            KtTokens.IDENTIFIER -> call(e, e)
            in BINARY_OPERATORS -> {
                val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
                operator(BINARY_OPERATORS.getValue(token), l, left.expressionType, r, right.expressionType, e)
            }
            else -> unsupported(e, "Operator '${e.operationReference.text}'")
        }
    }

    /** `left op right` for `and`/`or`, keeping [right]'s preceding statements behind the short circuit. */
    private fun shortCircuit(op: LuaBinOp, left: LuaExpr, right: () -> LuaExpr): LuaExpr {
        val (r, pre) = withPreceding(right)
        if (pre.isEmpty()) return LuaBinary(op, left, r)
        val name = ctx.temp("cond")
        emit(LuaLocal(listOf(name), listOf(left)))
        val test = if (op == LuaBinOp.And) LuaName(name) else LuaUnary(LuaUnOp.Not, LuaName(name))
        emit(LuaIf(test, pre + LuaAssign(listOf(LuaName(name)), listOf(r))))
        return LuaName(name)
    }

    /**
     * A Kotlin operator applied to primitive/String operands. [op] is the Lua operator the Kotlin token
     * maps to; division and remainder get Kotlin's truncating semantics.
     */
    private fun operator(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, element: KtElement): LuaExpr {
        val numeric = lt != null && rt != null && lt.isNumber && rt.isNumber
        return when (op) {
            LuaBinOp.Add -> when {
                lt?.isStringType == true -> LuaBinary(LuaBinOp.Concat, l, str(r, rt, forConcat = true))
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'+' on '${lt.pretty()}'")
            }
            LuaBinOp.Sub, LuaBinOp.Mul -> if (numeric) LuaBinary(op, l, r) else unsupported(element, "Arithmetic on '${lt.pretty()}'")
            LuaBinOp.Div -> when {
                numeric && lt!!.isIntegral && rt!!.isIntegral -> lualibCall("IDiv", l, r)
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'/' on '${lt.pretty()}'")
            }
            LuaBinOp.Mod -> if (numeric) luaCall(luaPath("math", "fmod"), l, r) else unsupported(element, "'%' on '${lt.pretty()}'")
            LuaBinOp.Eq, LuaBinOp.Ne -> LuaBinary(op, l, r)
            LuaBinOp.Lt, LuaBinOp.Gt, LuaBinOp.Le, LuaBinOp.Ge ->
                if (numeric || (lt.isTextual && rt.isTextual)) LuaBinary(op, l, r)
                else unsupported(element, "Comparison of '${lt.pretty()}'")
            else -> LuaBinary(op, l, r)
        }
    }

    private fun prefix(e: KtPrefixExpression): LuaExpr {
        val base = e.baseExpression ?: return LuaNil
        return when (e.operationToken) {
            KtTokens.MINUS -> LuaUnary(LuaUnOp.Neg, expression(base))
            KtTokens.PLUS -> expression(base)
            KtTokens.EXCL -> negate(expression(base))
            KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
                increment(e)
                assignTarget(base) ?: LuaNil
            }
            else -> unsupported(e, "Prefix operator '${e.operationReference.text}'")
        }
    }

    private fun postfix(e: KtPostfixExpression): LuaExpr {
        val base = e.baseExpression ?: return LuaNil
        return when (e.operationToken) {
            KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
                val target = assignTarget(base) ?: return LuaNil
                val old = ctx.temp("old")
                emit(LuaLocal(listOf(old), listOf(target)))
                increment(e)
                LuaName(old)
            }
            else -> unsupported(e, "Postfix operator '${e.operationReference.text}'")
        }
    }

    private fun negate(e: LuaExpr): LuaExpr = when {
        e is LuaUnary && e.op == LuaUnOp.Not -> e.operand
        e is LuaBool -> LuaBool(!e.value)
        e is LuaBinary && e.op == LuaBinOp.Eq -> LuaBinary(LuaBinOp.Ne, e.left, e.right)
        e is LuaBinary && e.op == LuaBinOp.Ne -> LuaBinary(LuaBinOp.Eq, e.left, e.right)
        else -> LuaUnary(LuaUnOp.Not, e)
    }

    /**
     * Transforms [exprs] left to right. If a later expression needs preceding statements, earlier
     * results are cached in locals first so evaluation order is preserved.
     */
    private fun ordered(exprs: List<KtExpression>): List<LuaExpr> {
        val results = exprs.map { withPreceding { expression(it) } }
        val last = results.indexOfLast { it.second.isNotEmpty() }
        return results.mapIndexed { i, (value, pre) ->
            emitAll(pre)
            if (i < last) cache(value, "arg") else value
        }
    }

    // ---- calls ----

    /**
     * A resolved call or property access. [element] is what the Analysis API resolves (a call,
     * name reference or infix binary expression); [full] includes any explicit receiver.
     */
    private fun call(element: KtExpression, full: KtExpression): LuaExpr {
        val call = element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
            ?: return unsupported(full, "Unresolved call '${full.text}'")
        val symbol = call.partiallyAppliedSymbol.symbol
        val callableId = symbol.callableId?.toString()
        val psi = symbol.psi

        // Library constants such as Int.MAX_VALUE fold to literals; their receiver is not a value.
        if (call !is KaFunctionCall<*> && !StdlibMappings.has(callableId) && full.evaluate() != null) return constant(full)

        val receiverValue = call.partiallyAppliedSymbol.extensionReceiver ?: call.partiallyAppliedSymbol.dispatchReceiver
        val receiver = receiverValue?.let { explicitReceiver(it) }
        if (receiverValue != null && receiver == null) return unsupported(full, "Implicit receiver")

        val args = if (call is KaFunctionCall<*>) {
            val bySignature = call.argumentMapping.entries.groupBy({ it.value.symbol }, { it.key })
            val params = (symbol as KaFunctionSymbol).valueParameters
            params.flatMap { p ->
                val mapped = bySignature[p]
                if (mapped == null && psi is KtNamedFunction) unsupported(full, "Omitting an argument with a default value")
                mapped.orEmpty()
            }
        } else {
            emptyList()
        }

        if (psi is KtNamedFunction && psi.containingFile == file) {
            if (receiver != null) return unsupported(full, "Calling an extension function")
            return LuaCall(LuaName(nameOf(psi)), ordered(args))
        }
        val declaringFile = psi?.containingFile as? KtFile
        if (declaringFile != null && declaringFile != file && !declaringFile.isCompiled) {
            return unsupported(full, "Referencing declarations from another file")
        }

        val values = ordered(listOfNotNull(receiver) + args)
        val site = CallSite(
            transformer = this,
            element = full,
            name = symbol.callableId?.callableName?.asString(),
            receiver = if (receiver != null) values[0] else null,
            receiverType = receiver?.expressionType,
            args = if (receiver != null) values.drop(1) else values,
            argTypes = args.map { it.expressionType },
        )
        StdlibMappings.map(callableId, site)?.let { return it }
        return unsupported(full, "Kotlin library API '${callableId ?: full.text}'")
    }

    private fun explicitReceiver(value: KaReceiverValue): KtExpression? = when (value) {
        is KaExplicitReceiverValue -> value.expression
        is KaSmartCastedReceiverValue -> explicitReceiver(value.original)
        else -> null
    }

    // ---- type helpers ----

    @OptIn(KaExperimentalApi::class)
    private fun KaType?.pretty(): String = this?.render(position = Variance.INVARIANT) ?: "?"

    val KaType.isIntegral get() = isIntType || isLongType || isShortType || isByteType
    val KaType.isNumber get() = !isMarkedNullable && (isIntegral || isDoubleType || isFloatType)
    private val KaType?.isTextual get() = this != null && !isMarkedNullable && (isStringType || isCharType)

    companion object {
        private val ASSIGNMENTS: Set<IElementType> = setOf(
            KtTokens.EQ, KtTokens.PLUSEQ, KtTokens.MINUSEQ, KtTokens.MULTEQ, KtTokens.DIVEQ, KtTokens.PERCEQ,
        )
        private val AUGMENTED: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUSEQ to LuaBinOp.Add, KtTokens.MINUSEQ to LuaBinOp.Sub, KtTokens.MULTEQ to LuaBinOp.Mul,
            KtTokens.DIVEQ to LuaBinOp.Div, KtTokens.PERCEQ to LuaBinOp.Mod,
        )
        private val BINARY_OPERATORS: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUS to LuaBinOp.Add, KtTokens.MINUS to LuaBinOp.Sub, KtTokens.MUL to LuaBinOp.Mul,
            KtTokens.DIV to LuaBinOp.Div, KtTokens.PERC to LuaBinOp.Mod,
            KtTokens.EQEQ to LuaBinOp.Eq, KtTokens.EXCLEQ to LuaBinOp.Ne,
            KtTokens.EQEQEQ to LuaBinOp.Eq, KtTokens.EXCLEQEQEQ to LuaBinOp.Ne,
            KtTokens.LT to LuaBinOp.Lt, KtTokens.GT to LuaBinOp.Gt, KtTokens.LTEQ to LuaBinOp.Le, KtTokens.GTEQ to LuaBinOp.Ge,
        )
    }
}
