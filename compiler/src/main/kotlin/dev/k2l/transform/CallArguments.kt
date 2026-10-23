package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.KaReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.name.StandardClassIds
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

// The arguments of a call in parameter order, with spreads, defaults and the receiver operand.

/** A receiver as an operand: either an explicit expression (transformed later, in order) or an implicit `this`. */
internal fun FileTransformer.receiverOperand(value: KaReceiverValue, element: KtElement): Operand? = with(session) {
    explicitReceiver(value)?.asOperand() ?: implicitReceiver(value, element)?.asOperand()
}

/** The implicit `this` if there is one, else the explicit receiver expression; null if neither. */
internal fun FileTransformer.receiverOperand(implicit: LuaExpr?, explicit: KtExpression?): Operand? =
    implicit?.asOperand() ?: explicit?.asOperand()

/**
 * Transforms the [Operand.Source]s among [receivers] and then [args] in source order. Omitted
 * arguments become nil so later ones keep their position; trailing omitted ones are dropped.
 */
internal fun FileTransformer.arguments(receivers: List<Operand>, args: List<KtExpression?>): List<LuaExpr> = with(session) {
    val operands = receivers + args.map { it?.asOperand() }
    val sources = operands.filterIsInstance<Operand.Source>().map { it.expr }
    val transformed = orderedAsWritten(sources, receivers.count { it is Operand.Source }).iterator()
    val firstSpread = operands.indexOfFirst { it is Operand.Source && it.expr in callState.spreads }
    if (firstSpread >= 0 && firstSpread < operands.lastIndex) return spreadArguments(operands, transformed, firstSpread)
    val values = operands.map { item ->
        when (item) {
            is Operand.Source -> transformed.next().let {
                if (item.expr in callState.spreads) lualibCall("Unpack", it) else converted(item.expr, it)
            }

            is Operand.Value -> item.lua

            null -> null // omitted
        }
    }
    return values.dropLastWhile { it == null }.map { it ?: LuaNil }
}

/** An argument's value as the parameter takes it: a lambda for a `fun interface` as its object, see [arguments]. */
private fun FileTransformer.converted(expr: KtExpression, value: LuaExpr): LuaExpr = with(session) {
    when (expr) {
        in callState.samConversions -> funInterfaceObject(callState.samConversions.getValue(expr), value)
        in callState.unitResults -> returningUnit(value)
        in callState.nullArguments -> nullArgument(value)
        else -> value
    }
}

/**
 * Argument expressions in parameter order (named arguments are reordered); null where an argument is
 * omitted and the parameter's default applies. The arguments of a `vararg` parameter of the program that is not
 * the last one come last, as the Lua function takes them as its varargs (`fun f(vararg xs: Int, block: () -> Unit)` is
 * `function f(block, ...)`).
 */
internal fun FileTransformer.callArguments(call: KaCallableMemberCall<*, *>): List<KtExpression?> {
    if (call !is KaFunctionCall<*>) return emptyList()
    val mappedArguments = call.valueArgumentMapping.entries.map { it.value.symbol to it.key } +
        callState.unmappedArguments[call].orEmpty().map { (arg, parameter) -> parameter to arg }
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
            noteNullableForDefault(p.psi as? KtParameter, arg)
            if (arg != null) {
                registerSamConversion(p.returnType, arg)
                noteUnitResult(p, arg)
            }
        }
    }
    if (trailingVarargs.isNotEmpty()) return result + trailingVarargs
    return result.dropLastWhile { it == null }
}

private fun FileTransformer.registerSpread(arg: KtExpression) {
    if ((arg.parent as? KtValueArgument)?.getSpreadElement() == null) return
    callState.spreads += arg
}

/**
 * Arguments with a spread that is not the last one (`f(*xs, y)`): from that spread on, the arguments (all of the trailing
 * `vararg` parameter's) are one `__K2L_Spread("s.", xs, y)` that returns the elements as Lua values.
 */
