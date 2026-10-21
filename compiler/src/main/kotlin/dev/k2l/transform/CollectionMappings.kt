package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtClassOrObject

/** The empty collection `null.orEmpty()` is, by kind. */
private val EMPTY_OF = mapOf(CollectionKind.Set to "__K2L_ReadOnlySetOf", CollectionKind.Array to "__K2L_ArrayOf")
private const val EMPTY_LIST = "__K2L_ReadOnlyListOf"

/** `StringBuilder.append(text, start, end)` */
private const val APPEND_RANGE_ARITY = 3

/** The number of the stdlib's class of `asList()` of each primitive array (`kotlin.collections.ArraysKt___ArraysJvmKt$asList$3`). */
private val PRIMITIVE_AS_LIST = mapOf(
    "ByteArray" to 1,
    "ShortArray" to 2,
    "IntArray" to 3,
    "LongArray" to 4,
    "FloatArray" to 5,
    "DoubleArray" to 6,
    "BooleanArray" to 7,
    "CharArray" to 8,
)

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
        "toBooleanArray", "toFloatArray", "toCharArray", "toShortArray", "toByteArray", "asSequence", "asIterable", "add",
        "addAll", "removeAt", "remove", "removeFirst", "removeLast",
        "removeAll", "removeIf", "retainAll", "clear", "sort", "sortDescending", "sortBy", "sortByDescending", "sortWith",
        "reverse", "fill", "subList", "contentEquals", "contentToString", "set", "toMutableMap", "hashCode",
        "windowed", "zipWithNext", "unzip", "foldRight", "reduceRight", "reduceOrNull", "foldIndexed", "reduceIndexed",
        "runningFold", "scan", "runningReduce", "maxWith", "minWith", "maxWithOrNull", "minWithOrNull", "takeLastWhile",
        "dropLastWhile", "mapIndexedNotNull", "flatMapIndexed", "mapTo", "filterTo", "toCollection", "associateByTo",
        "associateWithTo", "elementAtOrNull", "elementAtOrElse", "firstNotNullOfOrNull", "firstNotNullOf", "ifEmpty", "slice",
        "requireNoNulls", "asReversed", "asList", "binarySearch", "binarySearchBy", "sortedArray", "sortedArrayDescending",
        "sortedArrayWith", "reversedArray", "copyOfRange", "copyInto", "iterator", "addFirst", "addLast", "removeFirstOrNull",
        "removeLastOrNull",
        "replaceAll", "offer", "poll", "peek", "push", "pop", "offerFirst", "offerLast", "pollFirst", "pollLast", "peekFirst",
        "peekLast", "element", "getFirst", "getLast", "descendingIterator", "groupingBy", "sliceArray", "contentDeepToString",
        "contentHashCode", "contentDeepHashCode", "contentDeepEquals", "toSortedSet", "floor", "lower", "ceiling", "higher",
        "headSet", "tailSet", "subSet", "descendingSet", "foldRightIndexed", "mapIndexedTo",
        "maxOfWith", "minOfWith", "maxOfWithOrNull", "minOfWithOrNull", "reduceIndexedOrNull", "runningFoldIndexed",
        "scanIndexed", "runningReduceIndexed",
        "filterNotNullTo", "mapIndexedNotNullTo", "flatMapIndexedTo", "joinTo",
    )

    /** `Map` operations that are the `Iterable<Map.Entry>` ones, so they run over `entries`. */
    private val MAP_VIA_ENTRIES = setOf(
        "sumOf", "maxOf", "minOf", "maxOfOrNull", "minOfOrNull", "maxBy", "minBy", "maxWithOrNull", "minWithOrNull", "maxWith",
        "minWith", "firstNotNullOfOrNull", "firstNotNullOf", "sortedBy", "sortedByDescending", "sortedWith", "groupBy",
        "associate", "associateBy", "associateWith", "firstOrNull", "first", "toList", "flatMap", "mapNotNull", "mapIndexed",
        "fold", "single", "singleOrNull", "withIndex", "zip", "filterIsInstance",
        "maxOfWith", "minOfWith", "maxOfWithOrNull", "minOfWithOrNull",
    )

    private val MAP_METHODS = setOf(
        "get", "getOrDefault", "getOrElse", "getValue", "getOrPut", "containsKey", "containsValue", "put", "set", "putAll",
        "remove", "clear", "isEmpty", "isNotEmpty", "map", "mapNotNull", "flatMap", "any", "all", "none", "count", "filter",
        "filterKeys", "filterValues", "mapValues", "mapKeys", "toList", "toMap", "toMutableMap", "maxByOrNull", "minByOrNull",
        "forEach", "hashCode", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent", "replaceAll", "onEach",
        "filterNot", "mapValuesTo", "mapKeysTo", "orEmpty", "iterator", "asIterable", "toSortedMap", "firstKey", "lastKey",
        "firstEntry", "lastEntry", "floorKey", "lowerKey", "ceilingKey", "higherKey", "floorEntry", "lowerEntry", "ceilingEntry",
        "higherEntry", "pollFirstEntry", "pollLastEntry", "headMap", "tailMap", "subMap", "descendingMap", "descendingKeySet",
        "navigableKeySet",
        "filterTo", "ifEmpty",
    )

    private val ITERATOR_METHODS =
        setOf(
            "hasNext", "next", "remove", "hasPrevious", "previous", "nextIndex", "previousIndex", "set", "add", "setNext", "done",
            "nextInt", "nextLong", "nextDouble",
        )

    /** `Random` is passed explicitly to the lualib methods; calls without one use `Random.Default`. */
    private val RANDOM_METHODS = setOf("shuffled", "shuffle", "random", "randomOrNull")

    /** Members by the collection kind of the receiver; null for a receiver of no collection kind (see `StdlibMappings.AREAS`). */
    fun byReceiver(callableId: String?, site: CallSite): LuaExpr? {
        val kind = site.receiverKind ?: return null
        val name = site.name ?: return null
        return when (kind) {
            CollectionKind.List, CollectionKind.Array, CollectionKind.Set, CollectionKind.Iterable ->
                iterable(kind, name, site)?.let { if (site.utf16 && name == "joinToString") site.transformer.u16Norm(it) else it }

            CollectionKind.Map -> mapMember(name, site)

            CollectionKind.Range -> rangeMember(name, site)

            CollectionKind.ClosedRange -> closedRangeMember(name, site)

            CollectionKind.Entry, CollectionKind.Pair, CollectionKind.Triple, CollectionKind.IndexedValue -> tupleMember(kind, name, site)

            CollectionKind.LuaTable -> luaTableMember(name, site)

            CollectionKind.StringBuilder -> stringBuilderMember(name, site) ?: builderAsText(callableId, site)

            // see SequenceMappings
            CollectionKind.Sequence -> null

            CollectionKind.Regex -> RegexMappings.regexMember(name, site)

            CollectionKind.Match -> RegexMappings.matchMember(name, site)

            CollectionKind.Iterator -> iteratorMember(name, site)

            CollectionKind.Grouping ->
                if (name in setOf("eachCount", "fold", "reduce", "aggregate")) LuaMethodCall(site.self, name, site.args) else null
        }
    }

    private fun iteratorMember(name: String, site: CallSite): LuaExpr? =
        if (name in ITERATOR_METHODS) LuaMethodCall(site.self, name, site.args) else null

    private fun rangeMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "first", "last", "step" -> if (site.args.isEmpty() && !site.isFunctionCall()) {
            LuaIndex(site.self, LuaString(name))
        } else {
            // the range's `first` and `last` fields hide the Iterable methods of the same name
            site.libCall("Collections", "__K2L_Iterable", name, listOf(site.self) + site.args)
        }

        "start" -> LuaIndex(site.self, LuaString("first"))

        "endInclusive" -> LuaIndex(site.self, LuaString("last"))

        "contains" -> LuaMethodCall(site.self, "contains", site.args)

        "isEmpty" -> LuaMethodCall(site.self, "isEmpty", emptyList())

        else -> iterable(CollectionKind.Range, name, site)
    }

    private fun closedRangeMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "start" -> rangeBound(site, "first", "__K2L_RangeStart")
        "endInclusive" -> rangeBound(site, "last", "__K2L_RangeEnd")
        "contains", "isEmpty" -> LuaMethodCall(site.self, name, site.args)
        else -> null
    }

    /** A lualib range stores its bounds as `first`/`last`; a ClosedRange class of the program has its own `start`/`endInclusive`. */
    private fun rangeBound(site: CallSite, field: String, helper: String): LuaExpr = if (site.transformer.implementsClosedRange) {
        LuaCall(site.ref("Collections", helper), listOf(site.self))
    } else {
        LuaIndex(site.self, LuaString(field))
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
                site.libNew(PAIR_TABLE, fields.map { LuaIndex(site.self, LuaString(it)) })

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

    /** A `kotlin.text` function of CharSequence called on a StringBuilder (`sb.removeSuffix(",")`, `sb.lines()`): on its text. */
    private fun builderAsText(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId?.startsWith("kotlin/text/") != true) return null
        val text = LuaMethodCall(site.self, "toString", emptyList())
        return TextMappings.map(callableId, site.withReceiver(text, site.session.builtinTypes.string))
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

            // repeat(text, count) and repeat(codePoint, count) (JDK 21)
            "repeat" -> LuaMethodCall(
                self,
                "append",
                listOf(
                    site.libMember(
                        "JavaUtil",
                        "__K2L_JavaUtil",
                        if (site.isIntegral(site.argTypes[0])) "repeatCodePoint" else "repeatText",
                        if (site.isIntegral(site.argTypes[0])) args[0] else site.str(args[0], site.argTypes[0]),
                        args[1],
                    ),
                ),
            )

            "appendCodePoint" ->
                if (site.utf16) {
                    LuaMethodCall(
                        self,
                        "appendCodePoint",
                        args,
                    )
                } else {
                    site.unsupported("'appendCodePoint' without --strings utf16")
                }

            // the code point functions of String, on the builder's text
            "codePointAt", "codePointBefore", "codePointCount", "offsetByCodePoints" ->
                if (site.utf16) {
                    site.u16(name, LuaMethodCall(self, "toString", emptyList()), *args.toTypedArray())
                } else {
                    site.unsupported("'$name' without --strings utf16")
                }

            else -> null
        }
    }

    private fun substringOf(site: CallSite, text: Int, from: Int, to: Int): LuaExpr = if (site.utf16) {
        site.libMember(
            "Strings",
            "__K2L_Text",
            "substring",
            site.str(site.arg(text), site.argTypes.getOrNull(text)),
            site.arg(from),
            site.arg(to),
        )
    } else {
        LuaMethodCall(
            site.str(site.arg(text), site.argTypes.getOrNull(text)),
            "sub",
            listOf(LuaBinary(LuaBinOp.Add, site.arg(from), LuaNumber("1")), site.arg(to)),
        )
    }

    private fun concatToString(site: CallSite, self: LuaExpr): LuaExpr =
        LuaMethodCall(self, "joinToString", listOf(LuaString(""))).let { if (site.utf16) site.transformer.u16Norm(it) else it }

    private fun isCollection(site: CallSite, type: KaType?) = type != null && with(site.session) { type.collectionKind() } in ELEMENT_GROUPS

    /** The start value of `sum`/`sumOf` over elements of [type]: BigInteger/BigDecimal zero, `0.0`, or none (Lua's 0). */
    internal fun zeroFor(site: CallSite, type: KaType?): List<LuaExpr> = with(site.session) {
        BigNumberMappings.zero(site, type)?.let { return listOf(it) }
        if (type != null && (type.isDoubleType || type.isFloatType)) listOf(LuaNumber("0.0")) else emptyList()
    }

    /** The zero value of an array's element type, for `copyOf(newSize)`; null elements for object arrays. */
    private fun padFor(site: CallSite): LuaExpr = with(site.session) {
        val type = site.receiverType?.withoutFlexibility
        val classId = (type as? KaClassType)?.classId?.asString()
        when (classId) {
            "kotlin/DoubleArray", "kotlin/FloatArray" -> LuaNumber("0.0")

            "kotlin/IntArray", "kotlin/LongArray", "kotlin/ShortArray", "kotlin/ByteArray", "kotlin/UIntArray", "kotlin/ULongArray",
            "kotlin/UByteArray", "kotlin/UShortArray",
            -> LuaNumber("0")

            "kotlin/BooleanArray" -> LuaBool(false)

            "kotlin/CharArray" -> LuaString("\u0000")

            else -> LuaNil
        }
    }

    private fun iterable(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val self = site.self
        val component = name.removePrefix("component").toIntOrNull()
        return when {
            name in RANDOM_METHODS -> LuaMethodCall(self, name, listOf(site.args.firstOrNull() ?: site.defaultRandom()))
            name == "joinToString" -> FloatMappings.joinToString(site) ?: iterableByName(kind, name, site)
            component != null && name.startsWith("component") -> LuaMethodCall(self, "elementAt", listOf(LuaNumber("${component - 1}")))
            else -> iterableByName(kind, name, site)
        }
    }

    private fun iterableByName(kind: CollectionKind, name: String, site: CallSite): LuaExpr? {
        val self = site.self
        return when (name) {
            "size" -> LuaIndex(self, LuaString("size"))

            "get" -> when {
                site.isString(site.argTypes.getOrNull(0)) -> LuaMethodCall(self, "getNamed", site.args)

                // xs[i] and xs.get(i) throw IndexOutOfBoundsException; a loop index over xs.indices needs no check
                kind == CollectionKind.Iterable || site.transformer.isProvenIndex(
                    site.element,
                    site.receiverType,
                ) -> index(self, site.arg(0))

                site.transformer.isPrimitiveArray(site.receiverType) -> site.transformer.primitiveArrayRead(self, site.arg(0))

                else -> LuaMethodCall(self, "get", site.args)
            }

            "indices" -> LuaMethodCall(self, "getIndices", emptyList())

            // of a class of the program (which may override size): its getLastIndex, which calls size()
            "lastIndex" -> if (isSourceClass(site)) {
                LuaMethodCall(self, "getLastIndex", emptyList())
            } else {
                LuaBinary(LuaBinOp.Sub, LuaIndex(self, LuaString("size")), LuaNumber("1"))
            }

            "add", "addAll", "asList", "remove" -> renamedMember(name, site)

            "sum" -> FloatMappings.sum(site)
                ?: LuaMethodCall(self, "sum", zeroFor(site, with(site.session) { site.receiverType?.elementType }))

            "sumOf" -> LuaMethodCall(self, "sumOf", site.args + zeroFor(site, (site.argTypes.getOrNull(0) as? KaFunctionType)?.returnType))

            "plus", "minus" -> LuaMethodCall(self, if (isCollection(site, site.overloadType(0))) name + "All" else name, site.args)

            "plusAssign" -> LuaMethodCall(self, if (isCollection(site, site.overloadType(0))) "addAll" else "add", site.args)

            "minusAssign" -> LuaMethodCall(self, if (isCollection(site, site.overloadType(0))) "removeAll" else "remove", site.args)

            "sortedBy", "sortedByDescending", "sortBy", "sortByDescending" -> sortBySelector(name, site)

            "plusElement" -> LuaMethodCall(self, "plus", site.args)

            "minusElement" -> LuaMethodCall(self, "minus", site.args)

            "copyOf" -> if (site.args.isEmpty()) {
                LuaMethodCall(self, "toTypedArray", emptyList())
            } else {
                LuaMethodCall(self, "copyOfSize", listOf(site.arg(0), padFor(site)))
            }

            "concatToString" -> concatToString(site, self)

            "toString" -> null

            // the array type of the result (`listOf("a").toTypedArray()` is a String[])
            "toTypedArray" -> LuaMethodCall(self, name, listOfNotNull(FactoryMappings.arrayBinary(site)?.let { LuaString(it) }))

            "isNullOrEmpty" -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, self, LuaNil), LuaMethodCall(self, "isEmpty", emptyList()))

            // null.orEmpty() is emptyList() (emptySet() for a set, an empty array for an array)
            "orEmpty" -> LuaBinary(LuaBinOp.Or, self, LuaCall(site.ref("Collections", EMPTY_OF[kind] ?: EMPTY_LIST), emptyList()))

            else -> if (name in ITERABLE_METHODS) LuaMethodCall(self, name, site.args) else null
        }
    }

    private fun isSourceClass(site: CallSite): Boolean = with(site.session) {
        val psi = site.receiverType?.expandedSymbol?.psi as? org.jetbrains.kotlin.psi.KtClassOrObject
        psi != null && site.transformer.classes.isSource(psi)
    }

    /** Members whose lualib name depends on the arguments or the receiver's type. */
    private fun renamedMember(name: String, site: CallSite): LuaExpr {
        val self = site.self
        return when (name) {
            "add", "addAll" -> LuaMethodCall(self, if (site.args.size == 2) name + "At" else name, site.args)

            // a primitive array's asList() is the read-only view numbered like the stdlib's class (see __K2L_Array.asList)
            "asList" -> {
                val array = site.receiverType?.let { with(site.session) { it.expandedSymbol?.classId?.shortClassName?.asString() } }
                LuaMethodCall(self, "asList", listOfNotNull(PRIMITIVE_AS_LIST[array]?.let { LuaNumber(it.toString()) }))
            }

            // Queue.remove() takes the head; remove(element) is another method
            else -> LuaMethodCall(self, if (site.args.isEmpty()) "removeHead" else "remove", site.args)
        }
    }

    /** `sortedBy(selector)` and the like; a pure selector lets the lualib compute each key once (see `isPureSelector`). */
    fun sortBySelector(name: String, site: CallSite): LuaExpr {
        val pure = site.transformer.isPureSelector(site.element)
        return LuaMethodCall(site.self, name, if (pure) listOf(site.arg(0), LuaBool(true)) else site.args)
    }

    private fun mapMember(name: String, site: CallSite): LuaExpr? {
        val self = site.self
        return when (name) {
            "size" -> LuaIndex(self, LuaString("size"))

            "keys" -> LuaMethodCall(self, "getKeys", emptyList())

            "values" -> LuaMethodCall(self, "getValues", emptyList())

            "entries" -> LuaMethodCall(self, "getEntries", emptyList())

            "contains" -> LuaMethodCall(self, "containsKey", site.args)

            // null.orEmpty() is emptyMap()
            "orEmpty" -> LuaBinary(LuaBinOp.Or, self, LuaCall(site.ref("Collections", "__K2L_ReadOnlyMapOf"), emptyList()))

            "plusAssign" -> LuaMethodCall(self, if (isMapOrIterable(site)) "putAll" else "set", pairArguments(site))

            "plus" -> LuaMethodCall(self, "plus", site.args)

            "minus" -> LuaMethodCall(self, if (isCollection(site, site.overloadType(0))) "minusAll" else "minus", site.args)

            "minusAssign" -> if (isCollection(site, site.overloadType(0))) {
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
        site.overloadType(0)?.collectionKind() in
            setOf(
                CollectionKind.Map,
                CollectionKind.List,
                CollectionKind.Array,
                CollectionKind.Set,
                CollectionKind.Iterable,
                CollectionKind.Sequence,
            )
    }

    /** `map += pair` is `set(first, second)`; `map += otherMap` and `map += listOfPairs` are `putAll`. */
    private fun pairArguments(site: CallSite): List<LuaExpr> =
        if (with(site.session) { site.overloadType(0)?.collectionKind() } == CollectionKind.Pair) {
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
