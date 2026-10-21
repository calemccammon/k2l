package dev.k2l.coverage

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolModality
import org.jetbrains.kotlin.analysis.api.symbols.KaTypeParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType

/** Thrown with the reason a callable gets no probe. */
class NotProbeable(reason: String) : Exception(reason)

/**
 * Writes the probes of a callable: a function [PROBE_NAME] whose parameters are the receiver and the arguments, and whose
 * body calls the API the way a program would: operators and infix functions in their syntax, a trailing lambda for a
 * function-typed last parameter, defaulted parameters left out (one probe) and passed (a second one).
 */
class ProbeWriter(private val session: KaSession) {
    /** The callable [symbol] of [owner] (null for a top-level one). */
    fun probes(symbol: KaCallableSymbol, owner: KaNamedClassSymbol?): List<ProbeSource> = with(session) {
        if (symbol.contextParameters.isNotEmpty()) throw NotProbeable("has context parameters")
        val ownerParams = if (owner != null && dispatchedOn(symbol, owner)) owner.typeParameters else emptyList()
        val ownParams = if (symbol is KaConstructorSymbol) emptyList() else typeParametersOf(symbol)
        val all = ownerParams + ownParams
        if (all.map { it.name }.toSet().size != all.size) throw NotProbeable("type parameter names clash")
        // Array's constructor needs a reified element type
        val arrayConstructor = symbol is KaConstructorSymbol && owner?.classId?.asString() == "kotlin/Array"
        val reified = all.filter { it.isReified || arrayConstructor }
        val reifiedTypes = reified.associate { it.name.asString() to reifiedReplacement(it) }
        // a receiver typed by a type parameter (`C : Iterable<T>` of `C.onEach`) is its bound, as in a program's calls
        val receiver = receiverTypeParameter(symbol)?.takeIf { it !in reified }
        val receiverBound = receiver?.let { p ->
            // not a recursive bound (`T : Comparable<T>`)
            TypeSource(this, reifiedTypes).render(p.upperBounds.single())?.takeUnless { Regex("\\b${p.name}\\b") in it }
        }
        val replaced = if (receiverBound != null) listOf(receiver) else emptyList()
        val types = TypeSource(this, reifiedTypes + replaced.associate { it.name.asString() to receiverBound!! })
        val (header, where) = typeParameterList(all - reified.toSet() - replaced.toSet(), types)
        val target = apiSignature(symbol)
        val imports = importsOf(symbol, owner)
        val suspend = if ((symbol as? KaNamedFunctionSymbol)?.isSuspend == true) "suspend " else ""
        callVariants(symbol, owner, ownParams, types).map { (params, body, checks) ->
            val code = "${suspend}fun $header$PROBE_NAME(${params.joinToString()})$where {\n${body.prependIndent("    ")}\n}\n"
            ProbeSource(code, imports, target, checks)
        }
    }

    /** The type parameter that is an extension's receiver type, when it has one bound that is a class (`C : Iterable<T>`). */
    private fun KaSession.receiverTypeParameter(symbol: KaCallableSymbol): KaTypeParameterSymbol? {
        val type = symbol.receiverParameter?.returnType as? KaTypeParameterType ?: return null
        return type.symbol.takeIf { p -> p.upperBounds.size == 1 && p.upperBounds[0] is KaClassType && !p.upperBounds[0].isAnyType }
    }

    private data class Variant(val params: List<String>, val body: String, val checksResolution: Boolean)

    private fun dispatchedOn(symbol: KaCallableSymbol, owner: KaNamedClassSymbol) =
        symbol is KaConstructorSymbol || (!isStatic(symbol) && !owner.classKind.isObject)

    /** A reified type parameter becomes a type that satisfies its bound. */
    private fun reifiedReplacement(p: KaTypeParameterSymbol): String {
        if (p.upperBounds.isEmpty()) return "kotlin.String"
        val bound = p.upperBounds.singleOrNull() as? KaClassType ?: throw NotProbeable("a reified type with several bounds")
        return when (bound.classId.asString()) {
            "kotlin/Any", "kotlin/Comparable", "kotlin/CharSequence" -> "kotlin.String"

            "kotlin/Enum" -> PROBE_ENUM

            "kotlin/Number" -> "kotlin.Int"

            "kotlin/Throwable" -> "kotlin.IllegalStateException"

            else -> bound.classId.asSingleFqName().asString().takeIf { bound.typeArguments.isEmpty() }
                ?: throw NotProbeable("a reified type bounded by ${bound.classId}")
        }
    }

    /** `<T : Comparable<T>> ` and, for type parameters with several bounds, a `where` clause. */
    private fun KaSession.typeParameterList(params: List<KaTypeParameterSymbol>, types: TypeSource): Pair<String, String> {
        if (params.isEmpty()) return "" to ""
        val where = mutableListOf<String>()
        val written = params.map { p ->
            val bounds = p.upperBounds.filterNot { it.isAnyType && it.isMarkedNullable }.map { types.type(it) }
            when (bounds.size) {
                0 -> p.name.asString()

                1 -> "${p.name} : ${bounds[0]}"

                else -> {
                    bounds.forEach { where += "${p.name} : $it" }
                    p.name.asString()
                }
            }
        }
        return "<${written.joinToString()}> " to if (where.isEmpty()) "" else " where ${where.joinToString()}"
    }

    private fun importsOf(symbol: KaCallableSymbol, owner: KaNamedClassSymbol?): Set<String> {
        val id = symbol.callableId ?: return emptySet()
        // a member extension of an object (`Duration.Companion.seconds`) is imported from it
        if (owner != null && symbol.isExtension) return setOf("${owner.classId!!.asSingleFqName()}.${id.callableName}")
        if (owner != null || id.packageName.asString() in DEFAULT_IMPORTS) return emptySet()
        return setOf("${id.packageName}.${id.callableName}")
    }

