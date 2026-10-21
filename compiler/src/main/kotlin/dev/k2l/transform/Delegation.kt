package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Delegated properties (`val x by ...`). The delegate lives in a hidden slot (`self.____x_delegate` for members,
 * a local `____x_delegate` otherwise) and reads and writes call its `getValue`/`setValue`. The `KProperty`
 * argument is a property reference without accessors, see [propertyInfo]. `provideDelegate` is called once, where
 * the delegate would be stored. Open and overriding delegated properties belong to the accessor families of
 * [PropertyFamilies]: every member is read through `getX`.
 */
private const val GET_VALUE = "getValue"
private const val SET_VALUE = "setValue"
private val LIBRARY_DELEGATE_TYPES = setOf("kotlin/properties/ReadWriteProperty", "kotlin/properties/ReadOnlyProperty")
private val PROPERTY_REFERENCES = mapOf(
    "kotlin/reflect/KProperty0" to false,
    "kotlin/reflect/KMutableProperty0" to false,
    "kotlin/reflect/KProperty1" to true,
    "kotlin/reflect/KMutableProperty1" to true,
)

private fun FileTransformer.delegateKind(p: KtProperty): DelegateKind? {
    if (delegateKinds.containsKey(p)) return delegateKinds[p]
    return computeKind(p).also { delegateKinds[p] = it }
}

private fun FileTransformer.computeKind(p: KtProperty): DelegateKind? = with(session) {
    val expr = p.delegateExpression ?: return null
    var type = expr.expressionType ?: return unsupported(p, "Delegate of unknown type").let { null }
    // `by provider`: the delegate is what provider.provideDelegate(thisRef, property) returns
    libraryProvider(type)?.let { delegate ->
        delegateProviders[p] = Operator.Method("provideDelegate")
        type = delegate
    }
    findOperators(type, "provideDelegate").let { found ->
        if (found.size > 1) return unsupported(p, "Delegate that overloads provideDelegate").let { null }
        found.singleOrNull()?.let { (operator, result) ->
            delegateProviders[p] = operator
            type = result ?: return unsupported(p, "Delegate whose provideDelegate has an unknown type").let { null }
        }
    }
    return kindOf(p, type)
}

/** The kind of a delegate of [type], after any `provideDelegate`. */
private fun FileTransformer.kindOf(p: KtProperty, type: KaType): DelegateKind? = with(session) {
    val symbol = type.expandedSymbol
    val classId = symbol?.classId?.asString()
    val psi = symbol?.psi as? KtClassOrObject
    return when {
        classId == "kotlin/Lazy" -> DelegateKind.Lazy
        type.collectionKind() == CollectionKind.Map -> DelegateKind.MapKey
        classId in LIBRARY_DELEGATE_TYPES -> DelegateKind.Library
        classId in PROPERTY_REFERENCES -> DelegateKind.Property(PROPERTY_REFERENCES.getValue(classId!!))
        psi != null && classes.isSource(psi) -> userKind(p, type)
        else -> unsupported(p, "Delegate of type '${type.pretty()}'").let { null }
    }
}

/** The delegate type `D` of a library `PropertyDelegateProvider<T, D>`. */
private fun FileTransformer.libraryProvider(type: KaType): KaType? = with(session) {
    val classType = type.withoutFlexibility as? KaClassType ?: return null
    if (classType.classId.asString() != "kotlin/properties/PropertyDelegateProvider") return null
    classType.typeArguments.getOrNull(1)?.type
}

/**
 * The operator functions [name] that apply to a value of [type] and the type each returns: members of its class and
 * supertypes in this program, and top-level extension functions of the module whose receiver is one of its classes.
 */
private fun FileTransformer.findOperators(type: KaType, name: String): List<Pair<Operator, KaType?>> = with(session) {
    val cls = type.expandedSymbol?.psi as? KtClassOrObject
    val members = if (cls != null && classes.isSource(cls)) {
        // An override shares its Lua name with what it overrides, so distinct names are distinct overloads.
        classes.hierarchy(cls).flatMap { c -> c.declarations.filterIsInstance<KtNamedFunction>().filter { it.name == name } }
            .distinctBy { naming.function(it) }.map { Operator.Method(naming.function(it)) to returnTypeOf(it) }
    } else {
        emptyList()
    }
    val ids = (sequenceOf(type) + type.allSupertypes).mapNotNull { it.expandedSymbol?.classId }.toSet()
    val extensions = classes.topLevelFunctions().filter { fn ->
        fn.name == name && fn.receiverTypeReference?.type?.expandedSymbol?.classId in ids
    }.map { Operator.Extension(it) to returnTypeOf(it) }
    members + extensions
}

private fun FileTransformer.returnTypeOf(fn: KtNamedFunction): KaType? = with(session) { fn.symbol.returnType }

