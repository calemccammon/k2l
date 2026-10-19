package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.psi.*

private const val SEQUENCE_CLASS = "kotlin/sequences/Sequence"
private const val ELEMENT_CLASS = "kotlin/coroutines/AbstractCoroutineContextElement"

/** Collects the supertype entries of a class by what they need at run time. */
private class SuperEntries {
    var base: KtClassOrObject? = null
    var baseCall: KtSuperTypeCallEntry? = null
    var bad: KtSuperTypeListEntry? = null
    var libraryBase: String? = null
    var sequence: KtSuperTypeListEntry? = null
    var element: KtSuperTypeListEntry? = null
    val interfaces = mutableListOf<KtClassOrObject>()

    /** Library interfaces with a single abstract method, implemented through a lualib mixin (see SAM_MIXINS). */
    val samMixins = mutableListOf<String>()

    /** A library collection class or interface the lualib implements (see CollectionBases). */
    var collection: String? = null
    var collectionEntry: KtSuperTypeListEntry? = null

    val delegations = mutableListOf<InterfaceDelegation>()
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
    val elementBase = found.element != null && found.bad == null
    return SuperInfo(
        found.base, found.baseCall, found.interfaces, found.bad, found.libraryBase, ownSequence, elementBase, sequenceMixin,
        found.collection, found.samMixins, found.delegations,
    )
}

/**
 * A collection base needs the class to have no other base: implementing `List` next to a source class is only possible
 * when that class already is a collection (the interface adds nothing then).
 */
private fun checkCollection(found: SuperEntries, isCollectionClass: (KtClassOrObject) -> Boolean) {
    val entry = found.collectionEntry ?: return
    val base = found.base
    when {
        base != null && entry !is KtSuperTypeCallEntry && isCollectionClass(base) -> found.collection = null
        base != null || found.libraryBase != null || found.element != null -> found.bad = found.bad ?: entry
    }
}

private fun KaSession.add(found: SuperEntries, entry: KtSuperTypeListEntry, isSource: (KtClassOrObject) -> Boolean) {
    val symbol = entry.typeReference?.type?.expandedSymbol
    val id = symbol?.classId?.asString()
    val psi = symbol?.psi as? KtClassOrObject
    when {
        // `: Named by impl`: an interface of the program whose members are forwarded to the delegate (see InterfaceDelegation)
        entry is KtDelegatedSuperTypeEntry -> if (psi is KtClass && psi.isInterface() && isSource(psi)) {
            found.interfaces += psi
            val clash = found.delegations.any { it.iface.name == psi.name }
            found.delegations +=
                InterfaceDelegation(entry, psi, "____delegate_${psi.name}" + if (clash) "_${found.delegations.size}" else "")
        } else {
            found.bad = found.bad ?: entry
        }

        id in MARKER_INTERFACES -> Unit

        id == SEQUENCE_CLASS -> found.sequence = entry

        id == ELEMENT_CLASS -> {
            found.element = entry
            found.baseCall = entry as? KtSuperTypeCallEntry
        }

        id in LIBRARY_CLASSES -> {
            found.libraryBase = LIBRARY_CLASSES[id]
            found.baseCall = entry as? KtSuperTypeCallEntry
        }

        id in COLLECTION_BASES -> addCollection(found, entry, COLLECTION_BASES.getValue(id!!))

        id in SAM_MIXINS -> found.samMixins += SAM_MIXINS.getValue(id!!)

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
