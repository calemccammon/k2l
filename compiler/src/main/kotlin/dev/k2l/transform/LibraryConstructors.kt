package dev.k2l.transform

import dev.k2l.codegen.LuaExpr

/** One area of library constructors (an object's `construct`): the new instance of [classId], or null when it isn't one of its classes. */
typealias ConstructorArea = (classId: String?, site: CallSite) -> LuaExpr?

/**
 * The constructors of library classes (exceptions aside, see `LIBRARY_CLASSES`), by area, tried in order until one answers.
 *
 * Constructor calls and constructor references (`::ArrayList`) reach every area; a JDK factory member (`List.of`) reaches only
 * [REFERENCE_AREAS].
 */
internal object LibraryConstructors {
    /** Collections, ranges, text builders and arrays, big numbers, the JDK's other collections, code points and stream statistics. */
    private val REFERENCE_AREAS = listOf<ConstructorArea>(
        { id, site -> CoreConstructors.construct(id, site) },
        { id, site -> BigNumberMappings.construct(id, site) },
        { id, site -> JdkCollectionsMappings.construct(id, site) },
        { id, site -> Utf16Mappings.construct(id, site) },
        { id, site -> StreamMappings.construct(id, site) },
    )

    /** [REFERENCE_AREAS], then time, `java.util`, deep recursion and the rest of the kotlin package. */
    private val CALL_AREAS = REFERENCE_AREAS + listOf<ConstructorArea>(
        { id, site -> TimeMappings.construct(id, site) },
        { id, site -> JavaUtilMappings.construct(id, site) },
        { id, site -> DeepRecursiveMappings.construct(id, site) },
        { id, site -> CollectionExtrasMappings.construct(id, site) },
        { id, site -> KotlinMiscMappings.construct(id, site) },
    )

    /** A constructor call `ArrayList(xs)`, or the call a constructor reference `::ArrayList` makes. */
    fun call(classId: String?, site: CallSite): LuaExpr? = CALL_AREAS.firstNotNullOfOrNull { it(classId, site) }

    /** The constructor a JDK factory member (`List.of`) calls. */
    fun reference(classId: String?, site: CallSite): LuaExpr? = REFERENCE_AREAS.firstNotNullOfOrNull { it(classId, site) }
}
