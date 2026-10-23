package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

internal class SuperInfo(
    val base: KtClassOrObject?,
    val baseCall: KtSuperTypeCallEntry?,
    val interfaces: List<KtClassOrObject>,
    val unsupported: KtSuperTypeListEntry?,
    /** A lualib class extended instead of an in-file one, e.g. `__K2L_Exception`. */
    val libraryBase: String? = null,
    /** The class implements `kotlin.sequences.Sequence` itself (its table extends the lualib `Sequence`). */
    val sequenceBase: Boolean = false,
    /** The class extends `AbstractCoroutineContextElement(key)`, which the lualib implements. */
    val elementBase: Boolean = false,
    /** The class implements `Sequence` next to a base class: the lualib `Sequence` is one of its interfaces. */
    val sequenceMixin: Boolean = false,
    /** A lualib collection class extended or implemented, e.g. `__K2L_AbstractList` or `__K2L_List` (see CollectionBases). */
    val collectionBase: String? = null,
    /** Lualib mixins of library SAM interfaces the class implements (`Comparator`, `Runnable`, function types). */
    val samMixins: List<String> = emptyList(),
    /** `: I by expr` entries, in declaration order. */
    val delegations: List<InterfaceDelegation> = emptyList(),
    /** `: List<T> by expr` and the like: library interfaces whose members are forwarded to the delegate (see LibraryDelegation). */
    val libraryDelegations: List<LibraryDelegation> = emptyList(),
    /** The lualib base of a collection interface implemented next to a base that is not a collection, as an interface. */
    val collectionMixin: String? = null,
    /** The class extends `kotlin.random.Random()`: the lualib base draws everything from the class's `nextBits` (Random.lua). */
    val randomBase: Boolean = false,
)

/** `: I by expr`: the delegate is stored in [field] of the instance when it is constructed. */
internal class InterfaceDelegation(val entry: KtDelegatedSuperTypeEntry, val iface: KtClassOrObject, val field: String)

/** `: Comparator<T> by cmp`: a library interface; the delegate is stored in [field] like that of an [InterfaceDelegation]. */
internal class LibraryDelegation(val entry: KtDelegatedSuperTypeEntry, val field: String)

/** Queries over the classes of the module being compiled: supertypes, initializers and `equals`. */
internal class ClassHierarchy(private val session: KaSession, private val file: KtFile, val module: ModuleContext) {
    /** Whether [psi] is declared in one of the module's source files (not a library). */
    fun isSource(psi: PsiElement?): Boolean = (psi?.containingFile as? KtFile)?.let { it in module.files } == true

    /** [c] and its in-file supertypes, supertypes first. */
    fun hierarchy(c: KtClassOrObject): List<KtClassOrObject> {
        val result = LinkedHashSet<KtClassOrObject>()
        fun visit(k: KtClassOrObject) {
            if (k in result) return
            superInfo(k).let { listOfNotNull(it.base) + it.interfaces }.forEach(::visit)
            result += k
        }
        visit(c)
        return result.toList()
    }

    /** Top-level functions of the module's files. */
    fun topLevelFunctions(): List<KtNamedFunction> = module.files.flatMap { it.declarations.filterIsInstance<KtNamedFunction>() }

    fun classInFile(id: ClassId): KtClassOrObject? = module.classInFile(id, file)

    private val superInfoCache = HashMap<KtClassOrObject, SuperInfo>()

    fun superInfo(c: KtClassOrObject): SuperInfo = superInfoCache.getOrPut(c) {
        if (c is KtEnumEntry) {
            // an entry with a body is a subclass of its enum class
            val call = c.initializerList?.initializers?.firstOrNull() as? KtSuperTypeCallEntry
            return@getOrPut SuperInfo(c.containingClassOrObject, call, emptyList(), null)
        }
        with(session) { classifySupertypes(c, ::isSource, ::isSequenceClass, { collectionBaseOf(it) != null }) }
    }

    private val initCache = HashMap<KtClassOrObject, Boolean>()

    /** Whether the constructor of a class binds members without `self` to the instance (see NoSelfMembers.kt). */
    var bindsMembers: (KtClassOrObject) -> Boolean = { false }

