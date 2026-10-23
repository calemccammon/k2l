package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.psiUtil.isPrivate

// The file as a Lua chunk: its top-level declarations in order, the exports table (or globals) and the call of main.

internal fun FileTransformer.transformChunk(): LuaChunk {
    renameHidingLocals()
    renameFunctionShadows()
    val topLevel = file.declarations.filter { isTransformedTopLevel(it) }
    val main = topLevel.filterIsInstance<KtNamedFunction>().firstOrNull(::isMain)
    val exported = topLevel.filter { !it.isPrivate() && it != main }
    val globals = globals(exported)
    val forward = forwardDeclared(topLevel, globals)
    val body = exportsTableSetup().toMutableList()
    // Requires go after the exports table is registered, so an import cycle finds it in package.loaded.
    val requiresAt = body.size
    if (forward.isNotEmpty()) body += LuaLocal(forward.flatMap { naming.topLevel(it) })

    val emitted = HashSet<KtDeclaration>()
    val initializers = mutableListOf<LuaStmt>()
    for (decl in file.declarations) {
        val target = if (deferredInit && isFileField(decl)) initializers else body
        emitDeclaration(decl, emitted, target, forward + globals, exported)
    }
    if (tableMode && file !in module.cyclic) {
        exported.filterNot { isFileField(it) }.forEach { body += exportStatements(it) }
    }
    if (deferredInit) body += if (globalMode) initializers else listOf(lazyFileSetup(topLevel.filter(::isFileField), initializers))

    if (main != null) body += mainCall(main)

    val requires = ctx.imports.map { (path, name) -> LuaLocal(listOf(name), listOf(luaCall(LuaName("require"), LuaString(path)))) }
    body.addAll(requiresAt, requires)
    exportsReturn(exported)?.let { body += it }
    body.addAll(0, moduleTableSetup())
    return LuaChunk(body)
}

/**
 * A class must be created after the classes and interfaces it extends, wherever they are declared. The [declared]
 * declarations (forward `local`s and globals) are assigned without `local`.
 */
private fun FileTransformer.emitDeclaration(
    decl: KtDeclaration,
    emitted: MutableSet<KtDeclaration>,
    body: MutableList<LuaStmt>,
    declared: Set<KtDeclaration>,
    exported: List<KtDeclaration>,
): Unit = with(session) {
    if (!emitted.add(decl)) return
    if (decl is KtClassOrObject) {
        classes.superInfo(decl).let { listOfNotNull(it.base) + it.interfaces }
            .filter { it.isTopLevel() && it.containingFile == file }.forEach { emitDeclaration(it, emitted, body, declared, exported) }
    }
    body += collect { withOrigin(decl) { topLevelDeclaration(decl, decl in declared) } }
    if (isShared(decl) && !isSharedField(decl)) body += naming.topLevel(decl).map { assign(sharedRef(it), LuaName(it)) }
    // In an import cycle, other files may run before this one finishes, so export as we go.
    if (file in module.cyclic && decl in exported && !isFileField(decl)) body += exportStatements(decl)
}

private fun FileTransformer.isTransformedTopLevel(decl: KtDeclaration) =
    (decl is KtNamedFunction || decl is KtProperty || (decl is KtClassOrObject && !(decl is KtClass && decl.isAnnotation()))) &&
        !interop.isExternalDeclaration(decl) && !(decl is KtNamedFunction && decl.isReifiedInline())

private fun FileTransformer.exportsTableSetup(): List<LuaStmt> {
    if (!tableMode) return emptyList()
    val table = LuaLocal(listOf(EXPORTS), listOf(LuaTable(emptyList())))
    if (file !in module.cyclic) return listOf(table)
    // Files that require each other see this table, filled in as declarations run.
    return listOf(table, assign(LuaIndex(luaPath("package", "loaded"), LuaString(module.modulePath(file))), LuaName(EXPORTS)))
}

/**
 * With globals, the public [exported] declarations, each of whose Lua names is recorded in [TransformContext.globals]. The
 * names of the internal ones in the module table go in [TransformContext.shared].
 */
private fun FileTransformer.globals(exported: List<KtDeclaration>): Set<KtDeclaration> {
    if (!globalMode) return emptySet()
    val (internal, public) = exported.partition { it.hasModifier(KtTokens.INTERNAL_KEYWORD) }
    public.forEach { decl -> naming.topLevel(decl).forEach { ctx.globals += it to decl as KtNamedDeclaration } }
    internal.filter(::isShared).forEach { decl -> naming.topLevel(decl).forEach { ctx.shared += it to decl as KtNamedDeclaration } }
    return public.toSet()
}

/**
 * With globals, an internal top-level declaration that other files use ([ModuleContext.moduleTable]). Its file defines it
 * as a local and copies it into [MODULE_TABLE], or, for a plain property, keeps it there.
 */
private fun FileTransformer.isShared(decl: KtDeclaration) = globalMode && decl in module.moduleTable && isTransformedTopLevel(decl)

