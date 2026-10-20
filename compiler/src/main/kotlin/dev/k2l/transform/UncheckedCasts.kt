package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.getParentOfType

/**
 * Unchecked casts. An erased `x as T` (or `x as List<T>`) checks nothing, and neither does `x as List<String>` check the
 * elements: the JVM throws `ClassCastException` later, where the generic value meets a concrete type and Kotlin emits a
 * CHECKCAST (a variable or parameter of that type, a member call on it), not where it only meets `Any` or a type
 * parameter (`println(x)`, a string template, `==`). k2l checks the results of the two common sources of such values at those
 * uses: calls of functions (and property getters) of the program whose body makes such a cast and whose return type is a
 * type parameter, and reads through a local `val` initialized by a cast to a generic type (`l[0]`, `l.first()`, `m[k]`,
 * the elements of a `for` loop). Other ways of passing an unchecked value on are not checked.
 */
internal class UncheckedCasts(
    /** Functions and properties whose body casts to a type that mentions a type parameter. */
    val producers: Set<KtCallableDeclaration>,
    /** Local `val`s initialized by a cast to a type with type arguments. */
    val locals: Set<KtProperty>,
) {
    val producerNames: Set<String> = producers.mapNotNullTo(HashSet()) { it.name }
    val localNames: Set<String> = locals.mapNotNullTo(HashSet()) { it.name }
    val isEmpty get() = producers.isEmpty() && locals.isEmpty()

    companion object {
        fun scan(files: Set<KtFile>): UncheckedCasts {
            val producers = HashSet<KtCallableDeclaration>()
            val locals = HashSet<KtProperty>()
            for (file in files) {
                file.accept(object : KtTreeVisitorVoid() {
                    override fun visitBinaryWithTypeRHSExpression(expression: KtBinaryExpressionWithTypeRHS) {
                        super.visitBinaryWithTypeRHSExpression(expression)
                        if (expression.operationReference.getReferencedNameElementType() != KtTokens.AS_KEYWORD) return
                        val type = expression.right ?: return
                        producerOf(expression, type)?.let { producers += it }
                        uncheckedLocalOf(expression, type)?.let { locals += it }
                    }
                })
            }
            return UncheckedCasts(producers, locals)
        }

        /** The function or property around [cast] when it casts to a [type] that mentions a type parameter in scope. */
        private fun producerOf(cast: KtExpression, type: KtTypeReference): KtCallableDeclaration? {
            val owner = cast.getParentOfType<KtCallableDeclaration>(true, KtClassOrObject::class.java)
            if (owner !is KtNamedFunction && owner !is KtProperty) return null
            // the type parameters in scope: of the declaration and the functions and classes around it
            val owners = generateSequence(cast.getParentOfType<KtTypeParameterListOwner>(true)) {
                it.getParentOfType<KtTypeParameterListOwner>(true)
            }
            val typeParameters = owners.flatMap { o -> o.typeParameters.mapNotNull { it.name } }.toSet()
            return owner.takeIf { type.collectDescendantsOfType<KtUserType>().any { it.referencedName in typeParameters } }
        }

        /** The local `val` that [cast] initializes, when it casts to a [type] with type arguments. */
        private fun uncheckedLocalOf(cast: KtExpression, type: KtTypeReference): KtProperty? {
            var outer = cast.parent
            while (outer is KtParenthesizedExpression) outer = outer.parent
            val local = (outer as? KtProperty)?.takeIf { it.isLocal && !it.isVar } ?: return null
            return local.takeIf { type.collectDescendantsOfType<KtTypeArgumentList>().isNotEmpty() }
        }

        private inline fun <reified T : KtElement> KtElement.collectDescendantsOfType(): List<T> {
            val result = ArrayList<T>()
            accept(object : KtTreeVisitorVoid() {
                override fun visitElement(element: com.intellij.psi.PsiElement) {
                    if (element is T) result += element
                    super.visitElement(element)
                }
            })
            return result
        }
    }
}

/**
 * [value], the translation of the call or read [e], checked against its static type where the JVM would check it, when it
 * can carry an unchecked value (see [UncheckedCasts]).
 */
internal fun FileTransformer.uncheckedResult(e: KtExpression, value: LuaExpr): LuaExpr = with(session) {
    val unchecked = uncheckedCasts
    if (unchecked.isEmpty || !mayBeUnchecked(e, unchecked)) return value
    val type = e.expressionType ?: return value
    if (!isCheckedType(type) || !checkedUse(e)) return value
    return checkedValue(value, type, e)
}

