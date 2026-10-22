package dev.k2l.transform

import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtSimpleNameExpression
import org.jetbrains.kotlin.psi.KtSuperTypeListEntry
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
import org.jetbrains.kotlin.psi.KtTryExpression
import org.jetbrains.kotlin.psi.KtUserType

/**
 * What the files of a module mention, found in one walk over them: the flags of [ModuleContext] (`usesListViews`, ...).
 * Each flag only says whether some file mentions something, so it doesn't matter in which order the files are walked.
 */
internal class ModuleScan(files: Set<KtFile>) {
    /** A class extending one of [LIST_BASES]. */
    var listViews = false
        private set

    /** A class implementing `ClosedRange`. */
    var closedRange = false
        private set

    /** A class implementing `CharSequence`. */
    var charSequence = false
        private set

    /** A class extending or implementing one of [COLLECTION_TYPES]. */
    var collections = false
        private set

    init {
        val visitor = Visitor()
        files.forEach { it.accept(visitor) }
    }

    private inner class Visitor : KtTreeVisitorVoid() {
        override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
            val name = expression.getReferencedName()
            super.visitSimpleNameExpression(expression)
        }

        override fun visitSuperTypeListEntry(specifier: KtSuperTypeListEntry) {
            val name = (specifier.typeReference?.typeElement as? KtUserType)?.referencedName
            if (name in LIST_BASES) listViews = true
            if (name == "ClosedRange") closedRange = true
            if (name == "CharSequence") charSequence = true
            if (name in COLLECTION_TYPES) collections = true
            super.visitSuperTypeListEntry(specifier)
        }
    }

    private companion object {
        val LIST_BASES = setOf("AbstractList", "AbstractMutableList", "List", "MutableList")
        val COLLECTION_TYPES = listOf("Iterable", "Collection", "List", "Set", "Map").flatMap {
            listOf(it, "Mutable$it", "Abstract$it", "AbstractMutable$it")
        }.toSet() + setOf(
            "ArrayList",
            "HashSet",
            "LinkedHashSet",
            "HashMap",
            "LinkedHashMap",
            "ArrayDeque",
            "MutableIterable",
        )
    }
}
