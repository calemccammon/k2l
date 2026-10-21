package dev.k2l.transform

// The lualib features (`resources/dev/k2l/lualib/<Name>.lua`) the transformer loads by name, and the tables they define.

/** lualib feature that implements the exception classes. */
internal const val EXCEPTIONS_FEATURE = "Exceptions"

/** lualib feature with the abstract collection bases, see `AbstractCollections.lua`. */
internal const val ABSTRACT_COLLECTIONS_FEATURE = "AbstractCollections"

/** lualib feature with ArrayDeque and LinkedList, see `Deques.lua`. */
internal const val DEQUES_FEATURE = "Deques"

/** lualib feature with EnumMap and EnumSet, see `EnumCollections.lua`. */
internal const val ENUM_COLLECTIONS_FEATURE = "EnumCollections"

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

/** `--long64 emulate`: the 64-bit arithmetic (`Long64.lua`) and its less used operations (`Long64Ext.lua`). */
internal const val LONG64_FEATURE = "Long64"
internal const val LONG64_EXT = "Long64Ext"

/** Lua feature implementing `kotlin.time`, see `Duration.lua`. */
internal const val DURATION_FEATURE = "Duration"

/** Lua feature implementing `kotlin.time.Instant` and `Clock.System`, see `Instant.lua`. */
internal const val INSTANT_FEATURE = "Instant"

/** The lualib tables of `--strings utf16` (see `Utf16.lua` and `Utf16Case.lua`) and the general categories. */
internal const val UTF16_FEATURE = "Utf16"
internal const val UTF16_CASE_FEATURE = "Utf16Case"
internal const val UNICODE_CATEGORIES = "UnicodeCategories"

/** Lua feature implementing `kotlin.text.CharCategory`, see `CharCategory.lua`. */
internal const val CHAR_CATEGORY = "CharCategory"

/** The Unicode table for the categories of non-ASCII characters (`--strings utf16`), see `CharCategoryUnicode.lua`. */
internal const val CHAR_CATEGORY_UNICODE = "CharCategoryUnicode"

/** The Unicode table for the directionality of non-ASCII characters (`--strings utf16`), see `UnicodeDirectionality.lua`. */
internal const val UNICODE_DIRECTIONALITY = "UnicodeDirectionality"

/** Lua feature implementing `kotlin.text.HexFormat`, see `HexFormat.lua`. */
internal const val HEX_FORMAT = "HexFormat"

/** Lua feature implementing `java.util.Stack`'s own methods, `StringJoiner` and the helpers of `JavaUtil.lua`. */
internal const val JAVA_UTIL_FEATURE = "JavaUtil"

/** Lua feature of the target-independent `java.lang` number statics (`JavaNumbers.lua`). */
internal const val JAVA_NUMBERS_FEATURE = "JavaNumbers"

/** Lua feature of the `Long` statics whose arithmetic depends on the target (`JavaLongs.lua`, `.float`, `.l64`). */
internal const val JAVA_LONGS_FEATURE = "JavaLongs"

/** `java.util.BitSet`, see `BitSet.lua`. */
internal const val BITSET_FEATURE = "BitSet"

/** `java.util.stream`, see `Streams.lua`, and the summary statistics classes of `SummaryStatistics.lua`. */
internal const val STREAMS_FEATURE = "Streams"
internal const val STATISTICS_FEATURE = "SummaryStatistics"

internal const val PAIR_FEATURE = "Pair"

/** Lua feature implementing `kotlin.DeepRecursiveFunction` on a trampoline of coroutines, see `DeepRecursive.lua`. */
internal const val DEEP_RECURSIVE = "DeepRecursive"

/** Lua feature with the helpers of `Extras.lua`. */
internal const val EXTRAS_FEATURE = "Extras"

/** Lua feature with the helpers of `CollectionExtras.lua`. */
internal const val COLLECTION_EXTRAS = "CollectionExtras"

/** Lua feature with KotlinVersion and the library enums, see `KotlinMisc.lua`. */
internal const val KOTLIN_MISC = "KotlinMisc"

internal const val KCLASS_FEATURE = "KClass"

internal const val FUNCTION_REF_FEATURE = "FunctionRef"

/** A table of functions that a lualib [feature] defines, such as `__K2L_Num` of `Numbers.lua`. */
internal class LualibTable(val feature: String, val name: String)

internal val NUM_TABLE = LualibTable("Numbers", "__K2L_Num")
internal val TEXT_TABLE = LualibTable("Strings", "__K2L_Text")
internal val UNSIGNED_TABLE = LualibTable("Unsigned", "__K2L_Unsigned")
internal val RANDOM_TABLE = LualibTable("Random", "__K2L_Random")
internal val RANDOM_LONG_TABLE = LualibTable("RandomLong", "__K2L_RandomLong")
internal val REGEX_TABLE = LualibTable("Regex", "__K2L_Regex")
internal val PAIR_TABLE = LualibTable(PAIR_FEATURE, "__K2L_Pair")
internal val INT_RANGE_TABLE = LualibTable("Collections", "__K2L_IntRange")
internal val DURATION_TABLE = LualibTable(DURATION_FEATURE, "__K2L_Duration")
internal val DURATION_UNIT_TABLE = LualibTable(DURATION_FEATURE, "__K2L_DurationUnit")
internal val UTF16_TABLE = LualibTable(UTF16_FEATURE, "__K2L_Utf16")
internal val UTF16_CASE_TABLE = LualibTable(UTF16_CASE_FEATURE, "__K2L_Utf16Case")
internal val LONG64_TABLE = LualibTable(LONG64_FEATURE, "__K2L_Long64")
internal val LONG64_EXT_TABLE = LualibTable(LONG64_EXT, "__K2L_Long64X")
internal val JAVA_UTIL_TABLE = LualibTable(JAVA_UTIL_FEATURE, "__K2L_JavaUtil")
internal val JDK_COLLECTIONS_TABLE = LualibTable("JdkCollections", "__K2L_JdkCollections")
internal val JAVA_NUMBERS_TABLE = LualibTable(JAVA_NUMBERS_FEATURE, "__K2L_JavaNumbers")
internal val JAVA_LONGS_TABLE = LualibTable(JAVA_LONGS_FEATURE, "__K2L_JavaLongs")
internal val EXTRAS_TABLE = LualibTable(EXTRAS_FEATURE, "__K2L_Extras")
internal val COLLECTION_EXTRAS_TABLE = LualibTable(COLLECTION_EXTRAS, "__K2L_CollectionExtras")
internal val STREAMS_TABLE = LualibTable(STREAMS_FEATURE, "__K2L_Streams")
internal val BITSET_TABLE = LualibTable(BITSET_FEATURE, "__K2L_BitSet")
