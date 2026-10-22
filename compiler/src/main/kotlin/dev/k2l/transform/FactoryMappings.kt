package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtQualifiedExpression

/** `LinkedHashMap(initialCapacity, loadFactor, accessOrder)` */
internal const val LINKED_MAP_ACCESS_ORDER_ARITY = 3

/** Functions that create collections, ranges, comparators and pairs (the constructors are in [CoreConstructors]). */
internal object FactoryMappings {
    fun factory(callableId: String?, site: CallSite): LuaExpr? {
        fun call(name: String, vararg args: LuaExpr) = LuaCall(site.ref(featureOf(name), name), args.toList())
        val args = site.args.toTypedArray()
        return when (callableId) {
            // read-only collections are mutable ones at run time
            "kotlin/collections/listOf", "kotlin/collections/emptyList", "kotlin/collections/mutableListOf",
            "kotlin/collections/arrayListOf",
            -> call("__K2L_ListOf", *args)

            "kotlin/collections/listOfNotNull" -> LuaMethodCall(call("__K2L_ListOf", *args), "filterNotNull", emptyList())

            "kotlin/arrayOf", "kotlin/intArrayOf", "kotlin/longArrayOf", "kotlin/doubleArrayOf", "kotlin/floatArrayOf",
            "kotlin/booleanArrayOf", "kotlin/charArrayOf", "kotlin/shortArrayOf", "kotlin/byteArrayOf", "kotlin/emptyArray",
            -> call("__K2L_ArrayOf", *args)

            "kotlin/arrayOfNulls" -> call("__K2L_ListOfSize", site.arg(0), LuaNil, LuaBool(true))

            // a HashSet or HashMap keeps insertion order, as a LinkedHashSet or LinkedHashMap
            "kotlin/collections/setOf", "kotlin/collections/emptySet", "kotlin/collections/mutableSetOf",
            "kotlin/collections/linkedSetOf", "kotlin/collections/hashSetOf",
            -> call("__K2L_SetOf", *args)

            "kotlin/collections/mapOf", "kotlin/collections/emptyMap", "kotlin/collections/mutableMapOf",
            "kotlin/collections/linkedMapOf", "kotlin/collections/hashMapOf",
            -> call("__K2L_MapOf", *args)

            // sortedMapOf(pairs) and sortedMapOf(comparator, pairs): the comparator first, nil for the natural order
            "kotlin/collections/sortedMapOf", "kotlin/collections/sortedSetOf" -> {
                val name = if (callableId.endsWith("MapOf")) "__K2L_SortedMapOf" else "__K2L_SortedSetOf"
                val first = with(site.session) { site.parameterTypes.firstOrNull()?.expandedSymbol?.classId?.asString() }
                val comparator = first == "java/util/Comparator"
                if (comparator) call(name, *args) else call(name, LuaNil, *args)
            }

            "kotlin/to" -> site.libNew(PAIR_TABLE, listOf(site.self, site.arg(0)))

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
                    site.fusedComparator(false, null) ?: call("__K2L_CompareBy", *args)
                }

            "kotlin/comparisons/compareByDescending" -> site.fusedComparator(true, null) ?: call("__K2L_CompareByDescending", *args)

            "kotlin/comparisons/thenBy" -> site.thenBy(false) ?: call("__K2L_ThenBy", site.self, site.arg(0))

            "kotlin/comparisons/thenByDescending" -> site.thenBy(true) ?: call("__K2L_ThenByDescending", site.self, site.arg(0))

            "kotlin/comparisons/then", "kotlin/comparisons/thenComparator" -> call("__K2L_Then", site.self, site.arg(0))

            "kotlin/comparisons/thenDescending" -> call("__K2L_Then", site.self, call("__K2L_ReverseComparator", site.arg(0)))

            "kotlin/comparisons/reversed", "java/util/Comparator.reversed" -> call("__K2L_ReverseComparator", site.self)

            "kotlin/comparisons/naturalOrder" -> site.ref("Comparators", "__K2L_NaturalOrder")

            "kotlin/comparisons/reverseOrder" -> site.ref("Comparators", "__K2L_ReverseOrder")

            "kotlin/comparisons/nullsFirst" -> call(
                "__K2L_NullsFirst",
                site.args.firstOrNull() ?: site.ref("Comparators", "__K2L_NaturalOrder"),
            )

            "kotlin/comparisons/nullsLast" -> call(
                "__K2L_NullsLast",
                site.args.firstOrNull() ?: site.ref("Comparators", "__K2L_NaturalOrder"),
            )

            // SAM constructors: values of library SAM interfaces are Lua callables (see SamInterfaces.lua)
            "kotlin/Comparator", "java/util/Comparator", "java/lang/Runnable", "java/util/concurrent/Callable" -> site.arg(0)

            "java/util/Comparator.compare", "java/lang/Runnable.run", "java/util/concurrent/Callable.call" -> LuaCall(site.self, site.args)

            // `f(x)` on an object of a class implementing a function type by delegation: the object is callable
            in FUNCTION_INVOKES -> LuaCall(site.self, site.args)

            "kotlin/comparisons/compareValues" -> LuaCall(site.ref("Compare", "__K2L_CompareValues"), listOf(site.arg(0), site.arg(1)))

            "kotlin/comparisons/compareValuesBy" ->
                LuaCall(call("__K2L_CompareBy", *args.drop(2).toTypedArray()), listOf(site.arg(0), site.arg(1)))

            else -> null
        }
    }

    private fun ranges(callableId: String?, site: CallSite): LuaExpr? {
        val charOperands = site.isChar(site.receiverType ?: site.argTypes.firstOrNull())
        return when (callableId) {
            "kotlin/Int.rangeTo", "kotlin/Long.rangeTo" -> newRange(site, site.self, site.arg(0))

            "kotlin/Char.rangeTo" -> newCharRange(site, site.self, site.arg(0))

            "kotlin/ranges/rangeTo" -> site.libNew(
                "Collections",
                "__K2L_ClosedRange",
                listOf(site.self, site.arg(0)),
            )

            "kotlin/Int.rangeUntil", "kotlin/ranges/until" ->
                if (charOperands) {
                    newCharRange(site, site.self, charFromCode(charCodeMinusOne(site.arg(0))))
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
        // the stdlib's empty ranges are 1..0 (and '\u0001'..'\u0000')
        "kotlin/ranges/IntRange.Companion.EMPTY" -> newRange(site, LuaNumber("1"), LuaNumber("0"))

        "kotlin/ranges/LongRange.Companion.EMPTY" -> newRange(site, LuaNumber("1"), LuaNumber("0"))

        "kotlin/ranges/CharRange.Companion.EMPTY" ->
            newCharRange(site, charFromCode(LuaNumber("1")), charFromCode(LuaNumber("0")))

        else -> null
    }

    private fun newRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null) =
        site.libNew(INT_RANGE_TABLE, listOfNotNull(first, last, step))

    private fun newCharRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null): LuaExpr {
        val range = luaField(site.ref("Collections", "__K2L_CharRange"), "new")
        return LuaCall(range, listOfNotNull(first, last, step))
    }
}

