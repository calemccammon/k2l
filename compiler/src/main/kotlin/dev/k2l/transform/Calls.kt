package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.KaReceiverValue
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSamConstructorSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

// Calls: of functions and constructors of the program, of library functions (see StdlibMappings) and of function values.

/**
 * A resolved call or property access. [element] is what the Analysis API resolves (a call,
 * name reference or infix binary expression); [full] includes any explicit receiver.
 */
internal fun FileTransformer.call(element: KtExpression, full: KtExpression): LuaExpr = with(session) {
    val call = element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
        ?: return unsupported(full, "Unresolved call '${full.text}'")
    recordUnmappedArguments(call, element)
    return catchingJumps(call, full) { shortcutCall(call, full) ?: callWithReceiver(call, full) }
}

private fun FileTransformer.recordUnmappedArguments(call: KaCallableMemberCall<*, *>, element: KtExpression): Unit = with(session) {
    if (call !is KaFunctionCall<*>) return
    unmappedWhenSubject(element)?.let { subject ->
        val parameter = call.signature.symbol.valueParameters.singleOrNull()
        if (call.valueArgumentMapping.isEmpty() && parameter != null) callState.unmappedArguments[call] = mapOf(subject to parameter)
        return
    }
    val args = (element as? KtCallElement)?.valueArguments?.map { it.getArgumentExpression() } ?: return
    val mapped = call.valueArgumentMapping.keys
    val parameters = call.signature.symbol.valueParameters

    // arguments past the end of the parameter list belong to a trailing vararg
    fun parameterAt(i: Int) = parameters.getOrNull(i) ?: parameters.lastOrNull()?.takeIf { it.isVararg }
    val missing = args.withIndex().filter { (i, arg) -> arg != null && arg !in mapped && parameterAt(i) != null }
    if (missing.isNotEmpty()) callState.unmappedArguments[call] = missing.associate { (i, arg) -> arg!! to parameterAt(i)!! }
}

