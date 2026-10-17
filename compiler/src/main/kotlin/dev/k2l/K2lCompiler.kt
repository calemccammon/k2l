package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import dev.k2l.lua.LuaPrinter
import dev.k2l.lua.Lualib
import dev.k2l.transform.FileTransformer
import dev.k2l.transform.TransformContext
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.components.KaDiagnosticCheckerFilter
import org.jetbrains.kotlin.analysis.api.diagnostics.KaSeverity
import org.jetbrains.kotlin.psi.KtFile
import java.nio.file.Path
import java.nio.file.Paths

/** A generated Lua file; [path] is relative to the output directory. */
data class LuaOutput(val path: String, val code: String)

data class CompileResult(val outputs: List<LuaOutput>, val diagnostics: List<Diagnostic>) {
    val hasErrors get() = diagnostics.any { it.severity == Severity.Error }
}

class K2lCompiler(private val options: CompilerOptions = CompilerOptions()) {

    fun compile(session: SourceSession, module: SourceModule): CompileResult {
        val outputs = mutableListOf<LuaOutput>()
        val diagnostics = mutableListOf<Diagnostic>()
        val usedFeatures = sortedSetOf<String>()
        for (file in session.files(module.name)) {
            analyze(file) {
                val kotlinErrors = file.collectDiagnostics(KaDiagnosticCheckerFilter.ONLY_COMMON_CHECKERS)
                    .filter { it.severity == KaSeverity.ERROR }
                if (kotlinErrors.isNotEmpty()) {
                    // Don't transpile code the Kotlin compiler would reject.
                    diagnostics += kotlinErrors.map { Diagnostic.at(it.psi, Severity.Error, it.defaultMessage) }
                    return@analyze
                }
                val ctx = TransformContext(options)
                val chunk = FileTransformer(this, file, ctx).transformFile()
                diagnostics += ctx.diagnostics
                usedFeatures += ctx.lualib
                outputs += LuaOutput(outputPath(module, file), render(chunk, ctx))
            }
        }
        if (options.luaLibImport == LuaLibImport.Require && usedFeatures.isNotEmpty()) {
            outputs += LuaOutput("${Lualib.BUNDLE_MODULE}.lua", Lualib.bundle(usedFeatures))
        }
        return CompileResult(outputs, diagnostics)
    }

    private fun render(chunk: dev.k2l.lua.LuaChunk, ctx: TransformContext): String {
        val code = LuaPrinter().print(chunk)
        if (ctx.lualib.isEmpty()) return code
        return when (options.luaLibImport) {
            LuaLibImport.Inline -> Lualib.resolve(ctx.lualib).joinToString("\n\n", postfix = "\n\n") { it.code } + code
            LuaLibImport.Require -> buildString {
                append("local ____lualib = require(\"${Lualib.BUNDLE_MODULE}\")\n")
                ctx.lualibNames.forEach { append("local $it = ____lualib.$it\n") }
                append("\n").append(code)
            }
        }
    }

    private fun outputPath(module: SourceModule, file: KtFile): String {
        val path = Paths.get(file.virtualFile.path)
        val root = module.roots.map(Path::toAbsolutePath).firstOrNull { path.startsWith(it) }
        val relative = root?.relativize(path) ?: path.fileName
        return relative.toString().removeSuffix(".kt") + ".lua"
    }
}
