package dev.k2l.coverage

import java.io.File
import kotlin.system.exitProcess

/**
 * The standard library audit behind `./gradlew :compiler:stdlibCoverage` (see "Standard library coverage" in the README):
 * enumerates the public API of the [AREAS] from the Kotlin stdlib and the JDK ([ApiEnumerator]), writes a small probe
 * function that calls each function or property ([ProbeWriter]), transpiles the probes with k2l in-process
 * ([ProbeRunner]) and writes which ones translate to `docs/stdlib-coverage.md` ([CoverageReport]).
 */
fun main() {
    val config = CoverageConfig.fromSystemProperties()
    val areas = AREAS.filter { config.only == null || it.name in config.only }
    require(areas.isNotEmpty()) { "no areas selected (-PcoverageOnly=${config.only}); areas: ${AREAS.joinToString { it.name }}" }
    config.work.deleteRecursively()
    val apis = ApiEnumerator.enumerate(File(config.work, "enumerate"), areas)
    println("k2l stdlib coverage: ${apis.size} declarations in ${areas.size} areas")
    val results = ProbeRunner(File(config.work, "probes")).run(apis)
    val mapped = MappingScan(config.sources)
    val report = CoverageReport(areas, results, mapped::mentions)
    if (config.only == null) {
        config.report.parentFile.mkdirs()
        config.report.writeText(report.markdown())
        println("wrote ${config.report}")
    } else {
        println(report.details())
    }
    println(report.summary())
    // The Analysis API leaves non-daemon threads behind.
    exitProcess(0)
}

/**
 * The fallback for an API without a usable probe: whether k2l's sources name its callable id (`"kotlin/text/format"`),
 * which suggests a mapping exists for some form of the call.
 */
class MappingScan(sources: File) {
    private val text = sources.walkTopDown().filter { it.extension == "kt" }.joinToString("\n") { it.readText() }

    fun mentions(callableId: String): Boolean = "\"$callableId\"" in text
}

/** Settings from the system properties the `stdlibCoverage` task passes. */
class CoverageConfig(val report: File, val work: File, val sources: File, val only: Set<String>?) {
    companion object {
        fun fromSystemProperties() = CoverageConfig(
            report = File(System.getProperty("k2l.coverage.report") ?: "../docs/stdlib-coverage.md"),
            work = File(System.getProperty("k2l.coverage.work") ?: "build/coverage"),
            sources = File(System.getProperty("k2l.coverage.sources") ?: "src/main/kotlin"),
            only = System.getProperty("k2l.coverage.only")?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }?.toSet(),
        )
    }
}

/**
 * A section of the report: the public top-level callables of [packages] and the members of their public classes, plus
 * the members of [classes] (class ids such as `java/util/ArrayList`; nested classes are included). [staticsOnly] keeps
 * only the static members (and constructors) of [classes], for classes such as `java.lang.Integer` whose instances
 * Kotlin maps to its own types.
 */
class Area(
    val name: String,
    val packages: List<String> = emptyList(),
    val classes: List<String> = emptyList(),
    val staticsOnly: Boolean = false,
    /** Classes of [packages] left out (`kotlin` has the unsigned types in an area of their own). */
    val excludedClasses: Set<String> = emptySet(),
)

private val UNSIGNED = listOf("UInt", "ULong", "UShort", "UByte", "UIntArray", "ULongArray", "UShortArray", "UByteArray")

val AREAS = listOf(
    Area("kotlin", packages = listOf("kotlin"), excludedClasses = UNSIGNED.toSet()),
    Area("kotlin (unsigned types)", classes = UNSIGNED.map { "kotlin/$it" }),
    Area("kotlin.collections", packages = listOf("kotlin.collections")),
    Area("kotlin.text", packages = listOf("kotlin.text")),
    Area("kotlin.sequences", packages = listOf("kotlin.sequences")),
    Area("kotlin.ranges", packages = listOf("kotlin.ranges")),
    Area("kotlin.comparisons", packages = listOf("kotlin.comparisons")),
    Area("kotlin.time", packages = listOf("kotlin.time")),
    Area("kotlin.properties", packages = listOf("kotlin.properties")),
    Area(
        "java.util",
        classes = listOf(
            "ArrayList", "LinkedList", "HashMap", "LinkedHashMap", "TreeMap", "HashSet", "LinkedHashSet", "TreeSet",
            "ArrayDeque", "PriorityQueue", "Stack", "BitSet", "EnumMap", "EnumSet", "Collections", "Arrays", "Objects",
            "Optional", "OptionalInt", "OptionalLong", "OptionalDouble", "StringJoiner", "Comparator",
        ).map { "java/util/$it" },
    ),
    Area("java.lang.Math", classes = listOf("java/lang/Math")),
    Area("java.lang.StringBuilder", classes = listOf("java/lang/StringBuilder")),
    Area(
        "java.lang statics",
        classes = listOf("Character", "Integer", "Long", "Double", "Boolean").map { "java/lang/$it" },
        staticsOnly = true,
    ),
)
