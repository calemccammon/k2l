package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtQualifiedExpression

/** `LinkedHashMap(initialCapacity, loadFactor, accessOrder)` */
internal const val LINKED_MAP_ACCESS_ORDER_ARITY = 3

/** Functions that create collections, ranges, comparators and pairs, and constructors of library classes. */
@Suppress("TooManyFunctions") // one small mapper per kind of factory
internal object FactoryMappings {
    fun factory(callableId: String?, site: CallSite): LuaExpr? {
        fun call(name: String, vararg args: LuaExpr) = LuaCall(site.ref(featureOf(name), name), args.toList())
        val args = site.args.toTypedArray()
        return when (callableId) {
            // the JVM's classes: EmptyList, Collections$SingletonList for listOf(x), Arrays$ArrayList for listOf(a, b, ...)
            "kotlin/collections/listOf" -> if (isSingleArgument(
                    site,
                )
            ) {
                call("__K2L_SingletonListOf", *args)
            } else {
                call("__K2L_ReadOnlyListOf", *args)
            }

            "kotlin/collections/emptyList" -> call("__K2L_ReadOnlyListOf")

            "kotlin/collections/mutableListOf", "kotlin/collections/arrayListOf" -> call("__K2L_ListOf", *args)

            "kotlin/collections/listOfNotNull" -> LuaMethodCall(call("__K2L_ListOf", *args), "filterNotNull", emptyList()).let {
                if (isSingleArgument(site)) LuaMethodCall(it, "toList", emptyList()) else it
            }

            "kotlin/arrayOf", "kotlin/intArrayOf", "kotlin/longArrayOf", "kotlin/doubleArrayOf", "kotlin/floatArrayOf",
            "kotlin/booleanArrayOf", "kotlin/charArrayOf", "kotlin/shortArrayOf", "kotlin/byteArrayOf", "kotlin/emptyArray",
            "kotlin/uintArrayOf", "kotlin/ulongArrayOf", "kotlin/ubyteArrayOf", "kotlin/ushortArrayOf",
            -> arrayBinary(site)?.let { call("__K2L_TypedArrayOf", LuaString(it), *args) } ?: call("__K2L_ArrayOf", *args)

            "kotlin/arrayOfNulls" -> call("__K2L_ListOfSize", site.arg(0), LuaNil, arrayClass(site))

            "kotlin/collections/setOf", "kotlin/collections/emptySet" -> call("__K2L_ReadOnlySetOf", *args)

            "kotlin/collections/mutableSetOf", "kotlin/collections/linkedSetOf" -> call("__K2L_SetOf", *args)

            "kotlin/collections/mapOf" -> if (isSingleArgument(
                    site,
                )
            ) {
                call("__K2L_SingletonMapOf", *args)
            } else {
                call("__K2L_ReadOnlyMapOf", *args)
            }

            "kotlin/collections/emptyMap" -> call("__K2L_ReadOnlyMapOf")

            "kotlin/collections/mutableMapOf", "kotlin/collections/linkedMapOf" -> call("__K2L_MapOf", *args)

            "kotlin/collections/hashSetOf" -> call("__K2L_HashSetOf", *args)

            "kotlin/collections/hashMapOf" -> call("__K2L_HashMapOf", *args)

            "kotlin/collections/sortedMapOf" -> call("__K2L_SortedMapOf", *args)

            "kotlin/collections/sortedSetOf" -> call("__K2L_SortedSetOf", *args)

            "kotlin/to" -> LuaCall(LuaIndex(site.ref("Pair", "__K2L_Pair"), LuaString("new")), listOf(site.self, site.arg(0)))

            "kotlin/collections/List", "kotlin/collections/MutableList" -> call("__K2L_ListOfSize", site.arg(0), site.arg(1))

            else -> comparators(callableId, site) ?: ranges(callableId, site) ?: misc(callableId, site)
        }
    }

