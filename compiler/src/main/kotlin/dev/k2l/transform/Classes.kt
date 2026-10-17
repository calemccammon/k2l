package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.idea.references.mainReference
import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

internal fun FileTransformer.selfRef(): LuaExpr = LuaName("self").also { stable += it }

private inline fun <T> FileTransformer.withClass(c: KtClassOrObject, block: () -> T): T {
    val savedClass = currentClass
    val savedLoops = loops
    currentClass = c
    loops = ArrayDeque()
    try {
        return block()
    } finally {
        currentClass = savedClass
        loops = savedLoops
    }
}

/** Where a class's table lives: a local, or a field of its enclosing class. Companions live on their class. */
internal fun FileTransformer.classRef(c: KtClassOrObject): LuaExpr {
    if (c is KtObjectDeclaration && c.isCompanion()) return classRef(c.containingClassOrObject!!)
    val outer = c.containingClassOrObject
    return when {
        outer != null -> LuaIndex(classRef(outer), LuaString(c.name!!))
        c.isTopLevel() -> topLevelRef(c)
        else -> LuaName(naming.of(c)) // local class
    }
}

internal fun FileTransformer.classDeclaration(c: KtClassOrObject, isLocal: Boolean): Unit = with(session) {
    if (interop.isExternalDeclaration(c)) return
    when {
        c is KtEnumEntry || c is KtClass && c.isAnnotation() -> return
        c is KtObjectDeclaration && c.isCompanion() -> return // emitted together with its class
        c is KtClass && c.isInner() -> {
            unsupported(c, "Inner class")
            return
        }
    }
    val info = classes.superInfo(c)
    if (info.unsupported != null) {
        unsupported(info.unsupported, "Extending '${info.unsupported.text}'")
        return
    }
    val ref = classRef(c)
    val classArgs = mutableListOf<LuaExpr>(LuaString(c.name ?: "?"))
    val baseRef = info.base?.let(::classRef) ?: info.libraryBase?.let { lualibRef(EXCEPTIONS_FEATURE, it) }
    if (baseRef != null || info.interfaces.isNotEmpty()) classArgs += baseRef ?: LuaNil
    info.interfaces.mapTo(classArgs) { classRef(it) }
    val create = lualibCall("Class", *classArgs.toTypedArray())
    emit(if (isLocal) LuaLocal(listOf(naming.of(c)), listOf(create)) else assign(ref, create))

    withClass(c) {
        checkMembers(c)
        constructors(c, ref, info)
        members(c, ref)
        if (c is KtClass && c.isData()) dataClassMembers(c, ref)
        if (c is KtClass && c.isEnum() && c.declaredFunction("toString") == null) {
            emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(LuaIndex(selfRef(), LuaString("name"))))))
        }
    }
    if (c is KtClass && c.isEnum()) enumEntries(c, ref)
    c.companionObjects.forEach { companion(it, ref) }
    // Objects are initialized where they are declared (Kotlin initializes them lazily, on first access).
    if (c is KtObjectDeclaration && classes.initNeeded(c)) emit(LuaCallStmt(LuaMethodCall(ref, INIT, emptyList())))
}

private fun FileTransformer.emitMethod(ref: LuaExpr, name: String, params: List<String>, body: List<LuaStmt>) {
    emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), LuaFunction(params, body), isLocal = false, isMethod = true))
}

/** Lua tables hold methods and fields in one namespace. */
private fun FileTransformer.checkMembers(c: KtClassOrObject) {
    val fields = (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }?.mapNotNull { it.name }.orEmpty().toMutableSet()
    c.declarations.filterIsInstance<KtProperty>().mapNotNullTo(fields) { it.name }
    for (decl in c.declarations.filterIsInstance<KtNamedFunction>()) {
        val name = naming.function(decl)
        when {
            name == "new" || name.startsWith("____") ->
                ctx.error(decl, "A member named '${decl.name}' clashes with the generated Lua class table")
            name in fields -> ctx.error(decl, "A function and a property both named '$name' would share one Lua field")
        }
    }
    // Overloads inherited along different paths can end up with the same Lua name.
    val roots = classes.hierarchy(c).flatMap { k -> k.declarations.filterIsInstance<KtNamedFunction>().filter { !it.hasModifier(KtTokens.OVERRIDE_KEYWORD) } }
    roots.groupBy { naming.function(it) }.filterValues { it.size > 1 }.forEach { (name, fns) ->
        if (fns.any { it.containingClassOrObject == c }) {
            ctx.error(fns.last(), "Overloads of '$name' inherited from different supertypes clash in Lua")
        }
    }
}

