package dev.k2l.gradle

import org.gradle.api.GradleException
import org.gradle.api.file.RegularFileProperty
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction
import org.gradle.process.ExecOperations
import org.gradle.work.DisableCachingByDefault
import javax.inject.Inject

/**
 * Runs `k2l --check`: reports every Kotlin error and every construct k2l cannot translate, without writing Lua, and fails
 * the build when there are errors. The compiler's report of a passing check goes to [report], which keeps the task up to
 * date while the sources, the options and the compiler are unchanged.
 */
@DisableCachingByDefault(because = "The report embeds absolute paths; checking is cheap to redo")
abstract class K2lCheckTask @Inject constructor(exec: ExecOperations) : K2lTask(exec) {
    @get:OutputFile
    abstract val report: RegularFileProperty

    @TaskAction
    fun check() {
        val sources = existingSources()
        val file = report.get().asFile
        file.parentFile.mkdirs()
        if (sources.isEmpty()) {
            file.writeText("k2l: no Kotlin source directories found\n")
            logger.lifecycle("k2l: no Kotlin source directories found, nothing to check")
            return
        }
        val (status, output) = runCompiler(compilerArgs(sources, listOf("--check")))
        if (status != 0) {
            file.delete()
            throw GradleException("k2l check failed (exit code $status):\n$output")
        }
        file.writeText(output + "\n")
        logger.lifecycle(output)
    }
}