    /** `listOf(x)`, `mapOf(pair)`: the one-element overload, not the vararg one called with a single `*spread` argument. */
    private fun isSingleArgument(site: CallSite): Boolean {
        val call = site.element as? KtCallExpression ?: (site.element as? KtQualifiedExpression)?.selectorExpression as? KtCallExpression
        val argument = call?.valueArguments?.singleOrNull() ?: return false
        return argument.getSpreadElement() == null
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

            // SAM constructors: values of library SAM interfaces are Lua callables (see SamInterfaces.lua)
            "kotlin/Comparator", "java/util/Comparator", "java/lang/Runnable", "java/util/concurrent/Callable" -> site.arg(0)

            "java/util/Comparator.compare", "java/lang/Runnable.run", "java/util/concurrent/Callable.call" -> LuaCall(site.self, site.args)

            // `f(x)` on an object of a class implementing a function type by delegation: the object is callable
            in FUNCTION_INVOKES -> LuaCall(site.self, site.args)

            "kotlin/comparisons/compareValues" -> LuaCall(site.ref("Compare", "__K2L_CompareValues"), listOf(site.arg(0), site.arg(1)))

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
                listOfNotNull(site.self, site.arg(0), boundsFormat(site)),
            )

            "kotlin/Int.rangeUntil", "kotlin/ranges/until" ->
                if (charOperands) {
                    newCharRange(site, site.self, charFromCode(site, charCodeMinusOne(site, site.arg(0))))
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

    /**
     * How a range of Doubles or Floats prints its bounds (`30.0..50.0`): an integral Double is an integer on Lua 5.1, 5.2 and
     * LuaJIT, so the range is given the formatter of its static type.
     */
    private fun boundsFormat(site: CallSite): LuaExpr? = with(site.session) {
        val type = site.receiverType ?: return null
        when {
            type.isDoubleType -> site.ref("DoubleToString", "__K2L_DoubleToString")
            type.isFloatType -> site.ref("FloatToString", "__K2L_FloatToString")
            else -> null
        }
    }

    private fun charCodeMinusOne(site: CallSite, c: LuaExpr): LuaExpr =
        LuaBinary(LuaBinOp.Sub, if (site.utf16) site.u16("code", c) else LuaMethodCall(c, "byte", emptyList()), LuaNumber("1"))

    private fun charFromCode(site: CallSite, code: LuaExpr): LuaExpr =
        if (site.utf16) site.u16("char", code) else LuaCall(luaPath("string", "char"), listOf(code))

    private fun misc(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
        "java/util/Objects.equals" -> LuaCall(site.ref("Equals", "__K2L_Equals"), listOf(site.arg(0), site.arg(1)))

        "java/util/Objects.hashCode" -> LuaCall(site.ref("Hash", "__K2L_Hash"), listOf(site.arg(0)))

        "java/util/Objects.hash" ->
            LuaMethodCall(LuaCall(site.ref("Collections", "__K2L_ListOf"), site.args), "hashCode", emptyList())

        // the stdlib's empty ranges are 1..0 (and '\u0001'..'\u0000')
        "kotlin/ranges/IntRange.Companion.EMPTY" -> newRange(site, LuaNumber("1"), LuaNumber("0"))

        "kotlin/ranges/LongRange.Companion.EMPTY" -> if (site.transformer.emulatesLong) {
            LuaCall(
                LuaIndex(site.ref("Long64Range", "__K2L_LongRange"), LuaString("new")),
                listOf(LuaNumber("1"), LuaNumber("0"), LuaNil, LuaBool(false)),
            )
        } else {
            newRange(site, LuaNumber("1"), LuaNumber("0"))
        }

        "kotlin/ranges/CharRange.Companion.EMPTY" ->
            newCharRange(site, charFromCode(site, LuaNumber("1")), charFromCode(site, LuaNumber("0")))

        else -> null
    }

    private fun newRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null) =
        LuaCall(LuaIndex(site.ref("Collections", "__K2L_IntRange"), LuaString("new")), listOfNotNull(first, last, step))

    private fun newCharRange(site: CallSite, first: LuaExpr, last: LuaExpr, step: LuaExpr? = null): LuaExpr {
        val range = if (site.utf16) {
            LuaIndex(
                LuaIndex(site.ref("Utf16", "__K2L_Utf16"), LuaString("CharRange")),
                LuaString("new"),
            )
        } else {
            LuaIndex(site.ref("Collections", "__K2L_CharRange"), LuaString("new"))
        }
        return LuaCall(range, listOfNotNull(first, last, step))
    }

