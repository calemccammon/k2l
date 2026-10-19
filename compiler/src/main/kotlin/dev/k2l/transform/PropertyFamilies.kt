package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
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
@Suppress("TooManyFunctions") // one query per aspect of a family; the scan itself is split into helper classes below
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
        val libraryOverrides: Set<KtNamedDeclaration>,
        val fields: List<KtNamedDeclaration>,
        /** Read while a constructor runs, so a subclass's field is seen before it is initialized (0, false or null). */
        val readInConstructor: Boolean = false,
    )

    // The scan covers the whole module, so it is done once and shared by the transformers of all files (it holds only PSI).
    private val families: Map<KtNamedDeclaration, Family> by lazy {
        @Suppress("UNCHECKED_CAST")
        module.shared.getOrPut("propertyFamilies", ::scan) as Map<KtNamedDeclaration, Family>
    }

    /** Whether [p] is read and written through `getX`/`setX` methods. */
    fun usesAccessors(p: KtNamedDeclaration): Boolean = families[p]?.accessors == true && !isExternal(p)

    /**
     * Whether [p] overrides a library property (`Throwable.message`, `Continuation.context`) and is read through an accessor:
     * the library, which reads the field, has to be sent to the accessor (see `PropertyOverride`).
     */
    fun overridesLibraryWithAccessor(p: KtNamedDeclaration): Boolean = families[p]?.let { it.accessors && p in it.libraryOverrides } == true

    /** Why the family of [p] cannot be compiled, or null. */
    fun problem(p: KtNamedDeclaration): String? = families[p]?.problem

    /** Whether [p] stores its value in a field of the object (the only accessor-less member of a field-less family has none). */
    fun hasOwnField(p: KtNamedDeclaration): Boolean = families[p]?.fields?.contains(p) == true

    /**
     * The value a read of [p]'s field gives before its initializer ran, when the family is read by a constructor
     * (the JVM's field default), or null when that is `nil` anyway or cannot happen.
     */
    fun uninitializedValue(p: KtNamedDeclaration): LuaExpr? {
        val family = families[p] ?: return null
        if (!family.readInConstructor || p !in family.fields.drop(1)) return null
        return with(session) { jvmFieldDefault((if (p is KtProperty) p.symbol else (p as KtParameter).symbol).returnType) }
    }

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
        val constructorReads = ConstructorReads(declarations).reads
        val delegated = delegatedInterfaces(declarations.classes)
        val result = HashMap<KtNamedDeclaration, Family>()
        for ((_, members) in all.groupBy(::find)) {
            val overrides = members.filter { it in libraryOverrides }.toSet()
            val family = family(members, overrides, declarations.readThroughSuper, constructorReads, delegated)
            members.forEach { result[it] = family }
        }
        return result
    }

    private fun family(
        members: List<KtNamedDeclaration>,
        libraryOverrides: Set<KtNamedDeclaration>,
        readThroughSuper: Set<PsiElement>,
        constructorReads: Set<PsiElement>,
        delegated: Set<KtClassOrObject>,
    ): Family {
        val fields = members.filter(::declaresField).sortedBy { classes.hierarchy(ownerClass(it) ?: return@sortedBy 0).size }
        // Separate backing fields are only observable through `super` or a constructor reading an overridden property;
        // otherwise one shared field behaves the same.
        val readInConstructor = members.any { it in constructorReads }
        val separateFields = fields.size > 1 && (readInConstructor || members.any { it in readThroughSuper })
        // a class delegating an interface forwards its properties to the delegate, which needs methods
        val accessors = members.any(::hasCustomAccessor) || separateFields || members.any { ownerClass(it) in delegated }
        return Family(members, accessors, null, libraryOverrides, fields, readInConstructor)
    }

    /** The interfaces some class delegates (`: I by impl`), with their superinterfaces. */
    private fun delegatedInterfaces(all: List<KtClassOrObject>): Set<KtClassOrObject> = with(session) {
        all.flatMap { c -> c.superTypeListEntries.filterIsInstance<KtDelegatedSuperTypeEntry>() }
            .mapNotNull { it.typeReference?.type?.expandedSymbol?.psi as? KtClassOrObject }
            .filter { classes.isSource(it) }
            .flatMap { classes.hierarchy(it) }
            .toSet()
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
        d is KtProperty && !isExternal(d) && (d.getter?.hasBody() == true || d.setter?.hasBody() == true || d.hasDelegate())

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
private class Declarations(
    val properties: List<KtNamedDeclaration>,
    val readThroughSuper: Set<PsiElement>,
    val classes: List<KtClassOrObject>,
    val functions: Map<String, List<KtNamedFunction>>,
)

private fun collectDeclarations(files: Set<KtFile>): Declarations {
    val properties = mutableListOf<KtNamedDeclaration>()
    val readThroughSuper = HashSet<PsiElement>()
    val classes = mutableListOf<KtClassOrObject>()
    val functions = mutableListOf<KtNamedFunction>()
    val visitor = object : KtTreeVisitorVoid() {
        override fun visitClassOrObject(classOrObject: KtClassOrObject) {
            classes += classOrObject
            super.visitClassOrObject(classOrObject)
        }

        override fun visitNamedFunction(function: KtNamedFunction) {
            if (function.name != null) functions += function
            super.visitNamedFunction(function)
        }

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
    return Declarations(properties, readThroughSuper, classes, functions.groupBy { it.name!! })
}

/**
 * The properties that code running during construction (`init` blocks, property initializers, secondary constructor
 * bodies, and the functions and accessors they call, overrides included) can read.
 */
private class ConstructorReads(private val declarations: Declarations) {
    val reads = HashSet<PsiElement>()
    private val visited = HashSet<PsiElement>()
    private val pending = ArrayDeque<PsiElement>()

    init {
        for (c in declarations.classes) {
            c.declarations.forEach { d ->
                when (d) {
                    is KtAnonymousInitializer -> pending += d
                    is KtProperty -> listOfNotNull(d.initializer, d.delegateExpression).forEach { pending += it }
                    is KtSecondaryConstructor -> d.bodyExpression?.let { pending += it }
                    else -> Unit
                }
            }
        }
        while (pending.isNotEmpty()) {
            val root = pending.removeFirst()
            if (visited.add(root)) scan(root)
        }
    }

    private fun scan(root: PsiElement) {
        root.accept(object : KtTreeVisitorVoid() {
            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                when (val target = expression.mainReference.resolve()) {
                    is KtNamedFunction -> declarations.functions[target.name].orEmpty().forEach { pending += it }

                    is KtProperty -> {
                        reads += target
                        listOfNotNull(target.getter?.takeIf { it.hasBody() }, target.setter?.takeIf { it.hasBody() }).forEach {
                            pending +=
                                it
                        }
                    }

                    is KtParameter -> reads += target

                    else -> Unit
                }
                super.visitSimpleNameExpression(expression)
            }
        })
    }
}
