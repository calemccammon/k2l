package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtArrayAccessExpression

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

/** `StringBuilder.append(text, start, end)` */
private const val APPEND_RANGE_ARITY = 3

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
        "java/util/LinkedList",
        "kotlin/enums/EnumEntries",
        "kotlin/collections/ArrayDeque",
        "java/util/ArrayDeque",
        "java/util/Queue",
        "java/util/Deque",
        "kotlin/text/MatchResult.Destructured",
        "kotlin/text/MatchGroupCollection",
    )
    val arrayTypes =
        listOf("Array", "IntArray", "LongArray", "DoubleArray", "FloatArray", "BooleanArray", "CharArray", "ShortArray", "ByteArray")
    for (t in arrayTypes) {
        put("kotlin/$t", CollectionKind.Array)
    }
    kind(
        CollectionKind.Set,
        "kotlin/collections/Set",
        "kotlin/collections/MutableSet",
        "java/util/HashSet",
        "java/util/LinkedHashSet",
        "java/util/Set",
        "kotlin/collections/HashSet",
        "kotlin/collections/LinkedHashSet",
        "java/util/TreeSet",
        "java/util/SortedSet",
        "java/util/NavigableSet",
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
        "java/util/TreeMap",
        "java/util/SortedMap",
        "java/util/NavigableMap",
    )
    kind(
        CollectionKind.Iterable,
        "kotlin/collections/Iterable",
        "kotlin/collections/MutableIterable",
        "kotlin/collections/Collection",
        "kotlin/collections/MutableCollection",
        "java/util/Collection",
        "java/lang/Iterable",
        "java/util/PriorityQueue",
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
        "java/util/Iterator",
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
    kind(CollectionKind.Iterator, "kotlin/collections/Iterator", "kotlin/collections/MutableIterator", "java/util/Iterator")
}

/** Java platform types (`T!`) are flexible; their lower bound is the Kotlin type. */
val KaType.withoutFlexibility: KaType get() = (this as? KaFlexibleType)?.lowerBound ?: this

context(s: KaSession)
fun KaType.collectionKind(): CollectionKind? = with(s) { withoutFlexibility.expandedSymbol?.classId?.asString()?.let(KIND_BY_CLASS::get) }

context(s: KaSession)
val KaType.elementType: KaType? get() = (withoutFlexibility as? KaClassType)?.typeArguments?.firstOrNull()?.type

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

    luaName.startsWith("__K2L_Compare") || luaName.startsWith("__K2L_Then") || luaName.startsWith("__K2L_Nulls") ||
        luaName == "__K2L_ReverseComparator" ||
        luaName == "__K2L_NaturalOrder" || luaName == "__K2L_ReverseOrder" -> "Comparators"

    else -> "Collections"
}

