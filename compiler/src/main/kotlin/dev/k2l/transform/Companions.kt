package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** A companion that implements an interface or extends a class is a value of that type, so it gets a table of its own. */
internal fun FileTransformer.hasOwnTable(c: KtObjectDeclaration): Boolean = with(session) {
    c.isCompanion() && c.superTypeListEntries.any { it.typeReference?.type?.expandedSymbol?.classId?.asString() !in MARKER_INTERFACES }
}

/**
 * Companion members live on the class table; their initializers run in `____initCompanion`. A companion with a table of
 * its own is declared like a nested object; when its initialization is observable, the class's `____initCompanion` touches
 * it, so constructing the class and using the companion both initialize it, as on the JVM.
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
            if (lazyInit.isObservable(companion)) return@withClass true
            emit(LuaCallStmt(LuaMethodCall(ref, INIT_COMPANION, emptyList())))
        }
        false
    }
}
