package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Lua names of Kotlin declarations. */
internal class DeclarationNames(private val session: KaSession, private val classes: ClassHierarchy) {
    fun of(decl: KtNamedDeclaration): String =
        renames[decl] ?: if (decl is KtNamedFunction) function(decl) else LuaNames.of(decl.name ?: "_")

    /**
     * Declarations of an inlined function body whose Lua names were changed to avoid capturing a name used by the
     * code inlined into it (the call's arguments), see `inlineUserFunction`.
     */
    val renames = HashMap<PsiElement, String>()

    fun renamed(decl: PsiElement?): String? = decl?.let { renames[it] }

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
     * Lua name of a property accessor function (extension properties and top-level properties with custom
     * accessors): `getX` or `setX`. Like overloads, accessors sharing a name with each other or with a function
     * (`val String.x`, `val Int.x`, `fun getX()`) get `__1`, `__2`, ...
     */
    fun propertyAccessor(p: KtProperty, prefix: String): String = accessorNames.getOrPut(p to prefix) {
        val raw = accessorRaw(p, prefix)
        val index = topLevelOverloads(p.parent, raw).indexOf(p to prefix)
        val base = LuaNames.of(raw)
        if (index <= 0) base else "${base}__$index"
    }

    /** The name of the hidden Lua local holding the backing field of a top-level property with custom accessors. */
    fun backingField(p: KtProperty): String = "____${of(p)}_field"

    /** The name of the hidden Lua local holding a top-level or local delegated property's delegate. */
    fun delegate(p: KtProperty): String = "____${of(p)}_delegate"

    /** Lua names a top-level declaration defines (a property with accessor functions defines up to two). */
    fun topLevel(decl: KtDeclaration): List<String> = when {
        decl is KtProperty && decl.hasAccessorFunctions() ->
            listOfNotNull(propertyAccessor(decl, "get"), if (decl.isVar) propertyAccessor(decl, "set") else null)

        decl is KtProperty && decl.delegate != null -> listOf(delegate(decl))

        else -> listOf(of(decl as KtNamedDeclaration))
    }

    private fun accessorRaw(p: KtProperty, prefix: String) = prefix + p.name!!.replaceFirstChar { it.uppercaseChar() }

    /** Top-level functions and extension property accessors that would be called [name] in Lua, in declaration order. */
    private fun topLevelOverloads(parent: PsiElement, name: String): List<Any> = parent.children.flatMap { child ->
        when {
            child is KtNamedFunction && child.name == name -> listOf(child)

            child is KtProperty && child.hasAccessorFunctions() && child.name != null ->
                listOf("get", "set").filter { (it == "get" || child.isVar) && accessorRaw(child, it) == name }.map { child to it }

            else -> emptyList()
        }
    }

    /** Lua name of a destructuring entry; `_` stays `_`. */
    fun entry(entry: KtDestructuringDeclarationEntry): String = if (entry.name == "_") "_" else of(entry)
}

/**
 * Whether a property is compiled to `getX`/`setX` functions: extension properties, and top-level properties with
 * a custom getter or setter (their backing field, if any, is a hidden local).
 */
internal fun KtProperty.hasAccessorFunctions(): Boolean =
    receiverTypeReference != null || (isTopLevel && delegate == null && (getter?.hasBody() == true || setter?.hasBody() == true))
