package dev.k2l.transform

import com.intellij.psi.PsiElement
import com.intellij.psi.util.PsiTreeUtil
import dev.k2l.codegen.*
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

// Private members as locals of the file: only the file's own code can use them, so they need no field of a table.

/**
 * How many locals a file's top-level declarations and private members may take together. Lua allows a function, the chunk
 * included, 200 locals, and the chunk also has a local for each runtime name it uses (see LambdaHoisting); the members past
 * this stay fields of their class.
 */
private const val CHUNK_LOCALS = 100

/**
 * How many private members' locals one function may use. Lua 5.1 and LuaJIT allow a function 60 upvalues, which it also
 * needs for the file's other locals (see UpvalueLimit); the members past this stay fields of their class.
 */
private const val FUNCTION_UPVALUES = 30

/** Lua names the generated code gives its own parameters around a member's value (property references' accessors). */
private val GENERATED_NAMES = setOf("self", "value", "receiver", "it")

/**
 * The private members of the file's classes that are locals of the file, with their Lua names: functions
 * (`local function f(self, a)` in a class, `local function f(a)` in an object, called `f(obj, a)` and `f(a)`) and plain
 * properties of objects and companion objects, which their object's initializer assigns. Members of local and anonymous
 * classes stay fields, and so do those of an object that is initialized on first use (see LazyInit) when code that can run
 * before that, such as a nested class's, uses them: only reading the object's table runs its initializer.
 */
internal fun FileTransformer.planPrivateLocals(): Map<KtNamedDeclaration, String> {
    val roots = file.declarations.filterIsInstance<KtClassOrObject>().filter { !interop.isExternalDeclaration(it) }
    val candidates = roots.flatMap { privateCandidates(it) }.toSet()
    if (candidates.isEmpty()) return emptyMap()
    val unsafe = HashSet<KtNamedDeclaration>()
    for (root in roots) {
        PsiTreeUtil.collectElementsOfType(root, KtNameReferenceExpression::class.java).forEach { ref ->
            val target = ref.mainReference.resolve() as? KtNamedDeclaration ?: return@forEach
            if (target in candidates && !isSafeUse(ref, target)) unsafe += target
        }
    }
    val chosen = candidates.filter { it !in unsafe }.take((CHUNK_LOCALS - file.declarations.size).coerceAtLeast(0)).toMutableSet()
    for (unit in roots.flatMap(::functionBodies)) {
        val used = unit.flatMap { PsiTreeUtil.collectElementsOfType(it, KtNameReferenceExpression::class.java) }
            .mapNotNullTo(LinkedHashSet()) { it.mainReference.resolve() as? KtNamedDeclaration }.filter { it in chosen }
        chosen -= used.drop(FUNCTION_UPVALUES).toSet()
    }
    val taken = takenNames(roots)
    val result = LinkedHashMap<KtNamedDeclaration, String>()
    for (d in candidates.filter { it in chosen }) {
        val base = LuaNames.of(if (d is KtNamedFunction) naming.function(d) else d.name!!)
        val name = generateSequence(0) { it + 1 }.map { if (it == 0) base else "${base}__$it" }.first { it !in taken }
        taken += name
        result[d] = name
    }
    return result
}

/** The Lua local of [d] when it is a private member compiled as a local of the file (see [planPrivateLocals]). */
internal fun FileTransformer.privateLocal(d: PsiElement?): String? = (d as? KtNamedDeclaration)?.let { privateLocals[it] }

/** The storage of a member property: its field in [receiver], or the local of a private one. */
internal fun FileTransformer.memberSlot(receiver: LuaExpr, p: KtNamedDeclaration): LuaExpr =
    privateLocal(p)?.let(::LuaName) ?: LuaIndex(receiver, LuaString(fieldKey(p)))

/**
 * The code of [c] and of the classes nested in it that becomes one Lua function each: a function, a property's accessors,
 * and the initializers and constructors together (`____init`).
 */
private fun functionBodies(c: KtClassOrObject): List<List<PsiElement>> {
    val own = c.declarations.flatMap { d ->
        when (d) {
            is KtNamedFunction -> listOf(listOf(d))
            is KtProperty -> listOfNotNull(d.getter, d.setter).map { listOf(it) }
            is KtClassOrObject -> functionBodies(d)
            else -> emptyList()
        }
    }
    val construction = c.declarations.filter { it is KtAnonymousInitializer || it is KtSecondaryConstructor } +
        c.declarations.filterIsInstance<KtProperty>().mapNotNull { it.initializer ?: it.delegateExpression } +
        listOfNotNull(c.primaryConstructor) + c.superTypeListEntries
    return own + listOf(construction)
}

/** The private members of [c] and the classes nested in it that can be locals, in declaration order. */
private fun FileTransformer.privateCandidates(c: KtClassOrObject): List<KtNamedDeclaration> {
    if (c is KtEnumEntry || interop.isExternalDeclaration(c)) return emptyList()
    return c.declarations.flatMap { d ->
        when (d) {
            is KtClassOrObject -> privateCandidates(d)
            is KtNamedFunction -> listOfNotNull(d.takeIf { isLocalFunction(it, c) })
            is KtProperty -> listOfNotNull(d.takeIf { isLocalProperty(it, c) })
            else -> emptyList()
        }
    }
}

private fun FileTransformer.isPrivateMember(d: KtCallableDeclaration, owner: KtClassOrObject) =
    d.hasModifier(KtTokens.PRIVATE_KEYWORD) && d.receiverTypeReference == null && classes.collectionBaseOf(owner) == null &&
        d.annotationEntries.none { it.shortName?.asString() == "LuaName" }

