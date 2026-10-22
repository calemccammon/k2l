package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolOrigin
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.psi.KtTypeAlias

/**
 * The class's own constructor behind one called through a typealias (`typealias IntWrapper = Wrapper<Int>`, then
 * `IntWrapper(1, 0)` or `::IntWrapper`). The Analysis API resolves such a call to a copy of the constructor whose class id
 * and PSI are the typealias's; the original is the constructor of the expanded class with the same parameters.
 */
internal fun KaSession.typeAliasedOriginal(symbol: KaConstructorSymbol): KaConstructorSymbol? {
    // only a typealias of the program: the library's (kotlin.collections.ArrayList) are mapped by their own ids
    if (symbol.origin != KaSymbolOrigin.TYPEALIASED_CONSTRUCTOR || symbol.psi !is KtTypeAlias) return null
    val cls = symbol.returnType.expandedSymbol ?: return null
    val params = symbol.valueParameters
    val candidates = cls.declaredMemberScope.constructors.filter { c ->
        c.valueParameters.size == params.size &&
            c.valueParameters.zip(params).all { (a, b) -> a.name == b.name && a.isVararg == b.isVararg }
    }.toList()
    // constructors with the same parameter names differ in a parameter's class (the alias substitutes only type parameters)
    return candidates.singleOrNull() ?: candidates.firstOrNull { c ->
        c.valueParameters.zip(params).all { (a, b) ->
            val expected = (a.returnType as? KaClassType)?.classId
            expected == null || expected == (b.returnType as? KaClassType)?.classId
        }
    } ?: candidates.firstOrNull()
}
