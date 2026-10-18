package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Override families of member properties: a property plus everything it overrides or is overridden by in
 * the module's source files (closed world, so the scan is complete). A family with a custom getter or
 * setter anywhere is accessed through `getX`/`setX` methods everywhere, since a read through a base type
 * must reach the subclass's getter. So is a family whose members keep separate backing fields (an override
 * with its own value) when one of them is read through `super`. Any other family stays a plain table field.
 */
internal class PropertyFamilies(
    private val session: KaSession,
    private val module: ModuleContext,
    private val classes: ClassHierarchy,
    private val isExternal: (KtNamedDeclaration) -> Boolean,
) {
    private class Family(
        val members: List<KtNamedDeclaration>,
        val accessors: Boolean,
        val problem: String?,
        val fields: List<KtNamedDeclaration>,
    )

    private val families: Map<KtNamedDeclaration, Family> by lazy(::scan)

    /** Whether [p] is read and written through `getX`/`setX` methods. */
    fun usesAccessors(p: KtNamedDeclaration): Boolean = families[p]?.accessors == true && !isExternal(p)

    /** Why the family of [p] cannot be compiled, or null. */
    fun problem(p: KtNamedDeclaration): String? = families[p]?.problem

    /** Whether [p] stores its value in a field of the object (the only accessor-less member of a field-less family has none). */
    fun hasOwnField(p: KtNamedDeclaration): Boolean = families[p]?.fields?.contains(p) == true

    /** The Lua table key holding [p]'s backing field. Members of one family that each have a field get distinct keys, like the JVM. */
    fun fieldName(p: KtNamedDeclaration): String {
        val name = p.name!!
        val fields = families[p]?.takeIf { it.accessors }?.fields.orEmpty()
        if (fields.size < 2 || fields.first() == p) return name
        return "${name}__${ownerClass(p)?.name ?: "object"}"
    }

    private fun scan(): Map<KtNamedDeclaration, Family> {
        val declarations = collectDeclarations(module.files)
        val all = declarations.properties
        val parent = HashMap<KtNamedDeclaration, KtNamedDeclaration>()

        fun find(d: KtNamedDeclaration): KtNamedDeclaration {
            var root = d
            while (parent[root] != null && parent[root] != root) root = parent.getValue(root)
            return root
        }
        val libraryOverrides = HashSet<KtNamedDeclaration>()
        for (d in all) {
            for (o in overriddenDeclarations(d)) {
                if (o is KtNamedDeclaration && o in all) {
                    parent[find(o)] = find(d)
                } else {
                    libraryOverrides += d
                }
            }
        }
        val result = HashMap<KtNamedDeclaration, Family>()
        for ((_, members) in all.groupBy(::find)) {
            val family = family(members, members.any { it in libraryOverrides }, declarations.readThroughSuper)
            members.forEach { result[it] = family }
        }
        return result
    }

    private fun family(members: List<KtNamedDeclaration>, overridesLibrary: Boolean, readThroughSuper: Set<PsiElement>): Family {
        val fields = members.filter(::declaresField).sortedBy { classes.hierarchy(ownerClass(it) ?: return@sortedBy 0).size }
        // Separate backing fields are only observable through `super`; otherwise one shared field behaves the same.
        val separateFields = fields.size > 1 && members.any { it in readThroughSuper }
        val accessors = members.any(::hasCustomAccessor) || separateFields
        val problem = if (accessors && overridesLibrary) {
            "Custom accessors on a property overriding a library property are not supported yet"
        } else {
            null
        }
        return Family(members, accessors, problem, fields)
    }

    private fun overriddenDeclarations(d: KtNamedDeclaration): List<PsiElement?> = with(session) {
        val symbol: KaCallableSymbol? = when (d) {
            is KtProperty -> d.symbol
            is KtParameter -> (d.symbol as? KaValueParameterSymbol)?.generatedPrimaryConstructorProperty
            else -> null
        }
        symbol?.directlyOverriddenSymbols?.map { it.psi }?.toList().orEmpty()
    }

    private fun hasCustomAccessor(d: KtNamedDeclaration) =
        d is KtProperty && !isExternal(d) && (d.getter?.hasBody() == true || d.setter?.hasBody() == true)

    /** Whether [d] has a backing field: an initializer, a default accessor or a `field` reference. */
    fun declaresField(d: KtNamedDeclaration): Boolean {
        if (d is KtParameter) return true
        val p = d as KtProperty
        val owner = p.containingClassOrObject
        val bodiless = p.hasModifier(KtTokens.ABSTRACT_KEYWORD) || (owner is KtClass && owner.isInterface())
        if (p.hasDelegate() || bodiless) return false
        val defaultGetter = p.getter?.hasBody() != true
        val defaultSetter = p.isVar && p.setter?.hasBody() != true
        return p.initializer != null || defaultGetter || defaultSetter || usesField(p)
    }

    private fun isBackingField(e: KtSimpleNameExpression) = with(session) { e.mainReference.resolveToSymbol() } is KaBackingFieldSymbol

    private fun usesField(p: KtProperty): Boolean {
        var found = false
        val visitor = object : KtTreeVisitorVoid() {
            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() == "field" && isBackingField(expression)) {
                    found = true
                }
            }
        }
        p.getter?.accept(visitor)
        p.setter?.accept(visitor)
        return found
    }
}

/** The class a member property or constructor property parameter belongs to. */
internal fun ownerClass(d: KtNamedDeclaration): KtClassOrObject? =
    if (d is KtParameter) d.ownerFunction?.containingClassOrObject else d.containingClassOrObject

/** Member properties of the module's source files, and the declarations read through `super`. */
private class Declarations(val properties: List<KtNamedDeclaration>, val readThroughSuper: Set<PsiElement>)

private fun collectDeclarations(files: Set<KtFile>): Declarations {
    val properties = mutableListOf<KtNamedDeclaration>()
    val readThroughSuper = HashSet<PsiElement>()
    val visitor = object : KtTreeVisitorVoid() {
        override fun visitDotQualifiedExpression(expression: KtDotQualifiedExpression) {
            if (expression.receiverExpression is KtSuperExpression) {
                val selector = expression.selectorExpression as? KtNameReferenceExpression
                selector?.mainReference?.resolve()?.let { readThroughSuper += it }
            }
            super.visitDotQualifiedExpression(expression)
        }

        override fun visitProperty(property: KtProperty) {
            if (property.containingClassOrObject != null) properties += property
            super.visitProperty(property)
        }

        override fun visitParameter(parameter: KtParameter) {
            if (parameter.hasValOrVar() && parameter.ownerFunction is KtPrimaryConstructor) properties += parameter
            super.visitParameter(parameter)
        }
    }
    files.forEach { it.accept(visitor) }
    return Declarations(properties, readThroughSuper)
}
