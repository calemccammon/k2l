package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotated
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Members without `self`, like TypeScriptToLua's `@noSelf`: those of a class, object or interface marked `@NoSelf`, of a file
 * marked `@file:NoSelfInFile` (or of every file, with the `noImplicitSelf` option), and single functions and properties
 * marked `@NoSelf`. They are called with `.`: `Book.Initialize(a, b)`, `ticker.start()`.
 * - In an object (also a companion or an object expression) such a member is a function of the object's table, and `this`
 *   is that table. One the object inherits calls the implementation with the object (see [inheritedMembers]).
 * - A class or interface keeps the method taking `self` in its table, and each instance has a field per such member: a
 *   closure calling the method with the instance, set by the constructor (see [bindMembers]).
 *
 * Supertypes decide: an override takes `self` exactly when the member it overrides does. Members of library types
 * (`toString`, `equals`, `compareTo`, `iterator`, ...) take `self`, since the runtime calls them with `:`, and so do
 * operators and member extensions.
 */
internal class NoSelfMembers(
    private val session: KaSession,
    private val classes: ClassHierarchy,
    private val interop: LuaInterop,
    private val noImplicitSelf: Boolean,
) {
    private val cache = HashMap<KtNamedDeclaration, Boolean>()

    /**
     * Whether the members of [c] are declared without `self`, unless their supertypes say otherwise. A companion object
     * follows its class's `@NoSelf`.
     */
    fun inScope(c: KtClassOrObject): Boolean = noImplicitSelf || annotated(c) || inNoSelfFile(c.containingKtFile) ||
        (c is KtObjectDeclaration && c.isCompanion() && c.containingClassOrObject?.let(::annotated) == true)

    /** Whether the member [d] (a function, a property or a `val` constructor parameter) of a class of the program takes no `self`. */
    fun isNoSelf(d: KtNamedDeclaration): Boolean = cache.getOrPut(d) {
        val owner = ownerClass(d)
        when {
            owner == null || !classes.isSource(d) || takesSelfAlways(d) -> false
            else -> overridden(d).firstOrNull()?.let(::isNoSelf) ?: (annotated(d) || inScope(owner))
        }
    }

    /** Why member [d] cannot have the convention it is declared with, if it cannot. */
    fun problem(d: KtNamedDeclaration): String? {
        val supers = overridden(d).map(::isNoSelf)
        return when {
            supers.distinct().size > 1 -> "Overriding members with and without self at once ('${d.name}')"
            !annotated(d) -> null
            takesSelfAlways(d) -> "@NoSelf on an operator function or member extension"
            supers.firstOrNull() == false -> "@NoSelf on an override of a member with self ('${d.name}')"
            else -> null
        }
    }

    private fun takesSelfAlways(d: KtNamedDeclaration) = (d is KtCallableDeclaration && d.receiverTypeReference != null) ||
        (d is KtNamedFunction && d.hasModifier(KtTokens.OPERATOR_KEYWORD))

    private fun overridden(d: KtNamedDeclaration): List<KaCallableSymbol> = with(session) {
        val symbol: KaCallableSymbol? = when (d) {
            is KtParameter -> (d.symbol as? KaValueParameterSymbol)?.generatedPrimaryConstructorProperty
            is KtCallableDeclaration -> d.symbol as? KaCallableSymbol
            else -> null
        }
        symbol?.directlyOverriddenSymbols?.map { it.fakeOverrideOriginal }?.toList().orEmpty()
    }

    /** A source member by its declaration; an external one as it is called (see ExternalCalls); a library one takes `self`. */
    private fun isNoSelf(symbol: KaCallableSymbol): Boolean = with(session) {
        val psi = symbol.psi as? KtNamedDeclaration
        if (psi != null && classes.isSource(psi)) return isNoSelf(psi)
        if (!interop.isExternal(symbol)) return false
        val container = symbol.containingDeclaration as? KaClassSymbol
        return (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true || container?.annotations?.contains(NO_SELF) == true ||
            container?.classKind?.isObject == true
    }

    private fun annotated(d: KtNamedDeclaration): Boolean = with(session) {
        val symbol = if (d is KtParameter) (d.symbol as? KaValueParameterSymbol)?.generatedPrimaryConstructorProperty else d.symbol
        (symbol as? KaAnnotated)?.annotations?.contains(NO_SELF) == true
    }

    private fun inNoSelfFile(file: KtFile) =
        file.fileAnnotationList?.annotationEntries?.any { it.shortName?.asString() == "NoSelfInFile" } == true
}

/** Reports the members of [c] whose convention cannot work. */
internal fun FileTransformer.checkNoSelf(c: KtClassOrObject) {
    for (d in memberDeclarations(c)) noSelf.problem(d)?.let { unsupported(d, it) }
}

/** The Lua names a member without `self` takes in its class table: the function, or the accessors of a property. */
private fun FileTransformer.noSelfNames(d: KtNamedDeclaration): List<String> = when {
    !noSelf.isNoSelf(d) -> emptyList()

    d is KtNamedFunction -> listOf(naming.function(d))

    !hasAccessors(d) -> emptyList()

    else -> listOfNotNull(
        accessorName("get", d),
        accessorName("set", d).takeIf {
            (d as? KtProperty)?.isVar ?: (d as KtParameter).isMutable
        },
    )
}

/** The members without `self` of [c] and its supertypes, by Lua name; with [implemented], only those with a body. */
private fun FileTransformer.noSelfMembers(c: KtClassOrObject, implemented: Boolean = false): Set<String> =
    classes.hierarchy(c).flatMapTo(LinkedHashSet()) { k ->
        memberDeclarations(k).filter { !implemented || hasBody(it) }.flatMap { noSelfNames(it) }
    }

private fun memberDeclarations(c: KtClassOrObject): List<KtNamedDeclaration> =
    c.declarations.filterIsInstance<KtNamedDeclaration>().filter { it is KtNamedFunction || it is KtProperty } +
        (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }.orEmpty()

private fun hasBody(d: KtNamedDeclaration): Boolean = when (d) {
    is KtNamedFunction -> d.hasBody()

    is KtProperty -> !d.hasModifier(KtTokens.ABSTRACT_KEYWORD) &&
        ((d.containingClassOrObject as? KtClass)?.isInterface() != true || d.getter?.hasBody() == true)

    else -> true
}

/** The members without `self` the constructor of class [c] binds to the instance: those its base class does not bind already. */
internal fun FileTransformer.boundMembers(c: KtClassOrObject): Set<String> {
    if (c is KtObjectDeclaration) return emptySet()
    return noSelfMembers(c) - classes.superInfo(c).base?.let { noSelfMembers(it) }.orEmpty()
}

/**
 * `if rawget(self, "m") == nil then self.m = function(...) return getmetatable(self).m(self, ...) end end` for each member
 * without `self` of [names]: the instance's field calls the method of its class. A field already set is kept: the function
 * of an object (whose table is its class), or the closure a subclass's constructor set.
 */
internal fun FileTransformer.bindMembers(target: LuaExpr, names: Collection<String>) {
    for (name in names) {
        val field = LuaIndex(target, LuaString(name))
        val method = LuaIndex(LuaCall(LuaName("getmetatable"), listOf(target)), LuaString(name))
        val closure = LuaFunction(emptyList(), listOf(LuaReturn(listOf(LuaCall(method, listOf(target, LuaName("...")))))), isVararg = true)
        val unset = LuaBinary(LuaBinOp.Eq, LuaCall(LuaName("rawget"), listOf(target, LuaString(name))), LuaNil)
        emit(LuaIf(unset, listOf(assign(field, closure))))
    }
}

/**
 * The members without `self` object [c] inherits and does not define: functions of its table calling the implementation of
 * its base class or interface with the object, `function O.m(...) return Base.m(O, ...) end`.
 */
internal fun FileTransformer.inheritedMembers(c: KtObjectDeclaration, ref: LuaExpr) {
    val info = classes.superInfo(c)
    val own = memberDeclarations(c).flatMap { noSelfNames(it) } + info.delegations.flatMap { noSelfMembers(it.iface) }
    for (name in noSelfMembers(c) - own.toSet()) {
        val provider =
            (listOfNotNull(info.base) + info.interfaces).firstOrNull { name in noSelfMembers(it, implemented = true) } ?: continue
        val call = LuaCall(LuaIndex(classRef(provider), LuaString(name)), listOf(ref, LuaName("...")))
        val fn = LuaFunction(emptyList(), listOf(LuaReturn(listOf(call))), isVararg = true)
        emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), fn, isLocal = false))
    }
}