    private fun KaSession.callVariants(
        symbol: KaCallableSymbol,
        owner: KaNamedClassSymbol?,
        ownParams: List<KaTypeParameterSymbol>,
        types: TypeSource,
    ): List<Variant> {
        val receiverParams = mutableListOf<String>()
        val receiver = receiverOf(symbol, owner, types, receiverParams)
        return when (symbol) {
            is KaPropertySymbol -> listOf(Variant(receiverParams, "val v = ${member(receiver, symbol.name.asString())}", true))
            is KaConstructorSymbol -> constructorVariants(symbol, owner!!, types)
            is KaNamedFunctionSymbol -> functionVariants(symbol, receiver, receiverParams, ownParams, types)
            else -> throw NotProbeable("a ${symbol.javaClass.simpleName}")
        }
    }

    /** What the call is made on: the probe's parameter `r` (added to [params]), a class or object name, or nothing. */
    private fun KaSession.receiverOf(
        symbol: KaCallableSymbol,
        owner: KaNamedClassSymbol?,
        types: TypeSource,
        params: MutableList<String>,
    ): String? {
        val receiverType = symbol.receiverParameter?.returnType
        // an extension of an object or companion (`String.Companion.format`) is called on its name
        val objectType = (receiverType?.expandedSymbol as? KaNamedClassSymbol)?.takeIf { it.classKind.isObject }
        return when {
            symbol is KaConstructorSymbol -> null

            owner != null && dispatchedOn(symbol, owner) -> {
                if (symbol.isExtension) throw NotProbeable("a member extension of a class")
                val args = owner.typeParameters.map { it.name.asString() }
                params += "r: " + owner.classId!!.asSingleFqName().asString() + if (args.isEmpty()) "" else "<${args.joinToString()}>"
                "r"
            }

            objectType != null -> qualifier(objectType)

            receiverType != null -> {
                params += "r: ${types.type(receiverType)}"
                "r"
            }

            owner != null -> qualifier(owner)

            else -> null
        }
    }

    private fun KaSession.constructorVariants(symbol: KaConstructorSymbol, owner: KaNamedClassSymbol, types: TypeSource): List<Variant> {
        if (owner.modality == KaSymbolModality.ABSTRACT || owner.modality == KaSymbolModality.SEALED ||
            owner.classKind != KaClassKind.CLASS
        ) {
            throw NotProbeable("a constructor of an abstract class")
        }
        val typeArgs = owner.typeParameters.map { it.name.asString() }
        val callee = owner.classId!!.asSingleFqName().asString() + if (typeArgs.isEmpty()) "" else "<${typeArgs.joinToString()}>"
        return argumentLists(symbol, types::type).map { (params, args) -> Variant(params, "val v = $callee$args", true) }
    }

    private fun KaSession.functionVariants(
        symbol: KaNamedFunctionSymbol,
        receiver: String?,
        receiverParams: List<String>,
        ownParams: List<KaTypeParameterSymbol>,
        types: TypeSource,
    ): List<Variant> {
        val name = symbol.name.asString()
        val values = symbol.valueParameters
        val conventional = values.none { it.isVararg || it.hasDefaultValue }
        val operator = if (symbol.isOperator && receiver == "r" && conventional) {
            operatorBody(name, values.size)
        } else {
            null
        }
        if (operator != null) {
            val params = if (name == "getValue") emptyList() else values.mapIndexed { i, p -> "a$i: ${types.type(p.returnType)}" }
            return listOf(Variant(receiverParams + params, operator, operator.startsWith("val v = ")))
        }
        val typeArgs = if (ownParams.isEmpty()) "" else "<${ownParams.joinToString { types.typeParameter(it.name.asString()) }}>"
        val infix = symbol.isInfix && receiver != null && values.size == 1 && typeArgs.isEmpty()
        // a restricted suspension (SequenceScope.yield) is only callable inside its builder
        val restricted = symbol.isSuspend && symbol.callableId?.classId?.asString() == "kotlin/sequences/SequenceScope"
        return argumentLists(symbol, types::type).map { (params, args) ->
            val call = if (infix) "$receiver ${name.quoted()} a0" else member(receiver, name) + typeArgs + args
            val body = if (restricted) "kotlin.sequences.sequence<T> { ${call.removePrefix("r.")} }" else call
            Variant(receiverParams + params, "val v = $body", !restricted)
        }
    }

    companion object {
        /** An enum class each probe file declares, for reified type parameters bounded by `Enum`. */
        const val PROBE_ENUM = "ProbeEnum"

        val DEFAULT_IMPORTS = setOf(
            "kotlin", "kotlin.collections", "kotlin.text", "kotlin.sequences", "kotlin.ranges", "kotlin.comparisons",
            "kotlin.annotation", "kotlin.io", "kotlin.jvm",
        )
    }
}

private fun isStatic(symbol: KaCallableSymbol) =
    (symbol as? KaNamedFunctionSymbol)?.isStatic == true || (symbol as? KaPropertySymbol)?.isStatic == true

/** How a static member or a member of an object is reached: `Math.abs`, `Duration.parse` (through its companion). */
private fun qualifier(owner: KaNamedClassSymbol): String {
    val id = owner.classId!!
    val named = if (owner.classKind == KaClassKind.COMPANION_OBJECT) id.outerClassId!! else id
    return named.asSingleFqName().asString()
}

private fun member(receiver: String?, name: String) = if (receiver == null) name.quoted() else "$receiver.${name.quoted()}"

/** A type for a probe, or [NotProbeable]. */
private fun TypeSource.type(t: KaType) = render(t) ?: throw NotProbeable("a type without a source form")
