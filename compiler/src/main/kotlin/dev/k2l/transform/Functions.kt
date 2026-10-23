package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.psi.*

// Functions: parameters, varargs, default arguments and bodies.

internal fun FileTransformer.function(fn: KtNamedFunction): LuaFunction = with(session) {
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
internal fun FileTransformer.varargParameter(params: List<KtParameter>): KtParameter? = params.firstOrNull { it.isVarArg }

/** `vararg xs: Int` arrives as Lua varargs and is packed into an Array. */
internal fun FileTransformer.packVararg(vararg: KtParameter?) {
    if (vararg == null) return
    emit(LuaLocal(listOf(naming.of(vararg)), listOf(LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))))))
}

/**
 * Callee-side defaults: `if x == nil then x = <default> end`. Callers pass nil for omitted arguments. An override of [fn]
 * applies the defaults it inherits. A parameter that can be null, with a default that is not, also takes the marker of
 * a null argument (`elseif x == __K2L_NULL_ARGUMENT then x = nil`, see [nullArgument]).
 */
internal fun FileTransformer.defaultArguments(params: List<KtParameter>, fn: KtNamedFunction? = null): Unit = with(session) {
    val inherited = fn?.let { inheritedDefaults(it) }.orEmpty()
    for (p in params) {
        val base = inherited[p]
        // a null default needs nothing: an omitted argument is nil already
        val default = (p.defaultValue ?: base?.defaultValue)?.takeUnless { isNullDefault(it) } ?: continue
        val name = LuaName(naming.of(p))
        val assignment = if (base == null) {
            valueInto(default) { listOf(assign(name, it)) }
        } else {
            withParametersOf(fn!!, base) { valueInto(default) { listOf(assign(name, it)) } }
        }
        val type = p.returnType
        val nullable = type.isMarkedNullable || type is KaTypeParameterType
        val marker = if (nullable) {
            listOf(
                LuaIf(LuaBinary(LuaBinOp.Eq, name, lualibRef(NULL_ARGUMENT_FEATURE, "__K2L_NULL_ARGUMENT")), listOf(assign(name, LuaNil))),
            )
        } else {
            null
        }
        emit(LuaIf(LuaBinary(LuaBinOp.Eq, name, LuaNil), assignment, marker))
    }
}

internal fun <F> FileTransformer.functionBody(fn: F): Unit where F : KtDeclarationWithBody, F : KtDeclarationWithReturnType =
    with(session) {
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

/** A name for a receiver parameter; `self` unless that would hide a class instance or another receiver. */
internal fun FileTransformer.receiverName(): String {
    val selfTaken = currentClass != null || receiverBindings.values.any { it is LuaName && it.name == "self" }
    return if (selfTaken) ctx.temp("this") else "self"
}
