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
import org.jetbrains.kotlin.psi.KtNamedFunction

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
    // HashSet and HashMap keep insertion order, as LinkedHashSet and LinkedHashMap
    base("__K2L_Set", "java/util/LinkedHashSet", "java/util/HashSet")
    base("__K2L_Map", "java/util/LinkedHashMap", "java/util/HashMap")
}

/** Bases with state of their own: a subclass's constructor has to run theirs. */
internal val CONCRETE_COLLECTION_BASES = setOf("__K2L_List", "__K2L_Set", "__K2L_Map")

internal fun collectionBaseFeature(lua: String) = when (lua) {
    ARRAY_DEQUE -> DEQUES_FEATURE
    in CONCRETE_COLLECTION_BASES -> "Collections"
    else -> ABSTRACT_COLLECTIONS_FEATURE
}

internal fun FileTransformer.collectionBaseRef(lua: String): LuaExpr = lualibRef(collectionBaseFeature(lua), lua)

/**
 * `class Stack : ArrayList<Int>(elements)`: the lualib constructor of a concrete base, with the collection or map the
 * constructor takes first (a capacity is ignored). Abstract bases have no state to initialize.
 */
internal fun FileTransformer.collectionSuperInit(call: KtCallElement?, lua: String): Unit = with(session) {
    if (lua !in CONCRETE_COLLECTION_BASES) return
    val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
    val values = resolved?.let { arguments(emptyList(), callArguments(it)) }.orEmpty()
    if (values.size == LINKED_MAP_ACCESS_ORDER_ARITY) unsupported(call!!, "LinkedHashMap in access order")
    val args = values.take(1)
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

/** The lualib bases of maps, whose `remove` Lua method is both `remove(key)` and `remove(key, value)`. */
private val MAP_BASES = setOf(ABSTRACT_MAP, "__K2L_MapBase", "__K2L_Map")

private const val OVERLOAD_DISPATCH = "OverloadDispatch"

/**
 * A class extending or implementing a library collection that overrides one overload of a member the lualib implements as
 * one Lua method for all of them (see `OverloadDispatch.lua`): `removeAll(elements)` or `retainAll(elements)`, which also
 * take a predicate, and a map's `remove(key)`, which also takes the value (or a map's own `remove(key, value)`). The class's
 * method is wrapped so the other overloads keep working when called through the library's interfaces.
 */
internal fun FileTransformer.overloadDispatch(c: KtClassOrObject, ref: LuaExpr) {
    val base = classes.collectionBaseOf(c) ?: return
    val functions = c.declarations.filterIsInstance<KtNamedFunction>()
    for (name in listOf("removeAll", "retainAll")) {
        val overrides = functions.any {
            it.name == name && it.hasModifier(KtTokens.OVERRIDE_KEYWORD) && it.valueParameters.size == 1 && naming.function(it) == name
        }
        if (overrides) emit(LuaCallStmt(LuaCall(lualibRef(OVERLOAD_DISPATCH, "__K2L_DispatchPredicate"), listOf(ref, LuaString(name)))))
    }
    if (base in MAP_BASES) mapRemoveDispatch(c, ref, functions)
}

/** `__K2L_DispatchMapRemove(C, valueRemove)` for a map class overriding `remove(key)` or declaring `remove(key, value)`. */
private fun FileTransformer.mapRemoveDispatch(c: KtClassOrObject, ref: LuaExpr, functions: List<KtNamedFunction>) {
    val removesKey = functions.any { it.name == "remove" && it.valueParameters.size == 1 && it.hasModifier(KtTokens.OVERRIDE_KEYWORD) }
    val removesValue = functions.any { it.name == "remove" && it.valueParameters.size == 2 }
    if (!removesKey && !removesValue) return
    val valueRemove = classes.hierarchy(c).flatMap { it.declarations.filterIsInstance<KtNamedFunction>() }
        .lastOrNull { it.name == "remove" && it.valueParameters.size == 2 && it.hasBody() }
    val name = valueRemove?.let { LuaString(naming.function(it)) } ?: LuaNil
    emit(LuaCallStmt(LuaCall(lualibRef(OVERLOAD_DISPATCH, "__K2L_DispatchMapRemove"), listOf(ref, name))))
}

/** Map.Entry's ids: a class of the program implementing it keeps its own members, and is marked for `is Map.Entry`. */
private val ENTRY_INTERFACES = setOf("kotlin/collections/Map.Entry", "kotlin/collections/MutableMap.MutableEntry", "java/util/Map.Entry")

/**
 * `C.____interfaces[__K2L_Entry] = true` for a class implementing Map.Entry: its objects are entries for `is Map.Entry` and
 * the lualib's entry sets (`entries.contains(e)`, an entry set's `equals`) without taking the lualib entry's members.
 */
internal fun FileTransformer.entryFlag(c: KtClassOrObject, ref: LuaExpr): Unit = with(session) {
    val symbol = c.symbol as? KaClassSymbol ?: return
    if (symbol.superTypes.none { it.expandedSymbol?.classId?.asString() in ENTRY_INTERFACES }) return
    val entry = lualibRef("Collections", "__K2L_Entry")
    emit(assign(LuaIndex(luaCall(LuaName("rawget"), ref, LuaString("____interfaces")), entry), LuaBool(true)))
}
