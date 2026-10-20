package dev.k2l

import dev.k2l.codegen.Lualib
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
import java.util.concurrent.TimeUnit

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
    fun cases(): List<DynamicNode> = modules.map { module ->
        val dir = module.roots.single().toFile()
        val options = caseOptions(dir)
        val result by lazy { K2lCompiler(options).compile(session, module) }
        val errors = File(dir, "errors.txt")
        if (errors.isFile) {
            DynamicTest.dynamicTest(module.name) {
                val actual = result.diagnostics.joinToString("") { d ->
                    "${d.line}:${d.column}: ${d.message}\n" + d.hint?.let { "  hint: $it\n" }.orEmpty()
                }
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
                        val skip = skippedTargets(dir)["5.4"]
                        assumeTrue(skip == null, "skipped on 5.4: $skip")
                        assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(File(dir, "stdout.txt").readText(), runLua(lua, result.outputs, dir.toPath()))
                    },
                ) + otherTargets.map { (target, interpreter) ->
                    // The golden Lua is for 5.4; other targets only have to print the same output.
                    DynamicTest.dynamicTest("runs on ${target.id}") {
                        val skip = skippedTargets(dir)[target.id]
                        assumeTrue(skip == null, "skipped on ${target.id}: $skip")
                        val targetResult = K2lCompiler(options.copy(luaTarget = target)).compile(session, module)
                        assertEquals("", targetResult.diagnostics.joinToString("\n"), "unexpected diagnostics")
                        assertEquals(File(dir, "stdout.txt").readText(), runLua(interpreter, targetResult.outputs, dir.toPath()))
                    }
                },
            )
        }
    }

    /** `options.txt`: `intOverflow=wrap` lines; the Lua target is chosen by the test, not by the case. */
    private fun caseOptions(dir: File): CompilerOptions {
        val lines = File(dir, "options.txt").takeIf { it.isFile }?.readLines().orEmpty().filter { '=' in it }
        val values = lines.associate { it.substringBefore('=').trim() to it.substringAfter('=').trim() }
        require(
            values.keys.all {
                it == "intOverflow" || it == "luaLibImport" || it == "strings" || it == "long64"
            },
        ) { "unknown option in ${dir.name}/options.txt: ${values.keys}" }
        return CompilerOptions(
            luaLibImport =
            values["luaLibImport"]?.let { if (it == "inline") LuaLibImport.Inline else LuaLibImport.Require } ?: LuaLibImport.Require,
            intOverflow = values["intOverflow"]?.let(IntOverflow::parse) ?: IntOverflow.Unchecked,
            strings = values["strings"]?.let(StringSemantics::parse) ?: StringSemantics.Bytes,
            long64 = values["long64"]?.let(Long64::parse) ?: Long64.AsDouble,
        )
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
    private fun runLua(lua: String, outputs: List<LuaOutput>, caseDir: Path): String {
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
            val entry = outputs.firstOrNull { it.path == "main.lua" }?.path ?: outputs.first { it.path != BUNDLE_FILE }.path
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
        private const val BUNDLE_FILE = "${Lualib.BUNDLE_MODULE}.lua"
        private val update = System.getProperty("k2l.updateGolden").toBoolean()
        private val lua = System.getProperty("k2l.lua") ?: "lua5.4"
        private val luaAvailable by lazy { versionOf(lua) != null }

        private fun versionOf(interpreter: String): String? = runCatching {
            val p = ProcessBuilder(interpreter, "-v").redirectErrorStream(true).start()
            p.inputStream.readBytes().toString(Charsets.UTF_8).takeIf { p.waitFor() == 0 }
        }.getOrNull()

        /** Interpreters for the other targets, found by name and confirmed by their version banner. */
        private val otherTargets: List<Pair<LuaTarget, String>> by lazy {
            val candidates = mapOf(
                LuaTarget.Lua51 to (listOf(System.getProperty("k2l.lua51")) + listOf("lua5.1", "lua51", "lua")) to "Lua 5.1",
                LuaTarget.Lua52 to (listOf(System.getProperty("k2l.lua52")) + listOf("lua5.2", "lua52")) to "Lua 5.2",
                LuaTarget.Lua53 to (listOf(System.getProperty("k2l.lua53")) + listOf("lua5.3", "lua53")) to "Lua 5.3",
                LuaTarget.LuaJIT to (listOf(System.getProperty("k2l.luajit")) + listOf("luajit")) to "LuaJIT",
            )
            candidates.mapNotNull { (targetAndNames, banner) ->
                val (target, names) = targetAndNames
                names.filterNotNull().firstOrNull { versionOf(it)?.contains(banner) == true }?.let { target to it }
            }
        }

        private val modules: List<SourceModule> by lazy {
            Files.list(casesDir).use { dirs ->
                val only = System.getProperty("k2l.only")?.split(',')
                dirs.filter {
                    Files.isRegularFile(it.resolve("main.kt")) && (only == null || it.fileName.toString() in only)
                }.sorted().toList()
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
