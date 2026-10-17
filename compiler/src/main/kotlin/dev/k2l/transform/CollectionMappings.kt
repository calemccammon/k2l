package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

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
        "java/util/LinkedList",
        "kotlin/enums/EnumEntries",
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
    )
    kind(
        CollectionKind.Iterable,
        "kotlin/collections/Iterable",
        "kotlin/collections/MutableIterable",
        "kotlin/collections/Collection",
        "kotlin/collections/MutableCollection",
        "kotlin/sequences/Sequence",
        "java/util/Collection",
        "java/lang/Iterable",
    )
    kind(
        CollectionKind.Range,
        "kotlin/ranges/IntRange",
        "kotlin/ranges/IntProgression",
        "kotlin/ranges/LongRange",
        "kotlin/ranges/LongProgression",
    )
    put("kotlin/collections/Map.Entry", CollectionKind.Entry)
    put("kotlin/collections/MutableMap.MutableEntry", CollectionKind.Entry)
    put("java/util/Map.Entry", CollectionKind.Entry)
    put("kotlin/Pair", CollectionKind.Pair)
    put("kotlin/Triple", CollectionKind.Triple)
    put("kotlin/collections/IndexedValue", CollectionKind.IndexedValue)
    put("java/lang/StringBuilder", CollectionKind.StringBuilder)
    put("kotlin/text/StringBuilder", CollectionKind.StringBuilder)
    put("dev/k2l/lua/LuaTable", CollectionKind.LuaTable)
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
    CollectionKind.StringBuilder to "__K2L_StringBuilder",
)