private fun FileTransformer.spreadArguments(operands: List<Operand?>, transformed: Iterator<LuaExpr>, firstSpread: Int): List<LuaExpr> =
    with(session) {
        val values = operands.map { item ->
            when (item) {
                is Operand.Source -> converted(item.expr, transformed.next())
                is Operand.Value -> item.lua
                null -> LuaNil
            }
        }
        val marks = operands.drop(firstSpread).joinToString("") { if (it is Operand.Source && it.expr in callState.spreads) "s" else "." }
        return values.take(firstSpread) + LuaCall(lualibRef("Unpack", "__K2L_Spread"), listOf(LuaString(marks)) + values.drop(firstSpread))
    }

/**
 * nil means "use the default", so a nullable argument for a parameter whose default is not null is passed as a
 * [nullArgument], which the function turns back into nil (see [defaultArguments]). A function implemented in Lua can't.
 */
private fun FileTransformer.noteNullableForDefault(decl: KtParameter?, arg: KtExpression?): Unit = with(session) {
    if (arg == null || decl == null) return
    if (!decl.hasDefaultValue() || !classes.isSource(decl)) return
    if (arg.expressionType?.isMarkedNullable != true || isNullDefault(decl.defaultValue)) return
    val owner = decl.ownerFunction ?: decl.containingClassOrObject
    if (owner != null && interop.isExternalDeclaration(owner)) {
        ctx.error(arg, "Passing a nullable value for '${decl.name}', which has a default, is ambiguous in Lua (nil selects the default)")
        return
    }
    callState.nullArguments += arg
}

/** Whether a parameter's [default] is `null`, which nil selects either way. */
internal fun isNullDefault(default: KtExpression?): Boolean =
    (KtPsiUtil.safeDeparenthesize(default ?: return false) as? KtConstantExpression)?.text == "null"

/** A nullable argument for a parameter whose default is not null: a marker in place of null (see `NullArgument.lua`). */
internal fun FileTransformer.nullArgument(value: LuaExpr): LuaExpr =
    if (value == LuaNil) lualibRef(NULL_ARGUMENT_FEATURE, "__K2L_NULL_ARGUMENT") else lualibCall(NULL_ARGUMENT_FEATURE, value)

/** The primitive parameter types of AssertionError's constructors, whose argument is the message. */
private val VALUE_MESSAGES = setOf("kotlin/Int", "kotlin/Long", "kotlin/Char", "kotlin/Boolean", "kotlin/Float", "kotlin/Double")

/**
 * Arguments of a library exception constructor, as (message, cause), classified by the parameter each one is for (the
 * `enableSuppression`/`writableStackTrace` flags of `RuntimeException(message, cause, false, false)` are dropped). The
 * detail of `AssertionError(detail)` is its message, as the string of the value, or its cause if it is a Throwable.
 */
internal fun FileTransformer.throwableArguments(args: List<KtExpression?>, parameters: List<KaValueParameterSymbol>): List<LuaExpr> =
    with(session) {
        val present = args.zip(parameters).mapNotNull { (arg, p) -> arg?.let { it to p } }
        val values = ordered(present.map { it.first })
        var message: LuaExpr = LuaNil
        var cause: LuaExpr = LuaNil
        present.zip(values).forEach { (argument, value) ->
            val id = argument.second.returnType.withoutFlexibility.expandedSymbol?.classId?.asString()
            when {
                id == "kotlin/String" -> message = value

                // AssertionError(detail: Any?) and AssertionError(Int), (Boolean), ...: the detail's string, and also the
                // cause when it is a Throwable
                parameters.size == 1 && (id == "kotlin/Any" || id in VALUE_MESSAGES) -> {
                    val type = argument.first.expressionType
                    message = str(value, type)
                    if (id == "kotlin/Any" && type != null && type.isSubtypeOf(StandardClassIds.Throwable)) cause = value
                }

                id == "kotlin/Boolean" -> Unit

                else -> cause = value
            }
        }
        return if (cause == LuaNil) listOfNotNull(message.takeIf { it != LuaNil }) else listOf(message, cause)
    }
