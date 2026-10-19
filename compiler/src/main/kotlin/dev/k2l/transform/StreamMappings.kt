package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/**
 * `java.util.stream` (`Stream`, `IntStream`, `LongStream`, `DoubleStream`, `Collectors`) and `Optional`, `OptionalInt`,
 * `OptionalLong`, `OptionalDouble`, as in `Streams.lua`: `Arrays.stream`, `collection.stream()` and `parallelStream()` (which
 * runs sequentially), `IntStream.range` and the commonly used stages and terminal operations; the `*SummaryStatistics`
 * classes are in `SummaryStatistics.lua`. A member that is not listed here is reported as unsupported.
 */
internal object StreamMappings {
    private const val PACKAGE = "java/util/stream/"
    private const val STREAMS = "Streams"

    private val COMMON = setOf(
        "filter", "map", "flatMap", "distinct", "sorted", "limit", "skip", "peek", "takeWhile", "dropWhile", "parallel", "sequential",
        "unordered", "forEach", "forEachOrdered", "count", "toArray", "anyMatch", "allMatch", "noneMatch", "findFirst", "findAny",
        "reduce", "min", "max", "close", "iterator", "isParallel",
    )

    private val PRIMITIVE = setOf("sum", "average", "boxed", "mapToObj")

    /** The instance members of each stream class. */
    private val MEMBERS = mapOf(
        "Stream" to COMMON +
            setOf("toList", "mapToInt", "mapToLong", "mapToDouble", "collect", "flatMapToInt", "flatMapToLong", "flatMapToDouble"),
        "IntStream" to COMMON + PRIMITIVE + setOf("asDoubleStream", "asLongStream", "mapToLong", "mapToDouble"),
        "LongStream" to COMMON + PRIMITIVE + setOf("asDoubleStream", "mapToInt", "mapToDouble"),
        "DoubleStream" to COMMON + PRIMITIVE + setOf("mapToInt", "mapToLong"),
        "BaseStream" to setOf("isParallel", "iterator", "parallel", "sequential", "unordered", "close"),
    )

    private val FACTORIES = setOf("of", "empty", "iterate", "generate", "concat")

    private val COLLECTORS = setOf(
        "toList", "toSet", "toCollection", "joining", "counting", "summingInt", "summingLong", "summingDouble", "averagingInt",
        "averagingLong", "averagingDouble", "mapping", "collectingAndThen", "minBy", "maxBy", "groupingBy", "partitioningBy",
        "toMap",
    )

    /** `Collectors.summarizingInt` and the like: the kind of statistics they fill. */
    private val SUMMARIZING = mapOf("summarizingInt" to "Int", "summarizingLong" to "Long", "summarizingDouble" to "Double")

    private val OPTIONAL_MEMBERS = setOf(
        "isPresent", "isEmpty", "orElse", "orElseGet", "orElseThrow", "ifPresent", "ifPresentOrElse", "equals", "toString",
    )

    /** The Kotlin names of getters (`optional.asInt` is `getAsInt()`). */
    private val GETTERS = mapOf("asInt" to "getAsInt", "asLong" to "getAsLong", "asDouble" to "getAsDouble")

    private val OPTIONAL_CLASSES = mapOf(
        "Optional" to setOf("get", "map", "flatMap", "filter"),
        "OptionalInt" to setOf("getAsInt", "asInt"),
        "OptionalLong" to setOf("getAsLong", "asLong"),
        "OptionalDouble" to setOf("getAsDouble", "asDouble"),
    )

