package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotated
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
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaReceiverParameterSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import com.intellij.psi.PsiElement
import com.intellij.psi.tree.IElementType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import com.intellij.psi.util.PsiTreeUtil
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject
import org.jetbrains.kotlin.psi.psiUtil.isPrivate

/**
 * Translates one Kotlin file into a Lua chunk. Expressions may need statements to run before them
 * (e.g. an `if` used as a value); those are emitted into the current statement buffer, see [collect].
 */
class FileTransformer(
    private val session: KaSession,
    private val file: KtFile,
    override val ctx: TransformContext,
    private val module: ModuleContext = ModuleContext.single(file),
) : StatementEmitter() {
    /** `local ____strings = require("util.strings")` for another file of the module. */
    private fun moduleRef(other: KtFile): LuaExpr =
        LuaName(ctx.imports.getOrPut(module.modulePath(other)) { ctx.temp(LuaNames.of(other.name.removeSuffix(".kt"))) })

    /** Exported top-level `var`s live in `____exports` so other files see updates. */
    private val tableMode: Boolean by lazy {
        file in module.cyclic || file.declarations.any { it is KtProperty && it.isVar && !it.isPrivate() }
    }

    private fun isExportedVar(decl: PsiElement?) =
        decl is KtProperty && decl.isTopLevel && decl.isVar && !decl.isPrivate()

    /** A top-level declaration as a Lua value: a local of this file or a field of another file's module. */
    private fun topLevelRef(decl: KtNamedDeclaration): LuaExpr = when {
        decl.containingFile != file -> LuaIndex(moduleRef(decl.containingKtFile), LuaString(naming.of(decl)))
        tableMode && isExportedVar(decl) -> LuaIndex(LuaName(EXPORTS), LuaString(naming.of(decl)))
        else -> LuaName(naming.of(decl))
    }

    private val interop = LuaInterop(session, ctx)
    private val classes = ClassHierarchy(session, file, module)
    private val naming = DeclarationNames(session, classes)

    private val target get() = ctx.options.luaTarget

    fun unsupported(element: KtElement, what: String): LuaExpr {
        ctx.error(element, "$what is not supported yet")
        return LuaNil
    }

    // ---- file ----

    fun transformFile(): LuaChunk = with(session) { transformChunk() }

    private fun KaSession.transformChunk(): LuaChunk {
        val body = mutableListOf<LuaStmt>()
        val topLevel = file.declarations.filter {
            (it is KtNamedFunction || it is KtProperty || (it is KtClassOrObject && !(it is KtClass && it.isAnnotation()))) &&
                !interop.isExternalDeclaration(it)
        }
        val forward = forwardReferenced(topLevel.filterNot { tableMode && isExportedVar(it) }.toSet())
        val main = topLevel.filterIsInstance<KtNamedFunction>().firstOrNull(::isMain)
        val exported = topLevel.filter { !it.isPrivate() && it != main }
        if (tableMode) {
            body += LuaLocal(listOf(EXPORTS), listOf(LuaTable(emptyList())))
            if (file in module.cyclic) {
                // Files that require each other see this table, filled in as declarations run.
                body += assign(LuaIndex(luaPath("package", "loaded"), LuaString(module.modulePath(file))), LuaName(EXPORTS))
            }
        }
        // Requires go after the exports table is registered, so an import cycle finds it in package.loaded.
        val requiresAt = body.size
        if (forward.isNotEmpty()) body += LuaLocal(forward.map { naming.of(it as KtNamedDeclaration) })

        // A class must be created after the classes and interfaces it extends, wherever they are declared.
        val emitted = HashSet<KtDeclaration>()
        fun emitDeclaration(decl: KtDeclaration) {
            if (!emitted.add(decl)) return
            if (decl is KtClassOrObject) {
                classes.superInfo(decl).let { listOfNotNull(it.base) + it.interfaces }
                    .filter { it.isTopLevel() && it.containingFile == file }.forEach { emitDeclaration(it) }
            }
            body += collect { topLevelDeclaration(decl, decl in forward) }
            // In an import cycle, other files may run before this one finishes, so export as we go.
            if (file in module.cyclic && decl in exported && !isExportedVar(decl)) body += exportStatement(decl)
        }
        file.declarations.forEach { emitDeclaration(it) }
        if (tableMode && file !in module.cyclic) {
            exported.filterNot { isExportedVar(it) }.forEach { body += exportStatement(it) }
        }

        if (main != null && file !in module.imported) body += mainInvocation(main)

        val requires = ctx.imports.map { (path, name) -> LuaLocal(listOf(name), listOf(luaCall(LuaName("require"), LuaString(path)))) }
        body.addAll(requiresAt, requires)
        exportsReturn(exported)?.let { body += it }
        return LuaChunk(body)
    }

    /** Runs `main`, passing the command-line arguments as a table when it takes them. */
    private fun mainInvocation(main: KtNamedFunction): LuaStmt {
        val args = if (main.valueParameters.isEmpty()) emptyList() else listOf(LuaTable(listOf(LuaField.Positional(LuaName("...")))))
        return LuaCallStmt(LuaCall(LuaName(naming.of(main)), args))
    }

    /** The chunk's `return`: the exports table, or a table of the [exported] declarations when not in table mode. */
    private fun exportsReturn(exported: List<KtDeclaration>): LuaStmt? = when {
        tableMode -> LuaReturn(listOf(LuaName(EXPORTS)))
        exported.isNotEmpty() ->
            LuaReturn(listOf(LuaTable(exported.map { naming.of(it as KtNamedDeclaration).let { n -> LuaField.Named(n, LuaName(n)) } })))
        else -> null
    }

    private fun exportStatement(decl: KtDeclaration): LuaStmt {
        val name = naming.of(decl as KtNamedDeclaration)
        return assign(LuaIndex(LuaName(EXPORTS), LuaString(name)), LuaName(name))
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
        if (interop.isExternalDeclaration(decl)) return // implemented in Lua
        when (decl) {
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(naming.of(decl)), function(decl), isLocal = !forwardDeclared))
            is KtProperty -> if (tableMode && isExportedVar(decl)) {
                val field = topLevelRef(decl)
                decl.initializer?.let { init -> emitAll(valueInto(init) { listOf(assign(field, it)) }) }
            } else {
                property(decl, isLocal = !forwardDeclared)
            }
            is KtClassOrObject -> classDeclaration(decl, isLocal = !forwardDeclared)
            is KtTypeAlias -> Unit
            else -> unsupported(decl, "Declaration '${decl.javaClass.simpleName.removePrefix("Kt")}'")
        }
    }

    // ---- functions ----

    private var loops = ArrayDeque<LoopFrame>()

    private var frames = ArrayDeque<FunctionFrame>()

    private inline fun <T> inFrame(frame: FunctionFrame, block: () -> T): T {
        val savedLoops = loops
        if (frame.kind != FunctionFrame.Kind.Inline) loops = ArrayDeque()
        frames.addLast(frame)
        try {
            return block()
        } finally {
            frames.removeLast()
            loops = savedLoops
        }
    }

    /** Lua values for receivers that aren't a class's `self`: extension functions and lambdas with receivers. */
    private val receiverBindings = HashMap<PsiElement, LuaExpr>()

    /** Lambda parameters of inlined lambdas, keyed by (function literal, parameter name). */
    private val lambdaBindings = HashMap<Pair<PsiElement, String>, LuaExpr>()

    /** A name for a receiver parameter; `self` unless that would hide a class instance or another receiver. */
    private fun receiverName(): String {
        val selfTaken = currentClass != null || receiverBindings.values.any { it is LuaName && it.name == "self" }
        return if (selfTaken) ctx.temp("this") else "self"
    }

    private fun KaSession.function(fn: KtNamedFunction): LuaFunction {
        if (fn.hasModifier(KtTokens.SUSPEND_KEYWORD)) unsupported(fn, "suspend function (coroutines)")
        val params = mutableListOf<String>()
        if (fn.receiverTypeReference != null) {
            if (fn.containingClassOrObject != null) unsupported(fn, "Extension function declared in a class")
            val name = receiverName()
            receiverBindings[fn] = LuaName(name).also { stable += it }
            params += name
        }
        val vararg = fn.valueParameters.firstOrNull { it.isVarArg }
        if (vararg != null && vararg != fn.valueParameters.last()) unsupported(vararg, "A vararg parameter that is not last")
        fn.valueParameters.filter { !it.isVarArg }.mapTo(params) { naming.of(it) }
        val labels = setOfNotNull(fn.name)
        return inFrame(FunctionFrame(FunctionFrame.Kind.Function, labels)) {
            LuaFunction(params, collect {
                // vararg xs: Int arrives as Lua varargs and is packed into an Array.
                if (vararg != null) emit(LuaLocal(listOf(naming.of(vararg)), listOf(LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))))))
                defaultArguments(fn.valueParameters)
                functionBody(fn)
            }, isVararg = vararg != null)
        }
    }

    /** Callee-side defaults: `if x == nil then x = <default> end`. Callers pass nil for omitted arguments. */
    private fun KaSession.defaultArguments(params: List<KtParameter>) {
        for (p in params) {
            val default = p.defaultValue ?: continue
            val name = LuaName(naming.of(p))
            emit(LuaIf(LuaBinary(LuaBinOp.Eq, name, LuaNil), valueInto(default) { listOf(assign(name, it)) }))
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
            is KtDestructuringDeclaration -> {
                val init = e.initializer ?: return
                val initType = init.expressionType?.expandedSymbol?.classId?.asString()
                if (initType != null && initType.startsWith("dev/k2l/lua/LuaMultiReturn")) {
                    // A Lua function returning several values: local ok, err = pcall(f)
                    emit(LuaLocal(e.entries.map { naming.entry(it) }, listOf(expression(init))))
                    return
                }
                val value = cache(expression(init), "destructured")
                emit(destructure(e.entries, value))
            }
            is KtClassOrObject -> classDeclaration(e, isLocal = true)
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(naming.of(e)), function(e), isLocal = true))
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
            is KtThrowExpression -> throwStatement(e)
            is KtTryExpression -> tryInto(e, sink = null)
            is KtSafeQualifiedExpression -> safeCallStatement(e)
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
        if (p.receiverTypeReference != null) {
            unsupported(p, "Extension property")
            return
        }
        if (p.getter != null || p.setter != null) unsupported(p, "Top-level or local property accessor")
        val name = naming.of(p)
        val init = p.initializer
        when {
            init == null -> if (isLocal) emit(LuaLocal(listOf(name)))
            isLocal && needsBranching(init) -> {
                emit(LuaLocal(listOf(name)))
                emitAll(valueInto(init) { listOf(assign(name, it)) })
            }
            isLocal -> emit(LuaLocal(listOf(name), listOf(expression(init))))
            else -> emitAll(valueInto(init) { listOf(assign(name, it)) })
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
            // `list += x` calls plusAssign; `readOnly += x` is `readOnly = readOnly + x`.
            val callee = e.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()?.partiallyAppliedSymbol?.symbol
            val name = callee?.callableId?.callableName?.asString()
            if (name != null && name.endsWith("Assign")) {
                val value = call(e, e)
                if (value is LuaCall || value is LuaMethodCall) emit(LuaCallStmt(value))
            } else {
                emit(target.write(call(e, e)))
            }
            return
        }
        val value = operator(op, target.read, leftType, expression(right), right.expressionType, e)
        emit(target.write(value))
    }

    private fun KaSession.assignTarget(e: KtExpression): Target? {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        if (ex is KtArrayAccessExpression) return indexTarget(ex)
        val ref = when (ex) {
            is KtNameReferenceExpression -> ex
            is KtDotQualifiedExpression -> ex.selectorExpression as? KtNameReferenceExpression
            else -> null
        }
        val receiverExpr = (ex as? KtDotQualifiedExpression)?.receiverExpression
        if (ref != null && receiverExpr == null && ref.mainReference.resolveToSymbol() is KaBackingFieldSymbol) {
            val field = backingField(ref)
            return Target(field) { assign(field, it) }
        }
        val decl = ref?.mainReference?.resolve()
        if (ref == null || decl == null || !classes.isSource(decl)) {
            unsupported(e, "Assignment to this target")
            return null
        }
        if (decl is KtProperty && decl.containingClassOrObject == null) {
            val name = if (decl.isTopLevel) topLevelRef(decl) else LuaName(naming.of(decl))
            return Target(name) { assign(name, it) }
        }
        if (!isMemberProperty(decl)) {
            unsupported(e, "Assignment to this target")
            return null
        }
        val receiver = if (receiverExpr != null) cache(expression(receiverExpr), "object") else implicitReceiverOf(ref) ?: return null
        val property = decl as KtNamedDeclaration
        return Target(propertyRead(receiver, property)) { propertyWrite(receiver, property, it) }
    }

    /** `xs[i] = v`, `map[k] = v`, or a user `operator fun set`. */
    private fun KaSession.indexTarget(e: KtArrayAccessExpression): Target? {
        val arrayExpr = e.arrayExpression ?: return null
        val indexExpr = e.indexExpressions.singleOrNull() ?: return unsupported(e, "Multi-index access").let { null }
        val type = arrayExpr.expressionType
        val values = ordered(listOf(arrayExpr, indexExpr))
        val receiver = cache(values[0], "object")
        val key = cache(values[1], "key")
        val userClass = type?.expandedSymbol?.psi as? KtClassOrObject
        return when {
            userClass != null && classes.isSource(userClass) -> {
                val get = userClass.declaredFunction("get")
                val set = userClass.declaredFunction("set")
                if (get == null || set == null) return unsupported(e, "Index assignment without operator get/set").let { null }
                Target(LuaMethodCall(receiver, naming.function(get), listOf(key))) {
                    LuaCallStmt(LuaMethodCall(receiver, naming.function(set), listOf(key, it)))
                }
            }
            type?.collectionKind() == CollectionKind.Map ->
                Target(LuaMethodCall(receiver, "get", listOf(key))) { LuaCallStmt(LuaMethodCall(receiver, "set", listOf(key, it))) }
            type?.collectionKind() == CollectionKind.LuaTable -> {
                val slot = LuaIndex(receiver, key)
                Target(slot) { assign(slot, it) }
            }
            type?.collectionKind()?.isIndexable == true -> {
                val slot = CollectionMappings.index(receiver, key)
                Target(slot) { assign(slot, it) }
            }
            else -> unsupported(e, "Index assignment on '${type.pretty()}'").let { null }
        }
    }

    private fun KaSession.increment(e: KtUnaryExpression, target: Target) {
        val op = if (e.operationToken == KtTokens.PLUSPLUS) LuaBinOp.Add else LuaBinOp.Sub
        emit(target.write(LuaBinary(op, target.read, LuaNumber("1"))))
    }

    private fun KaSession.returnStatement(e: KtReturnExpression) {
        val label = e.getLabelName()
        val target = if (label == null) frames.lastOrNull { it.kind == FunctionFrame.Kind.Function }
        else frames.lastOrNull { label in it.labels }
        if (target == null) {
            unsupported(e, "This return")
            return
        }
        val value = e.returnedExpression
        if (target.kind == FunctionFrame.Kind.Inline) {
            val sink = target.sink
            if (value != null) {
                if (sink != null) emitAll(valueInto(value, sink)) else statement(value)
            }
            val end = target.endLabel ?: ctx.temp("inline_end").also { target.endLabel = it }
            emit(LuaGoto(end))
            return
        }
        if (target !== frames.last { it.kind != FunctionFrame.Kind.Inline }) {
            unsupported(e, "Non-local return out of a lambda")
            return
        }
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

    private fun KaSession.loopBody(frame: LoopFrame, body: KtExpression?): List<LuaStmt> {
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

    private fun KaSession.forLoop(e: KtForExpression, frame: LoopFrame) {
        val rangeExpr = e.loopRange ?: return
        val param = e.loopParameter ?: return
        val range = parseRange(rangeExpr)
        if (range != null) rangeLoop(e, frame, rangeExpr, param, range) else iterationLoop(e, frame, rangeExpr, param)
    }

    /** `for (i in a..b)`, `until`, `downTo` and `step` become a numeric `for`. */
    private fun KaSession.rangeLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter, range: KRange) {
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
    private fun KaSession.iterationLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter) {
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
    private fun KaSession.indicesLoop(e: KtForExpression, frame: LoopFrame, param: KtParameter, receiver: KtExpression) {
        val list = expression(receiver)
        val last = lastIndex(list)
        emit(LuaNumericFor(naming.of(param), LuaNumber("0"), last, null, loopBody(frame, e.body)))
    }

    /** `for ((i, x) in xs.withIndex())` */
    private fun KaSession.withIndexLoop(e: KtForExpression, frame: LoopFrame, destructuring: KtDestructuringDeclaration, receiver: KtExpression) {
        val list = cache(expression(receiver), "list")
        val (indexEntry, valueEntry) = destructuring.entries
        val index = if (indexEntry.name == "_") ctx.temp("i") else naming.of(indexEntry)
        val value = LuaLocal(listOf(naming.of(valueEntry)), listOf(CollectionMappings.index(list, LuaName(index))))
        val last = lastIndex(list)
        emit(LuaNumericFor(index, LuaNumber("0"), last, null, listOf(value) + loopBody(frame, e.body)))
    }

    private fun KaSession.mapLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter) {
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

    private fun KaSession.collectionLoop(e: KtForExpression, frame: LoopFrame, rangeExpr: KtExpression, param: KtParameter, kind: CollectionKind) {
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
    private fun KaSession.destructure(entries: List<KtDestructuringDeclarationEntry>, value: LuaExpr): LuaStmt {
        val names = mutableListOf<String>()
        val values = mutableListOf<LuaExpr>()
        entries.forEachIndexed { i, entry ->
            if (entry.name == "_") return@forEachIndexed
            names += naming.of(entry)
            values += component(entry, value, i + 1)
        }
        return LuaLocal(names, values)
    }

    private fun KaSession.component(entry: KtDestructuringDeclarationEntry, value: LuaExpr, n: Int): LuaExpr {
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
    private fun asList(kind: CollectionKind?, collection: LuaExpr): LuaExpr =
        if (kind?.isIndexable == true) collection else LuaMethodCall(collection, "toList", emptyList())

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

    private fun KaSession.continueStatement(e: KtContinueExpression) {
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
    private fun innerFrames(outer: LoopFrame): List<LoopFrame> = loops.toList().takeLastWhile { it !== outer }.reversed()

    // ---- ranges ----

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

    // ---- branching values ----

    private fun KaSession.needsBranching(e: KtExpression): Boolean {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        return ex is KtWhenExpression || ex is KtTryExpression || (ex is KtIfExpression && !canTernary(ex))
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
            ex is KtTryExpression -> tryInto(ex, sink)
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
        return !isJump(orElse) && listOf(cond, then, orElse).none { mayNeedStatements(it) }
    }

    private fun KaSession.ternary(e: KtIfExpression): LuaExpr {
        val parts = listOf(e.condition!!, singleExpression(e.then!!)!!, singleExpression(e.`else`!!)!!).map { expression(it) }
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, parts[0], parts[1]), parts[2])
    }

    private fun KaSession.mayNeedStatements(e: KtExpression): Boolean {
        var found = false
        e.accept(object : KtTreeVisitorVoid() {
            override fun visitElement(element: PsiElement) {
                if (found) return
                if (element is KtIfExpression || element is KtWhenExpression || element is KtTryExpression ||
                    element is KtSafeQualifiedExpression || element is KtLambdaExpression ||
                    (element is KtBinaryExpression && element.operationToken == KtTokens.ELVIS) ||
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
        emitAll(valueInto(e) { listOf(assign(name, it)) })
        return LuaName(name)
    }

    // ---- when ----

    private fun KaSession.whenInto(e: KtWhenExpression, sink: ((LuaExpr) -> List<LuaStmt>)?) {
        val subjectVar = e.subjectVariable
        val subjectExpr = e.subjectExpression
        val subject: LuaExpr? = when {
            subjectVar != null -> {
                val name = naming.of(subjectVar)
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
            type.isIntegral || type.isDoubleType || type.isFloatType -> {
                val wantInteger = type.isIntegral
                if (target.hasIntegers) {
                    return LuaBinary(LuaBinOp.Eq, luaCall(luaPath("math", "type"), value), LuaString(if (wantInteger) "integer" else "float"))
                }
                // Without an integer subtype, an Int is an integral number (so 2.0 is Int and Double).
                val isNumber = LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString("number"))
                return if (wantInteger) LuaBinary(LuaBinOp.And, isNumber, LuaBinary(LuaBinOp.Eq, LuaBinary(LuaBinOp.Mod, value, LuaNumber("1")), LuaNumber("0")))
                else isNumber
            }
            else -> {
                val symbol = type.expandedSymbol
                val psi = symbol?.psi as? KtClassOrObject
                return when {
                    symbol?.classId?.asString() == "kotlin/Any" -> LuaBinary(LuaBinOp.Ne, value, LuaNil)
                    type.collectionKind()?.let(LIBRARY_COLLECTION_CLASSES::get) != null -> {
                        val luaClass = LIBRARY_COLLECTION_CLASSES.getValue(type.collectionKind()!!)
                        lualibCall("InstanceOf", value, lualibRef(featureOf(luaClass), luaClass))
                    }
                    symbol?.classId?.asString() in LIBRARY_CLASSES ->
                        lualibCall("InstanceOf", value, lualibRef(EXCEPTIONS_FEATURE, LIBRARY_CLASSES.getValue(symbol!!.classId!!.asString())))
                    psi == null || !classes.isSource(psi) -> unsupported(element, "Type check against '${type.pretty()}'")
                    psi is KtObjectDeclaration -> LuaBinary(LuaBinOp.Eq, value, classRef(psi))
                    else -> lualibCall("InstanceOf", value, classRef(psi))
                }
            }
        }
        return LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString(luaType))
    }

    // ---- expressions ----

    /** `*array` arguments, expanded with table.unpack. */
    private val spreads = HashSet<KtExpression>()

    /** Values substituted for receiver expressions, e.g. the cached receiver of `a?.b`. */
    private val overrides = HashMap<KtExpression, LuaExpr>()

    fun KaSession.expression(e: KtExpression): LuaExpr = overrides[e] ?: when (e) {
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
        is KtWhenExpression, is KtTryExpression -> branchingValue(e)
        is KtThisExpression -> thisRef(e)
        is KtLambdaExpression -> lambda(e)
        is KtLabeledExpression -> e.baseExpression?.let { expression(it) } ?: LuaNil
        is KtNamedFunction -> function(e) // anonymous function
        is KtCallableReferenceExpression -> callableReference(e)
        is KtArrayAccessExpression -> call(e, e)
        is KtSafeQualifiedExpression -> safeCall(e)
        is KtThrowExpression -> {
            throwStatement(e)
            LuaNil
        }
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
                // At runtime 2.0 and 2 look the same without integers, so use the static type.
                !target.hasIntegers && (type.withoutFlexibility.isDoubleType || type.withoutFlexibility.isFloatType) ->
                    return lualibCall("DoubleToString", value)
                // tostring() keeps only 14 digits of a large Long when numbers are doubles.
                !target.hasIntegers && type.withoutFlexibility.isLongType -> return lualibCall("Str", value)
                type.isStringType || type.isCharType -> return value
                type.isIntegral -> return if (forConcat) value else luaCall(LuaName("tostring"), value)
                type.isBooleanType -> return luaCall(LuaName("tostring"), value)
            }
        }
        return lualibCall("Str", value)
    }

    fun lualibCall(feature: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(lualibRef(feature, Lualib.functionName(feature)), args.toList())

    private fun KaSession.reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr {
        val symbol = e.mainReference.resolveToSymbol()
        val psi = symbol?.psi
        return when {
            interop.isExternal(symbol) && symbol !is KaClassLikeSymbol -> call(e, full)
            symbol is KaValueParameterSymbol && lambdaBindings.isNotEmpty() &&
                symbol.containingDeclaration?.psi?.let { lambdaBindings[it to symbol.name.asString()] } != null ->
                lambdaBindings.getValue(symbol.containingDeclaration!!.psi!! to symbol.name.asString())
            symbol is KaLocalVariableSymbol || symbol is KaValueParameterSymbol -> {
                val name = LuaName(LuaNames.of(symbol.name.asString()))
                if (symbol is KaValueParameterSymbol || (symbol as KaLocalVariableSymbol).isVal) stable += name
                name
            }
            symbol is KaPropertySymbol && psi is KtProperty && classes.isSource(psi) && psi.isTopLevel -> topLevelRef(psi)
            symbol is KaBackingFieldSymbol -> backingField(e)
            symbol is KaEnumEntrySymbol && psi is KtEnumEntry && classes.isSource(psi) ->
                LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(psi.name!!))
            symbol is KaClassLikeSymbol && interop.isExternal(symbol) -> interop.externalClassRef(symbol as KaClassSymbol) ?: LuaName("_G")
            symbol is KaClassLikeSymbol && psi is KtClassOrObject && classes.isSource(psi) -> classRef(psi)
            else -> call(e, full)
        }
    }

    private fun KaSession.binary(e: KtBinaryExpression): LuaExpr {
        val token = e.operationToken
        val left = e.left ?: return LuaNil
        val right = e.right ?: return LuaNil
        return when (token) {
            KtTokens.ELVIS -> elvis(left, right)
            KtTokens.ANDAND -> shortCircuit(LuaBinOp.And, expression(left)) { expression(right) }
            KtTokens.OROR -> shortCircuit(LuaBinOp.Or, expression(left)) { expression(right) }
            KtTokens.IN_KEYWORD, KtTokens.NOT_IN -> {
                val range = parseRange(right)
                val contains = if (range != null) rangeContains(expression(left), range, e) else call(e, e)
                if (token == KtTokens.NOT_IN) negate(contains) else contains
            }
            KtTokens.RANGE, KtTokens.RANGE_UNTIL -> call(e, e)
            KtTokens.IDENTIFIER -> call(e, e)
            KtTokens.EQEQ, KtTokens.EXCLEQ -> {
                val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
                equality(l, left.expressionType, r, right.expressionType, negated = token == KtTokens.EXCLEQ)
            }
            in BINARY_OPERATORS -> {
                if (token in ARITHMETIC && !isPrimitiveOperand(left.expressionType)) return call(e, e) // operator fun plus etc.
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
        emit(LuaIf(test, pre + assign(name, r)))
        return LuaName(name)
    }

    /**
     * A Kotlin operator applied to primitive/String operands. [op] is the Lua operator the Kotlin token
     * maps to; division and remainder get Kotlin's truncating semantics.
     */
    private fun KaSession.operator(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, element: KtElement): LuaExpr {
        val numeric = lt != null && rt != null && lt.isNumber && rt.isNumber
        if (lt?.isCharType == true && !lt.isMarkedNullable && (op == LuaBinOp.Add || op == LuaBinOp.Sub)) {
            // Chars are one-character strings: 'c' - 'a' is an Int, 'a' + 1 is a Char.
            val code = LuaMethodCall(l, "byte", emptyList())
            return if (rt?.isCharType == true) LuaBinary(LuaBinOp.Sub, code, LuaMethodCall(r, "byte", emptyList()))
            else luaCall(luaPath("string", "char"), LuaBinary(op, code, r))
        }
        return when (op) {
            LuaBinOp.Add -> when {
                lt?.isStringType == true -> LuaBinary(LuaBinOp.Concat, l, str(r, rt, forConcat = true))
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'+' on '${lt.pretty()}'")
            }
            LuaBinOp.Sub, LuaBinOp.Mul -> if (numeric) LuaBinary(op, l, r) else unsupported(element, "Arithmetic on '${lt.pretty()}'")
            LuaBinOp.Div -> when {
                numeric && lt.isIntegral && rt.isIntegral -> lualibCall("IDiv", l, r)
                numeric -> LuaBinary(op, l, r)
                else -> unsupported(element, "'/' on '${lt.pretty()}'")
            }
            LuaBinOp.Mod -> if (numeric) luaCall(luaPath("math", "fmod"), l, r) else unsupported(element, "'%' on '${lt.pretty()}'")
            LuaBinOp.Eq, LuaBinOp.Ne -> LuaBinary(op, l, r)
            LuaBinOp.Lt, LuaBinOp.Gt, LuaBinOp.Le, LuaBinOp.Ge ->
                if (numeric || (lt.isTextual && rt.isTextual)) LuaBinary(op, l, r)
                else LuaBinary(op, lualibCall("Compare", l, r), LuaNumber("0")) // Comparable.compareTo
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
            KtTokens.EXCLEXCL -> lualibCall("NotNull", expression(base))
            else -> unsupported(e, "Postfix operator '${e.operationReference.text}'")
        }
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

        val pas = call.partiallyAppliedSymbol
        if (symbol.callableId?.callableName?.asString() == "invoke" && pas.dispatchReceiver?.type is KaFunctionType) {
            return invokeFunctionValue(call, full)
        }

        val receiverValue = pas.extensionReceiver ?: pas.dispatchReceiver
        val receiverExpr = receiverValue?.let { explicitReceiver(it) }
        val implicit = if (receiverValue != null && receiverExpr == null) {
            implicitReceiver(receiverValue, full) ?: return LuaNil
        } else {
            null
        }
        if (interop.isExternal(symbol)) return externalCall(call, receiverExpr, implicit, full)
        dataClassMember(call, receiverExpr, implicit)?.let { return it }
        scopeFunction(callableId, call, receiverExpr, implicit, full)?.let { return it }
        val args = callArguments(call, full)

        if (symbol is KaConstructorSymbol) return constructorCall(symbol, psi, args, full)

        val inFile = classes.isSource(psi)
        if (inFile && psi is KtNamedFunction) return sourceFunctionCall(psi, args, receiverExpr, implicit)
        if (inFile && isMemberProperty(psi)) return memberPropertyRead(psi as KtNamedDeclaration, receiverExpr, implicit, full)
        if (inFile && psi is KtProperty && psi.receiverTypeReference != null) return unsupported(full, "Extension property")
        if (receiverExpr is KtSuperExpression) return unsupported(full, "Calling a library member through 'super'")
        return libraryCall(symbol.callableId?.callableName?.asString(), callableId, receiverExpr, implicit, receiverValue?.type, args, full)
    }

    /** Invoking a function value: the value is the dispatch receiver; a receiver of `T.() -> R` is the first argument. */
    private fun KaSession.invokeFunctionValue(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr {
        val pas = call.partiallyAppliedSymbol
        val fnValue = receiverExpression(pas.dispatchReceiver!!, full) ?: return LuaNil
        val extension = pas.extensionReceiver?.let { receiverExpression(it, full) ?: return LuaNil }
        val args = callArguments(call, full)
        val values = arguments(listOf(fnValue) + listOfNotNull(extension), args)
        return LuaCall(values[0], values.drop(1))
    }

    /** A constructor of a class in this program, a library exception, or a mapped collection class. */
    private fun KaSession.constructorCall(
        symbol: KaConstructorSymbol,
        psi: com.intellij.psi.PsiElement?,
        args: List<KtExpression?>,
        full: KtExpression,
    ): LuaExpr {
        val classId = symbol.containingClassId
        classId?.let(classes::classInFile)?.let { cls ->
            return LuaCall(LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi))), arguments(emptyList(), args))
        }
        LIBRARY_CLASSES[classId?.asString()]?.let { lua ->
            return LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, lua), LuaString("new")), throwableArguments(args))
        }
        val site = CallSite(this, this@FileTransformer, full, null, null, null, arguments(emptyList(), args), args.map { it?.expressionType })
        return CollectionMappings.construct(classId?.asString(), site)
            ?: unsupported(full, "Constructing library class '${classId?.asString()}'")
    }

    /** A top-level or extension function, or a method (including `super.method()`), declared in this program. */
    private fun KaSession.sourceFunctionCall(
        psi: KtNamedFunction,
        args: List<KtExpression?>,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
    ): LuaExpr {
        if (psi.containingClassOrObject == null) {
            // Extension functions take their receiver as the first argument.
            val receivers = if (psi.receiverTypeReference != null) listOf(implicit ?: receiverExpr ?: return LuaNil) else emptyList()
            val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
            return LuaCall(fn, arguments(receivers, args))
        }
        val method = naming.function(psi)
        if (receiverExpr is KtSuperExpression) {
            // The resolved declaration is the implementation `super` reaches, in a class or interface.
            return LuaCall(LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(method)), listOf(selfRef()) + arguments(emptyList(), args))
        }
        val values = arguments(listOf(implicit ?: receiverExpr!!), args)
        return LuaMethodCall(values[0], method, values.drop(1))
    }

    private fun KaSession.memberPropertyRead(
        property: KtNamedDeclaration,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        full: KtExpression,
    ): LuaExpr {
        val receiver = when (receiverExpr) {
            null -> implicit ?: return unsupported(full, "Property without receiver")
            is KtSuperExpression -> selfRef() // a field overridden in a subclass shares storage with the base
            else -> expression(receiverExpr)
        }
        return propertyRead(receiver, property)
    }

    /** A Kotlin standard library call, translated through [StdlibMappings]. */
    private fun KaSession.libraryCall(
        name: String?,
        callableId: String?,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        receiverValueType: KaType?,
        args: List<KtExpression?>,
        full: KtExpression,
    ): LuaExpr {
        val values = arguments(listOfNotNull<Any>(implicit ?: receiverExpr), args)
        val hasReceiver = implicit != null || receiverExpr != null
        val site = CallSite(
            session = this,
            transformer = this@FileTransformer,
            element = full,
            name = name,
            receiver = if (hasReceiver) values[0] else null,
            receiverType = receiverExpr?.expressionType ?: receiverValueType,
            args = (if (hasReceiver) values.drop(1) else values).let { a -> a + List(maxOf(0, args.size - a.size)) { LuaNil } },
            argTypes = args.map { it?.expressionType },
        )
        StdlibMappings.map(callableId, site)?.let { return it }
        return unsupported(full, "Kotlin library API '${callableId ?: full.text}'")
    }

    /** A receiver as a Lua value: either an explicit expression (transformed later, in order) or an implicit `this`. */
    private fun KaSession.receiverExpression(value: KaReceiverValue, element: KtElement): Any? =
        explicitReceiver(value) ?: implicitReceiver(value, element)

    /**
     * Transforms [receivers] (KtExpressions or ready LuaExprs) and then [args] in source order. Omitted
     * arguments become nil so later ones keep their position; trailing omitted ones are dropped.
     */
    private fun KaSession.arguments(receivers: List<Any>, args: List<KtExpression?>): List<LuaExpr> {
        val exprs = (receivers + args).filterIsInstance<KtExpression>()
        val transformed = ordered(exprs).iterator()
        val values = (receivers + args).map { item ->
            when (item) {
                is KtExpression -> transformed.next().let { if (item in spreads) lualibCall("Unpack", it) else it }
                is LuaExpr -> item
                else -> null // omitted
            }
        }
        return values.dropLastWhile { it == null }.map { it ?: LuaNil }
    }

    /**
     * Argument expressions in parameter order (named arguments are reordered); null where an argument is
     * omitted and the parameter's default applies.
     */
    private fun KaSession.callArguments(call: KaCallableMemberCall<*, *>, element: KtElement): List<KtExpression?> {
        if (call !is KaFunctionCall<*>) return emptyList()
        val symbol = call.partiallyAppliedSymbol.symbol
        val bySignature = call.argumentMapping.entries.groupBy({ it.value.symbol }, { it.key })
        val result = mutableListOf<KtExpression?>()
        for (p in symbol.valueParameters) {
            val mapped = bySignature[p]
            if (p.isVararg) {
                mapped?.forEach { arg ->
                    if ((arg.parent as? KtValueArgument)?.getSpreadElement() != null) {
                        if (arg != call.argumentMapping.keys.last()) unsupported(arg, "A spread argument that is not last")
                        spreads += arg
                    }
                    result += arg
                }
                continue
            }
            val arg = mapped?.singleOrNull()
            result += arg
            // nil means "use the default", so a nullable argument for a nullable parameter is ambiguous.
            val decl = p.psi as? KtParameter
            if (arg != null && decl?.hasDefaultValue() == true && classes.isSource(decl) &&
                arg.expressionType?.isMarkedNullable == true && (decl.defaultValue as? KtConstantExpression)?.text != "null"
            ) {
                ctx.error(arg, "Passing a nullable value for '${decl.name}', which has a default, is ambiguous in Lua (nil selects the default)")
            }
        }
        return result.dropLastWhile { it == null }
    }

    /** Arguments of a library exception constructor, as (message, cause). */
    private fun KaSession.throwableArguments(args: List<KtExpression?>): List<LuaExpr> {
        val present = args.filterNotNull()
        val values = ordered(present)
        var message: LuaExpr = LuaNil
        var cause: LuaExpr = LuaNil
        present.zip(values).forEach { (expr, value) ->
            val type = expr.expressionType
            if (type != null && (type.isStringType || type.isNothingType)) message = value else cause = value
        }
        return if (cause == LuaNil) listOfNotNull(message.takeIf { it != LuaNil }) else listOf(message, cause)
    }

    fun lualibRef(feature: String, name: String): LuaExpr {
        ctx.lualib += feature
        ctx.lualibNames += name
        return LuaName(name)
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
        return when {
            outer != null -> LuaIndex(classRef(outer), LuaString(c.name!!))
            c.isTopLevel() -> topLevelRef(c)
            else -> LuaName(naming.of(c)) // local class
        }
    }

    private fun KaSession.classDeclaration(c: KtClassOrObject, isLocal: Boolean) {
        if (interop.isExternalDeclaration(c)) return
        when {
            c is KtEnumEntry || c is KtClass && c.isAnnotation() -> return
            c is KtObjectDeclaration && c.isCompanion() -> return // emitted together with its class
            c is KtClass && c.isInner() -> {
                unsupported(c, "Inner class")
                return
            }
        }
        val info = classes.superInfo(c)
        if (info.unsupported != null) {
            unsupported(info.unsupported, "Extending '${info.unsupported.text}'")
            return
        }
        val ref = classRef(c)
        val classArgs = mutableListOf<LuaExpr>(LuaString(c.name ?: "?"))
        val baseRef = info.base?.let(::classRef) ?: info.libraryBase?.let { lualibRef(EXCEPTIONS_FEATURE, it) }
        if (baseRef != null || info.interfaces.isNotEmpty()) classArgs += baseRef ?: LuaNil
        info.interfaces.mapTo(classArgs) { classRef(it) }
        val create = lualibCall("Class", *classArgs.toTypedArray())
        emit(if (isLocal) LuaLocal(listOf(naming.of(c)), listOf(create)) else assign(ref, create))

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
        if (c is KtObjectDeclaration && classes.initNeeded(c)) emit(LuaCallStmt(LuaMethodCall(ref, INIT, emptyList())))
    }

    private fun emitMethod(ref: LuaExpr, name: String, params: List<String>, body: List<LuaStmt>) {
        emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), LuaFunction(params, body), isLocal = false, isMethod = true))
    }

    /** Lua tables hold methods and fields in one namespace. */
    private fun checkMembers(c: KtClassOrObject) {
        val fields = (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }?.mapNotNull { it.name }.orEmpty().toMutableSet()
        c.declarations.filterIsInstance<KtProperty>().mapNotNullTo(fields) { it.name }
        for (decl in c.declarations.filterIsInstance<KtNamedFunction>()) {
            val name = naming.function(decl)
            when {
                name == "new" || name.startsWith("____") ->
                    ctx.error(decl, "A member named '${decl.name}' clashes with the generated Lua class table")
                name in fields -> ctx.error(decl, "A function and a property both named '$name' would share one Lua field")
            }
        }
        // Overloads inherited along different paths can end up with the same Lua name.
        val roots = classes.hierarchy(c).flatMap { k -> k.declarations.filterIsInstance<KtNamedFunction>().filter { !it.hasModifier(KtTokens.OVERRIDE_KEYWORD) } }
        roots.groupBy { naming.function(it) }.filterValues { it.size > 1 }.forEach { (name, fns) ->
            if (fns.any { it.containingClassOrObject == c }) {
                ctx.error(fns.last(), "Overloads of '$name' inherited from different supertypes clash in Lua")
            }
        }
    }

    private fun KaSession.members(c: KtClassOrObject, ref: LuaExpr) {
        for (decl in c.declarations) {
            when (decl) {
                is KtNamedFunction -> if (decl.hasBody()) {
                    emit(LuaFunctionDecl(LuaIndex(ref, LuaString(naming.function(decl))), function(decl), isLocal = false, isMethod = true))
                }
                is KtProperty -> if (hasAccessors(decl)) accessorMethods(decl, ref)
                is KtEnumEntry -> Unit // created by enumEntries()
                is KtClassOrObject -> classDeclaration(decl, isLocal = false)
                else -> Unit // initializers and constructors are handled by constructors()
            }
        }
    }

    // ---- constructors ----

    private fun constructorSuffix(psi: PsiElement?): String {
        if (psi !is KtSecondaryConstructor) return ""
        return (psi.getContainingClassOrObject().secondaryConstructors.indexOf(psi) + 1).toString()
    }

    private fun KaSession.constructors(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo) {
        val isEnum = c is KtClass && c.isEnum()
        val enumParams = if (isEnum) listOf("name", "ordinal") else emptyList()
        if (hasPrimary(c) && classes.initNeeded(c)) {
            val params = (c as? KtClass)?.primaryConstructorParameters.orEmpty()
            val body = collect {
                defaultArguments(params)
                if (isEnum) enumParams.forEach { emit(assign(LuaIndex(selfRef(), LuaString(it)), LuaName(it))) }
                superInit(info.baseCall, info.base, info.libraryBase)
                for (p in params) {
                    if (p.hasValOrVar()) emit(assign(LuaIndex(selfRef(), LuaString(p.name!!)), LuaName(naming.of(p))))
                }
                initializers(c)
            }
            emitMethod(ref, INIT, enumParams + params.map { naming.of(it) }, body)
        }
        (c as? KtClass)?.secondaryConstructors?.forEachIndexed { i, ctor ->
            val suffix = (i + 1).toString()
            val params = enumParams + ctor.valueParameters.map { naming.of(it) }
            val body = collect {
                defaultArguments(ctor.valueParameters)
                val delegation = ctor.getDelegationCallOrNull()
                if (delegation != null && delegation.isCallToThis) {
                    delegatingInit(delegation, c, enumParams)
                } else {
                    superInit(delegation?.takeIf { it.valueArgumentList != null }, info.base, info.libraryBase)
                    if (!hasPrimary(c)) initializers(c)
                }
                ctor.bodyExpression?.let { block(it) }
            }
            emitMethod(ref, "$INIT$suffix", params, body)
            val self = LuaName("self")
            emit(
                LuaFunctionDecl(
                    LuaIndex(ref, LuaString("new$suffix")),
                    LuaFunction(
                        params,
                        listOf(
                            LuaLocal(listOf("self"), listOf(luaCall(LuaName("setmetatable"), LuaTable(emptyList()), ref))),
                            LuaCallStmt(LuaMethodCall(self, "$INIT$suffix", params.map { LuaName(it) })),
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
                    emitAll(valueInto(init) { listOf(assign(field, it)) })
                }
                is KtAnonymousInitializer -> decl.body?.let { block(it) }
                else -> Unit
            }
        }
    }

    /** Calls the base class constructor that [call] (a super-type entry or `super(...)`) resolves to. */
    private fun KaSession.superInit(call: KtCallElement?, base: KtClassOrObject?, libraryBase: String? = null) {
        if (libraryBase != null) {
            val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
            val args = resolved?.let { throwableArguments(callArguments(it, call)) }.orEmpty()
            emit(LuaCallStmt(LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, libraryBase), LuaString(INIT)), listOf(selfRef()) + args)))
            return
        }
        if (base == null) return
        if (call == null) {
            if (classes.initNeeded(base)) emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString(INIT)), listOf(selfRef()))))
            return
        }
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
        val suffix = constructorSuffix(resolved.partiallyAppliedSymbol.symbol.psi)
        if (suffix.isEmpty() && !classes.initNeeded(base)) return
        val args = arguments(emptyList(), callArguments(resolved, call))
        emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString("$INIT$suffix")), listOf(selfRef()) + args)))
    }

    /** `constructor(...) : this(...)`. */
    private fun KaSession.delegatingInit(call: KtConstructorDelegationCall, c: KtClassOrObject, enumParams: List<String>) {
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
        val suffix = constructorSuffix(resolved.partiallyAppliedSymbol.symbol.psi)
        if (suffix.isEmpty() && !classes.initNeeded(c)) return
        val args = arguments(enumParams.map { LuaName(it) }, callArguments(resolved, call))
        emit(LuaCallStmt(LuaMethodCall(selfRef(), "$INIT$suffix", args)))
    }

    // ---- properties ----

    private fun isMemberProperty(psi: PsiElement?): Boolean =
        (psi is KtProperty && psi.containingClassOrObject != null) ||
            (psi is KtParameter && psi.hasValOrVar() && psi.ownerFunction is KtPrimaryConstructor)

    private fun hasAccessors(p: KtNamedDeclaration) =
        p is KtProperty && !interop.isExternalDeclaration(p) && (p.getter?.hasBody() == true || p.setter?.hasBody() == true)

    private fun accessorName(prefix: String, p: KtNamedDeclaration) =
        prefix + p.name!!.replaceFirstChar { it.uppercaseChar() }

    private fun propertyRead(receiver: LuaExpr, p: KtNamedDeclaration): LuaExpr =
        if (hasAccessors(p)) LuaMethodCall(receiver, accessorName("get", p), emptyList())
        else LuaIndex(receiver, LuaString(p.name!!))

    private fun propertyWrite(receiver: LuaExpr, p: KtNamedDeclaration, value: LuaExpr): LuaStmt =
        if (hasAccessors(p)) LuaCallStmt(LuaMethodCall(receiver, accessorName("set", p), listOf(value)))
        else assign(LuaIndex(receiver, LuaString(p.name!!)), value)

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
                setter?.let { accessorBody(it) } ?: listOf(assign(field, LuaName(param))),
            )
        }
    }

    private fun KaSession.accessorBody(accessor: KtPropertyAccessor): List<LuaStmt> = collect { functionBody(accessor) }

    // ---- receivers ----

    private fun KaSession.thisRef(e: KtThisExpression): LuaExpr =
        receiverValue(e.instanceReference.mainReference.resolveToSymbol(), e) ?: LuaNil

    private fun KaSession.implicitReceiverOf(ref: KtNameReferenceExpression): LuaExpr? {
        val call = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val value = call.partiallyAppliedSymbol.dispatchReceiver ?: return null
        return implicitReceiver(value, ref)
    }

    /** The Lua value of an implicit `this`. */
    private fun KaSession.implicitReceiver(value: KaReceiverValue, element: KtElement): LuaExpr? {
        val original = (value as? KaSmartCastedReceiverValue)?.original ?: value
        return receiverValue((original as? KaImplicitReceiverValue)?.symbol, element)
    }

    /**
     * What a `this` symbol is in Lua: `self` for the class being transformed, the table of an object or
     * companion, or the receiver parameter of an extension function or lambda.
     */
    private fun KaSession.receiverValue(symbol: KaSymbol?, element: KtElement): LuaExpr? {
        val psi = if (symbol is KaReceiverParameterSymbol) symbol.owningCallableSymbol.psi else symbol?.psi
        receiverBindings[psi]?.let { return it }
        return when {
            psi != null && psi == currentClass -> selfRef()
            psi is KtObjectDeclaration && classes.isSource(psi) -> classRef(psi)
            else -> {
                unsupported(element, "This receiver")
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
        if (c.declaredFunction("hashCode") == null) {
            // result = 31 * result + field.hashCode(), as the Kotlin compiler generates.
            val hash = props.map { p -> lualibCall("Hash", LuaIndex(selfRef(), LuaString(p.name!!))) }
                .reduceOrNull { acc, h -> lualibCall("ToInt32", LuaBinary(LuaBinOp.Add, LuaBinary(LuaBinOp.Mul, LuaNumber("31"), acc), h)) }
                ?: LuaNumber("0")
            emitMethod(ref, "hashCode", emptyList(), listOf(LuaReturn(listOf(hash))))
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
        val cls = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass ?: return null
        if (!cls.isData() || symbol.psi is KtNamedFunction) return null // user-declared members are ordinary methods
        if (name != "copy" && name != "toString" && name != "equals" && name != "hashCode" && !name.matches(Regex("component[0-9]+"))) return null
        val props = cls.primaryConstructorParameters
        val receiver = implicit ?: expression(receiverExpr ?: return null)
        if (name == "toString" || name == "equals" || name == "hashCode") {
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
            val args = if (resolved != null) arguments(emptyList(), callArguments(resolved, callEntry)) else emptyList()
            val value = LuaCall(LuaIndex(ref, LuaString("new$suffix")), listOf(LuaString(entry.name!!), LuaNumber(ordinal.toString())) + args)
            emit(assign(LuaIndex(ref, LuaString(entry.name!!)), value))
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
                emitMethod(ref, INIT_COMPANION, emptyList(), init)
                emit(LuaCallStmt(LuaMethodCall(ref, INIT_COMPANION, emptyList())))
            }
        }
    }

    // ---- lambdas and function references ----

    /** Labels a `return@label` can use to leave [e]: an explicit `label@{}` or the name of the call it is passed to. */
    private fun lambdaLabels(e: KtLambdaExpression): Set<String> {
        val labels = mutableSetOf<String>()
        (e.parent as? KtLabeledExpression)?.getLabelName()?.let { labels += it }
        val call = generateSequence(e.parent) { it.parent }.take(4).filterIsInstance<KtCallExpression>().firstOrNull()
        (call?.calleeExpression as? KtNameReferenceExpression)?.getReferencedName()?.let { labels += it }
        return labels
    }

    private fun KaSession.lambda(e: KtLambdaExpression): LuaExpr {
        val literal = e.functionLiteral
        val type = e.expressionType as? KaFunctionType
        val params = mutableListOf<String>()
        if (type?.hasReceiver == true) {
            val name = receiverName()
            receiverBindings[literal] = LuaName(name).also { stable += it }
            params += name
        }
        val prologue = mutableListOf<LuaStmt>()
        for (p in literal.valueParameters) {
            val destructuring = p.destructuringDeclaration
            if (destructuring != null) {
                val name = ctx.temp("destructured")
                params += name
                prologue += destructure(destructuring.entries, LuaName(name))
            } else {
                params += naming.of(p)
            }
        }
        if (literal.valueParameters.isEmpty() && type?.parameterTypes?.size == 1) params += "it"
        val returnsValue = type?.returnType?.let { !it.isUnitType } ?: true
        val body = inFrame(FunctionFrame(FunctionFrame.Kind.Lambda, lambdaLabels(e))) {
            prologue + collect { lambdaBody(literal, if (returnsValue) ({ listOf(LuaReturn(listOf(it))) }) else null) }
        }
        return LuaFunction(params, body)
    }

    /** Statements of a lambda; the last expression goes to [sink] (null = the lambda returns Unit). */
    private fun KaSession.lambdaBody(literal: KtFunctionLiteral, sink: ((LuaExpr) -> List<LuaStmt>)?) {
        val statements = literal.bodyExpression?.statements.orEmpty()
        statements.dropLast(1).forEach { statement(it) }
        val last = statements.lastOrNull() ?: return
        if (sink == null || last is KtDeclaration) statement(last) else emitAll(valueInto(last, sink))
    }

    /**
     * Inlines a lambda passed to an inline function such as `let`: its parameters are bound to [args]
     * and its result goes to [sink]. Anything else (a function reference, a variable) is called instead.
     */
    private fun KaSession.inlineLambda(
        lambdaExpr: KtExpression,
        args: List<LuaExpr>,
        receiver: LuaExpr?,
        sink: ((LuaExpr) -> List<LuaStmt>)?,
    ) {
        val lambda = KtPsiUtil.safeDeparenthesize(lambdaExpr).let { (it as? KtLabeledExpression)?.baseExpression ?: it } as? KtLambdaExpression
        if (lambda == null) {
            val call = LuaCall(expression(lambdaExpr), listOfNotNull(receiver) + args)
            if (sink != null) emitAll(sink(call)) else emit(LuaCallStmt(call))
            return
        }
        val literal = lambda.functionLiteral
        val names = literal.valueParameters.map { it.name ?: "_" }.ifEmpty { if (args.isNotEmpty()) listOf("it") else emptyList() }
        val frame = FunctionFrame(FunctionFrame.Kind.Inline, lambdaLabels(lambda)).also { it.sink = sink }
        val body = collect {
            literal.valueParameters.zip(args).forEach { (p, value) ->
                p.destructuringDeclaration?.let { emit(destructure(it.entries, cache(value, "destructured"))) }
            }
            // Parameters bound to stable values are substituted; others get a local named like the parameter.
            names.zip(args).forEach { (name, value) ->
                lambdaBindings[literal to name] = if (isStable(value)) value else {
                    emit(LuaLocal(listOf(LuaNames.of(name)), listOf(value)))
                    LuaName(LuaNames.of(name)).also { stable += it }
                }
            }
            if (receiver != null) receiverBindings[literal] = receiver
            inFrame(frame) { lambdaBody(literal, sink) }
        }
        val end = frame.endLabel
        if (end != null && !target.hasGoto) {
            // No goto on Lua 5.1: `return@label` breaks out of a one-iteration repeat.
            val rewritten = body.mapStatements { s, depth ->
                if (s is LuaGoto) {
                    if (s.label == end && depth == 0) LuaBreak else s.also {
                        ctx.error(lambda, "return@label from inside a loop in an inlined lambda needs goto (Lua 5.1)")
                    }
                } else {
                    s
                }
            }
            emit(LuaRepeat(rewritten, LuaBool(true)))
            return
        }
        val needsBlock = end != null || body.any { it is LuaLocal || it is LuaFunctionDecl }
        if (needsBlock) emit(LuaDo(body + listOfNotNull(end?.let(::LuaLabel)))) else emitAll(body)
    }

    /** Inline-lambda result as a value: a temp assigned inside the inlined body. */
    private fun KaSession.inlineValue(lambdaExpr: KtExpression, args: List<LuaExpr>, receiver: LuaExpr?): LuaExpr {
        val single = (KtPsiUtil.safeDeparenthesize(lambdaExpr) as? KtLambdaExpression)?.bodyExpression?.statements?.singleOrNull()
        if (single != null && single !is KtDeclaration && !mayNeedStatements(single) && args.all(::isStable) &&
            PsiTreeUtil.findChildOfType(lambdaExpr, KtReturnExpression::class.java) == null
        ) {
            // `x.let { it + 1 }` becomes `x + 1`.
            var result: LuaExpr = LuaNil
            inlineLambda(lambdaExpr, args, receiver) { listOf(LuaCallStmt(it.also { v -> result = v })) }
            buffer.removeLastOrNull()
            return result
        }
        val name = ctx.temp("result")
        emit(LuaLocal(listOf(name)))
        inlineLambda(lambdaExpr, args, receiver) { listOf(assign(name, it)) }
        return LuaName(name)
    }

    private fun KaSession.lambdaReturnsUnit(e: KtExpression): Boolean =
        (e.expressionType as? KaFunctionType)?.returnType?.isUnitType == true

    private fun symbol(call: KaCallableMemberCall<*, *>) = call.partiallyAppliedSymbol.symbol

    /** Kotlin's inline scope functions and preconditions, expanded in place. */
    private fun KaSession.scopeFunction(
        callableId: String?,
        call: KaCallableMemberCall<*, *>,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        element: KtExpression,
    ): LuaExpr? {
        if (callableId == null || call !is KaFunctionCall<*>) return null
        // forEach resolves to Kotlin's inline extension or, for (k, v) lambdas, to java.util.Map.forEach.
        val simpleName = symbol(call).callableId?.callableName?.asString()
        val effectiveId = if (simpleName == "forEach" && (callableId.startsWith("kotlin/") || callableId.startsWith("java/"))) {
            "kotlin/collections/forEach"
        } else {
            callableId
        }
        if (effectiveId !in SCOPE_FUNCTIONS) return null
        val args = callArguments(call, element)
        val receiver = (implicit ?: receiverExpr?.let { expression(it) })
        fun lambdaArg(i: Int) = args.getOrNull(i)
        return when (effectiveId) {
            "kotlin/let" -> inlineValue(lambdaArg(0)!!, listOf(cache(receiver!!, "value")), null)
            "kotlin/also" -> cache(receiver!!, "value").also { inlineLambda(lambdaArg(0)!!, listOf(it), null, null) }
            "kotlin/apply" -> cache(receiver!!, "value").also { inlineLambda(lambdaArg(0)!!, emptyList(), it, null) }
            "kotlin/run" -> if (receiver != null) {
                runInline(lambdaArg(0)!!, cache(receiver, "value"))
            } else {
                runInline(lambdaArg(0)!!, null)
            }
            "kotlin/with" -> {
                val target = cache(expression(lambdaArg(0)!!), "value")
                runInline(lambdaArg(1)!!, target)
            }
            "kotlin/takeIf", "kotlin/takeUnless" -> {
                val value = cache(receiver!!, "value")
                val cond = inlineValue(lambdaArg(0)!!, listOf(value), null)
                val test = if (callableId == "kotlin/takeIf") cond else negate(cond)
                if (receiverExpr?.expressionType?.isBooleanType == true) {
                    val name = ctx.temp("result")
                    emit(LuaLocal(listOf(name)))
                    emit(LuaIf(test, listOf(assign(name, value))))
                    LuaName(name)
                } else {
                    LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, test, value), LuaNil)
                }
            }
            "kotlin/repeat" -> {
                val times = arguments(emptyList(), listOf(lambdaArg(0)))[0]
                val lambda = lambdaArg(1)!!
                val index = (KtPsiUtil.safeDeparenthesize(lambda) as? KtLambdaExpression)?.functionLiteral?.valueParameters
                    ?.singleOrNull()?.name ?: "it"
                val body = collect { inlineLambda(lambda, listOf(LuaName(LuaNames.of(index)).also { stable += it }), null, null) }
                emit(LuaNumericFor(LuaNames.of(index), LuaNumber("0"), plusConstant(times, -1), null, body))
                LuaNil
            }
            "kotlin/require", "kotlin/check" -> {
                val cond = arguments(emptyList(), listOf(lambdaArg(0)))[0]
                val (exception, default) = PRECONDITION_FAILURES.getValue(effectiveId)
                failUnless(negate(cond), exception, default, lambdaArg(1))
                LuaNil
            }
            "kotlin/requireNotNull", "kotlin/checkNotNull" -> {
                val value = cache(arguments(emptyList(), listOf(lambdaArg(0)))[0], "value")
                val (exception, default) = PRECONDITION_FAILURES.getValue(effectiveId)
                failUnless(LuaBinary(LuaBinOp.Eq, value, LuaNil), exception, default, lambdaArg(1))
                value
            }
            "kotlin/error" -> {
                val message = arguments(emptyList(), listOf(lambdaArg(0)))[0]
                emit(throwNew(ILLEGAL_STATE_EXCEPTION, str(message, lambdaArg(0)?.expressionType)))
                LuaNil
            }
            "kotlin/text/buildString" -> {
                val builder = cache(LuaCall(LuaIndex(lualibRef("Strings", "__K2L_StringBuilder"), LuaString("new")), emptyList()), "builder")
                inlineLambda(lambdaArg(0)!!, emptyList(), builder, null)
                LuaMethodCall(builder, "toString", emptyList())
            }
            "kotlin/collections/forEach", "kotlin/sequences/forEach", "java/lang/Iterable.forEach", "java/util/Map.forEach",
            "kotlin/text/forEach" -> {
                forEachLoop(receiver!!, receiverExpr?.expressionType ?: call.partiallyAppliedSymbol.dispatchReceiver?.type, lambdaArg(0)!!, indexed = false)
                LuaNil
            }
            "kotlin/collections/forEachIndexed" -> {
                forEachLoop(receiver!!, receiverExpr?.expressionType, lambdaArg(0)!!, indexed = true)
                LuaNil
            }
            "kotlin/TODO" -> {
                val reason = lambdaArg(0)?.let { expression(it) }
                val message = if (reason == null) LuaString("An operation is not implemented.")
                else LuaBinary(LuaBinOp.Concat, LuaString("An operation is not implemented: "), reason)
                emit(throwNew(NOT_IMPLEMENTED_ERROR, message))
                LuaNil
            }
            else -> null
        }
    }

    /** `xs.forEach { ... }` as a loop with the lambda inlined, so `return` and `return@forEach` work. */
    private fun KaSession.forEachLoop(collection: LuaExpr, type: KaType?, lambda: KtExpression, indexed: Boolean) {
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

    private fun KaSession.runInline(lambda: KtExpression, receiver: LuaExpr?): LuaExpr =
        if (lambdaReturnsUnit(lambda)) {
            inlineLambda(lambda, emptyList(), receiver, null)
            LuaNil
        } else {
            inlineValue(lambda, emptyList(), receiver)
        }

    /** `if <failed> then error(Exception.new(message)) end`, with the message from an optional lazy lambda. */
    private fun KaSession.failUnless(failed: LuaExpr, exception: String, default: String, lazyMessage: KtExpression?) {
        val body = collect {
            val message = if (lazyMessage == null) LuaString(default) else {
                val value = inlineValue(lazyMessage, emptyList(), null)
                val last = (KtPsiUtil.safeDeparenthesize(lazyMessage) as? KtLambdaExpression)?.bodyExpression?.statements?.lastOrNull()
                str(value, last?.expressionType ?: (lazyMessage.expressionType as? KaFunctionType)?.returnType)
            }
            emit(throwNew(exception, message))
        }
        emit(LuaIf(failed, body))
    }

    private fun throwNew(exception: String, message: LuaExpr): LuaStmt =
        LuaCallStmt(luaCall(LuaName("error"), LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, exception), LuaString("new")), listOf(message))))

    private fun KaSession.callableReference(e: KtCallableReferenceExpression): LuaExpr {
        val symbol = e.callableReference.mainReference.resolveToSymbol()
        val psi = symbol?.psi
        val receiverExpr = e.receiverExpression
        return when {
            symbol is KaConstructorSymbol -> {
                val cls = symbol.containingClassId?.let(classes::classInFile) ?: return unsupported(e, "Reference to a library constructor")
                LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi)))
            }
            psi is KtNamedFunction && classes.isSource(psi) && psi.containingClassOrObject == null -> {
                val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
                if (receiverExpr != null && psi.receiverTypeReference == null) unsupported(e, "Bound function reference")
                // An extension function already takes its receiver first, so `String::shout` is just `shout`.
                if (receiverExpr != null && isBoundReference(e)) {
                    val target = cache(expression(receiverExpr), "receiver")
                    LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(fn, listOf(target, LuaName("...")))))), isVararg = true)
                } else {
                    fn
                }
            }
            psi is KtNamedFunction && classes.isSource(psi) -> {
                val method = naming.function(psi)
                if (receiverExpr != null && isBoundReference(e)) {
                    // obj::method
                    val target = cache(expression(receiverExpr), "receiver")
                    LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaMethodCall(target, method, listOf(LuaName("...")))))), isVararg = true)
                } else {
                    // Class::method takes the instance first.
                    val self = LuaName("self")
                    LuaFunction(listOf("self"), listOf(LuaReturn(listOf(LuaMethodCall(self, method, listOf(LuaName("...")))))), isVararg = true)
                }
            }
            else -> unsupported(e, "This callable reference")
        }
    }

    /** `obj::f` is bound to a value; `Type::f` is not. */
    private fun KaSession.isBoundReference(e: KtCallableReferenceExpression): Boolean {
        val receiver = e.receiverExpression ?: return false
        val ref = (receiver as? KtNameReferenceExpression)
            ?: (receiver as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
            ?: return true
        return ref.mainReference.resolveToSymbol() !is KaClassLikeSymbol
    }

    // ---- null safety ----

    /** `a?.b`: `a and a.b`, or an `if a ~= nil` block when the access needs statements or `a` may be false. */
    private fun KaSession.safeCall(e: KtSafeQualifiedExpression): LuaExpr {
        val receiver = cache(expression(e.receiverExpression), "receiver")
        val (value, pre) = withPreceding { withOverride(e.receiverExpression, receiver) { selector(e) } }
        if (pre.isEmpty() && e.receiverExpression.expressionType?.isBooleanType != true) {
            return LuaBinary(LuaBinOp.And, receiver, value)
        }
        val name = ctx.temp("result")
        emit(LuaLocal(listOf(name)))
        emit(LuaIf(LuaBinary(LuaBinOp.Ne, receiver, LuaNil), pre + assign(name, value)))
        return LuaName(name)
    }

    private fun KaSession.safeCallStatement(e: KtSafeQualifiedExpression) {
        val receiver = cache(expression(e.receiverExpression), "receiver")
        val body = collect {
            val value = withOverride(e.receiverExpression, receiver) { selector(e) }
            if (value is LuaCall || value is LuaMethodCall) emit(LuaCallStmt(value))
        }
        emit(LuaIf(LuaBinary(LuaBinOp.Ne, receiver, LuaNil), body))
    }

    private fun KaSession.selector(e: KtQualifiedExpression): LuaExpr = when (val selector = e.selectorExpression) {
        is KtCallExpression -> call(selector, e)
        is KtNameReferenceExpression -> reference(selector, e)
        else -> unsupported(e, "This qualified expression")
    }

    private inline fun <T> withOverride(e: KtExpression, value: LuaExpr, block: () -> T): T {
        overrides[e] = value
        try {
            return block()
        } finally {
            overrides.remove(e)
        }
    }

    /** `a ?: b`: `a or b` unless `a` may be false or `b` needs statements; `a ?: return` becomes an `if`. */
    private fun KaSession.elvis(left: KtExpression, right: KtExpression): LuaExpr {
        val l = expression(left)
        if (isJump(KtPsiUtil.safeDeparenthesize(right))) {
            val value = cache(l, "value")
            emit(LuaIf(LuaBinary(LuaBinOp.Eq, value, LuaNil), collect { statement(KtPsiUtil.safeDeparenthesize(right)) }))
            return value
        }
        val (r, pre) = withPreceding { expression(right) }
        if (pre.isEmpty() && left.expressionType?.isBooleanType != true) return LuaBinary(LuaBinOp.Or, l, r)
        val name = ctx.temp("value")
        emit(LuaLocal(listOf(name), listOf(l)))
        emit(LuaIf(LuaBinary(LuaBinOp.Eq, LuaName(name), LuaNil), pre + assign(name, r)))
        return LuaName(name)
    }

    // ---- exceptions ----

    private fun KaSession.throwStatement(e: KtThrowExpression) {
        val thrown = e.thrownExpression ?: return
        emit(LuaCallStmt(luaCall(LuaName("error"), expression(thrown))))
    }

    /**
     * try/catch/finally via pcall. The try (and, with finally, the catch) blocks become functions, so a
     * Kotlin `return` inside them becomes `return true, value` and is re-issued after the pcall.
     */
    private fun KaSession.tryInto(e: KtTryExpression, sink: ((LuaExpr) -> List<LuaStmt>)?) {
        val ok = ctx.temp("ok")
        val result = ctx.temp("result")
        val returned = ctx.temp("returned")
        var hasReturn = false
        fun tryFunction(stmts: List<LuaStmt>, element: KtElement): LuaExpr {
            val (rewritten, returns) = rewriteReturns(stmts, element)
            hasReturn = hasReturn || returns
            return luaCall(LuaName("pcall"), LuaFunction(emptyList(), rewritten))
        }
        fun branch(body: KtExpression) = if (sink != null) valueInto(body, sink) else collect { block(body) }
        fun resultNames() = if (hasReturn) listOf(ok, result, returned) else listOf(ok, result)

        val tryBlock = e.tryBlock
        val tryCall = tryFunction(branch(tryBlock), tryBlock)
        val finally = e.finallyBlock?.finalExpression
        val dispatch = catchDispatch(e.catchClauses, result, ::branch)
        if (finally == null) {
            val names = resultNames()
            emit(LuaLocal(names, listOf(tryCall)))
            val onSuccess = listOf(LuaIf(LuaName(result), listOf(LuaReturn(listOf(LuaName(returned))))))
            if (hasReturn) emit(LuaIf(LuaName(ok), onSuccess, dispatch)) else emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), dispatch))
        } else {
            val catchCall = if (e.catchClauses.isNotEmpty()) tryFunction(dispatch, e) else null
            val names = resultNames()
            emit(LuaLocal(names, listOf(tryCall)))
            if (catchCall != null) {
                emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaAssign(names.map { LuaName(it) }, listOf(catchCall)))))
            }
            emitAll(collect { block(finally) })
            emit(LuaIf(LuaUnary(LuaUnOp.Not, LuaName(ok)), listOf(LuaCallStmt(luaCall(LuaName("error"), LuaName(result), LuaNumber("0"))))))
            if (hasReturn) emit(LuaIf(LuaName(result), listOf(LuaReturn(listOf(LuaName(returned))))))
        }
    }

    /** Picks the first catch clause matching the error in [result], or rethrows it. */
    private fun KaSession.catchDispatch(
        catches: List<KtCatchClause>,
        result: String,
        branch: (KtExpression) -> List<LuaStmt>,
    ): List<LuaStmt> {
        val errorName = ctx.temp("error")
        return collect {
            emit(LuaLocal(listOf(errorName), listOf(lualibCall("ToThrowable", LuaName(result)))))
            var tail: List<LuaStmt> = listOf(LuaCallStmt(luaCall(LuaName("error"), LuaName(errorName), LuaNumber("0"))))
            for (clause in catches.reversed()) {
                val param = clause.catchParameter ?: continue
                val type = param.typeReference?.type ?: continue
                val body = listOf(LuaLocal(listOf(naming.of(param)), listOf(LuaName(errorName)))) + (clause.catchBody?.let(branch).orEmpty())
                val catchesAll = type.expandedSymbol?.classId?.asString() in setOf("java/lang/Throwable", "kotlin/Throwable")
                tail = if (catchesAll) body else listOf(LuaIf(typeTest(LuaName(errorName), type, clause), body, tail))
            }
            emitAll(tail)
        }
    }

    /** Rewrites `return x` into `return true, x` outside nested functions; reports jumps that would leave the function. */
    private fun rewriteReturns(stmts: List<LuaStmt>, element: KtElement): Pair<List<LuaStmt>, Boolean> {
        var found = false
        val labels = mutableSetOf<String>()
        stmts.forEachLeafStatement { if (it is LuaLabel) labels += it.label }
        val rewritten = stmts.mapStatements { s, depth ->
            when (s) {
                is LuaReturn -> {
                    found = true
                    LuaReturn(listOf(LuaBool(true)) + s.values.ifEmpty { listOf(LuaNil) })
                }
                LuaBreak -> {
                    if (depth == 0) ctx.error(element, "break out of a try block is not supported yet")
                    s
                }
                is LuaGoto -> {
                    if (s.label !in labels) ctx.error(element, "Jumping out of a try block is not supported yet")
                    s
                }
                else -> s
            }
        }
        return rewritten to found
    }

    // ---- Lua interop ----

    /**
     * A call to (or access of) something implemented in Lua. Top-level functions are globals or fields of
     * a required module; members of external objects are called with `.`, instance members with `:`.
     */
    private fun KaSession.externalCall(call: KaCallableMemberCall<*, *>, receiverExpr: KtExpression?, implicit: LuaExpr?, element: KtExpression): LuaExpr {
        val symbol = call.partiallyAppliedSymbol.symbol
        val args = callArguments(call, element)
        val isFunction = call is KaFunctionCall<*>
        if (symbol is KaConstructorSymbol) {
            val cls = symbol.containingClassId?.let { findClass(it) } ?: return unsupported(element, "This external constructor")
            val ref = interop.externalClassRef(cls) ?: return unsupported(element, "Constructing _G")
            return LuaCall(LuaIndex(ref, LuaString("new")), arguments(emptyList(), args))
        }
        val name = interop.luaName(symbol)
        val container = symbol.containingDeclaration as? KaClassSymbol
        if (container == null || container.classKind.isObject) {
            val base = if (container != null) interop.externalClassRef(container) else interop.fileRequire(symbol.psi)?.let(interop::moduleRequire)
            val target = base?.let { LuaIndex(it, LuaString(name)) } ?: LuaName(name)
            return if (isFunction) LuaCall(target, arguments(emptyList(), args)) else target
        }
        val receiver: Any = implicit ?: receiverExpr ?: return unsupported(element, "External member without a receiver")
        val values = arguments(listOf(receiver), args)
        if (!isFunction) return LuaIndex(values[0], LuaString(name))
        val noSelf = (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true || container.annotations.contains(NO_SELF)
        return if (noSelf) LuaCall(LuaIndex(values[0], LuaString(name)), values.drop(1)) else LuaMethodCall(values[0], name, values.drop(1))
    }

    // ---- equality and casts ----

    /** Kotlin `==`: identity for primitives, enums and objects; `equals()` when a class may override it. */
    private fun KaSession.equality(l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?, negated: Boolean): LuaExpr {
        val result = when {
            l is LuaNil || r is LuaNil || lt.isNullLiteral || rt.isNullLiteral -> LuaBinary(LuaBinOp.Eq, l, r)
            !classes.mayOverrideEquals(lt) && !classes.mayOverrideEquals(rt) -> LuaBinary(LuaBinOp.Eq, l, r)
            lt != null && !lt.isMarkedNullable && classes.knownEquals(lt) -> LuaMethodCall(l, "equals", listOf(r))
            else -> lualibCall("Equals", l, r)
        }
        return if (negated) negate(result) else result
    }

    private fun KaSession.isPrimitiveOperand(t: KaType?): Boolean =
        t == null || t.isNumber || t.isStringType || t.isCharType || t.isBooleanType ||
            (t.isMarkedNullable && (t.isStringType)) // String? + x is still string concatenation

    private val KaType?.isNullLiteral get() = this != null && with(session) { isNothingType }

    private fun KaSession.cast(e: KtBinaryExpressionWithTypeRHS): LuaExpr {
        val type = e.right?.type ?: return LuaNil
        val value = expression(e.left)
        if (e.operationReference.getReferencedNameElementType() != KtTokens.AS_SAFE) return value // unchecked, as in TSTL
        val v = cache(value, "cast")
        if (type.isBooleanType) {
            val name = ctx.temp("cast")
            emit(LuaLocal(listOf(name)))
            emit(LuaIf(typeTest(v, type, e), listOf(assign(name, v))))
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
        private val ARITHMETIC: Set<IElementType> = setOf(KtTokens.PLUS, KtTokens.MINUS, KtTokens.MUL, KtTokens.DIV, KtTokens.PERC)

        private val BINARY_OPERATORS: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUS to LuaBinOp.Add, KtTokens.MINUS to LuaBinOp.Sub, KtTokens.MUL to LuaBinOp.Mul,
            KtTokens.DIV to LuaBinOp.Div, KtTokens.PERC to LuaBinOp.Mod,
            KtTokens.EQEQEQ to LuaBinOp.Eq, KtTokens.EXCLEQEQEQ to LuaBinOp.Ne,
            KtTokens.LT to LuaBinOp.Lt, KtTokens.GT to LuaBinOp.Gt, KtTokens.LTEQ to LuaBinOp.Le, KtTokens.GTEQ to LuaBinOp.Ge,
        )
    }
}
