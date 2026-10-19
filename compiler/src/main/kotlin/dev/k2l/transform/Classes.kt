package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaKotlinPropertySymbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

internal fun FileTransformer.selfRef(): LuaExpr = LuaName("self").also { stable += it }

internal inline fun <T> FileTransformer.withClass(c: KtClassOrObject, block: () -> T): T {
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

/**
 * Where a class's table lives: a local, or a field of its enclosing class. Companions live on their class, unless they
 * have supertypes: then they are an object of their own, a field of the class (`Foo.Companion`).
 */
internal fun FileTransformer.classRef(c: KtClassOrObject): LuaExpr {
    if (c is KtObjectDeclaration && c.isCompanion()) {
        val owner = classRef(c.containingClassOrObject!!)
        return if (hasOwnTable(c)) LuaIndex(owner, LuaString(c.name ?: "Companion")) else owner
    }
    val outer = c.containingClassOrObject
    return when {
        outer != null -> LuaIndex(classRef(outer), LuaString(c.name!!))
        c.isTopLevel() -> topLevelRef(c)
        else -> LuaName(naming.of(c)) // local class
    }
}

internal fun FileTransformer.classDeclaration(c: KtClassOrObject, isLocal: Boolean) {
    if (interop.isExternalDeclaration(c) || isSkipped(c)) return
    declareClass(c, isLocal)
}

/** The class table of [c] with its members and initialization; [companion] uses it for companions with a table of their own. */
internal fun FileTransformer.declareClass(c: KtClassOrObject, isLocal: Boolean): Unit = with(session) {
    val info = classes.superInfo(c)
    if (info.unsupported != null) {
        val what = if (info.unsupported is KtDelegatedSuperTypeEntry) "Delegating the library interface in" else "Extending"
        unsupported(info.unsupported, "$what '${info.unsupported.text}'")
        return
    }
    if (isLocal) captureOuters(c)
    val ref = classRef(c)
    emitClassTable(c, ref, info, isLocal)
    classBody(c, ref, info)
    val lazy = initialization(c, ref)
    if (lazy.isNotEmpty()) emit(LuaCallStmt(lualibCall("LazyObject", ref, *lazy.map { LuaString(it) }.toTypedArray())))
}

private fun FileTransformer.emitClassTable(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo, isLocal: Boolean) {
    val classArgs = mutableListOf<LuaExpr>(LuaString(binaryName(c)))
    val baseRef = info.base?.let(::classRef) ?: info.libraryBase?.let { lualibRef(EXCEPTIONS_FEATURE, it) }
        ?: info.collectionBase?.let { collectionBaseRef(it) }
        ?: when {
            info.sequenceBase -> lualibRef(SEQUENCE_FEATURE, "__K2L_Sequence")
            info.elementBase -> lualibRef(COROUTINES_FEATURE, "__K2L_AbstractCoroutineContextElement")
            else -> null
        }
    val mixins = info.samMixins.distinct().map { lualibRef(SAM_FEATURE, it) } +
        listOfNotNull(if (info.sequenceMixin) lualibRef(SEQUENCE_FEATURE, "__K2L_Sequence") else null)
    if (baseRef != null || info.interfaces.isNotEmpty() || mixins.isNotEmpty()) classArgs += baseRef ?: LuaNil
    info.interfaces.mapTo(classArgs) { classRef(it) }
    classArgs += mixins
    val create = lualibCall("Class", *classArgs.toTypedArray())
    emit(if (isLocal) LuaLocal(listOf(naming.of(c)), listOf(create)) else assign(ref, create))
    classInfo(c, ref)
}

/** Annotations, enum entries and companions are emitted with their class. */
private fun isSkipped(c: KtClassOrObject): Boolean =
    c is KtEnumEntry || (c is KtClass && c.isAnnotation()) || (c is KtObjectDeclaration && c.isCompanion())

private fun FileTransformer.classBody(c: KtClassOrObject, ref: LuaExpr, info: SuperInfo) = withClass(c) {
    checkMembers(c)
    constructors(c, ref, info)
    members(c, ref)
    delegatedMembers(c, ref)
    libraryPropertyOverrides(c, ref)
    if (c is KtClass && c.isData()) dataClassMembers(c, ref)
    if (c is KtClass && c.isEnum() && c.declaredFunction("toString") == null) {
        emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(LuaIndex(selfRef(), LuaString("name"))))))
    }
}

