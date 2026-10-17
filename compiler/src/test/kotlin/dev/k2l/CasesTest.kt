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
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.concurrent.TimeUnit

/**
 * Every directory in `src/test/cases` is a program:
 * - `main.kt`: the Kotlin input
 * - `expected.lua`: the exact transpiler output (regenerate with `-PupdateGolden`)
 * - `stdout.txt`: what the program prints, produced by the Kotlin/JVM oracle (`kotlinOracle` task)
 * - `errors.txt` (instead of the other two): expected diagnostics, one `line:column: message` per line
 */
class CasesTest {
    @TestFactory
    fun cases(): List<DynamicNode> = modules.map { module ->
        val dir = module.roots.single().toFile()
        val result by lazy { K2lCompiler().compile(session, module) }
        val errors = File(dir, "errors.txt")
        if (errors.isFile) {
            DynamicTest.dynamicTest(module.name) {
                val actual = result.diagnostics.joinToString("") { "${it.line}:${it.column}: ${it.message}\n" }
                if (update) errors.writeText(actual) else assertEquals(errors.readText(), actual)
            }
        } else {
            DynamicContainer.dynamicContainer(
                module.name,
                listOf(
                    DynamicTest.dynamicTest("transpiles") {
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        val expected = File(dir, "expected.lua")
                        val actual = goldenText(result.outputs)
                        if (update) expected.writeText(actual) else assertSameText(expected.readText(), actual)
                    },
                    DynamicTest.dynamicTest("runs") {
                        assumeTrue(luaAvailable, "$lua not found")
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(File(dir, "stdout.txt").readText(), runLua(result.outputs, dir.toPath()))
                    },
                ),
            )
        }
    }

    /** The generated files except the shared lualib bundle; several files are concatenated with headers. */
    private fun goldenText(outputs: List<LuaOutput>): String {
        val files = outputs.filter { it.path != "lualib_bundle.lua" }.sortedBy { it.path }
        return files.singleOrNull()?.code ?: files.joinToString("") { "-- ==== ${it.path} ====\n${it.code}" }
    }

    /** Like assertEquals, but the message points at the first differing line instead of dumping both files. */
    private fun assertSameText(expected: String, actual: String) {
        if (expected == actual) return
        val e = expected.lines()
        val a = actual.lines()
        val i = e.indices.firstOrNull { it >= a.size || e[it] != a[it] } ?: e.size
        val message = "first difference at line ${i + 1}:\n  expected: ${e.getOrNull(i)}\n  actual:   ${a.getOrNull(i)}"
        throw org.opentest4j.AssertionFailedError(message, expected, actual)
    }

    /** Runs the generated files plus any hand-written Lua the case calls into (the `lib` directory). */
    private fun runLua(outputs: List<LuaOutput>, caseDir: Path): String {
        val dir = Files.createTempDirectory("k2l-case")
        try {
            outputs.forEach {
                val path = dir.resolve(it.path)
                Files.createDirectories(path.parent)
                Files.writeString(path, it.code)
            }
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
            val entry = outputs.firstOrNull { it.path == "main.lua" }?.path ?: outputs.first { it.path != "lualib_bundle.lua" }.path
            val process = ProcessBuilder(lua, entry).directory(dir.toFile()).redirectErrorStream(true).start()
            val output = process.inputStream.readBytes().toString(Charsets.UTF_8)
            check(process.waitFor(30, TimeUnit.SECONDS)) { "lua timed out" }
            check(process.exitValue() == 0) { "lua exited with ${process.exitValue()}:\n$output" }
            return output
        } finally {
            dir.toFile().deleteRecursively()
        }
    }

    companion object {
        private val casesDir: Path = Paths.get(System.getProperty("k2l.casesDir") ?: "src/test/cases")
        private val update = System.getProperty("k2l.updateGolden").toBoolean()
        private val lua = System.getProperty("k2l.lua") ?: "lua5.4"
        private val luaAvailable by lazy {
            runCatching { ProcessBuilder(lua, "-v").start().waitFor() == 0 }.getOrDefault(false)
        }

        private val modules: List<SourceModule> by lazy {
            Files.list(casesDir).use { dirs ->
                dirs.filter { Files.isRegularFile(it.resolve("main.kt")) }.sorted().toList()
                    .map { SourceModule(it.fileName.toString(), listOf(it.toAbsolutePath())) }
            }
        }

        // One session for all cases: each case is its own source module, so their declarations don't clash.
        private val session: SourceSession by lazy { SourceSession.create(modules) }

        @JvmStatic
        @AfterAll
        fun closeSession() = session.close()
    }
}
