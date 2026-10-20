package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import java.io.File

/**
 * The benchmark programs (`src/bench/programs`, run by `./gradlew :compiler:bench`) must keep transpiling on every
 * target. Timing them is local only; this just catches a program the compiler stops accepting.
 */
class BenchProgramsTest {
    @TestFactory
    fun benchProgramsTranspile(): List<DynamicTest> = programs.flatMap { dir ->
        LuaTarget.entries.map { target ->
            DynamicTest.dynamicTest("${dir.name} on ${target.id}") {
                assertTrue(File(dir, "stdout.txt").isFile, "${dir.name} has no stdout.txt (run :compiler:benchOracle -PupdateOracle)")
                val result = K2lCompiler(
                    options(dir).copy(luaTarget = target),
                ).compile(session, SourceModule(dir.name, listOf(dir.toPath())))
                assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
            }
        }
    }

    private fun options(dir: File): CompilerOptions {
        val values = File(dir, "options.txt").takeIf { it.isFile }?.readLines().orEmpty().filter { '=' in it }
            .associate { it.substringBefore('=').trim() to it.substringAfter('=').trim() }
        return CompilerOptions(
            intOverflow = values["intOverflow"]?.let(IntOverflow::parse) ?: IntOverflow.Unchecked,
            strings = values["strings"]?.let(StringSemantics::parse) ?: StringSemantics.Bytes,
            long64 = values["long64"]?.let(Long64::parse) ?: Long64.AsDouble,
        )
    }

    companion object {
        private val programs: List<File> by lazy {
            File(System.getProperty("k2l.benchDir") ?: "src/bench/programs").absoluteFile.listFiles().orEmpty()
                .filter { File(it, "main.kt").isFile }.sortedBy { it.name }
        }

        private val session: SourceSession by lazy {
            SourceSession.create(programs.map { SourceModule(it.name, listOf(it.toPath())) })
        }

        @JvmStatic
        @AfterAll
        fun closeSession() {
            if (programs.isNotEmpty()) session.close()
        }
    }
}
