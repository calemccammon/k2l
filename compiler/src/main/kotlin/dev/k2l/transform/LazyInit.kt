package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Library functions and constructors whose call has no effect anyone could observe, when their arguments have none. */
private val PURE_LIBRARY_CALLS = setOf(
    "listOf", "mutableListOf", "arrayListOf", "emptyList", "setOf", "mutableSetOf", "hashSetOf", "linkedSetOf", "emptySet",
    "mapOf", "mutableMapOf", "hashMapOf", "linkedMapOf", "emptyMap", "arrayOf", "intArrayOf", "longArrayOf", "doubleArrayOf",
    "booleanArrayOf", "charArrayOf", "arrayOfNulls", "lazy", "to", "Pair", "Triple", "StringBuilder", "ArrayList", "HashMap",
    "LinkedHashMap", "HashSet", "LinkedHashSet", "ArrayDeque", "observable", "vetoable", "notNull", "intern",
)

private val PURE_OPERATORS = setOf(
    KtTokens.PLUS, KtTokens.MINUS, KtTokens.MUL, KtTokens.DIV, KtTokens.PERC, KtTokens.EQEQ, KtTokens.EXCLEQ, KtTokens.LT,
    KtTokens.GT, KtTokens.LTEQ, KtTokens.GTEQ, KtTokens.ANDAND, KtTokens.OROR, KtTokens.ELVIS, KtTokens.EQEQEQ, KtTokens.EXCLEQEQEQ,
)

/**
 * Kotlin initializes an `object`, a companion object or an enum class when it is first accessed. k2l does it when the
 * file loads, unless the initialization is observable (see [isObservable]): then the first access triggers it, see `LazyObject.lua`.
 */
internal class LazyInit(private val session: KaSession, private val classes: ClassHierarchy) {
    private val cache = HashMap<KtClassOrObject, Boolean>()
    private val inProgress = HashSet<KtClassOrObject>()

    /**
     * Whether initializing [c] can have an effect other than setting its own fields to constants: `init` blocks, property
     * initializers that call code or read mutable state, constructors with bodies, or a superclass that does any of that.
     */
    fun isObservable(c: KtClassOrObject): Boolean {
        cache[c]?.let { return it }
        if (!inProgress.add(c)) return false
        val result = with(session) { compute(c) }
        inProgress.remove(c)
        cache[c] = result
        return result
    }

    private fun KaSession.compute(c: KtClassOrObject): Boolean {
        val info = classes.superInfo(c)
        return c.declarations.any { memberObservable(it, c) } ||
            info.baseCall?.valueArguments?.any { !pure(it.getArgumentExpression(), c) } == true ||
            info.base?.let(::isObservable) == true ||
            (c is KtClass && c.secondaryConstructors.any { !pureBody(it, c) })
    }

    private fun KaSession.memberObservable(decl: KtDeclaration, owner: KtClassOrObject): Boolean = when (decl) {
        is KtAnonymousInitializer -> (decl.body as? KtBlockExpression)?.statements?.all { assignsPure(it, owner) } != true

        is KtProperty -> !pure(decl.initializer, owner) || !pure(decl.delegateExpression, owner)

        is KtEnumEntry -> isObservable(decl) || decl.initializerList?.initializers?.any { entry ->
            (entry as? KtSuperTypeCallEntry)?.valueArguments?.any { !pure(it.getArgumentExpression(), owner) } == true
        } == true

        else -> false
    }

    /** Whether evaluating [e] has no effect and gives the same value whenever it runs (as far as k2l can tell). */
    private fun KaSession.pure(e: KtExpression?, owner: KtClassOrObject): Boolean {
        if (e == null || e.evaluate() != null) return true
        return when (e) {
            is KtConstantExpression, is KtLambdaExpression, is KtCallableReferenceExpression, is KtThisExpression -> true

            is KtStringTemplateExpression -> e.entries.all { pure(it.expression, owner) }

            is KtParenthesizedExpression -> pure(e.expression, owner)

            is KtAnnotatedExpression -> pure(e.baseExpression, owner)

            is KtPrefixExpression -> e.operationToken in setOf(KtTokens.MINUS, KtTokens.PLUS, KtTokens.EXCL) &&
                pure(e.baseExpression, owner)

            is KtBinaryExpression -> pureBinary(e, owner)

            is KtNameReferenceExpression -> pureReference(e, owner)

            is KtDotQualifiedExpression -> pure(e.receiverExpression, owner) && pureSelector(e.selectorExpression, owner)

            is KtCallExpression -> pureCall(e, owner)

            else -> false
        }
    }

