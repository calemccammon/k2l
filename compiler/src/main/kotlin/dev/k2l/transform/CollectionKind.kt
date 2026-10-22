package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaIntersectionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.psi.KtClassOrObject

/** Runtime representation of a Kotlin library type, see `Collections.lua`. */
enum class CollectionKind {
    List,
    Array,
    Set,
    Map,
    Iterable,
    Range,
    Entry,
    Pair,
    Triple,
    IndexedValue,
    StringBuilder,
    LuaTable,
    Sequence,
    Regex,
    Match,
    Iterator,
    ClosedRange,
    Grouping,
    ;

    /** Lists and arrays share one representation: a 1-based table with a `size` field. */
    val isIndexable: Boolean get() = this == List || this == Array
}

private val KIND_BY_CLASS: Map<String, CollectionKind> = buildMap {
    fun kind(kind: CollectionKind, vararg ids: String) = ids.forEach { put(it, kind) }
    kind(
        CollectionKind.List,
        "kotlin/collections/List",
        "kotlin/collections/MutableList",
        "java/util/ArrayList",
        "java/util/List",
        "kotlin/collections/ArrayList",
        "java/util/AbstractList",
        "kotlin/enums/EnumEntries",
        "kotlin/collections/ArrayDeque",
        "kotlin/text/MatchResult.Destructured",
        "kotlin/text/MatchGroupCollection",
        "kotlin/collections/AbstractList",
        "kotlin/collections/AbstractMutableList",
    )
    val arrays = listOf("", "Int", "Long", "Double", "Float", "Boolean", "Char", "Short", "Byte")
    for (t in arrays) put("kotlin/${t}Array", CollectionKind.Array)
    kind(
        CollectionKind.Set,
        "kotlin/collections/Set",
        "kotlin/collections/MutableSet",
        "java/util/HashSet",
        "java/util/LinkedHashSet",
        "java/util/Set",
        "kotlin/collections/HashSet",
        "kotlin/collections/LinkedHashSet",
        // what toSortedSet() and sortedSetOf() return: their Set operations (a TreeSet's navigation is not there)
        "java/util/SortedSet",
        "java/util/TreeSet",
        "kotlin/collections/AbstractSet",
        "kotlin/collections/AbstractMutableSet",
        "java/util/AbstractSet",
    )
    kind(
        CollectionKind.Map,
        "kotlin/collections/Map",
        "kotlin/collections/MutableMap",
        "java/util/HashMap",
        "java/util/LinkedHashMap",
        "java/util/Map",
        "kotlin/collections/HashMap",
        "kotlin/collections/LinkedHashMap",
        // what toSortedMap() and sortedMapOf() return: their Map operations (a TreeMap's navigation is not there)
        "java/util/SortedMap",
        "kotlin/collections/AbstractMap",
        "kotlin/collections/AbstractMutableMap",
        "java/util/AbstractMap",
    )
    kind(
        CollectionKind.Iterable,
        "kotlin/collections/Iterable",
        "kotlin/collections/MutableIterable",
        "kotlin/collections/Collection",
        "kotlin/collections/MutableCollection",
        "java/util/Collection",
        "java/lang/Iterable",
        "kotlin/collections/AbstractCollection",
        "kotlin/collections/AbstractMutableCollection",
        "java/util/AbstractCollection",
    )
    kind(
        CollectionKind.Range,
        "kotlin/ranges/IntRange",
        "kotlin/ranges/IntProgression",
        "kotlin/ranges/LongRange",
        "kotlin/ranges/LongProgression",
        "kotlin/ranges/CharRange",
        "kotlin/ranges/CharProgression",
    )
    kind(
        CollectionKind.ClosedRange,
        "kotlin/ranges/ClosedRange",
        "kotlin/ranges/ClosedFloatingPointRange",
    )
    kind(CollectionKind.Grouping, "kotlin/collections/Grouping")
    kind(CollectionKind.Regex, "kotlin/text/Regex")
    kind(CollectionKind.Match, "kotlin/text/MatchResult", "kotlin/text/MatchGroup")
    kind(
        CollectionKind.Iterator,
        "kotlin/collections/Iterator",
        "kotlin/collections/MutableIterator",
        "kotlin/collections/ListIterator",
        "kotlin/collections/MutableListIterator",
        "kotlin/collections/CharIterator",
        "kotlin/collections/IntIterator",
        "kotlin/collections/BooleanIterator",
        "kotlin/collections/ByteIterator",
        "kotlin/collections/ShortIterator",
        "kotlin/collections/LongIterator",
        "kotlin/collections/FloatIterator",
        "kotlin/collections/DoubleIterator",
        "java/util/Iterator",
        "kotlin/collections/AbstractIterator",
    )
    put("kotlin/collections/Map.Entry", CollectionKind.Entry)
    put("kotlin/collections/MutableMap.MutableEntry", CollectionKind.Entry)
    put("java/util/Map.Entry", CollectionKind.Entry)
    put("kotlin/Pair", CollectionKind.Pair)
    put("kotlin/Triple", CollectionKind.Triple)
    put("kotlin/collections/IndexedValue", CollectionKind.IndexedValue)
    put("java/lang/StringBuilder", CollectionKind.StringBuilder)
    put("java/lang/StringBuffer", CollectionKind.StringBuilder)
    put("kotlin/text/StringBuilder", CollectionKind.StringBuilder)
    put("dev/k2l/lua/LuaTable", CollectionKind.LuaTable)
    put("kotlin/sequences/Sequence", CollectionKind.Sequence)
}

