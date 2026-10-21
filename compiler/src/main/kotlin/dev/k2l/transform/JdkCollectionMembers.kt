package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/**
 * Members of the JDK's collection classes that Kotlin's collection interfaces lack (`clone()`, `comparator()`,
 * `removeLastOccurrence`, `ensureCapacity`, `toArray`, the JDK 19 `HashMap.newHashMap` factories, JDK 21's
 * `LinkedHashMap.putLast` and `sequencedKeySet`), and `java.util.Arrays.compare`/`mismatch`; see `JdkCollections.lua`.
 */
internal object JdkCollectionMembers {
    private val CLONEABLE = setOf(
        "ArrayList", "LinkedList", "ArrayDeque", "HashMap", "LinkedHashMap", "TreeMap", "HashSet", "LinkedHashSet", "TreeSet",
    )

    private val SORTED = setOf("TreeMap", "TreeSet", "PriorityQueue")

    /** `HashMap.newHashMap(n)` and the like: the class they make. */
    private val FACTORIES = mapOf(
        "newHashMap" to "java/util/HashMap",
        "newHashSet" to "java/util/HashSet",
        "newLinkedHashMap" to "java/util/LinkedHashMap",
        "newLinkedHashSet" to "java/util/LinkedHashSet",
    )

    /** The views of JDK 21's sequenced collections that are the plain ones here. */
    private val SEQUENCED = mapOf("sequencedKeySet" to "getKeys", "sequencedValues" to "getValues", "sequencedEntrySet" to "getEntries")

    private const val REPLACE_IF_ARITY = 3

    private fun isMap(site: CallSite) = site.receiverKind == CollectionKind.Map

    private fun isArray(site: CallSite) =
        with(site.session) { (site.argTypes[0]?.withoutFlexibility as? KaClassType)?.classId?.asString() == "kotlin/Array" }

    private fun CallSite.lib(member: String, vararg args: LuaExpr) = libMember(JDK_COLLECTIONS_TABLE, member, *args)

    fun map(callableId: String, name: String, site: CallSite): LuaExpr? {
        // the classes of java.util itself, not of its subpackages (java.util.stream has a toArray of its own)
        val owner = callableId.removePrefix("java/util/").substringBefore('.').takeIf { '/' !in it } ?: return null
        if (site.receiver == null) {
            val classId = FACTORIES[name] ?: return null
            return LibraryConstructors.reference(
                classId,
                CallSite(site.session, site.transformer, site.element, null, null, null, emptyList(), emptyList()),
            )
        }
        return copies(owner, name, site) ?: removals(owner, name, site) ?: maps(owner, name, site)
    }

    /** `clone()`, `comparator()`, `toArray()` and the capacity hints, which keep nothing. */
    private fun copies(owner: String, name: String, site: CallSite): LuaExpr? = when {
        name == "clone" && owner in CLONEABLE && site.args.isEmpty() -> site.lib("clone", site.self)

        name == "clone" && owner == "EnumSet" -> site.libMember(ENUM_COLLECTIONS_FEATURE, "__K2L_EnumSets", "copyOf", site.self)

        name == "clone" && owner == "EnumMap" ->
            site.libNew(ENUM_COLLECTIONS_FEATURE, "__K2L_EnumMap", listOf(site.self))

        name == "comparator" && owner in SORTED -> site.lib("comparator", site.self)

        name == "ensureCapacity" || name == "trimToSize" -> site.lib("identity", site.self)

        name == "toArray" && site.args.isEmpty() -> method(site.self, "toTypedArray")

        // toArray(array): into the array when it is long enough, else into a new one of its type
        name == "toArray" && site.args.size == 1 && isArray(site) -> site.lib("toArray", site.self, site.arg(0))

        else -> null
    }

    private fun removals(owner: String, name: String, site: CallSite): LuaExpr? = when {
        owner != "ArrayDeque" && owner != "LinkedList" -> null
        name == "removeFirstOccurrence" -> method(site.self, "remove", site.arg(0))
        name == "removeLastOccurrence" -> site.lib("removeLastOccurrence", site.self, site.arg(0))
        else -> null
    }

    private fun maps(owner: String, name: String, site: CallSite): LuaExpr? = when {
        name in SEQUENCED && owner == "LinkedHashMap" -> method(site.self, SEQUENCED.getValue(name))

        name == "replace" && site.args.size == 2 && isMap(site) -> site.lib("replace", site.self, site.arg(0), site.arg(1))

        name == "replace" && site.args.size == REPLACE_IF_ARITY && isMap(site) ->
            site.lib("replaceIf", site.self, site.arg(0), site.arg(1), site.arg(2))

        name == "putLast" && owner == "LinkedHashMap" -> site.lib("putLast", site.self, site.arg(0), site.arg(1))

        // a TreeMap's order is its comparator's
        (name == "putFirst" || name == "putLast") && owner == "TreeMap" -> site.lib("unsupported")

        else -> null
    }

    /** `Arrays.compare(a, b)`, `compareUnsigned` and `mismatch`, also over ranges and with a comparator: told the element kind. */
    fun arrays(name: String, site: CallSite): LuaExpr? {
        val classId = with(site.session) { (site.argTypes.firstOrNull()?.withoutFlexibility as? KaClassType)?.classId?.asString() }
        val kind = classId?.removePrefix("kotlin/")?.removeSuffix("Array")?.takeIf { it != "" } ?: "Object"
        return when (name) {
            "compare", "compareUnsigned", "mismatch" -> site.lib(name + "Arrays", LuaString(kind), *site.args.toTypedArray())
            "parallelSort" -> site.lib("sort_array", *site.args.toTypedArray())
            "parallelSetAll" -> site.lib("setAll", *site.args.toTypedArray())
            "parallelPrefix" -> site.lib("parallelPrefix", *site.args.toTypedArray())
            else -> null
        }
    }
}
