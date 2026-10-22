package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Assumptions.assumeTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Files
import java.nio.file.Path

class SourceMapTest {
    @TempDir
    lateinit var dir: Path

    private val program = """
        |class Account(var balance: Int) {
        |    fun withdraw(n: Int) {
        |        if (n > balance) {
        |            throw IllegalStateException("insufficient funds")
        |        }
        |        balance -= n
        |    }
        |}
        |
        |fun process(a: Account) {
        |    println("start")
        |    a.withdraw(5)
        |    a.withdraw(500)
        |}
        |
        |fun main() {
        |    val a = Account(10)
        |    process(a)
        |}
        |
    """.trimMargin()

    private fun compile(options: CompilerOptions, source: String = program): CompileResult {
        val src = dir.resolve("src").also { Files.createDirectories(it) }
        Files.writeString(src.resolve("main.kt"), source)
        val module = SourceModule("main", listOf(src))
        return SourceSession.create(listOf(module)).use { K2lCompiler(options).compile(it, module) }
    }

    @Test
    fun `source map decodes to the Kotlin lines of the statements`() {
        val result = compile(CompilerOptions(sourceMap = true))
        assertEquals("", result.diagnostics.joinToString("\n"))
        result.writeTo(dir.resolve("out"))

        val lua = Files.readAllLines(dir.resolve("out/main.lua"))
        val json = Files.readString(dir.resolve("out/main.lua.map"))
        assertTrue(lua.last().startsWith("--# sourceMappingURL=main.lua.map"))
        assertTrue(json.contains("\"version\":3") && json.contains("\"sources\":[\"../src/main.kt\"]"), json)

        val mappings = SourceMap.decode(Regex("\"mappings\":\"([^\"]*)\"").find(json)!!.groupValues[1])
        fun kotlinLineOf(luaText: String): Int {
            val luaLine = lua.indexOfFirst { it.trim().startsWith(luaText) } + 1
            assertTrue(luaLine > 0, "no Lua line starting with $luaText")
            return mappings.single { it.luaLine == luaLine }.origin.line
        }
        assertEquals(4, kotlinLineOf("error("))
        assertEquals(6, kotlinLineOf("self.balance = self.balance - n"))
        assertEquals(11, kotlinLineOf("print(\"start\")"))
        assertEquals(13, kotlinLineOf("a:withdraw(500)"))
        assertEquals(17, kotlinLineOf("local a = Account.new(10)"))
        // Statements keep their columns: `throw` is indented by 12 spaces in Kotlin.
        assertEquals(13, mappings.single { it.origin.line == 4 }.origin.column)
        // And the generated column is the Lua indentation.
        assertEquals(8, mappings.single { it.origin.line == 4 }.luaColumn)
    }

    @Test
    fun `the generated Lua is unchanged without the option`() {
        val plain = compile(CompilerOptions()).outputs.single { it.path == "main.lua" }
        assertFalse(plain.code.contains("SourceMap"))
        assertEquals(null, plain.sourceMap)
    }

    @Test
    fun `an uncaught exception prints a traceback with Kotlin positions`() {
        val interpreters = installedInterpreters
        assumeTrue(interpreters.isNotEmpty(), "no Lua interpreter found")
        for (mode in LuaLibImport.entries) {
            for ((lua, target) in interpreters) {
                val out = dir.resolve("out-$mode-${target.id}")
                compile(CompilerOptions(luaTarget = target, luaLibImport = mode, sourceMap = true)).writeTo(out)
                val (status, output) = runLua(lua, out)
                assertEquals(1, status, "$lua $mode: $output")
                assertTrue(output.contains("start\n"), "$lua $mode: $output")
                assertTrue(output.contains("java.lang.IllegalStateException: insufficient funds"), "$lua $mode: $output")
                // withdraw -> process -> main, at the Kotlin lines of the throw and the two calls.
                for (frame in listOf("main.kt:4:", "main.kt:13:", "main.kt:18:")) {
                    assertTrue(output.contains(frame), "$lua $mode: missing $frame in\n$output")
                }
                // Inlined lualib code (before the program's own lines) has no Kotlin position.
                if (mode == LuaLibImport.Require) {
                    assertFalse(Regex("main\\.lua:\\d+").containsMatchIn(output), "$lua $mode: Lua position left in\n$output")
                }
            }
        }
    }

    @Test
    fun `runtime errors in Lua code are rewritten too`() {
        val interpreters = installedInterpreters
        assumeTrue(interpreters.isNotEmpty(), "no Lua interpreter found")
        val source = """
            |import dev.k2l.lua.*
            |
            |fun main() {
            |    println("before")
            |    Lua.error("raw failure")
            |}
            |
        """.trimMargin()
        for ((lua, target) in interpreters) {
            val out = dir.resolve("out-raw-${target.id}")
            val result = compile(CompilerOptions(luaTarget = target, sourceMap = true), source)
            assertEquals("", result.diagnostics.joinToString("\n"))
            result.writeTo(out)
            val (status, output) = runLua(lua, out)
            assertEquals(1, status, output)
            assertTrue(output.contains("main.kt:5: raw failure"), "$lua: $output")
        }
    }

    @Test
    fun `an uncaught Lua error in a program with try blocks shows the traceback of its site`() {
        val interpreters = installedInterpreters
        assumeTrue(interpreters.isNotEmpty(), "no Lua interpreter found")
        val source = """
            |import dev.k2l.lua.*
            |
            |fun fail(n: Int): Int {
            |    if (n == 0) Lua.error("raw failure")
            |    return n
            |}
            |
            |fun guarded(n: Int): Int = try { fail(n) } catch (e: IllegalStateException) { -1 }
            |
            |fun process(n: Int): Int = fail(n) + 1
            |
            |fun main() {
            |    println(guarded(1))
            |    println(process(0))
            |}
            |
        """.trimMargin()
        for ((lua, target) in interpreters) {
            val out = dir.resolve("out-deep-${target.id}")
            val result = compile(CompilerOptions(luaTarget = target), source)
            assertEquals("", result.diagnostics.joinToString("\n"))
            result.writeTo(out)
            val code = Files.readAllLines(out.resolve("main.lua"))
            // the frame of process(), which called fail()
            val processLine = code.indexOfFirst { it.trim() == "return fail(n) + 1" } + 1
            val (status, output) = runLua(lua, out)
            assertEquals(1, status, output)
            assertTrue(output.contains("raw failure"), "$lua: $output")
            assertTrue(output.contains("main.lua:$processLine:"), "$lua: no frame of process() in\n$output")
        }
    }
}
