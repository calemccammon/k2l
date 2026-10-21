package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

private fun CallSite.extra(member: String, vararg args: LuaExpr): LuaExpr = libMember(COLLECTION_EXTRAS_TABLE, member, *args)

/** `setOfNotNull(...)`, and `reduceRightOrNull`, `reduceRightIndexed` and `reduceRightIndexedOrNull` of a list or array. */
private fun listExtras(callableId: String?, site: CallSite): LuaExpr? = when (callableId) {
    "kotlin/collections/setOfNotNull" -> notNullSet(site)

    "kotlin/collections/reduceRightOrNull", "kotlin/collections/reduceRightIndexed", "kotlin/collections/reduceRightIndexedOrNull" ->
        listReduceRight(callableId, site)

    else -> null
}

private fun listReduceRight(callableId: String, site: CallSite): LuaExpr? = with(site) {
    val kind = receiverKind
    if (receiver == null || (kind != CollectionKind.List && kind != CollectionKind.Array)) return null
    val indexed = LuaBool("Indexed" in callableId)
    val orNull = LuaBool(callableId.endsWith("OrNull"))
    extrasMember("reduceRight", self, arg(0), indexed, orNull, LuaString(if (kind == CollectionKind.Array) "array" else "list"))
}

private fun notNullSet(site: CallSite): LuaExpr {
    val list = LuaCall(site.ref(featureOf("__K2L_ListOf"), "__K2L_ListOf"), site.args)
    return LuaMethodCall(LuaMethodCall(list, "filterNotNull", emptyList()), "toSet", emptyList())
}

/**
 * More of `kotlin.collections`, `kotlin.sequences` and `kotlin.text`: `isSorted` and friends, Grouping's `eachCountTo`,
 * `foldTo`, `reduceTo` and `aggregateTo`, `Map.onEachIndexed`/`mapTo`/`filterNotTo`, `Iterator.withIndex`, `IndexedValue`,
 * `Sequence.unzip`, `setOfNotNull`, a list's or array's `reduceRightOrNull` and friends, and CharSequence's `findAnyOf`, `findLastAnyOf`, `lastIndexOfAny`, `filterTo`, `onEachIndexed`, the
 * right-to-left reductions, `replaceIndent` and `replaceIndentByMargin`.
 */
internal object CollectionExtrasMappings {
    private val IS_SORTED = mapOf(
        "isSorted" to "",
        "isSortedDescending" to "Descending",
        "isSortedBy" to "By",
        "isSortedByDescending" to "ByDescending",
        "isSortedWith" to "With",
    )

    private val GROUPING_TO = setOf("eachCountTo", "foldTo", "reduceTo", "aggregateTo")

    /** `nextInt()` and friends of the primitive iterators are `next()`. */
    private val PRIMITIVE_NEXT = setOf("nextBoolean", "nextByte", "nextShort", "nextChar", "nextInt", "nextLong", "nextFloat", "nextDouble")

    private val REDUCE_RIGHT = setOf("reduceRightOrNull", "reduceRightIndexed", "reduceRightIndexedOrNull")

