package dev.k2l.transform

import org.jetbrains.kotlin.name.ClassId

/** k2l annotations from the `dev.k2l.lua` interop package. */
internal val LUA_EXTERNAL = ClassId.fromString("dev/k2l/lua/LuaExternal")
internal val LUA_NAME = ClassId.fromString("dev/k2l/lua/LuaName")
internal val LUA_REQUIRE = ClassId.fromString("dev/k2l/lua/LuaRequire")
internal val NO_SELF = ClassId.fromString("dev/k2l/lua/NoSelf")

/** Kotlin library functions whose lambdas are inlined at the call site. */
internal val SCOPE_FUNCTIONS = setOf(
    "kotlin/let", "kotlin/also", "kotlin/apply", "kotlin/run", "kotlin/with", "kotlin/takeIf", "kotlin/takeUnless",
    "kotlin/repeat", "kotlin/require", "kotlin/check", "kotlin/requireNotNull", "kotlin/checkNotNull",
    "kotlin/error", "kotlin/TODO", "kotlin/text/buildString",
    "kotlin/collections/forEach", "kotlin/collections/forEachIndexed", "kotlin/sequences/forEach",
    "java/lang/Iterable.forEach", "java/util/Map.forEach", "kotlin/text/forEach",
    "kotlin/collections/buildList", "kotlin/collections/buildMap", "kotlin/collections/buildSet",
)

/** Library classes implemented by lualib, by ClassId (JVM typealiases expand to java.lang classes). */
internal val LIBRARY_CLASSES = listOf(
    "Throwable", "Exception", "Error", "RuntimeException", "IllegalArgumentException", "IllegalStateException",
    "NullPointerException", "IndexOutOfBoundsException", "ArithmeticException", "UnsupportedOperationException",
    "ClassCastException", "NumberFormatException",
).flatMap { listOf("java/lang/$it" to "__K2L_$it", "kotlin/$it" to "__K2L_$it") }.toMap() + mapOf(
    "kotlin/Throwable" to "__K2L_Throwable",
    "java/util/NoSuchElementException" to "__K2L_NoSuchElementException",
    "kotlin/NoSuchElementException" to "__K2L_NoSuchElementException",
    "java/util/ConcurrentModificationException" to "__K2L_ConcurrentModificationException",
    "kotlin/ConcurrentModificationException" to "__K2L_ConcurrentModificationException",
    "kotlin/NotImplementedError" to "__K2L_NotImplementedError",
)

/** Library supertypes that need no runtime support (Comparable is honored via compareTo). */
internal val MARKER_INTERFACES = setOf(
    "kotlin/Any",
    "kotlin/Comparable",
    "java/lang/Comparable",
    "java/io/Serializable",
    "kotlin/properties/ReadWriteProperty",
    "kotlin/properties/ReadOnlyProperty",
    // implemented by objects with resumeWith()/hasNext()/next(), as the lualib calls them
    "kotlin/coroutines/Continuation",
    "kotlin/collections/Iterator",
    // coroutine contexts are handled by the lualib's functions, which read the `key` field
    "kotlin/coroutines/CoroutineContext",
    "kotlin/coroutines/CoroutineContext.Element",
    "kotlin/coroutines/CoroutineContext.Key",
    "kotlin/coroutines/ContinuationInterceptor",
)

/** Types compared by value, whose `equals` can never be overridden. */
internal val IDENTITY_TYPES = setOf(
    "kotlin/Int", "kotlin/Long", "kotlin/Short", "kotlin/Byte", "kotlin/Double", "kotlin/Float",
    "kotlin/Boolean", "kotlin/Char", "kotlin/String", "kotlin/Unit", "kotlin/Nothing",
)

/** Collection kinds that `for` loops iterate directly. */
internal val ITERATED_KINDS =
    setOf(CollectionKind.List, CollectionKind.Array, CollectionKind.Set, CollectionKind.Iterable, CollectionKind.Range)

/** Name of the per-module table that collects exported declarations. */
internal const val EXPORTS = "____exports"

/** Name of the generated initializer method; constructors with a suffix append it (`____init1`). */
internal const val INIT = "____init"

/** Name of the generated companion-object initializer method. */
internal const val INIT_COMPANION = "____initCompanion"

/** Creates the entries of an enum class whose initialization is lazy. */
internal const val INIT_ENUM = "____initEnum"

/** lualib feature that implements the exception classes. */
internal const val EXCEPTIONS_FEATURE = "Exceptions"

internal const val ILLEGAL_ARGUMENT_EXCEPTION = "__K2L_IllegalArgumentException"
internal const val ILLEGAL_STATE_EXCEPTION = "__K2L_IllegalStateException"
internal const val NOT_IMPLEMENTED_ERROR = "__K2L_NotImplementedError"

/** Precondition function id to the exception it throws and its default message. */
internal val PRECONDITION_FAILURES = mapOf(
    "kotlin/require" to (ILLEGAL_ARGUMENT_EXCEPTION to "Failed requirement."),
    "kotlin/check" to (ILLEGAL_STATE_EXCEPTION to "Check failed."),
    "kotlin/requireNotNull" to (ILLEGAL_ARGUMENT_EXCEPTION to "Required value was null."),
    "kotlin/checkNotNull" to (ILLEGAL_STATE_EXCEPTION to "Required value was null."),
)
