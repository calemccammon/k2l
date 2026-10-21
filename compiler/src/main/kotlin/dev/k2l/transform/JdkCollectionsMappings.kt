package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType

/**
 * `java.util.Collections`, `java.util.Arrays`, `java.util.Random` and the `EnumSet` factories (see `JdkCollections.lua`,
 * `JavaRandom.lua` and `EnumCollections.lua`), plus `Map.withDefault` and `List.listIterator` of the Kotlin stdlib.
 */
internal object JdkCollectionsMappings {
    private const val COLLECTIONS = "java/util/Collections."
    private const val ARRAYS = "java/util/Arrays."
    private const val RANDOM = "java/util/Random"
    private const val ENUM_SET = "java/util/EnumSet."

    private val ENUM_SET_FUNCTIONS = setOf("noneOf", "allOf", "of", "copyOf", "range", "complementOf")

    /** The `synchronized*` wrappers, and the `checked*` ones, whose element type checks are left out. */
    private val IDENTITIES = listOf(
        "synchronizedSortedSet", "synchronizedNavigableSet", "synchronizedSortedMap", "synchronizedNavigableMap", "checkedList",
        "checkedCollection", "checkedSet", "checkedSortedSet", "checkedNavigableSet", "checkedQueue", "checkedMap", "checkedSortedMap",
        "checkedNavigableMap",
    )

    /** `Collections.x(...)` is the Lua function of the same name, unless listed here. */
    private val COLLECTIONS_RENAMED = mapOf(
        "binarySearch" to "binarySearch_array",
        "synchronizedList" to "identity",
        "synchronizedSet" to "identity",
        "synchronizedMap" to "identity",
        "synchronizedCollection" to "identity",
        "newSequencedSetFromMap" to "newSetFromMap",
    ) + IDENTITIES.associateWith { "identity" }

    private val COLLECTIONS_FUNCTIONS = setOf(
        "sort", "reverse", "shuffle", "swap", "max", "min", "frequency", "addAll", "fill", "rotate", "replaceAll", "copy", "disjoint",
        "nCopies", "emptyList", "emptySet", "emptyMap", "singletonList", "singleton", "singletonMap", "unmodifiableList",
        "unmodifiableSet", "unmodifiableMap", "unmodifiableCollection", "reverseOrder", "indexOfSubList", "lastIndexOfSubList",
        "emptyIterator", "emptyListIterator", "newSetFromMap", "unmodifiableSortedSet", "unmodifiableNavigableSet",
        "unmodifiableSequencedSet", "unmodifiableSortedMap", "unmodifiableNavigableMap", "unmodifiableSequencedMap",
        "unmodifiableSequencedCollection", "emptySortedSet", "emptySortedMap", "emptyNavigableSet", "emptyNavigableMap",
    ) + COLLECTIONS_RENAMED.keys

    private val ARRAYS_RENAMED = mapOf(
        "sort" to "sort_array",
        "fill" to "fill_array",
        "toString" to "arrayToString",
        "equals" to "arrayEquals",
        "deepEquals" to "arrayEquals",
        "hashCode" to "arrayHashCode",
        "deepHashCode" to "arrayHashCode",
        "binarySearch" to "binarySearch_array",
    )

    private val ARRAYS_FUNCTIONS = setOf("asList", "deepToString", "setAll", "copyOf", "copyOfRange") + ARRAYS_RENAMED.keys

    private val RANDOM_METHODS = setOf("nextInt", "nextLong", "nextDouble", "nextBoolean", "nextFloat", "nextGaussian", "setSeed")

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        callableId ?: return null
        val name = site.name ?: return null
        return when {
            callableId.startsWith(COLLECTIONS) && name in COLLECTIONS_FUNCTIONS -> lib(site, COLLECTIONS_RENAMED[name] ?: name, site.args)

            callableId.startsWith(ARRAYS) && name in ARRAYS_FUNCTIONS -> arrays(site, name)

            callableId.startsWith(ARRAYS) -> JdkCollectionMembers.arrays(name, site)

            callableId.startsWith(ENUM_SET) && name in ENUM_SET_FUNCTIONS && site.receiver == null ->
                site.libMember(ENUM_COLLECTIONS_FEATURE, "__K2L_EnumSets", name, *site.args.toTypedArray())

            (callableId.startsWith("$RANDOM.") || callableId.startsWith("java/util/random/RandomGenerator.")) &&
                name in RANDOM_METHODS && site.receiver != null ->
                method(site.self, name, *site.args.toTypedArray())

            callableId.startsWith("java/util/") -> JdkCollectionMembers.map(callableId, name, site) ?: kotlinCollections(site, name)

            callableId.startsWith("kotlin/collections/") -> kotlinCollections(site, name)

            else -> null
        }
    }

    private fun lib(site: CallSite, member: String, args: List<LuaExpr>): LuaExpr = site.libCall(JDK_COLLECTIONS_TABLE, member, args)

    private fun kotlinCollections(site: CallSite, name: String): LuaExpr? {
        val kind = site.receiverKind
        return when {
            name == "withDefault" && kind == CollectionKind.Map -> lib(site, "withDefault", listOf(site.self, site.arg(0)))
            name == "listIterator" && kind == CollectionKind.List -> lib(site, "listIterator", listOf(site.self) + site.args)
            else -> null
        }
    }

    private fun arrays(site: CallSite, name: String): LuaExpr = when (name) {
        "copyOf", "copyOfRange" -> lib(site, name, site.args + padFor(site, site.argTypes.firstOrNull()))
        else -> lib(site, ARRAYS_RENAMED[name] ?: name, site.args)
    }

    /** The zero value of an array's element type; null elements for object arrays. */
    private fun padFor(site: CallSite, type: KaType?): LuaExpr {
        val classId = with(site.session) { (type?.withoutFlexibility as? KaClassType)?.classId?.asString() }
        return when (classId) {
            "kotlin/DoubleArray", "kotlin/FloatArray" -> LuaNumber("0.0")
            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray" -> LuaNumber("0")
            "kotlin/BooleanArray" -> LuaBool(false)
            "kotlin/CharArray" -> LuaString("\u0000")
            else -> LuaNil
        }
    }

    /** `java.util.Random()` and `java.util.Random(seed)`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? = if (classId == RANDOM) {
        site.libNew("JavaRandom", "__K2L_JavaRandom", site.args)
    } else {
        null
    }
}