/** `override val message: String get() = ...`: lualib code reading `self.message` has to reach the getter. */
private fun FileTransformer.libraryPropertyOverrides(c: KtClassOrObject, ref: LuaExpr) {
    val properties = c.declarations.filterIsInstance<KtProperty>() +
        (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }.orEmpty()
    for (p in properties.filter { props.overridesLibraryWithAccessor(it) }) {
        emit(
            LuaCallStmt(
                LuaCall(lualibRef("Class", "__K2L_PropertyOverride"), listOf(ref, LuaString(p.name!!), LuaString(accessorName("get", p)))),
            ),
        )
    }
}

internal fun FileTransformer.emitMethod(ref: LuaExpr, name: String, params: List<String>, body: List<LuaStmt>) {
    emit(LuaFunctionDecl(LuaIndex(ref, LuaString(name)), LuaFunction(params, body), isLocal = false, isMethod = true))
}

/** Lua tables hold methods and fields in one namespace. */
internal fun FileTransformer.checkMembers(c: KtClassOrObject) {
    val fields = (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }?.mapNotNull { it.name }.orEmpty().toMutableSet()
    c.declarations.filterIsInstance<KtProperty>().mapNotNullTo(fields) { it.name }
    for (decl in c.declarations.filterIsInstance<KtNamedFunction>()) {
        val name = naming.function(decl)
        when {
            name == "new" || decl.name.orEmpty().startsWith("____") ->
                ctx.error(decl, "A member named '${decl.name}' clashes with the generated Lua class table")

            name in fields -> ctx.error(decl, "A function and a property both named '$name' would share one Lua field")
        }
    }
    // Overrides of library overloads keep the library's name (see DeclarationNames).
    c.declarations.filterIsInstance<KtNamedFunction>().groupBy { naming.function(it) }.filterValues { it.size > 1 }.forEach { (name, fns) ->
        ctx.error(fns.last(), "Overrides of '${fns.last().name}' share the Lua name '$name'")
    }
    // Overloads inherited along different paths can end up with the same Lua name.
    val roots = classes.hierarchy(c).flatMap { k ->
        k.declarations.filterIsInstance<KtNamedFunction>().filter { !it.hasModifier(KtTokens.OVERRIDE_KEYWORD) }
    }
    roots.groupBy { naming.function(it) }.filterValues { it.size > 1 }.forEach { (name, fns) ->
        if (fns.any { it.containingClassOrObject == c }) {
            ctx.error(fns.last(), "Overloads of '$name' inherited from different supertypes clash in Lua")
        }
    }
}

