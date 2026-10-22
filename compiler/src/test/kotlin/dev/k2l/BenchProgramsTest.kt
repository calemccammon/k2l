package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.condition.EnabledIf
import java.io.File

/**
 * The benchmark programs (`src/bench/programs`, run by `./gradlew :compiler:bench`) must keep transpiling on every
 * target. Timing them is local only; this just catches a program the compiler stops accepting.
 */
@EnabledIf(TARGET_FREE)
class BenchProgramsTest {
    @TestFactory
    fun benchProgramsTranspile(): List<DynamicTest> = programs.flatMap { dir ->
        LuaTarget.entries.map { target ->
            DynamicTest.dynamicTest("${dir.name} on ${target.id}") {
                assertTrue(File(dir, "stdout.txt").isFile, "${dir.name} has no stdout.txt (run ./gradlew :compiler:bench -PupdateGolden)")
                val result = K2lCompiler(
                    caseOptions(dir).copy(luaTarget = target),
                ).compile(session, modules.single { it.name == dir.name })
                assertEquals("", result.diagnostics.joinToString("\n"), "unexpected diagnostics")
            }
        }
    }

    companion object {
        private val modules: List<SourceModule> by lazy {
            programModules(File(System.getProperty("k2l.benchDir") ?: "src/bench/programs"))
        }
        private val programs: List<File> by lazy { modules.map { it.roots.single().toFile() } }

        private val session: SourceSession by lazy { SourceSession.create(modules) }

        @JvmStatic
        @AfterAll
        fun closeSession() {
            if (programs.isNotEmpty()) session.close()
        }
    }
}
