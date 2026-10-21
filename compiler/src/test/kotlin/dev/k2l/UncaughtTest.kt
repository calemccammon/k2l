package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Assumptions.assumeTrue
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Files
import java.nio.file.Path

/**
 * An uncaught exception prints like on the JVM on every target: `Exception in thread "main" ...` and its `Caused by:` lines
 * on stderr, then a Lua traceback (with Kotlin positions under --source-map), and the program exits with status 1.
 */
class UncaughtTest {
    @TempDir
    lateinit var dir: Path

    /**
     * A program, what it prints, the first lines of its stderr (before the traceback) and a Kotlin line its traceback shows
     * under source maps: that of the `throw`, or of a call on the way when a `catch` that does not match raises it again.
     */
    private class Program(val source: String, val stdout: String, val stderr: List<String>, val throwLine: Int)

    @TestFactory
    fun uncaught(): List<DynamicTest> = PROGRAMS.keys.flatMap { name ->
        listOf(false, true).map { sourceMap ->
            DynamicTest.dynamicTest(if (sourceMap) "$name with source maps" else name) { check(name, sourceMap) }
        }
    }

    private fun check(name: String, sourceMap: Boolean) {
        assumeTrue(installedInterpreters.isNotEmpty(), "no Lua interpreter found")
        val program = PROGRAMS.getValue(name)
        for ((lua, target) in installedInterpreters) {
            val out = dir.resolve("$name-${target.id}")
            val result = K2lCompiler(CompilerOptions(luaTarget = target, sourceMap = sourceMap)).compile(session, module(name))
            assertEquals("", result.diagnostics.joinToString("\n"))
            result.writeTo(out)
            val (status, stdout, stderr) = runLua(lua, out, separateStderr = true)
            val label = "$name on $lua${if (sourceMap) " with source maps" else ""}:\n$stderr"
            assertEquals(1, status, label)
            assertEquals(program.stdout, stdout, label)
            val lines = stderr.lines()
            // a line starting with "..." only has to end the same
            val header = lines.take(program.stderr.size).zip(program.stderr) { line, expected ->
                if (expected.startsWith("...") && line.endsWith(expected.removePrefix("..."))) expected else line
            }
            assertEquals(program.stderr, header, label)
            // then the Lua traceback, its frames indented like the JVM's
            assertEquals("stack traceback:", lines[program.stderr.size], label)
            assertTrue(lines.drop(program.stderr.size + 1).filter { it.isNotEmpty() }.all { it.startsWith("\t") }, label)
            if (sourceMap) {
                assertTrue(stderr.contains("main.kt:${program.throwLine}:"), label)
                assertFalse(Regex("main\\.lua:\\d+").containsMatchIn(stderr), label)
            } else {
                assertTrue(Regex("\tmain\\.lua:\\d+: in ").containsMatchIn(stderr), label)
            }
        }
    }

    @TestFactory
    fun printedOutputComesFirst(): List<DynamicTest> = installedInterpreters.map { (lua, target) ->
        DynamicTest.dynamicTest("on $lua") {
            val out = dir.resolve("merged-${target.id}")
            K2lCompiler(CompilerOptions(luaTarget = target)).compile(session, module("plain")).writeTo(out)
            val output = runLua(lua, out).stdout
            assertTrue(output.startsWith("start\nException in thread \"main\" "), output)
        }
    }

