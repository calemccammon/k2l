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
import dev.k2l.transform.SOURCE_MAP_FEATURE
import dev.k2l.transform.TransformContext
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.components.KaDiagnosticCheckerFilter
import org.jetbrains.kotlin.analysis.api.diagnostics.KaSeverity
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.KtFile
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
        const val NANOS_PER_MILLI = 1_000_000
    }

    /**
     * Transpiles every file of [module]. With [emit] false (`k2l --check`) the files are only analyzed and transformed, to
     * find every diagnostic: no Lua is printed and the result has no outputs.
     */
    fun compile(session: SourceSession, module: SourceModule, emit: Boolean = true): CompileResult {
        val files = session.files(module.name)
        val profile = System.getenv("K2L_PROFILE") != null
        var t0 = System.nanoTime()
        fun lap(what: String) {
            if (profile) System.err.println("[profile] $what ${(System.nanoTime() - t0) / NANOS_PER_MILLI} ms")
            t0 = System.nanoTime()
        }
        val moduleContext = moduleContext(module, files)
        lap("module references")
        val results = files.map { file -> compileFile(file, module, moduleContext, emit) }
        lap("files")
        val outputs = results.mapNotNullTo(mutableListOf()) { it.output }
        // A construct reached more than once (an inline function expanded at several call sites, say) is reported once.
        val diagnostics = results.flatMap { it.diagnostics }.distinctBy { listOf(it.file, it.line, it.column, it.message) }
        val usedFeatures = results.flatMapTo(sortedSetOf()) { it.features }
        if (emit && options.luaLibImport == LuaLibImport.Require && usedFeatures.isNotEmpty()) {
            outputs += LuaOutput("${Lualib.BUNDLE_MODULE}.lua", Lualib.bundle(usedFeatures, options.luaTarget))
        }
        return CompileResult(outputs, diagnostics)
    }

    private class FileResult(val diagnostics: List<Diagnostic>, val output: LuaOutput?, val features: Set<String>)

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
        val output = if (produces) render(chunk, ctx, outputPath(module, file), Paths.get(file.virtualFile.path)) else null
        FileResult(ctx.diagnostics.toList(), output, ctx.lualib.toSet())
    }

    private fun render(chunk: LuaChunk, ctx: TransformContext, luaPath: String, sourcePath: Path): LuaOutput {
        if (!options.sourceMap) return LuaOutput(luaPath, renderPlain(chunk, ctx))
        val (code, mappings) = printer(chunk, ctx, ctx.origins).printMapped(chunk)
        if (mappings.isEmpty()) return LuaOutput(luaPath, renderPlain(chunk, ctx))
        ctx.lualib += SOURCE_MAP_FEATURE
        ctx.lualibNames += REGISTER_NAME
        // The runtime table is one line, so the code starts after the lines of the header plus that line.
        val top = when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.inline(ctx.lualib, ctx.lualibNames, options.luaTarget)
            LuaLibImport.Require -> requireHeader(ctx)
        }
        val offset = top.count { it == '\n' } + REGISTER_LINES + 1
        val map = SourceMap(luaPath, sourcePath, mappings.map { it.copy(luaLine = it.luaLine + offset) })
        val kotlinPath = luaPath.removeSuffix(".lua") + "." + sourcePath.fileName.toString().substringAfterLast('.')
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

    private fun renderPlain(chunk: LuaChunk, ctx: TransformContext): String {
        val code = printer(chunk, ctx, null).print(chunk)
        if (ctx.lualib.isEmpty()) return code
        return when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.inline(ctx.lualib, ctx.lualibNames, options.luaTarget) + "\n" + code
            LuaLibImport.Require -> requireHeader(ctx) + "\n" + code
        }
    }

    /** `local ____lualib = require("lualib_bundle")`, then a local for each runtime name the file refers to. */
    private fun requireHeader(ctx: TransformContext): String = buildString {
        append("local ____lualib = require(\"${Lualib.BUNDLE_MODULE}\")\n")
        ctx.lualibNames.forEach { append("local $it = ____lualib.$it\n") }
    }

    /** Which files reference which: needed to break import cycles and to find entry points. */
    private fun moduleContext(module: SourceModule, files: List<KtFile>): ModuleContext {
        val fileSet = files.toSet()
        val edges = files.associateWith { file ->
            val targets = LinkedHashSet<KtFile>()
            analyze(file) {
                file.accept(object : KtTreeVisitorVoid() {
                    override fun visitReferenceExpression(expression: KtReferenceExpression) {
                        super.visitReferenceExpression(expression)
                        val target = expression.mainReference.resolve()?.containingFile as? KtFile ?: return
                        if (target != file && target in fileSet) targets += target
                    }
                })
            }
            targets
        }
        return ModuleContext(
            files = fileSet,
            modulePath = { outputPath(module, it).removeSuffix(".lua").replace('/', '.') },
            cyclic = cyclicFiles(edges),
            imported = edges.values.flatten().toSet(),
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