context(s: KaSession)
fun KaType.collectionKind(): CollectionKind? = with(s) {
    val unwrapped = withoutFlexibility
    // a type parameter (`C : MutableCollection<in V>`, `E : Map.Entry<K, V>`) is represented like its bound
    if (unwrapped is KaTypeParameterType) return unwrapped.symbol.upperBounds.firstNotNullOfOrNull { it.collectionKind() }
    // a smart cast (`this is Collection<*>` of an Iterable): the most specific kind of its parts
    if (unwrapped is KaIntersectionType) {
        val kinds = unwrapped.conjuncts.mapNotNull { it.collectionKind() }
        return INHERITED_KINDS.firstOrNull { it in kinds } ?: kinds.firstOrNull()
    }
    val direct = withoutFlexibility.expandedSymbol?.classId?.asString()?.let(KIND_BY_CLASS::get)
    if (direct != null) return direct
    // A class of the program implementing Sequence has all the Sequence operations; one extending or implementing a library
    // collection (AbstractList, ArrayList, Map, ...) those of the collection.
    val symbol = withoutFlexibility.expandedSymbol
    if (symbol?.psi !is KtClassOrObject) return null
    val supertypes = withoutFlexibility.allSupertypes.mapNotNull { it.expandedSymbol?.classId?.asString() }.toSet()
    if (SEQUENCE_ID in supertypes) return CollectionKind.Sequence
    val kinds = supertypes.mapNotNull(KIND_BY_CLASS::get).toSet()
    return INHERITED_KINDS.firstOrNull { it in kinds }
}

private const val SEQUENCE_ID = "kotlin/sequences/Sequence"

/** The collection kinds a class of the program can inherit, most specific first. */
private val INHERITED_KINDS =
    listOf(
        CollectionKind.Map,
        CollectionKind.List,
        CollectionKind.Set,
        CollectionKind.Iterator,
        CollectionKind.Iterable,
        CollectionKind.Entry,
        CollectionKind.ClosedRange,
    )

/** The kinds whose values are a group of elements, as the argument of `plus`/`minus` (`list + otherList`). */
internal val ELEMENT_GROUPS = setOf(
    CollectionKind.List,
    CollectionKind.Array,
    CollectionKind.Set,
    CollectionKind.Iterable,
    CollectionKind.Range,
    CollectionKind.Sequence,
)

/** Lua class names for library types that can be constructed or type-checked. */
val LIBRARY_COLLECTION_CLASSES = mapOf(
    CollectionKind.List to "__K2L_List", CollectionKind.Array to "__K2L_Array", CollectionKind.Set to "__K2L_Set",
    CollectionKind.Map to "__K2L_Map", CollectionKind.Iterable to "__K2L_Iterable", CollectionKind.Range to "__K2L_IntRange",
    CollectionKind.Pair to "__K2L_Pair", CollectionKind.Triple to "__K2L_Triple", CollectionKind.Entry to "__K2L_Entry",
    CollectionKind.StringBuilder to "__K2L_StringBuilder", CollectionKind.Sequence to "__K2L_Sequence",
    CollectionKind.Regex to "__K2L_Regex",
)

fun featureOf(luaName: String) = when {
    luaName == "__K2L_Pair" || luaName == "__K2L_Triple" -> "Pair"

    luaName == "__K2L_StringBuilder" -> "Strings"

    luaName == "__K2L_Sequence" -> SEQUENCE_FEATURE

    luaName == "__K2L_Regex" -> "Regex"

    luaName == ARRAY_DEQUE -> DEQUES_FEATURE

    luaName.startsWith("__K2L_Compare") || luaName.startsWith("__K2L_Then") || luaName.startsWith("__K2L_Nulls") ||
        luaName == "__K2L_ReverseComparator" ||
        luaName == "__K2L_NaturalOrder" || luaName == "__K2L_ReverseOrder" -> "Comparators"

    else -> "Collections"
}

/** The lualib class of `kotlin.collections.ArrayDeque`, see `Deques.lua`. */
internal const val ARRAY_DEQUE = "__K2L_ArrayDeque"

/** Lua classes for `is`/`as` against library collection classes that share their kind's representation with others. */
val SPECIFIC_COLLECTION_CLASSES = mapOf("kotlin/collections/ArrayDeque" to ARRAY_DEQUE)
