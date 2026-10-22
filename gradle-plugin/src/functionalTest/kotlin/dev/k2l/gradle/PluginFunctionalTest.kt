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

    /**
     * A project whose compiler is the runtime-libs zip this test was given instead of a published artifact; the plugin
     * unpacks it like the published one.
     */
    private fun sampleProject(extension: String = "") {
        write("settings.gradle", "rootProject.name = 'sample'\n")
        val zips = compilerLibs.joinToString(", ") { "'${it.replace("\\", "/")}'" }
        write(
            "build.gradle",
            """
            plugins { id 'dev.k2l' }
            dependencies { k2lCompiler files($zips) }
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
    fun luaLibImportOptionReachesTheCompiler() {
        sampleProject("k2l { luaLibImport = 'inline' }")
        write("src/main/kotlin/main.kt", "fun main() {\n    println(listOf(1, 2).map { it * 2 })\n}\n")
        val result = runner("compileKotlinToLua").build()
        assertEquals(TaskOutcome.SUCCESS, result.task(":compileKotlinToLua")?.outcome, result.output)
        val out = project.resolve("build/lua")
        assertTrue(Files.readString(out.resolve("main.lua")).contains("local ____lualib = {}"), Files.readString(out.resolve("main.lua")))
        assertFalse(Files.exists(out.resolve("lualib_bundle.lua")))
    }

    @Test
    fun checkReportsWithoutWritingLuaAndFailsOnUnsupportedConstructs() {
        sampleProject()
        write("src/main/kotlin/main.kt", "fun main() {\n    println(\"hi\")\n}\n")
        val clean = runner("k2lCheck", "--configuration-cache").build()
        assertEquals(TaskOutcome.SUCCESS, clean.task(":k2lCheck")?.outcome, clean.output)
        assertTrue(clean.output.contains("k2l: checked 1 file(s): 0 errors, 0 warnings"), clean.output)
        assertFalse(Files.exists(project.resolve("build/lua")), "k2lCheck must not write Lua")
        val again = runner("k2lCheck", "--configuration-cache").build()
        assertEquals(TaskOutcome.UP_TO_DATE, again.task(":k2lCheck")?.outcome, again.output)

        write(
            "src/main/kotlin/main.kt",
            "import java.util.Vector\n\nclass Numbers : Vector<Int>()\n\nfun main() {\n    println(Numbers().size)\n}\n",
        )
        val failed = runner("k2lCheck").buildAndFail()
        assertEquals(TaskOutcome.FAILED, failed.task(":k2lCheck")?.outcome, failed.output)
        assertTrue(failed.output.contains("main.kt:3:17: error: Extending 'Vector<Int>()' is not supported"), failed.output)
        assertTrue(failed.output.contains("hint: extend java.util.ArrayList"), failed.output)
        assertTrue(failed.output.contains("1 error, 0 warnings"), failed.output)
        assertFalse(Files.exists(project.resolve("build/lua")))
    }

    @Test
    fun multiPackageProjectWithImportCycle() {
        sampleProject()
        // main.kt and game/World.kt import each other; ui/Style.common.kt has a dotted name; api/Hooks.kt is called from Lua.
        write(
            "src/main/kotlin/main.kt",
            "import game.World\nimport ui.styled\n\nvar frames = 0\n\nfun main() {\n    println(styled(World.describe()))\n}\n",
        )
        write(
            "src/main/kotlin/game/World.kt",
            "package game\n\nimport frames\n\nobject World {\n    fun describe() = \"frames \$frames\"\n}\n",
        )
        write("src/main/kotlin/ui/Style.common.kt", "package ui\n\nfun styled(s: String) = \"[\$s]\"\n")
        write(
            "src/main/kotlin/api/Hooks.kt",
            "package api\n\nimport dev.k2l.lua.LuaName\n\nval started = listOf(\"boot\").also { println(\"hooks ready\") }\n\n" +
                "@LuaName(\"on_load\")\nfun onLoad(name: String) = \"loaded \$name\"\n",
        )

        val result = runner("compileKotlinToLua").build()
        assertEquals(TaskOutcome.SUCCESS, result.task(":compileKotlinToLua")?.outcome, result.output)
        val out = project.resolve("build/lua")
        val main = Files.readString(out.resolve("main.lua"))
        assertTrue(main.contains("require(\"game.World\")") && main.contains("require(\"ui.Style_common\")"), main)
        // main.lua is required by game/World.lua, so it runs main only as the script
        assertTrue(main.contains("if ... ~= \"main\" then"), main)
        assertTrue(Files.readString(out.resolve("game/World.lua")).contains("require(\"main\")"))
        assertTrue(Files.exists(out.resolve("ui/Style_common.lua")))
        val hooks = Files.readString(out.resolve("api/Hooks.lua"))
        assertTrue(hooks.contains("____exports.on_load = on_load") && hooks.contains("__K2L_LazyFile(____exports"), hooks)
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
