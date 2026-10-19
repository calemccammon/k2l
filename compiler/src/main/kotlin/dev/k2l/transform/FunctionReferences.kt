package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

private const val FUNCTION_REF_FEATURE = "FunctionRef"

/**
 * References to functions are plain Lua functions. When the program reads the `name` of a function reference held in a value
 * (`val f = ::greet; f.name`), the references that are not passed straight to a parameter of a function type become
 * `__K2L_FunctionRef` objects, which carry the name and can still be called (see `FunctionRef.lua`).
 */
internal fun FileTransformer.named(e: KtCallableReferenceExpression, function: LuaExpr): LuaExpr = with(session) {
    if (function == LuaNil || !usesFunctionNames { files -> files.any { readsFunctionName(it) } }) return function
    val expected = e.expectedType
    if (expected is KaFunctionType && !expected.isReflectionFunctionType()) return function
    val constructor = e.callableReference.mainReference.resolveToSymbol() is KaConstructorSymbol
    val name = if (constructor) "<init>" else e.callableReference.getReferencedName()
    LuaCall(LuaIndex(lualibRef(FUNCTION_REF_FEATURE, "__K2L_FunctionRef"), LuaString("new")), listOf(LuaString(name), function))
}

private fun FileTransformer.readsFunctionName(file: KtFile): Boolean = with(session) {
    var found = false
    file.accept(object : KtTreeVisitorVoid() {
        override fun visitQualifiedExpression(expression: KtQualifiedExpression) {
            super.visitQualifiedExpression(expression)
            val selector = expression.selectorExpression as? KtNameReferenceExpression
            if (found || selector?.getReferencedName() != "name") return
            val receiver = expression.receiverExpression
            // `::f.name` is the name written there, see referencedName
            if (KtPsiUtil.safeDeparenthesize(receiver) is KtCallableReferenceExpression) return
            if (receiver.expressionType.isFunctionReferenceType()) found = true
        }
    })
    found
}

/** `KFunction1<A, R>`, `KCallable<R>` and the like: the types of a reference, as opposed to the function types `(A) -> R`. */
private fun KaType?.isFunctionReferenceType(): Boolean {
    val id = (this as? KaClassType)?.classId?.asString() ?: return false
    return id == "kotlin/reflect/KCallable" || id.startsWith("kotlin/reflect/KFunction") || id.startsWith("kotlin/reflect/KSuspendFunction")
}

private fun KaFunctionType.isReflectionFunctionType(): Boolean {
    val id = classId.asString()
    return id.startsWith("kotlin/reflect/")
}
