package dev.k2l.coverage

import dev.k2l.CompilerOptions
import dev.k2l.K2lCompiler
import dev.k2l.StringSemantics
import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.components.KaDiagnosticCheckerFilter
import org.jetbrains.kotlin.analysis.api.diagnostics.KaSeverity
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.*
import java.io.File

/**
 * Transpiles probes with k2l, many to a file and one file per module. A file Kotlin rejects is not transpiled, so its
 * probes with Kotlin errors are set aside ([Outcome.Inconclusive]) and the others go into the next round; so do those of
 * a file k2l crashes on, one probe to a file, to find the one that crashes it.
 */
class ProbeRunner(private val work: File) {
    private class Job(val id: Int, val probe: ProbeSource)

    private class Placed(val unit: Job, val firstLine: Int, val lastLine: Int)

    private class ProbeFile(val module: SourceModule, val file: File, val placed: List<Placed>)

    /**
     * Runs every probe with the default options; those k2l rejects for want of `--strings utf16` run again with it, and
     * count as supported with [Outcome.NeedsUtf16] if they translate then.
     */
    fun run(apis: List<Api>): List<ApiResult> {
        val jobs = apis.flatMap { it.probes }.mapIndexed { i, p -> Job(i, p) }
        val outcomes = arrayOfNulls<Outcome>(jobs.size)
        runJobs(jobs, CompilerOptions(), outcomes, "default")
        val utf16 = jobs.filter { (outcomes[it.id] as? Outcome.Unsupported)?.message?.contains("--strings utf16") == true }
        val again = arrayOfNulls<Outcome>(jobs.size)
        runJobs(utf16, CompilerOptions(strings = StringSemantics.Utf16), again, "utf16")
        utf16.filter { again[it.id] == Outcome.Supported }.forEach { outcomes[it.id] = Outcome.NeedsUtf16 }
        var next = 0
        return apis.map { api -> ApiResult(api, api.probes.map { outcomes[next++]!! }) }
    }

    private fun runJobs(jobs: List<Job>, options: CompilerOptions, outcomes: Array<Outcome?>, name: String) {
        var pending = jobs.chunked(FILE_SIZE)
        var round = 0
        while (pending.isNotEmpty() && round < MAX_ROUNDS) {
            round++
            val retry = mutableListOf<List<Job>>()
            val files = pending.mapIndexed { i, group -> write(File(work, "$name/round$round/m$i"), group) }
            println("$name round $round: ${files.sumOf { it.placed.size }} probes in ${files.size} files")
            SourceSession.create(files.map { it.module }).use { session ->
                for (f in files) runFile(session, f, options, outcomes, retry)
            }
            pending = retry
        }
        pending.flatten().forEach { outcomes[it.id] = Outcome.Inconclusive("not compiled") }
    }

    private fun runFile(
        session: SourceSession,
        f: ProbeFile,
        options: CompilerOptions,
        outcomes: Array<Outcome?>,
        retry: MutableList<List<Job>>,
    ) {
        val kt = session.files(f.module.name).single()
        val (errors, resolutions) = analyze(kt) { kotlinErrors(kt) to resolutions(kt, f) }
        if (errors.isNotEmpty()) {
            val bad = f.placed.filter { p -> errors.any { (line, _) -> line in p.firstLine..p.lastLine } }
            bad.forEach { p ->
                outcomes[p.unit.id] =
                    Outcome.Inconclusive("Kotlin: " + errors.first { it.first in p.firstLine..p.lastLine }.second)
            }
            val rest = f.placed - bad.toSet()
            // an error outside every probe (or none found) means no probe of the file can be judged on its own
            if (bad.isEmpty()) rest.forEach { outcomes[it.unit.id] = Outcome.Inconclusive("Kotlin: " + errors.first().second) }
            if (bad.isNotEmpty() && rest.isNotEmpty()) retry += rest.map { it.unit }.chunked(FILE_SIZE)
            return
        }
        // a crash (an exception, a stack overflow) is narrowed down to its probe, which k2l then doesn't support
        val compiled = runCatching { K2lCompiler(options).compile(session, f.module, emit = false).diagnostics }
        val diagnostics = compiled.getOrElse { e ->
            if (e !is Exception && e !is StackOverflowError) throw e
            if (f.placed.size == 1) {
                outcomes[f.placed[0].unit.id] =
                    Outcome.Unsupported("k2l crashed: ${e.javaClass.simpleName}: ${e.message?.lineSequence()?.first()}")
            } else {
                retry += f.placed.map { listOf(it.unit) }
            }
            return
        }
        for (p in f.placed) {
            val resolved = resolutions[p.unit.id]
            val message = diagnostics.firstOrNull { it.line in p.firstLine..p.lastLine }?.message
            outcomes[p.unit.id] = when {
                resolved != null -> Outcome.Inconclusive("the probe calls $resolved")
                message != null -> Outcome.Unsupported(message)
                else -> Outcome.Supported
            }
        }
    }

    private fun KaSession.kotlinErrors(kt: KtFile): List<Pair<Int, String>> =
        kt.collectDiagnostics(KaDiagnosticCheckerFilter.ONLY_COMMON_CHECKERS).filter { it.severity == KaSeverity.ERROR }.map { d ->
            val offset = d.textRanges.first().startOffset
            kt.text.substring(0, offset).count { it == '\n' } + 1 to d.defaultMessage.lineSequence().first()
        }

    /** The probes whose call resolves to another declaration than their API, with that declaration. */
    private fun KaSession.resolutions(kt: KtFile, f: ProbeFile): Map<Int, String> {
        val byName = kt.declarations.filterIsInstance<KtNamedFunction>().associateBy { it.name }
        val result = HashMap<Int, String>()
        for (p in f.placed.filter { it.unit.probe.checksResolution }) {
            val fn = byName[probeName(p.unit.id)]
            val init = (fn?.bodyBlockExpression?.statements?.firstOrNull() as? KtProperty)?.initializer ?: continue
            val element = (init as? KtQualifiedExpression)?.selectorExpression ?: init
            val call = element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>()
            val symbol = call?.partiallyAppliedSymbol?.symbol
            val signature = symbol?.let { apiSignature(it) }
            val target = p.unit.probe.target
            if (symbol == null || (signature != target && apiSignature(symbol.fakeOverrideOriginal) != target)) {
                result[p.unit.id] = signature ?: "nothing resolvable"
            }
        }
        return result
    }

    private fun write(dir: File, group: List<Job>): ProbeFile {
        dir.mkdirs()
        val text = StringBuilder()
        val imports = group.flatMap { it.probe.imports }.toSortedSet()
        imports.forEach { text.append("import ").append(it).append('\n') }
        text.append("\nenum class ${ProbeWriter.PROBE_ENUM} { A, B }\n")
        var line = text.count { it == '\n' } + 1
        val placed = group.map { unit ->
            text.append('\n')
            line++
            val code = unit.probe.code.replace(PROBE_NAME, probeName(unit.id))
            text.append(code)
            val lines = code.count { it == '\n' }
            Placed(unit, line, line + lines - 1).also { line += lines }
        }
        val file = File(dir, "Probes.kt")
        file.writeText(text.toString())
        return ProbeFile(SourceModule(dir.name + "_" + dir.parentFile.name, listOf(dir.toPath())), file, placed)
    }

    private fun probeName(id: Int) = "probe$id"

    private companion object {
        const val FILE_SIZE = 150
        const val MAX_ROUNDS = 8
    }
}