    /** Whether the primary constructor does anything, i.e. whether `____init` is generated for it. */
    fun initNeeded(c: KtClassOrObject): Boolean = initCache.getOrPut(c) {
        if ((c is KtClass && c.isInterface()) || !hasPrimary(c)) return@getOrPut false
        val info = superInfo(c)
        c.hasConstructorState() || c.hasInitializers() || info.baseCall?.valueArguments?.isNotEmpty() == true ||
            info.libraryBase != null || info.elementBase || info.collectionBase in CONCRETE_COLLECTION_BASES ||
            info.delegations.isNotEmpty() || info.libraryDelegations.isNotEmpty() ||
            info.base?.let { !hasPrimary(it) || initNeeded(it) } == true
    }

    private fun KtClassOrObject.hasConstructorState() =
        (this is KtClass && (isEnum() || isInner() || primaryConstructorParameters.isNotEmpty())) || bindsMembers(this)

    private fun KtClassOrObject.hasInitializers() =
        declarations.any { (it is KtProperty && (it.initializer != null || it.delegate != null)) || it is KtAnonymousInitializer }

    fun mayOverrideEquals(t: KaType?): Boolean = with(session) {
        val symbol = t?.expandedSymbol ?: return true
        if (symbol.classId?.asString() in IDENTITY_TYPES) return false
        if (symbol.classKind == KaClassKind.ENUM_CLASS || symbol.classKind.isObject) return false
        val psi = symbol.psi as? KtClassOrObject
        if (psi == null || !isSource(psi)) return true
        return overridesEquals(psi) || psi.hasModifier(KtTokens.OPEN_KEYWORD) || psi.hasModifier(KtTokens.ABSTRACT_KEYWORD) ||
            psi.hasModifier(KtTokens.SEALED_KEYWORD) || (psi is KtClass && psi.isInterface())
    }

    fun knownEquals(t: KaType): Boolean = with(session) {
        val psi = t.expandedSymbol?.psi as? KtClassOrObject ?: return false
        return isSource(psi) && overridesEquals(psi)
    }

    /** Whether [c] has an `equals` other than identity: its own, a data class's, or a library collection's it extends. */
    fun overridesEquals(c: KtClassOrObject): Boolean = (c is KtClass && c.hasDataMembers()) ||
        c.declaredFunction("equals")?.hasModifier(KtTokens.OVERRIDE_KEYWORD) == true ||
        superInfo(c).collectionBase != null ||
        superInfo(c).base?.let { overridesEquals(it) } == true
}

internal fun KtClassOrObject.declaredFunction(name: String) =
    declarations.filterIsInstance<KtNamedFunction>().firstOrNull { it.name == name }

internal fun hasPrimary(c: KtClassOrObject) = c !is KtClass || c.primaryConstructor != null || c.secondaryConstructors.isEmpty()

/** Whether [c] (or a source superclass) implements `Sequence`. */
internal fun ClassHierarchy.isSequenceClass(c: KtClassOrObject): Boolean =
    superInfo(c).let { it.sequenceBase || it.sequenceMixin || it.base?.let(::isSequenceClass) == true }

/** The lualib collection class [c] (or a source superclass) extends or implements, if any. */
internal fun ClassHierarchy.collectionBaseOf(c: KtClassOrObject): String? = superInfo(c).let {
    it.collectionBase ?: it.collectionMixin ?: it.base?.let(::collectionBaseOf)
}

/** Names of the properties [c] declares (in its body or as `val`/`var` constructor parameters). */
internal fun declaredFieldNames(c: KtClassOrObject): Set<String> {
    val fields = (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }?.mapNotNull { it.name }.orEmpty().toMutableSet()
    c.declarations.filterIsInstance<KtProperty>().filter { it.receiverTypeReference == null }.mapNotNullTo(fields) { it.name }
    return fields
}

/**
 * Names of the properties stored as fields of the instances of [c]: those of [c], its supertypes and its subclasses in the
 * module. A method sharing one of these names would be hidden by the field (see `DeclarationNames.function`).
 */
internal fun ClassHierarchy.fieldNames(c: KtClassOrObject): Set<String> {
    val below = module.shared.getOrPut(FIELD_NAMES_BELOW) {
        val result = HashMap<KtClassOrObject, MutableSet<String>>()
        for (k in module.allClasses) {
            val names = declaredFieldNames(k)
            if (names.isNotEmpty()) hierarchy(k).forEach { result.getOrPut(it) { HashSet() } += names }
        }
        result
    }
    return below[c].orEmpty() + hierarchy(c).flatMap(::declaredFieldNames)
}

/** The field names of each class's subclasses, see [fieldNames]. */
private val FIELD_NAMES_BELOW = SharedKey<Map<KtClassOrObject, Set<String>>>("fieldNamesBelow")
