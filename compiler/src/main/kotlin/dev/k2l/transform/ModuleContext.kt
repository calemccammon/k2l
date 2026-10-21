package dev.k2l.transform

import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid

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
    internal val shared = ModuleShared()

    /** What the files mention, for the flags below: one walk over all of them, on the first flag read. */
    private val mentions: ModuleScan by lazy { ModuleScan(files) }

    /** Whether some file uses `::class`, `javaClass` or `typeOf`: then classes record their qualified names (see Reflection.kt). */
    val usesReflection: Boolean by lazy { mentions.reflection }

    /**
     * Whether some file mentions `Float`: then the runtime recognizes floats among untyped values, so a statically
     * typed `Double` is printed by `__K2L_DoubleToString` rather than through the untyped printer.
     */
    val usesFloat: Boolean by lazy { mentions.float }

    /**
     * Whether some file calls `Collections.unmodifiableList`, `unmodifiableCollection`, `subList` or `asList`, or declares a
     * class extending `AbstractList` (or implementing `List`): such lists (views) have no array part, so loops over lists have
     * to index them rather than use `ipairs`, which does not follow `__index` before Lua 5.3.
     */
    val usesListViews: Boolean by lazy { mentions.listViews }

    /** Whether some class implements `ClosedRange`: then `start` of a ClosedRange value may be its own property. */
    val implementsClosedRange: Boolean by lazy { mentions.closedRange }

    /** Casts whose results are checked where they are used (see UncheckedCasts.kt). */
    internal val uncheckedCasts: UncheckedCasts by lazy { UncheckedCasts.scan(files) }

    /** Whether some file has a `try` or calls `use` or `runCatching`, which run their blocks in protected calls. */
    val usesTry: Boolean by lazy { mentions.protectedCalls }

    /** Whether some class implements `CharSequence`: then CharSequence values may be objects (see CharSequences.kt). */
    val implementsCharSequence: Boolean by lazy { mentions.charSequence }

    /**
     * Whether some class extends or implements a library collection or map: then a collection value may be an object of
     * the program, whose collection operations call its overrides (see CollectionOverrides.lua) and stay method calls.
     */
    val implementsCollections: Boolean by lazy { mentions.collections }

    private var functionNames: Boolean? = null

    /** Whether some file reads the `name` of a function reference held in a value; computed once with [scan]. */
    fun usesFunctionNames(scan: (Set<KtFile>) -> Boolean): Boolean = functionNames ?: scan(files).also { functionNames = it }

    companion object {
        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}

/** The key of a per-module result of type [T] in [ModuleShared]; keys are compared by identity, so each is one constant. */
internal class SharedKey<T : Any>(private val name: String) {
    override fun toString() = name
}

/** Results computed once per module and shared by the transformers of its files, by [SharedKey]. */
internal class ModuleShared {
    private val values = HashMap<SharedKey<*>, Any>()

    fun <T : Any> getOrPut(key: SharedKey<T>, compute: () -> T): T {
        @Suppress("UNCHECKED_CAST") // only this function stores values, each under a key of its type
        return values.getOrPut(key, compute) as T
    }
}
