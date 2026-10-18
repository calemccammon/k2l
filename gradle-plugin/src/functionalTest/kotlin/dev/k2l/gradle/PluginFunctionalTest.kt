package dev.k2l.gradle

import org.gradle.testkit.runner.GradleRunner
import org.gradle.testkit.runner.TaskOutcome
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Timeout
import org.junit.jupiter.api.io.TempDir
import java.io.File
import java.nio.file.Files
import java.nio.file.Path

@Timeout(value = 5, unit = java.util.concurrent.TimeUnit.MINUTES, threadMode = Timeout.ThreadMode.SEPARATE_THREAD)
class PluginFunctionalTest {
    @TempDir
    lateinit var project: Path

    private val compilerLibs = System.getProperty("k2l.compilerLibs").split(File.pathSeparator).filter { it.isNotEmpty() }

    private fun write(path: String, text: String) {
        val file = project.resolve(path)
        Files.createDirectories(file.parent)
        Files.writeString(file, text)
    }

    private fun runner(vararg args: String) = GradleRunner.create()
        .withProjectDir(project.toFile())
        .withPluginClasspath()
        .withArguments(*args, "--stacktrace", "--info")
        .forwardOutput()

    /** A project whose compiler comes from the jars this test was given instead of a published artifact. */
    private fun sampleProject(extension: String = "") {
        write("settings.gradle", "rootProject.name = 'sample'\n")
        val dirs = compilerLibs.joinToString(", ") { "fileTree(dir: '${it.replace("\\", "/")}', include: '*.jar')" }
        write(
            "build.gradle",
            """
            plugins { id 'dev.k2l' }
            dependencies { k2lCompiler files($dirs) }
            $extension
            """.trimIndent(),
        )
    }

    @Test
    fun compilesIsIncrementalAndWorksWithConfigurationCache() {
        sampleProject("k2l { luaTarget = '5.3'; sourceMap = true }")
        write("src/main/kotlin/main.kt", "import greet.greeting\n\nfun main() {\n    println(greeting())\n}\n")
        write("src/main/kotlin/greet/text.kt", "package greet\n\nfun greeting() = \"hello\"\n")

        val first = runner("compileKotlinToLua", "--configuration-cache").build()
        assertEquals(TaskOutcome.SUCCESS, first.task(":compileKotlinToLua")?.outcome, first.output)
        val out = project.resolve("build/lua")
        val main = Files.readString(out.resolve("main.lua"))
        assertTrue(main.contains("print("), main)
        assertTrue(Files.exists(out.resolve("greet/text.lua")))
        assertTrue(Files.readString(out.resolve("main.lua.map")).contains("\"version\":3"))
        assertTrue(Files.exists(out.resolve("lualib_bundle.lua")))

        val second = runner("compileKotlinToLua", "--configuration-cache").build()
        assertEquals(TaskOutcome.UP_TO_DATE, second.task(":compileKotlinToLua")?.outcome, second.output)
        assertTrue(second.output.contains("Reusing configuration cache"), second.output)

        // Removing a source drops its output; a changed option reruns the task.
        Files.delete(project.resolve("src/main/kotlin/greet/text.kt"))
        write("src/main/kotlin/main.kt", "fun main() {\n    println(\"hi\")\n}\n")
        val third = runner("compileKotlinToLua", "--configuration-cache").build()
        assertEquals(TaskOutcome.SUCCESS, third.task(":compileKotlinToLua")?.outcome, third.output)
        assertFalse(Files.exists(out.resolve("greet/text.lua")))

        // `assemble` runs it too.
        assertEquals(TaskOutcome.UP_TO_DATE, runner("assemble").build().task(":compileKotlinToLua")?.outcome)
    }

    @Test
    fun kotlinErrorFailsBuildWithDiagnostics() {
        sampleProject()
        write("src/main/kotlin/main.kt", "fun main() {\n    val x: Int = \"not a number\"\n}\n")
        val result = runner("compileKotlinToLua").buildAndFail()
        assertEquals(TaskOutcome.FAILED, result.task(":compileKotlinToLua")?.outcome, result.output)
        assertTrue(result.output.contains("main.kt:2:"), result.output)
        assertTrue(result.output.contains("error"), result.output)
    }
}
