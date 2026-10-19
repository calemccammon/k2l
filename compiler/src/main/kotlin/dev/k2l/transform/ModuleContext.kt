package dev.k2l.transform

import org.jetbrains.kotlin.KtNodeTypes
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtConstantExpression
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtSimpleNameExpression
import org.jetbrains.kotlin.psi.KtSuperTypeListEntry
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
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

    /** The source class with [id], looked up in [preferred] first; indexes are built once per module, not per query. */
    fun classInFile(id: ClassId, preferred: KtFile): KtClassOrObject? = classesOf(preferred)[id] ?: classIndex[id]

    /** Per-module results that need an analysis session to compute but only hold PSI (see `PropertyFamilies`). */
    val shared = HashMap<String, Any>()

    /** Whether some file uses `::class` or `javaClass`: then classes record their qualified names (see Reflection.kt). */
    val usesReflection: Boolean by lazy { files.any(::mentionsReflection) }

    /**
     * Whether some file mentions `Float`: then the runtime recognizes floats among untyped values, so a statically
     * typed `Double` is printed by `__K2L_DoubleToString` rather than through the untyped printer.
     */
    val usesFloat: Boolean by lazy { files.any(::mentionsFloat) }

    /**
     * Whether some file calls `Collections.unmodifiableList` or `unmodifiableCollection`, or declares a class extending
     * `AbstractList` (or implementing `List`): such lists have no array part, so loops over lists have to index them rather
     * than use `ipairs`, which does not follow `__index` before Lua 5.3.
     */
    val usesListViews: Boolean by lazy { files.any(::mentionsListViews) }

    /** Whether some class implements `CharSequence`: then CharSequence values may be objects (see CharSequences.kt). */
    val implementsCharSequence: Boolean by lazy { files.any { mentionsSuperType(it, "CharSequence") } }

    private fun mentionsSuperType(file: KtFile, name: String): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitSuperTypeListEntry(specifier: KtSuperTypeListEntry) {
                if ((specifier.typeReference?.typeElement as? KtUserType)?.referencedName == name) found = true
                super.visitSuperTypeListEntry(specifier)
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
                if (expression.getReferencedName() == "javaClass") found = true
            }
        })
        return found
    }

    companion object {
        private val VIEW_NAMES = setOf("unmodifiableList", "unmodifiableCollection")
        private val LIST_BASES = setOf("AbstractList", "AbstractMutableList", "List", "MutableList")
        private val FLOAT_NAMES = setOf("Float", "FloatArray", "floatArrayOf", "toFloat", "toFloatOrNull", "toFloatArray")

        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}