/** Whether the initializers of object [c] (`____init`, `____initCompanion`) take no `self`. */
internal fun FileTransformer.initWithoutSelf(c: KtClassOrObject) = c is KtObjectDeclaration && noSelf.inScope(c)

/** The table that is `this` in member [d] of [c], when [c] is an object and [d] takes no `self`. */
internal fun FileTransformer.objectSelfOf(c: KtClassOrObject, ref: LuaExpr, d: KtNamedDeclaration): LuaExpr? =
    ref.takeIf { c is KtObjectDeclaration && noSelf.isNoSelf(d) }

/** While [block] defines a member of the object [ref] without `self`, `this` is the object's table and methods take no `self`. */
internal inline fun <T> FileTransformer.withObjectSelf(ref: LuaExpr?, block: () -> T): T {
    val saved = objectSelf
    objectSelf = ref
    try {
        return block()
    } finally {
        objectSelf = saved
    }
}

/** Calls the method [name] of [target]: `target.name(args)` when it takes no `self`, else `target:name(args)`. */
internal fun methodCall(target: LuaExpr, name: String, args: List<LuaExpr>, noSelf: Boolean): LuaExpr =
    if (noSelf) LuaCall(LuaIndex(target, LuaString(name)), args) else LuaMethodCall(target, name, args)
