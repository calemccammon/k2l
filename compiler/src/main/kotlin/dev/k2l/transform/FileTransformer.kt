package dev.k2l.transform

import com.intellij.psi.PsiElement
import com.intellij.psi.tree.IElementType
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import java.util.IdentityHashMap

/**
 * Translates one Kotlin file into a Lua chunk. Expressions may need statements to run before them
 * (e.g. an `if` used as a value); those are emitted into the current statement buffer, see [collect].
 *
 * The class holds the state of the file's transformation and dispatches statements and expressions; each language area is
 * a set of extensions of it in a sibling file (FileChunk.kt, Functions.kt, Statements.kt, Calls.kt, Templates.kt, ...).
 */
class FileTransformer(
    internal val session: KaSession,
    internal val file: KtFile,
    override val ctx: TransformContext,
    internal val module: ModuleContext = ModuleContext.single(file),
) : StatementEmitter() {
    internal val usesReflection get() = module.usesReflection
    internal val usesFloat get() = module.usesFloat
    internal val usesListViews get() = module.usesListViews
    internal val implementsCharSequence get() = module.implementsCharSequence
    internal val implementsClosedRange get() = module.implementsClosedRange
    internal val implementsCollections get() = module.implementsCollections
    internal val uncheckedCasts get() = module.uncheckedCasts
    internal fun usesFunctionNames(scan: (Set<KtFile>) -> Boolean) = module.usesFunctionNames(scan)

    /** Exported top-level `var`s live in `____exports` so other files see updates. */
    internal val tableMode: Boolean by lazy {
        file in module.cyclic || file.declarations.any { isExportedVar(it) } || deferredInit
    }

    /** The file's plain properties are initialized on first use, see [FileInit]. */
    internal val deferredInit: Boolean by lazy { fileInit.isDeferred(file) }

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

    // ---- functions ----

    /** The loops and functions being transformed, and what jumps out of them need. */
    internal val jumps = JumpState()

    internal inline fun <T> inFrame(frame: FunctionFrame, block: () -> T): T {
        val savedLoops = jumps.loops
        frame.outerLoops = savedLoops
        if (frame.kind != FunctionFrame.Kind.Inline) jumps.loops = ArrayDeque()
        jumps.frames.addLast(frame)
        try {
            return block()
        } finally {
            jumps.frames.removeLast()
            jumps.loops = savedLoops
        }
    }

    /** Lua values for receivers that aren't a class's `self`: extension functions and lambdas with receivers. */
    internal val receiverBindings = HashMap<PsiElement, LuaExpr>()

    /** Lambda parameters of inlined lambdas, keyed by (function literal, parameter name). */
    internal val lambdaBindings = HashMap<Pair<PsiElement, String>, LuaExpr>()

    /** The temps holding values checked against their static type (see UncheckedCasts.kt), which need no second check. */
    internal val checkedValues = HashSet<LuaName>()

    // ---- statements ----

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

    // ---- expressions ----

    /** What the arguments of the calls being transformed need (see CallArguments.kt). */
    internal val callState = CallState()

    /** `getmetatable(subject)` read once before a `when`, by its subject, see [hoistSubjectMetatable]. */
    internal val subjectMetatables: MutableMap<LuaExpr, LuaExpr> = IdentityHashMap()

    /** The comparators built by [fusedComparator], for a `thenBy` on them to extend. */
    internal val fusedComparators: MutableMap<LuaExpr, FusedComparator> = IdentityHashMap()

    /** The expression in statement position being transformed, whose value (if it is of type Unit) is not used. */
    internal var statementExpression: KtExpression? = null

    fun KaSession.expression(e: KtExpression): LuaExpr = when {
        e !== statementExpression && isUnitValued(e) -> unitValueOf(e)
        convertsUnitFunction(e) -> returningUnit(translated(e))
        else -> translated(e)
    }

    private fun KaSession.translated(e: KtExpression): LuaExpr = callState.overrides[e] ?: when (e) {
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

    fun lualibCall(feature: String, vararg args: LuaExpr): LuaExpr =
        LuaCall(lualibRef(feature, Lualib.functionName(feature)), args.toList())

    // ---- calls ----

    fun lualibRef(feature: String, name: String): LuaExpr {
        ctx.lualib += feature
        // with Floats among untyped values, every printer of untyped values has to recognize them (see FloatToString.lua)
        if (usesFloat) ctx.lualib += "FloatToString"
        ctx.lualibNames += name
        // --strings utf16 patches the text and Regex runtime in place when its feature is loaded
        if (utf16 && (feature == "Strings" || feature == "Regex")) ctx.lualib += "Utf16"
        return LuaName(name)
    }

    // ---- classes ----

    /** The class or object whose members are being transformed; its instance is `self`. */
    internal var currentClass: KtClassOrObject? = null

    /** The instances a local class or object expression sees from where it is declared (`this@Outer`), see [captureOuters]. */
    internal val lexicalOuters = HashMap<KtClassOrObject, List<Pair<KtClassOrObject, LuaExpr>>>()

    companion object {
        private val ASSIGNMENTS: Set<IElementType> = setOf(
            KtTokens.EQ,
            KtTokens.PLUSEQ,
            KtTokens.MINUSEQ,
            KtTokens.MULTEQ,
            KtTokens.DIVEQ,
            KtTokens.PERCEQ,
        )
    }
}