internal fun FileTransformer.members(c: KtClassOrObject, ref: LuaExpr): Unit = with(session) {
    for (decl in c.declarations) {
        when (decl) {
            is KtNamedFunction -> if (decl.hasBody()) {
                emit(LuaFunctionDecl(LuaIndex(ref, LuaString(naming.function(decl))), function(decl), isLocal = false, isMethod = true))
            }
            is KtProperty -> if (hasAccessors(decl)) accessorMethods(decl, ref)
            is KtEnumEntry -> Unit // created by enumEntries()
            is KtClassOrObject -> classDeclaration(decl, isLocal = false)
            else -> Unit // initializers and constructors are handled by constructors()
        }
    }
}

internal fun FileTransformer.constructorSuffix(psi: PsiElement?): String {
    if (psi !is KtSecondaryConstructor) return ""
    return (psi.getContainingClassOrObject().secondaryConstructors.indexOf(psi) + 1).toString()
}

internal fun FileTransformer.constructors(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo): Unit = with(session) {
    val isEnum = c is KtClass && c.isEnum()
    val enumParams = if (isEnum) listOf("name", "ordinal") else emptyList()
    if (hasPrimary(c) && classes.initNeeded(c)) {
        val params = (c as? KtClass)?.primaryConstructorParameters.orEmpty()
        val body = collect {
            defaultArguments(params)
            if (isEnum) enumParams.forEach { emit(assign(LuaIndex(selfRef(), LuaString(it)), LuaName(it))) }
            superInit(info.baseCall, info.base, info.libraryBase)
            for (p in params) {
                if (p.hasValOrVar()) emit(assign(LuaIndex(selfRef(), LuaString(p.name!!)), LuaName(naming.of(p))))
            }
            initializers(c)
        }
        emitMethod(ref, INIT, enumParams + params.map { naming.of(it) }, body)
    }
    (c as? KtClass)?.secondaryConstructors?.forEachIndexed { i, ctor ->
        val suffix = (i + 1).toString()
        val params = enumParams + ctor.valueParameters.map { naming.of(it) }
        val body = collect {
            defaultArguments(ctor.valueParameters)
            val delegation = ctor.getDelegationCallOrNull()
            if (delegation != null && delegation.isCallToThis) {
                delegatingInit(delegation, c, enumParams)
            } else {
                superInit(delegation?.takeIf { it.valueArgumentList != null }, info.base, info.libraryBase)
                if (!hasPrimary(c)) initializers(c)
            }
            ctor.bodyExpression?.let { block(it) }
        }
        emitMethod(ref, "$INIT$suffix", params, body)
        val self = LuaName("self")
        emit(
            LuaFunctionDecl(
                LuaIndex(ref, LuaString("new$suffix")),
                LuaFunction(
                    params,
                    listOf(
                        LuaLocal(listOf("self"), listOf(luaCall(LuaName("setmetatable"), LuaTable(emptyList()), ref))),
                        LuaCallStmt(LuaMethodCall(self, "$INIT$suffix", params.map { LuaName(it) })),
                        LuaReturn(listOf(self)),
                    ),
                ),
                isLocal = false,
            ),
        )
    }
}

/** Property initializers and `init` blocks, in declaration order. */
private fun FileTransformer.initializers(c: KtClassOrObject): Unit = with(session) {
    for (decl in c.declarations) {
        when (decl) {
            is KtProperty -> decl.initializer?.let { init ->
                val field = LuaIndex(selfRef(), LuaString(decl.name!!))
                emitAll(valueInto(init) { listOf(assign(field, it)) })
            }
            is KtAnonymousInitializer -> decl.body?.let { block(it) }
            else -> Unit
        }
    }
}

/** Calls the base class constructor that [call] (a super-type entry or `super(...)`) resolves to. */
private fun FileTransformer.superInit(call: KtCallElement?, base: KtClassOrObject?, libraryBase: String? = null): Unit = with(session) {
    if (libraryBase != null) {
        val resolved = call?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
        val args = resolved?.let { throwableArguments(callArguments(it, call)) }.orEmpty()
        emit(LuaCallStmt(LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, libraryBase), LuaString(INIT)), listOf(selfRef()) + args)))
        return
    }
    if (base == null) return
    if (call == null) {
        if (classes.initNeeded(base)) emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString(INIT)), listOf(selfRef()))))
        return
    }
    val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
    val suffix = constructorSuffix(resolved.signature.symbol.psi)
    if (suffix.isEmpty() && !classes.initNeeded(base)) return
    val args = arguments(emptyList(), callArguments(resolved, call))
    emit(LuaCallStmt(LuaCall(LuaIndex(classRef(base), LuaString("$INIT$suffix")), listOf(selfRef()) + args)))
}

