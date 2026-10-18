package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * Delegated properties (`val x by ...`). The delegate lives in a hidden slot (`self.____x_delegate` for members,
 * a local `____x_delegate` otherwise) and reads and writes call its `getValue`/`setValue`. The `KProperty`
 * argument is a table `{ name = "x" }`: only `property.name` is available.
 */
private const val GET_VALUE = "getValue"
private const val SET_VALUE = "setValue"
private val LIBRARY_DELEGATE_TYPES = setOf("kotlin/properties/ReadWriteProperty", "kotlin/properties/ReadOnlyProperty")

private fun FileTransformer.delegateKind(p: KtProperty): DelegateKind? {
    if (delegateKinds.containsKey(p)) return delegateKinds[p]
    return computeKind(p).also { delegateKinds[p] = it }
}

private fun FileTransformer.computeKind(p: KtProperty): DelegateKind? = with(session) {
    val expr = p.delegateExpression ?: return null
    val type = expr.expressionType ?: return unsupported(p, "Delegate of unknown type").let { null }
    val symbol = type.expandedSymbol
    val classId = symbol?.classId?.asString()
    val psi = symbol?.psi as? KtClassOrObject
    return when {
        classId == "kotlin/Lazy" -> DelegateKind.Lazy
        type.collectionKind() == CollectionKind.Map -> DelegateKind.MapKey
        psi != null && classes.isSource(psi) -> userKind(p, psi)
        classId in LIBRARY_DELEGATE_TYPES -> DelegateKind.Library
        else -> unsupported(p, "Delegate of type '${type.pretty()}'").let { null }
    }
}

private fun FileTransformer.userKind(p: KtProperty, cls: KtClassOrObject): DelegateKind? {
    // An override shares its Lua name with what it overrides, so distinct names are distinct overloads.
    fun operators(name: String) = classes.hierarchy(cls).flatMap { c ->
        c.declarations.filterIsInstance<KtNamedFunction>().filter { it.name == name }
    }.distinctBy { naming.function(it) }

    if (operators("provideDelegate").isNotEmpty()) {
        unsupported(p, "Delegate with provideDelegate")
        return null
    }
    val getters = operators(GET_VALUE)
    val setters = operators(SET_VALUE)
    val problem = when {
        getters.isEmpty() -> "has no member getValue (extension operators are not supported)"
        getters.size > 1 || setters.size > 1 -> "overloads getValue or setValue"
        p.isVar && setters.isEmpty() -> "has no member setValue"
        else -> null
    }
    if (problem != null) {
        unsupported(p, "Delegate class '${cls.name}' that $problem")
        return null
    }
    return DelegateKind.User(naming.function(getters.single()), setters.singleOrNull()?.let { naming.function(it) })
}

/** The `KProperty` stand-in. */
private fun propertyInfo(name: String): LuaExpr = LuaTable(listOf(LuaField.Named("name", LuaString(name))))

private fun delegateGet(kind: DelegateKind, delegate: LuaExpr, thisRef: LuaExpr, name: String): LuaExpr = when (kind) {
    DelegateKind.Lazy -> LuaMethodCall(delegate, GET_VALUE, emptyList())
    DelegateKind.MapKey -> LuaMethodCall(delegate, GET_VALUE, listOf(LuaString(name)))
    DelegateKind.Library -> LuaMethodCall(delegate, GET_VALUE, listOf(thisRef, propertyInfo(name)))
    is DelegateKind.User -> LuaMethodCall(delegate, kind.get, listOf(thisRef, propertyInfo(name)))
}

private fun delegateSet(kind: DelegateKind, delegate: LuaExpr, thisRef: LuaExpr, name: String, value: LuaExpr): LuaStmt = LuaCallStmt(
    when (kind) {
        DelegateKind.MapKey -> LuaMethodCall(delegate, "set", listOf(LuaString(name), value))
        is DelegateKind.User -> LuaMethodCall(delegate, kind.set!!, listOf(thisRef, propertyInfo(name), value))
        else -> LuaMethodCall(delegate, SET_VALUE, listOf(thisRef, propertyInfo(name), value))
    },
)

// ---- local and top-level ----

/** `val x by d` as a local or top-level: `local ____x_delegate = d`. */
internal fun FileTransformer.delegatedVariable(p: KtProperty, isLocal: Boolean): Unit = with(session) {
    delegateKind(p) ?: return
    val expr = p.delegateExpression ?: return
    val name = naming.delegate(p)
    val value = expression(expr)
    emit(if (isLocal) LuaLocal(listOf(name), listOf(value)) else assign(LuaName(name), value))
}

private fun FileTransformer.variableDelegate(p: KtProperty): LuaExpr =
    if (p.isTopLevel) topLevelRef(p, naming.delegate(p)) else LuaName(naming.delegate(p))

internal fun FileTransformer.isSourceDelegatedVariable(psi: PsiElement?): Boolean =
    psi is KtProperty && psi.delegate != null && psi.containingClassOrObject == null && classes.isSource(psi)

internal fun FileTransformer.delegatedVariableRead(p: KtProperty): LuaExpr {
    val kind = delegateKind(p) ?: return LuaNil
    return delegateGet(kind, variableDelegate(p), LuaNil, p.name!!)
}

internal fun FileTransformer.delegatedVariableTarget(p: KtProperty): Target? {
    val kind = delegateKind(p) ?: return null
    val delegate = variableDelegate(p)
    return Target(delegateGet(kind, delegate, LuaNil, p.name!!)) { delegateSet(kind, delegate, LuaNil, p.name!!, it) }
}

// ---- members ----

private fun delegateField(p: KtProperty, self: LuaExpr): LuaExpr = LuaIndex(self, LuaString("____${p.name}_delegate"))

/** A member property's initializer: its field, or its delegate's slot. */
internal fun FileTransformer.propertyInitializer(p: KtProperty): Unit = with(session) {
    if (p.delegate != null) {
        delegateInitializer(p)
        return
    }
    p.initializer?.let { init ->
        val field = LuaIndex(selfRef(), LuaString(props.fieldName(p)))
        emitAll(valueInto(init) { listOf(assign(field, it)) })
    }
}

/** `self.____x_delegate = d`, in declaration order with the other initializers. */
private fun FileTransformer.delegateInitializer(p: KtProperty): Unit = with(session) {
    delegateKind(p) ?: return
    val expr = p.delegateExpression ?: return
    emitAll(valueInto(expr) { listOf(assign(delegateField(p, selfRef()), it)) })
}

/** `getX`/`setX` methods that forward to the delegate. */
internal fun FileTransformer.delegatedAccessors(p: KtProperty, ref: LuaExpr) {
    val unsupportedModifier = listOf(KtTokens.OPEN_KEYWORD, KtTokens.OVERRIDE_KEYWORD, KtTokens.ABSTRACT_KEYWORD).any { p.hasModifier(it) }
    if (unsupportedModifier) {
        unsupported(p, "Delegated property that is open or overriding")
        return
    }
    val kind = delegateKind(p) ?: return
    val delegate = delegateField(p, selfRef())
    val name = p.name!!
    emitMethod(ref, accessorName("get", p), emptyList(), listOf(LuaReturn(listOf(delegateGet(kind, delegate, selfRef(), name)))))
    if (p.isVar) {
        emitMethod(ref, accessorName("set", p), listOf("value"), listOf(delegateSet(kind, delegate, selfRef(), name, LuaName("value"))))
    }
}

// ---- library delegate factories ----

/** `lazy { }`, `Delegates.observable(...)`, `Delegates.vetoable(...)` and `Delegates.notNull()`. */
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

        else -> null
    }
}