/** Collection, string and pair functions of the Kotlin stdlib. */
@Suppress("TooManyFunctions") // one small mapper per receiver kind
object CollectionMappings {
    /** Iterable operations implemented as methods of the same name on the Lua collection classes. */
    private val ITERABLE_METHODS = setOf(
        "toList", "toMutableList", "toSet", "toMutableSet", "toHashSet", "isEmpty", "isNotEmpty", "contains", "containsAll",
        "indexOf", "lastIndexOf", "indexOfFirst", "indexOfLast", "elementAt", "getOrNull", "getOrElse", "firstOrNull", "find",
        "first", "lastOrNull", "findLast", "last", "single", "singleOrNull", "map", "mapIndexed", "mapNotNull", "flatMap",
        "flatten", "filter", "filterIndexed", "filterNot", "filterNotNull", "partition", "any", "all", "none", "count",
        "average", "maxOrNull", "minOrNull", "max", "min", "maxByOrNull", "minByOrNull", "maxBy", "minBy", "maxOf", "minOf",
        "maxOfOrNull", "minOfOrNull", "sorted", "sortedDescending", "sortedBy", "sortedByDescending", "sortedWith", "reversed",
        "distinct", "distinctBy", "take", "takeLast", "drop", "dropLast", "takeWhile", "dropWhile", "chunked", "withIndex",
        "zip", "fold", "reduce", "joinToString", "groupBy", "associate", "associateBy", "associateWith", "toMap", "forEach",
        "onEach", "intersect", "union", "subtract", "toTypedArray", "toIntArray", "toLongArray", "toDoubleArray",
        "toBooleanArray", "asSequence", "asIterable", "add", "addAll", "removeAt", "remove", "removeFirst", "removeLast",
        "removeAll", "removeIf", "retainAll", "clear", "sort", "sortDescending", "sortBy", "sortByDescending", "sortWith",
        "reverse", "fill", "subList", "contentEquals", "contentToString", "set", "toMutableMap", "hashCode",
        "windowed", "zipWithNext", "unzip", "foldRight", "reduceRight", "reduceOrNull", "foldIndexed", "reduceIndexed",
        "runningFold", "scan", "runningReduce", "maxWith", "minWith", "maxWithOrNull", "minWithOrNull", "takeLastWhile",
        "dropLastWhile", "mapIndexedNotNull", "flatMapIndexed", "mapTo", "filterTo", "toCollection", "associateByTo",
        "associateWithTo", "elementAtOrNull", "elementAtOrElse", "firstNotNullOfOrNull", "firstNotNullOf", "ifEmpty", "slice",
        "requireNoNulls", "asReversed", "asList", "binarySearch", "binarySearchBy", "sortedArray", "sortedArrayDescending",
        "reversedArray", "copyOfRange", "copyInto", "iterator", "addFirst", "addLast", "removeFirstOrNull", "removeLastOrNull",
        "replaceAll", "offer", "poll", "peek", "push", "pop", "offerFirst", "offerLast", "pollFirst", "pollLast", "peekFirst",
        "peekLast", "element", "groupingBy", "sliceArray", "contentDeepToString", "toSortedSet", "floor", "lower", "ceiling",
        "higher", "pollFirst", "pollLast", "headSet", "tailSet", "subSet", "descendingSet", "foldRightIndexed", "mapIndexedTo",
    )

    /** `Map` operations that are the `Iterable<Map.Entry>` ones, so they run over `entries`. */
    private val MAP_VIA_ENTRIES = setOf(
        "sumOf", "maxOf", "minOf", "maxOfOrNull", "minOfOrNull", "maxBy", "minBy", "maxWithOrNull", "minWithOrNull", "maxWith",
        "minWith", "firstNotNullOfOrNull", "firstNotNullOf", "sortedBy", "sortedByDescending", "sortedWith", "groupBy",
        "associate", "associateBy", "associateWith", "firstOrNull", "first", "toList", "flatMap", "mapNotNull", "mapIndexed",
        "fold", "single", "singleOrNull", "withIndex", "zip", "filterIsInstance",
    )

    private val MAP_METHODS = setOf(
        "get", "getOrDefault", "getOrElse", "getValue", "getOrPut", "containsKey", "containsValue", "put", "set", "putAll",
        "remove", "clear", "isEmpty", "isNotEmpty", "map", "mapNotNull", "flatMap", "any", "all", "none", "count", "filter",
        "filterKeys", "filterValues", "mapValues", "mapKeys", "toList", "toMap", "toMutableMap", "maxByOrNull", "minByOrNull",
        "forEach", "hashCode", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent", "replaceAll", "onEach",
        "filterNot", "mapValuesTo", "mapKeysTo", "orEmpty", "iterator", "asIterable", "toSortedMap", "firstKey", "lastKey",
        "firstEntry", "lastEntry", "floorKey", "lowerKey", "ceilingKey", "higherKey", "floorEntry", "lowerEntry", "ceilingEntry",
        "higherEntry", "pollFirstEntry", "pollLastEntry", "headMap", "tailMap", "subMap", "descendingMap", "descendingKeySet",
        "filterTo", "ifEmpty",
    )

    /** `Random` is passed explicitly to the lualib methods; calls without one use `Random.Default`. */
    private val RANDOM_METHODS = setOf("shuffled", "shuffle", "random", "randomOrNull")

    fun map(callableId: String?, site: CallSite): LuaExpr? = FactoryMappings.factory(callableId, site) ?: byReceiver(callableId, site)