    private fun KaSession.pureBody(ctor: KtSecondaryConstructor, owner: KtClassOrObject) =
        ctor.bodyExpression?.statements?.all { assignsPure(it, owner) } != false

    /** `x = <pure>` or `this.x = <pure>`: an `init` block made only of these has no effect beyond setting fields. */
    private fun KaSession.assignsPure(statement: KtExpression, owner: KtClassOrObject): Boolean {
        val assignment = statement as? KtBinaryExpression ?: return false
        if (assignment.operationToken != KtTokens.EQ) return false
        val target = assignment.left
        val isField = target is KtNameReferenceExpression ||
            (target is KtDotQualifiedExpression && target.receiverExpression is KtThisExpression)
        return isField && pure(assignment.right, owner)
    }

    private fun KaSession.pureBinary(e: KtBinaryExpression, owner: KtClassOrObject): Boolean {
        val isInfixTo = e.operationReference.getReferencedName() == "to"
        if (e.operationToken !in PURE_OPERATORS && !isInfixTo) return false
        val callee = e.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()?.symbol?.psi
        return (callee == null || !classes.isSource(callee)) && pure(e.left, owner) && pure(e.right, owner)
    }

    private fun KaSession.pureSelector(selector: KtExpression?, owner: KtClassOrObject): Boolean = when (selector) {
        is KtNameReferenceExpression -> pureReference(selector, owner)
        is KtCallExpression -> pureCall(selector, owner)
        else -> false
    }

    private fun KaSession.pureReference(ref: KtNameReferenceExpression, owner: KtClassOrObject): Boolean {
        val symbol = ref.mainReference.resolveToSymbol()
        val psi = symbol?.psi
        return when {
            symbol is KaEnumEntrySymbol -> (psi as? KtEnumEntry)?.containingClassOrObject?.let { !isObservable(it) } ?: true

            psi == null || !classes.isSource(psi) -> symbol != null

            // library property or class

            psi is KtObjectDeclaration -> !isObservable(psi)

            psi is KtParameter && !psi.hasValOrVar() -> true

            psi is KtProperty && psi.getter?.hasBody() == true -> false

            psi is KtProperty && psi.isTopLevel -> !psi.isVar

            psi is KtProperty || psi is KtParameter -> pureMemberRead(psi as KtDeclaration, owner)

            else -> false
        }
    }

    private fun pureMemberRead(psi: KtDeclaration, owner: KtClassOrObject): Boolean {
        val container = psi.containingClassOrObject
        return container == owner || (container != null && container in classes.hierarchy(owner)) ||
            (container is KtObjectDeclaration && !isObservable(container) && !(psi is KtProperty && psi.isVar))
    }

    private fun KaSession.pureCall(call: KtCallExpression, owner: KtClassOrObject): Boolean {
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return false
        val symbol = resolved.symbol
        val psi = symbol.psi
        val argsPure = resolved.valueArgumentMapping.keys.all { pure(it, owner) }
        return when {
            symbol is KaConstructorSymbol && psi != null && classes.isSource(psi) -> {
                val cls = (psi as? KtConstructor<*>)?.getContainingClassOrObject() ?: (psi as? KtClassOrObject)
                argsPure && cls != null && !isObservable(cls) && !(psi is KtSecondaryConstructor && !pureBody(psi, cls))
            }

            psi != null && classes.isSource(psi) -> false

            else ->
                argsPure &&
                    (
                        symbol.callableId?.callableName?.asString()
                            ?: (symbol as? KaConstructorSymbol)?.containingClassId?.shortClassName?.asString()
                        ) in
                    PURE_LIBRARY_CALLS
        }
    }
}
