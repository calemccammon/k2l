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
 * An uncaught exception ends the program as Lua ends it, on every target: the exception's string (its `__tostring`, the
 * `toString()` of Kotlin) and a Lua traceback on stderr, with Kotlin positions under --source-map, and exit status 1.
 */
class UncaughtTest {
    @TempDir
    lateinit var dir: Path

    /**
     * A program, what it prints, the text its stderr has to contain and a Kotlin line its traceback shows under source maps
     * (null when the traceback is not that of the throw), and whether stderr has a traceback.
     */
    private class Program(val source: String, val stdout: String, val message: String, val throwLine: Int?, val traceback: Boolean = true)

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
            assertTrue(stderr.contains(program.message), label)
            if (!program.traceback) continue
            assertTrue(stderr.contains("stack traceback:"), label)
            if (sourceMap) {
                program.throwLine?.let { assertTrue(stderr.contains("main.kt:$it:"), label) }
                assertFalse(Regex("main\\.lua:\\d+").containsMatchIn(stderr), label)
            } else {
                assertTrue(Regex("main\\.lua:\\d+: in ").containsMatchIn(stderr), label)
            }
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
                "java.lang.IllegalStateException: too big: 3",
                2,
            ),
            // the exception that ends main, after the finally block has run; its causes are not printed
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
                "AppError: load failed",
                // the finally block raises the exception again
                13,
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
                "java.lang.IndexOutOfBoundsException: after a suspension",
                // raised again by the completion of main's coroutine
                null,
            ),
            // Lua's "stack overflow"; LuaJIT may report it without a traceback when the overflow happens in a compiled trace
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
                "stack overflow",
                2,
                traceback = false,
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
                "raw failure",
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