/** Whether [uncheckedResult] may check [e] (and so emit statements before it). */
internal fun FileTransformer.mayCheckUnchecked(e: KtExpression): Boolean {
    val unchecked = uncheckedCasts
    if (unchecked.isEmpty) return false
    if (e !is KtCallExpression && e !is KtQualifiedExpression && e !is KtArrayAccessExpression) return false
    return mayBeUnchecked(e, unchecked)
}

/** `for (s in l)` over a local of [UncheckedCasts.locals]: the check of each element [variable], else nothing. */
internal fun FileTransformer.uncheckedElementCheck(rangeExpr: KtExpression, param: KtParameter, variable: String): List<LuaStmt> =
    with(session) {
        val unchecked = uncheckedCasts
        if (unchecked.isEmpty || uncheckedLocal(rangeExpr, unchecked) == null) return emptyList()
        val type = param.symbol.returnType
        if (!isCheckedType(type)) return emptyList()
        return collect { checkedValue(LuaName(variable), type, param) }
    }

/** Whether [e] calls a producer or reads through an unchecked local; a cheap test of the names first. */
private fun FileTransformer.mayBeUnchecked(e: KtExpression, unchecked: UncheckedCasts): Boolean = with(session) {
    // the element that resolves to the call: the selector of `a.b()`, else [e] itself (`f()`, `a[i]`)
    val callElement = (e as? KtQualifiedExpression)?.selectorExpression ?: e
    val receiver = (e as? KtQualifiedExpression)?.receiverExpression ?: (e as? KtArrayAccessExpression)?.arrayExpression
    val symbol by lazy { callElement.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()?.partiallyAppliedSymbol?.symbol }
    val returnsTypeParameter by lazy { symbol?.returnType is KaTypeParameterType }
    if (calleeName(e, callElement) in unchecked.producerNames && symbol?.psi in unchecked.producers && returnsTypeParameter) return true
    return receiver != null && uncheckedLocal(receiver, unchecked) != null && returnsTypeParameter
}

private fun calleeName(e: KtExpression, callElement: KtExpression): String? {
    if (e is KtArrayAccessExpression) return "get"
    val callee = (callElement as? KtCallExpression)?.calleeExpression ?: callElement
    return (callee as? KtNameReferenceExpression)?.getReferencedName()
}

/** The unchecked local [e] reads, if it does. */
private fun FileTransformer.uncheckedLocal(e: KtExpression, unchecked: UncheckedCasts): KtProperty? = with(session) {
    val ref = KtPsiUtil.safeDeparenthesize(e) as? KtNameReferenceExpression ?: return null
    if (ref.getReferencedName() !in unchecked.localNames) return null
    return (ref.mainReference.resolveToSymbol()?.psi as? KtProperty)?.takeIf { it in unchecked.locals }
}

/** A type whose values the JVM checks with a CHECKCAST and k2l can test: not a type parameter, `Any` or `Nothing`. */
private fun FileTransformer.isCheckedType(type: KaType): Boolean = with(session) {
    type !is KaTypeParameterType && !type.isAnyType && !type.isNothingType && !type.isUnitType && isTestable(type)
}

/** Whether a CHECKCAST would test the value of [e] against its type: what its context does with it. */
private fun FileTransformer.checkedUse(e: KtExpression): Boolean = with(session) {
    var child: KtElement = e
    var parent = e.parent
    while (parent is KtParenthesizedExpression || parent is KtLabeledExpression || parent is KtAnnotatedExpression) {
        child = parent as KtElement
        parent = parent.parent
    }
    return when (parent) {
        is KtValueArgument -> parent.getParentOfType<KtCallElement>(true)?.let { operandUse(it, child as KtExpression) } == true

        is KtQualifiedExpression -> if (parent.receiverExpression == child) {
            parent.selectorExpression?.let { operandUse(it, child as KtExpression) } == true
        } else {
            checkedUse(parent)
        }

        is KtArrayAccessExpression -> operandUse(parent, child as KtExpression)

        is KtStringTemplateEntry, is KtIsExpression, is KtBinaryExpressionWithTypeRHS -> false

        is KtBinaryExpression -> binaryUse(parent, child as KtExpression)

        is KtUnaryExpression -> if (parent.operationToken ==
            KtTokens.EXCLEXCL
        ) {
            checkedUse(parent)
        } else {
            operandUse(parent, child as KtExpression)
        }

        is KtProperty -> parent.initializer == child && isConcrete(parent.symbol.returnType)

        is KtNamedFunction -> parent.bodyExpression == child && isConcrete(parent.symbol.returnType)

        is KtReturnExpression -> isConcrete((child as KtExpression).expectedType)

        // a branch takes the type of the `if` or `when`, also when that is not used
        is KtContainerNodeForControlStructureBody -> isConcrete((parent.parent as? KtExpression)?.expressionType)

        is KtContainerNode -> true

        // a condition
        is KtWhenEntry -> parent.expression == child && isConcrete((parent.parent as? KtWhenExpression)?.expressionType)

        is KtBlockExpression -> blockResultUse(parent, child)

        else -> false
    }
}

