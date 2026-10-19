package dev.k2l

import dev.k2l.codegen.Lualib
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assumptions.assumeTrue
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.io.TempDir
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.util.concurrent.TimeUnit

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
    fun everyFeatureLoadsTogether(): List<DynamicTest> = INTERPRETERS.map { (target, names) ->
        DynamicTest.dynamicTest("all features on ${target.id}") {
            val interpreter = names.firstOrNull(::onPath)
            assumeTrue(interpreter != null, "${names.first()} not found")
            val bundle = dir.resolve("bundle_${target.name}.lua")
            // Features that exist only as another target's variant (e.g. IMul.float) are left out.
            val available = features.filter { runCatching { Lualib.feature(it, target) }.isSuccess }
            Files.writeString(bundle, Lualib.bundle(available, target))
            val process = ProcessBuilder(interpreter, bundle.toString()).redirectErrorStream(true).start()
            check(process.waitFor(30, TimeUnit.SECONDS)) { "lua timed out" }
            val output = process.inputStream.bufferedReader().readText()
            assertEquals(0, process.exitValue(), "bundle of all features failed to load:\n$output")
        }
    }

    private fun onPath(name: String) = System.getenv("PATH").orEmpty().split(File.pathSeparator).any { File(it, name).canExecute() }

    private companion object {
        val INTERPRETERS = listOf(
            LuaTarget.Lua51 to listOf("lua5.1", "lua51", "lua"),
            LuaTarget.Lua52 to listOf("lua5.2", "lua52"),
            LuaTarget.Lua53 to listOf("lua5.3", "lua53"),
            LuaTarget.Lua54 to listOf("lua5.4", "lua54"),
            LuaTarget.LuaJIT to listOf("luajit"),
        )
    }
}
