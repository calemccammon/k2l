package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.psiUtil.isPrivate

// The file as a Lua chunk: its top-level declarations in order, the exports table and the call of main.

internal fun FileTransformer.transformChunk(): LuaChunk {
    renameHidingLocals()
    renameFunctionShadows()
    val topLevel = file.declarations.filter { isTransformedTopLevel(it) }
    val forward = forwardReferenced(topLevel.filterNot { tableMode && isFileField(it) }.toSet())
    val main = topLevel.filterIsInstance<KtNamedFunction>().firstOrNull(::isMain)
    val exported = topLevel.filter { !it.isPrivate() && it != main }
    val body = exportsTableSetup().toMutableList()
    // Requires go after the exports table is registered, so an import cycle finds it in package.loaded.
    val requiresAt = body.size
    if (forward.isNotEmpty()) body += LuaLocal(forward.flatMap { naming.topLevel(it) })

    val emitted = HashSet<KtDeclaration>()
    val initializers = mutableListOf<LuaStmt>()
    for (decl in file.declarations) {
        val target = if (deferredInit && isFileField(decl)) initializers else body
        emitDeclaration(decl, emitted, target, forward, exported)
    }
    if (tableMode && file !in module.cyclic) {
        exported.filterNot { isFileField(it) }.forEach { body += exportStatements(it) }
    }
    if (deferredInit) body += lazyFileSetup(topLevel.filter(::isFileField), initializers)

    if (main != null) {
        // Another file requires this one (an import cycle through the entry file): `require` passes the chunk its
        // module name, a script its command-line arguments, so `main` runs only when the file is the script.
        val run = mainInvocation(main)
        val asScript = LuaBinary(LuaBinOp.Ne, LuaName("..."), LuaString(module.modulePath(file)))
        body += if (file !in module.imported) run else LuaIf(asScript, listOf(run))
    }

    val requires = ctx.imports.map { (path, name) -> LuaLocal(listOf(name), listOf(luaCall(LuaName("require"), LuaString(path)))) }
    body.addAll(requiresAt, requires)
    body.addAll(requiresAt + requires.size, hoistedLongs())
    exportsReturn(exported)?.let { body += it }
    return LuaChunk(body)
}

/** A class must be created after the classes and interfaces it extends, wherever they are declared. */
private fun FileTransformer.emitDeclaration(
    decl: KtDeclaration,
    emitted: MutableSet<KtDeclaration>,
    body: MutableList<LuaStmt>,
    forward: Set<KtDeclaration>,
    exported: List<KtDeclaration>,
): Unit = with(session) {
    if (!emitted.add(decl)) return
    if (decl is KtClassOrObject) {
        classes.superInfo(decl).let { listOfNotNull(it.base) + it.interfaces }
            .filter { it.isTopLevel() && it.containingFile == file }.forEach { emitDeclaration(it, emitted, body, forward, exported) }
    }
    body += collect { withOrigin(decl) { topLevelDeclaration(decl, decl in forward) } }
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

/** Runs `main`, passing the command-line arguments as an `Array<String>` when it takes them. */
private fun FileTransformer.mainInvocation(main: KtNamedFunction): LuaStmt {
    val args = if (main.valueParameters.isEmpty()) {
        emptyList()
    } else {
        listOf(
            LuaCall(lualibRef("Collections", "__K2L_ArrayOf"), listOf(LuaName("..."))),
        )
    }
    val name = LuaName(naming.of(main))

    // An uncaught error prints as on the JVM and exits with status 1 (Uncaught.lua); with --source-map its traceback
    // shows Kotlin positions, since the source-map runtime rewrites debug.traceback.
    fun run() = lualibRef("Uncaught", "__K2L_Main")
    if (main.hasModifier(KtTokens.SUSPEND_KEYWORD)) {
        return LuaCallStmt(LuaCall(run(), listOf(lualibRef(COROUTINES_FEATURE, "__K2L_RunSuspend"), name) + args))
    }
    // protected calls nested deeper than Lua's C stack allows run in coroutines the driver resumes (DeepPcall.lua)
    if (module.usesTry && target.drivesDeepPcall) {
        return LuaCallStmt(LuaCall(lualibRef("DeepPcall", "__K2L_DeepMain"), listOf(name) + args))
    }
    return LuaCallStmt(LuaCall(run(), listOf(name) + args))
}

/** The chunk's `return`: the exports table, or a table of the [exported] declarations when not in table mode. */
private fun FileTransformer.exportsReturn(exported: List<KtDeclaration>): LuaStmt? = when {
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
        } else if (tableMode && isFileField(decl)) {
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

/** A top-level declaration as a Lua value: a local of this file or a field of another file's module. */
internal fun FileTransformer.topLevelRef(decl: KtNamedDeclaration, name: String = naming.of(decl)): LuaExpr = when {
    decl.containingFile != file -> LuaIndex(moduleRef(decl.containingKtFile), LuaString(name))
    tableMode && isFileField(decl) -> LuaIndex(LuaName(EXPORTS), LuaString(name))
    else -> LuaName(name)
}
