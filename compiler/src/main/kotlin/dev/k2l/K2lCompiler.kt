package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import dev.k2l.lua.LuaChunk
import dev.k2l.lua.LuaPrinter
import dev.k2l.lua.Lualib
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
    }

    fun compile(session: SourceSession, module: SourceModule): CompileResult {
        val outputs = mutableListOf<LuaOutput>()
        val diagnostics = mutableListOf<Diagnostic>()
        val usedFeatures = sortedSetOf<String>()
        val files = session.files(module.name)
        val moduleContext = moduleContext(module, files)
        for (file in files) {
            analyze(file) {
                val kotlinErrors = file.collectDiagnostics(KaDiagnosticCheckerFilter.ONLY_COMMON_CHECKERS)
                    .filter { it.severity == KaSeverity.ERROR }
                if (kotlinErrors.isNotEmpty()) {
                    // Don't transpile code the Kotlin compiler would reject.
                    diagnostics += kotlinErrors.map { Diagnostic.at(it.psi, Severity.Error, it.defaultMessage) }
                    return@analyze
                }
                val ctx = TransformContext(options)
                val chunk = FileTransformer(this, file, ctx, moduleContext).transformFile()
                diagnostics += ctx.diagnostics
                // A file of only external declarations (Lua bindings) produces no Lua.
                if (chunk.body.isNotEmpty()) outputs += render(chunk, ctx, outputPath(module, file), Paths.get(file.virtualFile.path))
                usedFeatures += ctx.lualib
            }
        }
        if (options.luaLibImport == LuaLibImport.Require && usedFeatures.isNotEmpty()) {
            outputs += LuaOutput("${Lualib.BUNDLE_MODULE}.lua", Lualib.bundle(usedFeatures, options.luaTarget))
        }
        return CompileResult(outputs, diagnostics)
    }

    private fun render(chunk: LuaChunk, ctx: TransformContext, luaPath: String, sourcePath: Path): LuaOutput {
        if (!options.sourceMap) return LuaOutput(luaPath, renderPlain(chunk, ctx))
        val (code, mappings) = LuaPrinter(origins = ctx.origins).printMapped(chunk)
        if (mappings.isEmpty()) return LuaOutput(luaPath, renderPlain(chunk, ctx))
        ctx.lualib += SOURCE_MAP_FEATURE
        ctx.lualibNames += REGISTER_NAME
        // The runtime table is one line, so the code starts after the lines of the header plus that line.
        val top = when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.resolve(ctx.lualib, options.luaTarget).joinToString("\n\n", postfix = "\n") { it.code }

            LuaLibImport.Require -> buildString {
                append("local ____lualib = require(\"${Lualib.BUNDLE_MODULE}\")\n")
                ctx.lualibNames.forEach { append("local $it = ____lualib.$it\n") }
            }
        }
        val offset = top.count { it == '\n' } + REGISTER_LINES + 1
        val map = SourceMap(luaPath, sourcePath, mappings.map { it.copy(luaLine = it.luaLine + offset) })
        val kotlinPath = luaPath.removeSuffix(".lua") + "." + sourcePath.fileName.toString().substringAfterLast('.')
        val register = "$REGISTER_NAME(\"$luaPath\", \"$kotlinPath\", \"${map.runtimeTable()}\")\n"
        return LuaOutput(luaPath, top + register + "\n" + code + "--# sourceMappingURL=${luaPath.substringAfterLast('/')}.map\n", map)
    }

    private fun renderPlain(chunk: LuaChunk, ctx: TransformContext): String {
        val code = LuaPrinter().print(chunk)
        if (ctx.lualib.isEmpty()) return code
        return when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.resolve(ctx.lualib, options.luaTarget).joinToString("\n\n", postfix = "\n\n") { it.code } + code

            LuaLibImport.Require -> buildString {
                append("local ____lualib = require(\"${Lualib.BUNDLE_MODULE}\")\n")
                ctx.lualibNames.forEach { append("local $it = ____lualib.$it\n") }
                append("\n").append(code)
            }
        }
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
        return relative.toString().removeSuffix(".kt") + ".lua"
    }
}
