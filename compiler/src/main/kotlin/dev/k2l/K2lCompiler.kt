package dev.k2l

import dev.k2l.codegen.LambdaHoisting
import dev.k2l.codegen.LuaChunk
import dev.k2l.codegen.LuaPrinter
import dev.k2l.codegen.LuaStmt
import dev.k2l.codegen.Lualib
import dev.k2l.codegen.UpvalueLimit
import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import dev.k2l.transform.FileTransformer
import dev.k2l.transform.ModuleContext
import dev.k2l.transform.ModuleTable
import dev.k2l.transform.SOURCE_MAP_FEATURE
import dev.k2l.transform.TransformContext
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.components.KaDiagnosticCheckerFilter
import org.jetbrains.kotlin.analysis.api.diagnostics.KaSeverity
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.KtDeclaration
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtNamedDeclaration
import org.jetbrains.kotlin.psi.KtReferenceExpression
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
import java.nio.file.Path
import java.nio.file.Paths

/** A generated Lua file; [path] is relative to the output directory. */
data class LuaOutput(val path: String, val code: String, val sourceMap: SourceMap? = null)

data class CompileResult(val outputs: List<LuaOutput>, val diagnostics: List<Diagnostic>) {
    val hasErrors get() = diagnostics.any { it.severity == Severity.Error }
}

class K2lCompiler(private val options: CompilerOptions = CompilerOptions()) {
    private companion object {
        const val REGISTER_NAME = "__K2L_SourceMapRegister"
        const val REGISTER_LINES = 1

        /** The runtime's table: a local of each file, and with [ModuleMode.Global] also the global the bundle sets. */
        const val LUALIB_GLOBAL = "____lualib"
    }

    /**
     * Transpiles every file of [module]. With [emit] false (`k2l --check`) the files are only analyzed and transformed, to
     * find every diagnostic: no Lua is printed and the result has no outputs.
     */
    fun compile(session: SourceSession, module: SourceModule, emit: Boolean = true): CompileResult {
        val files = session.files(module.name)
        val moduleContext = moduleContext(module, files)
        val results = files.map { file -> compileFile(file, module, moduleContext, emit) }
        val printed = results.mapNotNull { it.printed }
        val moduleCode = printed.map { it.code }
        val outputs = printed.mapTo(mutableListOf()) { assemble(it, moduleCode) }
        // A construct reached more than once (an inline function expanded at several call sites, say) is reported once.
        val diagnostics = results.flatMap { it.diagnostics }.distinctBy { listOf(it.file, it.line, it.column, it.message) } +
            GlobalClashes.of(results.flatMap { it.globals }, results.flatMap { it.shared }, LUALIB_GLOBAL)
        val usedFeatures = results.flatMapTo(sortedSetOf()) { it.features }
        if (emit && options.luaLibImport == LuaLibImport.Require && usedFeatures.isNotEmpty()) {
            val global = options.moduleMode == ModuleMode.Global
            val bundle = Lualib.bundle(usedFeatures, options.luaTarget, outputs.map { it.code }, global)
            outputs += LuaOutput("${Lualib.BUNDLE_MODULE}.lua", bundle)
        }
        return CompileResult(outputs, diagnostics)
    }

    private class FileResult(
        val diagnostics: List<Diagnostic>,
        val printed: PrintedFile?,
        val features: Set<String>,
        val globals: List<Pair<String, KtNamedDeclaration>> = emptyList(),
        val shared: List<Pair<String, KtNamedDeclaration>> = emptyList(),
    )

    /** A file's Lua without the runtime header, which waits for the other files (the runtime keeps what they all use). */
    private class PrintedFile(
        val luaPath: String,
        val sourcePath: Path,
        val ctx: TransformContext,
        val code: String,
        val mappings: List<LineMapping>?,
    )

    private fun compileFile(file: KtFile, module: SourceModule, moduleContext: ModuleContext, emit: Boolean): FileResult = analyze(file) {
        val kotlinErrors = file.collectDiagnostics(KaDiagnosticCheckerFilter.ONLY_COMMON_CHECKERS)
            .filter { it.severity == KaSeverity.ERROR }
        if (kotlinErrors.isNotEmpty()) {
            // Don't transpile code the Kotlin compiler would reject.
            // The first text range is where kotlinc puts its caret (the initializer of a mistyped `val`, not the `val`).
            val diagnostics = kotlinErrors.map { Diagnostic.at(it.psi, Severity.Error, it.defaultMessage, it.textRanges.first()) }
            return@analyze FileResult(diagnostics, null, emptySet())
        }
        val ctx = TransformContext(options)
        val chunk = FileTransformer(this, file, ctx, moduleContext).transformFile()
        // A file of only external declarations (Lua bindings) produces no Lua.
        val produces = emit && chunk.body.isNotEmpty()
        val printed = if (produces) print(chunk, ctx, outputPath(module, file), Paths.get(file.virtualFile.path)) else null
        FileResult(ctx.diagnostics.toList(), printed, ctx.lualib.toSet(), ctx.globals.toList(), ctx.shared.toList())
    }

    private fun print(chunk: LuaChunk, ctx: TransformContext, luaPath: String, sourcePath: Path): PrintedFile {
        if (options.sourceMap) {
            val (code, mappings) = printer(chunk, ctx, ctx.origins).printMapped(chunk)
            if (mappings.isNotEmpty()) {
                ctx.lualib += SOURCE_MAP_FEATURE
                ctx.lualibNames += REGISTER_NAME
                return PrintedFile(luaPath, sourcePath, ctx, code, mappings)
            }
        }
        return PrintedFile(luaPath, sourcePath, ctx, printer(chunk, ctx, null).print(chunk), null)
    }

