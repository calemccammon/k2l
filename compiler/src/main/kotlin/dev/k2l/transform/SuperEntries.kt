package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.psi.*

private const val SEQUENCE_CLASS = "kotlin/sequences/Sequence"
private const val ELEMENT_CLASS = "kotlin/coroutines/AbstractCoroutineContextElement"
private const val RANDOM_CLASS = "kotlin/random/Random"

/** Collects the supertype entries of a class by what they need at run time. */
private class SuperEntries {
    var base: KtClassOrObject? = null
    var baseCall: KtSuperTypeCallEntry? = null
    var bad: KtSuperTypeListEntry? = null
    var libraryBase: String? = null
    var sequence: KtSuperTypeListEntry? = null

    /** `AbstractCoroutineContextElement(key)`, or `Random()` when [random]: a lualib base class with no constructor state of its own. */
    var element: KtSuperTypeListEntry? = null
    var random = false
    val interfaces = mutableListOf<KtClassOrObject>()

    /** Library interfaces with a single abstract method, implemented through a lualib mixin (see SAM_MIXINS). */
    val samMixins = mutableListOf<String>()

    /** A library collection class or interface the lualib implements (see CollectionBases). */
    var collection: String? = null
    var collectionEntry: KtSuperTypeListEntry? = null

    /** The lualib base of a collection interface implemented next to a base class that is not a collection. */
    var collectionMixin: String? = null

    val delegations = mutableListOf<InterfaceDelegation>()
    val libraryDelegations = mutableListOf<LibraryDelegation>()
}

/** What the class `c` extends and implements: source classes, library bases the lualib implements, and unsupported entries. */
internal fun KaSession.classifySupertypes(
    c: KtClassOrObject,
    isSource: (KtClassOrObject) -> Boolean,
    isSequenceClass: (KtClassOrObject) -> Boolean,
    isCollectionClass: (KtClassOrObject) -> Boolean,
): SuperInfo {
    val found = SuperEntries()
    c.superTypeListEntries.forEach { entry -> add(found, entry, isSource) }
    checkCollection(found, isCollectionClass)
    // A class that implements Sequence next to a source class, a library class or the context element base gets the Sequence
    // operations as a mixin: its table lists the lualib Sequence among its interfaces.
    val ownSequence = found.sequence != null && found.base == null && found.libraryBase == null && found.element == null &&
        found.collection == null
    val inheritsSequence = found.base?.let(isSequenceClass) ?: false
    val sequenceMixin = found.sequence != null && !ownSequence && !inheritsSequence
    if (found.element != null && (found.base != null || found.libraryBase != null)) found.bad = found.bad ?: found.element
    val (elementBase, randomBase) = lualibBases(found)
    return SuperInfo(
        found.base, found.baseCall, found.interfaces, found.bad, found.libraryBase, ownSequence, elementBase, sequenceMixin,
        found.collection, found.samMixins, found.delegations, found.libraryDelegations, found.collectionMixin,
        randomBase = randomBase,
    )
}

/** Whether the class extends `AbstractCoroutineContextElement` and whether it extends `Random`, the lualib bases of [SuperEntries.element]. */
private fun lualibBases(found: SuperEntries): Pair<Boolean, Boolean> {
    val extends = found.element != null && found.bad == null
    return (extends && !found.random) to (extends && found.random)
}

/**
 * A collection interface next to another base: nothing to add when that base already is a collection; otherwise the lualib
 * base of the interface is a mixin, one of the class's interfaces (`class Named : Base(), List<String>`).
 */
private fun checkCollection(found: SuperEntries, isCollectionClass: (KtClassOrObject) -> Boolean) {
    val entry = found.collectionEntry ?: return
    val base = found.base
    when {
        base != null && entry !is KtSuperTypeCallEntry && isCollectionClass(base) -> found.collection = null

        base == null && found.libraryBase == null && found.element == null -> Unit

        entry is KtSuperTypeCallEntry -> found.bad = found.bad ?: entry

        else -> {
            found.collectionMixin = found.collection
            found.collection = null
        }
    }
}

