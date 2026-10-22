package dev.k2l.transform

import dev.k2l.codegen.LuaExpr
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.psi.KtClass
import org.jetbrains.kotlin.psi.KtExpression

/** What the arguments of the calls being transformed need: spreads, SAM conversions, Unit results, substituted values. */
internal class CallState {
    /** `*array` arguments, expanded with table.unpack. */
    val spreads = HashSet<KtExpression>()

    /** Lambdas passed for a parameter of a `fun interface` of the program, by that interface (see FunInterfaces). */
    val samConversions = HashMap<KtExpression, KtClass>()

    /** Function values returning Unit passed where a function with a result is expected, see [noteUnitResult]. */
    val unitResults = HashSet<KtExpression>()

    /** Nullable arguments for a parameter whose default is not null: a null is passed as a marker, see [nullArgument]. */
    val nullArguments = HashSet<KtExpression>()

    /** Values substituted for receiver expressions, e.g. the cached receiver of `a?.b`. */
    val overrides = HashMap<KtExpression, LuaExpr>()

    /** Arguments by call whose parameter the Analysis API leaves out of `valueArgumentMapping`, e.g. `f(x !in y)`. */
    val unmappedArguments = java.util.IdentityHashMap<KaCallableMemberCall<*, *>, Map<KtExpression, KaValueParameterSymbol>>()
}