private fun FileTransformer.isSharedField(decl: PsiElement?) =
    decl is KtProperty && !decl.hasAccessorFunctions() && decl.delegate == null && isShared(decl)

/** With globals, the top-level declarations of the file that are Lua locals, by name. */
internal fun FileTransformer.localTopLevelDeclarations(): Map<String, KtNamedDeclaration> = file.declarations
    .filter {
        isTransformedTopLevel(it) && !isSharedField(it) &&
            (it.isPrivate() || it.hasModifier(KtTokens.INTERNAL_KEYWORD) || (it is KtNamedFunction && isMain(it)))
    }
    .flatMap { decl -> naming.topLevel(decl).map { it to decl as KtNamedDeclaration } }
    .toMap()

/** `____internal.name`, a field of the module table. */
private fun FileTransformer.sharedRef(name: String): LuaExpr {
    usesModuleTable = true
    return LuaIndex(LuaName(MODULE_TABLE), LuaString(name))
}

/**
 * When the file uses the module table: `____internal = ____internal or {}`, then a local of it. Whichever file the host
 * loads first creates the table.
 */
private fun FileTransformer.moduleTableSetup(): List<LuaStmt> {
    if (!usesModuleTable) return emptyList()
    return listOf(
        assign(MODULE_TABLE, LuaBinary(LuaBinOp.Or, LuaName(MODULE_TABLE), LuaTable(emptyList()))),
        LuaLocal(listOf(MODULE_TABLE), listOf(LuaName(MODULE_TABLE))),
    )
}

/**
 * The top-level declarations that get a `local` at the start of the file: those used before they are declared, and with
 * globals, the private properties of a deferred file, whose initializers run at its end.
 */
private fun FileTransformer.forwardDeclared(topLevel: List<KtDeclaration>, globals: Set<KtDeclaration>): Set<KtDeclaration> {
    val late = topLevel.filter { globalMode && deferredInit && isFileField(it) && it !in globals && !isSharedField(it) }.toSet()
    val referenced = forwardReferenced(
        topLevel.filterNot { (tableMode && isFileField(it)) || isSharedField(it) || it in globals || it in late }.toSet(),
    )
    return topLevel.filterTo(LinkedHashSet()) { it in referenced || it in late }
}

/**
 * Another file requires this one (an import cycle through the entry file): `require` passes the chunk its module name, a
 * script its command-line arguments, so `main` runs only when the file is the script. With globals it always runs.
 */
private fun FileTransformer.mainCall(main: KtNamedFunction): LuaStmt {
    val run = mainInvocation(main)
    val asScript = LuaBinary(LuaBinOp.Ne, LuaName("..."), LuaString(module.modulePath(file)))
    return if (globalMode || file !in module.imported) run else LuaIf(asScript, listOf(run))
}

/** Runs `main`, passing the command-line arguments as an `Array<String>` when it takes them. */
private fun FileTransformer.mainInvocation(main: KtNamedFunction): LuaStmt {
    val args = if (main.valueParameters.isEmpty()) {
        emptyList()
    } else {
        listOf(LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))))
    }
    val name = LuaName(naming.of(main))
    val call = if (main.hasModifier(KtTokens.SUSPEND_KEYWORD)) {
        listOf(lualibRef(COROUTINES_FEATURE, "__K2L_RunSuspend"), name) + args
    } else {
        listOf(name) + args
    }
    // An uncaught error prints the exception's string and the traceback, and exits with status 1 (RunMain.lua)
    return LuaCallStmt(LuaCall(lualibRef("RunMain", "__K2L_RunMain"), call))
}

/** The chunk's `return`: the exports table, or a table of the [exported] declarations when not in table mode; none for globals. */
private fun FileTransformer.exportsReturn(exported: List<KtDeclaration>): LuaStmt? = when {
    globalMode -> null

    tableMode -> LuaReturn(listOf(LuaName(EXPORTS)))

    exported.isNotEmpty() ->
        LuaReturn(listOf(LuaTable(exported.flatMap { naming.topLevel(it) }.map { n -> LuaField.Named(n, LuaName(n)) })))

    else -> null
}

private fun FileTransformer.exportStatements(decl: KtDeclaration): List<LuaStmt> =
    naming.topLevel(decl).map { name -> assign(LuaIndex(LuaName(EXPORTS), LuaString(name)), LuaName(name)) }

/** `__K2L_LazyFile(____exports, function() <initializers> end, {"names", ...})`: the first use of a field runs them. */
private fun FileTransformer.lazyFileSetup(fields: List<KtDeclaration>, initializers: List<LuaStmt>): LuaStmt {
    val names = LuaTable(fields.flatMap { naming.topLevel(it) }.map { LuaField.Positional(LuaString(it)) })
    return LuaCallStmt(lualibCall("LazyFile", LuaName(EXPORTS), LuaFunction(emptyList(), initializers), names))
}

