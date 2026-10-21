package dev.k2l.coverage

import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaTypeParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaDefinitelyNotNullType
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaStarTypeProjection
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeArgumentWithVariance
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.types.Variance

/**
 * Writes types as Kotlin source: fully qualified for probes, with short names for the report ([short]). A type parameter
 * in [substitutions] is written as its replacement (a reified one can't stay a type parameter of the probe). A Java
 * (flexible) type is written as its upper bound without the `?`: `(Mutable)List<E!>!` becomes `List<E>`. Returns null for
 * what has no source form (captured, intersection or error types).
 */
class TypeSource(private val session: KaSession, private val substitutions: Map<String, String> = emptyMap(), val short: Boolean = false) {
    fun render(type: KaType): String? = with(session) { renderIn(type) }

    /** A type argument for the type parameter [name]. */
    fun typeParameter(name: String): String = substitutions[name] ?: name

    private fun KaSession.renderIn(type: KaType, forceNonNull: Boolean = false): String? {
        val nullable = !forceNonNull && type.isMarkedNullable
        val body = when (type) {
            is KaFlexibleType -> return renderIn(type.upperBound, forceNonNull = true)
            is KaDefinitelyNotNullType -> return renderIn(type.original)?.let { "$it & Any" }
            is KaTypeParameterType -> substitutions[type.name.asString()] ?: type.name.asString()
            is KaFunctionType -> functionType(type)?.let { if (nullable) "($it)" else it }
            is KaClassType -> classType(type)
            else -> null
        } ?: return null
        return if (nullable) "$body?" else body
    }

    @OptIn(KaExperimentalApi::class)
    private fun KaSession.functionType(type: KaFunctionType): String? {
        if (type.hasContextReceivers || type.isReflectType) return null
        val receiver = type.receiverType?.let { r ->
            renderIn(r)?.let { if (it.endsWith("?")) "($it)." else "$it." } ?: return null
        }.orEmpty()
        val parameters = type.parameterTypes.map { renderIn(it) ?: return null }
        val result = renderIn(type.returnType) ?: return null
        val suspend = if (type.isSuspend) "suspend " else ""
        return "$suspend$receiver(${parameters.joinToString()}) -> $result"
    }

    private fun KaSession.classType(type: KaClassType): String? {
        val name = if (short) {
            type.classId.relativeClassName.asString()
        } else {
            type.classId.asSingleFqName().asString()
        }
        if (type.typeArguments.isEmpty()) return name
        val args = type.typeArguments.map { arg ->
            when (arg) {
                is KaStarTypeProjection -> "*"

                is KaTypeArgumentWithVariance -> {
                    val inner = renderIn(arg.type) ?: return null
                    when (arg.variance) {
                        Variance.IN_VARIANCE -> "in $inner"
                        Variance.OUT_VARIANCE -> "out $inner"
                        Variance.INVARIANT -> inner
                    }
                }
            }
        }
        return "$name<${args.joinToString()}>"
    }
}

/** A stable description of a callable for comparing the probe's resolved call with the API it was written for. */
fun KaSession.apiSignature(symbol: KaCallableSymbol): String {
    val types = TypeSource(this)
    val receiver = symbol.receiverParameter?.returnType?.let { types.render(it) }.orEmpty()
    val parameters = (symbol as? KaFunctionSymbol)?.valueParameters?.joinToString { types.render(it.returnType).toString() }
    val id = symbol.callableId?.toString() ?: "${(symbol as? KaConstructorSymbol)?.containingClassId}.<init>"
    return "$id $receiver" + parameters?.let { "($it)" }.orEmpty()
}

/** The type parameters a callable declares itself. */
fun typeParametersOf(symbol: KaCallableSymbol): List<KaTypeParameterSymbol> = when (symbol) {
    is KaNamedFunctionSymbol -> symbol.typeParameters
    is KaPropertySymbol -> symbol.typeParameters
    else -> emptyList()
}
