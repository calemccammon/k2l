package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * An override inherits the default values of the function it overrides (`fun report(indent: String = "")` in an interface,
 * `override fun report(indent: String)` in a class), and defaults are applied in the callee, so every override applies them
 * too. Maps each parameter of [fn] without a default to the parameter of the overridden source function declaring one.
 */
internal fun FileTransformer.inheritedDefaults(fn: KtNamedFunction): Map<KtParameter, KtParameter> = with(session) {
    if (!fn.hasModifier(KtTokens.OVERRIDE_KEYWORD)) return emptyMap()
    val result = HashMap<KtParameter, KtParameter>()
    val seen = HashSet<KaFunctionSymbol>()
    fun visit(symbol: KaFunctionSymbol) {
        for (overridden in symbol.directlyOverriddenSymbols.filterIsInstance<KaFunctionSymbol>().filter(seen::add)) {
            val psi = overridden.psi as? KtNamedFunction
            if (psi == null || !classes.isSource(psi)) continue
            psi.valueParameters.zip(fn.valueParameters).forEach { (base, own) ->
                if (base.defaultValue != null && own.defaultValue == null) result.putIfAbsent(own, base)
            }
            visit(overridden)
        }
    }
    visit(fn.symbol)
    return result
}

/**
 * Transforms an inherited default value with the parameters of the function declaring it (which it may read) renamed to the
 * override's, so `fun f(a: Int, b: Int = a + 1)` overridden by `fun f(x: Int, y: Int)` gives `y = x + 1`; the `this` of the
 * declaring class (`target: String = name`) is the override's `self`.
 */
internal inline fun <T> FileTransformer.withParametersOf(fn: KtNamedFunction, base: KtParameter, block: () -> T): T {
    val baseFunction = base.ownerFunction ?: return block()
    val pairs = baseFunction.valueParameters.zip(fn.valueParameters).filter { (b, _) -> b !in naming.renames }
    pairs.forEach { (b, own) -> naming.renames[b] = naming.of(own) }
    val baseClass = baseFunction.containingClassOrObject?.takeIf { it !in receiverBindings && it != fn.containingClassOrObject }
    if (baseClass != null) receiverBindings[baseClass] = selfRef()
    try {
        return block()
    } finally {
        pairs.forEach { (b, _) -> naming.renames.remove(b) }
        if (baseClass != null) receiverBindings.remove(baseClass)
    }
}
