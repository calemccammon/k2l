package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.psi.KtProperty

/**
 * Top-level properties with a custom getter or setter are functions, like extension properties without a
 * receiver: `val now: Int get() = counter * 2` becomes `getNow()`, and a `var` also gets `setNow(value)`.
 * A backing field (`field`, or an initializer) is a hidden local, `____x_field`, that the accessors close over.
 * Reads, writes and `+=`/`++` go through the functions, which are exported like any other function.
 */
internal fun FileTransformer.accessorPropertyDeclaration(p: KtProperty, forwardDeclared: Boolean): Unit = with(session) {
    val field = if (props.declaresField(p)) LuaName(naming.backingField(p)) else null
    if (field != null) {
        val init = p.initializer
        when {
            init == null -> emit(LuaLocal(listOf(field.name)))

            needsBranching(init) -> {
                emit(LuaLocal(listOf(field.name)))
                emitAll(valueInto(init) { listOf(assign(field, it)) })
            }

            else -> emit(LuaLocal(listOf(field.name), listOf(expression(init))))
        }
    }
    val getter = p.getter?.takeIf { it.hasBody() }
    val getBody = if (getter != null) {
        accessorFunction(getter, emptyList())
    } else {
        LuaFunction(emptyList(), listOf(LuaReturn(listOf(field ?: LuaNil))))
    }
    emit(LuaFunctionDecl(LuaName(naming.propertyAccessor(p, "get")), getBody, isLocal = !forwardDeclared))
    if (!p.isVar) return
    val setter = p.setter?.takeIf { it.hasBody() }
    val param = LuaNames.of(setter?.parameter?.name ?: "value")
    val setBody = if (setter != null) {
        accessorFunction(setter, listOf(param))
    } else {
        LuaFunction(listOf(param), listOfNotNull(field?.let { assign(it, LuaName(param)) }))
    }
    emit(LuaFunctionDecl(LuaName(naming.propertyAccessor(p, "set")), setBody, isLocal = !forwardDeclared))
}

/** `x` is `getX()`. */
internal fun FileTransformer.accessorPropertyRead(p: KtProperty): LuaExpr =
    LuaCall(topLevelRef(p, naming.propertyAccessor(p, "get")), emptyList())

/** `x += 1` is `setX(getX() + 1)`. */
internal fun FileTransformer.accessorPropertyTarget(p: KtProperty): Target {
    val set = topLevelRef(p, naming.propertyAccessor(p, "set"))
    return Target(accessorPropertyRead(p)) { LuaCallStmt(LuaCall(set, listOf(it))) }
}