private fun KaSession.add(found: SuperEntries, entry: KtSuperTypeListEntry, isSource: (KtClassOrObject) -> Boolean) {
    val symbol = entry.typeReference?.type?.expandedSymbol
    val id = symbol?.classId?.asString()
    val psi = symbol?.psi as? KtClassOrObject
    if (entry !is KtDelegatedSuperTypeEntry) return addSupertype(found, entry, id, psi, isSource)
    val name = symbol?.name?.asString()
    val count = found.delegations.size + found.libraryDelegations.size
    val clash = found.delegations.any { it.iface.name == name } || found.libraryDelegations.any { it.field == "____delegate_$name" }
    val field = "____delegate_$name" + if (clash) "_$count" else ""
    when {
        // `: Named by impl`: an interface of the program whose members are forwarded to the delegate (see InterfaceDelegation)
        psi is KtClass && psi.isInterface() && isSource(psi) -> {
            found.interfaces += psi
            found.delegations += InterfaceDelegation(entry, psi, field)
        }

        // `: List<T> by xs`: implemented like the interface itself, with its members forwarded to the delegate
        id in DELEGATED_LIBRARY_INTERFACES -> {
            addSupertype(found, entry, id, psi, isSource)
            found.libraryDelegations += LibraryDelegation(entry, field)
        }

        else -> found.bad = found.bad ?: entry
    }
}

private fun addSupertype(
    found: SuperEntries,
    entry: KtSuperTypeListEntry,
    id: String?,
    psi: KtClassOrObject?,
    isSource: (KtClassOrObject) -> Boolean,
) {
    when {
        id in MARKER_INTERFACES -> Unit

        id == SEQUENCE_CLASS -> found.sequence = entry

        id == ELEMENT_CLASS || id == RANDOM_CLASS -> {
            found.element = entry
            found.random = id == RANDOM_CLASS
            found.baseCall = entry as? KtSuperTypeCallEntry
        }

        id in LIBRARY_CLASSES -> {
            found.libraryBase = LIBRARY_CLASSES[id]
            found.baseCall = entry as? KtSuperTypeCallEntry
        }

        id in COLLECTION_BASES -> addCollection(found, entry, COLLECTION_BASES.getValue(id!!))

        id in SAM_MIXINS -> found.samMixins += SAM_MIXINS.getValue(id!!)

        id == CLOSED_RANGE_CLASS -> found.samMixins += CLOSED_RANGE_MIXIN

        psi == null || !isSource(psi) -> found.bad = found.bad ?: entry

        psi is KtClass && psi.isInterface() -> found.interfaces += psi

        else -> {
            found.base = psi
            found.baseCall = entry as? KtSuperTypeCallEntry
        }
    }
}

/** A collection class (`AbstractList<Int>()`) wins over a collection interface listed next to it (`MutableList<Int>`). */
private fun addCollection(found: SuperEntries, entry: KtSuperTypeListEntry, lua: String) {
    val previous = found.collectionEntry
    when {
        previous == null || (previous !is KtSuperTypeCallEntry && entry is KtSuperTypeCallEntry) -> {
            found.collection = lua
            found.collectionEntry = entry
            if (entry is KtSuperTypeCallEntry) found.baseCall = entry
        }

        previous is KtSuperTypeCallEntry && entry is KtSuperTypeCallEntry -> found.bad = found.bad ?: entry

        else -> Unit
    }
}

/** Lualib feature with the mixins of library SAM interfaces, see `SamInterfaces.lua`. */
internal const val SAM_FEATURE = "SamInterfaces"

private const val CLOSED_RANGE_CLASS = "kotlin/ranges/ClosedRange"

/** The default `contains`/`isEmpty` of a class of the program implementing `ClosedRange` (in `Collections.lua`). */
internal const val CLOSED_RANGE_MIXIN = "__K2L_ClosedRangeMixin"