private fun FileTransformer.userKind(p: KtProperty, type: KaType): DelegateKind? = with(session) {
    val getters = findOperators(type, GET_VALUE)
    val setters = findOperators(type, SET_VALUE)
    val problem = when {
        getters.isEmpty() -> "has no getValue"
        getters.size > 1 || setters.size > 1 -> "overloads getValue or setValue"
        p.isVar && setters.isEmpty() -> "has no setValue"
        else -> null
    }
    if (problem != null) {
        unsupported(p, "Delegate class '${type.expandedSymbol?.name?.asString()}' that $problem")
        return null
    }
    return DelegateKind.User(getters.single().first, setters.singleOrNull()?.first)
}

/**
 * The `KProperty` passed to the delegate: a property reference (see [propertyRefObject]) with the name, `toString()` and `==` of
 * the JVM's, without accessors (on the JVM only kotlin-reflect would make them reachable for a `KProperty<*>`). Members store
 * theirs in the class; for top-level and local properties `__K2L_KProperty` keeps one per property.
 */
private fun FileTransformer.propertyInfo(p: KtProperty, member: Boolean = false): LuaExpr = with(session) {
    val key = referenceKey(p.symbol as KaCallableSymbol)
    if (member) return propertyRefObject(p.name!!, key, LuaNil, null, null)
    LuaCall(lualibRef("PropertyRef", "__K2L_KProperty"), listOf(LuaString(p.name!!), LuaString(key)))
}

private fun FileTransformer.operatorCall(operator: Operator, delegate: LuaExpr, args: List<LuaExpr>): LuaExpr = when (operator) {
    is Operator.Method -> LuaMethodCall(delegate, operator.name, args)
    is Operator.Extension -> LuaCall(topLevelRef(operator.function), listOf(delegate) + args)
}

/** `provideDelegate`: what `by provider` actually delegates to. */
private fun FileTransformer.provide(p: KtProperty, provider: LuaExpr, thisRef: LuaExpr): LuaExpr {
    val operator = delegateProviders[p] ?: return provider
    return operatorCall(operator, provider, listOf(thisRef, propertyInfo(p)))
}

/** [info] is the `KProperty` passed to the delegate: accessors of a class pass a constant, others [propertyInfo]. */
private fun FileTransformer.delegateGet(
    kind: DelegateKind,
    delegate: LuaExpr,
    thisRef: LuaExpr,
    p: KtProperty,
    info: LuaExpr? = null,
): LuaExpr = when (kind) {
    DelegateKind.Lazy -> LuaMethodCall(delegate, GET_VALUE, emptyList())
    DelegateKind.MapKey -> LuaMethodCall(delegate, GET_VALUE, listOf(LuaString(p.name!!)))
    DelegateKind.Library -> LuaMethodCall(delegate, GET_VALUE, listOf(thisRef, info ?: propertyInfo(p)))
    is DelegateKind.User -> operatorCall(kind.get, delegate, listOf(thisRef, info ?: propertyInfo(p)))
    is DelegateKind.Property -> LuaMethodCall(delegate, "get", if (kind.unbound) listOf(thisRef) else emptyList())
}

private fun FileTransformer.delegateSet(
    kind: DelegateKind,
    delegate: LuaExpr,
    thisRef: LuaExpr,
    p: KtProperty,
    value: LuaExpr,
    info: LuaExpr? = null,
): LuaStmt = LuaCallStmt(
    when (kind) {
        DelegateKind.MapKey -> LuaMethodCall(delegate, "set", listOf(LuaString(p.name!!), value))
        is DelegateKind.User -> operatorCall(kind.set!!, delegate, listOf(thisRef, info ?: propertyInfo(p), value))
        is DelegateKind.Property -> LuaMethodCall(delegate, "set", if (kind.unbound) listOf(thisRef, value) else listOf(value))
        else -> LuaMethodCall(delegate, SET_VALUE, listOf(thisRef, info ?: propertyInfo(p), value))
    },
)

// ---- local and top-level ----

/** `val x by d` as a local or top-level: `local ____x_delegate = d`. */
internal fun FileTransformer.delegatedVariable(p: KtProperty, isLocal: Boolean): Unit = with(session) {
    delegateKind(p) ?: return
    val expr = p.delegateExpression ?: return
    val name = naming.delegate(p)
    val value = provide(p, expression(expr), LuaNil)
    emit(if (isLocal) LuaLocal(listOf(name), listOf(value)) else assign(LuaName(name), value))
}

private fun FileTransformer.variableDelegate(p: KtProperty): LuaExpr =
    if (p.isTopLevel) topLevelRef(p, naming.delegate(p)) else LuaName(naming.delegate(p))

internal fun FileTransformer.isSourceDelegatedVariable(psi: PsiElement?): Boolean =
    psi is KtProperty && psi.delegate != null && psi.containingClassOrObject == null && classes.isSource(psi)

