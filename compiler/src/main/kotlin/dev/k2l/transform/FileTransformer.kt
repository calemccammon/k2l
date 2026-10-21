package dev.k2l.transform

import com.intellij.psi.PsiElement
import com.intellij.psi.tree.IElementType
import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.LuaTarget
import dev.k2l.codegen.*
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
import org.jetbrains.kotlin.analysis.api.symbols.KaAnonymousFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaAnonymousObjectSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaReceiverParameterSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSamConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject
import org.jetbrains.kotlin.psi.psiUtil.isPrivate
import java.util.IdentityHashMap

/** The companion objects of the basic types, whose members are constants (see `isBasicCompanion`). */
private val BASIC_COMPANIONS =
    listOf("Int", "Long", "Short", "Byte", "Double", "Float", "Char", "String", "Boolean", "UInt", "ULong", "UShort", "UByte")
        .map { "kotlin/$it.Companion" }.toSet()

/**
 * Translates one Kotlin file into a Lua chunk. Expressions may need statements to run before them
 * (e.g. an `if` used as a value); those are emitted into the current statement buffer, see [collect].
 */
@Suppress("TooManyFunctions", "LargeClass") // the recursive core; language areas are already split into sibling files
class FileTransformer(
    internal val session: KaSession,
    internal val file: KtFile,
    override val ctx: TransformContext,
    private val module: ModuleContext = ModuleContext.single(file),
) : StatementEmitter() {
    internal val usesReflection get() = module.usesReflection
    internal val usesFloat get() = module.usesFloat
    internal val usesListViews get() = module.usesListViews
    internal val implementsCharSequence get() = module.implementsCharSequence
    internal val implementsClosedRange get() = module.implementsClosedRange
    internal val implementsCollections get() = module.implementsCollections
    internal val uncheckedCasts get() = module.uncheckedCasts
    internal fun usesFunctionNames(scan: (Set<KtFile>) -> Boolean) = module.usesFunctionNames(scan)

    /** `local ____strings = require("util.strings")` for another file of the module. */
    private fun moduleRef(other: KtFile): LuaExpr =
        LuaName(ctx.imports.getOrPut(module.modulePath(other)) { ctx.temp(LuaNames.of(other.name.removeSuffix(".kt"))) })

    /** Exported top-level `var`s live in `____exports` so other files see updates. */
    private val tableMode: Boolean by lazy {
        file in module.cyclic || file.declarations.any(::isExportedVar) || deferredInit
    }

    /** The file's plain properties are initialized on first use, see [FileInit]. */
    private val deferredInit: Boolean by lazy { fileInit.isDeferred(file) }

    /** A top-level property kept in `____exports`: an exported `var`, or any plain property of a deferred file. */
    private fun isFileField(decl: PsiElement?) =
        isExportedVar(decl) || (deferredInit && decl is KtProperty && FileInit.isField(decl) && !interop.isExternalDeclaration(decl))

    private fun isExportedVar(decl: PsiElement?) = decl is KtProperty && decl.isTopLevel && decl.isVar && !decl.isPrivate() &&
        !decl.hasAccessorFunctions() && decl.delegate == null

    /** A top-level declaration as a Lua value: a local of this file or a field of another file's module. */
    internal fun topLevelRef(decl: KtNamedDeclaration, name: String = naming.of(decl)): LuaExpr = when {
        decl.containingFile != file -> LuaIndex(moduleRef(decl.containingKtFile), LuaString(name))
        tableMode && isFileField(decl) -> LuaIndex(LuaName(EXPORTS), LuaString(name))
        else -> LuaName(name)
    }

    /** Delegated properties' delegate kinds (null when unsupported, already reported). */
    internal val delegateKinds = HashMap<KtProperty, DelegateKind?>()

    /** The `provideDelegate` operator of delegated properties whose delegate has one. */
    internal val delegateProviders = HashMap<KtProperty, Operator>()

    internal val interop = LuaInterop(session, ctx)
    internal val classes = ClassHierarchy(session, file, module)
    internal val lazyInit = LazyInit(session, classes)
    private val fileInit = FileInit(session, lazyInit)
    internal val naming = DeclarationNames(session, classes)
    internal val props = PropertyFamilies(session, module, classes) { interop.isExternalDeclaration(it) }

    init {
        naming.plainAccessors = { props.usesAccessors(it) || it.delegate != null }
        lazyInit.deferredFile = fileInit::isDeferred
    }

    internal val target get() = ctx.options.luaTarget

    /** Lambda arguments of the inlined functions being expanded, by the parameter they are bound to. */
    internal val inlinedLambdas = HashMap<KtParameter, InlinedLambda>()

    /** Actual types of the reified type parameters of the inlined functions being expanded. */
    internal val reifiedTypes = HashMap<PsiElement, KaType>()

    fun unsupported(element: KtElement, what: String): LuaExpr {
        ctx.error(element, "$what is not supported yet")
        return LuaNil
    }

    // ---- file ----

    fun transformFile(): LuaChunk = with(session) { transformChunk() }

    private fun KaSession.transformChunk(): LuaChunk {
        renameHidingLocals()
        renameFunctionShadows()
        val topLevel = file.declarations.filter { isTransformedTopLevel(it) }
        val forward = forwardReferenced(topLevel.filterNot { tableMode && isFileField(it) }.toSet())
        val main = topLevel.filterIsInstance<KtNamedFunction>().firstOrNull(::isMain)
        val exported = topLevel.filter { !it.isPrivate() && it != main }
        val body = exportsTableSetup().toMutableList()
        // Requires go after the exports table is registered, so an import cycle finds it in package.loaded.
        val requiresAt = body.size
        if (forward.isNotEmpty()) body += LuaLocal(forward.flatMap { naming.topLevel(it) })

        val emitted = HashSet<KtDeclaration>()
        val initializers = mutableListOf<LuaStmt>()
        for (decl in file.declarations) {
            val target = if (deferredInit && isFileField(decl)) initializers else body
            emitDeclaration(decl, emitted, target, forward, exported)
        }
        if (tableMode && file !in module.cyclic) {
            exported.filterNot { isFileField(it) }.forEach { body += exportStatements(it) }
        }
        if (deferredInit) body += lazyFileSetup(topLevel.filter(::isFileField), initializers)

        if (main != null) {
            // Another file requires this one (an import cycle through the entry file): `require` passes the chunk its
            // module name, a script its command-line arguments, so `main` runs only when the file is the script.
            val run = mainInvocation(main)
            val asScript = LuaBinary(LuaBinOp.Ne, LuaName("..."), LuaString(module.modulePath(file)))
            body += if (file !in module.imported) run else LuaIf(asScript, listOf(run))
        }

        val requires = ctx.imports.map { (path, name) -> LuaLocal(listOf(name), listOf(luaCall(LuaName("require"), LuaString(path)))) }
        body.addAll(requiresAt, requires)
        body.addAll(requiresAt + requires.size, hoistedLongs())
        exportsReturn(exported)?.let { body += it }
        return LuaChunk(body)
    }

    /** A class must be created after the classes and interfaces it extends, wherever they are declared. */
    private fun KaSession.emitDeclaration(
        decl: KtDeclaration,
        emitted: MutableSet<KtDeclaration>,
        body: MutableList<LuaStmt>,
        forward: Set<KtDeclaration>,
        exported: List<KtDeclaration>,
    ) {
        if (!emitted.add(decl)) return
        if (decl is KtClassOrObject) {
            classes.superInfo(decl).let { listOfNotNull(it.base) + it.interfaces }
                .filter { it.isTopLevel() && it.containingFile == file }.forEach { emitDeclaration(it, emitted, body, forward, exported) }
        }
        body += collect { withOrigin(decl) { topLevelDeclaration(decl, decl in forward) } }
        // In an import cycle, other files may run before this one finishes, so export as we go.
        if (file in module.cyclic && decl in exported && !isFileField(decl)) body += exportStatements(decl)
    }

    private fun isTransformedTopLevel(decl: KtDeclaration) =
        (decl is KtNamedFunction || decl is KtProperty || (decl is KtClassOrObject && !(decl is KtClass && decl.isAnnotation()))) &&
            !interop.isExternalDeclaration(decl) && !(decl is KtNamedFunction && decl.isReifiedInline())

    private fun exportsTableSetup(): List<LuaStmt> {
        if (!tableMode) return emptyList()
        val table = LuaLocal(listOf(EXPORTS), listOf(LuaTable(emptyList())))
        if (file !in module.cyclic) return listOf(table)
        // Files that require each other see this table, filled in as declarations run.
        return listOf(table, assign(LuaIndex(luaPath("package", "loaded"), LuaString(module.modulePath(file))), LuaName(EXPORTS)))
    }

    /** Runs `main`, passing the command-line arguments as an `Array<String>` when it takes them. */
    private fun mainInvocation(main: KtNamedFunction): LuaStmt {
        val args = if (main.valueParameters.isEmpty()) {
            emptyList()
        } else {
            listOf(
                LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))),
            )
        }
        val name = LuaName(naming.of(main))

        // An uncaught error prints as on the JVM and exits with status 1 (Uncaught.lua); with --source-map its traceback
        // shows Kotlin positions, since the source-map runtime rewrites debug.traceback.
        fun run() = lualibRef("Uncaught", "__K2L_Main")
        if (main.hasModifier(KtTokens.SUSPEND_KEYWORD)) {
            return LuaCallStmt(LuaCall(run(), listOf(lualibRef(COROUTINES_FEATURE, "__K2L_RunSuspend"), name) + args))
        }
        // protected calls nested deeper than Lua's C stack allows run in coroutines the driver resumes (DeepPcall.lua)
        if (module.usesTry && target.hasGoto && target != LuaTarget.LuaJIT) {
            return LuaCallStmt(LuaCall(lualibRef("DeepPcall", "__K2L_DeepMain"), listOf(name) + args))
        }
        return LuaCallStmt(LuaCall(run(), listOf(name) + args))
    }

    /** The chunk's `return`: the exports table, or a table of the [exported] declarations when not in table mode. */
    private fun exportsReturn(exported: List<KtDeclaration>): LuaStmt? = when {
        tableMode -> LuaReturn(listOf(LuaName(EXPORTS)))

        exported.isNotEmpty() ->
            LuaReturn(listOf(LuaTable(exported.flatMap { naming.topLevel(it) }.map { n -> LuaField.Named(n, LuaName(n)) })))

        else -> null
    }

    private fun exportStatements(decl: KtDeclaration): List<LuaStmt> =
        naming.topLevel(decl).map { name -> assign(LuaIndex(LuaName(EXPORTS), LuaString(name)), LuaName(name)) }

    /** `__K2L_LazyFile(____exports, function() <initializers> end, {"names", ...})`: the first use of a field runs them. */
    private fun lazyFileSetup(fields: List<KtDeclaration>, initializers: List<LuaStmt>): LuaStmt {
        val names = LuaTable(fields.flatMap { naming.topLevel(it) }.map { LuaField.Positional(LuaString(it)) })
        return LuaCallStmt(lualibCall("LazyFile", LuaName(EXPORTS), LuaFunction(emptyList(), initializers), names))
    }

    private fun isMain(fn: KtNamedFunction) = fn.name == "main" && fn.receiverTypeReference == null && fn.valueParameters.size <= 1

    /** Top-level declarations referenced textually before they are declared (or inside their own initializer) need a forward `local`. */
    private fun KaSession.forwardReferenced(candidates: Set<KtDeclaration>): Set<KtDeclaration> {
        val result = LinkedHashSet<KtDeclaration>()
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitReferenceExpression(expression: KtReferenceExpression) {
                super.visitReferenceExpression(expression)
                if (expression !is KtNameReferenceExpression) return
                // Members, constructors and enum entries count as references to their top-level class.
                val resolved = expression.mainReference.resolve() ?: return
                val target = generateSequence(resolved) { it.parent }.firstOrNull { it in candidates } as? KtDeclaration ?: return
                if (target is KtProperty && resolved != target) return // a local declared inside the property's initializer
                // a property's own initializer (`val json = lazyParser { ... json ... }`) runs before its `local` is in scope
                val own = (target as? KtProperty)?.let { it.initializer ?: it.delegateExpression }
                val inOwnInitializer = own != null && own.textRange.contains(expression.textRange)
                if (expression.textRange.startOffset < target.textRange.startOffset || inOwnInitializer) result += target
            }
        })
        return candidates.filter { it in result }.toCollection(LinkedHashSet())
    }

    private fun KaSession.topLevelDeclaration(decl: KtDeclaration, forwardDeclared: Boolean) {
        if (interop.isExternalDeclaration(decl)) return // implemented in Lua
        if (decl is KtNamedFunction && decl.isReifiedInline()) return // only exists expanded at its calls
        when (decl) {
            is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(naming.of(decl)), function(decl), isLocal = !forwardDeclared))

            is KtProperty -> if (decl.receiverTypeReference != null) {
                extensionPropertyDeclaration(decl, forwardDeclared)
            } else if (decl.hasAccessorFunctions()) {
                accessorPropertyDeclaration(decl, forwardDeclared)
            } else if (tableMode && isFileField(decl)) {
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

    internal var frames = ArrayDeque<FunctionFrame>()

    /** Calls of inline functions being transformed whose lambdas may stay Lua functions, innermost last (see NonLocalJumps.kt). */
    internal val jumpSites = ArrayDeque<JumpSite>()

    /** How many jumps out of lambdas raised a token so far. */
    internal var jumpsRaised = 0

    /** The break and continue labels of loops and the end labels of inlined bodies: on Lua 5.1 each is lowered where it is. */
    internal val jumpLabels = HashSet<String>()

    internal inline fun <T> inFrame(frame: FunctionFrame, block: () -> T): T {
        val savedLoops = loops
        frame.outerLoops = savedLoops
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

    /** The temps holding values checked against their static type (see UncheckedCasts.kt), which need no second check. */
    internal val checkedValues = HashSet<LuaName>()

    /** A name for a receiver parameter; `self` unless that would hide a class instance or another receiver. */
    internal fun receiverName(): String {
        val selfTaken = currentClass != null || receiverBindings.values.any { it is LuaName && it.name == "self" }
        return if (selfTaken) ctx.temp("this") else "self"
    }

    internal fun KaSession.function(fn: KtNamedFunction): LuaFunction {
        val params = mutableListOf<String>()
        if (fn.receiverTypeReference != null) {
            val name = receiverName()
            receiverBindings[fn] = LuaName(name).also { stable += it }
            params += name
        }
        val vararg = varargParameter(fn.valueParameters)
        fn.valueParameters.filter { !it.isVarArg }.mapTo(params) { naming.of(it) }
        val labels = setOfNotNull(fn.name)
        return inFrame(FunctionFrame(FunctionFrame.Kind.Function, labels, fn)) {
            LuaFunction(
                params,
                collect {
                    packVararg(vararg)
                    defaultArguments(fn.valueParameters, fn)
                    functionBody(fn)
                },
                isVararg = vararg != null,
            )
        }
    }

    /**
     * The `vararg` parameter of a function or constructor: it arrives as the Lua varargs, after the other parameters also when
     * it is not the last one (see [callArguments]).
     */
    internal fun varargParameter(params: List<KtParameter>): KtParameter? = params.firstOrNull { it.isVarArg }

    /** `vararg xs: Int` arrives as Lua varargs and is packed into an Array. */
    internal fun packVararg(vararg: KtParameter?) {
        if (vararg == null) return
        emit(LuaLocal(listOf(naming.of(vararg)), listOf(LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))))))
    }

    /**
     * Callee-side defaults: `if x == nil then x = <default> end`. Callers pass nil for omitted arguments. An override of [fn]
     * applies the defaults it inherits.
     */
    internal fun KaSession.defaultArguments(params: List<KtParameter>, fn: KtNamedFunction? = null) {
        val inherited = fn?.let { inheritedDefaults(it) }.orEmpty()
        for (p in params) {
            val base = inherited[p]
            val default = p.defaultValue ?: base?.defaultValue ?: continue
            val name = LuaName(naming.of(p))
            val assignment = if (base == null) {
                valueInto(default) { listOf(assign(name, it)) }
            } else {
                withParametersOf(fn!!, base) { valueInto(default) { listOf(assign(name, it)) } }
            }
            emit(LuaIf(LuaBinary(LuaBinOp.Eq, name, LuaNil), assignment))
        }
    }

    internal fun <F> KaSession.functionBody(fn: F) where F : KtDeclarationWithBody, F : KtDeclarationWithReturnType {
        val body = fn.bodyExpression ?: return
        if (fn.hasBlockBody()) {
            block(body)
            return
        }
        val returnType = fn.returnType
        if ((returnType.isUnitType && !returnType.isMarkedNullable) || returnType.isNothingType) {
            statement(body)
        } else {
            withOrigin(body) { emitAll(valueInto(body) { listOf(LuaReturn(listOf(it))) }) }
        }
    }

    // ---- statements ----

    internal fun KaSession.block(e: KtExpression) {
        if (e is KtBlockExpression) e.statements.forEach { statement(it) } else statement(e)
    }

    internal fun KaSession.statement(e: KtExpression) = withOrigin(e) { translateStatement(e) }

    private fun KaSession.translateStatement(e: KtExpression) {
        when (e) {
            is KtParenthesizedExpression -> e.expression?.let { statement(it) }

            is KtAnnotatedExpression -> e.baseExpression?.let { statement(it) }

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
        if (isUnitObject(e)) return // `else -> Unit`
        val value = asStatement(e) { expression(e) }
        when {
            value is LuaCall || value is LuaMethodCall -> emit(LuaCallStmt(value))

            isStable(value) || value is LuaName -> Unit

            // a bare value has no effect
            else -> emit(LuaLocal(listOf("_"), listOf(value)))
        }
    }

    private fun KaSession.property(p: KtProperty, isLocal: Boolean) {
        if (p.delegate != null) {
            delegatedVariable(p, isLocal)
            return
        }
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
        if (e.operationToken != KtTokens.EQ && callsAssignOperator(e)) {
            // `list += x` calls plusAssign, also on a `val` or a parameter
            val value = call(e, e)
            if (value is LuaCall || value is LuaMethodCall) emit(LuaCallStmt(value))
            return
        }
        val target = assignTarget(left) ?: return
        if (e.operationToken == KtTokens.EQ) {
            emitAll(valueInto(right) { target.assignAll(it) })
            return
        }
        val op = AUGMENTED.getValue(e.operationToken)
        val leftType = left.expressionType
        if (leftType == null || !(leftType.isNumber || leftType.isStringType)) {
            // `readOnly += x` is `readOnly = readOnly + x`
            emit(target.write(compoundOperatorCall(e) ?: call(e, e)))
            return
        }
        val value = operator(op, target.read, leftType, expression(right), right.expressionType, e)
        emit(target.update(value))
    }

    /** Whether `a op= b` calls an `opAssign` operator (`plusAssign`) rather than assigning `a op b`. */
    private fun KaSession.callsAssignOperator(e: KtBinaryExpression): Boolean {
        val leftType = e.left?.expressionType
        if (leftType != null && (leftType.isNumber || leftType.isStringType)) return false
        val callee = e.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()?.partiallyAppliedSymbol?.symbol
        return callee?.callableId?.callableName?.asString()?.endsWith("Assign") == true
    }

    private fun KaSession.assignTarget(e: KtExpression): Target? {
        val ex = KtPsiUtil.safeDeparenthesize(e)
        if (ex is KtArrayAccessExpression) return indexTarget(ex)
        val ref = assignedReference(ex)
        val receiverExpr = (ex as? KtDotQualifiedExpression)?.receiverExpression
        if (ref != null && receiverExpr == null && ref.mainReference.resolveToSymbol() is KaBackingFieldSymbol) {
            val field = backingField(ref)
            return Target(field) { assign(field, it) }
        }
        val decl = ref?.mainReference?.resolve()
        if (ref == null || decl == null || !classes.isSource(decl)) return unsupported(e, "Assignment to this target").let { null }
        return when {
            decl is KtProperty && decl.containingClassOrObject == null -> variableTarget(decl, ref, receiverExpr)

            // `var (a, b) = pair` declares plain locals
            decl is KtDestructuringDeclarationEntry -> LuaName(naming.entry(decl)).let { name -> Target(name) { assign(name, it) } }

            isMemberProperty(decl) -> memberPropertyTarget(decl as KtNamedDeclaration, ref, receiverExpr)

            else -> unsupported(e, "Assignment to this target").let { null }
        }
    }

    private fun assignedReference(ex: KtExpression) = when (ex) {
        is KtNameReferenceExpression -> ex
        is KtDotQualifiedExpression -> ex.selectorExpression as? KtNameReferenceExpression
        else -> null
    }

    private fun KaSession.memberPropertyTarget(
        property: KtNamedDeclaration,
        ref: KtNameReferenceExpression,
        receiverExpr: KtExpression?,
    ): Target? {
        if (property is KtProperty &&
            property.receiverTypeReference != null
        ) {
            return memberExtensionPropertyTarget(property, ref, receiverExpr)
        }
        val receiver = if (receiverExpr != null) cache(expression(receiverExpr), "object") else implicitReceiverOf(ref) ?: return null
        return Target(propertyRead(receiver, property)) { propertyWrite(receiver, property, it) }
    }

    /** `xs[i] = v`, `map[k] = v`, or a user `operator fun set` (also with several indices: `m[i, j] = v`). */
    private fun KaSession.indexTarget(e: KtArrayAccessExpression): Target? {
        val arrayExpr = e.arrayExpression ?: return null
        if (e.indexExpressions.isEmpty()) return null
        val type = arrayExpr.expressionType
        val values = ordered(listOf(arrayExpr) + e.indexExpressions)
        val receiver = cache(values[0], "object")
        val keys = values.drop(1).map { cache(it, "key") }
        sourceIndexOperators(e)?.let { return sourceIndexTarget(e, it, receiver, keys) }
        if (keys.size > 1) return unsupported(e, "Multi-index access on '${type.pretty()}'").let { null }
        val key = keys[0]
        val userClass = type?.expandedSymbol?.psi as? KtClassOrObject
        val kind = type?.collectionKind()
        return when {
            // a class of the program without index operators (those are handled above)
            userClass != null && classes.isSource(userClass) && kind == null ->
                unsupported(e, "Index assignment without operator get/set").let { null }

            kind == CollectionKind.Map || kind == CollectionKind.StringBuilder ->
                Target(LuaMethodCall(receiver, "get", listOf(key))) { LuaCallStmt(LuaMethodCall(receiver, "set", listOf(key, it))) }

            kind == CollectionKind.LuaTable -> {
                val slot = LuaIndex(receiver, key)
                Target(slot) { assign(slot, it) }
            }

            kind?.isIndexable == true && isProvenIndex(e, type) -> {
                val slot = CollectionMappings.index(receiver, key)
                Target(slot) { assign(slot, it) }
            }

            // checked like the JVM: out-of-range reads and writes throw IndexOutOfBoundsException
            kind?.isIndexable == true -> checkedIndexTarget(type, receiver, key)

            else -> unsupported(e, "Index assignment on '${type.pretty()}'").let { null }
        }
    }

    private fun KaSession.increment(e: KtUnaryExpression, target: Target) {
        val op = if (e.operationToken == KtTokens.PLUSPLUS) LuaBinOp.Add else LuaBinOp.Sub
        val type = e.baseExpression?.expressionType
        emit(target.update(if (type?.isCharType == true) charStepped(op, target.read) else stepped(op, target.read, type)))
    }

    /** `c++` on a Char: the Char whose code is one more (or less). */
    private fun charStepped(op: LuaBinOp, read: LuaExpr): LuaExpr = if (utf16) {
        u16("char", LuaBinary(op, u16("code", read), LuaNumber("1")))
    } else {
        luaCall(luaPath("string", "char"), LuaBinary(op, LuaMethodCall(read, "byte", emptyList()), LuaNumber("1")))
    }

    private fun KaSession.returnStatement(e: KtReturnExpression) {
        val label = e.getLabelName()
        val target = if (label == null) bareReturnTarget(e) else frames.lastOrNull { label in it.labels }
        if (target == null) {
            unsupported(e, "This return")
            return
        }
        jumpTo(JumpTarget.Return(target), e.returnedExpression?.asOperand(), e)
    }

    /** A `return` of [target], with no Lua function between here and it: a `goto` out of an inlined body, or a Lua `return`. */
    internal fun KaSession.returnLocally(target: FunctionFrame, value: Operand?) {
        if (target.kind == FunctionFrame.Kind.Inline || target.kind == FunctionFrame.Kind.InlineFunction) {
            val sink = target.sink
            when (value) {
                is Operand.Source -> if (sink != null) emitAll(valueInto(value.expr, sink)) else statement(value.expr)
                is Operand.Value -> if (sink != null) emitAll(sink(value.lua))
                null -> Unit
            }
            val end = target.endLabel ?: ctx.temp("inline_end").also {
                target.endLabel = it
                jumpLabels += it
            }
            emit(LuaGoto(end))
            return
        }
        when (value) {
            null -> emit(LuaReturn(listOfNotNull(if (target.unitResult) unitObject() else null)))

            is Operand.Source -> {
                val returned = KtPsiUtil.safeDeparenthesize(value.expr)
                val result = { valueInto(returned) { listOf(LuaReturn(listOf(it))) } }
                // `return unitCall()` where the result is not used stays a tail call
                emitAll(if (returnsNothing(target)) asStatement(returned, result) else result())
            }

            is Operand.Value -> emit(LuaReturn(listOf(value.lua)))
        }
    }

    /**
     * What a `return` without a label leaves: the innermost function it is written in, which can be an inlined
     * function when this is the body of one (or a lambda passed to it, written in the function that called it).
     */
    private fun bareReturnTarget(e: KtReturnExpression): FunctionFrame? {
        val owner = generateSequence<PsiElement>(e) { it.parent }.firstOrNull { it is KtNamedFunction || it is KtPropertyAccessor }
        return frames.lastOrNull { it.isFunctionBody && it.psi != null && it.psi === owner }
            ?: frames.lastOrNull { it.kind == FunctionFrame.Kind.Function }
    }

    private fun KaSession.ifStatement(e: KtIfExpression) {
        val cond = expression(e.condition ?: return)
        val then = collect { e.then?.let { block(it) } }
        val orElse = e.`else`?.let { collect { block(it) } }
        emit(LuaIf(cond, then, orElse?.takeIf { it.isNotEmpty() }))
    }

    // ---- branching values ----

    internal fun KaSession.needsBranching(e: KtExpression): Boolean {
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
        if (canBeFalsyInLua(thenType)) return false
        return !isJump(orElse) && listOf(cond, then, orElse).none { mayNeedStatements(it) }
    }

    /** Nullable, Boolean, Nothing and Unit values may be nil or false in Lua. */
    private fun KaSession.canBeFalsyInLua(t: KaType) = t.isMarkedNullable || t.isBooleanType || t.isNothingType || t.isUnitType

    private fun KaSession.ternary(e: KtIfExpression): LuaExpr {
        val parts = listOf(e.condition!!, singleExpression(e.then!!)!!, singleExpression(e.`else`!!)!!).map { expression(it) }
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, parts[0], parts[1]), parts[2])
    }

    internal fun KaSession.mayNeedStatements(e: KtExpression): Boolean {
        var found = false
        e.accept(object : KtTreeVisitorVoid() {
            override fun visitElement(element: PsiElement) {
                if (found) return
                if (needsStatements(element) || mayExpandOrCheck(element)) {
                    found = true
                    return
                }
                super.visitElement(element)
            }
        })
        return found
    }

    private fun KaSession.mayExpandOrCheck(element: PsiElement) =
        (element is KtCallExpression && mayExpandInline(element)) || (element is KtBinaryExpressionWithTypeRHS && mayCheckCast(element)) ||
            (element is KtExpression && mayCheckUnchecked(element))

    private fun needsStatements(element: PsiElement) = when (element) {
        is KtIfExpression, is KtWhenExpression, is KtTryExpression, is KtSafeQualifiedExpression, is KtLambdaExpression,
        is KtObjectLiteralExpression,
        -> true

        is KtBinaryExpression -> element.operationToken == KtTokens.ELVIS

        is KtUnaryExpression -> element.operationToken == KtTokens.PLUSPLUS || element.operationToken == KtTokens.MINUSMINUS

        else -> false
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
        hoistSubjectMetatable(e, subject)

        var tail: List<LuaStmt>? = null
        for (entry in e.entries.reversed()) {
            val bodyExpr = entry.expression ?: continue
            val body = if (sink == null) collect { block(bodyExpr) } else valueInto(bodyExpr, sink)
            // a guard (`is Int if x > 0 ->`, `else if ready ->`) is evaluated only when the conditions hold
            val guard = entry.guard?.getExpression()
            if (entry.isElse && guard == null) {
                tail = body
            } else {
                val (cond, pre) = withPreceding {
                    val conditions = entry.conditions.map { c -> { condition(c, subject, subjectType) } }
                    val matched = if (conditions.isEmpty()) null else conditions.reduceOr()
                    when {
                        guard == null -> matched!!
                        matched == null -> expression(guard)
                        else -> shortCircuit(LuaBinOp.And, matched) { expression(guard) }
                    }
                }
                tail = pre + LuaIf(cond, body, tail?.takeIf { it.isNotEmpty() })
            }
        }
        subject?.let(subjectMetatables::remove)
        tail?.let { emitAll(it) }
    }

    private fun List<() -> LuaExpr>.reduceOr(): LuaExpr = drop(1).fold(first()()) { acc, next -> shortCircuit(LuaBinOp.Or, acc, next) }

    private fun KaSession.condition(c: KtWhenCondition, subject: LuaExpr?, subjectType: KaType?): LuaExpr = when (c) {
        is KtWhenConditionWithExpression -> {
            val expr = c.expression ?: return LuaNil
            if (subject == null) {
                expression(expr)
            } else {
                equality(subject, subjectType, expression(expr), expr.expressionType, negated = false)
            }
        }

        is KtWhenConditionInRange -> inRangeCondition(c, subject)

        is KtWhenConditionIsPattern -> isPatternCondition(c, subject)

        else -> unsupported(c, "This 'when' condition")
    }

    private fun KaSession.inRangeCondition(c: KtWhenConditionInRange, subject: LuaExpr?): LuaExpr {
        val range = c.rangeExpression?.let { parseRange(it) }
        if (subject != null && range == null) containsCondition(c, subject)?.let { return it }
        if (subject == null || range == null) return unsupported(c, "This 'in' condition")
        return rangeContains(subject, range).let { if (c.isNegated) negate(it) else it }
    }

    /**
     * `in collection ->`, `in "aeiou" ->`: the `contains` call the condition resolves to, with the cached subject as its
     * argument, like `x in collection`.
     */
    private fun KaSession.containsCondition(c: KtWhenConditionInRange, subject: LuaExpr): LuaExpr? {
        val op = c.operationReference
        val call = op.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return null
        val argument = call.valueArgumentMapping.keys.singleOrNull() ?: return null
        overrides[argument] = subject
        val contains = call(op, c.rangeExpression ?: return null)
        return if (c.isNegated) negate(contains) else contains
    }

    private fun KaSession.isPatternCondition(c: KtWhenConditionIsPattern, subject: LuaExpr?): LuaExpr {
        val type = c.typeReference?.type
        if (subject == null || type == null) return LuaNil
        return typeTest(subject, type, c).let { if (c.isNegated) negate(it) else it }
    }

    private fun KaType.isPrimitiveLike() = with(session) {
        isStringType || isCharType || isBooleanType || isIntegral || isDoubleType ||
            isFloatType
    }

    /** Whether [typeTest] can test [declaredType] (type parameters and unmapped library types cannot be told at run time). */
    internal fun KaSession.isTestable(declaredType: KaType): Boolean {
        val type = reifiedType(declaredType)
        if (type.isPrimitiveLike()) return true
        val symbol = type.expandedSymbol ?: return false
        val psi = symbol.psi as? KtClassOrObject
        return symbol.classId?.asString() in setOf("kotlin/Any", "kotlin/Unit") ||
            type.collectionKind()?.let(LIBRARY_COLLECTION_CLASSES::get) != null ||
            symbol.classId?.asString() in LIBRARY_CLASSES || symbol.classId?.asString() in SAM_MIXINS ||
            symbol.classId?.asString() in TYPE_CHECKS ||
            (psi != null && classes.isSource(psi))
    }

    /** `value is declaredType`; a nullable type (`is String?`, `is T` with `T` reified as `Int?`) also holds for null. */
    internal fun KaSession.typeTest(value: LuaExpr, declaredType: KaType, element: KtElement): LuaExpr {
        val type = reifiedType(declaredType)
        if (!type.isMarkedNullable) return nonNullTypeTest(value, type, element)
        val v = cache(value, "value")
        return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, v, LuaNil), nonNullTypeTest(v, type.withNullability(false), element))
    }

    private fun KaSession.nonNullTypeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr {
        val luaType = when {
            type.isStringType || type.isCharType -> "string"

            type.isBooleanType -> "boolean"

            emulatesLong && type.isLongType -> return l64Member("isLong", value)

            type.isIntegral || type.isDoubleType || type.isFloatType -> {
                val wantInteger = type.isIntegral
                if (target.hasIntegers) {
                    return LuaBinary(
                        LuaBinOp.Eq,
                        luaCall(luaPath("math", "type"), value),
                        LuaString(if (wantInteger) "integer" else "float"),
                    )
                }
                // Without an integer subtype, an Int is an integral number (so 2.0 is Int and Double).
                val isNumber = LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString("number"))
                return if (wantInteger) {
                    LuaBinary(
                        LuaBinOp.And,
                        isNumber,
                        LuaBinary(LuaBinOp.Eq, LuaBinary(LuaBinOp.Mod, value, LuaNumber("1")), LuaNumber("0")),
                    )
                } else {
                    isNumber
                }
            }

            else -> return classTest(value, type, element)
        }
        return LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString(luaType))
    }

    /** `is` against a class or interface: of the program, a library collection or a library exception. */
    private fun KaSession.classTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr {
        val symbol = type.expandedSymbol
        val id = symbol?.classId?.asString()
        val psi = (symbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
        val collection = SPECIFIC_COLLECTION_CLASSES[id] ?: type.collectionKind()?.let(LIBRARY_COLLECTION_CLASSES::get)
        return when {
            id == "kotlin/Any" -> LuaBinary(LuaBinOp.Ne, value, LuaNil)

            id == "kotlin/Unit" -> LuaBinary(LuaBinOp.Eq, value, unitObject())

            // Lua numbers, emulated Longs and BigInteger/BigDecimal
            psi is KtObjectDeclaration -> LuaBinary(LuaBinOp.Eq, value, classRef(psi))

            psi != null && isFinalSourceClass(type) -> finalClassTest(value, classRef(psi))

            psi != null -> lualibCall("InstanceOf", value, classRef(psi))

            type.collectionKind() == CollectionKind.Array -> arrayTypeTest(value, type)

            collection != null -> {
                val test = lualibCall("InstanceOf", value, lualibRef(featureOf(collection), collection))
                // an Iterable that is not a Collection (a class implementing Iterable, a range) has no size
                val sized = if (id in COLLECTION_INTERFACES) {
                    LuaBinary(LuaBinOp.And, test, LuaBinary(LuaBinOp.Ne, LuaIndex(value, LuaString("size")), LuaNil))
                } else {
                    test
                }
                // Kotlin's read-only collections (emptyList(), a class implementing List) are not mutable ones, as on the JVM
                if (id in MUTABLE_INTERFACES) LuaBinary(LuaBinOp.And, sized, negate(LuaIndex(value, LuaString("____readOnly")))) else sized
            }

            id in LIBRARY_CLASSES -> lualibCall("InstanceOf", value, lualibRef(EXCEPTIONS_FEATURE, LIBRARY_CLASSES.getValue(id!!)))

            // a lambda, or an object of a class implementing the interface
            id in SAM_MIXINS -> LuaBinary(
                LuaBinOp.Or,
                LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString("function")),
                lualibCall("InstanceOf", value, lualibRef(SAM_FEATURE, SAM_MIXINS.getValue(id!!))),
            )

            id in TYPE_CHECKS -> {
                val test = LuaCall(lualibRef("TypeChecks", TYPE_CHECKS.getValue(id!!)), listOf(value))
                if (id == "kotlin/Number" && emulatesLong) LuaBinary(LuaBinOp.Or, test, l64Member("isLong", value)) else test
            }

            else -> unsupported(element, "Type check against '${type.pretty()}'")
        }
    }

    // ---- expressions ----

    /** `*array` arguments, expanded with table.unpack. */
    internal val spreads = HashSet<KtExpression>()

    /** Lambdas passed for a parameter of a `fun interface` of the program, by that interface (see FunInterfaces). */
    internal val samConversions = HashMap<KtExpression, KtClass>()

    /** Function values returning Unit passed where a function with a result is expected, see [noteUnitResult]. */
    internal val unitResults = HashSet<KtExpression>()

    /** `getmetatable(subject)` read once before a `when`, by its subject, see [hoistSubjectMetatable]. */
    internal val subjectMetatables: MutableMap<LuaExpr, LuaExpr> = IdentityHashMap()

    /** The comparators built by [fusedComparator], for a `thenBy` on them to extend. */
    internal val fusedComparators: MutableMap<LuaExpr, FusedComparator> = IdentityHashMap()

    /** Values substituted for receiver expressions, e.g. the cached receiver of `a?.b`. */
    internal val overrides = HashMap<KtExpression, LuaExpr>()

    /** The expression in statement position being transformed, whose value (if it is of type Unit) is not used. */
    internal var statementExpression: KtExpression? = null

    fun KaSession.expression(e: KtExpression): LuaExpr = when {
        e !== statementExpression && isUnitValued(e) -> unitValueOf(e)
        convertsUnitFunction(e) -> returningUnit(translated(e))
        else -> translated(e)
    }

    private fun KaSession.translated(e: KtExpression): LuaExpr = overrides[e] ?: when (e) {
        is KtParenthesizedExpression, is KtAnnotatedExpression ->
            ((e as? KtParenthesizedExpression)?.expression ?: (e as? KtAnnotatedExpression)?.baseExpression)?.let { expression(it) }
                ?: LuaNil

        is KtConstantExpression -> constant(e)

        is KtStringTemplateExpression -> template(e)

        is KtNameReferenceExpression -> reference(e)

        is KtBinaryExpression -> binary(e)

        is KtPrefixExpression -> prefix(e)

        is KtPostfixExpression -> postfix(e)

        is KtCallExpression -> uncheckedResult(e, call(e, e))

        is KtDotQualifiedExpression -> uncheckedResult(
            e,
            when (val selector = e.selectorExpression) {
                is KtCallExpression -> call(selector, e)
                is KtNameReferenceExpression -> reference(selector, e)
                else -> unsupported(e, "This qualified expression")
            },
        )

        is KtIfExpression -> if (canTernary(e)) ternary(e) else branchingValue(e)

        is KtWhenExpression, is KtTryExpression -> branchingValue(e)

        is KtThisExpression -> thisRef(e)

        is KtLambdaExpression -> lambda(e)

        is KtObjectLiteralExpression -> objectExpression(e)

        is KtLabeledExpression -> e.baseExpression?.let { expression(it) } ?: LuaNil

        is KtNamedFunction -> function(e)

        // anonymous function
        is KtCallableReferenceExpression -> callableReference(e)

        is KtArrayAccessExpression -> uncheckedResult(e, arrayAccess(e))

        is KtSafeQualifiedExpression -> uncheckedResult(e, safeCall(e))

        is KtThrowExpression -> {
            throwStatement(e)
            LuaNil
        }

        is KtBinaryExpressionWithTypeRHS -> cast(e)

        is KtClassLiteralExpression -> classLiteral(e)

        is KtIsExpression -> {
            val type = e.typeReference?.type
            if (type == null) {
                LuaNil
            } else {
                typeTest(cache(expression(e.leftHandSide), "value"), type, e).let { if (e.isNegated) negate(it) else it }
            }
        }

        else -> unsupported(e, "Expression '${e.javaClass.simpleName.removePrefix("Kt")}'")
    }

    private fun KaSession.constant(e: KtExpression): LuaExpr = constantValue(e.evaluate(), e)

    /** A compile-time constant as a Lua literal; [e] is where an unsupported one is reported. */
    internal fun constantValue(c: KaConstantValue?, e: KtElement): LuaExpr = when (c) {
        is KaConstantValue.IntValue -> LuaNumber(c.value.toString())

        // 9223372036854775808 does not fit a Lua integer, so Long.MIN_VALUE is spelled as a subtraction
        is KaConstantValue.LongValue ->
            if (emulatesLong) {
                long64Literal(c.value)
            } else if (c.value == Long.MIN_VALUE) {
                LuaBinary(LuaBinOp.Sub, LuaNumber("-9223372036854775807"), LuaNumber("1"))
            } else {
                LuaNumber(c.value.toString())
            }

        is KaConstantValue.ShortValue -> LuaNumber(c.value.toString())

        is KaConstantValue.ByteValue -> LuaNumber(c.value.toString())

        is KaConstantValue.DoubleValue -> floatingLiteral(c.value)

        is KaConstantValue.FloatValue -> floatingLiteral(c.value.toDouble())

        is KaConstantValue.UIntValue -> unsignedLiteral(c.value.toULong())

        is KaConstantValue.ULongValue -> unsignedLiteral(c.value)

        is KaConstantValue.UShortValue -> unsignedLiteral(c.value.toULong())

        is KaConstantValue.UByteValue -> unsignedLiteral(c.value.toULong())

        is KaConstantValue.BooleanValue -> LuaBool(c.value)

        is KaConstantValue.CharValue -> LuaString(c.value.toString())

        is KaConstantValue.StringValue -> LuaString(c.value)

        is KaConstantValue.NullValue -> LuaNil

        null -> unsupported(e, "Non-constant literal")

        else -> unsupported(e, "Constant of type ${c.javaClass.simpleName}")
    }

    /** Lua 5.1 merges the constants 0.0 and -0.0 of a function, so a negative zero is computed there. */
    internal fun floatingLiteral(d: Double): LuaExpr = if (target == LuaTarget.Lua51 && d == 0.0 && 1 / d < 0) {
        LuaBinary(LuaBinOp.Div, LuaNumber("1"), LuaUnary(LuaUnOp.Neg, luaPath("math", "huge")))
    } else {
        doubleLiteral(d)
    }

    private fun KaSession.template(e: KtStringTemplateExpression): LuaExpr {
        val parts = mutableListOf<LuaExpr>()
        var lone: Pair<KtExpression, LuaExpr>? = null
        var hasChar = false
        val pending = StringBuilder()
        fun flush() {
            if (pending.isNotEmpty()) parts += LuaString(pending.toString())
            pending.clear()
        }
        // A later entry that needs statements (an expanded inline call) must not run before the earlier entries.
        val exprs = e.entries.mapNotNull { (it as? KtStringTemplateEntryWithExpression)?.expression }
        val texts = if (exprs.size > 1) orderedTexts(exprs) else null
        val values = (texts ?: ordered(exprs, unlessReads = true)).iterator()
        for (entry in e.entries) {
            when (entry) {
                is KtLiteralStringTemplateEntry -> pending.append(entry.text)

                is KtEscapeStringTemplateEntry -> pending.append(entry.unescapedValue)

                is KtStringTemplateEntryWithExpression -> {
                    val expr = entry.expression ?: continue
                    flush()
                    val value = values.next()
                    lone = expr to value
                    if (expr.expressionType?.isCharType == true && expr.evaluate() == null) hasChar = true
                    parts += if (texts != null) value else str(value, templateType(expr), forConcat = true)
                }
            }
        }
        flush()
        return joined(templateParts(parts, lone), hasChar)
    }

    /**
     * The text of each template entry, ordered like [ordered]; an entry is turned into text where the JVM appends it, so a later
     * entry that is computed first (`"$list ${list.removeLastOrNull()?.x}"`) can't change what an earlier object prints.
     */
    private fun KaSession.orderedTexts(exprs: List<KtExpression>): List<LuaExpr> {
        val results = exprs.map { expr -> withPreceding { str(expression(expr), templateType(expr), forConcat = true) } }
        val last = results.indexOfLast { (_, pre) -> pre.any { !isLocalRead(it) } }
        return results.mapIndexed { i, (text, pre) ->
            emitAll(pre)
            if (i < last) cache(text, "arg") else text
        }
    }

    /**
     * The type a template prints [expr] by. A platform type may be null, except for a parameter of a lambda converted to a Java
     * interface (`Comparator { a, b -> }`, `stream.peek { }`), which the library calls with its own elements.
     */
    private fun KaSession.templateType(expr: KtExpression): KaType? {
        val type = expr.expressionType
        if (type !is KaFlexibleType) return type
        val symbol = (KtPsiUtil.safeDeparenthesize(expr) as? KtNameReferenceExpression)?.mainReference?.resolveToSymbol()
        val lambdaParameter = symbol is KaValueParameterSymbol && symbol.containingDeclaration is KaAnonymousFunctionSymbol
        return if (lambdaParameter) type.lowerBound else type
    }

    private fun KaSession.templateParts(parts: List<LuaExpr>, lone: Pair<KtExpression, LuaExpr>?): LuaExpr = when (parts.size) {
        0 -> LuaString("")

        // "$x" on its own still has to produce a string.
        1 -> lone?.let { (expr, value) -> str(value, expr.expressionType) } ?: parts[0]

        else -> parts.reduceRight { part, acc -> LuaBinary(LuaBinOp.Concat, part, acc) }
    }

    /**
     * Converts [value] to a string the way Kotlin's `toString()` would. With [forConcat], numbers that
     * Lua's `..` already formats identically are left alone.
     */
    fun KaSession.str(value: LuaExpr, type: KaType?, forConcat: Boolean = false): LuaExpr {
        if (!target.hasIntegers && type?.holdsOnlyDoubles() == true) return lualibCall("StrDoubles", value)
        val t = type?.takeUnless { it.isMarkedNullable || isPlatformNullable(it) } ?: return nullableStr(value, type)
        return when {
            t.withoutFlexibility.isFloatType -> lualibCall("FloatToString", value)

            // At runtime 2.0 and 2 look the same without integers, so use the static type.
            (!target.hasIntegers || usesFloat) && t.withoutFlexibility.isDoubleType ->
                lualibCall("DoubleToString", value)

            // tostring() keeps only 14 digits of a large Long when numbers are doubles.
            !target.hasIntegers && t.withoutFlexibility.isLongType -> lualibCall("Str", value)

            t.withoutFlexibility.isULongType ->
                LuaCall(LuaIndex(lualibRef("Unsigned", "__K2L_Unsigned"), LuaString("toString")), listOf(value))

            t.isStringType || t.isCharType -> value

            t.isUnitType && (value is LuaName || value is LuaNil) -> LuaString("kotlin.Unit")

            t.isIntegral -> if (forConcat) value else luaCall(LuaName("tostring"), value)

            t.isBooleanType -> luaCall(LuaName("tostring"), value)

            else -> lualibCall("Str", value)
        }
    }

    /** A `Double?` or `Float?` prints by its static type too (the lualib functions print nil as "null"). */
    private fun KaSession.nullableStr(value: LuaExpr, type: KaType?): LuaExpr =
        when ((type?.withoutFlexibility as? KaClassType)?.classId?.asString()) {
            "kotlin/Float" -> lualibCall("FloatToString", value)
            "kotlin/Double" if !target.hasIntegers || usesFloat -> lualibCall("DoubleToString", value)
            else -> lualibCall("Str", value)
        }

    /**
     * A platform type from a Java method (`treeMap.higherKey(k)` is `Int!`) may be null; Java strings, and the floating-point
     * types that print by their static type, are taken as non-null.
     */
    private fun KaSession.isPlatformNullable(type: KaType): Boolean = type is KaFlexibleType && type.upperBound.isMarkedNullable &&
        type.lowerBound.let { !it.isStringType && !it.isDoubleType && !it.isFloatType }

    fun lualibCall(feature: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(lualibRef(feature, Lualib.functionName(feature)), args.toList())

    internal fun KaSession.reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr {
        val symbol = e.mainReference.resolveToSymbol()
        val psi = symbol?.psi
        val bound = (symbol as? KaValueParameterSymbol)?.let { lambdaBinding(it, e) }
        return when {
            interop.isExternal(symbol) && symbol !is KaClassLikeSymbol -> call(e, full)

            bound != null -> bound

            isSourceDelegatedVariable(psi) -> delegatedVariableRead(psi as KtProperty)

            symbol is KaLocalVariableSymbol || symbol is KaValueParameterSymbol -> {
                val name = LuaName(naming.renamed(psi) ?: LuaNames.of(symbol.name.asString()))
                if (symbol is KaValueParameterSymbol || (symbol as KaLocalVariableSymbol).isVal) stable += name
                lateinitRead(psi, name)
            }

            isSourceAccessorProperty(symbol, psi) -> accessorPropertyRead(psi as KtProperty)

            isSourceTopLevelProperty(symbol, psi) -> lateinitRead(psi, topLevelRef(psi as KtProperty))

            symbol is KaBackingFieldSymbol -> backingField(e)

            symbol is KaEnumEntrySymbol && psi is KtEnumEntry && classes.isSource(psi) ->
                LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(psi.name!!))

            symbol is KaClassLikeSymbol -> classValue(e, symbol, psi) ?: call(e, full)

            else -> call(e, full)
        }
    }

    /** A class or object named as a value; `Foo` is its companion, which is not the class table when it has one of its own. */
    private fun KaSession.classValue(e: KtNameReferenceExpression, symbol: KaClassLikeSymbol, psi: PsiElement?): LuaExpr? {
        val companion = (e.expressionType?.expandedSymbol?.psi as? KtObjectDeclaration)?.takeIf { hasOwnTable(it) && classes.isSource(it) }
        val target = companion ?: psi
        val value = classLikeReference(symbol, target) ?: return if (isBasicCompanion(e)) LuaNil else null
        return if (initializesOnUse(e, target)) lualibCall("TouchObject", value) else value
    }

    /** `Long` in `Long.parse(s)`, a call of an extension of `Long.Companion`: the companions of the basic types only hold constants. */
    private fun KaSession.isBasicCompanion(e: KtNameReferenceExpression): Boolean =
        (e.expressionType?.withoutFlexibility as? KaClassType)?.classId?.asString() in BASIC_COMPANIONS

    /** A class or object used as a value: an external Lua table, a library object or a source class. */
    private fun KaSession.classLikeReference(symbol: KaClassLikeSymbol, psi: PsiElement?): LuaExpr? = when {
        interop.isExternal(symbol) -> interop.externalClassRef(symbol as KaClassSymbol) ?: LuaName("_G")
        symbol.classId?.asString() in LIBRARY_OBJECTS -> libraryObject(symbol.classId!!.asString())
        psi is KtClassOrObject && classes.isSource(psi) -> classRef(psi)
        else -> null
    }

    /** An object with observable initialization used as a value (not as the qualifier of a member): that initializes it. */
    private fun initializesOnUse(e: KtNameReferenceExpression, psi: PsiElement?): Boolean {
        // (a companion without a table of its own is its class's table, which is armed for the companion's initialization)
        if (psi !is KtObjectDeclaration || !lazyInit.isObservable(psi)) return false
        val parent = e.parent
        val qualified = if (parent is KtDotQualifiedExpression && parent.selectorExpression == e) parent else e
        val outer = qualified.parent
        return !(outer is KtDotQualifiedExpression && outer.receiverExpression == qualified)
    }

    private fun isSourceTopLevelProperty(symbol: KaSymbol?, psi: PsiElement?) =
        symbol is KaPropertySymbol && psi is KtProperty && classes.isSource(psi) && psi.isTopLevel && psi.receiverTypeReference == null

    /** A top-level property with custom accessors, read through `getX()`. */
    private fun isSourceAccessorProperty(symbol: KaSymbol?, psi: PsiElement?) =
        isSourceTopLevelProperty(symbol, psi) && (psi as KtProperty).hasAccessorFunctions()

    /**
     * The value an inlined lambda's parameter was bound to, if any; for a lambda parameter of an inlined function passed on to
     * a function that is not expanded, the lambda as a closure.
     */
    private fun KaSession.lambdaBinding(symbol: KaValueParameterSymbol, e: KtNameReferenceExpression): LuaExpr? {
        if (lambdaBindings.isNotEmpty()) {
            symbol.containingDeclaration?.psi?.let {
                lambdaBindings[it to symbol.name.asString()]
            }?.let { return it }
        }
        return inlinedLambdaOf(e)?.let { inCallerContext(it) { lambda(it.expr) } }
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
                val contains = if (range != null) rangeContains(left, range) else call(e, e)
                if (token == KtTokens.NOT_IN) negate(contains) else contains
            }

            KtTokens.RANGE, KtTokens.RANGE_UNTIL -> call(e, e)

            KtTokens.IDENTIFIER -> call(e, e)

            KtTokens.EQEQ, KtTokens.EXCLEQ -> {
                val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
                byteComparison(equality(l, left.expressionType, r, right.expressionType, negated = token == KtTokens.EXCLEQ))
            }

            in BINARY_OPERATORS -> {
                foldedInt(e)?.let { return it }
                if (token in ARITHMETIC && callsOperator(e, left, right)) return call(e, e)
                val (l, r) = ordered(listOf(left, right)).let { it[0] to it[1] }
                operator(BINARY_OPERATORS.getValue(token), l, left.expressionType, r, right.expressionType, e)
            }

            else -> unsupported(e, "Operator '${e.operationReference.text}'")
        }
    }

    /**
     * An arithmetic operator that is a call: `operator fun plus` etc., including extensions such as Int.times(String), and a
     * library operator on a number, such as Int.times(Duration).
     */
    private fun KaSession.callsOperator(e: KtBinaryExpression, left: KtExpression, right: KtExpression): Boolean {
        val numberOperator = left.expressionType?.isNumber == true && !isPrimitiveOperand(right.expressionType)
        return !isPrimitiveOperand(left.expressionType) || numberOperator || isSourceOperator(e)
    }

    /** `left op right` for `and`/`or`, keeping [right]'s preceding statements behind the short circuit. */
    internal fun shortCircuit(op: LuaBinOp, left: LuaExpr, right: () -> LuaExpr): LuaExpr {
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
        val numeric = both(lt, rt) { it.isNumber }
        return charArithmetic(op, l, lt, r, rt) ?: when (op) {
            LuaBinOp.Add -> when {
                lt?.isStringType == true -> joined(
                    LuaBinary(LuaBinOp.Concat, str(l, lt, forConcat = true), str(r, rt, forConcat = true)),
                    rt?.isCharType == true,
                )

                numeric -> arithmetic(op, l, lt, r, rt)

                else -> unsupported(element, "'+' on '${lt.pretty()}'")
            }

            LuaBinOp.Sub, LuaBinOp.Mul ->
                if (numeric) arithmetic(op, l, lt, r, rt) else unsupported(element, "Arithmetic on '${lt.pretty()}'")

            LuaBinOp.Div -> when {
                numeric && both(lt, rt) { it.isIntegral } -> integerDivision(l, lt, r, rt)
                numeric -> floatDivision(l, lt, r, rt)
                else -> unsupported(element, "'/' on '${lt.pretty()}'")
            }

            LuaBinOp.Mod -> if (numeric) remainder(l, lt, r, rt) else unsupported(element, "'%' on '${lt.pretty()}'")

            LuaBinOp.Eq, LuaBinOp.Ne -> LuaBinary(op, l, r)

            LuaBinOp.Lt, LuaBinOp.Gt, LuaBinOp.Le, LuaBinOp.Ge ->
                // strings compare by UTF-16 unit, which differs from the byte order for supplementary characters
                if (numeric || comparesNatively(lt, rt)) {
                    long64Comparison(op, l, lt, r, rt) ?: unsignedLongComparison(op, l, lt, r, rt) ?: LuaBinary(op, l, r)
                } else {
                    LuaBinary(op, lualibCall("Compare", l, r), LuaNumber("0"))
                }

            // Comparable.compareTo
            else -> LuaBinary(op, l, r)
        }
    }

    /** A concatenation involving Chars: with `--strings utf16`, two surrogate halves next to each other become one character. */
    private fun joined(concatenation: LuaExpr, hasChar: Boolean): LuaExpr = if (utf16 && hasChar) u16Norm(concatenation) else concatenation

    /** Texts compare with Lua's `<`, except two Strings with `--strings utf16`, which go through `__K2L_Compare` (UTF-16 order). */
    internal fun KaSession.comparesNatively(lt: KaType?, rt: KaType?): Boolean {
        val strings = lt?.isStringType == true && rt?.isStringType == true
        return lt.isTextual && rt.isTextual && !(utf16 && strings)
    }

    private fun both(lt: KaType?, rt: KaType?, test: (KaType) -> Boolean) = listOfNotNull(lt, rt).let { it.size == 2 && it.all(test) }

    /** Chars are one-character strings: 'c' - 'a' is an Int, 'a' + 1 is a Char. */
    private fun KaSession.charArithmetic(op: LuaBinOp, l: LuaExpr, lt: KaType?, r: LuaExpr, rt: KaType?): LuaExpr? {
        val addOrSub = op == LuaBinOp.Add || op == LuaBinOp.Sub
        if (lt?.isCharType != true || lt.isMarkedNullable || !addOrSub) return null
        if (op == LuaBinOp.Add && rt?.isStringType == true) return joined(LuaBinary(LuaBinOp.Concat, l, r), true) // 'a' + "bc" is a String
        val code = if (utf16) u16("code", l) else LuaMethodCall(l, "byte", emptyList())
        return if (rt?.isCharType == true) {
            LuaBinary(LuaBinOp.Sub, code, if (utf16) u16("code", r) else LuaMethodCall(r, "byte", emptyList()))
        } else if (utf16) {
            u16("char", LuaBinary(op, code, r))
        } else {
            luaCall(luaPath("string", "char"), LuaBinary(op, code, r))
        }
    }

    private fun KaSession.prefix(e: KtPrefixExpression): LuaExpr {
        val base = e.baseExpression ?: return LuaNil
        return when (e.operationToken) {
            KtTokens.MINUS, KtTokens.PLUS, KtTokens.EXCL ->
                if (isPrimitiveOperand(base.expressionType) && !isSourceOperator(e)) primitivePrefix(e, base) else call(e, e)

            KtTokens.PLUSPLUS, KtTokens.MINUSMINUS -> {
                val target = assignTarget(base) ?: return LuaNil
                increment(e, target)
                target.read
            }

            else -> unsupported(e, "Prefix operator '${e.operationReference.text}'")
        }
    }

    /** Whether an operator expression calls an `operator fun` of this program, e.g. an extension `Int.times(String)`. */
    private fun KaSession.isSourceOperator(e: KtExpression): Boolean =
        e.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol?.psi.let { it is KtNamedFunction && classes.isSource(it) }

    /** With `--int-overflow wrap`, a constant `Int` expression is the value the Kotlin compiler computes (it wraps). */
    private fun KaSession.foldedInt(e: KtExpression): LuaExpr? = when {
        wrapsInt && e.expressionType?.isIntType == true && e.evaluate() is KaConstantValue.IntValue -> constant(e)

        // a constant Long expression such as -5000000000000000000L or 60L * 60 * 24 * 365 * 1000000000 is one literal
        emulatesLong && isWide(e.expressionType) && e.evaluate().let {
            it is KaConstantValue.LongValue || it is KaConstantValue.ULongValue
        } ->
            constant(e)

        else -> null
    }

    private fun KaSession.primitivePrefix(e: KtPrefixExpression, base: KtExpression): LuaExpr = foldedInt(e) ?: negativeLiteral(e, base)
        ?: when (e.operationToken) {
            KtTokens.MINUS -> negation(expression(base), base.expressionType)
            KtTokens.PLUS -> expression(base)
            else -> negate(expression(base))
        }

    /**
     * `-2147483648` and `-9223372036854775808` (and -128 and -32768 as a Byte or Short): the literal after the minus does not
     * fit its type and evaluates to the negative value already, so the whole expression is the literal (negating it again
     * would give +2147483648).
     */
    private fun KaSession.negativeLiteral(e: KtPrefixExpression, base: KtExpression): LuaExpr? {
        if (e.operationToken != KtTokens.MINUS || base !is KtConstantExpression) return null
        return when (val v = e.evaluate()) {
            is KaConstantValue.IntValue -> v.value.takeIf { it == Int.MIN_VALUE }?.let { constantValue(v, e) }

            is KaConstantValue.LongValue -> v.value.takeIf { it == Long.MIN_VALUE }?.let { constantValue(v, e) }

            // byteArrayOf(-128), shortArrayOf(-32768)
            is KaConstantValue.ByteValue -> v.value.takeIf { it == Byte.MIN_VALUE }?.let { constantValue(v, e) }

            is KaConstantValue.ShortValue -> v.value.takeIf { it == Short.MIN_VALUE }?.let { constantValue(v, e) }

            else -> null
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
     * results are cached in locals first so evaluation order is preserved; with [unlessReads], statements that only compute
     * values without calls into locals (`local ____receiver = a.b` of `a.b?.c`) do not count.
     */
    internal fun KaSession.ordered(exprs: List<KtExpression>, unlessReads: Boolean = false): List<LuaExpr> {
        val results = exprs.map { withPreceding { expression(it) } }
        val last = results.indexOfLast { (_, pre) -> if (unlessReads) pre.any { !isLocalRead(it) } else pre.isNotEmpty() }
        return results.mapIndexed { i, (value, pre) ->
            emitAll(pre)
            if (i < last) cache(touchedIfCached(exprs[i], value), "arg") else value
        }
    }

    private fun isLocalRead(stmt: LuaStmt): Boolean = stmt is LuaLocal && stmt.values.all(::isRead)

    /** Reads and operators, no calls: a local holding one can be computed before or after the expressions around it. */
    private fun isRead(e: LuaExpr): Boolean = when (e) {
        is LuaIndex -> isRead(e.target) && isRead(e.key)
        is LuaBinary -> isRead(e.left) && isRead(e.right)
        is LuaUnary -> isRead(e.operand)
        else -> isStable(e) || e is LuaName
    }

    /**
     * An object (or companion) with observable initialization named as a qualifier (`Registry.register(...)`) is initialized when
     * the member is reached; when the qualifier is cached in a local because a later argument needs statements, the JVM has
     * already initialized it by then, so the cached value touches it.
     */
    private fun KaSession.touchedIfCached(expr: KtExpression, value: LuaExpr): LuaExpr {
        if ((expr.parent as? KtQualifiedExpression)?.receiverExpression != expr) return value // a value is touched already
        val name = when (val e = KtPsiUtil.safeDeparenthesize(expr)) {
            is KtNameReferenceExpression -> e
            is KtDotQualifiedExpression -> e.selectorExpression as? KtNameReferenceExpression
            else -> null
        } ?: return value
        if (name.mainReference.resolveToSymbol() !is KaClassLikeSymbol) return value
        val target = name.expressionType?.expandedSymbol?.psi as? KtObjectDeclaration ?: return value
        return if (lazyInit.isObservable(target)) lualibCall("TouchObject", value) else value
    }

    // ---- calls ----

    /**
     * A resolved call or property access. [element] is what the Analysis API resolves (a call,
     * name reference or infix binary expression); [full] includes any explicit receiver.
     */
    internal fun KaSession.call(element: KtExpression, full: KtExpression): LuaExpr {
        val call = element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
            ?: return unsupported(full, "Unresolved call '${full.text}'")
        recordUnmappedArguments(call, element)
        return catchingJumps(call, full) { shortcutCall(call, full) ?: callWithReceiver(call, full) }
    }

    /** Arguments by call whose parameter the Analysis API leaves out of `valueArgumentMapping`, e.g. `f(x !in y)`. */
    private val unmappedArguments = java.util.IdentityHashMap<KaCallableMemberCall<*, *>, Map<KtExpression, KaValueParameterSymbol>>()

    private fun KaSession.recordUnmappedArguments(call: KaCallableMemberCall<*, *>, element: KtExpression) {
        if (call !is KaFunctionCall<*>) return
        val args = (element as? KtCallElement)?.valueArguments?.map { it.getArgumentExpression() } ?: return
        val mapped = call.valueArgumentMapping.keys
        val parameters = call.signature.symbol.valueParameters

        // arguments past the end of the parameter list belong to a trailing vararg
        fun parameterAt(i: Int) = parameters.getOrNull(i) ?: parameters.lastOrNull()?.takeIf { it.isVararg }
        val missing = args.withIndex().filter { (i, arg) -> arg != null && arg !in mapped && parameterAt(i) != null }
        if (missing.isNotEmpty()) unmappedArguments[call] = missing.associate { (i, arg) -> arg!! to parameterAt(i)!! }
    }

    private fun KaSession.shortcutCall(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr? {
        val symbol = call.partiallyAppliedSymbol.symbol
        val isInvoke = symbol.callableId?.callableName?.asString() == "invoke"
        return when {
            // Library constants such as Int.MAX_VALUE fold to literals; their receiver is not a value.
            call !is KaFunctionCall<*> && !StdlibMappings.has(symbol.callableId?.toString()) && full.evaluate() != null -> constant(full)

            isInvoke && call.partiallyAppliedSymbol.dispatchReceiver?.type is KaFunctionType ->
                invokeFunctionValue(call, full)

            else -> null
        }
    }

    private fun KaSession.callWithReceiver(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr {
        val pas = call.partiallyAppliedSymbol
        val symbol = pas.symbol
        val receiverValue = (pas.extensionReceiver ?: pas.dispatchReceiver)?.takeUnless { isNoValueReceiver(it, symbol) }
        val receiverExpr = receiverValue?.let { explicitReceiver(it) }
        val implicit = if (receiverValue != null && receiverExpr == null) {
            implicitReceiver(receiverValue, full) ?: return LuaNil
        } else {
            null
        }
        if (interop.isExternal(symbol)) return externalCall(call, receiverExpr, implicit, full)
        memberExtensionAccess(call, full)?.let { return it }
        userInlineCall(call, full)?.let { return it }
        val id = libraryCallableId(symbol)
        return delegateFactory(id, call)
            ?: dataClassMember(call, receiverExpr, implicit)
            ?: inlinedCollectionCall(id, call, receiverExpr, implicit, full)
            ?: loopedListOfSize(id, call)
            ?: scopeFunction(id, call, receiverExpr, implicit)
            ?: declaredCall(call, receiverExpr, implicit, receiverValue?.type, full)
    }

    private fun KaSession.declaredCall(
        call: KaCallableMemberCall<*, *>,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        receiverType: KaType?,
        full: KtExpression,
    ): LuaExpr {
        val symbol = call.partiallyAppliedSymbol.symbol
        val psi = symbol.psi
        val args = callArguments(call)
        val inFile = classes.isSource(psi)
        val enumMember = if (psi == null || psi is KtClass) enumStaticMember(symbol, args) else null
        return when {
            symbol is KaConstructorSymbol -> constructorCall(symbol, psi, args, full, receiverOperand(implicit, receiverExpr))

            symbol is KaSamConstructorSymbol && sourceFunInterface(symbol.returnType) != null ->
                funInterfaceObject(sourceFunInterface(symbol.returnType)!!, arguments(emptyList(), args)[0])

            inFile && psi is KtNamedFunction -> sourceFunctionCall(psi, args, receiverExpr, implicit)

            inFile && isMemberProperty(psi) -> memberPropertyRead(psi as KtNamedDeclaration, receiverExpr, implicit, full)

            inFile && psi is KtProperty && psi.receiverTypeReference != null -> extensionPropertyRead(psi, receiverExpr, implicit)

            receiverExpr is KtSuperExpression -> collectionSuperCall(symbol, args, receiverType, full) ?: librarySuperCall(symbol, args)
                ?: unsupported(full, "Calling a library member through 'super'")

            enumMember != null -> enumMember

            else -> libraryCall(
                symbol.callableId?.callableName?.asString(),
                libraryCallableId(symbol),
                receiverExpr,
                implicit,
                receiverType,
                args,
                full,
                (call as? KaFunctionCall<*>)?.symbol?.valueParameters?.map { it.returnType }.orEmpty(),
            )
        }
    }

    /**
     * The id mappings know a library member by: a member a class of the program inherits from a library class
     * (`MyList.contains` of `AbstractList<Int>`) is a fake override with the subclass's id, so the original's is used.
     */
    internal fun KaSession.libraryCallableId(symbol: KaCallableSymbol): String? {
        val own = symbol.callableId
        if (own?.classId?.let(classes::classInFile) == null || classes.isSource(symbol.psi)) return own?.toString()
        return symbol.fakeOverrideOriginal.callableId?.toString()
    }

    /** Invoking a function value: the value is the dispatch receiver; a receiver of `T.() -> R` is the first argument. */
    private fun KaSession.invokeFunctionValue(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr =
        inlinedParameterCall(call, full) ?: callFunctionValue(call, full)

    private fun KaSession.callFunctionValue(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr {
        val pas = call.partiallyAppliedSymbol
        val fnValue = receiverOperand(pas.dispatchReceiver!!, full) ?: return LuaNil
        val extension = pas.extensionReceiver?.let { receiverOperand(it, full) ?: return LuaNil }
        val values = arguments(listOf(fnValue) + listOfNotNull(extension), invokeArguments(call))
        return LuaCall(values[0], values.drop(1))
    }

    /** Arguments of `invoke`: with `receiver.f(a)` the function's receiver parameter is not among them. */
    internal fun KaSession.invokeArguments(call: KaCallableMemberCall<*, *>): List<KtExpression?> =
        callArguments(call).let { if (call.partiallyAppliedSymbol.extensionReceiver != null) it.drop(1) else it }

    /** A constructor of a class in this program, a library exception, or a mapped collection class. */
    private fun KaSession.constructorCall(
        symbol: KaConstructorSymbol,
        psi: com.intellij.psi.PsiElement?,
        args: List<KtExpression?>,
        full: KtExpression,
        outer: Operand?,
    ): LuaExpr {
        val classId = symbol.containingClassId
        (classId?.let(classes::classInFile) ?: localClassOf(psi, classId))?.let { cls ->
            val outers = if (isInner(
                    cls,
                )
            ) {
                listOf(outer ?: return unsupported(full, "Inner class constructor without an outer instance"))
            } else {
                emptyList()
            }
            return LuaCall(LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi))), arguments(outers, args))
        }
        LIBRARY_CLASSES[classId?.asString()]?.takeIf { classId?.relativeClassName?.asString() !in FORMATTER_EXCEPTIONS }?.let { lua ->
            return LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, lua), LuaString("new")), throwableArguments(args, symbol.valueParameters))
        }
        val site =
            CallSite(this, this@FileTransformer, full, null, null, null, arguments(emptyList(), args), args.map { it?.expressionType })
        return FactoryMappings.construct(classId?.asString(), site) ?: TimeMappings.construct(classId?.asString(), site)
            ?: JavaUtilMappings.construct(classId?.asString(), site)
            ?: unsupported(full, "Constructing library class '${classId?.asSingleFqName()}'")
    }

    /** The class a constructor of a local class belongs to: local classes have no class id to look up. */
    private fun localClassOf(constructor: com.intellij.psi.PsiElement?, classId: org.jetbrains.kotlin.name.ClassId?): KtClassOrObject? =
        if (classId == null) (constructor as? KtClassOrObject) ?: (constructor as? KtConstructor<*>)?.getContainingClassOrObject() else null

    /** A top-level or extension function, or a method (including `super.method()`), declared in this program. */
    internal fun KaSession.sourceFunctionCall(
        psi: KtNamedFunction,
        args: List<KtExpression?>,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
    ): LuaExpr {
        if (psi.containingClassOrObject == null) {
            // Extension functions take their receiver as the first argument.
            val receivers = if (psi.receiverTypeReference !=
                null
            ) {
                listOf(receiverOperand(implicit, receiverExpr) ?: return LuaNil)
            } else {
                emptyList()
            }
            val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
            return LuaCall(fn, arguments(receivers, args))
        }
        val method = naming.function(psi)
        if (receiverExpr is KtSuperExpression) {
            // The resolved declaration is the implementation `super` reaches, in a class or interface.
            return LuaCall(
                LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(method)),
                listOf(selfRef()) + arguments(emptyList(), args),
            )
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

            is KtSuperExpression -> {
                // the implementation `super` reaches, called statically
                if (hasAccessors(property)) {
                    return LuaCall(LuaIndex(classRef(ownerClass(property)!!), LuaString(accessorName("get", property))), listOf(selfRef()))
                }
                selfRef()
            }

            // a field overridden in a subclass shares storage with the base
            else -> expression(receiverExpr)
        }
        return propertyRead(receiver, property)
    }

    /** A receiver that is not a value: a library class named as a qualifier, or the enum class of `entries` in its companion. */
    private fun KaSession.isNoValueReceiver(value: KaReceiverValue, symbol: KaCallableSymbol): Boolean =
        isLibraryClassQualifier(value) || isEnumStaticMember(symbol)

    /** Whether [symbol] is `values()`, `entries` or `valueOf` of an enum class: its implicit receiver (in a companion) is not a value. */
    private fun KaSession.isEnumStaticMember(symbol: KaCallableSymbol): Boolean {
        val psi = symbol.psi
        if (psi != null && psi !is KtClass) return false
        val name = symbol.callableId?.callableName?.asString()
        return (name == "values" || name == "entries" || name == "valueOf") &&
            (symbol.callableId?.classId?.let(classes::classInFile) as? KtClass)?.isEnum() == true
    }

    /** `values()`, `entries` and `valueOf(name)` of an enum class declared in this program. */
    private fun KaSession.enumStaticMember(symbol: KaCallableSymbol, args: List<KtExpression?>): LuaExpr? {
        val psi = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass ?: return null
        if (!psi.isEnum()) return null
        return when (symbol.callableId?.callableName?.asString()) {
            "values", "entries" -> lualibCall("EnumValues", classRef(psi))
            "valueOf" -> lualibCall("EnumValueOf", classRef(psi), arguments(emptyList(), args)[0])
            else -> null
        }
    }

    /** A Kotlin standard library call, translated through [StdlibMappings]. */
    internal fun KaSession.libraryCall(
        name: String?,
        callableId: String?,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        receiverValueType: KaType?,
        args: List<KtExpression?>,
        full: KtExpression,
        parameterTypes: List<KaType?> = emptyList(),
    ): LuaExpr {
        val values = arguments(listOfNotNull(receiverOperand(implicit, receiverExpr)), args)
        val hasReceiver = implicit != null || receiverExpr != null
        val receiverType = receiverExpr?.expressionType ?: receiverValueType
        val argTypes = args.map { it?.expressionType }
        // an object implementing CharSequence is passed to the String functions as its text (its toString() is its own)
        val textReceiver = hasReceiver && isTextReceiver(name, receiverType)
        val argValues = charSequenceArguments(if (hasReceiver) values.drop(1) else values, argTypes, parameterTypes)
        if (textReceiver) charSequenceMember(callableId, values[0], argValues)?.let { return it }
        val site = CallSite(
            session = this,
            transformer = this@FileTransformer,
            element = full,
            name = name,
            receiver = if (textReceiver) charSequenceText(values[0], receiverType) else values.firstOrNull()?.takeIf { hasReceiver },
            receiverType = if (textReceiver) builtinTypes.string else receiverType,
            // omitted trailing arguments are nil; spread arguments may stand for several (`__K2L_Spread`), which must stay last
            args = argValues.let { a -> if (args.any { it in spreads }) a else a + List(maxOf(0, args.size - a.size)) { LuaNil } },
            argTypes = argTypes,
            parameterTypes = parameterTypes,
        )
        StdlibMappings.map(callableId, site)?.let { return it }
        return unsupported(full, "Library API '${callableId?.replace('/', '.') ?: full.text}'")
    }

    /** A receiver as an operand: either an explicit expression (transformed later, in order) or an implicit `this`. */
    internal fun KaSession.receiverOperand(value: KaReceiverValue, element: KtElement): Operand? =
        explicitReceiver(value)?.asOperand() ?: implicitReceiver(value, element)?.asOperand()

    /** The implicit `this` if there is one, else the explicit receiver expression; null if neither. */
    internal fun receiverOperand(implicit: LuaExpr?, explicit: KtExpression?): Operand? = implicit?.asOperand() ?: explicit?.asOperand()

    /**
     * Transforms the [Operand.Source]s among [receivers] and then [args] in source order. Omitted
     * arguments become nil so later ones keep their position; trailing omitted ones are dropped.
     */
    internal fun KaSession.arguments(receivers: List<Operand>, args: List<KtExpression?>): List<LuaExpr> {
        val operands = receivers + args.map { it?.asOperand() }
        val transformed = ordered(operands.filterIsInstance<Operand.Source>().map { it.expr }).iterator()
        val firstSpread = operands.indexOfFirst { it is Operand.Source && it.expr in spreads }
        if (firstSpread >= 0 && firstSpread < operands.lastIndex) return spreadArguments(operands, transformed, firstSpread)
        val values = operands.map { item ->
            when (item) {
                is Operand.Source -> transformed.next().let {
                    if (item.expr in
                        spreads
                    ) {
                        lualibCall("Unpack", it)
                    } else {
                        converted(item.expr, it)
                    }
                }

                is Operand.Value -> item.lua

                null -> null // omitted
            }
        }
        return values.dropLastWhile { it == null }.map { it ?: LuaNil }
    }

    /** An argument's value as the parameter takes it: a lambda for a `fun interface` as its object, see [arguments]. */
    private fun KaSession.converted(expr: KtExpression, value: LuaExpr): LuaExpr = when (expr) {
        in samConversions -> funInterfaceObject(samConversions.getValue(expr), value)
        in unitResults -> returningUnit(value)
        else -> value
    }

    /**
     * Argument expressions in parameter order (named arguments are reordered); null where an argument is
     * omitted and the parameter's default applies. The arguments of a `vararg` parameter of the program that is not
     * the last one come last, as the Lua function takes them as its varargs (`fun f(vararg xs: Int, block: () -> Unit)` is
     * `function f(block, ...)`).
     */
    internal fun KaSession.callArguments(call: KaCallableMemberCall<*, *>): List<KtExpression?> {
        if (call !is KaFunctionCall<*>) return emptyList()
        val mappedArguments = call.valueArgumentMapping.entries.map { it.value.symbol to it.key } +
            unmappedArguments[call].orEmpty().map { (arg, parameter) -> parameter to arg }
        val bySignature = mappedArguments.groupBy({ it.first }, { it.second })
        val result = mutableListOf<KtExpression?>()
        val parameters = call.signature.symbol.valueParameters
        val varargLast = parameters.lastOrNull()?.isVararg != false || !classes.isSource(call.signature.symbol.psi)
        val trailingVarargs = mutableListOf<KtExpression>()
        for (p in parameters) {
            val mapped = bySignature[p]
            if (p.isVararg) {
                mapped?.sortedBy { it.textRange.startOffset }?.forEach { arg ->
                    registerSpread(arg)
                    if (varargLast) result += arg else trailingVarargs += arg
                }
            } else {
                val arg = mapped?.singleOrNull()
                result += arg
                checkNullableForDefault(p.psi as? KtParameter, arg)
                if (arg != null) {
                    registerSamConversion(p.returnType, arg)
                    noteUnitResult(p, arg)
                }
            }
        }
        if (trailingVarargs.isNotEmpty()) return result + trailingVarargs
        return result.dropLastWhile { it == null }
    }

    private fun registerSpread(arg: KtExpression) {
        if ((arg.parent as? KtValueArgument)?.getSpreadElement() == null) return
        spreads += arg
    }

    /**
     * Arguments with a spread that is not the last one (`f(*xs, y)`): from that spread on, the arguments (all of the trailing
     * `vararg` parameter's) are one `__K2L_Spread("s.", xs, y)` that returns the elements as Lua values.
     */
    private fun KaSession.spreadArguments(operands: List<Operand?>, transformed: Iterator<LuaExpr>, firstSpread: Int): List<LuaExpr> {
        val values = operands.map { item ->
            when (item) {
                is Operand.Source -> converted(item.expr, transformed.next())
                is Operand.Value -> item.lua
                null -> LuaNil
            }
        }
        val marks = operands.drop(firstSpread).joinToString("") { if (it is Operand.Source && it.expr in spreads) "s" else "." }
        return values.take(firstSpread) + LuaCall(lualibRef("Unpack", "__K2L_Spread"), listOf(LuaString(marks)) + values.drop(firstSpread))
    }

    /** nil means "use the default", so a nullable argument for a nullable parameter is ambiguous. */
    private fun KaSession.checkNullableForDefault(decl: KtParameter?, arg: KtExpression?) {
        if (arg == null || decl == null) return
        if (!decl.hasDefaultValue() || !classes.isSource(decl)) return
        if (arg.expressionType?.isMarkedNullable != true || (decl.defaultValue as? KtConstantExpression)?.text == "null") return
        ctx.error(arg, "Passing a nullable value for '${decl.name}', which has a default, is ambiguous in Lua (nil selects the default)")
    }

    /**
     * Arguments of a library exception constructor, as (message, cause), classified by the parameter each one is for (the
     * `enableSuppression`/`writableStackTrace` flags of `RuntimeException(message, cause, false, false)` are dropped).
     */
    internal fun KaSession.throwableArguments(args: List<KtExpression?>, parameters: List<KaValueParameterSymbol>): List<LuaExpr> {
        val present = args.zip(parameters).mapNotNull { (arg, p) -> arg?.let { it to p } }
        val values = ordered(present.map { it.first })
        var message: LuaExpr = LuaNil
        var cause: LuaExpr = LuaNil
        present.zip(values).forEach { (argument, value) ->
            when (argument.second.returnType.withoutFlexibility.expandedSymbol?.classId?.asString()) {
                "kotlin/String" -> message = value
                "kotlin/Boolean" -> Unit
                else -> cause = value
            }
        }
        return if (cause == LuaNil) listOfNotNull(message.takeIf { it != LuaNil }) else listOf(message, cause)
    }

    fun lualibRef(feature: String, name: String): LuaExpr {
        ctx.lualib += feature
        // with Floats among untyped values, every printer of untyped values has to recognize them (see FloatToString.lua)
        if (usesFloat) ctx.lualib += "FloatToString"
        ctx.lualibNames += name
        // --strings utf16 patches the text and Regex runtime in place when its feature is loaded
        if (utf16 && (feature == "Strings" || feature == "Regex")) ctx.lualib += "Utf16"
        return LuaName(name)
    }

    /** `Math` in `Math.abs(x)` or `Random` in `Random.nextInt()`: a library class named as the receiver, not a value. */
    private fun KaSession.isLibraryClassQualifier(value: KaReceiverValue): Boolean {
        val expr = explicitReceiver(value) ?: return false
        val ref =
            expr as? KtNameReferenceExpression ?: (expr as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
        val symbol = ref?.mainReference?.resolveToSymbol()
        return symbol is KaClassLikeSymbol && symbol.classId?.asString() !in LIBRARY_OBJECTS && !classes.isSource(symbol.psi) &&
            !interop.isExternal(symbol)
    }

    internal fun KaSession.explicitReceiver(value: KaReceiverValue): KtExpression? = when (value) {
        is KaExplicitReceiverValue -> value.expression
        is KaSmartCastedReceiverValue -> explicitReceiver(value.original)
        else -> null
    }

    // ---- classes ----

    /** The class or object whose members are being transformed; its instance is `self`. */
    internal var currentClass: KtClassOrObject? = null

    /** The instances a local class or object expression sees from where it is declared (`this@Outer`), see [captureOuters]. */
    internal val lexicalOuters = HashMap<KtClassOrObject, List<Pair<KtClassOrObject, LuaExpr>>>()

    // ---- receivers ----

    private fun KaSession.thisRef(e: KtThisExpression): LuaExpr =
        receiverValue(e.instanceReference.mainReference.resolveToSymbol(), e) ?: LuaNil

    private fun KaSession.implicitReceiverOf(ref: KtNameReferenceExpression): LuaExpr? {
        val call = ref.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val value = call.partiallyAppliedSymbol.dispatchReceiver ?: return null
        return implicitReceiver(value, ref)
    }

    /** The Lua value of an implicit `this`. */
    internal fun KaSession.implicitReceiver(value: KaReceiverValue, element: KtElement): LuaExpr? {
        val original = (value as? KaSmartCastedReceiverValue)?.original ?: value
        return receiverValue((original as? KaImplicitReceiverValue)?.symbol, element)
    }

    /**
     * What a `this` symbol is in Lua: `self` for the class being transformed, the table of an object or
     * companion, or the receiver parameter of an extension function or lambda.
     */
    private fun KaSession.receiverValue(symbol: KaSymbol?, element: KtElement): LuaExpr? {
        val psi = when (symbol) {
            is KaReceiverParameterSymbol -> symbol.owningCallableSymbol.psi

            // an object expression, or the body of an enum entry
            is KaAnonymousObjectSymbol -> objectLiteralOf(symbol.psi) ?: symbol.containingDeclaration?.psi

            else -> symbol?.psi
        }
        receiverBindings[psi]?.let { return it }
        val enclosing = if (psi is KtClassOrObject) enclosingInstances().firstOrNull { it.first == psi }?.second else null
        return when {
            enclosing != null -> enclosing

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
    private fun KaSession.externalCall(
        call: KaCallableMemberCall<*, *>,
        receiverExpr: KtExpression?,
        implicit: LuaExpr?,
        element: KtExpression,
    ): LuaExpr {
        val symbol = call.partiallyAppliedSymbol.symbol
        val args = callArguments(call)
        val isFunction = call is KaFunctionCall<*>
        if (symbol is KaConstructorSymbol) return externalConstructor(symbol, args, element)
        val name = interop.luaName(symbol)
        val container = symbol.containingDeclaration as? KaClassSymbol
        if (container == null || container.classKind.isObject) {
            val base = when (container) {
                null -> interop.fileRequire(symbol.psi)?.let(interop::moduleRequire)
                else -> interop.externalClassRef(container)
            }
            val target = base?.let { LuaIndex(it, LuaString(name)) } ?: LuaName(name)
            return if (isFunction) LuaCall(target, arguments(emptyList(), args)) else target
        }
        val receiver = receiverOperand(implicit, receiverExpr) ?: return unsupported(element, "External member without a receiver")
        val values = arguments(listOf(receiver), args)
        if (!isFunction) return LuaIndex(values[0], LuaString(name))
        val noSelf = (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true || container.annotations.contains(NO_SELF)
        if (noSelf) return LuaCall(LuaIndex(values[0], LuaString(name)), values.drop(1))
        if (LuaPrinter.isIdentifier(name)) return LuaMethodCall(values[0], name, values.drop(1))
        // `@LuaName("repeat")`: `s:repeat(n)` is not Lua, `s["repeat"](s, n)` is
        val self = cache(values[0], "self")
        return LuaCall(LuaIndex(self, LuaString(name)), listOf(self) + values.drop(1))
    }

    private fun KaSession.externalConstructor(symbol: KaConstructorSymbol, args: List<KtExpression?>, element: KtExpression): LuaExpr {
        val cls = symbol.containingClassId?.let { findClass(it) } ?: return unsupported(element, "This external constructor")
        val ref = interop.externalClassRef(cls) ?: return unsupported(element, "Constructing _G")
        return LuaCall(LuaIndex(ref, LuaString("new")), arguments(emptyList(), args))
    }

    companion object {
        private val ASSIGNMENTS: Set<IElementType> = setOf(
            KtTokens.EQ,
            KtTokens.PLUSEQ,
            KtTokens.MINUSEQ,
            KtTokens.MULTEQ,
            KtTokens.DIVEQ,
            KtTokens.PERCEQ,
        )
        private val AUGMENTED: Map<IElementType, LuaBinOp> = mapOf(
            KtTokens.PLUSEQ to LuaBinOp.Add,
            KtTokens.MINUSEQ to LuaBinOp.Sub,
            KtTokens.MULTEQ to LuaBinOp.Mul,
            KtTokens.DIVEQ to LuaBinOp.Div,
            KtTokens.PERCEQ to LuaBinOp.Mod,
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
