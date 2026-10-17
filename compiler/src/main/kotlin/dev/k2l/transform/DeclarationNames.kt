package dev.k2l.transform

import com.intellij.psi.PsiElement
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
        val overloads: List<Any> = if (owner == null) {
            topLevelOverloads(fn.parent, name)
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

    private val accessorNames = HashMap<Pair<KtProperty, String>, String>()

    /**
     * Lua name of an extension property's accessor function: `getX` or `setX`. Like overloads, accessors sharing a
     * name with each other or with a function (`val String.x`, `val Int.x`, `fun getX()`) get `__1`, `__2`, ...
     */
    fun extensionAccessor(p: KtProperty, prefix: String): String = accessorNames.getOrPut(p to prefix) {
        val raw = accessorRaw(p, prefix)
        val index = topLevelOverloads(p.parent, raw).indexOf(p to prefix)
        val base = LuaNames.of(raw)
        if (index <= 0) base else "${base}__$index"
    }

    /** The name of the hidden Lua local holding a top-level or local delegated property's delegate. */
    fun delegate(p: KtProperty): String = "____${of(p)}_delegate"

    /** Lua names a top-level declaration defines (an extension property defines up to two functions). */
    fun topLevel(decl: KtDeclaration): List<String> = when {
        decl is KtProperty && decl.receiverTypeReference != null ->
            listOfNotNull(extensionAccessor(decl, "get"), if (decl.isVar) extensionAccessor(decl, "set") else null)

        decl is KtProperty && decl.delegate != null -> listOf(delegate(decl))

        else -> listOf(of(decl as KtNamedDeclaration))
    }

    private fun accessorRaw(p: KtProperty, prefix: String) = prefix + p.name!!.replaceFirstChar { it.uppercaseChar() }

    /** Top-level functions and extension property accessors that would be called [name] in Lua, in declaration order. */
    private fun topLevelOverloads(parent: PsiElement, name: String): List<Any> = parent.children.flatMap { child ->
        when {
            child is KtNamedFunction && child.name == name -> listOf(child)

            child is KtProperty && child.receiverTypeReference != null && child.name != null ->
                listOf("get", "set").filter { (it == "get" || child.isVar) && accessorRaw(child, it) == name }.map { child to it }

            else -> emptyList()
        }
    }

    /** Lua name of a destructuring entry; `_` stays `_`. */
    fun entry(entry: KtDestructuringDeclarationEntry): String = if (entry.name == "_") "_" else of(entry)
}