private fun FileTransformer.binaryUse(parent: KtBinaryExpression, child: KtExpression): Boolean = with(session) {
    when (parent.operationToken) {
        KtTokens.EQEQ, KtTokens.EXCLEQ, KtTokens.EQEQEQ, KtTokens.EXCLEQEQEQ -> false

        KtTokens.ELVIS -> true

        // the operands are coerced to the result, of the non-null type of the left one
        KtTokens.ANDAND, KtTokens.OROR -> true

        KtTokens.EQ -> parent.right == child && isConcrete(parent.left?.expressionType)

        else -> operandUse(parent, child)
    }
}

/** The last statement of a lambda is its result, of a branch the value of the `if` or `when`; other statements are not used. */
private fun FileTransformer.blockResultUse(block: KtBlockExpression, child: KtElement): Boolean = with(session) {
    if (block.statements.lastOrNull() != child) return false
    return when (val owner = block.parent) {
        is KtFunctionLiteral -> ((owner.parent as? KtLambdaExpression)?.expressionType as? KaFunctionType)?.returnType.let(::isConcrete)
        is KtContainerNodeForControlStructureBody -> isConcrete((owner.parent as? KtExpression)?.expressionType)
        is KtWhenEntry -> isConcrete((owner.parent as? KtWhenExpression)?.expressionType)
        else -> false
    }
}

/**
 * [child] as an operand of the call [call]: an argument is checked when the callee's declared parameter type is concrete,
 * the receiver when the callee is a member of a concrete class (not `Any`'s `toString`/`equals`/`hashCode`) or an extension
 * of a concrete type (not `Any?.toString()`), or an inline function passing it to a lambda (`x.let { }`, whose parameter has
 * the concrete type).
 */
private fun FileTransformer.operandUse(call: KtElement, child: KtExpression): Boolean = with(session) {
    val resolved = call.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return false
    val parameter = (resolved as? KaFunctionCall<*>)?.valueArgumentMapping?.get(child)
    if (parameter != null) return isConcrete(parameter.symbol.returnType)
    val symbol = resolved.partiallyAppliedSymbol.symbol
    val extensionReceiver = symbol.receiverParameter
    if (extensionReceiver != null) {
        val inlineWithLambda =
            symbol is KaNamedFunctionSymbol && symbol.isInline && symbol.valueParameters.any { it.returnType is KaFunctionType }
        return isConcrete(extensionReceiver.returnType) || (extensionReceiver.returnType is KaTypeParameterType && inlineWithLambda)
    }
    return symbol.callableId?.classId?.asString() != "kotlin/Any"
}

private fun FileTransformer.isConcrete(type: KaType?): Boolean = with(session) {
    type != null && type !is KaTypeParameterType && !type.isAnyType && !type.isNothingType && !type.isUnitType
}

/** `if value ~= nil and not <value is type> then <ClassCastException> end`, as a CHECKCAST lets null through. */
private fun FileTransformer.checkedValue(value: LuaExpr, type: KaType, element: KtElement): LuaExpr = with(session) {
    val v = cache(value, "value")
    val nonNull = type.withNullability(false)
    // a number is unboxed through java.lang.Number (`intValue()`), which any number passes
    val numeric = nonNull.isIntegral || nonNull.isDoubleType || nonNull.isFloatType
    val test = when {
        !numeric -> typeTest(v, nonNull, element)
        emulatesLong -> LuaCall(lualibRef("TypeChecks", "__K2L_IsNumber"), listOf(v))
        else -> LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), v), LuaString("number"))
    }
    val fail = if (numeric) {
        lualibCall("CastFail", v, LuaString("java.lang.Number"), LuaString("kotlin.Number"))
    } else {
        lualibCall("CastFail", v, LuaString(jvmClassName(nonNull)), LuaString(kotlinClassName(nonNull)))
    }
    emit(LuaIf(LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Ne, v, LuaNil), negate(test)), listOf(LuaCallStmt(fail))))
    return v
}