private fun FileTransformer.isMain(fn: KtNamedFunction) =
    fn.name == "main" && fn.receiverTypeReference == null && fn.valueParameters.size <= 1

/** Top-level declarations referenced textually before they are declared (or inside their own initializer) need a forward `local`. */
private fun FileTransformer.forwardReferenced(candidates: Set<KtDeclaration>): Set<KtDeclaration> = with(session) {
    val result = LinkedHashSet<KtDeclaration>()
    file.accept(object : KtTreeVisitorVoid() {
        override fun visitReferenceExpression(expression: KtReferenceExpression) {
            super.visitReferenceExpression(expression)
            if (expression !is KtNameReferenceExpression) return
            // Members, constructors and enum entries count as references to their top-level class.
            val resolved = expression.mainReference.resolve() ?: return
            val target = generateSequence(resolved) { it.parent }.firstOrNull { it in candidates } as? KtDeclaration ?: return
            if (target is KtProperty && resolved != target) return // a local declared inside the property's initializer
            // a property's own initializer (`val json = lazyParser { ... json ... }`) runs before its `local` is in scope
            val own = (target as? KtProperty)?.let { it.initializer ?: it.delegateExpression }
            val inOwnInitializer = own != null && own.textRange.contains(expression.textRange)
            if (expression.textRange.startOffset < target.textRange.startOffset || inOwnInitializer) result += target
        }
    })
    return candidates.filter { it in result }.toCollection(LinkedHashSet())
}

private fun FileTransformer.topLevelDeclaration(decl: KtDeclaration, forwardDeclared: Boolean): Unit = with(session) {
    if (interop.isExternalDeclaration(decl)) return // implemented in Lua
    if (decl is KtNamedFunction && decl.isReifiedInline()) return // only exists expanded at its calls
    when (decl) {
        is KtNamedFunction -> emit(LuaFunctionDecl(LuaName(naming.of(decl)), function(decl), isLocal = !forwardDeclared))

        is KtProperty -> if (decl.receiverTypeReference != null) {
            extensionPropertyDeclaration(decl, forwardDeclared)
        } else if (decl.hasAccessorFunctions()) {
            accessorPropertyDeclaration(decl, forwardDeclared)
        } else if ((tableMode && isFileField(decl)) || isSharedField(decl)) {
            val field = topLevelRef(decl)
            decl.initializer?.let { init -> emitAll(valueInto(init) { listOf(assign(field, it)) }) }
        } else {
            property(decl, isLocal = !forwardDeclared)
        }

        is KtClassOrObject -> classDeclaration(decl, isLocal = !forwardDeclared)

        is KtTypeAlias -> Unit

        else -> unsupported(decl, "Declaration '${decl.javaClass.simpleName.removePrefix("Kt")}'")
    }
}

/** `local ____strings = require("util.strings")` for another file of the module. */
private fun FileTransformer.moduleRef(other: KtFile): LuaExpr =
    LuaName(ctx.imports.getOrPut(module.modulePath(other)) { ctx.temp(LuaNames.of(other.name.removeSuffix(".kt"))) })

/** A top-level property kept in `____exports`: an exported `var`, or any plain property of a deferred file. */
private fun FileTransformer.isFileField(decl: PsiElement?) =
    isExportedVar(decl) || (deferredInit && decl is KtProperty && FileInit.isField(decl) && !interop.isExternalDeclaration(decl))

internal fun FileTransformer.isExportedVar(decl: PsiElement?) = decl is KtProperty && decl.isTopLevel && decl.isVar && !decl.isPrivate() &&
    !decl.hasAccessorFunctions() && decl.delegate == null

/**
 * A top-level declaration as a Lua value: a local of this file, a field of another file's module, or with globals, a global
 * or a field of the module table.
 */
internal fun FileTransformer.topLevelRef(decl: KtNamedDeclaration, name: String = naming.of(decl)): LuaExpr = when {
    decl.containingFile != file && !globalMode -> LuaIndex(moduleRef(decl.containingKtFile), LuaString(name))
    decl.containingFile != file -> if (isShared(decl)) sharedRef(name) else globalRef(decl, name)
    isSharedField(decl) -> sharedRef(name)
    tableMode && isFileField(decl) -> LuaIndex(LuaName(EXPORTS), LuaString(name))
    else -> LuaName(name)
}

/** The global of another file's public [decl]. A top-level local of this file with its name would hide it. */
private fun FileTransformer.globalRef(decl: KtNamedDeclaration, name: String): LuaExpr {
    check(!decl.hasModifier(KtTokens.INTERNAL_KEYWORD) || !isTransformedTopLevel(decl)) { "${decl.fqName} is not in $MODULE_TABLE" }
    localTopLevel[name]?.let { local ->
        ctx.error(local.nameIdentifier ?: local, "'${local.fqName}' is the Lua local '$name', which hides the global '${decl.fqName}'")
    }
    return LuaName(name)
}