internal fun FileTransformer.members(c: KtClassOrObject, ref: LuaExpr): Unit = with(session) {
    (c as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() && hasAccessors(it) }?.forEach { accessorMethods(it, ref) }
    for (decl in c.declarations) {
        when (decl) {
            is KtNamedFunction -> if (decl.hasBody() && !decl.isReifiedInline()) {
                emit(LuaFunctionDecl(LuaIndex(ref, LuaString(naming.function(decl))), function(decl), isLocal = false, isMethod = true))
            }

            is KtProperty -> if (hasAccessors(decl) || props.problem(decl) != null) accessorMethods(decl, ref)

            is KtEnumEntry -> Unit

            // created by enumEntries()
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
    val enumParams = leadingConstructorParams(c)
    if (hasPrimary(c) && classes.initNeeded(c)) {
        val params = (c as? KtClass)?.primaryConstructorParameters.orEmpty()
        val body = collect {
            storeOuter(c)
            defaultArguments(params)
            if (isEnum) enumParams.forEach { emit(assign(LuaIndex(selfRef(), LuaString(it)), LuaName(it))) }
            superInit(info.baseCall, info)
            for (p in params) {
                if (p.hasValOrVar()) emit(assign(LuaIndex(selfRef(), LuaString(props.fieldName(p))), LuaName(naming.of(p))))
            }
            delegateFields(c)
            initializers(c)
        }
        emitMethod(ref, INIT, enumParams + params.map { naming.of(it) }, body)
    }
    (c as? KtClass)?.secondaryConstructors?.forEachIndexed { i, ctor -> secondaryConstructor(c, ctor, (i + 1).toString(), ref, info) }
}

private fun FileTransformer.secondaryConstructor(c: KtClass, ctor: KtSecondaryConstructor, suffix: String, ref: LuaExpr, info: SuperInfo) =
    with(session) {
        val enumParams = leadingConstructorParams(c)
        val params = enumParams + ctor.valueParameters.map { naming.of(it) }
        val body = collect {
            storeOuter(c)
            defaultArguments(ctor.valueParameters)
            val delegation = ctor.getDelegationCallOrNull()
            if (delegation != null && delegation.isCallToThis) {
                delegatingInit(delegation, c, enumParams)
            } else {
                if (c.isEnum()) enumParams.forEach { emit(assign(LuaIndex(selfRef(), LuaString(it)), LuaName(it))) }
                superInit(delegation?.takeIf { it.valueArgumentList != null }, info)
                if (!hasPrimary(c)) {
                    delegateFields(c)
                    initializers(c)
                }
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

/** Property initializers and `init` blocks, in declaration order. */
internal fun FileTransformer.initializers(c: KtClassOrObject): Unit = with(session) {
    for (decl in c.declarations) {
        when (decl) {
            is KtProperty -> propertyInitializer(decl)
            is KtAnonymousInitializer -> decl.body?.let { block(it) }
            else -> Unit
        }
    }
}

/** `constructor(...) : this(...)`. */
private fun FileTransformer.delegatingInit(call: KtConstructorDelegationCall, c: KtClassOrObject, enumParams: List<String>): Unit =
    with(session) {
        val resolved = call.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
        val suffix = constructorSuffix(resolved.signature.symbol.psi)
        if (suffix.isEmpty() && !classes.initNeeded(c)) return
        val args = arguments(enumParams.map { LuaName(it).asOperand() }, callArguments(resolved))
        // not `self:____init`, which would dispatch to a subclass's initializer
        emit(LuaCallStmt(LuaCall(LuaIndex(classRef(c), LuaString("$INIT$suffix")), listOf(selfRef()) + args)))
    }

internal fun FileTransformer.isMemberProperty(psi: PsiElement?): Boolean = (psi is KtProperty && psi.containingClassOrObject != null) ||
    (psi is KtParameter && psi.hasValOrVar() && psi.ownerFunction is KtPrimaryConstructor)

internal fun FileTransformer.hasAccessors(p: KtNamedDeclaration) = props.usesAccessors(p) || (p is KtProperty && p.delegate != null)

internal fun FileTransformer.accessorName(prefix: String, p: KtNamedDeclaration) =
    (p as? KtProperty)?.takeIf { it.isMemberExtension() }?.let { naming.memberAccessor(it, prefix) }
        ?: (prefix + p.name!!.replaceFirstChar { it.uppercaseChar() })

internal fun FileTransformer.propertyRead(receiver: LuaExpr, p: KtNamedDeclaration): LuaExpr = if (hasAccessors(p)) {
    LuaMethodCall(receiver, accessorName("get", p), emptyList())
} else {
    LuaIndex(receiver, LuaString(p.name!!))
}

internal fun FileTransformer.propertyWrite(receiver: LuaExpr, p: KtNamedDeclaration, value: LuaExpr): LuaStmt = if (hasAccessors(p)) {
    LuaCallStmt(LuaMethodCall(receiver, accessorName("set", p), listOf(value)))
} else {
    assign(LuaIndex(receiver, LuaString(p.name!!)), value)
}

/** `field` inside an accessor: the property's storage on `self`. */
internal fun FileTransformer.backingField(e: KtNameReferenceExpression): LuaExpr = with(session) {
    val symbol = e.mainReference.resolveToSymbol() as KaBackingFieldSymbol
    val top = symbol.owningProperty.psi as? KtProperty
    if (top != null && top.isTopLevel) return LuaName(naming.backingField(top))
    return LuaIndex(selfRef(), LuaString(fieldName(symbol.owningProperty)))
}

private fun FileTransformer.fieldName(symbol: KaKotlinPropertySymbol): String {
    val psi = symbol.psi as? KtNamedDeclaration
    return if (psi != null) props.fieldName(psi) else symbol.name.asString()
}