/** `constructor(...) : this(...)`. */
private fun FileTransformer.delegatingInit(call: KtConstructorDelegationCall, c: KtClassOrObject, enumParams: List<String>): Unit = with(session) {
    val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
    val suffix = constructorSuffix(resolved.signature.symbol.psi)
    if (suffix.isEmpty() && !classes.initNeeded(c)) return
    val args = arguments(enumParams.map { LuaName(it).asOperand() }, callArguments(resolved, call))
    emit(LuaCallStmt(LuaMethodCall(selfRef(), "$INIT$suffix", args)))
}

internal fun FileTransformer.isMemberProperty(psi: PsiElement?): Boolean =
    (psi is KtProperty && psi.containingClassOrObject != null) ||
        (psi is KtParameter && psi.hasValOrVar() && psi.ownerFunction is KtPrimaryConstructor)

private fun FileTransformer.hasAccessors(p: KtNamedDeclaration) =
    p is KtProperty && !interop.isExternalDeclaration(p) && (p.getter?.hasBody() == true || p.setter?.hasBody() == true)

private fun FileTransformer.accessorName(prefix: String, p: KtNamedDeclaration) =
    prefix + p.name!!.replaceFirstChar { it.uppercaseChar() }

internal fun FileTransformer.propertyRead(receiver: LuaExpr, p: KtNamedDeclaration): LuaExpr =
    if (hasAccessors(p)) LuaMethodCall(receiver, accessorName("get", p), emptyList())
    else LuaIndex(receiver, LuaString(p.name!!))

internal fun FileTransformer.propertyWrite(receiver: LuaExpr, p: KtNamedDeclaration, value: LuaExpr): LuaStmt =
    if (hasAccessors(p)) LuaCallStmt(LuaMethodCall(receiver, accessorName("set", p), listOf(value)))
    else assign(LuaIndex(receiver, LuaString(p.name!!)), value)

/** `field` inside an accessor: the property's storage on `self`. */
internal fun FileTransformer.backingField(e: KtNameReferenceExpression): LuaExpr = with(session) {
    val symbol = e.mainReference.resolveToSymbol() as KaBackingFieldSymbol
    return LuaIndex(selfRef(), LuaString(symbol.owningProperty.name.asString()))
}

private fun FileTransformer.accessorMethods(p: KtProperty, ref: LuaExpr): Unit = with(session) {
    val owner = p.containingClassOrObject
    if (p.hasModifier(KtTokens.OPEN_KEYWORD) || p.hasModifier(KtTokens.OVERRIDE_KEYWORD) ||
        p.hasModifier(KtTokens.ABSTRACT_KEYWORD) || (owner is KtClass && owner.isInterface())
    ) {
        unsupported(p, "Custom accessors on an open or overriding property")
        return
    }
    val field = LuaIndex(selfRef(), LuaString(p.name!!))
    val getter = p.getter?.takeIf { it.hasBody() }
    emitMethod(ref, accessorName("get", p), emptyList(), getter?.let { accessorBody(it) } ?: listOf(LuaReturn(listOf(field))))
    if (p.isVar) {
        val setter = p.setter?.takeIf { it.hasBody() }
        val param = LuaNames.of(setter?.parameter?.name ?: "value")
        emitMethod(
            ref, accessorName("set", p), listOf(param),
            setter?.let { accessorBody(it) } ?: listOf(assign(field, LuaName(param))),
        )
    }
}

private fun FileTransformer.accessorBody(accessor: KtPropertyAccessor): List<LuaStmt> = with(session) { collect { functionBody(accessor) } }

private fun FileTransformer.dataClassMembers(c: KtClass, ref: LuaExpr): Unit = with(session) {
    val props = c.primaryConstructorParameters.filter { it.hasValOrVar() }
    if (c.declaredFunction("toString") == null) {
        val parts = mutableListOf<LuaExpr>()
        props.forEachIndexed { i, p ->
            parts += LuaString((if (i == 0) "${c.name}(" else ", ") + "${p.name}=")
            parts += str(LuaIndex(selfRef(), LuaString(p.name!!)), p.returnType, forConcat = true)
        }
        parts += LuaString(if (props.isEmpty()) "${c.name}()" else ")")
        val merged = parts.fold(mutableListOf<LuaExpr>()) { acc, part ->
            val last = acc.lastOrNull()
            if (last is LuaString && part is LuaString) acc[acc.lastIndex] = LuaString(last.value + part.value) else acc += part
            acc
        }
        emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(merged.reduceRight { a, b -> LuaBinary(LuaBinOp.Concat, a, b) }))))
    }
    if (c.declaredFunction("hashCode") == null) {
        // result = 31 * result + field.hashCode(), as the Kotlin compiler generates.
        val hash = props.map { p -> lualibCall("Hash", LuaIndex(selfRef(), LuaString(p.name!!))) }
            .reduceOrNull { acc, h -> lualibCall("ToInt32", LuaBinary(LuaBinOp.Add, LuaBinary(LuaBinOp.Mul, LuaNumber("31"), acc), h)) }
            ?: LuaNumber("0")
        emitMethod(ref, "hashCode", emptyList(), listOf(LuaReturn(listOf(hash))))
    }
    if (c.declaredFunction("equals") == null) {
        val other = LuaName("other")
        val checks = listOf<LuaExpr>(LuaBinary(LuaBinOp.Eq, luaCall(LuaName("getmetatable"), other), ref)) +
            props.map { p ->
                val key = LuaString(p.name!!)
                equality(LuaIndex(selfRef(), key), p.returnType, LuaIndex(other, key), p.returnType, negated = false)
            }
        emitMethod(ref, "equals", listOf("other"), listOf(LuaReturn(listOf(checks.reduce { a, b -> LuaBinary(LuaBinOp.And, a, b) }))))
    }
}

