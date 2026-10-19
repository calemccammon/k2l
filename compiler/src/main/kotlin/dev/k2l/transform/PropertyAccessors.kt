package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/**
 * `getX`/`setX` for a member of an accessor family: the custom accessor, or a default one over the backing
 * field. Abstract and interface members without a body get no method.
 */
internal fun FileTransformer.accessorMethods(p: KtNamedDeclaration, ref: LuaExpr): Unit = with(session) {
    if (specialAccessors(p, ref)) return
    val property = p as? KtProperty
    val bodiless = property != null && !props.hasOwnField(p)
    val field = LuaIndex(selfRef(), LuaString(props.fieldName(p)))
    // A constructor can read an overridden property before the subclass initialized its field
    val fieldRead = props.uninitializedValue(p)?.let { zero -> LuaBinary(LuaBinOp.Or, field, zero) } ?: field
    val getter = property?.getter?.takeIf { it.hasBody() }
    if (getter != null || !bodiless) {
        emitMethod(ref, accessorName("get", p), emptyList(), getter?.let { accessorBody(it) } ?: listOf(LuaReturn(listOf(fieldRead))))
    }
    if (property?.isVar ?: (p as KtParameter).isMutable) setterMethod(p, ref, field, bodiless)
}

/** Member extension and delegated properties have accessors of their own kind. */
private fun FileTransformer.specialAccessors(p: KtNamedDeclaration, ref: LuaExpr): Boolean {
    if (p !is KtProperty) return false
    when {
        p.receiverTypeReference != null -> memberExtensionPropertyDeclaration(p, ref)
        p.delegate != null -> delegatedAccessors(p, ref)
        else -> return false
    }
    return true
}

private fun FileTransformer.setterMethod(p: KtNamedDeclaration, ref: LuaExpr, field: LuaExpr, bodiless: Boolean) {
    val setter = (p as? KtProperty)?.setter?.takeIf { it.hasBody() }
    if (setter == null && bodiless) return
    val param = LuaNames.of(setter?.parameter?.name ?: "value")
    emitMethod(ref, accessorName("set", p), listOf(param), setter?.let { accessorBody(it) } ?: listOf(assign(field, LuaName(param))))
}

private fun FileTransformer.accessorBody(accessor: KtPropertyAccessor): List<LuaStmt> = with(session) {
    inFrame(FunctionFrame(FunctionFrame.Kind.Function, emptySet(), accessor)) { collect { functionBody(accessor) } }
}
