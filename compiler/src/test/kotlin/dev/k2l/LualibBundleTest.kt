package dev.k2l

import dev.k2l.codegen.Lualib
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.io.TempDir
import java.io.File
import java.nio.file.Files
import java.nio.file.Path

/**
 * The shared `lualib_bundle.lua` is one Lua chunk, and Lua limits a function (a chunk included) to 200 locals:
 * a program using many features at once must still load. This loads a bundle of every feature on every target.
 */
class LualibBundleTest {
    @TempDir
    lateinit var dir: Path

    private val features: List<String> by lazy {
        val lualibDir = File(System.getProperty("k2l.casesDir"), "../../main/resources/dev/k2l/lualib")
        lualibDir.listFiles().orEmpty().map { it.name.substringBefore('.') }.distinct().sorted()
    }

    @TestFactory
    fun everyFeatureLoadsTogether(): List<DynamicTest> = LuaTarget.entries.filter(LuaInterpreters::selects).map { target ->
        DynamicTest.dynamicTest("all features on ${target.id}") {
            val interpreter = LuaInterpreters.of(target)
            assumeInterpreter(interpreter != null, "no interpreter for ${target.id} found")
            val bundle = dir.resolve("bundle_${target.name}.lua")
            // Features that exist only as another target's variant (e.g. IMul.float) are left out.
            val available = features.filter { runCatching { Lualib.feature(it, target) }.isSuccess }
            Files.writeString(bundle, Lualib.bundle(available, target))
            val (status, output) = runLua(requireNotNull(interpreter), dir, bundle.fileName.toString())
            assertEquals(0, status, "bundle of all features failed to load:\n$output")
        }
    }
}