fun featureOf(luaName: String) = when {
    luaName == "__K2L_Pair" || luaName == "__K2L_Triple" -> "Pair"

    luaName == "__K2L_StringBuilder" -> "Strings"

    luaName.startsWith("__K2L_Compare") || luaName.startsWith("__K2L_Then") || luaName == "__K2L_ReverseComparator" ||
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
    )

    private val MAP_METHODS = setOf(
        "get", "getOrDefault", "getOrElse", "getValue", "getOrPut", "containsKey", "containsValue", "put", "set", "putAll",
        "remove", "clear", "isEmpty", "isNotEmpty", "map", "mapNotNull", "flatMap", "any", "all", "none", "count", "filter",
        "filterKeys", "filterValues", "mapValues", "mapKeys", "toList", "toMap", "toMutableMap", "maxByOrNull", "minByOrNull",
        "forEach", "hashCode",
    )

    private val RANGE_METHODS = ITERABLE_METHODS + setOf("reversed")

    fun map(callableId: String?, site: CallSite): LuaExpr? = factory(callableId, site) ?: byReceiver(callableId, site)

    private fun byReceiver(callableId: String?, site: CallSite): LuaExpr? {
        val kind = site.receiverType?.let { with(site.session) { it.collectionKind() } } ?: return strings(callableId, site)
        val name = site.name ?: return null
        return when (kind) {
            CollectionKind.List, CollectionKind.Array, CollectionKind.Set, CollectionKind.Iterable -> iterable(kind, name, site)
            CollectionKind.Map -> mapMember(name, site)
            CollectionKind.Range -> rangeMember(name, site)
            CollectionKind.Entry, CollectionKind.Pair, CollectionKind.Triple, CollectionKind.IndexedValue -> tupleMember(kind, name, site)
            CollectionKind.LuaTable -> luaTableMember(name, site)
            CollectionKind.StringBuilder -> stringBuilderMember(name, site)
        }
    }

    private fun rangeMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "first", "last", "step" ->
            if (site.args.isEmpty()) LuaIndex(site.self, LuaString(name)) else iterable(CollectionKind.Range, name, site)

        "contains" -> LuaMethodCall(site.self, "contains", site.args)

        else -> if (name in RANGE_METHODS) iterable(CollectionKind.Range, name, site) else null
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

    private fun stringBuilderMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "append" -> LuaMethodCall(site.self, "append", listOf(site.str(site.arg(0), site.argTypes.getOrNull(0))))
        "appendLine" -> LuaMethodCall(site.self, "appendLine", site.args.take(1).map { site.str(it, site.argTypes[0]) })
        "length" -> LuaMethodCall(site.self, "getLength", emptyList())
        "clear", "reverse", "toString" -> LuaMethodCall(site.self, name, emptyList())
        else -> null
    }

    private fun factory(callableId: String?, site: CallSite): LuaExpr? {
        fun call(name: String, vararg args: LuaExpr) = LuaCall(site.ref(featureOf(name), name), args.toList())
        val args = site.args.toTypedArray()
        return when (callableId) {
            "kotlin/collections/listOf", "kotlin/collections/mutableListOf", "kotlin/collections/arrayListOf",
            "kotlin/collections/emptyList",
            -> call("__K2L_ListOf", *args)

            "kotlin/collections/listOfNotNull" -> LuaMethodCall(call("__K2L_ListOf", *args), "filterNotNull", emptyList())

            "kotlin/arrayOf", "kotlin/intArrayOf", "kotlin/longArrayOf", "kotlin/doubleArrayOf", "kotlin/floatArrayOf",
            "kotlin/booleanArrayOf", "kotlin/charArrayOf", "kotlin/shortArrayOf", "kotlin/byteArrayOf", "kotlin/emptyArray",
            ->
                call("__K2L_ArrayOf", *args)

            "kotlin/arrayOfNulls" -> call("__K2L_ListOfSize", site.arg(0), LuaNil, LuaBool(true))

            "kotlin/collections/setOf", "kotlin/collections/mutableSetOf", "kotlin/collections/hashSetOf",
            "kotlin/collections/linkedSetOf", "kotlin/collections/emptySet",
            -> call("__K2L_SetOf", *args)

            "kotlin/collections/mapOf", "kotlin/collections/mutableMapOf", "kotlin/collections/hashMapOf",
            "kotlin/collections/linkedMapOf", "kotlin/collections/emptyMap",
            -> call("__K2L_MapOf", *args)

            "kotlin/to" -> LuaCall(LuaIndex(site.ref("Pair", "__K2L_Pair"), LuaString("new")), listOf(site.self, site.arg(0)))

            "kotlin/collections/List", "kotlin/collections/MutableList" -> call("__K2L_ListOfSize", site.arg(0), site.arg(1))

            "kotlin/comparisons/compareBy" -> call("__K2L_CompareBy", *args)

            "kotlin/comparisons/compareByDescending" -> call("__K2L_CompareByDescending", *args)

            "kotlin/comparisons/thenBy" -> call("__K2L_ThenBy", site.self, site.arg(0))

            "kotlin/comparisons/thenByDescending" -> call("__K2L_ThenByDescending", site.self, site.arg(0))

            "kotlin/comparisons/reversed", "java/util/Comparator.reversed" -> call("__K2L_ReverseComparator", site.self)

            "kotlin/comparisons/naturalOrder" -> site.ref("Comparators", "__K2L_NaturalOrder")

            "kotlin/comparisons/reverseOrder" -> site.ref("Comparators", "__K2L_ReverseOrder")

            "kotlin/Int.rangeTo", "kotlin/Long.rangeTo" -> newRange(site, site.self, site.arg(0))

            "kotlin/Int.rangeUntil", "kotlin/ranges/until" -> newRange(
                site,
                site.self,
                LuaBinary(LuaBinOp.Sub, site.arg(0), LuaNumber("1")),
            )

            "kotlin/ranges/downTo" -> newRange(site, site.self, site.arg(0), LuaNumber("-1"))

            "kotlin/ranges/step" -> LuaMethodCall(site.self, "withStep", site.args)

            else -> null
        }
    }

    private fun newRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null) =
        LuaCall(LuaIndex(site.ref("Collections", "__K2L_IntRange"), LuaString("new")), listOfNotNull(first, last, step))

    /** Constructor of a library class, or null. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        fun new(luaClass: String, vararg args: LuaExpr) =
            LuaCall(LuaIndex(site.ref(featureOf(luaClass), luaClass), LuaString("new")), args.toList())
        val first = site.argTypes.firstOrNull()
        return when (classId) {
            "kotlin/Pair" -> new("__K2L_Pair", *site.args.toTypedArray())

            "kotlin/Triple" -> new("__K2L_Triple", *site.args.toTypedArray())

            "java/util/ArrayList", "kotlin/collections/ArrayList", "java/util/LinkedList" ->
                if (first != null &&
                    with(site.session) { first.collectionKind() } != null
                ) {
                    LuaMethodCall(site.arg(0), "toMutableList", emptyList())
                } else {
                    new("__K2L_List")
                }

            "java/util/HashSet", "java/util/LinkedHashSet", "kotlin/collections/HashSet", "kotlin/collections/LinkedHashSet" ->
                if (first != null && with(site.session) { first.collectionKind() } != null) {
                    LuaMethodCall(site.arg(0), "toSet", emptyList())
                } else {
                    new("__K2L_Set")
                }

            "java/util/HashMap", "java/util/LinkedHashMap", "kotlin/collections/HashMap", "kotlin/collections/LinkedHashMap" ->
                if (first != null &&
                    with(site.session) { first.collectionKind() } == CollectionKind.Map
                ) {
                    LuaMethodCall(site.arg(0), "toMap", emptyList())
                } else {
                    new("__K2L_Map")
                }

            "java/lang/StringBuilder", "kotlin/text/StringBuilder" ->
                new("__K2L_StringBuilder", *site.args.take(1).map { site.str(it, first) }.toTypedArray())

            "kotlin/ranges/IntRange" -> new("__K2L_IntRange", site.arg(0), site.arg(1))

            "dev/k2l/lua/LuaTable" -> LuaTable(emptyList())

            "kotlin/Char" -> LuaCall(LuaIndex(LuaName("string"), LuaString("char")), listOf(site.arg(0)))

            "kotlin/Array" -> LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.arg(1), LuaBool(true)))

            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray", "kotlin/DoubleArray",
            "kotlin/FloatArray", "kotlin/BooleanArray", "kotlin/CharArray",
            -> {
                val zero = when (classId) {
                    "kotlin/DoubleArray", "kotlin/FloatArray" -> LuaNumber("0.0")
                    "kotlin/BooleanArray" -> LuaBool(false)
                    "kotlin/CharArray" -> LuaString("\u0000")
                    else -> LuaNumber("0")
                }
                LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.args.getOrNull(1) ?: zero, LuaBool(true)))
            }

            else -> null
        }
    }

    private fun isCollection(site: CallSite, type: KaType?) = type != null && with(site.session) { type.collectionKind() } in setOf(
        CollectionKind.List,
        CollectionKind.Array,
        CollectionKind.Set,
        CollectionKind.Iterable,
        CollectionKind.Range,
    )

    private fun zeroFor(site: CallSite, type: KaType?): List<LuaExpr> = with(site.session) {
        if (type != null && (type.isDoubleType || type.isFloatType)) listOf(LuaNumber("0.0")) else emptyList()
    }

    private fun iterable(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val self = site.self
        return when (name) {
            "size" -> if (kind == CollectionKind.Iterable) LuaMethodCall(self, "count", emptyList()) else LuaIndex(self, LuaString("size"))
            "get" -> index(self, site.arg(0))
            "indices" -> LuaMethodCall(self, "getIndices", emptyList())
            "lastIndex" -> LuaBinary(LuaBinOp.Sub, LuaIndex(self, LuaString("size")), LuaNumber("1"))
            "add" -> if (site.args.size == 2) LuaMethodCall(self, "addAt", site.args) else LuaMethodCall(self, "add", site.args)
            "sum" -> LuaMethodCall(self, "sum", zeroFor(site, with(site.session) { site.receiverType?.elementType }))
            "sumOf" -> LuaMethodCall(self, "sumOf", site.args + zeroFor(site, (site.argTypes.getOrNull(0) as? KaFunctionType)?.returnType))
            "plus", "minus" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) name + "All" else name, site.args)
            "plusAssign" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) "addAll" else "add", site.args)
            "minusAssign" -> LuaMethodCall(self, if (isCollection(site, site.argTypes.getOrNull(0))) "removeAll" else "remove", site.args)
            "plusElement" -> LuaMethodCall(self, "plus", site.args)
            "minusElement" -> LuaMethodCall(self, "minus", site.args)
            "copyOf" -> if (site.args.isEmpty()) LuaMethodCall(self, "toTypedArray", emptyList()) else null
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

            "plusAssign" -> LuaMethodCall(
                self,
                if (with(site.session) { site.argTypes.getOrNull(0)?.collectionKind() } ==
                    CollectionKind.Map
                ) {
                    "putAll"
                } else {
                    "set"
                },
                if (with(site.session) { site.argTypes.getOrNull(0)?.collectionKind() } ==
                    CollectionKind.Pair
                ) {
                    listOf(LuaIndex(site.arg(0), LuaString("first")), LuaIndex(site.arg(0), LuaString("second")))
                } else {
                    site.args
                },
            )

            "plus" -> LuaMethodCall(self, "plus", site.args)

            "minus" -> LuaMethodCall(self, "minus", site.args)

            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaMethodCall(self, "isEmpty", emptyList()))

            else -> if (name in MAP_METHODS) LuaMethodCall(self, name, site.args) else null
        }
    }

    /** `xs[i]` on a list or array: direct 1-based indexing (no bounds check, as in TSTL). */
    fun index(list: LuaExpr, index: LuaExpr): LuaExpr {
        // xs[xs.size - 1] is xs[xs.size] in Lua.
        if (index is LuaBinary && index.op == LuaBinOp.Sub && index.right == LuaNumber("1")) return LuaIndex(list, index.left)
        val n = (index as? LuaNumber)?.text?.toLongOrNull()
        return LuaIndex(list, if (n != null) LuaNumber((n + 1).toString()) else LuaBinary(LuaBinOp.Add, index, LuaNumber("1")))
    }

    // ---- strings and chars ----

    private fun strings(callableId: String?, site: CallSite): LuaExpr? {
        val receiverType = site.receiverType ?: return null
        val session = site.session
        val isString = with(session) { receiverType.isStringType || receiverType.isCharSequenceType }
        val isChar = with(session) { receiverType.isCharType }
        val name = site.name ?: return null
        if (isChar) return chars(name, site)
        if (!isString || callableId?.startsWith("kotlin/") != true) return null
        val call = StringCall(site)
        return stringIndexing(name, call) ?: stringSearch(name, call) ?: stringNullAndBlank(name, call) ?: stringConversion(name, call)
    }

    private class StringCall(val site: CallSite) {
        val self = site.self

        fun helper(fn: String, vararg args: LuaExpr) = LuaCall(site.ref("Strings", "__K2L_String$fn"), listOf(self) + args)

        fun ignoreCase(i: Int) = site.args.getOrNull(i)?.let { it != LuaBool(false) } == true

        /** [helper] when the call has no arguments, else null (the overload isn't mapped). */
        fun noArgs(fn: String) = if (site.args.isEmpty()) helper(fn) else null
    }

    private fun stringIndexing(name: String, c: StringCall): LuaExpr? = when (name) {
        "get" -> {
            val i = c.site.arg(0)
            val n = (i as? LuaNumber)?.text?.toLongOrNull()
            if (n != null) {
                LuaMethodCall(c.self, "sub", listOf(LuaNumber("${n + 1}"), LuaNumber("${n + 1}")))
            } else {
                LuaMethodCall(
                    c.self,
                    "sub",
                    listOf(LuaBinary(LuaBinOp.Add, i, LuaNumber("1")), LuaBinary(LuaBinOp.Add, i, LuaNumber("1"))),
                )
            }
        }

        "substring" -> {
            val start = c.site.arg(0)
            val from =
                (start as? LuaNumber)?.text?.toLongOrNull()?.let { LuaNumber("${it + 1}") }
                    ?: LuaBinary(LuaBinOp.Add, start, LuaNumber("1"))
            LuaMethodCall(c.self, "sub", listOfNotNull(from, c.site.args.getOrNull(1)))
        }

        "first" -> if (c.site.args.isEmpty()) LuaMethodCall(c.self, "sub", listOf(LuaNumber("1"), LuaNumber("1"))) else null

        "last" -> if (c.site.args.isEmpty()) LuaMethodCall(c.self, "sub", listOf(LuaNumber("-1"))) else null

        "reversed" -> LuaMethodCall(c.self, "reverse", emptyList())

        else -> null
    }

    private fun stringSearch(name: String, c: StringCall): LuaExpr? {
        val site = c.site
        return when (name) {
            "startsWith" -> if (c.ignoreCase(1)) null else c.helper("StartsWith", site.arg(0))
            "endsWith" -> if (c.ignoreCase(1)) null else c.helper("EndsWith", site.arg(0))
            "contains" -> if (c.ignoreCase(1)) null else c.helper("Contains", site.arg(0))
            "indexOf" -> c.helper("IndexOf", *site.args.take(2).toTypedArray())
            "lastIndexOf" -> c.helper("LastIndexOf", site.arg(0))
            "replace" -> if (c.ignoreCase(2)) null else c.helper("Replace", site.arg(0), site.arg(1))
            "split" -> if (site.args.size == 1) c.helper("Split", site.arg(0)) else null
            "equals" -> if (c.ignoreCase(1)) c.helper("EqualsIgnoreCase", site.arg(0)) else LuaBinary(LuaBinOp.Eq, c.self, site.arg(0))
            "compareTo" -> LuaCall(site.ref("Compare", "__K2L_Compare"), listOf(c.self, site.arg(0)))
            "format" -> LuaCall(site.ref("Strings", "__K2L_StringFormat"), listOf(c.self) + site.args)
            else -> null
        }
    }

    private fun stringNullAndBlank(name: String, c: StringCall): LuaExpr? {
        val self = c.self
        return when (name) {
            "lines" -> c.helper("Lines")
            "trim" -> c.noArgs("Trim")
            "trimStart" -> c.noArgs("TrimStart")
            "trimEnd" -> c.noArgs("TrimEnd")
            "isBlank" -> c.helper("IsBlank")
            "isNotBlank" -> LuaUnary(LuaUnOp.Not, c.helper("IsBlank"))
            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaBinary(LuaBinOp.Eq, self, LuaString("")))
            "isNullOrBlank" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), c.helper("IsBlank"))
            "orEmpty" -> LuaBinary(LuaBinOp.Or, self, LuaString(""))
            "padStart" -> c.helper("PadStart", *c.site.args.toTypedArray())
            "padEnd" -> c.helper("PadEnd", *c.site.args.toTypedArray())
            else -> null
        }
    }

    private fun stringConversion(name: String, c: StringCall): LuaExpr? = when (name) {
        "toInt", "toLong" -> c.noArgs("ToInt")
        "toIntOrNull", "toLongOrNull" -> c.noArgs("ToIntOrNull")
        "toDouble" -> c.helper("ToDouble")
        "toDoubleOrNull" -> c.helper("ToDoubleOrNull")
        "toList" -> c.helper("ToList")
        "count" -> if (c.site.args.isEmpty()) LuaUnary(LuaUnOp.Len, c.self) else null
        else -> null
    }

    private fun chars(name: String, site: CallSite): LuaExpr? {
        val c = site.self
        fun matches(pattern: String) = LuaBinary(LuaBinOp.Ne, LuaMethodCall(c, "match", listOf(LuaString(pattern))), LuaNil)
        return when (name) {
            "code" -> LuaMethodCall(c, "byte", emptyList())
            "isDigit" -> matches("^%d$")
            "isLetter" -> matches("^%a$")
            "isLetterOrDigit" -> matches("^%w$")
            "isWhitespace" -> matches("^%s$")
            "isUpperCase" -> matches("^%u$")
            "isLowerCase" -> matches("^%l$")
            "uppercaseChar", "uppercase" -> LuaMethodCall(c, "upper", emptyList())
            "lowercaseChar", "lowercase" -> LuaMethodCall(c, "lower", emptyList())
            "digitToInt" -> LuaCall(LuaName("tonumber"), listOf(c))
            "toString" -> c
            else -> null
        }
    }
}
