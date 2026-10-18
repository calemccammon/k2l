package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

/** Lua feature implementing lazy sequences, iterators and the `sequence { }` builder, see `Sequence.lua`. */
internal const val SEQUENCE_FEATURE = "Sequence"

/** Lazy `kotlin.sequences`: sources, `Sequence` operations (methods of `__K2L_Sequence`) and iterators. */
internal object SequenceMappings {
    /** Sequence operations implemented as methods of the same name. */
    private val SEQUENCE_METHODS = setOf(
        "map", "mapIndexed", "mapNotNull", "mapIndexedNotNull", "withIndex", "filter", "filterNot", "filterIndexed",
        "filterNotNull", "flatMap", "flatten", "take", "drop", "takeWhile", "dropWhile", "distinct", "distinctBy", "onEach",
        "onEachIndexed", "zip", "zipWithNext", "windowed", "chunked", "runningFold", "scan", "runningReduce", "ifEmpty",
        "sorted", "sortedDescending", "sortedBy", "sortedByDescending", "sortedWith", "constrainOnce", "asSequence",
        "toList", "toMutableList", "toSet", "toMutableSet", "toHashSet", "forEachIndexed", "fold", "foldIndexed", "reduce",
        "first", "firstOrNull", "find", "last", "lastOrNull", "findLast", "single", "singleOrNull", "elementAt",
        "elementAtOrNull", "indexOf", "indexOfFirst", "contains", "any", "all", "none", "count", "average", "max", "min",
        "maxOrNull", "minOrNull", "maxBy", "minBy", "maxByOrNull", "minByOrNull", "maxOf", "minOf", "maxOfOrNull",
        "minOfOrNull", "joinToString", "groupBy", "associate", "associateBy", "associateWith", "toMap", "partition", "iterator",
    )

    private val ASSEQUENCE_IDS = setOf("kotlin/collections/asSequence", "kotlin/sequences/asSequence", "kotlin/text/asSequence")

    fun map(callableId: String?, site: CallSite): LuaExpr? = source(callableId, site) ?: byReceiver(site)

    private fun CallSite.call(name: String, vararg args: LuaExpr): LuaExpr = LuaCall(ref(SEQUENCE_FEATURE, name), args.toList())

    private fun source(callableId: String?, site: CallSite): LuaExpr? = with(site) {
        when (callableId) {
            "kotlin/sequences/sequenceOf", "kotlin/sequences/emptySequence" -> call("__K2L_SequenceOf", *args.toTypedArray())
            "kotlin/sequences/generateSequence" -> generateSequence(site)
            "kotlin/sequences/sequence" -> call("__K2L_SequenceBuilder", arg(0))
            "kotlin/sequences/iterator" -> call("__K2L_IteratorBuilder", arg(0))
            "kotlin/sequences/Sequence" -> call("__K2L_SequenceFromIterator", arg(0))
            "kotlin/sequences/SequenceScope.yield" -> LuaMethodCall(self, "yield", args)
            "kotlin/sequences/SequenceScope.yieldAll" -> LuaMethodCall(self, "yieldAll", args)
            in ASSEQUENCE_IDS -> if (receiverKind() == CollectionKind.Sequence) self else call("__K2L_AsSequence", self)
            else -> null
        }
    }

    /** `generateSequence(seed) { }`, `generateSequence({ seed }) { }` and the single-use `generateSequence { }`. */
    private fun generateSequence(site: CallSite): LuaExpr = with(site) {
        if (args.size == 2 && argTypes[0] !is KaFunctionType) {
            call("__K2L_GenerateSequence", *args.toTypedArray())
        } else {
            call("__K2L_GenerateSequenceLazy", *args.toTypedArray())
        }
    }

    private fun CallSite.receiverKind(): CollectionKind? = receiverType?.let { with(session) { it.collectionKind() } }

    private fun byReceiver(site: CallSite): LuaExpr? {
        val name = site.name ?: return null
        return when (site.receiverKind()) {
            CollectionKind.Sequence -> sequenceMember(name, site)

            CollectionKind.Iterator -> if (name == "hasNext" || name == "next") LuaMethodCall(site.self, name, emptyList()) else null

            CollectionKind.List, CollectionKind.Array, CollectionKind.Set, CollectionKind.Iterable, CollectionKind.Range ->
                if (name == "iterator" && site.args.isEmpty()) site.call("__K2L_IteratorOf", site.self) else null

            else -> null
        }
    }

    private fun sequenceMember(name: String, site: CallSite): LuaExpr? = with(site) {
        val elementType = with(session) { receiverType?.elementType }
        when (name) {
            "sum" -> LuaMethodCall(self, "sum", zeroFor(site, elementType))
            "sumOf" -> LuaMethodCall(self, "sumOf", args + zeroFor(site, (argTypes.getOrNull(0) as? KaFunctionType)?.returnType))
            "plus", "minus" -> LuaMethodCall(self, if (isElements(site, argTypes.getOrNull(0), elementType)) name + "All" else name, args)
            "plusElement", "minusElement" -> LuaMethodCall(self, name.removeSuffix("Element"), args)
            else -> if (name in SEQUENCE_METHODS) LuaMethodCall(self, name, args) else null
        }
    }

    /** Whether a `plus`/`minus` argument is a group of elements rather than one element. */
    private fun isElements(site: CallSite, argType: KaType?, elementType: KaType?): Boolean = with(site.session) {
        val kind = argType?.collectionKind() ?: return false
        val groups = setOf(
            CollectionKind.List,
            CollectionKind.Array,
            CollectionKind.Set,
            CollectionKind.Iterable,
            CollectionKind.Range,
            CollectionKind.Sequence,
        )
        kind in groups && elementType?.collectionKind() == null
    }

    private fun zeroFor(site: CallSite, type: KaType?): List<LuaExpr> = with(site.session) {
        if (type != null && (type.isDoubleType || type.isFloatType)) listOf(LuaNumber("0.0")) else emptyList()
    }
}
