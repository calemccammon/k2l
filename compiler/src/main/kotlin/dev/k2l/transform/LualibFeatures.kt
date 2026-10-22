package dev.k2l.transform

// The lualib features (`resources/dev/k2l/lualib/<Name>.lua`) the transformer loads by name, and the tables they define.

/** lualib feature that implements the exception classes. */
internal const val EXCEPTIONS_FEATURE = "Exceptions"

/** lualib feature with the abstract collection bases, see `AbstractCollections.lua`. */
internal const val ABSTRACT_COLLECTIONS_FEATURE = "AbstractCollections"

/** lualib feature with ArrayDeque and LinkedList, see `Deques.lua`. */
internal const val DEQUES_FEATURE = "Deques"

/** Lua feature implementing lazy sequences, iterators and the `sequence { }` builder, see `Sequence.lua`. */
internal const val SEQUENCE_FEATURE = "Sequence"

/** Lua feature implementing `kotlin.coroutines` on Lua coroutines, see `Coroutines.lua`. */
internal const val COROUTINES_FEATURE = "Coroutines"

/** Lua feature implementing `kotlin.Result`, see `Result.lua`. */
internal const val RESULT_FEATURE = "Result"

/** Lualib feature with the mixins of library SAM interfaces, see `SamInterfaces.lua`. */
internal const val SAM_FEATURE = "SamInterfaces"

/** Lualib feature with the source-map runtime: Lua positions in tracebacks rewritten to Kotlin ones. */
internal const val SOURCE_MAP_FEATURE = "SourceMap"

internal const val PAIR_FEATURE = "Pair"

/** Lua feature with the helpers of `Extras.lua`. */
internal const val EXTRAS_FEATURE = "Extras"

/** Lua feature with the helpers of `CollectionExtras.lua`. */
internal const val COLLECTION_EXTRAS = "CollectionExtras"

/** Lua feature with KotlinVersion and the library enums, see `KotlinMisc.lua`. */
internal const val KOTLIN_MISC = "KotlinMisc"

/** lualib feature with the marker of a null argument for a parameter whose default is not null, see `NullArgument.lua`. */
internal const val NULL_ARGUMENT_FEATURE = "NullArgument"

/** A table of functions that a lualib [feature] defines, such as `__K2L_Num` of `Numbers.lua`. */
internal class LualibTable(val feature: String, val name: String)

internal val NUM_TABLE = LualibTable("Numbers", "__K2L_Num")
internal val TEXT_TABLE = LualibTable("Strings", "__K2L_Text")
internal val RANDOM_TABLE = LualibTable("Random", "__K2L_Random")
internal val REGEX_TABLE = LualibTable("Regex", "__K2L_Regex")
internal val PAIR_TABLE = LualibTable(PAIR_FEATURE, "__K2L_Pair")
internal val INT_RANGE_TABLE = LualibTable("Collections", "__K2L_IntRange")
internal val EXTRAS_TABLE = LualibTable(EXTRAS_FEATURE, "__K2L_Extras")
internal val COLLECTION_EXTRAS_TABLE = LualibTable(COLLECTION_EXTRAS, "__K2L_CollectionExtras")
