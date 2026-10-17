package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Lua names of Kotlin declarations. */
internal class DeclarationNames(private val session: KaSession, private val classes: ClassHierarchy) {
    fun of(decl: KtNamedDeclaration): String = if (decl is KtNamedFunction) function(decl) else LuaNames.of(decl.name ?: "_")

    private val functionNames = HashMap<KtNamedFunction, String>()

    /**
     * Lua name of a function. Overloads get `name`, `name__1`, ... in declaration order; for methods the
     * numbering spans the class hierarchy, and an override reuses the name of what it overrides.
     */
    fun function(fn: KtNamedFunction): String = functionNames.getOrPut(fn) {
        val name = fn.name ?: "_"
        val owner = fn.containingClassOrObject
        val overloads = if (owner == null) {
            fn.parent.children.filterIsInstance<KtNamedFunction>().filter { it.name == name }
        } else {
            if (fn.hasModifier(KtTokens.OVERRIDE_KEYWORD)) {
                val overridden = with(session) {
                    (fn.symbol as? KaNamedFunctionSymbol)?.directlyOverriddenSymbols
                        ?.mapNotNull { it.psi as? KtNamedFunction }?.firstOrNull { classes.isSource(it) }
                }
                if (overridden != null) return@getOrPut function(overridden)
                if (with(session) { (fn.symbol as? KaNamedFunctionSymbol)?.directlyOverriddenSymbols?.any() } == true) {
                    return@getOrPut LuaNames.member(name) // overrides a library member such as toString
                }
            }
            classes.hierarchy(owner).flatMap { c ->
                c.declarations.filterIsInstance<KtNamedFunction>().filter { it.name == name && !it.hasModifier(KtTokens.OVERRIDE_KEYWORD) }
            }
        }
        val base = if (owner == null) LuaNames.of(name) else LuaNames.member(name)
        val index = overloads.indexOf(fn)
        if (index <= 0) base else "${base}__$index"
    }

    /** Lua name of a destructuring entry; `_` stays `_`. */
    fun entry(entry: KtDestructuringDeclarationEntry): String = if (entry.name == "_") "_" else of(entry)
}
