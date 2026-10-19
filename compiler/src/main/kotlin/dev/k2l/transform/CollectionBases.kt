package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtCallElement
import org.jetbrains.kotlin.psi.KtExpression

/** lualib feature with the abstract collection bases, see `AbstractCollections.lua`. */
internal const val ABSTRACT_COLLECTIONS_FEATURE = "AbstractCollections"

private const val ABSTRACT_COLLECTION = "__K2L_AbstractCollection"
private const val ABSTRACT_LIST = "__K2L_AbstractList"
private const val ABSTRACT_SET = "__K2L_AbstractSet"
private const val ABSTRACT_MAP = "__K2L_AbstractMap"

/**
 * Library collection classes a program's class can extend, and collection interfaces it can implement, by ClassId: the
 * lualib class its table extends. Abstract classes get the abstract bases, which implement every operation in terms of the
 * members the class provides; interfaces get the same bases with Any's toString, equals and hashCode (an interface has no
 * implementation of them); the open JDK classes are the lualib collections themselves.
 */
internal val COLLECTION_BASES: Map<String, String> = buildMap {
    fun base(lua: String, vararg ids: String) = ids.forEach { put(it, lua) }
    base("__K2L_IterableBase", "kotlin/collections/Iterable", "kotlin/collections/MutableIterable", "java/lang/Iterable")
    base("__K2L_CollectionBase", "kotlin/collections/Collection", "kotlin/collections/MutableCollection", "java/util/Collection")
    base("__K2L_ListBase", "kotlin/collections/List", "kotlin/collections/MutableList", "java/util/List")
    base("__K2L_SetBase", "kotlin/collections/Set", "kotlin/collections/MutableSet", "java/util/Set")
    base("__K2L_MapBase", "kotlin/collections/Map", "kotlin/collections/MutableMap", "java/util/Map")
    base(
        ABSTRACT_COLLECTION,
        "kotlin/collections/AbstractCollection",
        "kotlin/collections/AbstractMutableCollection",
        "java/util/AbstractCollection",
    )
    base(ABSTRACT_LIST, "kotlin/collections/AbstractList", "kotlin/collections/AbstractMutableList", "java/util/AbstractList")
    base(ABSTRACT_SET, "kotlin/collections/AbstractSet", "kotlin/collections/AbstractMutableSet", "java/util/AbstractSet")
    base(ABSTRACT_MAP, "kotlin/collections/AbstractMap", "kotlin/collections/AbstractMutableMap", "java/util/AbstractMap")
    base("__K2L_AbstractIterator", "kotlin/collections/AbstractIterator")
    base("__K2L_List", "java/util/ArrayList")
    base("__K2L_Set", "java/util/LinkedHashSet")
    base("__K2L_HashSet", "java/util/HashSet")
    base("__K2L_Map", "java/util/LinkedHashMap")
    base("__K2L_HashMap", "java/util/HashMap")
}

/** Bases with state of their own: a subclass's constructor has to run theirs. */
internal val CONCRETE_COLLECTION_BASES = setOf("__K2L_List", "__K2L_Set", "__K2L_HashSet", "__K2L_Map", "__K2L_HashMap")

internal fun collectionBaseFeature(lua: String) = if (lua in CONCRETE_COLLECTION_BASES) "Collections" else ABSTRACT_COLLECTIONS_FEATURE

internal fun FileTransformer.collectionBaseRef(lua: String): LuaExpr = lualibRef(collectionBaseFeature(lua), lua)

/**
 * `class Stack : ArrayList<Int>(elements)`: the lualib constructor of a concrete base, with the collection, map or initial
 * capacity (which decides a HashMap's order) the JDK constructor takes first. Abstract bases have no state to initialize.
 */
internal fun FileTransformer.collectionSuperInit(call: KtCallElement?, lua: String): Unit = with(session) {
    if (lua !in CONCRETE_COLLECTION_BASES) return
    val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
    val values = resolved?.let { arguments(emptyList(), callArguments(it)) }.orEmpty()
    // LinkedHashMap(initialCapacity, loadFactor, accessOrder) keeps the access order
    val args = if (lua == "__K2L_Map" && values.size == LINKED_MAP_ACCESS_ORDER_ARITY) listOf(LuaNil, values[2]) else values.take(1)
    emit(LuaCallStmt(LuaCall(LuaIndex(collectionBaseRef(lua), LuaString(INIT)), listOf(selfRef()) + args)))
}

/**
 * `super.add(x)`, `super.get(i)`, `super.toString()` in a class extending a library collection: the library member is
 * the lualib method of the superclass, called statically. The call is mapped as if it were `this.add(x)` on the
 * superclass type [superType]; a method call on `self` becomes a call of the superclass's function.
 */
internal fun FileTransformer.collectionSuperCall(
    symbol: KaCallableSymbol,
    args: List<KtExpression?>,
    superType: KaType?,
    full: KtExpression,
): LuaExpr? = with(session) {
    val c = currentClass ?: return null
    val info = classes.superInfo(c)
    val superRef = info.base?.takeIf { classes.collectionBaseOf(it) != null }?.let(::classRef)
        ?: info.collectionBase?.let { collectionBaseRef(it) }
        ?: return null
    val name = symbol.callableId?.callableName?.asString() ?: return null
    if (symbol.callableId?.classId?.asString() == "kotlin/Any") return null
    val self = selfRef()
    if (name in OBJECT_METHODS) return LuaCall(LuaIndex(superRef, LuaString(name)), listOf(self) + arguments(emptyList(), args))
    val mapped = libraryCall(name, symbol.callableId?.toString(), null, self, superType, args, full)
    if (mapped is LuaMethodCall && mapped.target == self) {
        return LuaCall(LuaIndex(superRef, LuaString(mapped.method)), listOf(self) + mapped.args)
    }
    mapped
}

private val OBJECT_METHODS = setOf("toString", "equals", "hashCode")
