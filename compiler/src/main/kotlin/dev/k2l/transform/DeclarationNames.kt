package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Lua names of Kotlin declarations. */
internal class DeclarationNames(private val session: KaSession, private val classes: ClassHierarchy) {
    fun of(decl: KtNamedDeclaration): String =
        renames[decl] ?: if (decl is KtNamedFunction) function(decl) else luaNameOf(decl) ?: LuaNames.of(decl.name ?: "_")

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
        luaNameOf(fn)?.let { return@getOrPut it }
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
                    // overrides a library member such as toString
                    return@getOrPut LuaNames.member(libraryMember(fn, name, classes.collectionBaseOf(owner) != null))
                }
            }
            classes.hierarchy(owner).flatMap { c ->
                c.declarations.filterIsInstance<KtNamedFunction>().filter { it.name == name && !it.hasModifier(KtTokens.OVERRIDE_KEYWORD) }
            }
        }
        val base = if (owner == null) LuaNames.of(name) else LuaNames.member(name)
        val index = overloads.indexOf(fn).coerceAtLeast(0) + if (hiddenByProperty(fn, name, classes)) 1 else 0
        if (index == 0) base else "${base}__$index"
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

    /** Whether a plain (non-extension) member property is accessed through `getX`/`setX`; set once the property families are known. */
    var plainAccessors: (KtProperty) -> Boolean = { false }

    private val memberAccessorNames = HashMap<Pair<KtProperty, String>, String>()

    /**
     * Lua name of the accessor method of a member extension property (`getX`/`setX`). Extension properties of one class
     * hierarchy that share a name (`val String.x`, `val Int.x`) and ones that clash with a function or another property's
     * accessor get `__1`, `__2`, ...; an override keeps the name of the property it overrides.
     */
    fun memberAccessor(p: KtProperty, prefix: String): String = memberAccessorNames.getOrPut(p to prefix) {
        if (p.hasModifier(KtTokens.OVERRIDE_KEYWORD)) {
            val overridden = with(session) {
                (p.symbol as? KaPropertySymbol)?.directlyOverriddenSymbols?.mapNotNull { it.psi as? KtProperty }
                    ?.firstOrNull { classes.isSource(it) }
            }
            if (overridden != null) return@getOrPut memberAccessor(overridden, prefix)
        }
        val raw = accessorRaw(p, prefix)
        val members = classes.hierarchy(p.containingClassOrObject!!).flatMap { it.declarations }
        val taken = HashSet<String>()
        members.filterIsInstance<KtNamedFunction>().mapTo(taken) { function(it) }
        for (other in members.filterIsInstance<KtProperty>()) {
            if (other.name == null || other.receiverTypeReference != null || !plainAccessors(other)) continue
            taken += accessorRaw(other, "get")
            taken += accessorRaw(other, "set")
        }
        val earlier = members.filterIsInstance<KtProperty>().filter {
            it.receiverTypeReference != null && it.name != null && !it.hasModifier(KtTokens.OVERRIDE_KEYWORD)
        }.takeWhile { it != p }
        earlier.filter { prefix == "get" || it.isVar }.mapTo(taken) { memberAccessor(it, prefix) }
        generateSequence(0) { it + 1 }.map { if (it == 0) raw else "${raw}__$it" }.first { it !in taken }
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
 * `@LuaName("on_load")` on a top-level function or plain property of the program: its local and the field Lua code reads
 * it from in the module table. Only a name k2l would not rename itself (no Lua keyword, no global it relies on) is used.
 */
private fun luaNameOf(decl: KtNamedDeclaration): String? {
    if (decl.parent !is KtFile || (decl !is KtNamedFunction && decl !is KtProperty)) return null
    if (decl is KtProperty && (decl.hasAccessorFunctions() || decl.delegate != null)) return null
    val entry = decl.annotationEntries.firstOrNull { it.shortName?.asString() == "LuaName" } ?: return null
    val text = entry.valueArguments.firstOrNull()?.getArgumentExpression() as? KtStringTemplateExpression ?: return null
    val name = text.entries.joinToString("") { it.text }
    return name.takeIf { LuaNames.of(it) == it && !it.startsWith("____") }
}

/**
 * Whether a method is named like a property (`private val items` and `fun items()`), which the instance's field would hide,
 * or a top-level function like a top-level property (`val label` and `fun label(n)`), which the property's local would.
 */
private fun hiddenByProperty(fn: KtNamedFunction, name: String, classes: ClassHierarchy): Boolean {
    val owner = fn.containingClassOrObject ?: return fn.parent.children.any {
        it is KtProperty && it.name == name && !it.hasAccessorFunctions() && it.delegate == null
    }
    return name in classes.fieldNames(owner)
}

/**
 * The lualib name of an overridden collection member: `add(index, element)` is `addAt`, `addAll(index, elements)`
 * `addAllAt`, `listIterator(index)` `listIteratorAt`, a queue's `remove()` (in a collection, not an iterator) `removeHead`.
 */
private fun libraryMember(fn: KtNamedFunction, name: String, inCollection: Boolean): String = when {
    (name == "add" || name == "addAll") && fn.valueParameters.size == 2 -> name + "At"
    name == "listIterator" && fn.valueParameters.size == 1 -> "listIteratorAt"
    name == "remove" && fn.valueParameters.isEmpty() && inCollection -> "removeHead"
    else -> name
}

/**
 * Whether a property is compiled to `getX`/`setX` functions: extension properties, and top-level properties with
 * a custom getter or setter (their backing field, if any, is a hidden local).
 */
internal fun KtProperty.hasAccessorFunctions(): Boolean =
    receiverTypeReference != null || (isTopLevel && delegate == null && (getter?.hasBody() == true || setter?.hasBody() == true))
