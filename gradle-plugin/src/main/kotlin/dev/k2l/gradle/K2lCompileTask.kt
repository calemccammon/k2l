package dev.k2l.gradle

import org.gradle.api.GradleException
import org.gradle.api.file.DirectoryProperty
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.OutputDirectory
import org.gradle.api.tasks.TaskAction
import org.gradle.process.ExecOperations
import org.gradle.work.DisableCachingByDefault
import javax.inject.Inject

/**
 * Transpiles [sourceDirs] to Lua in [outputDir]. The task is up to date while neither the sources, the options nor the
 * compiler change, and the build fails with the compiler's diagnostics on a Kotlin error.
 */
@DisableCachingByDefault(because = "Generated Lua embeds absolute paths in diagnostics and source maps; not worth sharing")
abstract class K2lCompileTask @Inject constructor(exec: ExecOperations) : K2lTask(exec) {
    @get:Input
    abstract val sourceMap: Property<Boolean>

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty

    @TaskAction
    fun compile() {
        val sources = existingSources()
        val out = outputDir.get().asFile
        // The output directory belongs to this task: drop files of Kotlin sources that no longer exist.
        out.deleteRecursively()
        out.mkdirs()
        if (sources.isEmpty()) {
            logger.lifecycle("k2l: no Kotlin source directories found, nothing to compile")
            return
        }
        // Without --watch the compiler writes no source maps unless asked to.
        val extra = listOf("-o", out.absolutePath) + if (sourceMap.get()) listOf("--source-map") else emptyList()
        val (status, output) = runCompiler(compilerArgs(sources, extra))
        if (status != 0) throw GradleException("k2l failed (exit code $status):\n$output")
        if (output.isNotEmpty()) logger.lifecycle(output)
    }
}