internal fun FileTransformer.delegatedVariableRead(p: KtProperty): LuaExpr {
    val kind = delegateKind(p) ?: return LuaNil
    return delegateGet(kind, variableDelegate(p), LuaNil, p)
}

internal fun FileTransformer.delegatedVariableTarget(p: KtProperty): Target? {
    val kind = delegateKind(p) ?: return null
    val delegate = variableDelegate(p)
    return Target(delegateGet(kind, delegate, LuaNil, p)) { delegateSet(kind, delegate, LuaNil, p, it) }
}

// ---- members ----

/** Each class of an override family that delegates has a delegate slot of its own, like the JVM's `x$delegate` fields. */
private fun delegateField(p: KtProperty, self: LuaExpr): LuaExpr = LuaIndex(self, LuaString(delegateSlot(p, "delegate")))

private fun delegateSlot(p: KtProperty, kind: String): String {
    val owner = if (p.hasModifier(KtTokens.OVERRIDE_KEYWORD)) "__${p.containingClassOrObject?.name ?: "object"}" else ""
    return "____${p.name}_$kind$owner"
}

/** A member property's initializer: its field, or its delegate's slot. */
internal fun FileTransformer.propertyInitializer(p: KtProperty): Unit = with(session) {
    if (p.delegate != null) {
        delegateInitializer(p)
        return
    }
    p.initializer?.let { init ->
        val field = LuaIndex(selfRef(), LuaString(fieldKey(p)))
        emitAll(valueInto(init) { listOf(assign(field, it)) })
    }
}

/** `self.____x_delegate = d`, in declaration order with the other initializers. */
private fun FileTransformer.delegateInitializer(p: KtProperty): Unit = with(session) {
    delegateKind(p) ?: return
    val expr = p.delegateExpression ?: return
    emitAll(valueInto(expr) { listOf(assign(delegateField(p, selfRef()), provide(p, it, selfRef()))) })
}

/** `getX`/`setX` methods that forward to the delegate. */
internal fun FileTransformer.delegatedAccessors(p: KtProperty, ref: LuaExpr) {
    val kind = delegateKind(p) ?: return
    val delegate = delegateField(p, selfRef())
    // The KProperty is built once per property, not on every access: `Holder.____x_property = __K2L_PropertyRef.new("x", ...)`
    val info = if (kind == DelegateKind.Lazy || kind == DelegateKind.MapKey || kind is DelegateKind.Property) {
        null
    } else {
        LuaIndex(ref, LuaString(delegateSlot(p, "property"))).also {
            emit(assign(it, propertyInfo(p, member = true)))
        }
    }
    emitMethod(ref, accessorName("get", p), emptyList(), listOf(LuaReturn(listOf(delegateGet(kind, delegate, selfRef(), p, info)))))
    if (p.isVar) {
        emitMethod(
            ref,
            accessorName("set", p),
            listOf("value"),
            listOf(delegateSet(kind, delegate, selfRef(), p, LuaName("value"), info)),
        )
    }
}

// ---- library delegate factories ----

/**
 * `lazy { }`, `Delegates.observable(...)`, `Delegates.vetoable(...)`, `Delegates.notNull()`, `ReadOnlyProperty { }` and
 * `PropertyDelegateProvider { }`.
 */
internal fun FileTransformer.delegateFactory(callableId: String?, call: KaCallableMemberCall<*, *>): LuaExpr? = with(session) {
    if (callableId == null || call !is KaFunctionCall<*>) return null
    val args = callArguments(call)
    return when (callableId) {
        // lazy(initializer), lazy(mode, initializer): the thread-safety mode is ignored
        "kotlin/lazy" -> lualibCall("Lazy", expression(args.last()!!))

        "kotlin/properties/Delegates.observable" -> LuaCall(
            lualibRef("Delegates", "__K2L_ObservableProperty"),
            arguments(emptyList(), args),
        )

        "kotlin/properties/Delegates.vetoable" -> LuaCall(lualibRef("Delegates", "__K2L_VetoableProperty"), arguments(emptyList(), args))

        "kotlin/properties/Delegates.notNull" -> LuaCall(lualibRef("Delegates", "__K2L_NotNullProperty"), emptyList())

        // the SAM constructors `ReadOnlyProperty { thisRef, property -> }` and `PropertyDelegateProvider { thisRef, property -> }`
        "kotlin/properties/ReadOnlyProperty" -> LuaCall(lualibRef("Delegates", "__K2L_ReadOnlyProperty"), arguments(emptyList(), args))

        "kotlin/properties/PropertyDelegateProvider" ->
            LuaCall(lualibRef("Delegates", "__K2L_DelegateProvider"), arguments(emptyList(), args))

        else -> null
    }
}