private fun FileTransformer.shortcutCall(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr? = with(session) {
    val symbol = call.partiallyAppliedSymbol.symbol
    val isInvoke = symbol.callableId?.callableName?.asString() == "invoke"
    return when {
        // Library constants such as Int.MAX_VALUE fold to literals; their receiver is not a value.
        call !is KaFunctionCall<*> && !StdlibMappings.has(symbol.callableId?.toString()) && full.evaluate() != null -> constant(full)

        isInvoke && call.partiallyAppliedSymbol.dispatchReceiver?.type is KaFunctionType ->
            invokeFunctionValue(call, full)

        else -> null
    }
}

private fun FileTransformer.callWithReceiver(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr {
    val pas = call.partiallyAppliedSymbol
    val symbol = pas.symbol
    val receiverValue = (pas.extensionReceiver ?: pas.dispatchReceiver)?.takeUnless { isNoValueReceiver(it, symbol) }
    val receiverExpr = receiverValue?.let { explicitReceiver(it) }
    val implicit = if (receiverValue != null && receiverExpr == null) {
        implicitReceiver(receiverValue, full) ?: return LuaNil
    } else {
        null
    }
    if (interop.isExternal(symbol)) return externalCall(call, receiverExpr, implicit, full)
    memberExtensionAccess(call, full)?.let { return it }
    userInlineCall(call, full)?.let { return it }
    val id = libraryCallableId(symbol)
    return delegateFactory(id, call)
        ?: dataClassMember(call, receiverExpr, implicit)
        ?: inlinedCollectionCall(id, call, receiverExpr, implicit, full)
        ?: loopedListOfSize(id, call)
        ?: scopeFunction(id, call, receiverExpr, implicit)
        ?: declaredCall(call, receiverExpr, implicit, receiverValue?.type, full)
}

private fun FileTransformer.declaredCall(
    call: KaCallableMemberCall<*, *>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    receiverType: KaType?,
    full: KtExpression,
): LuaExpr = with(session) {
    val symbol = call.partiallyAppliedSymbol.symbol
    val psi = symbol.psi
    val args = callArguments(call)
    val inFile = classes.isSource(psi)
    val enumMember = if (psi == null || psi is KtClass) enumStaticMember(symbol, args) else null
    return when {
        symbol is KaConstructorSymbol -> constructorCall(symbol, psi, args, full, receiverOperand(implicit, receiverExpr))

        symbol is KaSamConstructorSymbol && sourceFunInterface(symbol.returnType) != null ->
            funInterfaceObject(sourceFunInterface(symbol.returnType)!!, arguments(emptyList(), args)[0])

        inFile && psi is KtNamedFunction -> sourceFunctionCall(psi, args, receiverExpr, implicit)

        inFile && isMemberProperty(psi) -> memberPropertyRead(psi as KtNamedDeclaration, receiverExpr, implicit, full)

        inFile && psi is KtProperty && psi.receiverTypeReference != null -> extensionPropertyRead(psi, receiverExpr, implicit)

        receiverExpr is KtSuperExpression -> collectionSuperCall(symbol, args, receiverType, full) ?: librarySuperCall(symbol, args)
            ?: unsupported(full, "Calling a library member through 'super'")

        enumMember != null -> enumMember

        else -> libraryCall(
            symbol.callableId?.callableName?.asString(),
            libraryCallableId(symbol),
            receiverExpr,
            implicit,
            receiverType,
            args,
            full,
            (call as? KaFunctionCall<*>)?.symbol?.valueParameters?.map { it.returnType }.orEmpty(),
        )
    }
}

/**
 * The id mappings know a library member by: a member a class of the program inherits from a library class
 * (`MyList.contains` of `AbstractList<Int>`) is a fake override with the subclass's id, so the original's is used.
 */
private fun FileTransformer.libraryCallableId(symbol: KaCallableSymbol): String? = with(session) {
    val own = symbol.callableId
    if (own?.classId?.let(classes::classInFile) == null || classes.isSource(symbol.psi)) return own?.toString()
    return symbol.fakeOverrideOriginal.callableId?.toString()
}

/** Invoking a function value: the value is the dispatch receiver; a receiver of `T.() -> R` is the first argument. */
private fun FileTransformer.invokeFunctionValue(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr = with(session) {
    inlinedParameterCall(call, full) ?: callFunctionValue(call, full)
}

private fun FileTransformer.callFunctionValue(call: KaCallableMemberCall<*, *>, full: KtExpression): LuaExpr = with(session) {
    val pas = call.partiallyAppliedSymbol
    val fnValue = receiverOperand(pas.dispatchReceiver!!, full) ?: return LuaNil
    val extension = pas.extensionReceiver?.let { receiverOperand(it, full) ?: return LuaNil }
    val values = arguments(listOf(fnValue) + listOfNotNull(extension), invokeArguments(call))
    return LuaCall(values[0], values.drop(1))
}

/** Arguments of `invoke`: with `receiver.f(a)` the function's receiver parameter is not among them. */
internal fun FileTransformer.invokeArguments(call: KaCallableMemberCall<*, *>): List<KtExpression?> = with(session) {
    callArguments(call).let { if (call.partiallyAppliedSymbol.extensionReceiver != null) it.drop(1) else it }
}

/** A constructor of a class in this program, a library exception, or a mapped collection class. */
private fun FileTransformer.constructorCall(
    symbol: KaConstructorSymbol,
    psi: com.intellij.psi.PsiElement?,
    args: List<KtExpression?>,
    full: KtExpression,
    outer: Operand?,
): LuaExpr = with(session) {
    typeAliasedOriginal(symbol)?.let { return constructorCall(it, it.psi, args, full, outer) }
    val classId = symbol.containingClassId
    (classId?.let(classes::classInFile) ?: localClassOf(psi, classId))?.let { cls ->
        val outers = if (isInner(cls)) {
            listOf(outer ?: return unsupported(full, "Inner class constructor without an outer instance"))
        } else {
            emptyList()
        }
        return LuaCall(LuaIndex(classRef(cls), LuaString("new" + constructorSuffix(psi))), arguments(outers, args))
    }
    LIBRARY_CLASSES[classId?.asString()]?.let { lua ->
        return libNew(EXCEPTIONS_FEATURE, lua, throwableArguments(args, symbol.valueParameters))
    }
    val site =
        CallSite(this, this@constructorCall, full, null, null, null, arguments(emptyList(), args), args.map { it?.expressionType })
    return LibraryConstructors.call(classId?.asString(), site)
        ?: unsupported(full, "Constructing library class '${classId?.asSingleFqName()}'")
}

/** The class a constructor of a local class belongs to: local classes have no class id to look up. */
private fun FileTransformer.localClassOf(
    constructor: com.intellij.psi.PsiElement?,
    classId: org.jetbrains.kotlin.name.ClassId?,
): KtClassOrObject? =
    if (classId == null) (constructor as? KtClassOrObject) ?: (constructor as? KtConstructor<*>)?.getContainingClassOrObject() else null

/** A top-level or extension function, or a method (including `super.method()`), declared in this program. */
internal fun FileTransformer.sourceFunctionCall(
    psi: KtNamedFunction,
    args: List<KtExpression?>,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
): LuaExpr = with(session) {
    if (psi.containingClassOrObject == null) {
        // Extension functions take their receiver as the first argument.
        val receivers = if (psi.receiverTypeReference != null) {
            listOf(receiverOperand(implicit, receiverExpr) ?: return LuaNil)
        } else {
            emptyList()
        }
        val fn = if (psi.isTopLevel) topLevelRef(psi) else LuaName(naming.function(psi))
        return LuaCall(fn, arguments(receivers, args))
    }
    val method = naming.function(psi)
    if (receiverExpr is KtSuperExpression) {
        // The resolved declaration is the implementation `super` reaches, in a class or interface.
        return LuaCall(
            LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(method)),
            listOf(selfRef()) + arguments(emptyList(), args),
        )
    }
    val values = arguments(listOf(receiverOperand(implicit, receiverExpr)!!), args)
    return LuaMethodCall(values[0], method, values.drop(1))
}

private fun FileTransformer.memberPropertyRead(
    property: KtNamedDeclaration,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    full: KtExpression,
): LuaExpr = with(session) {
    val receiver = when (receiverExpr) {
        null -> implicit ?: return unsupported(full, "Property without receiver")

        is KtSuperExpression -> {
            // the implementation `super` reaches, called statically
            if (hasAccessors(property)) {
                return LuaCall(LuaIndex(classRef(ownerClass(property)!!), LuaString(accessorName("get", property))), listOf(selfRef()))
            }
            selfRef()
        }

        // a field overridden in a subclass shares storage with the base
        else -> expression(receiverExpr)
    }
    return propertyRead(receiver, property)
}

/** A receiver that is not a value: a library class named as a qualifier, or the enum class of `entries` in its companion. */
private fun FileTransformer.isNoValueReceiver(value: KaReceiverValue, symbol: KaCallableSymbol): Boolean = with(session) {
    isLibraryClassQualifier(value) || isEnumStaticMember(symbol)
}

/** Whether [symbol] is `values()`, `entries` or `valueOf` of an enum class: its implicit receiver (in a companion) is not a value. */
private fun FileTransformer.isEnumStaticMember(symbol: KaCallableSymbol): Boolean = with(session) {
    val psi = symbol.psi
    if (psi != null && psi !is KtClass) return false
    val name = symbol.callableId?.callableName?.asString()
    return (name == "values" || name == "entries" || name == "valueOf") &&
        (symbol.callableId?.classId?.let(classes::classInFile) as? KtClass)?.isEnum() == true
}

/** `values()`, `entries` and `valueOf(name)` of an enum class declared in this program. */
private fun FileTransformer.enumStaticMember(symbol: KaCallableSymbol, args: List<KtExpression?>): LuaExpr? = with(session) {
    val psi = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass ?: return null
    if (!psi.isEnum()) return null
    return when (symbol.callableId?.callableName?.asString()) {
        "values", "entries" -> lualibCall("EnumValues", classRef(psi))
        "valueOf" -> lualibCall("EnumValueOf", classRef(psi), arguments(emptyList(), args)[0])
        else -> null
    }
}

/** A Kotlin standard library call, translated through [StdlibMappings]. */
internal fun FileTransformer.libraryCall(
    name: String?,
    callableId: String?,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
    receiverValueType: KaType?,
    args: List<KtExpression?>,
    full: KtExpression,
    parameterTypes: List<KaType?> = emptyList(),
): LuaExpr = with(session) {
    val values = arguments(listOfNotNull(receiverOperand(implicit, receiverExpr)), args)
    val hasReceiver = implicit != null || receiverExpr != null
    val receiverType = receiverExpr?.expressionType ?: receiverValueType
    val argTypes = args.map { it?.expressionType }
    // an object implementing CharSequence is passed to the String functions as its text (its toString() is its own)
    val textReceiver = hasReceiver && isTextReceiver(name, receiverType)
    val argValues = charSequenceArguments(if (hasReceiver) values.drop(1) else values, argTypes, parameterTypes)
    if (textReceiver) charSequenceMember(callableId, values[0], argValues)?.let { return it }
    val site = CallSite(
        session = this,
        transformer = this@libraryCall,
        element = full,
        name = name,
        receiver = if (textReceiver) charSequenceText(values[0], receiverType) else values.firstOrNull()?.takeIf { hasReceiver },
        receiverType = if (textReceiver) builtinTypes.string else receiverType,
        // omitted trailing arguments are nil; spread arguments may stand for several (`__K2L_Spread`), which must stay last
        args = argValues.let { a -> if (args.any { it in callState.spreads }) a else a + List(maxOf(0, args.size - a.size)) { LuaNil } },
        argTypes = argTypes,
        parameterTypes = parameterTypes,
    )
    return StdlibMappings.map(callableId, site) ?: unsupportedLibraryCall(full, callableId, receiverType)
}

/** A library call no mapping translates; a member of an unsigned type is not reported again (its receiver was). */
private fun FileTransformer.unsupportedLibraryCall(full: KtExpression, callableId: String?, receiverType: KaType?): LuaExpr =
    if (with(session) { unsignedTypeName(receiverType) } != null) {
        LuaNil
    } else {
        unsupported(full, "Library API '${callableId?.replace('/', '.') ?: full.text}'")
    }