    /** Constructor of a library class, or null. */
    fun construct(classId: String?, site: CallSite): LuaExpr? {
        fun new(luaClass: String, vararg args: LuaExpr) =
            LuaCall(LuaIndex(site.ref(featureOf(luaClass), luaClass), LuaString("new")), args.toList())
        val first = site.argTypes.firstOrNull()
        val firstIsCollection = first != null && with(site.session) { first.collectionKind() } != null
        val elements = (if (firstIsCollection) site.args.take(1) else emptyList()).toTypedArray()
        return when (classId) {
            "kotlin/Pair" -> new("__K2L_Pair", *site.args.toTypedArray())

            "kotlin/Triple" -> new("__K2L_Triple", *site.args.toTypedArray())

            "java/util/ArrayList", "kotlin/collections/ArrayList" ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toMutableList", emptyList()) else new("__K2L_List")

            // ArrayDeque(elements), LinkedList(elements); a capacity is not passed on, except to a java.util.ArrayDeque, whose
            // iterators depend on its array (see Deques.lua)
            "kotlin/collections/ArrayDeque" -> new("__K2L_ArrayDeque", *elements)

            "java/util/ArrayDeque" -> new("__K2L_Deque", *site.args.take(1).toTypedArray())

            "java/util/LinkedList" -> new("__K2L_LinkedList", *site.args.take(1).toTypedArray())

            "java/util/HashSet", "kotlin/collections/HashSet" -> new("__K2L_HashSet", *site.args.take(1).toTypedArray())

            "java/util/HashMap", "kotlin/collections/HashMap" -> new("__K2L_HashMap", *site.args.take(1).toTypedArray())

            "java/util/LinkedHashSet", "kotlin/collections/LinkedHashSet" ->
                if (firstIsCollection) LuaMethodCall(site.arg(0), "toMutableSet", emptyList()) else new("__K2L_Set")

            "java/util/LinkedHashMap", "kotlin/collections/LinkedHashMap" ->
                when {
                    first != null && with(site.session) { first.collectionKind() } == CollectionKind.Map ->
                        LuaMethodCall(site.arg(0), "toMutableMap", emptyList())

                    // LinkedHashMap(initialCapacity, loadFactor, accessOrder)
                    site.args.size == LINKED_MAP_ACCESS_ORDER_ARITY -> new("__K2L_Map", LuaNil, site.arg(2))

                    else -> new("__K2L_Map")
                }

            "java/util/PriorityQueue" -> newPriorityQueue(site)

            "java/util/TreeMap" -> new("__K2L_SortedMap", *site.args.take(1).toTypedArray())

            "java/util/TreeSet" -> new("__K2L_SortedSet", *site.args.take(1).toTypedArray())

            "java/lang/StringBuilder", "kotlin/text/StringBuilder", "java/lang/StringBuffer" ->
                new("__K2L_StringBuilder", *site.args.take(1).map { site.str(it, first) }.toTypedArray())

            "kotlin/text/Regex" -> {
                site.requireRegexProperties(site.arg(0))
                new("__K2L_Regex", *site.args.toTypedArray())
            }

            "kotlin/ranges/IntRange" -> new("__K2L_IntRange", site.arg(0), site.arg(1))

            "dev/k2l/lua/LuaTable" -> LuaTable(emptyList())

            "kotlin/Char" -> charFromCode(site, site.arg(0))

            "kotlin/Array" -> LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.arg(1), arrayClass(site)))

            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray", "kotlin/DoubleArray",
            "kotlin/FloatArray", "kotlin/BooleanArray", "kotlin/CharArray", "kotlin/UIntArray", "kotlin/ULongArray", "kotlin/UByteArray",
            "kotlin/UShortArray",
            -> primitiveArray(classId, site)

            else -> BigNumberMappings.construct(classId, site) ?: JdkCollectionsMappings.construct(classId, site)
                ?: Utf16Mappings.construct(classId, site) ?: StreamMappings.construct(classId, site)
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
        return LuaCall(site.ref("Collections", "__K2L_ListOfSize"), listOf(site.arg(0), site.args.getOrNull(1) ?: zero, arrayClass(site)))
    }

    /** The JVM name of the array type the call makes (see `__K2L_ArrayClassOf`), null for an `Object[]`. */
    fun arrayBinary(site: CallSite): String? = with(site.session) { site.transformer.arrayBinary(site.element.expressionType) }

    /** The array class argument of `__K2L_ListOfSize`: the array type's JVM name, or true for an `Object[]`. */
    private fun arrayClass(site: CallSite): LuaExpr = arrayBinary(site)?.let { LuaString(it) } ?: LuaBool(true)
}

/** `kotlin.Function0.invoke` ... `kotlin.Function22.invoke`. */
private val FUNCTION_INVOKES = (0..22).map { "kotlin/Function$it.invoke" }.toSet()