    /**
     * [file] with its runtime header. An inlined runtime keeps what [moduleCode], the code of every file of the module, uses:
     * an object made by one file's runtime can reach the code of another.
     */
    private fun assemble(file: PrintedFile, moduleCode: List<String>): LuaOutput {
        val luaPath = file.luaPath
        val code = file.code
        val ctx = file.ctx
        if (ctx.lualib.isEmpty()) return LuaOutput(luaPath, code)
        val top = when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.inline(ctx.lualib, ctx.lualibNames, moduleCode, options.luaTarget)
            LuaLibImport.Require -> requireHeader(ctx)
        }
        val mappings = file.mappings ?: return LuaOutput(luaPath, top + "\n" + code)
        // The runtime table is one line, so the code starts after the lines of the header plus that line.
        val offset = top.count { it == '\n' } + REGISTER_LINES + 1
        val map = SourceMap(luaPath, file.sourcePath, mappings.map { it.copy(luaLine = it.luaLine + offset) })
        val kotlinPath = luaPath.removeSuffix(".lua") + "." + file.sourcePath.fileName.toString().substringAfterLast('.')
        val register = "$REGISTER_NAME(\"$luaPath\", \"$kotlinPath\", \"${map.runtimeTable()}\")\n"
        return LuaOutput(luaPath, top + register + "\n" + code + "--# sourceMappingURL=${luaPath.substringAfterLast('/')}.map\n", map)
    }

    /** Lambdas without captures are created once ([LambdaHoisting]); Lua 5.1 and LuaJIT limit upvalues ([UpvalueLimit]). */
    private fun printer(chunk: LuaChunk, ctx: TransformContext, origins: Map<LuaStmt, Origin>?): LuaPrinter {
        val limited = options.luaTarget.limitsUpvalues
        val hoisting = LambdaHoisting.plan(chunk, ctx.lualibNames, limited)
        val prologues = if (limited) UpvalueLimit.prologues(chunk, ctx.lualibNames, hoisting.upvalues) else emptyMap()
        return LuaPrinter(origins = origins, prologues = prologues, hoisting = hoisting)
    }

    /**
     * `local ____lualib = require("lualib_bundle")`, then a local for each runtime name the file refers to. With
     * [ModuleMode.Global] the bundle has set the global `____lualib` instead.
     */
    private fun requireHeader(ctx: TransformContext): String = buildString {
        if (options.moduleMode == ModuleMode.Require) append("local $LUALIB_GLOBAL = require(\"${Lualib.BUNDLE_MODULE}\")\n")
        ctx.lualibNames.forEach { append("local $it = $LUALIB_GLOBAL.$it\n") }
    }

    /**
     * Which files reference which: needed to break import cycles and to find entry points. With globals, also which internal
     * declarations other files use ([ModuleTable]).
     */
    private fun moduleContext(module: SourceModule, files: List<KtFile>): ModuleContext {
        val global = options.moduleMode == ModuleMode.Global
        val fileSet = files.toSet()
        val shared = HashSet<KtDeclaration>()
        val edges = files.associateWith { file ->
            val targets = LinkedHashSet<KtFile>()
            analyze(file) {
                file.accept(object : KtTreeVisitorVoid() {
                    override fun visitReferenceExpression(expression: KtReferenceExpression) {
                        super.visitReferenceExpression(expression)
                        val resolved = expression.mainReference.resolve() ?: return
                        val target = resolved.containingFile as? KtFile ?: return
                        if (target !in fileSet) return
                        if (target != file) targets += target
                        if (global) ModuleTable.sharedBy(expression, resolved, file)?.let { shared += it }
                    }
                })
            }
            if (global) shared += ModuleTable.usedUnnamed(file)
            targets
        }
        return ModuleContext(
            files = fileSet,
            modulePath = { outputPath(module, it).removeSuffix(".lua").replace('/', '.') },
            // globals need no exports table registered before the files that read them run
            cyclic = if (global) emptySet() else cyclicFiles(edges),
            imported = edges.values.flatten().toSet(),
            moduleTable = shared,
        )
    }

    /** Files on some import cycle (members of a strongly connected component of size > 1). */
    private fun cyclicFiles(edges: Map<KtFile, Set<KtFile>>): Set<KtFile> {
        val result = HashSet<KtFile>()
        for (start in edges.keys) {
            // A file is cyclic if it can reach itself.
            val seen = HashSet<KtFile>()
            val stack = ArrayDeque(edges[start].orEmpty())
            while (stack.isNotEmpty()) {
                val next = stack.removeLast()
                if (next == start) {
                    result += start
                    break
                }
                if (seen.add(next)) stack.addAll(edges[next].orEmpty())
            }
        }
        return result
    }

    private fun outputPath(module: SourceModule, file: KtFile): String {
        val path = Paths.get(file.virtualFile.path)
        val root = module.roots.map(Path::toAbsolutePath).firstOrNull { path.startsWith(it) }
        val relative = root?.relativize(path) ?: path.fileName
        // `require("text.Style.common")` would look for text/Style/common.lua: dots of a file name (Style.common.kt) become `_`
        val name = relative.fileName.toString().removeSuffix(".kt").replace('.', '_') + ".lua"
        return relative.parent?.resolve(name)?.toString() ?: name
    }
}
