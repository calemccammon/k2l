package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assumptions.assumeTrue
import org.junit.jupiter.api.DynamicContainer
import org.junit.jupiter.api.DynamicNode
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.opentest4j.AssertionFailedError
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

/**
 * Every directory in `src/test/cases` is a program:
 * - `main.kt`: the Kotlin input
 * - `expected.lua`: the exact transpiler output (regenerate with `-PupdateGolden`)
 * - `stdout.txt`: what the program prints, produced by the Kotlin/JVM oracle (`kotlinOracle` task)
 * - `options.txt` (optional): compiler options for the case, one `name=value` per line (`intOverflow=wrap`, `strings=utf16`, `long64=emulate`)
 * - `errors.txt` (instead of the other two): expected diagnostics, one `line:column: message` per line, each followed by its
 *   `  hint: ...` line if it has one
 */
class CasesTest {
    @TestFactory
    fun cases(): List<DynamicNode> = modules.mapNotNull { module ->
        val dir = module.roots.single().toFile()
        val options = caseOptions(dir)
        val result by lazy { K2lCompiler(options).compile(session, module) }
        val errors = File(dir, "errors.txt")
        if (errors.isFile) {
            // compiled for 5.4 like the golden output, so it runs with that target's tests
            if (!golden) return@mapNotNull null
            DynamicTest.dynamicTest(module.name) {
                val actual = result.diagnostics.joinToString("") { d ->
                    "${d.line}:${d.column}: ${d.message}\n" + d.hint?.let { "  hint: $it\n" }.orEmpty()
                }
                if (update) errors.writeText(actual) else assertEquals(errors.readText(), actual)
            }
        } else {
            DynamicContainer.dynamicContainer(
                module.name,
                // the golden output is 5.4's: its tests run when -PluaTargets selects 5.4 (see LuaInterpreters)
                listOf(
                    DynamicTest.dynamicTest("transpiles") {
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        val expected = File(dir, "expected.lua")
                        val actual = goldenText(result.outputs)
                        if (update) expected.writeText(actual) else assertSameText(expected.readText(), actual)
                    },
                    // every runtime name a file imports is exported by a feature of the runtime it loads
                    DynamicTest.dynamicTest("lualib names") {
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(emptyList<String>(), unexportedLualibNames(result.outputs), "names the runtime does not export")
                    },
                    DynamicTest.dynamicTest("runs") {
                        assumeInterpreter(luaAvailable, "$lua not found")
                        val skip = skippedTargets(dir)["5.4"]
                        assumeTrue(skip == null, "skipped on 5.4: $skip")
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(File(dir, "stdout.txt").readText(), runCase(lua, result.outputs, dir.toPath()))
                    },
                ).takeIf { golden }.orEmpty() + otherTargets.map { (target, interpreter) ->
                    // The golden Lua is for 5.4; other targets only have to print the same output.
                    DynamicTest.dynamicTest("runs on ${target.id}") {
                        val skip = skippedTargets(dir)[target.id]
                        assumeTrue(skip == null, "skipped on ${target.id}: $skip")
                        val targetResult = K2lCompiler(options.copy(luaTarget = target)).compile(session, module)
                        assertEquals("", targetResult.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(File(dir, "stdout.txt").readText(), runCase(interpreter, targetResult.outputs, dir.toPath()))
                    }
                },
            )
        }
    }

    /** The generated files except the shared lualib bundle; several files are concatenated with headers. */
    private fun goldenText(outputs: List<LuaOutput>): String {
        val files = outputs.filter { it.path != BUNDLE_FILE }.sortedBy { it.path }
        return files.singleOrNull()?.code ?: files.joinToString("") { "-- ==== ${it.path} ====\n${it.code}" }
    }

    /** Like assertEquals, but the message points at the first differing line instead of dumping both files. */
    private fun assertSameText(expected: String, actual: String) {
        if (expected == actual) return
        val e = expected.lines()
        val a = actual.lines()
        val i = e.indices.firstOrNull { it >= a.size || e[it] != a[it] } ?: e.size
        val message = "first difference at line ${i + 1}:\n  expected: ${e.getOrNull(i)}\n  actual:   ${a.getOrNull(i)}"
        throw AssertionFailedError(message, expected, actual)
    }

    /** `targets-skip.txt`: lines of `5.1: reason` (or `5.4: reason`, which skips the run of the golden Lua) for known, documented differences on a target. */
    private fun skippedTargets(dir: File): Map<String, String> = File(dir, "targets-skip.txt").takeIf { it.isFile }?.readLines().orEmpty()
        .filter { ':' in it }.associate { it.substringBefore(':').trim() to it.substringAfter(':').trim() }

    /** Runs the generated files plus any hand-written Lua the case calls into (the `lib` directory). */
    private fun runCase(lua: String, outputs: List<LuaOutput>, caseDir: Path): String {
        val dir = Files.createTempDirectory("k2l-case")
        try {
            writeOutputs(dir, outputs)
            val lib = caseDir.resolve("lib")
            if (Files.isDirectory(lib)) {
                Files.walk(lib).use { paths ->
                    paths.filter { it.toString().endsWith(".lua") }.forEach { source ->
                        val target = dir.resolve(caseDir.relativize(source).toString())
                        Files.createDirectories(target.parent)
                        Files.copy(source, target)
                    }
                }
            }
            val entry = outputs.firstOrNull { it.path == "main.lua" }?.path ?: outputs.first { it.path != BUNDLE_FILE }.path
            val (status, output) = runLua(lua, dir, entry)
            check(status == 0) { "lua exited with $status:\n$output" }
            return output
        } finally {
            dir.toFile().deleteRecursively()
        }
    }

    companion object {
        private val casesDir: Path = Paths.get(System.getProperty("k2l.casesDir") ?: "src/test/cases")
        private val update = System.getProperty("k2l.updateGolden").toBoolean()
        private val lua = System.getProperty("k2l.lua") ?: "lua5.4"
        private val luaAvailable by lazy { luaVersionBanner(lua) != null }

        /** Whether the tests of the golden 5.4 output run (`-PluaTargets`). */
        private val golden = LuaInterpreters.runsTargetFreeTests()

        /** Interpreters for the other targets that `-PluaTargets` selects. */
        private val otherTargets: List<Pair<LuaTarget, String>> by lazy {
            listOf(LuaTarget.Lua51, LuaTarget.Lua52, LuaTarget.Lua53, LuaTarget.LuaJIT).filter(LuaInterpreters::selects)
                .mapNotNull { target -> LuaInterpreters.of(target)?.let { target to it } }
        }

        private val modules: List<SourceModule> by lazy {
            programModules(casesDir.toFile(), System.getProperty("k2l.only")?.split(','))
        }

        // One session for all cases: each case is its own source module, so their declarations don't clash.
        private val session: SourceSession by lazy { SourceSession.create(modules) }

        @JvmStatic
        @AfterAll
        fun closeSession() = session.close()
    }
}