    private fun byReceiver(callableId: String?, site: CallSite): LuaExpr? {
        val kind = site.receiverType?.let { with(site.session) { it.collectionKind() } } ?: return TextMappings.map(callableId, site)
        val name = site.name ?: return null
        return when (kind) {
            CollectionKind.List, CollectionKind.Array, CollectionKind.Set, CollectionKind.Iterable -> iterable(kind, name, site)

            CollectionKind.Map -> mapMember(name, site)

            CollectionKind.Range -> rangeMember(name, site)

            CollectionKind.ClosedRange -> closedRangeMember(name, site)

            CollectionKind.Entry, CollectionKind.Pair, CollectionKind.Triple, CollectionKind.IndexedValue -> tupleMember(kind, name, site)

            CollectionKind.LuaTable -> luaTableMember(name, site)

            CollectionKind.StringBuilder -> stringBuilderMember(name, site)

            CollectionKind.Sequence -> null

            // see SequenceMappings
            CollectionKind.Regex -> RegexMappings.regexMember(name, site)

            CollectionKind.Match -> RegexMappings.matchMember(name, site)

            CollectionKind.Iterator -> iteratorMember(name, site)

            CollectionKind.Grouping -> if (name in
                setOf("eachCount", "fold", "reduce", "aggregate")
            ) {
                LuaMethodCall(site.self, name, site.args)
            } else {
                null
            }
        }
    }

    private fun iteratorMember(name: String, site: CallSite): LuaExpr? =
        if (name in setOf("hasNext", "next", "remove")) LuaMethodCall(site.self, name, site.args) else null

    private fun rangeMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "first", "last", "step" ->
            if (site.args.isEmpty()) LuaIndex(site.self, LuaString(name)) else iterable(CollectionKind.Range, name, site)

        "start" -> LuaIndex(site.self, LuaString("first"))

        "endInclusive" -> LuaIndex(site.self, LuaString("last"))

        "contains" -> LuaMethodCall(site.self, "contains", site.args)

        "isEmpty" -> LuaMethodCall(site.self, "isEmpty", emptyList())

