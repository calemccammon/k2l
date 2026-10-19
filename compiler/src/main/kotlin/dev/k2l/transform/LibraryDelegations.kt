package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/** Library properties the lualib reads as fields (`xs.size`, `cs.length`, `entry.key`): a forwarded getter has to be reached from them. */
private val FIELD_PROPERTIES = setOf("size", "length", "key", "value")

private const val CHAR_SEQUENCE = "kotlin/CharSequence"

/**
 * `class C(xs: MutableList<Int>) : MutableList<Int> by xs`: the class implements the library interface like a class that
 * implements it itself (it extends the lualib base, see CollectionBases, or is callable, see SAM_MIXINS), and every member
 * Kotlin delegates (the abstract ones the class does not override; not Java's default methods such as `removeIf` or `sort`,
 * nor `toString`/`equals`/`hashCode`) is a method calling that member on the delegate, as a call on a value of the
 * interface type compiles: `function C:get(index) return self.____delegate_MutableList:get(index) end`. The other
 * operations (`map`, `joinToString`, `for` loops, the default methods) are the base's, written in terms of these methods,
 * so they see the members the class overrides, as on the JVM.
 */
internal fun FileTransformer.libraryDelegatedMembers(c: KtClassOrObject, ref: LuaExpr): Unit = with(session) {
    val delegations = classes.superInfo(c).libraryDelegations
    if (delegations.isEmpty()) return
    val symbol = c.symbol as? KaClassSymbol ?: return
    val defined = HashSet<String>()
    for (member in symbol.delegatedMemberScope.callables) {
        val original = member.fakeOverrideOriginal
        val delegation = delegations.firstOrNull { owns(it, original) } ?: continue
        when (member) {
            is KaNamedFunctionSymbol -> forwardFunction(ref, member, original, delegation, defined)
            is KaPropertySymbol -> forwardProperty(ref, member, original, delegation, defined)
            else -> Unit
        }
    }
    if (delegations.any { it.entry.typeReference?.type?.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE }) {
        val d = delegations.first { it.entry.typeReference?.type?.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE }
        val text = charSequenceText(LuaIndex(selfRef(), LuaString(d.field)), d.entry.delegateExpression?.expressionType)
        // the text the library's String functions run on (see __K2L_CharSequenceText)
        emitMethod(ref, "____text", emptyList(), listOf(LuaReturn(listOf(text))))
    }
}

/** Whether [member] is a member of the interface delegated by [d] (or of one of its superinterfaces). */
private fun KaSession.owns(d: LibraryDelegation, member: KaCallableSymbol): Boolean {
    val owner = member.callableId?.classId ?: return false
    val type = d.entry.typeReference?.type ?: return false
    return type.expandedSymbol?.classId == owner || type.allSupertypes.any { it.expandedSymbol?.classId == owner }
}

private fun FileTransformer.forwardFunction(
    ref: LuaExpr,
    member: KaNamedFunctionSymbol,
    original: KaCallableSymbol,
    d: LibraryDelegation,
    defined: MutableSet<String>,
): Unit = with(session) {
    val name = member.name.asString()
    val params = member.valueParameters.map { LuaNames.of(it.name.asString()) }
    val luaName = libraryMemberName(name, params.size)
    if (!defined.add(luaName)) return
    val args = params.map { LuaName(it) }
    val delegate = LuaIndex(selfRef(), LuaString(d.field))
    val call = if (d.entry.typeReference?.type?.expandedSymbol?.classId?.asString() in SAM_MIXINS) {
        LuaCall(delegate, args) // a Comparator, Runnable or function value is a Lua callable
    } else {
        mappedMember(name, original, d, args, member.valueParameters.map { it.returnType }) ?: LuaMethodCall(delegate, luaName, args)
    }
    emitMethod(ref, luaName, params, listOf(LuaReturn(listOf(call))))
}

private fun FileTransformer.forwardProperty(
    ref: LuaExpr,
    member: KaPropertySymbol,
    original: KaCallableSymbol,
    d: LibraryDelegation,
    defined: MutableSet<String>,
) {
    val name = member.name.asString()
    val getter = "get" + name.replaceFirstChar { it.uppercaseChar() }
    if (!defined.add(getter)) return
    val read =
        mappedMember(name, original, d, emptyList(), emptyList()) ?: LuaIndex(LuaIndex(selfRef(), LuaString(d.field)), LuaString(name))
    emitMethod(ref, getter, emptyList(), listOf(LuaReturn(listOf(read))))
    if (name !in FIELD_PROPERTIES) return
    currentClass?.let { propertyOverride(it, ref, name, getter) }
}

/** The call of a library member on the delegate of [d], as the library mappings compile it on a value of the interface type. */
private fun FileTransformer.mappedMember(
    name: String,
    original: KaCallableSymbol,
    d: LibraryDelegation,
    args: List<LuaExpr>,
    parameterTypes: List<KaType?>,
): LuaExpr? = with(session) {
    val element = d.entry.delegateExpression ?: return null
    val type = d.entry.typeReference?.type ?: return null
    val delegate = LuaIndex(selfRef(), LuaString(d.field))
    val text = type.expandedSymbol?.classId?.asString() == CHAR_SEQUENCE
    val site = CallSite(
        session = this,
        transformer = this@mappedMember,
        element = element,
        name = name,
        receiver = if (text) charSequenceText(delegate, element.expressionType) else delegate,
        receiverType = if (text) builtinTypes.string else type,
        args = args,
        argTypes = parameterTypes,
        parameterTypes = parameterTypes,
    )
    StdlibMappings.map(original.callableId?.toString(), site)
}

/** The lualib name of a library member: `add(index, element)` is `addAt`, `addAll(index, elements)` `addAllAt`, ... */
private fun libraryMemberName(name: String, arity: Int): String = when {
    (name == "add" || name == "addAll") && arity == 2 -> name + "At"
    name == "listIterator" && arity == 1 -> "listIteratorAt"
    else -> LuaNames.member(name)
}
