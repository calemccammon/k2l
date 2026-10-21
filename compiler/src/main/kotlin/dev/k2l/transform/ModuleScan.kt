package dev.k2l.transform

import org.jetbrains.kotlin.KtNodeTypes
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtConstantExpression
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtSimpleNameExpression
import org.jetbrains.kotlin.psi.KtSuperTypeListEntry
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
import org.jetbrains.kotlin.psi.KtTryExpression
import org.jetbrains.kotlin.psi.KtUserType

/**
 * What the files of a module mention, found in one walk over them: the flags of [ModuleContext] (`usesReflection`, ...).
 * Each flag only says whether some file mentions something, so it doesn't matter in which order the files are walked.
 */
internal class ModuleScan(files: Set<KtFile>) {
    /** `::class`, `javaClass` or `typeOf<T>()`. */
    var reflection = false
        private set

    /** A float literal (`1f`) or one of [FLOAT_NAMES]. */
    var float = false
        private set

    /** One of [VIEW_NAMES], or a class extending one of [LIST_BASES]. */
    var listViews = false
        private set

    /** A `try`, or one of [PROTECTING_NAMES]. */
    var protectedCalls = false
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
        override fun visitClassLiteralExpression(expression: KtClassLiteralExpression) {
            reflection = true
            super.visitClassLiteralExpression(expression)
        }

        override fun visitTryExpression(expression: KtTryExpression) {
            protectedCalls = true
            super.visitTryExpression(expression)
        }

        override fun visitConstantExpression(expression: KtConstantExpression) {
            if (expression.node.elementType == KtNodeTypes.FLOAT_CONSTANT && expression.text.last() in "fF") float = true
            super.visitConstantExpression(expression)
        }

        override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
            val name = expression.getReferencedName()
            val typeOfCall = name == "typeOf" && (expression.parent as? KtCallExpression)?.typeArgumentList != null
            if (name == "javaClass" || typeOfCall) reflection = true
            if (name in FLOAT_NAMES) float = true
            if (name in VIEW_NAMES) listViews = true
            if (name in PROTECTING_NAMES) protectedCalls = true
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
        val PROTECTING_NAMES = setOf("use", "runCatching", "synchronized")
        val VIEW_NAMES = setOf("unmodifiableList", "unmodifiableCollection", "unmodifiableSequencedCollection", "subList", "asList")
        val LIST_BASES = setOf("AbstractList", "AbstractMutableList", "List", "MutableList")
        val COLLECTION_TYPES = listOf("Iterable", "Collection", "List", "Set", "Map").flatMap {
            listOf(it, "Mutable$it", "Abstract$it", "AbstractMutable$it")
        }.toSet() + setOf(
            "ArrayList", "LinkedList", "HashSet", "LinkedHashSet", "TreeSet", "SortedSet", "NavigableSet", "HashMap", "LinkedHashMap",
            "TreeMap", "SortedMap", "NavigableMap", "ArrayDeque", "Deque", "Queue", "AbstractQueue", "PriorityQueue",
            "AbstractSequentialList", "Vector", "Stack", "MutableIterable",
        )
        val FLOAT_NAMES = setOf("Float", "FloatArray", "floatArrayOf", "toFloat", "toFloatOrNull", "toFloatArray", "nextFloat")
    }
}
