package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/**
 * `getX`/`setX` for a member of an accessor family: the custom accessor, or a default one over the backing
 * field. Abstract and interface members without a body get no method.
 */
internal fun FileTransformer.accessorMethods(p: KtNamedDeclaration, ref: LuaExpr): Unit = with(session) {
    if (p is KtProperty && p.receiverTypeReference != null) {
        memberExtensionPropertyDeclaration(p, ref)
        return
    }
    if (p is KtProperty && p.delegate != null) {
        delegatedAccessors(p, ref)
        return
    }
    props.problem(p)?.let {
        ctx.error(p, it)
        return
    }
    val property = p as? KtProperty
    val bodiless = property != null && !props.hasOwnField(p)
    val field = LuaIndex(selfRef(), LuaString(props.fieldName(p)))
    val getter = property?.getter?.takeIf { it.hasBody() }
    if (getter != null || !bodiless) {
        emitMethod(ref, accessorName("get", p), emptyList(), getter?.let { accessorBody(it) } ?: listOf(LuaReturn(listOf(field))))
    }
    if (property?.isVar ?: (p as KtParameter).isMutable) setterMethod(p, ref, field, bodiless)
}

private fun FileTransformer.setterMethod(p: KtNamedDeclaration, ref: LuaExpr, field: LuaExpr, bodiless: Boolean) {
    val setter = (p as? KtProperty)?.setter?.takeIf { it.hasBody() }
    if (setter == null && bodiless) return
    val param = LuaNames.of(setter?.parameter?.name ?: "value")
    emitMethod(ref, accessorName("set", p), listOf(param), setter?.let { accessorBody(it) } ?: listOf(assign(field, LuaName(param))))
}

private fun FileTransformer.accessorBody(accessor: KtPropertyAccessor): List<LuaStmt> = with(session) { collect { functionBody(accessor) } }