/** `kotlin.Function0.invoke` ... `kotlin.Function22.invoke`. */
private val FUNCTION_INVOKES = (0..22).map { "kotlin/Function$it.invoke" }.toSet()

/** Constructors of library classes: pairs, collections, text builders, regexes, ranges, chars and arrays (see LibraryConstructors). */
internal object CoreConstructors {
    /** Constructor of a library class, or null. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        fun new(luaClass: String, vararg args: LuaExpr) = site.libNew(featureOf(luaClass), luaClass, args.toList())
        val first = site.argTypes.firstOrNull()
        val firstIsCollection = first != null && with(site.session) { first.collectionKind() } != null
        val elements = (if (firstIsCollection) site.args.take(1) else emptyList()).toTypedArray()
        return when (classId) {
            "kotlin/Pair" -> new("__K2L_Pair", *site.args.toTypedArray())

            "kotlin/Triple" -> new("__K2L_Triple", *site.args.toTypedArray())

            "java/util/ArrayList", "kotlin/collections/ArrayList" ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toMutableList", emptyList()) else new("__K2L_List")

            // ArrayDeque(elements); a capacity is not passed on
            "kotlin/collections/ArrayDeque" -> new("__K2L_ArrayDeque", *elements)

            // HashSet and HashMap keep insertion order, as LinkedHashSet and LinkedHashMap
            "java/util/LinkedHashSet", "kotlin/collections/LinkedHashSet", "java/util/HashSet", "kotlin/collections/HashSet" ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toMutableSet", emptyList()) else new("__K2L_Set")

            "java/util/LinkedHashMap", "kotlin/collections/LinkedHashMap", "java/util/HashMap", "kotlin/collections/HashMap" ->
                when {
                    first != null && with(site.session) { first.collectionKind() } == CollectionKind.Map ->
                        LuaMethodCall(site.arg(0), "toMutableMap", emptyList())

                    // LinkedHashMap(initialCapacity, loadFactor, accessOrder)
                    site.args.size == LINKED_MAP_ACCESS_ORDER_ARITY -> site.unsupported("LinkedHashMap in access order")

                    else -> new("__K2L_Map")
                }

            "java/lang/StringBuilder", "kotlin/text/StringBuilder", "java/lang/StringBuffer" ->
                new("__K2L_StringBuilder", *site.args.take(1).map { site.str(it, first) }.toTypedArray())

            "kotlin/text/Regex" -> RegexMappings.construct(site, site.arg(0), site.args.getOrNull(1))

            "kotlin/ranges/IntRange" -> new("__K2L_IntRange", site.arg(0), site.arg(1))

            "dev/k2l/lua/LuaTable" -> LuaTable(emptyList())

            "kotlin/Char" -> charFromCode(site.arg(0))

            "kotlin/Array" -> LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.arg(1), LuaBool(true)))

            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray", "kotlin/DoubleArray",
            "kotlin/FloatArray", "kotlin/BooleanArray", "kotlin/CharArray",
            -> primitiveArray(classId, site)

            // see LibraryConstructors for the other areas
            else -> null
        }
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