/** Generated members of data classes declared in this file: copy, componentN, toString, equals. */
internal fun FileTransformer.dataClassMember(call: KaCallableMemberCall<*, *>, receiverExpr: KtExpression?, implicit: LuaExpr?): LuaExpr? = with(session) {
    val symbol = call.partiallyAppliedSymbol.symbol
    val name = symbol.callableId?.callableName?.asString() ?: return null
    val cls = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass ?: return null
    if (!cls.isData() || symbol.psi is KtNamedFunction) return null // user-declared members are ordinary methods
    if (name != "copy" && name != "toString" && name != "equals" && name != "hashCode" && !name.matches(Regex("component[0-9]+"))) return null
    val props = cls.primaryConstructorParameters
    val receiver = implicit ?: expression(receiverExpr ?: return null)
    if (name == "toString" || name == "equals" || name == "hashCode") {
        val args = (call as KaFunctionCall<*>).valueArgumentMapping.keys.toList()
        return LuaMethodCall(receiver, name, ordered(args))
    }
    if (name != "copy") return propertyRead(receiver, props[name.removePrefix("component").toInt() - 1])
    val source = cache(receiver, "source")
    val mapping = (call as KaFunctionCall<*>).valueArgumentMapping.entries.toList()
    val provided = mapping.map { it.value.symbol.name.asString() }.zip(ordered(mapping.map { it.key })).toMap()
    val args = props.map { p -> provided[p.name] ?: propertyRead(source, p) }
    return LuaCall(LuaIndex(classRef(cls), LuaString("new")), args)
}

private fun FileTransformer.enumEntries(c: KtClass, ref: LuaExpr): Unit = with(session) {
    c.declarations.filterIsInstance<KtEnumEntry>().forEachIndexed { ordinal, entry ->
        if (entry.body != null) unsupported(entry, "Enum entry with a body")
        val callEntry = entry.initializerList?.initializers?.firstOrNull() as? KtSuperTypeCallEntry
        val resolved = callEntry?.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>()
        val suffix = constructorSuffix(resolved?.signature?.symbol?.psi)
        val args = if (resolved != null) arguments(emptyList(), callArguments(resolved, callEntry)) else emptyList()
        val value = LuaCall(LuaIndex(ref, LuaString("new$suffix")), listOf(LuaString(entry.name!!), LuaNumber(ordinal.toString())) + args)
        emit(assign(LuaIndex(ref, LuaString(entry.name!!)), value))
    }
}

/** Companion members live on the class table; their initializers run in `____initCompanion`. */
internal fun FileTransformer.companion(companion: KtObjectDeclaration, ref: LuaExpr): Unit = with(session) {
    if (companion.superTypeListEntries.isNotEmpty()) {
        unsupported(companion, "Companion object with supertypes")
        return
    }
    withClass(companion) {
        checkMembers(companion)
        val owner = companion.containingClassOrObject!!
        val instanceNames = owner.declarations.mapNotNull { (it as? KtNamedDeclaration)?.name }.toSet() +
            (owner as? KtClass)?.primaryConstructorParameters?.mapNotNull { it.name }.orEmpty()
        companion.declarations.filterIsInstance<KtNamedDeclaration>().filter { it.name in instanceNames }.forEach {
            ctx.error(it, "Companion member '${it.name}' clashes with an instance member of the same name")
        }
        members(companion, ref)
        val init = collect { initializers(companion) }
        if (init.isNotEmpty()) {
            emitMethod(ref, INIT_COMPANION, emptyList(), init)
            emit(LuaCallStmt(LuaMethodCall(ref, INIT_COMPANION, emptyList())))
        }
    }
}
