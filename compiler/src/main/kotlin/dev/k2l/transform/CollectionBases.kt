package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.KtCallElement
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtDeclaration
import org.jetbrains.kotlin.psi.KtExpression

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
    base("__K2L_SortedMap", "java/util/TreeMap")
    base("__K2L_SortedSet", "java/util/TreeSet")
    base("__K2L_PriorityQueue", "java/util/PriorityQueue")
    base("__K2L_Deque", "java/util/ArrayDeque")
    base("__K2L_LinkedList", "java/util/LinkedList")
}

/** Bases with state of their own: a subclass's constructor has to run theirs. */
internal val CONCRETE_COLLECTION_BASES = setOf(
    "__K2L_List", "__K2L_Set", "__K2L_HashSet", "__K2L_Map", "__K2L_HashMap", "__K2L_SortedMap", "__K2L_SortedSet",
    "__K2L_PriorityQueue", "__K2L_Deque", "__K2L_LinkedList",
)

internal fun collectionBaseFeature(lua: String) = when (lua) {
    in DEQUE_CLASSES -> DEQUES_FEATURE
    in CONCRETE_COLLECTION_BASES -> "Collections"
    else -> ABSTRACT_COLLECTIONS_FEATURE
}

internal fun FileTransformer.collectionBaseRef(lua: String): LuaExpr = lualibRef(collectionBaseFeature(lua), lua)

/**
 * `class Stack : ArrayList<Int>(elements)`: the lualib constructor of a concrete base, with the collection, map or initial
 * capacity (which decides a HashMap's order) the JDK constructor takes first. Abstract bases have no state to initialize.
 */
internal fun FileTransformer.collectionSuperInit(call: KtCallElement?, lua: String): Unit = with(session) {
    if (lua !in CONCRETE_COLLECTION_BASES) return
    val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
    val values = resolved?.let { arguments(emptyList(), callArguments(it)) }.orEmpty()
    val types = resolved?.let { callArguments(it) }.orEmpty().map { it?.expressionType }
    val args = when {
        // LinkedHashMap(initialCapacity, loadFactor, accessOrder) keeps the access order
        lua == "__K2L_Map" && values.size == LINKED_MAP_ACCESS_ORDER_ARITY -> listOf(LuaNil, values[2])

        // PriorityQueue(initialCapacity, comparator): the capacity is not passed on (ArrayDeque(numElements)'s is)
        lua == "__K2L_PriorityQueue" ->
            values.zip(types).filter { (_, type) -> type?.isIntegral != true }.map { it.first }.take(1)

        else -> values.take(1)
    }
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
    if (name in STATIC_SUPER_METHODS) return LuaCall(LuaIndex(superRef, LuaString(name)), listOf(self) + arguments(emptyList(), args))
    val mapped = libraryCall(name, symbol.callableId?.toString(), null, self, superType, args, full)
    if (mapped is LuaMethodCall && mapped.target == self) {
        return LuaCall(LuaIndex(superRef, LuaString(mapped.method)), listOf(self) + mapped.args)
    }
    // `super.size` in a class overriding `size`: the library's field is stored as `____size` then (see __K2L_PropertyOverride)
    if (mapped is LuaIndex && mapped.target == self && (mapped.key as? LuaString)?.value == "size") {
        return LuaBinary(LuaBinOp.Or, luaCall(LuaName("rawget"), self, LuaString("____size")), mapped)
    }
    mapped
}

/**
 * Called on the superclass as they are: Any's members, and `iterator()` (that of a value is __K2L_IteratorOf, which would
 * call the override).
 */
private val STATIC_SUPER_METHODS = setOf("toString", "equals", "hashCode", "iterator")

/** Kotlin's read-only collection interfaces. */
private val READ_ONLY_INTERFACES = setOf(
    "kotlin/collections/Iterable",
    "kotlin/collections/Collection",
    "kotlin/collections/List",
    "kotlin/collections/Set",
    "kotlin/collections/Map",
)

/**
 * Whether [c] is a read-only Kotlin collection: it implements `List` (or another read-only collection interface) and no
 * mutable one, so on the JVM `is MutableList` is false for its objects and `as MutableList` fails.
 */
private fun FileTransformer.isReadOnlyCollection(c: KtClassOrObject): Boolean = with(session) {
    val symbol = c.symbol as? KaClassSymbol ?: return false
    val ids = symbol.defaultType.allSupertypes.mapNotNull { it.expandedSymbol?.classId?.asString() }.toSet()
    ids.any { it in READ_ONLY_INTERFACES } && ids.none { it in MUTABLE_INTERFACES }
}

/** Members of a library collection that the JDK's and the stdlib's operations call, see `CollectionOverrides.lua`. */
private val HOOK_MEMBERS = setOf(
    "size", "iterator", "get", "contains", "isEmpty", "indexOf", "listIterator", "entries", "keys", "values", "containsKey",
)

private fun overriddenName(d: KtDeclaration): String? = if (d.hasModifier(KtTokens.OVERRIDE_KEYWORD)) d.name else null

/** The names of the members [c] (or a superclass of the program) overrides, of those the library's operations call. */
private fun FileTransformer.overriddenHooks(c: KtClassOrObject): Set<String> {
    val own: List<String> = c.declarations.mapNotNull { overriddenName(it) }
        .filter { it in HOOK_MEMBERS }
    return own.toSet() + (classes.superInfo(c).base?.let { overriddenHooks(it) }.orEmpty())
}

/**
 * `__K2L_HonorOverrides(C, base)` for a class extending a library collection that overrides a member the library's
 * operations call (size, iterator(), get, entries, ...): the class gets versions of those operations that call it where the
 * JVM does. Only such classes do, so plain collections keep their fast paths.
 */
internal fun FileTransformer.collectionOverrides(c: KtClassOrObject, ref: LuaExpr) {
    val base = classes.collectionBaseOf(c)?.takeIf { it in CONCRETE_COLLECTION_BASES } ?: return
    if (c.declarations.none { overriddenName(it) in HOOK_MEMBERS }) return
    emit(LuaCallStmt(LuaCall(lualibRef("CollectionOverrides", "__K2L_HonorOverrides"), listOf(ref, collectionBaseRef(base)))))
}

/** Whether values of [c] are walked with their own iterator(): it extends a library collection and overrides iterator(). */
internal fun FileTransformer.iteratesItself(c: KtClassOrObject): Boolean =
    classes.collectionBaseOf(c) in CONCRETE_COLLECTION_BASES && "iterator" in overriddenHooks(c)

/** `C.____readOnly = true` for a read-only collection class (false again in a mutable subclass of one), see MUTABLE_INTERFACES. */
internal fun FileTransformer.readOnlyFlag(c: KtClassOrObject, ref: LuaExpr) {
    val readOnly = isReadOnlyCollection(c)
    val inherited = classes.superInfo(c).base?.let { isReadOnlyCollection(it) } ?: false
    if (readOnly != inherited) emit(assign(LuaIndex(ref, LuaString("____readOnly")), LuaBool(readOnly)))
}