    companion object {
        private val PROGRAMS = mapOf(
            "plain" to Program(
                """
                |fun check(n: Int) {
                |    if (n > 2) throw IllegalStateException("too big: ${'$'}n")
                |}
                |
                |fun main() {
                |    println("start")
                |    for (i in 0..5) check(i)
                |}
                """.trimMargin(),
                "start\n",
                listOf("Exception in thread \"main\" java.lang.IllegalStateException: too big: 3"),
                2,
            ),
            // Caused by: lines for the whole chain, after the finally block has run
            "cause" to Program(
                """
                |class AppError(message: String, cause: Throwable?) : RuntimeException(message, cause)
                |
                |fun parse(s: String): Int = try { s.toInt() } catch (e: NumberFormatException) {
                |    throw IllegalArgumentException(e)
                |}
                |
                |fun load(s: String): Int = try { parse(s) } catch (e: IllegalArgumentException) {
                |    throw AppError("load failed", e)
                |}
                |
                |fun main() {
                |    println("start")
                |    try { load("x") } finally { println("finally") }
                |}
                """.trimMargin(),
                "start\nfinally\n",
                listOf(
                    "Exception in thread \"main\" AppError: load failed",
                    "Caused by: java.lang.IllegalArgumentException: java.lang.NumberFormatException: For input string: \"x\"",
                    "Caused by: java.lang.NumberFormatException: For input string: \"x\"",
                ),
                13,
            ),
            // Suppressed: lines (an exception of close() in `use`) indented under the exception, before its cause
            "suppressed" to Program(
                """
                |class Res(private val name: String) : AutoCloseable {
                |    override fun close() = throw IllegalStateException("close ${'$'}name")
                |}
                |
                |fun main() {
                |    println("start")
                |    val e = IllegalArgumentException("body", ArithmeticException("root"))
                |    e.addSuppressed(UnsupportedOperationException("earlier", NumberFormatException("deeper")))
                |    Res("a").use { throw e }
                |}
                """.trimMargin(),
                "start\n",
                listOf(
                    "Exception in thread \"main\" java.lang.IllegalArgumentException: body",
                    "\tSuppressed: java.lang.UnsupportedOperationException: earlier",
                    "\tCaused by: java.lang.NumberFormatException: deeper",
                    "\tSuppressed: java.lang.IllegalStateException: close a",
                    "Caused by: java.lang.ArithmeticException: root",
                ),
                9,
            ),
            // deeper than one segment of the try driver on Lua 5.2 to 5.4 (DeepPcall.lua)
            "deep_try" to Program(
                """
                |fun depth(n: Int): Int {
                |    try {
                |        if (n == 0) throw UnsupportedOperationException("bottom")
                |        return depth(n - 1) + 1
                |    } catch (e: ArithmeticException) {
                |        return -1
                |    }
                |}
                |
                |fun main() {
                |    println("start")
                |    println(depth(150))
                |}
                """.trimMargin(),
                "start\n",
                listOf("Exception in thread \"main\" java.lang.UnsupportedOperationException: bottom"),
                12,
            ),
            "suspend_main" to Program(
                """
                |import kotlin.coroutines.*
                |
                |suspend fun work(): Int {
                |    suspendCoroutine<Unit> { it.resume(Unit) }
                |    throw IndexOutOfBoundsException("after a suspension")
                |}
                |
                |suspend fun main() {
                |    println("start")
                |    println(work())
                |}
                """.trimMargin(),
                "start\n",
                listOf("Exception in thread \"main\" java.lang.IndexOutOfBoundsException: after a suspension"),
                5,
            ),
            // Lua's "stack overflow" is the JVM's StackOverflowError, then the message with its position. On LuaJIT the
            // overflow happens in a compiled trace, whose error skips the handler of xpcall: main runs in a coroutine there.
            "stack_overflow" to Program(
                """
                |fun down(n: Int): Int {
                |    return down(n + 1) + 1
                |}
                |
                |fun main() {
                |    println("start")
                |    println(down(0))
                |}
                """.trimMargin(),
                "start\n",
                listOf("Exception in thread \"main\" java.lang.StackOverflowError", "...: stack overflow"),
                2,
            ),
            // not an exception: the message of the Lua error and its traceback
            "lua_error" to Program(
                """
                |import dev.k2l.lua.*
                |
                |fun main() {
                |    println("start")
                |    Lua.error("raw failure")
                |}
                """.trimMargin(),
                "start\n",
                listOf("...: raw failure"),
                5,
            ),
        )

        private val roots: Path by lazy {
            Files.createTempDirectory("k2l-uncaught").also { root ->
                PROGRAMS.forEach { (name, program) ->
                    Files.createDirectories(root.resolve(name))
                    Files.writeString(root.resolve(name).resolve("main.kt"), program.source + "\n")
                }
            }
        }

        private val modules by lazy { PROGRAMS.keys.map { SourceModule(it, listOf(roots.resolve(it))) } }
        private val session by lazy { SourceSession.create(modules) }

        private fun module(name: String) = modules.single { it.name == name }

        @JvmStatic
        @AfterAll
        fun close() {
            session.close()
            roots.toFile().deleteRecursively()
        }
    }
}