    private val STREAM_CLASS_NAMES = mapOf(
        "Stream" to "__K2L_Stream",
        "IntStream" to "__K2L_IntStream",
        "LongStream" to "__K2L_LongStream",
        "DoubleStream" to "__K2L_DoubleStream",
    )

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        callableId ?: return null
        val name = site.name ?: return null
        return when {
            callableId.startsWith(PACKAGE) -> javaStream(callableId.removePrefix(PACKAGE), name, site)

            callableId.startsWith("java/util/Optional") -> optional(callableId.removePrefix("java/util/"), name, site)

            callableId == "java/util/Arrays.stream" -> arraysStream(site)

            callableId.startsWith("kotlin/collections/") && name == "stream" && site.receiver != null ->
                site.streams("ofCollection", site.self)

            // parallelStream() runs sequentially
            callableId.startsWith("kotlin/collections/") && name == "parallelStream" && site.receiver != null ->
                site.streams("ofCollection", site.self, LuaBool(true))

            callableId.substringBefore('.') in STATISTICS -> statistics(name, site)

            else -> null
        }
    }

    private fun CallSite.streams(member: String, vararg args: LuaExpr): LuaExpr = libMember(STREAMS, "__K2L_Streams", member, *args)

    private fun CallSite.streamClass(simpleName: String): LuaExpr = ref(STREAMS, STREAM_CLASS_NAMES.getValue(simpleName))

    private fun javaStream(rest: String, name: String, site: CallSite): LuaExpr? {
        val owner = rest.substringBefore('.')
        return when {
            owner == "Collectors" -> when (name) {
                in COLLECTORS -> site.libMember(STREAMS, "__K2L_Collectors", name, *site.args.toTypedArray())

                in SUMMARIZING -> site.libMember(
                    STATISTICS_FEATURE,
                    "__K2L_SummaryStatistics",
                    "collector",
                    LuaString(SUMMARIZING.getValue(name)),
                    *site.args.toTypedArray(),
                )

                else -> null
            }

            owner !in MEMBERS -> null

            // IntStream.summaryStatistics(): an IntSummaryStatistics, and so on
            site.receiver != null && name == "summaryStatistics" && owner != "Stream" ->
                site.libMember(STATISTICS_FEATURE, "__K2L_SummaryStatistics", "of", LuaString(owner.removeSuffix("Stream")), site.self)

            site.receiver != null -> if (name in MEMBERS.getValue(owner)) method(site.self, name, *site.args.toTypedArray()) else null

            name in FACTORIES || (owner in RANGES && (name == "range" || name == "rangeClosed")) -> staticFactory(owner, name, site)

            else -> null
        }
    }

    private fun staticFactory(owner: String, name: String, site: CallSite): LuaExpr? = when (name) {
        "range", "rangeClosed" -> if (owner == "LongStream") {
            site.streams("rangeLong", site.arg(0), site.arg(1), LuaBool(name == "rangeClosed"))
        } else {
            site.streams(name, *site.args.toTypedArray())
        }

        "of" -> site.streams("of", site.streamClass(owner), varargsList(site))

        else -> site.streams(name, site.streamClass(owner), *site.args.toTypedArray())
    }

    /** The elements of `of(a, b, c)` (or of one array passed as `of(*array)`) as a list. */
    private fun varargsList(site: CallSite): LuaExpr = LuaCall(site.ref("Collections", "__K2L_ListOf"), site.args)

    private fun arraysStream(site: CallSite): LuaExpr? {
        val classId = with(site.session) { (site.argTypes.firstOrNull()?.withoutFlexibility as? KaClassType)?.classId?.asString() }
        val owner = when (classId) {
            "kotlin/IntArray" -> "IntStream"
            "kotlin/DoubleArray" -> "DoubleStream"
            "kotlin/LongArray" -> "LongStream"
            else -> "Stream"
        }
        return site.streams("ofArray", site.streamClass(owner), *site.args.toTypedArray())
    }

    private fun optional(rest: String, name: String, site: CallSite): LuaExpr? {
        val owner = rest.substringBefore('.')
        val members = OPTIONAL_CLASSES[owner] ?: return null
        val table = site.ref(STREAMS, "__K2L_$owner")
        return when {
            site.receiver == null && (name == "of" || name == "empty" || (name == "ofNullable" && owner == "Optional")) ->
                LuaCall(LuaIndex(table, LuaString(name)), site.args)

            site.receiver == null -> null

            name in members || name in OPTIONAL_MEMBERS -> method(site.self, GETTERS[name] ?: name, *site.args.toTypedArray())

            else -> null
        }
    }

    private val RANGES = setOf("IntStream", "LongStream")

    private const val STATISTICS_FEATURE = "SummaryStatistics"

    private val STATISTICS = setOf("java/util/IntSummaryStatistics", "java/util/LongSummaryStatistics", "java/util/DoubleSummaryStatistics")

    /** The members of the statistics; Kotlin reads `getCount()` as `count`. */
    private val STATISTICS_MEMBERS = setOf("accept", "combine", "getCount", "getSum", "getMin", "getMax", "getAverage")

    /** `IntSummaryStatistics()` and the like. */
    fun construct(classId: String?, site: CallSite): LuaExpr? = if (classId in STATISTICS) {
        val name = "__K2L_" + classId!!.substringAfterLast('/')
        LuaCall(LuaIndex(site.ref(STATISTICS_FEATURE, name), LuaString("new")), emptyList())
    } else {
        null
    }

    private fun statistics(name: String, site: CallSite): LuaExpr? {
        site.receiver ?: return null
        val getter = if (name in STATISTICS_PROPERTIES) "get" + name.replaceFirstChar { it.uppercaseChar() } else name
        return when (getter) {
            in STATISTICS_MEMBERS -> method(site.self, getter, *site.args.toTypedArray())
            "toString" -> site.str(site.self, site.receiverType)
            else -> null
        }
    }

    private val STATISTICS_PROPERTIES = setOf("count", "sum", "min", "max", "average")
}