/** The lualib feature defining the mixin [name]. */
internal fun mixinFeature(name: String) = if (name == CLOSED_RANGE_MIXIN) "Collections" else SAM_FEATURE

/** The highest arity of `kotlin.FunctionN`. */
private const val MAX_FUNCTION_ARITY = 22

/**
 * Library interfaces with a single abstract method whose values are Lua callables (a lambda is a function): a class
 * implementing one lists the mixin among its interfaces, which makes its objects callable.
 */
internal val SAM_MIXINS: Map<String, String> = buildMap {
    put("java/util/Comparator", "__K2L_ComparatorMixin")
    put("java/lang/Runnable", "__K2L_RunnableMixin")
    put("java/util/concurrent/Callable", "__K2L_CallableMixin")
    for (n in 0..MAX_FUNCTION_ARITY) put("kotlin/Function$n", "__K2L_FunctionMixin")
}

/**
 * Library interfaces a class can delegate (`: Comparator<T> by cmp`): the collection interfaces, the SAM interfaces and the
 * ones whose members are the class's own. Their members are forwarded to the delegate (see LibraryDelegations.kt).
 */
private val DELEGATED_LIBRARY_INTERFACES: Set<String> = buildSet {
    for (kind in listOf("Iterable", "Collection", "List", "Set", "Map")) {
        add("kotlin/collections/$kind")
        add("kotlin/collections/Mutable$kind")
    }
    addAll(listOf("java/lang/Iterable", "java/util/Collection", "java/util/List", "java/util/Set", "java/util/Map"))
    addAll(SAM_MIXINS.keys)
    addAll(MARKER_INTERFACES.filter { it.startsWith("kotlin/collections/") || it.startsWith("java/") })
    addAll(listOf("kotlin/CharSequence", "kotlin/Comparable", "kotlin/properties/ReadWriteProperty", "kotlin/properties/ReadOnlyProperty"))
    add(SEQUENCE_CLASS)
}

/** ClosedRange's `contains`/`isEmpty` are members, so they win over the Iterable operations of a collection base (`DateRange`). */
internal fun FileTransformer.closedRangeMembers(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo) {
    if (CLOSED_RANGE_MIXIN !in info.samMixins || info.collectionBase == null) return
    for (name in listOf("contains", "isEmpty")) {
        if (c.declarations.any { it is KtNamedFunction && it.name == name }) continue
        emit(assign(LuaIndex(ref, LuaString(name)), LuaIndex(lualibRef("Collections", CLOSED_RANGE_MIXIN), LuaString(name))))
    }
}

/**
 * `C.____comparable = true` for a class, object or interface listing `Comparable` among its supertypes: `__K2L_IsComparable`
 * reads it, and subclasses and implementing classes inherit it through their metatables (a `compareTo` alone is not enough).
 */
internal fun FileTransformer.comparableFlag(c: KtClassOrObject, ref: LuaExpr) {
    if (listsComparable(c)) emit(assign(LuaIndex(ref, LuaString(COMPARABLE_FLAG)), LuaBool(true)))
}

private fun FileTransformer.listsComparable(c: KtClassOrObject): Boolean = with(session) {
    c.superTypeListEntries.any { it.typeReference?.type?.expandedSymbol?.classId?.asString() in COMPARABLE_CLASSES }
}

/**
 * A companion without a table of its own is its class's table, which holds what makes the instances Comparable (the flag above,
 * an enum's `____values`); as a value it is not Comparable, which `C.____companion = true` (read raw) tells.
 */
internal fun FileTransformer.sharedCompanionFlag(owner: KtClassOrObject, ref: LuaExpr) {
    val comparable = (owner is KtClass && owner.isEnum()) || classes.hierarchy(owner).any { listsComparable(it) }
    if (comparable) emit(assign(LuaIndex(ref, LuaString("____companion")), LuaBool(true)))
}

private const val COMPARABLE_FLAG = "____comparable"

private val COMPARABLE_CLASSES = setOf("kotlin/Comparable", "java/lang/Comparable")
