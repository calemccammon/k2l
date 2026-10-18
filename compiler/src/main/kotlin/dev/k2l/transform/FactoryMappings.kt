package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType

/** Functions that create collections, ranges, comparators and pairs, and constructors of library classes. */
@Suppress("TooManyFunctions") // one small mapper per kind of factory
internal object FactoryMappings {
    fun factory(callableId: String?, site: CallSite): LuaExpr? {
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

            "kotlin/collections/setOf", "kotlin/collections/mutableSetOf", "kotlin/collections/linkedSetOf",
            "kotlin/collections/emptySet",
            -> call("__K2L_SetOf", *args)

            "kotlin/collections/mapOf", "kotlin/collections/mutableMapOf", "kotlin/collections/linkedMapOf",
            "kotlin/collections/emptyMap",
            -> call("__K2L_MapOf", *args)

            "kotlin/collections/hashSetOf" -> call("__K2L_HashSetOf", *args)

            "kotlin/collections/hashMapOf" -> call("__K2L_HashMapOf", *args)

            "kotlin/collections/sortedMapOf" -> call("__K2L_SortedMapOf", *args)

            "kotlin/collections/sortedSetOf" -> call("__K2L_SortedSetOf", *args)

            "kotlin/to" -> LuaCall(LuaIndex(site.ref("Pair", "__K2L_Pair"), LuaString("new")), listOf(site.self, site.arg(0)))

            "kotlin/collections/List", "kotlin/collections/MutableList" -> call("__K2L_ListOfSize", site.arg(0), site.arg(1))

            else -> comparators(callableId, site) ?: ranges(callableId, site) ?: misc(callableId, site)
        }
    }

    private fun comparators(callableId: String?, site: CallSite): LuaExpr? {
        fun call(name: String, vararg args: LuaExpr) = LuaCall(site.ref(featureOf(name), name), args.toList())
        val args = site.args.toTypedArray()
        return when (callableId) {
            "kotlin/comparisons/compareBy" ->
                // compareBy(comparator, selector) compares the selected values with the comparator
                if (args.size == 2 && (site.argTypes[0] as? KaFunctionType)?.parameterTypes?.size != 1) {
                    call("__K2L_CompareByWith", args[0], args[1])
                } else {
                    call("__K2L_CompareBy", *args)
                }

            "kotlin/comparisons/compareByDescending" -> call("__K2L_CompareByDescending", *args)

            "kotlin/comparisons/thenBy" -> call("__K2L_ThenBy", site.self, site.arg(0))

            "kotlin/comparisons/thenByDescending" -> call("__K2L_ThenByDescending", site.self, site.arg(0))

            "kotlin/comparisons/then", "kotlin/comparisons/thenComparator" -> call("__K2L_Then", site.self, site.arg(0))

            "kotlin/comparisons/thenDescending" -> call("__K2L_Then", site.self, call("__K2L_ReverseComparator", site.arg(0)))

            "kotlin/comparisons/reversed", "java/util/Comparator.reversed" -> call("__K2L_ReverseComparator", site.self)

            "kotlin/comparisons/naturalOrder", "java/util/Comparator.naturalOrder" -> site.ref("Comparators", "__K2L_NaturalOrder")

            "kotlin/comparisons/reverseOrder", "java/util/Comparator.reverseOrder" -> site.ref("Comparators", "__K2L_ReverseOrder")

            "kotlin/comparisons/nullsFirst" -> call(
                "__K2L_NullsFirst",
                site.args.firstOrNull() ?: site.ref("Comparators", "__K2L_NaturalOrder"),
            )

            "kotlin/comparisons/nullsLast" -> call(
                "__K2L_NullsLast",
                site.args.firstOrNull() ?: site.ref("Comparators", "__K2L_NaturalOrder"),
            )

            "kotlin/Comparator" -> site.arg(0)

            "kotlin/comparisons/compareValues" -> LuaCall(site.ref("Compare", "__K2L_Compare"), listOf(site.arg(0), site.arg(1)))

            "kotlin/comparisons/compareValuesBy" ->
                LuaCall(call("__K2L_CompareBy", *args.drop(2).toTypedArray()), listOf(site.arg(0), site.arg(1)))

            "java/util/Comparator.comparing" -> call("__K2L_CompareBy", site.arg(0))

            "java/util/Comparator.thenComparing" ->
                if ((site.argTypes.getOrNull(0) as? KaFunctionType)?.parameterTypes?.size == 1) {
                    call("__K2L_ThenBy", site.self, site.arg(0))
                } else {
                    call("__K2L_Then", site.self, site.arg(0))
                }

            else -> null
        }
    }

    private fun ranges(callableId: String?, site: CallSite): LuaExpr? {
        val charOperands = site.isChar(site.receiverType ?: site.argTypes.firstOrNull())
        return when (callableId) {
            "kotlin/Int.rangeTo", "kotlin/Long.rangeTo" -> newRange(site, site.self, site.arg(0))

            "kotlin/Char.rangeTo" -> newCharRange(site, site.self, site.arg(0))

            "kotlin/ranges/rangeTo" -> LuaCall(
                LuaIndex(site.ref("Collections", "__K2L_ClosedRange"), LuaString("new")),
                listOf(site.self, site.arg(0)),
            )

            "kotlin/Int.rangeUntil", "kotlin/ranges/until" ->
                if (charOperands) {
                    newCharRange(site, site.self, LuaCall(luaPath("string", "char"), listOf(charCodeMinusOne(site.arg(0)))))
                } else {
                    newRange(site, site.self, LuaBinary(LuaBinOp.Sub, site.arg(0), LuaNumber("1")))
                }

            "kotlin/ranges/downTo" ->
                if (charOperands) {
                    newCharRange(
                        site,
                        site.self,
                        site.arg(0),
                        LuaNumber("-1"),
                    )
                } else {
                    newRange(site, site.self, site.arg(0), LuaNumber("-1"))
                }

            "kotlin/ranges/step" -> LuaMethodCall(site.self, "withStep", site.args)

            else -> null
        }
    }

    private fun charCodeMinusOne(c: LuaExpr): LuaExpr = LuaBinary(LuaBinOp.Sub, LuaMethodCall(c, "byte", emptyList()), LuaNumber("1"))

    private fun misc(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
        "java/util/Objects.equals" -> LuaCall(site.ref("Equals", "__K2L_Equals"), listOf(site.arg(0), site.arg(1)))

        "java/util/Objects.hashCode" -> LuaCall(site.ref("Hash", "__K2L_Hash"), listOf(site.arg(0)))

        "java/util/Objects.hash" ->
            LuaMethodCall(LuaCall(site.ref("Collections", "__K2L_ListOf"), site.args), "hashCode", emptyList())

        else -> null
    }

    private fun newRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null) =
        LuaCall(LuaIndex(site.ref("Collections", "__K2L_IntRange"), LuaString("new")), listOfNotNull(first, last, step))

    private fun newCharRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null) =
        LuaCall(LuaIndex(site.ref("Collections", "__K2L_CharRange"), LuaString("new")), listOfNotNull(first, last, step))

    /** Constructor of a library class, or null. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        fun new(luaClass: String, vararg args: LuaExpr) =
            LuaCall(LuaIndex(site.ref(featureOf(luaClass), luaClass), LuaString("new")), args.toList())
        val first = site.argTypes.firstOrNull()
        val firstIsCollection = first != null && with(site.session) { first.collectionKind() } != null
        return when (classId) {
            "kotlin/Pair" -> new("__K2L_Pair", *site.args.toTypedArray())

            "kotlin/Triple" -> new("__K2L_Triple", *site.args.toTypedArray())

            "java/util/ArrayList", "kotlin/collections/ArrayList", "java/util/LinkedList", "kotlin/collections/ArrayDeque",
            "java/util/ArrayDeque",
            ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toMutableList", emptyList()) else new("__K2L_List")

            "java/util/HashSet", "kotlin/collections/HashSet" -> new("__K2L_HashSet", *site.args.take(1).toTypedArray())

            "java/util/HashMap", "kotlin/collections/HashMap" -> new("__K2L_HashMap", *site.args.take(1).toTypedArray())

            "java/util/LinkedHashSet", "kotlin/collections/LinkedHashSet" ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toSet", emptyList()) else new("__K2L_Set")

            "java/util/LinkedHashMap", "kotlin/collections/LinkedHashMap" ->
                if (first != null && with(site.session) { first.collectionKind() } == CollectionKind.Map) {
                    LuaMethodCall(site.arg(0), "toMap", emptyList())
                } else {
                    new("__K2L_Map")
                }

            "java/util/PriorityQueue" -> newPriorityQueue(site)

            "java/util/TreeMap" -> new("__K2L_SortedMap", *site.args.take(1).toTypedArray())

            "java/util/TreeSet" -> new("__K2L_SortedSet", *site.args.take(1).toTypedArray())

            "java/lang/StringBuilder", "kotlin/text/StringBuilder", "java/lang/StringBuffer" ->
                new("__K2L_StringBuilder", *site.args.take(1).map { site.str(it, first) }.toTypedArray())

            "kotlin/text/Regex" -> new("__K2L_Regex", *site.args.toTypedArray())

            "kotlin/ranges/IntRange" -> new("__K2L_IntRange", site.arg(0), site.arg(1))

            "dev/k2l/lua/LuaTable" -> LuaTable(emptyList())

            "kotlin/Char" -> LuaCall(LuaIndex(LuaName("string"), LuaString("char")), listOf(site.arg(0)))

            "kotlin/Array" -> LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.arg(1), LuaBool(true)))

            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray", "kotlin/DoubleArray",
            "kotlin/FloatArray", "kotlin/BooleanArray", "kotlin/CharArray",
            -> primitiveArray(classId, site)

            else -> null
        }
    }

    /** `PriorityQueue()`, `(capacity)`, `(comparator)`, `(capacity, comparator)` and `(collection)`. */
    private fun newPriorityQueue(site: CallSite): LuaExpr {
        val index = site.argTypes.indexOfFirst { it != null && !site.isIntegral(it) }
        val args = if (index >= 0) listOf(site.arg(index)) else emptyList()
        return LuaCall(LuaIndex(site.ref("Collections", "__K2L_PriorityQueue"), LuaString("new")), args)
    }

    private fun primitiveArray(classId: String, site: CallSite): LuaExpr {
        val zero = when (classId) {
            "kotlin/DoubleArray", "kotlin/FloatArray" -> LuaNumber("0.0")
            "kotlin/BooleanArray" -> LuaBool(false)
            "kotlin/CharArray" -> LuaString("\u0000")
            else -> LuaNumber("0")
        }
        return LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.args.getOrNull(1) ?: zero, LuaBool(true)))
    }
}
