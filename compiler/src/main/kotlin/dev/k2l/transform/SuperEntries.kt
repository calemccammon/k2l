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
}

/** What the class `c` extends and implements: source classes, library bases the lualib implements, and unsupported entries. */
internal fun KaSession.classifySupertypes(
    c: KtClassOrObject,
    isSource: (KtClassOrObject) -> Boolean,
    isSequenceClass: (KtClassOrObject) -> Boolean,
): SuperInfo {
    val found = SuperEntries()
    c.superTypeListEntries.forEach { entry -> add(found, entry, isSource) }
    // A class that extends a source class or a library class gets its Sequence operations only through that.
    val ownSequence = found.sequence != null && found.base == null && found.libraryBase == null
    val inheritsSequence = found.base?.let(isSequenceClass) ?: false
    if (found.sequence != null && !ownSequence && !inheritsSequence) found.bad = found.bad ?: found.sequence
    if (found.element != null && (found.base != null || found.libraryBase != null)) found.bad = found.bad ?: found.element
    val elementBase = found.element != null && found.bad == null
    return SuperInfo(found.base, found.baseCall, found.interfaces, found.bad, found.libraryBase, ownSequence, elementBase)
}

private fun KaSession.add(found: SuperEntries, entry: KtSuperTypeListEntry, isSource: (KtClassOrObject) -> Boolean) {
    val symbol = entry.typeReference?.type?.expandedSymbol
    val id = symbol?.classId?.asString()
    val psi = symbol?.psi as? KtClassOrObject
    when {
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

        psi == null || !isSource(psi) -> found.bad = found.bad ?: entry

        psi is KtClass && psi.isInterface() -> found.interfaces += psi

        else -> {
            found.base = psi
            found.baseCall = entry as? KtSuperTypeCallEntry
        }
    }
}