/** A private function with a body that is called like any function: not an operator, which other code calls by its name. */
private fun FileTransformer.isLocalFunction(fn: KtNamedFunction, owner: KtClassOrObject) = isPrivateMember(fn, owner) &&
    fn.hasBody() && !fn.isReifiedInline() && !fn.hasModifier(KtTokens.OPERATOR_KEYWORD)

/** A private property of an object with a plain field: no accessors, delegate or constant. */
private fun FileTransformer.isLocalProperty(p: KtProperty, owner: KtClassOrObject) = owner is KtObjectDeclaration &&
    isPrivateMember(p, owner) && p.delegate == null && !p.hasModifier(KtTokens.CONST_KEYWORD) && !hasAccessors(p) &&
    props.problem(p) == null

/**
 * Whether the use [ref] of a private member [target] of an object reaches the object's table only to find the member: its
 * receiver is the object itself or implicit, and the object is initialized by then (its own code runs after its first use).
 */
private fun FileTransformer.isSafeUse(ref: KtNameReferenceExpression, target: KtNamedDeclaration): Boolean {
    val owner = target.containingClassOrObject as? KtObjectDeclaration ?: return true
    val outer = owner.takeIf { it.isCompanion() }?.containingClassOrObject
    val receiver = writtenReceiver(ref)
    if (receiver != null && receiver !is KtThisExpression) {
        val named = (receiver as? KtDotQualifiedExpression)?.selectorExpression ?: receiver
        val resolved = (named as? KtNameReferenceExpression)?.mainReference?.resolve()
        if (resolved != owner && (outer == null || resolved != outer)) return false
    }
    if (!lazyInit.isObservable(owner)) return true
    // local classes and object expressions are created by code that runs later
    val site = generateSequence(ref.parent) { it.parent }.filterIsInstance<KtClassOrObject>()
        .firstOrNull { !it.isLocal && !(it is KtObjectDeclaration && it.isObjectLiteral()) }
    return site == owner || (outer != null && site == outer)
}

/** The receiver written before the member [ref] names (`r.f()`, `r.x`, `r::f`), if any. */
private fun writtenReceiver(ref: KtNameReferenceExpression): KtExpression? {
    val call = (ref.parent as? KtCallExpression)?.takeIf { it.calleeExpression == ref } ?: ref
    return when (val parent = call.parent) {
        is KtQualifiedExpression -> parent.receiverExpression.takeIf { parent.selectorExpression == call }
        is KtCallableReferenceExpression -> parent.receiverExpression
        else -> null
    }
}

/** The Lua names a private member's local must not take: those code in [roots] can see, the file's and the module's. */
private fun FileTransformer.takenNames(roots: List<KtClassOrObject>): MutableSet<String> {
    val taken = HashSet(GENERATED_NAMES)
    for (f in if (globalMode) module.files else setOf(file)) {
        f.declarations.filter {
            it is KtNamedFunction || it is KtProperty || it is KtClassOrObject
        }.forEach { taken += naming.topLevel(it) }
    }
    for (root in roots) {
        PsiTreeUtil.collectElementsOfType(root, KtNamedDeclaration::class.java).filter(::isLuaLocal).mapNotNullTo(taken) {
            it.name?.let(LuaNames::of)
        }
        taken += externalNames(root)
    }
    return taken
}

/** A declaration that is a local of a Lua function: a parameter, or a local variable, function or class. */
private fun isLuaLocal(d: KtNamedDeclaration): Boolean = d is KtParameter || d is KtDestructuringDeclarationEntry ||
    (d is KtProperty && d.isLocal) || (d is KtNamedFunction && d.isLocal) || (d is KtClassOrObject && d.isLocal)

/** The Lua names of the external declarations (globals among them) that [root] uses. */
private fun FileTransformer.externalNames(root: KtClassOrObject): List<String> = with(session) {
    PsiTreeUtil.collectElementsOfType(root, KtNameReferenceExpression::class.java).mapNotNull { ref ->
        ref.mainReference.resolveToSymbol()?.takeIf { interop.isExternal(it) }?.let { interop.luaName(it) }
    }
}

/**
 * Declares the private members of the top-level class [c] (and of the classes nested in it) that are locals, after its
 * class table: `local count` for properties and for functions used before they are defined, then the functions.
 */
internal fun FileTransformer.privateLocalDeclarations(c: KtClassOrObject) {
    val members = privateCandidates(c).filter { privateLocal(it) != null }
    if (members.isEmpty()) return
    val functions = members.filterIsInstance<KtNamedFunction>()
    val usedEarlier = HashSet<PsiElement>()
    val forward = members.filter { d ->
        (d !is KtNamedFunction || d in usedEarlier).also {
            if (d is KtNamedFunction) {
                PsiTreeUtil.collectElementsOfType(d, KtNameReferenceExpression::class.java).mapNotNullTo(usedEarlier) {
                    it.mainReference.resolve()
                }
            }
        }
    }
    if (forward.isNotEmpty()) emit(LuaLocal(forward.map { privateLocal(it)!! }))
    for (fn in functions) {
        val owner = fn.containingClassOrObject!!
        val lua = withClass(owner) {
            withObjectSelf(classRef(owner).takeIf { owner is KtObjectDeclaration }) { function(fn) }
        }
        val params = if (owner is KtObjectDeclaration) lua.params else listOf("self") + lua.params
        emit(LuaFunctionDecl(LuaName(privateLocal(fn)!!), lua.copy(params = params), isLocal = fn !in forward))
    }
}
