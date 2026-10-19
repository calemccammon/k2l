package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/**
 * `java.util.stream` (`Stream`, `IntStream`, `DoubleStream`, `Collectors`) and `Optional`, `OptionalInt`, `OptionalDouble`,
 * as in `Streams.lua`: `Arrays.stream`, `collection.stream()`, `IntStream.range` and the commonly used stages and terminal
 * operations. A member that is not listed here (`LongStream`, `parallelStream`, `iterator`, ...) is reported as unsupported.
 */
internal object StreamMappings {
    private const val PACKAGE = "java/util/stream/"
    private const val STREAMS = "Streams"

    private val COMMON = setOf(
        "filter", "map", "flatMap", "distinct", "sorted", "limit", "skip", "peek", "takeWhile", "dropWhile", "parallel", "sequential",
        "unordered", "forEach", "forEachOrdered", "count", "toArray", "anyMatch", "allMatch", "noneMatch", "findFirst", "findAny",
        "reduce", "min", "max", "close",
    )

    private val PRIMITIVE = setOf("sum", "average", "boxed", "mapToObj")

    /** The instance members of each stream class. */
    private val MEMBERS = mapOf(
        "Stream" to COMMON + setOf("toList", "mapToInt", "mapToDouble", "collect"),
        "IntStream" to COMMON + PRIMITIVE + setOf("asDoubleStream", "mapToDouble"),
        "DoubleStream" to COMMON + PRIMITIVE + setOf("mapToInt"),
    )

    private val FACTORIES = setOf("of", "empty", "iterate", "generate", "concat")

    private val COLLECTORS = setOf(
        "toList", "toSet", "toCollection", "joining", "counting", "summingInt", "summingDouble", "averagingInt", "averagingDouble",
        "mapping", "collectingAndThen", "minBy", "maxBy", "groupingBy", "partitioningBy", "toMap",
    )

    private val OPTIONAL_MEMBERS = setOf(
        "isPresent", "isEmpty", "orElse", "orElseGet", "orElseThrow", "ifPresent", "ifPresentOrElse", "equals", "toString",
    )

    /** The Kotlin names of getters (`optional.asInt` is `getAsInt()`). */
    private val GETTERS = mapOf("asInt" to "getAsInt", "asDouble" to "getAsDouble")

    private val OPTIONAL_CLASSES = mapOf(
        "Optional" to setOf("get", "map", "flatMap", "filter"),
        "OptionalInt" to setOf("getAsInt", "asInt"),
        "OptionalDouble" to setOf("getAsDouble", "asDouble"),
    )

    private val STREAM_CLASS_NAMES = mapOf(
        "Stream" to "__K2L_Stream",
        "IntStream" to "__K2L_IntStream",
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

            else -> null
        }
    }

    private fun CallSite.streams(member: String, vararg args: LuaExpr): LuaExpr = libMember(STREAMS, "__K2L_Streams", member, *args)

    private fun CallSite.streamClass(simpleName: String): LuaExpr = ref(STREAMS, STREAM_CLASS_NAMES.getValue(simpleName))

    private fun javaStream(rest: String, name: String, site: CallSite): LuaExpr? {
        val owner = rest.substringBefore('.')
        return when {
            owner == "Collectors" -> if (name in
                COLLECTORS
            ) {
                site.libMember(STREAMS, "__K2L_Collectors", name, *site.args.toTypedArray())
            } else {
                null
            }

            owner !in MEMBERS -> null

            site.receiver != null -> if (name in MEMBERS.getValue(owner)) method(site.self, name, *site.args.toTypedArray()) else null

            name in FACTORIES || (owner == "IntStream" && (name == "range" || name == "rangeClosed")) -> staticFactory(owner, name, site)

            else -> null
        }
    }

    private fun staticFactory(owner: String, name: String, site: CallSite): LuaExpr? = when (name) {
        "range", "rangeClosed" -> site.streams(name, *site.args.toTypedArray())
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
            "kotlin/LongArray" -> return null
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
}
