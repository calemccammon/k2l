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
    "java/lang/Iterable.forEach", "java/util/Map.forEach", "kotlin/text/forEach", "kotlin/text/forEachIndexed",
    "kotlin/collections/buildList", "kotlin/collections/buildMap", "kotlin/collections/buildSet",
)

/**
 * The exceptions of `String.format` (java.util.Formatter): they can be caught and type-checked, and `message` reads the JDK's
 * text. Their constructors (which build that text from a conversion or flags) are not mapped.
 */
internal val FORMATTER_EXCEPTIONS = listOf(
    "IllegalFormatException",
    "MissingFormatArgumentException",
    "UnknownFormatConversionException",
    "MissingFormatWidthException",
    "IllegalFormatConversionException",
    "IllegalFormatPrecisionException",
    "FormatFlagsConversionMismatchException",
)

/** Library classes implemented by lualib, by ClassId (JVM typealiases expand to java.lang classes). */
internal val LIBRARY_CLASSES = listOf(
    "Throwable", "Exception", "Error", "RuntimeException", "IllegalArgumentException", "IllegalStateException",
    "NullPointerException", "IndexOutOfBoundsException", "ArithmeticException", "UnsupportedOperationException",
    "ClassCastException", "NumberFormatException", "VirtualMachineError", "StackOverflowError",
).flatMap { listOf("java/lang/$it" to "__K2L_$it", "kotlin/$it" to "__K2L_$it") }.toMap() + mapOf(
    "kotlin/Throwable" to "__K2L_Throwable",
    "java/util/NoSuchElementException" to "__K2L_NoSuchElementException",
    "kotlin/NoSuchElementException" to "__K2L_NoSuchElementException",
    "java/util/ConcurrentModificationException" to "__K2L_ConcurrentModificationException",
    "kotlin/ConcurrentModificationException" to "__K2L_ConcurrentModificationException",
    "kotlin/NotImplementedError" to "__K2L_NotImplementedError",
    "kotlin/UninitializedPropertyAccessException" to "__K2L_UninitializedPropertyAccessException",
    "java/lang/ArrayIndexOutOfBoundsException" to "__K2L_ArrayIndexOutOfBoundsException",
    "java/util/regex/PatternSyntaxException" to "__K2L_PatternSyntaxException",
) + FORMATTER_EXCEPTIONS.associate { "java/util/$it" to "__K2L_$it" }

/** Library supertypes that need no runtime support (Comparable is honored via compareTo). */
internal val MARKER_INTERFACES = setOf(
    "kotlin/Any",
    "kotlin/Comparable",
    // its members are the class's own; library text functions read its chars (see CharSequences.kt)
    "kotlin/CharSequence",
    "java/lang/Comparable",
    "java/io/Serializable",
    "java/io/Closeable",
    "java/lang/AutoCloseable",
    "kotlin/properties/ReadWriteProperty",
    "kotlin/properties/ReadOnlyProperty",
    // implemented by objects with resumeWith()/hasNext()/next(), as the lualib calls them
    "kotlin/coroutines/Continuation",
    "kotlin/collections/Iterator",
    "kotlin/collections/MutableIterator",
    "kotlin/collections/ListIterator",
    "kotlin/collections/MutableListIterator",
    "java/util/Iterator",
    "java/util/RandomAccess",
    // read through their key and value fields
    "kotlin/collections/Map.Entry",
    "kotlin/collections/MutableMap.MutableEntry",
    // coroutine contexts are handled by the lualib's functions, which read the `key` field
    "kotlin/coroutines/CoroutineContext",
    "kotlin/coroutines/CoroutineContext.Element",
    "kotlin/coroutines/CoroutineContext.Key",
    "kotlin/coroutines/ContinuationInterceptor",
)

/**
 * Kotlin's mutable collection interfaces: on the JVM `is MutableList` is false for the read-only collections of the
 * Kotlin stdlib (EmptyList, ...) and classes implementing only `List`; their lualib classes have `____readOnly` set.
 */
internal val MUTABLE_INTERFACES = setOf(
    "kotlin/collections/MutableList",
    "kotlin/collections/MutableSet",
    "kotlin/collections/MutableMap",
    "kotlin/collections/MutableCollection",
    "kotlin/collections/MutableIterable",
)

/** `Collection` types, which an `is` check tells apart from other Iterables by their `size`. */
internal val COLLECTION_INTERFACES = setOf("kotlin/collections/Collection", "kotlin/collections/MutableCollection", "java/util/Collection")

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

/** Library types whose `is` test is a lualib function of `TypeChecks.lua` (they have no lualib class to test against). */
internal val TYPE_CHECKS = mapOf(
    "kotlin/Number" to "__K2L_IsNumber",
    "kotlin/Comparable" to "__K2L_IsComparable",
    "kotlin/CharSequence" to "__K2L_IsCharSequence",
)
