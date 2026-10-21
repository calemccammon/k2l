package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.condition.EnabledIf
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

/**
 * Opt-in (`-Pk2l.snapshot=<dir>`): writes everything the compiler generates for every test case and benchmark program,
 * `lualib_bundle.lua` included, on every target and option set ([variants]), to `<dir>/<cases|bench>/<name>/<variant>/`.
 * A refactoring that must not change the output is checked with `diff -r` of a snapshot taken before and one after it.
 * Without the property this produces no tests.
 */
@EnabledIf(TARGET_FREE)
class SnapshotTest {
    @TestFactory
    fun snapshot(): List<DynamicTest> {
        val root = snapshotDir ?: return emptyList()
        return listOf("cases" to cases, "bench" to bench).flatMap { (group, set) ->
            set.modules.map { module ->
                DynamicTest.dynamicTest("$group/${module.name}") {
                    val dir = module.roots.single().toFile()
                    for ((variant, options) in variants(caseOptions(dir))) {
                        val result = K2lCompiler(options).compile(set.session, module)
                        write(root.resolve(group).resolve(module.name).resolve(variant), result)
                        val missing = unexportedLualibNames(result.outputs)
                        assertEquals(emptyList<String>(), missing, "$variant: names the runtime does not export")
                    }
                }
            }
        }
    }

    private fun write(dir: Path, result: CompileResult) {
        Files.createDirectories(dir)
        writeOutputs(dir, result.outputs)
        if (result.diagnostics.isNotEmpty()) {
            val text = result.diagnostics.joinToString("") { "${it.line}:${it.column}: ${it.message}\n" }
            Files.writeString(dir.resolve("diagnostics.txt"), text)
        }
    }

    private class ModuleSet(root: String) {
        val modules: List<SourceModule> = programModules(File(root))
        val session: SourceSession by lazy { SourceSession.create(modules) }
    }

    companion object {
        private val snapshotDir: Path? = System.getProperty("k2l.snapshot")?.takeIf { it.isNotBlank() }?.let { Paths.get(it) }

        /**
         * Every target with the case's own options; `--long64 emulate` on the targets without integers; the inlined runtime
         * and source maps on a target with integers and on one without.
         */
        fun variants(base: CompilerOptions): List<Pair<String, CompilerOptions>> {
            val targets = LuaTarget.entries.map { it.id to base.copy(luaTarget = it) }
            val emulate = if (base.long64 == Long64.Emulate) {
                emptyList()
            } else {
                LuaTarget.entries.filter { !it.hasIntegers }
                    .map { "${it.id}-emulate" to base.copy(luaTarget = it, long64 = Long64.Emulate) }
            }
            val extra = listOf(LuaTarget.Lua54, LuaTarget.Lua51).flatMap { target ->
                listOf(
                    "${target.id}-inline" to base.copy(luaTarget = target, luaLibImport = LuaLibImport.Inline),
                    "${target.id}-sourcemap" to base.copy(luaTarget = target, sourceMap = true),
                )
            }
            return targets + emulate + extra
        }

        private val cases by lazy { ModuleSet(System.getProperty("k2l.casesDir") ?: "src/test/cases") }
        private val bench by lazy { ModuleSet(System.getProperty("k2l.benchDir") ?: "src/bench/programs") }

        @JvmStatic
        @AfterAll
        fun closeSessions() {
            if (snapshotDir == null) return
            cases.session.close()
            bench.session.close()
        }
    }
}
