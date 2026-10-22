package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * A companion that implements an interface or extends a class is a value of that type, so it gets a table of its own; so does
 * one with a member named like a member of the class's instances (`fun ok()` next to `val ok`, `toString`), which the
 * instances would otherwise find on the class table.
 */
internal fun FileTransformer.hasOwnTable(c: KtObjectDeclaration): Boolean = with(session) {
    c.isCompanion() &&
        (c.superTypeListEntries.any { it.typeReference?.type?.expandedSymbol?.classId?.asString() !in MARKER_INTERFACES } || clashes(c))
}

/** Whether a member of companion [c] has the name of a member of its class's instances (or of what the class table holds). */
private fun FileTransformer.clashes(c: KtObjectDeclaration): Boolean {
    val owner = c.containingClassOrObject ?: return false
    val instanceNames = HashSet(CLASS_TABLE_NAMES)
    for (k in classes.hierarchy(owner)) {
        val named = k.declarations.filterIsInstance<KtNamedDeclaration>().filter { it != c } +
            (k as? KtClass)?.primaryConstructorParameters?.filter { it.hasValOrVar() }.orEmpty()
        for (d in named) {
            val name = d.name ?: continue
            instanceNames += name
            val capitalized = name.replaceFirstChar(Char::uppercaseChar)
            if (d is KtProperty || d is KtParameter) instanceNames += listOf("get$capitalized", "set$capitalized")
        }
        if (k is KtClass && k.isData()) instanceNames += k.primaryConstructorParameters.indices.map { "component${it + 1}" } + "copy"
    }
    return c.declarations.any { it is KtNamedDeclaration && it.name in instanceNames }
}

/** Members every class table (or its instances) has: the constructor, `Any`'s members and an enum's. */
private val CLASS_TABLE_NAMES = setOf("new", "toString", "equals", "hashCode", "compareTo", "name", "ordinal")

/**
 * Companion members live on the class table; their initializers run in `____initCompanion`. A companion with a table of
 * its own is declared like a nested object; when its initialization is observable, the class's `____initCompanion` touches
 * it, so constructing the class and using the companion both initialize it.
 */
internal fun FileTransformer.companion(companion: KtObjectDeclaration, ref: LuaExpr): Boolean = with(session) {
    if (hasOwnTable(companion)) {
        declareClass(companion, isLocal = false)
        if (!classes.initNeeded(companion) || !lazyInit.isObservable(companion)) return false
        emitMethod(ref, INIT_COMPANION, emptyList(), listOf(LuaCallStmt(lualibCall("TouchObject", classRef(companion)))))
        return true
    }
    withClass(companion) {
        checkMembers(companion)
        sharedCompanionFlag(companion.containingClassOrObject!!, ref)
        members(companion, ref)
        val init = collect { initializers(companion) }
        if (init.isNotEmpty()) {
            emitMethod(ref, INIT_COMPANION, emptyList(), init)
            if (lazyInit.isObservable(companion)) return@withClass true
            emit(LuaCallStmt(LuaMethodCall(ref, INIT_COMPANION, emptyList())))
        }
        false
    }
}
