package dev.k2l.transform

import org.jetbrains.kotlin.KtNodeTypes
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtConstantExpression
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtSimpleNameExpression
import org.jetbrains.kotlin.psi.KtSuperTypeListEntry
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
import org.jetbrains.kotlin.psi.KtTryExpression
import org.jetbrains.kotlin.psi.KtUserType

/** The files of the module being compiled and how they reference each other. */
class ModuleContext(
    val files: Set<KtFile>,
    /** Lua module name for `require`, e.g. `util.strings`. */
    val modulePath: (KtFile) -> String,
    /** Files that are part of an import cycle; their exports table is registered before anything is required. */
    val cyclic: Set<KtFile> = emptySet(),
    /** Files required by another file; `main()` is only called in files nobody requires. */
    val imported: Set<KtFile> = emptySet(),
) {
    private val classesByFile = HashMap<KtFile, Map<ClassId, KtClassOrObject>>()

    private fun classesOf(file: KtFile): Map<ClassId, KtClassOrObject> = classesByFile.getOrPut(file) {
        val result = LinkedHashMap<ClassId, KtClassOrObject>()
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitClassOrObject(classOrObject: KtClassOrObject) {
                classOrObject.getClassId()?.let { result.putIfAbsent(it, classOrObject) }
                super.visitClassOrObject(classOrObject)
            }
        })
        result
    }

    private val classIndex: Map<ClassId, KtClassOrObject> by lazy {
        val result = HashMap<ClassId, KtClassOrObject>()
        files.forEach { f -> classesOf(f).forEach { (id, c) -> result.putIfAbsent(id, c) } }
        result
    }

    /** Every class, object and object expression of the module, local ones included. */
    val allClasses: List<KtClassOrObject> by lazy {
        val result = ArrayList<KtClassOrObject>()
        files.forEach { f ->
            f.accept(object : KtTreeVisitorVoid() {
                override fun visitClassOrObject(classOrObject: KtClassOrObject) {
                    result += classOrObject
                    super.visitClassOrObject(classOrObject)
                }
            })
        }
        result
    }

    /** The source class with [id], looked up in [preferred] first; indexes are built once per module, not per query. */
    fun classInFile(id: ClassId, preferred: KtFile): KtClassOrObject? = classesOf(preferred)[id] ?: classIndex[id]

    /** Per-module results that need an analysis session to compute but only hold PSI (see `PropertyFamilies`). */
    val shared = HashMap<String, Any>()

    /** Whether some file uses `::class`, `javaClass` or `typeOf`: then classes record their qualified names (see Reflection.kt). */
    val usesReflection: Boolean by lazy { files.any(::mentionsReflection) }

    /**
     * Whether some file mentions `Float`: then the runtime recognizes floats among untyped values, so a statically
     * typed `Double` is printed by `__K2L_DoubleToString` rather than through the untyped printer.
     */
    val usesFloat: Boolean by lazy { files.any(::mentionsFloat) }

    /**
     * Whether some file calls `Collections.unmodifiableList`, `unmodifiableCollection`, `subList` or `asList`, or declares a
     * class extending `AbstractList` (or implementing `List`): such lists (views) have no array part, so loops over lists have
     * to index them rather than use `ipairs`, which does not follow `__index` before Lua 5.3.
     */
    val usesListViews: Boolean by lazy { files.any(::mentionsListViews) }

    /** Whether some class implements `ClosedRange`: then `start` of a ClosedRange value may be its own property. */
    val implementsClosedRange: Boolean by lazy { files.any { mentionsSuperType(it, setOf("ClosedRange")) } }

    /** Casts whose results are checked where they are used (see UncheckedCasts.kt). */
    internal val uncheckedCasts: UncheckedCasts by lazy { UncheckedCasts.scan(files) }

    /** Whether some file has a `try` or calls `use` or `runCatching`, which run their blocks in protected calls. */
    val usesTry: Boolean by lazy { files.any(::mentionsTry) }

    /** Whether some class implements `CharSequence`: then CharSequence values may be objects (see CharSequences.kt). */
    val implementsCharSequence: Boolean by lazy { files.any { mentionsSuperType(it, setOf("CharSequence")) } }

    /**
     * Whether some class extends or implements a library collection or map: then a collection value may be an object of
     * the program, whose collection operations call its overrides (see CollectionOverrides.lua) and stay method calls.
     */
    val implementsCollections: Boolean by lazy { files.any { mentionsSuperType(it, COLLECTION_TYPES) } }

    private fun mentionsSuperType(file: KtFile, names: Set<String>): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitSuperTypeListEntry(specifier: KtSuperTypeListEntry) {
                if ((specifier.typeReference?.typeElement as? KtUserType)?.referencedName in names) found = true
                super.visitSuperTypeListEntry(specifier)
            }
        })
        return found
    }

    private fun mentionsTry(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitTryExpression(expression: KtTryExpression) {
                found = true
            }

            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() in PROTECTING_NAMES) found = true
            }
        })
        return found
    }

    private fun mentionsListViews(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() in VIEW_NAMES) found = true
            }

            override fun visitSuperTypeListEntry(specifier: KtSuperTypeListEntry) {
                val type = specifier.typeReference?.typeElement as? KtUserType
                if (type?.referencedName in LIST_BASES) found = true
                super.visitSuperTypeListEntry(specifier)
            }
        })
        return found
    }

    private var functionNames: Boolean? = null

    /** Whether some file reads the `name` of a function reference held in a value; computed once with [scan]. */
    fun usesFunctionNames(scan: (Set<KtFile>) -> Boolean): Boolean = functionNames ?: scan(files).also { functionNames = it }

    private fun mentionsFloat(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitConstantExpression(expression: KtConstantExpression) {
                if (expression.node.elementType == KtNodeTypes.FLOAT_CONSTANT && expression.text.last() in "fF") found = true
            }

            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() in FLOAT_NAMES) found = true
            }
        })
        return found
    }

    private fun mentionsReflection(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitClassLiteralExpression(expression: KtClassLiteralExpression) {
                found = true
            }

            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                val name = expression.getReferencedName()
                if (name == "javaClass" ||
                    (name == "typeOf" && (expression.parent as? KtCallExpression)?.typeArgumentList != null)
                ) {
                    found = true
                }
            }
        })
        return found
    }

    companion object {
        private val PROTECTING_NAMES = setOf("use", "runCatching", "synchronized")
        private val VIEW_NAMES = setOf("unmodifiableList", "unmodifiableCollection", "subList", "asList")
        private val LIST_BASES = setOf("AbstractList", "AbstractMutableList", "List", "MutableList")
        private val COLLECTION_TYPES = listOf("Iterable", "Collection", "List", "Set", "Map").flatMap {
            listOf(it, "Mutable$it", "Abstract$it", "AbstractMutable$it")
        }.toSet() + setOf(
            "ArrayList", "LinkedList", "HashSet", "LinkedHashSet", "TreeSet", "SortedSet", "NavigableSet", "HashMap", "LinkedHashMap",
            "TreeMap", "SortedMap", "NavigableMap", "ArrayDeque", "Deque", "Queue", "AbstractQueue", "PriorityQueue",
            "AbstractSequentialList", "Vector", "Stack", "MutableIterable",
        )
        private val FLOAT_NAMES = setOf("Float", "FloatArray", "floatArrayOf", "toFloat", "toFloatOrNull", "toFloatArray", "nextFloat")

        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}
