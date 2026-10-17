package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.base.KaConstantValue
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaExplicitReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.KaImplicitReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.KaSmartCastedReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import com.intellij.psi.tree.IElementType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject
import org.jetbrains.kotlin.psi.psiUtil.isPrivate
import java.util.Collections
import java.util.IdentityHashMap

/**
 * Translates one Kotlin file into a Lua chunk. Expressions may need statements to run before them
 * (e.g. an `if` used as a value); those are emitted into the current statement buffer, see [collect].
 */
class FileTransformer(
    private val session: KaSession,
    private val file: KtFile,
    val ctx: TransformContext,
) {

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

    fun transformFile(): LuaChunk = with(session) { transformChunk() }

    private fun KaSession.transformChunk(): LuaChunk {
        val body = mutableListOf<LuaStmt>()
        val topLevel = file.declarations.filter {
            it is KtNamedFunction || it is KtProperty || (it is KtClassOrObject && !(it is KtClass && it.isAnnotation()))
        }
        val forward = forwardReferenced(topLevel.toSet())
        if (forward.isNotEmpty()) body += LuaLocal(forward.map { nameOf(it as KtNamedDeclaration) })

        // A class must be created after the classes and interfaces it extends, wherever they are declared.
        val emitted = HashSet<KtDeclaration>()
        fun emitDeclaration(decl: KtDeclaration) {
            if (!emitted.add(decl)) return
            if (decl is KtClassOrObject) {
                superInfo(decl).let { listOfNotNull(it.base) + it.interfaces }.filter { it.isTopLevel() }.forEach { emitDeclaration(it) }
            }
            body += collect { topLevelDeclaration(decl, decl in forward) }
        }
        file.declarations.forEach { emitDeclaration(it) }

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
    private fun KaSession.forwardReferenced(candidates: Set<KtDeclaration>): Set<KtDeclaration> {
        val result = LinkedHashSet<KtDeclaration>()
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitReferenceExpression(expression: KtReferenceExpression) {
                super.visitReferenceExpression(expression)
                if (expression !is KtNameReferenceExpression) return
                // Members, constructors and enum entries count as references to their top-level class.
                val resolved = expression.mainReference.resolve() ?: return
                val target = generateSequence(resolved) { it.parent }.firstOrNull { it in candidates } as? KtDeclaration ?: return
                if (expression.textRange.startOffset < target.textRange.startOffset) result += target
            }
        })
        return candidates.filter { it in result }.toCollection(LinkedHashSet())
    }

    private fun KaSession.topLevelDeclaration(decl: KtDeclaration, forwardDeclared: Boolean) {
        when (decl) {
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(nameOf(decl)), function(decl), isLocal = !forwardDeclared))
            is KtProperty -> property(decl, isLocal = !forwardDeclared)
            is KtClassOrObject -> classDeclaration(decl, isLocal = !forwardDeclared)
            is KtTypeAlias -> Unit
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

    private fun KaSession.function(fn: KtNamedFunction): LuaFunction {
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

    private fun KaSession.functionBody(fn: KtDeclarationWithBody) {
        val body = fn.bodyExpression ?: return
        if (fn.hasBlockBody()) {
            block(body)
            return
        }
        val returnType = fn.returnType
        if (returnType == null || returnType.isUnitType || returnType.isNothingType) statement(body)
        else emitAll(valueInto(body) { listOf(LuaReturn(listOf(it))) })
    }

    // ---- statements ----

    private fun KaSession.block(e: KtExpression) {
        if (e is KtBlockExpression) e.statements.forEach { statement(it) } else statement(e)
    }

    private fun KaSession.statement(e: KtExpression) {
        when (e) {
            is KtParenthesizedExpression -> e.expression?.let { statement(it) }
            is KtProperty -> property(e, isLocal = true)
            is KtClassOrObject -> classDeclaration(e, isLocal = true)
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(nameOf(e)), function(e), isLocal = true))
            is KtBinaryExpression -> if (e.operationToken in ASSIGNMENTS) assignment(e) else expressionStatement(e)
            is KtUnaryExpression -> if (e.operationToken == KtTokens.PLUSPLUS || e.operationToken == KtTokens.MINUSMINUS) {
                e.baseExpression?.let { assignTarget(it) }?.let { increment(e, it) }
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

    private fun KaSession.expressionStatement(e: KtExpression) {
        val value = expression(e)
        when {
            value is LuaCall || value is LuaMethodCall -> emit(LuaCallStmt(value))
            isStable(value) || value is LuaName -> Unit // a bare value has no effect
            else -> emit(LuaLocal(listOf("_"), listOf(value)))
        }
    }

    private fun KaSession.property(p: KtProperty, isLocal: Boolean) {
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

    private fun KaSession.assignment(e: KtBinaryExpression) {
        val left = e.left ?: return
        val right = e.right ?: return
        val target = assignTarget(left) ?: return
        if (e.operationToken == KtTokens.EQ) {
            emitAll(valueInto(right) { listOf(target.write(it)) })
            return
        }
        val op = AUGMENTED.getValue(e.operationToken)
        val leftType = left.expressionType
        if (leftType == null || !(leftType.isNumber || leftType.isStringType)) {
            unsupported(e, "Compound assignment on '${leftType.pretty()}'")
            return
        }
        val value = operator(op, target.read, leftType, expression(right), right.expressionType, e)
        emit(target.write(value))
    }

    /** Something assignable: a variable, or a property of an object (possibly with accessors). */
    private class Target(val read: LuaExpr, val write: (LuaExpr) -> LuaStmt)

    private fun KaSession.assignTarget(e: KtExpression): Target? {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        val ref = when (ex) {
            is KtNameReferenceExpression -> ex
            is KtDotQualifiedExpression -> ex.selectorExpression as? KtNameReferenceExpression
            else -> null
        }
        val receiverExpr = (ex as? KtDotQualifiedExpression)?.receiverExpression
        if (ref != null && receiverExpr == null && ref.mainReference.resolveToSymbol() is KaBackingFieldSymbol) {
            val field = backingField(ref)
            return Target(field) { LuaAssign(listOf(field), listOf(it)) }
        }
        val decl = ref?.mainReference?.resolve()
        if (ref == null || decl == null || decl.containingFile != file) {
            unsupported(e, "Assignment to this target")
            return null
        }
        if (decl is KtProperty && decl.containingClassOrObject == null) {
            val name = LuaName(nameOf(decl))
            return Target(name) { LuaAssign(listOf(name), listOf(it)) }
        }
        if (!isMemberProperty(decl)) {
            unsupported(e, "Assignment to this target")
            return null
        }
        val receiver = if (receiverExpr != null) cache(expression(receiverExpr), "object") else implicitReceiverOf(ref) ?: return null
        val property = decl as KtNamedDeclaration
        return Target(propertyRead(receiver, property)) { propertyWrite(receiver, property, it) }
    }

    private fun KaSession.increment(e: KtUnaryExpression, target: Target) {
        val op = if (e.operationToken == KtTokens.PLUSPLUS) LuaBinOp.Add else LuaBinOp.Sub
        emit(target.write(LuaBinary(op, target.read, LuaNumber("1"))))
    }

    private fun KaSession.returnStatement(e: KtReturnExpression) {
        if (e.getLabelName() != null) {
            unsupported(e, "Labeled return")
            return
        }
        val value = e.returnedExpression
        if (value == null) emit(LuaReturn())
        else emitAll(valueInto(value) { listOf(LuaReturn(listOf(it))) })
    }

    private fun KaSession.ifStatement(e: KtIfExpression) {
        val cond = expression(e.condition ?: return)
        val then = collect { e.then?.let { block(it) } }
        val orElse = e.`else`?.let { collect { block(it) } }
        emit(LuaIf(cond, then, orElse?.takeIf { it.isNotEmpty() }))
    }

    // ---- loops ----

    private fun KaSession.labeled(e: KtLabeledExpression) {
        val base = e.baseExpression
        if (base is KtLoopExpression) loop(base, e.getLabelName())
        else unsupported(e, "Labeled expression")
    }

    private fun KaSession.loop(e: KtLoopExpression, label: String?) {
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

    private fun KaSession.loopBody(frame: LoopFrame, body: KtExpression?): List<LuaStmt> {
        loops.addLast(frame)
        val stmts = try {
            collect { body?.let { block(it) } }
        } finally {
            loops.removeLast()
        }
        val cont = frame.continueLabel ?: return stmts
        // The label sits outside a do-block so `goto` never jumps into the scope of a body local.
        return listOf(LuaDo(stmts), LuaLabel(cont))
    }

    private fun KaSession.forLoop(e: KtForExpression, frame: LoopFrame) {
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

    private fun KaSession.jumpTarget(e: KtExpressionWithLabel): LoopFrame? {
        val label = e.getLabelName()
        val frame = if (label != null) loops.lastOrNull { it.label == label } else loops.lastOrNull()
        if (frame == null) unsupported(e, "Jump outside of a loop")
        return frame
    }

    private fun KaSession.breakStatement(e: KtBreakExpression) {
        val frame = jumpTarget(e) ?: return
        if (frame === loops.last()) {
            emit(LuaBreak)
        } else {
            val label = frame.breakLabel ?: ctx.temp("break").also { frame.breakLabel = it }
            emit(LuaGoto(label))
        }
    }

    private fun KaSession.continueStatement(e: KtContinueExpression) {
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

    private fun KaSession.parseRange(e: KtExpression): KRange? {
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
    private fun KaSession.rangeContains(value: LuaExpr, range: KRange, element: KtElement): LuaExpr {
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

    private fun KaSession.needsBranching(e: KtExpression): Boolean {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        return ex is KtWhenExpression || (ex is KtIfExpression && !canTernary(ex))
    }

    /**
     * Emits statements that compute [e] and hand its value to [sink], pushing the sink into the
     * branches of `if`/`when` so no temporary is needed.
     */
    private fun KaSession.valueInto(e: KtExpression, sink: (LuaExpr) -> List<LuaStmt>): List<LuaStmt> = collect {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        when {
            ex is KtIfExpression && !canTernary(ex) -> ifInto(ex, sink)
            ex is KtWhenExpression -> whenInto(ex, sink)
            ex is KtBlockExpression -> {
                ex.statements.dropLast(1).forEach { statement(it) }
                ex.statements.lastOrNull()?.let { emitAll(valueInto(it, sink)) }
            }
            isJump(ex) -> statement(ex)
            else -> emitAll(sink(expression(ex)))
        }
    }

    private fun KaSession.isJump(e: KtExpression) =
        e is KtReturnExpression || e is KtBreakExpression || e is KtContinueExpression || e is KtThrowExpression ||
            e.expressionType.let { it != null && it.isNothingType && !it.isMarkedNullable }

    private fun KaSession.ifInto(e: KtIfExpression, sink: (LuaExpr) -> List<LuaStmt>) {
        val cond = expression(e.condition ?: return)
        val then = e.then?.let { valueInto(it, sink) }.orEmpty()
        val orElse = e.`else`?.let { valueInto(it, sink) }
        emit(LuaIf(cond, then, orElse))
    }

    /**
     * `c and a or b` is only equivalent to `if (c) a else b` when `a` can never be nil or false, and
     * when no operand needs preceding statements (checked syntactically, so this has no side effects).
     */
    private fun KaSession.canTernary(e: KtIfExpression): Boolean {
        val cond = e.condition ?: return false
        val then = e.then?.let { singleExpression(it) } ?: return false
        val orElse = e.`else`?.let { singleExpression(it) } ?: return false
        val thenType = then.expressionType ?: return false
        if (thenType.isMarkedNullable || thenType.isBooleanType || thenType.isNothingType || thenType.isUnitType) return false
        return !isJump(orElse) && listOf(cond, then, orElse).none{ mayNeedStatements(it) }
    }

    private fun KaSession.ternary(e: KtIfExpression): LuaExpr {
        val parts = listOf(e.condition!!, singleExpression(e.then!!)!!, singleExpression(e.`else`!!)!!).map{ expression(it) }
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, parts[0], parts[1]), parts[2])
    }

    private fun KaSession.mayNeedStatements(e: KtExpression): Boolean {
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

    private fun KaSession.singleExpression(e: KtExpression): KtExpression? =
        if (e is KtBlockExpression) e.statements.singleOrNull()?.takeIf { it !is KtDeclaration } else e

    private fun KaSession.branchingValue(e: KtExpression): LuaExpr {
        val name = ctx.temp("temp")
        emit(LuaLocal(listOf(name)))
        emitAll(valueInto(e) { listOf(LuaAssign(listOf(LuaName(name)), listOf(it))) })
        return LuaName(name)
    }

    // ---- when ----

    private fun KaSession.whenInto(e: KtWhenExpression, sink: ((LuaExpr) -> List<LuaStmt>)?) {
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
        tail?.let { emitAll(it) }
    }

    private fun List<() -> LuaExpr>.reduceOr(): LuaExpr =
        drop(1).fold(first()()) { acc, next -> shortCircuit(LuaBinOp.Or, acc, next) }

    private fun KaSession.condition(c: KtWhenCondition, subject: LuaExpr?, subjectType: KaType?): LuaExpr = when (c) {
        is KtWhenConditionWithExpression -> {
            val expr = c.expression ?: return LuaNil
            if (subject == null) expression(expr)
            else equality(subject, subjectType, expression(expr), expr.expressionType, negated = false)
        }
        is KtWhenConditionInRange -> {
            val range = c.rangeExpression?.let { parseRange(it) }
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

    private fun KaSession.typeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr {
        val luaType = when {
            type.isStringType || type.isCharType -> "string"
            type.isBooleanType -> "boolean"
            type.isIntegral -> return LuaBinary(LuaBinOp.Eq, luaCall(luaPath("math", "type"), value), LuaString("integer"))
            type.isDoubleType || type.isFloatType -> return LuaBinary(LuaBinOp.Eq, luaCall(luaPath("math", "type"), value), LuaString("float"))
            else -> {
                val symbol = type.expandedSymbol
                val psi = symbol?.psi as? KtClassOrObject
                return when {
                    symbol?.classId?.asString() == "kotlin/Any" -> LuaBinary(LuaBinOp.Ne, value, LuaNil)
                    psi == null || psi.containingFile != file -> unsupported(element, "Type check against '${type.pretty()}'")
                    psi is KtObjectDeclaration -> LuaBinary(LuaBinOp.Eq, value, classRef(psi))
                    else -> lualibCall("InstanceOf", value, classRef(psi))
                }
            }
        }
        return LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString(luaType))
    }

    // ---- expressions ----

    fun KaSession.expression(e: KtExpression): LuaExpr = when (e) {
        is KtParenthesizedExpression -> e.expression?.let { expression(it) } ?: LuaNil
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
        is KtThisExpression -> thisRef(e)
        is KtBinaryExpressionWithTypeRHS -> cast(e)
        is KtIsExpression -> {
            val type = e.typeReference?.type
            if (type == null) LuaNil
            else typeTest(cache(expression(e.leftHandSide), "value"), type, e).let { if (e.isNegated) negate(it) else it }
        }
        else -> unsupported(e, "Expression '${e.javaClass.simpleName.removePrefix("Kt")}'")
    }

    private fun KaSession.constant(e: KtExpression): LuaExpr = when (val c = e.evaluate()) {
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

    private fun KaSession.doubleLiteral(d: Double): LuaExpr = when {
        d.isNaN() -> LuaBinary(LuaBinOp.Div, LuaNumber("0.0"), LuaNumber("0.0"))
        d == Double.POSITIVE_INFINITY -> luaPath("math", "huge")
        d == Double.NEGATIVE_INFINITY -> LuaUnary(LuaUnOp.Neg, luaPath("math", "huge"))
        else -> LuaNumber(d.toString())
    }

    private fun KaSession.template(e: KtStringTemplateExpression): LuaExpr {
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
    fun KaSession.str(value: LuaExpr, type: KaType?, forConcat: Boolean = false): LuaExpr {
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

    private fun KaSession.reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr {
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
            symbol is KaBackingFieldSymbol -> backingField(e)
            symbol is KaEnumEntrySymbol && psi is KtEnumEntry && psi.containingFile == file ->
                LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(psi.name!!))
            symbol is KaClassLikeSymbol && psi is KtClassOrObject && psi.containingFile == file -> classRef(psi)
            else -> call(e, full)
        }
    }

    private fun KaSession.binary(e: KtBinaryExpression): LuaExpr {
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
            KtTokens.EQEQ, KtTokens.EXCLEQ -> {
                val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
                equality(l, left.expressionType, r, right.expressionType, negated = token == KtTokens.EXCLEQ)
            }
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
    private fun KaSession.operator(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, element: KtElement): LuaExpr {
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

    private fun KaSession.prefix(e: KtPrefixExpression): LuaExpr {
        val base = e.baseExpression ?: return LuaNil
        return when (e.operationToken) {
            KtTokens.MINUS -> LuaUnary(LuaUnOp.Neg, expression(base))
            KtTokens.PLUS -> expression(base)
            KtTokens.EXCL -> negate(expression(base))
            KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
                val target = assignTarget(base) ?: return LuaNil
                increment(e, target)
                target.read
            }
            else -> unsupported(e, "Prefix operator '${e.operationReference.text}'")
        }
    }

    private fun KaSession.postfix(e: KtPostfixExpression): LuaExpr {
        val base = e.baseExpression ?: return LuaNil
        return when (e.operationToken) {
            KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
                val target = assignTarget(base) ?: return LuaNil
                val old = ctx.temp("old")
                emit(LuaLocal(listOf(old), listOf(target.read)))
                increment(e, target)
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
    private fun KaSession.ordered(exprs: List<KtExpression>): List<LuaExpr> {
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
    private fun KaSession.call(element: KtExpression, full: KtExpression): LuaExpr {
        val call = element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
            ?: return unsupported(full, "Unresolved call '${full.text}'")
        val symbol = call.partiallyAppliedSymbol.symbol
        val callableId = symbol.callableId?.toString()
        val psi = symbol.psi

        // Library constants such as Int.MAX_VALUE fold to literals; their receiver is not a value.
        if (call !is KaFunctionCall<*> && !StdlibMappings.has(callableId) && full.evaluate() != null) return constant(full)

        val receiverValue = call.partiallyAppliedSymbol.extensionReceiver ?: call.partiallyAppliedSymbol.dispatchReceiver
        val receiverExpr = receiverValue?.let { explicitReceiver(it) }
        val implicit = if (receiverValue != null && receiverExpr == null) {
            implicitReceiver(receiverValue, full) ?: return LuaNil
        } else {
            null
        }
        dataClassMember(call, receiverExpr, implicit)?.let { return it }
        val args = callArguments(call, full)

        if (symbol is KaConstructorSymbol) {
            val cls = symbol.containingClassId?.let(::classInFile)
                ?: return unsupported(full, "Constructing library class '${symbol.containingClassId?.asString()}'")
            return LuaCall(LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi))), ordered(args))
        }

        val inFile = psi != null && psi.containingFile == file
        if (inFile && psi is KtNamedFunction) {
            if (psi.containingClassOrObject == null) {
                if (receiverValue != null) return unsupported(full, "Calling an extension function")
                return LuaCall(LuaName(nameOf(psi)), ordered(args))
            }
            val method = LuaNames.member(psi.name!!)
            if (receiverExpr is KtSuperExpression) {
                // The resolved declaration is the implementation `super` reaches, in a class or interface.
                return LuaCall(LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(method)), listOf(selfRef()) + ordered(args))
            }
            val values = ordered(listOfNotNull(receiverExpr) + args)
            return if (implicit != null) LuaMethodCall(implicit, method, values) else LuaMethodCall(values[0], method, values.drop(1))
        }
        if (inFile && isMemberProperty(psi)) {
            val receiver = when (receiverExpr) {
                null -> implicit ?: return unsupported(full, "Property without receiver")
                is KtSuperExpression -> selfRef() // a field overridden in a subclass shares storage with the base
                else -> expression(receiverExpr)
            }
            return propertyRead(receiver, psi as KtNamedDeclaration)
        }
        val declaringFile = psi?.containingFile as? KtFile
        if (declaringFile != null && declaringFile != file && !declaringFile.isCompiled) {
            return unsupported(full, "Referencing declarations from another file")
        }
        if (receiverExpr is KtSuperExpression) return unsupported(full, "Calling a library member through 'super'")

        val values = ordered(listOfNotNull(receiverExpr) + args)
        val hasExplicit = receiverExpr != null
        val site = CallSite(
            session = this,
            transformer = this@FileTransformer,
            element = full,
            name = symbol.callableId?.callableName?.asString(),
            receiver = implicit ?: if (hasExplicit) values[0] else null,
            receiverType = receiverExpr?.expressionType ?: receiverValue?.type,
            args = if (hasExplicit) values.drop(1) else values,
            argTypes = args.map { it.expressionType },
        )
        StdlibMappings.map(callableId, site)?.let { return it }
        return unsupported(full, "Kotlin library API '${callableId ?: full.text}'")
    }

    /** Argument expressions in parameter order (named arguments are reordered). */
    private fun KaSession.callArguments(call: KaCallableMemberCall<*, *>, element: KtElement): List<KtExpression> {
        if (call !is KaFunctionCall<*>) return emptyList()
        val symbol = call.partiallyAppliedSymbol.symbol
        val bySignature = call.argumentMapping.entries.groupBy({ it.value.symbol }, { it.key })
        val declaredHere = symbol.psi?.containingFile == file
        return symbol.valueParameters.flatMap { p ->
            val mapped = bySignature[p]
            if (mapped == null && declaredHere) unsupported(element, "Omitting an argument with a default value")
            mapped.orEmpty()
        }
    }

    private fun KaSession.explicitReceiver(value: KaReceiverValue): KtExpression? = when (value) {
        is KaExplicitReceiverValue -> value.expression
        is KaSmartCastedReceiverValue -> explicitReceiver(value.original)
        else -> null
    }


    // ---- classes ----

    /** The class or object whose members are being transformed; its instance is `self`. */
    private var currentClass: KtClassOrObject? = null

    private fun selfRef(): LuaExpr = LuaName("self").also { stable += it }

    private inline fun <T> withClass(c: KtClassOrObject, block: () -> T): T {
        val savedClass = currentClass
        val savedLoops = loops
        currentClass = c
        loops = ArrayDeque()
        try {
            return block()
        } finally {
            currentClass = savedClass
            loops = savedLoops
        }
    }

    /** Where a class's table lives: a local, or a field of its enclosing class. Companions live on their class. */
    private fun classRef(c: KtClassOrObject): LuaExpr {
        if (c is KtObjectDeclaration && c.isCompanion()) return classRef(c.containingClassOrObject!!)
        val outer = c.containingClassOrObject
        return if (outer == null) LuaName(nameOf(c)) else LuaIndex(classRef(outer), LuaString(c.name!!))
    }

    private fun classInFile(id: ClassId): KtClassOrObject? {
        var found: KtClassOrObject? = null
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitClassOrObject(classOrObject: KtClassOrObject) {
                if (found == null && classOrObject.getClassId() == id) found = classOrObject
                if (found == null) super.visitClassOrObject(classOrObject)
            }
        })
        return found
    }

    private class SuperInfo(
        val base: KtClassOrObject?,
        val baseCall: KtSuperTypeCallEntry?,
        val interfaces: List<KtClassOrObject>,
        val unsupported: KtSuperTypeListEntry?,
    )

    private val superInfoCache = HashMap<KtClassOrObject, SuperInfo>()

    private fun KaSession.superInfo(c: KtClassOrObject): SuperInfo = superInfoCache.getOrPut(c) {
        var base: KtClassOrObject? = null
        var baseCall: KtSuperTypeCallEntry? = null
        var bad: KtSuperTypeListEntry? = null
        val interfaces = mutableListOf<KtClassOrObject>()
        for (entry in c.superTypeListEntries) {
            val symbol = entry.typeReference?.type?.expandedSymbol
            val psi = symbol?.psi as? KtClassOrObject
            when {
                symbol?.classId?.asString() == "kotlin/Any" -> Unit
                psi == null || psi.containingFile != file -> bad = bad ?: entry
                psi is KtClass && psi.isInterface() -> interfaces += psi
                else -> {
                    base = psi
                    baseCall = entry as? KtSuperTypeCallEntry
                }
            }
        }
        SuperInfo(base, baseCall, interfaces, bad)
    }

    private fun KaSession.classDeclaration(c: KtClassOrObject, isLocal: Boolean) {
        when {
            c is KtEnumEntry || c is KtClass && c.isAnnotation() -> return
            c is KtObjectDeclaration && c.isCompanion() -> return // emitted together with its class
            c is KtClass && c.isInner() -> {
                unsupported(c, "Inner class")
                return
            }
        }
        val info = superInfo(c)
        if (info.unsupported != null) {
            unsupported(info.unsupported, "Extending '${info.unsupported.text}'")
            return
        }
        val ref = classRef(c)
        val classArgs = mutableListOf<LuaExpr>(LuaString(c.name ?: "?"))
        if (info.base != null || info.interfaces.isNotEmpty()) classArgs += info.base?.let(::classRef) ?: LuaNil
        info.interfaces.mapTo(classArgs) { classRef(it) }
        val create = lualibCall("Class", *classArgs.toTypedArray())
        emit(if (isLocal) LuaLocal(listOf(nameOf(c)), listOf(create)) else LuaAssign(listOf(ref), listOf(create)))

        withClass(c) {
            checkMembers(c)
            constructors(c, ref, info)
            members(c, ref)
            if (c is KtClass && c.isData()) dataClassMembers(c, ref)
            if (c is KtClass && c.isEnum() && c.declaredFunction("toString") == null) {
                emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(LuaIndex(selfRef(), LuaString("name"))))))
            }
        }
        if (c is KtClass && c.isEnum()) enumEntries(c, ref)
        c.companionObjects.forEach { companion(it, ref) }
        // Objects are initialized where they are declared (Kotlin initializes them lazily, on first access).
        if (c is KtObjectDeclaration && initNeeded(c)) emit(LuaCallStmt(LuaMethodCall(ref, "____init", emptyList())))
    }

    private fun KtClassOrObject.declaredFunction(name: String) =
        declarations.filterIsInstance<KtNamedFunction>().firstOrNull { it.name == name }

    private fun emitMethod(ref: LuaExpr, name: String, params: List<String>, body: List<LuaStmt>) {
        emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), LuaFunction(params, body), isLocal = false, isMethod = true))
    }

    /** Lua tables hold methods and fields in one namespace, and Kotlin overloads need mangling (not done yet). */
    private fun checkMembers(c: KtClassOrObject) {
        val seen = HashSet<String>()
        for (decl in c.declarations) {
            val name = when (decl) {
                is KtNamedFunction -> decl.name
                is KtProperty -> decl.name
                else -> null
            } ?: continue
            if (decl is KtNamedFunction && (name == "new" || name.startsWith("____"))) {
                ctx.error(decl, "A member named '$name' clashes with the generated Lua class table")
            } else if (!seen.add(name)) {
                ctx.error(decl, "Overloaded or duplicate member '$name' is not supported yet")
            }
        }
    }

    private fun KaSession.members(c: KtClassOrObject, ref: LuaExpr) {
        for (decl in c.declarations) {
            when (decl) {
                is KtNamedFunction -> if (decl.hasBody()) {
                    emit(LuaFunctionDecl(LuaIndex(ref, LuaString(LuaNames.member(decl.name!!))), function(decl), isLocal = false, isMethod = true))
                }
                is KtProperty -> if (hasAccessors(decl)) accessorMethods(decl, ref)
                is KtEnumEntry -> Unit // created by enumEntries()
                is KtClassOrObject -> classDeclaration(decl, isLocal = false)
                else -> Unit // initializers and constructors are handled by constructors()
            }
        }
    }

    // ---- constructors ----

    private fun hasPrimary(c: KtClassOrObject) =
        c !is KtClass || c.primaryConstructor != null || c.secondaryConstructors.isEmpty()

    private val initCache = HashMap<KtClassOrObject, Boolean>()

    /** Whether the primary constructor does anything, i.e. whether `____init` is generated for it. */
    private fun KaSession.initNeeded(c: KtClassOrObject): Boolean = initCache.getOrPut(c) {
        if (c is KtClass && c.isInterface() || !hasPrimary(c)) return@getOrPut false
        val info = superInfo(c)
        val baseCall = info.baseCall
        (c is KtClass && (c.isEnum() || c.primaryConstructorParameters.isNotEmpty())) ||
            c.declarations.any { (it is KtProperty && it.initializer != null) || it is KtAnonymousInitializer } ||
            (baseCall != null && baseCall.valueArguments.isNotEmpty()) ||
            (info.base != null && (!hasPrimary(info.base) || initNeeded(info.base)))
    }

    private fun constructorSuffix(psi: com.intellij.psi.PsiElement?): String {
        if (psi !is KtSecondaryConstructor) return ""
        return (psi.getContainingClassOrObject().secondaryConstructors.indexOf(psi) + 1).toString()
    }

    private fun KaSession.constructors(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo) {
        val isEnum = c is KtClass && c.isEnum()
        val enumParams = if (isEnum) listOf("name", "ordinal") else emptyList()
        if (hasPrimary(c) && initNeeded(c)) {
            val params = (c as? KtClass)?.primaryConstructorParameters.orEmpty()
            params.filter { it.hasDefaultValue() }.forEach { unsupported(it, "Default parameter value") }
            val body = collect {
                if (isEnum) enumParams.forEach { emit(LuaAssign(listOf(LuaIndex(selfRef(), LuaString(it))), listOf(LuaName(it)))) }
                superInit(info.baseCall, info.base)
                for (p in params) {
                    if (p.hasValOrVar()) emit(LuaAssign(listOf(LuaIndex(selfRef(), LuaString(p.name!!))), listOf(LuaName(nameOf(p)))))
                }
                initializers(c)
            }
            emitMethod(ref, "____init", enumParams + params.map { nameOf(it) }, body)
        }
        (c as? KtClass)?.secondaryConstructors?.forEachIndexed { i, ctor ->
            val suffix = (i + 1).toString()
            ctor.valueParameters.filter { it.hasDefaultValue() }.forEach { unsupported(it, "Default parameter value") }
            val params = enumParams + ctor.valueParameters.map { nameOf(it) }
            val body = collect {
                val delegation = ctor.getDelegationCallOrNull()
                if (delegation != null && delegation.isCallToThis) {
                    delegatingInit(delegation, c, enumParams)
                } else {
                    superInit(delegation?.takeIf { it.valueArgumentList != null }, info.base)
                    if (!hasPrimary(c)) initializers(c)
                }
                ctor.bodyExpression?.let { block(it) }
            }
            emitMethod(ref, "____init$suffix", params, body)
            val self = LuaName("self")
            emit(
                LuaFunctionDecl(
                    LuaIndex(ref, LuaString("new$suffix")),
                    LuaFunction(
                        params,
                        listOf(
                            LuaLocal(listOf("self"), listOf(luaCall(LuaName("setmetatable"), LuaTable(emptyList()), ref))),
                            LuaCallStmt(LuaMethodCall(self, "____init$suffix", params.map { LuaName(it) })),
                            LuaReturn(listOf(self)),
                        ),
                    ),
                    isLocal = false,
                ),
            )
        }
    }

    /** Property initializers and `init` blocks, in declaration order. */
    private fun KaSession.initializers(c: KtClassOrObject) {
        for (decl in c.declarations) {
            when (decl) {
                is KtProperty -> decl.initializer?.let { init ->
                    val field = LuaIndex(selfRef(), LuaString(decl.name!!))
                    emitAll(valueInto(init) { listOf(LuaAssign(listOf(field), listOf(it))) })
                }
                is KtAnonymousInitializer -> decl.body?.let { block(it) }
                else -> Unit
            }
        }
    }

    /** Calls the base class constructor that [call] (a super-type entry or `super(...)`) resolves to. */
    private fun KaSession.superInit(call: KtCallElement?, base: KtClassOrObject?) {
        if (base == null) return
        if (call == null) {
            if (initNeeded(base)) emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString("____init")), listOf(selfRef()))))
            return
        }
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
        val suffix = constructorSuffix(resolved.partiallyAppliedSymbol.symbol.psi)
        if (suffix.isEmpty() && !initNeeded(base)) return
        val args = ordered(callArguments(resolved, call))
        emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString("____init$suffix")), listOf(selfRef()) + args)))
    }

    /** `constructor(...) : this(...)`. */
    private fun KaSession.delegatingInit(call: KtConstructorDelegationCall, c: KtClassOrObject, enumParams: List<String>) {
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
        val suffix = constructorSuffix(resolved.partiallyAppliedSymbol.symbol.psi)
        if (suffix.isEmpty() && !initNeeded(c)) return
        val args = enumParams.map { LuaName(it) } + ordered(callArguments(resolved, call))
        emit(LuaCallStmt(LuaMethodCall(selfRef(), "____init$suffix", args)))
    }

    // ---- properties ----

    private fun isMemberProperty(psi: com.intellij.psi.PsiElement?): Boolean =
        (psi is KtProperty && psi.containingClassOrObject != null) ||
            (psi is KtParameter && psi.hasValOrVar() && psi.ownerFunction is KtPrimaryConstructor)

    private fun hasAccessors(p: KtNamedDeclaration) =
        p is KtProperty && (p.getter?.hasBody() == true || p.setter?.hasBody() == true)

    private fun accessorName(prefix: String, p: KtNamedDeclaration) =
        prefix + p.name!!.replaceFirstChar { it.uppercaseChar() }

    private fun propertyRead(receiver: LuaExpr, p: KtNamedDeclaration): LuaExpr =
        if (hasAccessors(p)) LuaMethodCall(receiver, accessorName("get", p), emptyList())
        else LuaIndex(receiver, LuaString(p.name!!))

    private fun propertyWrite(receiver: LuaExpr, p: KtNamedDeclaration, value: LuaExpr): LuaStmt =
        if (hasAccessors(p)) LuaCallStmt(LuaMethodCall(receiver, accessorName("set", p), listOf(value)))
        else LuaAssign(listOf(LuaIndex(receiver, LuaString(p.name!!))), listOf(value))

    /** `field` inside an accessor: the property's storage on `self`. */
    private fun KaSession.backingField(e: KtNameReferenceExpression): LuaExpr {
        val symbol = e.mainReference.resolveToSymbol() as KaBackingFieldSymbol
        return LuaIndex(selfRef(), LuaString(symbol.owningProperty.name.asString()))
    }

    private fun KaSession.accessorMethods(p: KtProperty, ref: LuaExpr) {
        val owner = p.containingClassOrObject
        if (p.hasModifier(KtTokens.OPEN_KEYWORD) || p.hasModifier(KtTokens.OVERRIDE_KEYWORD) ||
            p.hasModifier(KtTokens.ABSTRACT_KEYWORD) || (owner is KtClass && owner.isInterface())
        ) {
            unsupported(p, "Custom accessors on an open or overriding property")
            return
        }
        val field = LuaIndex(selfRef(), LuaString(p.name!!))
        val getter = p.getter?.takeIf { it.hasBody() }
        emitMethod(ref, accessorName("get", p), emptyList(), getter?.let { accessorBody(it) } ?: listOf(LuaReturn(listOf(field))))
        if (p.isVar) {
            val setter = p.setter?.takeIf { it.hasBody() }
            val param = LuaNames.of(setter?.parameter?.name ?: "value")
            emitMethod(
                ref, accessorName("set", p), listOf(param),
                setter?.let { accessorBody(it) } ?: listOf(LuaAssign(listOf(field), listOf(LuaName(param)))),
            )
        }
    }

    private fun KaSession.accessorBody(accessor: KtPropertyAccessor): List<LuaStmt> = collect { functionBody(accessor) }

    // ---- receivers ----

    private fun KaSession.thisRef(e: KtThisExpression): LuaExpr {
        val label = e.getLabelName()
        val current = currentClass ?: return unsupported(e, "'this' outside of a class")
        return if (label == null || label == current.name) selfRef() else unsupported(e, "Labeled 'this'")
    }

    private fun KaSession.implicitReceiverOf(ref: KtNameReferenceExpression): LuaExpr? {
        val call = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val value = call.partiallyAppliedSymbol.dispatchReceiver ?: return null
        return implicitReceiver(value, ref)
    }

    /** The Lua value of an implicit `this`: `self`, or the table of an object or companion. */
    private fun KaSession.implicitReceiver(value: KaReceiverValue, element: KtElement): LuaExpr? {
        val original = (value as? KaSmartCastedReceiverValue)?.original ?: value
        val psi = (original as? KaImplicitReceiverValue)?.symbol?.psi
        return when {
            psi != null && psi == currentClass -> selfRef()
            psi is KtObjectDeclaration && psi.containingFile == file -> classRef(psi)
            else -> {
                unsupported(element, "This implicit receiver")
                null
            }
        }
    }

    // ---- data classes, enums, companions ----

    private fun KaSession.dataClassMembers(c: KtClass, ref: LuaExpr) {
        val props = c.primaryConstructorParameters.filter { it.hasValOrVar() }
        if (c.declaredFunction("toString") == null) {
            val parts = mutableListOf<LuaExpr>()
            props.forEachIndexed { i, p ->
                parts += LuaString((if (i == 0) "${c.name}(" else ", ") + "${p.name}=")
                parts += str(LuaIndex(selfRef(), LuaString(p.name!!)), p.returnType, forConcat = true)
            }
            parts += LuaString(if (props.isEmpty()) "${c.name}()" else ")")
            val merged = parts.fold(mutableListOf<LuaExpr>()) { acc, part ->
                val last = acc.lastOrNull()
                if (last is LuaString && part is LuaString) acc[acc.lastIndex] = LuaString(last.value + part.value) else acc += part
                acc
            }
            emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(merged.reduceRight { a, b -> LuaBinary(LuaBinOp.Concat, a, b) }))))
        }
        if (c.declaredFunction("equals") == null) {
            val other = LuaName("other")
            val checks = listOf<LuaExpr>(LuaBinary(LuaBinOp.Eq, luaCall(LuaName("getmetatable"), other), ref)) +
                props.map { p ->
                    val key = LuaString(p.name!!)
                    equality(LuaIndex(selfRef(), key), p.returnType, LuaIndex(other, key), p.returnType, negated = false)
                }
            emitMethod(ref, "equals", listOf("other"), listOf(LuaReturn(listOf(checks.reduce { a, b -> LuaBinary(LuaBinOp.And, a, b) }))))
        }
    }

    /** Generated members of data classes declared in this file: copy, componentN, toString, equals. */
    private fun KaSession.dataClassMember(call: KaCallableMemberCall<*, *>, receiverExpr: KtExpression?, implicit: LuaExpr?): LuaExpr? {
        val symbol = call.partiallyAppliedSymbol.symbol
        val name = symbol.callableId?.callableName?.asString() ?: return null
        val cls = symbol.callableId?.classId?.let(::classInFile) as? KtClass ?: return null
        if (!cls.isData() || symbol.psi is KtNamedFunction) return null // user-declared members are ordinary methods
        if (name != "copy" && name != "toString" && name != "equals" && !name.matches(Regex("component[0-9]+"))) return null
        val props = cls.primaryConstructorParameters
        val receiver = implicit ?: expression(receiverExpr ?: return null)
        if (name == "toString" || name == "equals") {
            val args = (call as KaFunctionCall<*>).argumentMapping.keys.toList()
            return LuaMethodCall(receiver, name, ordered(args))
        }
        if (name != "copy") return propertyRead(receiver, props[name.removePrefix("component").toInt() - 1])
        val source = cache(receiver, "source")
        val mapping = (call as KaFunctionCall<*>).argumentMapping.entries.toList()
        val provided = mapping.map { it.value.symbol.name.asString() }.zip(ordered(mapping.map { it.key })).toMap()
        val args = props.map { p -> provided[p.name] ?: propertyRead(source, p) }
        return LuaCall(LuaIndex(classRef(cls), LuaString("new")), args)
    }

    private fun KaSession.enumEntries(c: KtClass, ref: LuaExpr) {
        c.declarations.filterIsInstance<KtEnumEntry>().forEachIndexed { ordinal, entry ->
            if (entry.body != null) unsupported(entry, "Enum entry with a body")
            val callEntry = entry.initializerList?.initializers?.firstOrNull() as? KtSuperTypeCallEntry
            val resolved = callEntry?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
            val suffix = constructorSuffix(resolved?.partiallyAppliedSymbol?.symbol?.psi)
            val args = if (resolved != null) ordered(callArguments(resolved, callEntry)) else emptyList()
            val value = LuaCall(LuaIndex(ref, LuaString("new$suffix")), listOf(LuaString(entry.name!!), LuaNumber(ordinal.toString())) + args)
            emit(LuaAssign(listOf(LuaIndex(ref, LuaString(entry.name!!))), listOf(value)))
        }
    }

    /** Companion members live on the class table; their initializers run in `____initCompanion`. */
    private fun KaSession.companion(companion: KtObjectDeclaration, ref: LuaExpr) {
        if (companion.superTypeListEntries.isNotEmpty()) {
            unsupported(companion, "Companion object with supertypes")
            return
        }
        withClass(companion) {
            checkMembers(companion)
            val owner = companion.containingClassOrObject!!
            val instanceNames = owner.declarations.mapNotNull { (it as? KtNamedDeclaration)?.name }.toSet() +
                (owner as? KtClass)?.primaryConstructorParameters?.mapNotNull { it.name }.orEmpty()
            companion.declarations.filterIsInstance<KtNamedDeclaration>().filter { it.name in instanceNames }.forEach {
                ctx.error(it, "Companion member '${it.name}' clashes with an instance member of the same name")
            }
            members(companion, ref)
            val init = collect { initializers(companion) }
            if (init.isNotEmpty()) {
                emitMethod(ref, "____initCompanion", emptyList(), init)
                emit(LuaCallStmt(LuaMethodCall(ref, "____initCompanion", emptyList())))
            }
        }
    }

    // ---- equality and casts ----

    /** Kotlin `==`: identity for primitives, enums and objects; `equals()` when a class may override it. */
    private fun KaSession.equality(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, negated: Boolean): LuaExpr {
        val result = when {
            l is LuaNil || r is LuaNil || lt.isNullLiteral || rt.isNullLiteral -> LuaBinary(LuaBinOp.Eq, l, r)
            !mayOverrideEquals(lt) && !mayOverrideEquals(rt) -> LuaBinary(LuaBinOp.Eq, l, r)
            lt != null && !lt.isMarkedNullable && knownEquals(lt) -> LuaMethodCall(l, "equals", listOf(r))
            else -> lualibCall("Equals", l, r)
        }
        return if (negated) negate(result) else result
    }

    private val KaType?.isNullLiteral get() = this != null && with(session) { isNothingType }

    private fun KaSession.mayOverrideEquals(t: KaType?): Boolean {
        val symbol = t?.expandedSymbol ?: return true
        if (symbol.classId?.asString() in IDENTITY_TYPES) return false
        if (symbol.classKind == KaClassKind.ENUM_CLASS || symbol.classKind.isObject) return false
        val psi = symbol.psi as? KtClassOrObject
        if (psi == null || psi.containingFile != file) return true
        return overridesEquals(psi) || psi.hasModifier(KtTokens.OPEN_KEYWORD) || psi.hasModifier(KtTokens.ABSTRACT_KEYWORD) ||
            psi.hasModifier(KtTokens.SEALED_KEYWORD) || (psi is KtClass && psi.isInterface())
    }

    private fun KaSession.knownEquals(t: KaType): Boolean {
        val psi = t.expandedSymbol?.psi as? KtClassOrObject ?: return false
        return psi.containingFile == file && overridesEquals(psi)
    }

    private fun KaSession.overridesEquals(c: KtClassOrObject): Boolean =
        (c is KtClass && c.isData()) ||
            c.declaredFunction("equals")?.hasModifier(KtTokens.OVERRIDE_KEYWORD) == true ||
            superInfo(c).base?.let { overridesEquals(it) } == true

    private fun KaSession.cast(e: KtBinaryExpressionWithTypeRHS): LuaExpr {
        val type = e.right?.type ?: return LuaNil
        val value = expression(e.left)
        if (e.operationReference.getReferencedNameElementType() != KtTokens.AS_SAFE) return value // unchecked, as in TSTL
        val v = cache(value, "cast")
        if (type.isBooleanType) {
            val name = ctx.temp("cast")
            emit(LuaLocal(listOf(name)))
            emit(LuaIf(typeTest(v, type, e), listOf(LuaAssign(listOf(LuaName(name)), listOf(v)))))
            return LuaName(name)
        }
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, typeTest(v, type, e), v), LuaNil)
    }

    companion object {
        private val ASSIGNMENTS: Set<IElementType> = setOf(
            KtTokens.EQ, KtTokens.PLUSEQ, KtTokens.MINUSEQ, KtTokens.MULTEQ, KtTokens.DIVEQ, KtTokens.PERCEQ,
        )
        private val AUGMENTED: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUSEQ to LuaBinOp.Add, KtTokens.MINUSEQ to LuaBinOp.Sub, KtTokens.MULTEQ to LuaBinOp.Mul,
            KtTokens.DIVEQ to LuaBinOp.Div, KtTokens.PERCEQ to LuaBinOp.Mod,
        )
        private val IDENTITY_TYPES = setOf(
            "kotlin/Int", "kotlin/Long", "kotlin/Short", "kotlin/Byte", "kotlin/Double", "kotlin/Float",
            "kotlin/Boolean", "kotlin/Char", "kotlin/String", "kotlin/Unit", "kotlin/Nothing",
        )
        private val BINARY_OPERATORS: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUS to LuaBinOp.Add, KtTokens.MINUS to LuaBinOp.Sub, KtTokens.MUL to LuaBinOp.Mul,
            KtTokens.DIV to LuaBinOp.Div, KtTokens.PERC to LuaBinOp.Mod,
            KtTokens.EQEQEQ to LuaBinOp.Eq, KtTokens.EXCLEQEQEQ to LuaBinOp.Ne,
            KtTokens.LT to LuaBinOp.Lt, KtTokens.GT to LuaBinOp.Gt, KtTokens.LTEQ to LuaBinOp.Le, KtTokens.GTEQ to LuaBinOp.Ge,
        )
    }
}