    /** `append(csq, start, end)` and `appendRange(value, start, end)`. */
    private const val RANGE_ARGUMENTS = 3

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        listExtras(callableId, site)?.let { return it }
        val receiver = site.receiver
        if (callableId == null || receiver == null) return null
        val kind = site.receiverKind
        val name = callableId.substringAfterLast('/')
        return when {
            site.isClass(site.receiverType, "java/lang/Appendable") -> appendable(name, site)

            callableId.startsWith("kotlin/text/") && kind == null && site.isTextual(site.receiverType) && !site.isChar(site.receiverType) ->
                text(name, site)

            callableId.startsWith("kotlin/collections/") || callableId.startsWith("kotlin/sequences/") ->
                collection(kind, name, site, receiver)

            else -> null
        }
    }

    private fun collection(kind: CollectionKind?, name: String, site: CallSite, receiver: LuaExpr): LuaExpr? = when {
        name in IS_SORTED -> site.extra("isSorted", receiver, LuaString(IS_SORTED.getValue(name)), *site.args.toTypedArray())

        kind == CollectionKind.Grouping -> grouping(name, site)

        kind == CollectionKind.Map -> mapMember(name, site)

        kind == CollectionKind.Iterator && site.name in PRIMITIVE_NEXT -> LuaMethodCall(receiver, "next", emptyList())

        kind == CollectionKind.Iterator && name == "withIndex" -> site.extra("withIndex", receiver)

        kind == CollectionKind.IndexedValue && name == "IndexedValue.copy" -> site.extra("copyIndexed", receiver, *site.args.toTypedArray())

        kind == CollectionKind.IndexedValue && name == "IndexedValue.hashCode" -> site.lualib("Hash", receiver)

        kind == CollectionKind.Sequence && name == "unzip" -> LuaMethodCall(
            LuaMethodCall(receiver, "toList", emptyList()),
            "unzip",
            emptyList(),
        )

        else -> null
    }

    /** `IndexedValue(index, value)`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? = if (classId == "kotlin/collections/IndexedValue") {
        site.libNew("Collections", "__K2L_IndexedValue", site.args)
    } else {
        null
    }

    private fun grouping(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "Grouping.keyOf" -> LuaCall(LuaIndex(self, LuaString("keySelector")), args)

            "Grouping.sourceIterator" -> extra("sourceIterator", self)

            // foldTo(destination, initialValueSelector, operation) or foldTo(destination, initialValue, operation)
            "foldTo" -> extra("foldTo", self, arg(0), arg(1), arg(2), LuaBool(overloadType(1) is KaFunctionType))

            in GROUPING_TO -> extra(name, self, *args.toTypedArray())

            else -> null
        }
    }

    private fun mapMember(name: String, site: CallSite): LuaExpr? = when (name) {
        "onEachIndexed", "mapTo", "filterNotTo" -> site.extra(name, site.self, *site.args.toTypedArray())
        else -> null
    }

    /**
     * `Appendable.append(value)`, `append(csq, start, end)`, `appendLine(value)` and `appendRange(value, start, end)` on an
     * Appendable such as a StringBuilder: its `append` with a string.
     */
    private fun appendable(name: String, site: CallSite): LuaExpr? = with(site) {
        fun text(i: Int) = str(arg(i), argTypes.getOrNull(i))
        fun range(i: Int): LuaExpr? = StdlibMappings.map(
            "kotlin/text/substring",
            CallSite(
                session,
                transformer,
                element,
                "substring",
                arg(i),
                session.builtinTypes.string,
                args.drop(i + 1),
                argTypes.drop(i + 1),
            ),
        )
        when {
            name == "Appendable.append" && args.size == 1 -> LuaMethodCall(self, "append", listOf(text(0)))

            (name == "Appendable.append" || name == "appendRange") && args.size == RANGE_ARGUMENTS -> range(0)?.let {
                LuaMethodCall(self, "append", listOf(it))
            }

            // kotlin.text's `append(vararg value)`
            name == "append" -> args.indices.fold(self) { out, i -> LuaMethodCall(out, "append", listOf(text(i))) }

            name == "appendLine" && args.isEmpty() -> LuaMethodCall(self, "append", listOf(LuaString("\n")))

            name == "appendLine" && args.size == 1 ->
                LuaMethodCall(LuaMethodCall(self, "append", listOf(text(0))), "append", listOf(LuaString("\n")))

            else -> null
        }
    }

    private fun CallSite.isClass(type: KaType?, classId: String): Boolean =
        type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() } == classId

    /** The characters of a string as a list. */
    private fun CallSite.chars(text: LuaExpr): LuaExpr = if (utf16) {
        requireUtf16()
        libMember(TEXT_TABLE, "toList", text)
    } else {
        LuaCall(ref("Strings", "__K2L_StringToList"), listOf(text))
    }

    private fun text(name: String, site: CallSite): LuaExpr? = with(site) {
        fun at(i: Int) = args.getOrElse(i) { LuaNil }
        // ignoreCase needs the Unicode case folding of --strings utf16
        if (at(2) != LuaNil && at(2) != LuaBool(false)) requireUtf16Case()
        when (name) {
            "findAnyOf", "findLastAnyOf" -> extra("findAnyOf", self, arg(0), at(1), at(2), LuaBool(name == "findLastAnyOf"))

            "lastIndexOfAny" -> extra("lastIndexOfAny", self, arg(0), at(1), at(2))

            "filterTo" -> extra("filterCharsTo", chars(self), arg(0), arg(1))

            "onEachIndexed" -> {
                val text = transformer.cache(self, "text")
                extra("onEachIndexedChars", text, chars(text), arg(0))
            }

            in REDUCE_RIGHT -> libMember(
                "Extras",
                "__K2L_Extras",
                "reduceRight",
                chars(self),
                arg(0),
                LuaBool("Indexed" in name),
                LuaBool(name.endsWith("OrNull")),
                LuaString("char sequence"),
            )

            "hasSurrogatePairAt" -> extra("hasSurrogatePairAt", self, arg(0), if (utf16) ref(UTF16_TABLE) else LuaNil)

            "replaceIndent" -> extra("replaceIndent", self, at(0))

            "replaceIndentByMargin" -> extra("replaceIndentByMargin", self, at(0), at(1))

            else -> null
        }
    }
}
