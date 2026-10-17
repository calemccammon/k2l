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
    internal val session: KaSession,
    internal val file: KtFile,
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
    internal fun topLevelRef(decl: KtNamedDeclaration): LuaExpr = when {
        decl.containingFile != file -> LuaIndex(moduleRef(decl.containingKtFile), LuaString(naming.of(decl)))
        tableMode && isExportedVar(decl) -> LuaIndex(LuaName(EXPORTS), LuaString(naming.of(decl)))
        else -> LuaName(naming.of(decl))
    }

    internal val interop = LuaInterop(session, ctx)
    internal val classes = ClassHierarchy(session, file, module)
    internal val naming = DeclarationNames(session, classes)

    internal val target get() = ctx.options.luaTarget

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

    internal var loops = ArrayDeque<LoopFrame>()

    private var frames = ArrayDeque<FunctionFrame>()

    internal inline fun <T> inFrame(frame: FunctionFrame, block: () -> T): T {
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
    internal val receiverBindings = HashMap<PsiElement, LuaExpr>()

    /** Lambda parameters of inlined lambdas, keyed by (function literal, parameter name). */
    internal val lambdaBindings = HashMap<Pair<PsiElement, String>, LuaExpr>()

    /** A name for a receiver parameter; `self` unless that would hide a class instance or another receiver. */
    internal fun receiverName(): String {
        val selfTaken = currentClass != null || receiverBindings.values.any { it is LuaName && it.name == "self" }
        return if (selfTaken) ctx.temp("this") else "self"
    }

    internal fun KaSession.function(fn: KtNamedFunction): LuaFunction {
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
    internal fun KaSession.defaultArguments(params: List<KtParameter>) {
        for (p in params) {
            val default = p.defaultValue ?: continue
            val name = LuaName(naming.of(p))
            emit(LuaIf(LuaBinary(LuaBinOp.Eq, name, LuaNil), valueInto(default) { listOf(assign(name, it)) }))
        }
    }

    internal fun <F> KaSession.functionBody(fn: F) where F : KtDeclarationWithBody, F : KtDeclarationWithReturnType {
        val body = fn.bodyExpression ?: return
        if (fn.hasBlockBody()) {
            block(body)
            return
        }
        val returnType = fn.returnType
        if (returnType.isUnitType || returnType.isNothingType) statement(body)
        else emitAll(valueInto(body) { listOf(LuaReturn(listOf(it))) })
    }

    // ---- statements ----

    internal fun KaSession.block(e: KtExpression) {
        if (e is KtBlockExpression) e.statements.forEach { statement(it) } else statement(e)
    }

    internal fun KaSession.statement(e: KtExpression) {
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



    // ---- branching values ----

    private fun KaSession.needsBranching(e: KtExpression): Boolean {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        return ex is KtWhenExpression || ex is KtTryExpression || (ex is KtIfExpression && !canTernary(ex))
    }

    /**
     * Emits statements that compute [e] and hand its value to [sink], pushing the sink into the
     * branches of `if`/`when` so no temporary is needed.
     */
    internal fun KaSession.valueInto(e: KtExpression, sink: ValueSink): List<LuaStmt> = collect {
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

    internal fun KaSession.isJump(e: KtExpression) =
        e is KtReturnExpression || e is KtBreakExpression || e is KtContinueExpression || e is KtThrowExpression ||
            e.expressionType.let { it != null && it.isNothingType && !it.isMarkedNullable }

    private fun KaSession.ifInto(e: KtIfExpression, sink: ValueSink) {
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

    internal fun KaSession.mayNeedStatements(e: KtExpression): Boolean {
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

    private fun KaSession.whenInto(e: KtWhenExpression, sink: ValueSink?) {
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

    internal fun KaSession.typeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr {
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
    internal val overrides = HashMap<KtExpression, LuaExpr>()

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

    internal fun KaSession.reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr {
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
    internal fun KaSession.ordered(exprs: List<KtExpression>): List<LuaExpr> {
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
    internal fun KaSession.call(element: KtExpression, full: KtExpression): LuaExpr {
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
        val fnValue = receiverOperand(pas.dispatchReceiver!!, full) ?: return LuaNil
        val extension = pas.extensionReceiver?.let { receiverOperand(it, full) ?: return LuaNil }
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
            val receivers = if (psi.receiverTypeReference != null) listOf(receiverOperand(implicit, receiverExpr) ?: return LuaNil) else emptyList()
            val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
            return LuaCall(fn, arguments(receivers, args))
        }
        val method = naming.function(psi)
        if (receiverExpr is KtSuperExpression) {
            // The resolved declaration is the implementation `super` reaches, in a class or interface.
            return LuaCall(LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(method)), listOf(selfRef()) + arguments(emptyList(), args))
        }
        val values = arguments(listOf(receiverOperand(implicit, receiverExpr)!!), args)
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
        val values = arguments(listOfNotNull(receiverOperand(implicit, receiverExpr)), args)
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

    /** A receiver as an operand: either an explicit expression (transformed later, in order) or an implicit `this`. */
    private fun KaSession.receiverOperand(value: KaReceiverValue, element: KtElement): Operand? =
        explicitReceiver(value)?.asOperand() ?: implicitReceiver(value, element)?.asOperand()

    /** The implicit `this` if there is one, else the explicit receiver expression; null if neither. */
    private fun receiverOperand(implicit: LuaExpr?, explicit: KtExpression?): Operand? =
        implicit?.asOperand() ?: explicit?.asOperand()

    /**
     * Transforms the [Operand.Source]s among [receivers] and then [args] in source order. Omitted
     * arguments become nil so later ones keep their position; trailing omitted ones are dropped.
     */
    internal fun KaSession.arguments(receivers: List<Operand>, args: List<KtExpression?>): List<LuaExpr> {
        val operands = receivers + args.map { it?.asOperand() }
        val transformed = ordered(operands.filterIsInstance<Operand.Source>().map { it.expr }).iterator()
        val values = operands.map { item ->
            when (item) {
                is Operand.Source -> transformed.next().let { if (item.expr in spreads) lualibCall("Unpack", it) else it }
                is Operand.Value -> item.lua
                null -> null // omitted
            }
        }
        return values.dropLastWhile { it == null }.map { it ?: LuaNil }
    }

    /**
     * Argument expressions in parameter order (named arguments are reordered); null where an argument is
     * omitted and the parameter's default applies.
     */
    internal fun KaSession.callArguments(call: KaCallableMemberCall<*, *>, element: KtElement): List<KtExpression?> {
        if (call !is KaFunctionCall<*>) return emptyList()
        val symbol = call.signature.symbol
        val bySignature = call.valueArgumentMapping.entries.groupBy({ it.value.symbol }, { it.key })
        val result = mutableListOf<KtExpression?>()
        for (p in symbol.valueParameters) {
            val mapped = bySignature[p]
            if (p.isVararg) {
                mapped?.forEach { arg ->
                    if ((arg.parent as? KtValueArgument)?.getSpreadElement() != null) {
                        if (arg != call.valueArgumentMapping.keys.last()) unsupported(arg, "A spread argument that is not last")
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
    internal fun KaSession.throwableArguments(args: List<KtExpression?>): List<LuaExpr> {
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
    internal var currentClass: KtClassOrObject? = null



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
        val receiver = receiverOperand(implicit, receiverExpr) ?: return unsupported(element, "External member without a receiver")
        val values = arguments(listOf(receiver), args)
        if (!isFunction) return LuaIndex(values[0], LuaString(name))
        val noSelf = (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true || container.annotations.contains(NO_SELF)
        return if (noSelf) LuaCall(LuaIndex(values[0], LuaString(name)), values.drop(1)) else LuaMethodCall(values[0], name, values.drop(1))
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
