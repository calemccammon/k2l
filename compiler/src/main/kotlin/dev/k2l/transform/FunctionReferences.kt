package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

private const val FUNCTION_REF_FEATURE = "FunctionRef"

/** What a program can learn from a reference held in a value besides calling it. */
private val OBJECT_MEMBERS = setOf("name", "toString", "equals", "hashCode")

/**
 * References to functions are plain Lua functions. When the program looks at a function reference held in a value as an object
 * (`val f = ::greet; f.name`, `println(f)`, `f == g`), the references that are not passed straight to a parameter of a function
 * type become `__K2L_FunctionRef` objects, which carry the name, the [symbol]'s key for `==` and the bound [receiver], and can
 * still be called (see `FunctionRef.lua`).
 */
internal fun FileTransformer.named(
    e: KtCallableReferenceExpression,
    symbol: KaCallableSymbol,
    function: LuaExpr,
    receiver: LuaExpr? = null,
): LuaExpr = with(session) {
    if (function == LuaNil || !usesFunctionNames { files -> files.any { observesFunctionReferences(it) } }) return function
    val expected = e.expectedType
    if (expected is KaFunctionType && !expected.isReflectionFunctionType()) return function
    val name = if (symbol is KaConstructorSymbol) "<init>" else e.callableReference.getReferencedName()
    val args = listOf(LuaString(name), LuaString(referenceKey(symbol)), function) + listOfNotNull(receiver)
    LuaCall(LuaIndex(lualibRef(FUNCTION_REF_FEATURE, "__K2L_FunctionRef"), LuaString("new")), args)
}

/**
 * What identifies a callable for `==` between references: its id, with the receiver type of an extension and the parameter types
 * of a function (`kotlin.String.kotlin/text/uppercase()`), since overloads share an id. Local declarations have no id.
 */
context(s: KaSession)
internal fun referenceKey(symbol: KaCallableSymbol): String = with(s) {
    val id = symbol.callableId?.toString()
        ?: (symbol as? KaConstructorSymbol)?.containingClassId?.let { "$it.<init>" }
        ?: (symbol.psi as? KtNamedDeclaration)?.let { "${it.name}@${it.textOffset}" }
        ?: "?"
    val receiver = symbol.receiverParameter?.returnType?.let { "${it.pretty()}." }.orEmpty()
    val params = (symbol as? KaFunctionSymbol)?.valueParameters?.joinToString(",", "(", ")") { it.returnType.pretty() }.orEmpty()
    receiver + id + params
}

/**
 * Whether [file] looks at a function reference held in a value as an object: reads its `name` (`::f.name` is the name written
 * there, see [referencedName]), calls `toString`/`equals`/`hashCode`, compares it with `==`, puts it in a string template or
 * passes it where no function is expected (`println(f)`, `listOf(f)`).
 */
private fun FileTransformer.observesFunctionReferences(file: KtFile): Boolean = with(session) {
    var found = false
    file.accept(object : KtTreeVisitorVoid() {
        override fun visitExpression(expression: KtExpression) {
            super.visitExpression(expression)
            // the syntax first: types are only computed for the few expressions in such places
            if (found || !isObservingPlace(expression) || !expression.expressionType.isFunctionReferenceType()) return
            found =
                expression.parent !is KtValueArgument ||
                expression.expectedType.let { it !is KaFunctionType || it.isReflectionFunctionType() }
        }
    })
    found
}

private fun isObservingPlace(e: KtExpression): Boolean {
    val parent = e.parent
    return when {
        parent is KtQualifiedExpression && parent.receiverExpression == e -> {
            val selector = parent.selectorExpression
            val member = (selector as? KtNameReferenceExpression ?: (selector as? KtCallExpression)?.calleeExpression)
                ?.let { (it as? KtNameReferenceExpression)?.getReferencedName() }
            member in OBJECT_MEMBERS && !(member == "name" && KtPsiUtil.safeDeparenthesize(e) is KtCallableReferenceExpression)
        }

        parent is KtBinaryExpression -> parent.operationToken in EQUALITY_TOKENS

        else -> parent is KtStringTemplateEntryWithExpression || parent is KtValueArgument
    }
}

private val EQUALITY_TOKENS = setOf(KtTokens.EQEQ, KtTokens.EXCLEQ, KtTokens.EQEQEQ, KtTokens.EXCLEQEQEQ)

/** `KFunction1<A, R>`, `KCallable<R>` and the like: the types of a reference, as opposed to the function types `(A) -> R`. */
private fun KaType?.isFunctionReferenceType(): Boolean {
    val id = (this as? KaClassType)?.classId?.asString() ?: return false
    return id == "kotlin/reflect/KCallable" || id.startsWith("kotlin/reflect/KFunction") || id.startsWith("kotlin/reflect/KSuspendFunction")
}

internal fun KaFunctionType.isReflectionFunctionType(): Boolean {
    val id = classId.asString()
    return id.startsWith("kotlin/reflect/")
}

/**
 * A reference to a function or constructor with a `vararg` parameter, whose Lua function takes the vararg's elements as its
 * last arguments (see `callArguments`): when the function type passes the Array (`val f: (IntArray) -> Int = ::sum`), the
 * reference is a function unpacking it after the other arguments for [function], which takes [leading] receivers first. A
 * reference adapted to separate elements (`listOf(1).map(::sum)`) is [function] itself.
 */
internal fun FileTransformer.varargAdapter(
    e: KtCallableReferenceExpression,
    params: List<KtParameter>,
    leading: Int,
    function: LuaExpr,
): LuaExpr = with(session) {
    val at = params.indexOfFirst { it.isVarArg }
    val type = e.expressionType as? KaFunctionType
    if (at < 0 || type == null || function == LuaNil) return function
    val types = listOfNotNull(type.receiverType) + type.parameterTypes
    val elementType = (params[at].symbol as? KaValueParameterSymbol)?.returnType ?: return function
    if (types.size - leading != params.size || types[leading + at].semanticallyEquals(elementType)) return function
    val names = (1..types.size).map { "____p$it" }
    val args = names.map(::LuaName)
    val values = args.drop(leading)
    val target = if (function is LuaName || function is LuaIndex) function else cache(function, "reference")
    val call = LuaCall(target, args.take(leading) + values.filterIndexed { i, _ -> i != at } + lualibCall("Unpack", values[at]))
    LuaFunction(names, listOf(LuaReturn(listOf(call))))
}