        else -> iterable(CollectionKind.Range, name, site)
    }

    private fun closedRangeMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "start" -> LuaIndex(site.self, LuaString("first"))
        "endInclusive" -> LuaIndex(site.self, LuaString("last"))
        "contains", "isEmpty" -> LuaMethodCall(site.self, name, site.args)
        else -> null
    }

    /** Entries, pairs, triples and indexed values are tables with named fields. */
    private fun tupleMember(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val fields = when (kind) {
            CollectionKind.Entry -> listOf("key", "value")
            CollectionKind.IndexedValue -> listOf("index", "value")
            CollectionKind.Pair -> listOf("first", "second")
            else -> listOf("first", "second", "third")
        }
        val component = name.removePrefix("component").toIntOrNull()
        return when {
            name in fields -> LuaIndex(site.self, LuaString(name))

            name.startsWith("component") && component != null && component in 1..fields.size ->
                LuaIndex(site.self, LuaString(fields[component - 1]))

            name == "toList" && (kind == CollectionKind.Pair || kind == CollectionKind.Triple) ->
                LuaCall(site.ref("Collections", "__K2L_ListOf"), fields.map { LuaIndex(site.self, LuaString(it)) })

            name == "toPair" && kind == CollectionKind.Entry ->
                LuaCall(LuaIndex(site.ref("Pair", "__K2L_Pair"), LuaString("new")), fields.map { LuaIndex(site.self, LuaString(it)) })

            name == "setValue" && kind == CollectionKind.Entry -> LuaMethodCall(site.self, "setValue", site.args)

            name in setOf("copy", "hashCode") && (kind == CollectionKind.Pair || kind == CollectionKind.Triple) ->
                LuaMethodCall(site.self, name, site.args)

            name == "equals" -> LuaCall(site.ref("Equals", "__K2L_Equals"), listOf(site.self, site.arg(0)))

            else -> null
        }
    }

    private fun luaTableMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "get" -> LuaIndex(site.self, site.arg(0))

        "set" -> {
            site.transformer.emit(LuaAssign(listOf(LuaIndex(site.self, site.arg(0))), listOf(site.args.getOrElse(1) { LuaNil })))
            LuaNil
        }

        "length" -> LuaUnary(LuaUnOp.Len, site.self)

        "has" -> LuaBinary(LuaBinOp.Ne, LuaIndex(site.self, site.arg(0)), LuaNil)

        "remove" -> {
            site.transformer.emit(LuaAssign(listOf(LuaIndex(site.self, site.arg(0))), listOf(LuaNil)))
            LuaNil
        }

        else -> null
    }

    private fun stringBuilderMember(name: String, site: CallSite): LuaExpr? {
        val self = site.self
        val args = site.args
        return when (name) {
            "append" -> if (args.size == APPEND_RANGE_ARITY) {
                LuaMethodCall(self, "append", listOf(substringOf(site, 0, 1, 2)))
            } else {
                LuaMethodCall(self, "append", listOf(site.str(site.arg(0), site.argTypes.getOrNull(0))))
            }

            "appendRange" -> LuaMethodCall(self, "append", listOf(substringOf(site, 0, 1, 2)))

            "appendLine" -> LuaMethodCall(self, "appendLine", args.take(1).map { site.str(it, site.argTypes[0]) })

            "length" -> LuaMethodCall(self, "getLength", emptyList())

            "lastIndex" -> LuaBinary(LuaBinOp.Sub, LuaMethodCall(self, "getLength", emptyList()), LuaNumber("1"))

            "insert" -> LuaMethodCall(self, "insert", listOf(args[0], site.str(args[1], site.argTypes.getOrNull(1))))

            "replace" -> LuaMethodCall(self, "replace", args)

            "clear", "reverse", "toString", "isEmpty", "isNotEmpty", "get", "set", "deleteCharAt", "delete", "setLength", "substring",
            "indexOf", "lastIndexOf",
            -> LuaMethodCall(self, name, args)

            "setCharAt" -> LuaMethodCall(self, "set", args)

            else -> null
        }
    }

    private fun substringOf(site: CallSite, text: Int, from: Int, to: Int): LuaExpr = LuaMethodCall(
        site.str(site.arg(text), site.argTypes.getOrNull(text)),
        "sub",
        listOf(LuaBinary(LuaBinOp.Add, site.arg(from), LuaNumber("1")), site.arg(to)),
    )

    private fun isCollection(site: CallSite, type: KaType?) = type != null && with(site.session) { type.collectionKind() } in setOf(
        CollectionKind.List,
        CollectionKind.Array,
        CollectionKind.Set,
        CollectionKind.Iterable,
        CollectionKind.Range,
        CollectionKind.Sequence,
    )

    private fun zeroFor(site: CallSite, type: KaType?): List<LuaExpr> = with(site.session) {
        if (type != null && (type.isDoubleType || type.isFloatType)) listOf(LuaNumber("0.0")) else emptyList()
    }

    /** The zero value of an array's element type, for `copyOf(newSize)`; null elements for object arrays. */
    private fun padFor(site: CallSite): LuaExpr = with(site.session) {
        val type = site.receiverType?.withoutFlexibility
        val classId = (type as? KaClassType)?.classId?.asString()
        when (classId) {
            "kotlin/DoubleArray", "kotlin/FloatArray" -> LuaNumber("0.0")
            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray" -> LuaNumber("0")
            "kotlin/BooleanArray" -> LuaBool(false)
            "kotlin/CharArray" -> LuaString("\u0000")
            else -> LuaNil
        }
    }

    private fun defaultRandom(site: CallSite): LuaExpr = site.libMember("Random", "__K2L_Random", "default")

    private fun iterable(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val self = site.self
        val component = name.removePrefix("component").toIntOrNull()
        return when {
            name in RANDOM_METHODS -> LuaMethodCall(self, name, listOf(site.args.firstOrNull() ?: defaultRandom(site)))
            component != null && name.startsWith("component") -> LuaMethodCall(self, "elementAt", listOf(LuaNumber("${component - 1}")))
            else -> iterableByName(kind, name, site)
        }
    }

    private fun iterableByName(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val self = site.self
        return when (name) {
            "size" -> if (kind == CollectionKind.Iterable) LuaMethodCall(self, "count", emptyList()) else LuaIndex(self, LuaString("size"))

            "get" -> when {
                site.isString(site.argTypes.getOrNull(0)) -> LuaMethodCall(self, "getNamed", site.args)

                // xs[i] is unchecked, xs.get(i) throws IndexOutOfBoundsException
                site.element is KtArrayAccessExpression || kind == CollectionKind.Iterable -> index(self, site.arg(0))

                else -> LuaMethodCall(self, "get", site.args)
            }

            "indices" -> LuaMethodCall(self, "getIndices", emptyList())

            "lastIndex" -> LuaBinary(LuaBinOp.Sub, LuaIndex(self, LuaString("size")), LuaNumber("1"))

            "add" -> if (site.args.size == 2) LuaMethodCall(self, "addAt", site.args) else LuaMethodCall(self, "add", site.args)

            "addAll" -> if (site.args.size == 2) LuaMethodCall(self, "addAllAt", site.args) else LuaMethodCall(self, "addAll", site.args)

            "sum" -> LuaMethodCall(self, "sum", zeroFor(site, with(site.session) { site.receiverType?.elementType }))

            "sumOf" -> LuaMethodCall(self, "sumOf", site.args + zeroFor(site, (site.argTypes.getOrNull(0) as? KaFunctionType)?.returnType))

            "plus", "minus" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) name + "All" else name, site.args)

            "plusAssign" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) "addAll" else "add", site.args)

            "minusAssign" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) "removeAll" else "remove", site.args)

            "plusElement" -> LuaMethodCall(self, "plus", site.args)

            "minusElement" -> LuaMethodCall(self, "minus", site.args)

            "copyOf" -> if (site.args.isEmpty()) {
                LuaMethodCall(self, "toTypedArray", emptyList())
            } else {
                LuaMethodCall(self, "copyOfSize", listOf(site.arg(0), padFor(site)))
            }

            "concatToString" -> LuaMethodCall(self, "joinToString", listOf(LuaString("")))

            "toString" -> null

            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaMethodCall(self, "isEmpty", emptyList()))

            "orEmpty" -> LuaBinary(LuaBinOp.Or, self, LuaCall(site.ref("Collections", "__K2L_ListOf"), emptyList()))

            else -> if (name in ITERABLE_METHODS) LuaMethodCall(self, name, site.args) else null
        }
    }

    private fun mapMember(name: String, site: CallSite): LuaExpr? {
        val self = site.self
        return when (name) {
            "size" -> LuaIndex(self, LuaString("size"))

            "keys" -> LuaMethodCall(self, "getKeys", emptyList())

            "values" -> LuaMethodCall(self, "getValues", emptyList())

            "entries" -> LuaMethodCall(self, "getEntries", emptyList())

            "contains" -> LuaMethodCall(self, "containsKey", site.args)

            "plusAssign" -> LuaMethodCall(self, if (isMapOrIterable(site)) "putAll" else "set", pairArguments(site))

            "plus" -> LuaMethodCall(self, "plus", site.args)

            "minus" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) "minusAll" else "minus", site.args)

            "minusAssign" -> if (isCollection(site, site.argTypes.getOrNull(0))) {
                LuaMethodCall(LuaMethodCall(self, "getKeys", emptyList()), "removeAll", site.args)
            } else {
                LuaMethodCall(self, "remove", site.args)
            }

            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaMethodCall(self, "isEmpty", emptyList()))

            else -> when {
                name in MAP_METHODS -> LuaMethodCall(self, name, site.args)

                name in MAP_VIA_ENTRIES -> iterable(
                    CollectionKind.List,
                    name,
                    site.withReceiver(LuaMethodCall(self, "getEntries", emptyList())),
                )

                else -> null
            }
        }
    }

    private fun isMapOrIterable(site: CallSite) = with(site.session) {
        site.argTypes.getOrNull(0)?.collectionKind() in
            setOf(CollectionKind.Map, CollectionKind.List, CollectionKind.Array, CollectionKind.Set)
    }

    /** `map += pair` is `set(first, second)`; `map += otherMap` and `map += listOfPairs` are `putAll`. */
    private fun pairArguments(site: CallSite): List<LuaExpr> =
        if (with(site.session) { site.argTypes.getOrNull(0)?.collectionKind() } == CollectionKind.Pair) {
            listOf(LuaIndex(site.arg(0), LuaString("first")), LuaIndex(site.arg(0), LuaString("second")))
        } else {
            site.args
        }

    /** `xs[i]` on a list or array: direct 1-based indexing (no bounds check, as in TSTL). */
    fun index(list: LuaExpr, index: LuaExpr): LuaExpr {
        // xs[xs.size - 1] is xs[xs.size] in Lua.
        if (index is LuaBinary && index.op == LuaBinOp.Sub && index.right == LuaNumber("1")) return LuaIndex(list, index.left)
        val n = (index as? LuaNumber)?.text?.toLongOrNull()
        return LuaIndex(list, if (n != null) LuaNumber((n + 1).toString()) else LuaBinary(LuaBinOp.Add, index, LuaNumber("1")))
    }
}
