package dev.k2l

import dev.k2l.codegen.Lualib
import dev.k2l.frontend.SourceModule
import org.junit.jupiter.api.Assumptions.assumeTrue
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.util.concurrent.TimeUnit

/** The shared runtime's file among the outputs. */
internal const val BUNDLE_FILE = "${Lualib.BUNDLE_MODULE}.lua"

/**
 * Lua interpreters on this machine, found by name (or `-Dk2l.lua51=...` and so on) and confirmed by their version banner.
 *
 * `-PluaTargets=5.1,JIT` (`-Dk2l.luaTargets`) runs only the tests of those targets, so that CI can split them between jobs;
 * each selected target must then have an interpreter: its tests fail instead of being skipped. The tests that are not about
 * one target (the golden 5.4 output and its runtime names, the CLI, ...) go with 5.4 and run when it is selected. Without the
 * property every test runs, on every interpreter found.
 */
internal object LuaInterpreters {
    private val names = mapOf(
        LuaTarget.Lua51 to ("lua51" to listOf("lua5.1", "lua51", "lua")),
        LuaTarget.Lua52 to ("lua52" to listOf("lua5.2", "lua52", "lua")),
        LuaTarget.Lua53 to ("lua53" to listOf("lua5.3", "lua53", "lua")),
        LuaTarget.Lua54 to ("lua54" to listOf("lua5.4", "lua54", "lua")),
        LuaTarget.LuaJIT to ("luajit" to listOf("luajit")),
    )

    private val found: Map<LuaTarget, String> by lazy {
        names.mapNotNull { (target, candidates) ->
            val (property, defaults) = candidates
            (listOfNotNull(System.getProperty("k2l.$property")) + defaults)
                .firstOrNull { luaVersionBanner(it)?.let { banner -> matches(target, banner) } == true }
                ?.let { target to it }
        }.toMap()
    }

    private fun matches(target: LuaTarget, banner: String) =
        if (target == LuaTarget.LuaJIT) banner.startsWith("LuaJIT") else banner.startsWith("Lua ${target.id}")

    /** The targets of `-PluaTargets`, or null when it isn't given (every target). */
    val selection: Set<LuaTarget>? = System.getProperty("k2l.luaTargets")?.takeIf { it.isNotBlank() }?.split(',')
        ?.map { id ->
            LuaTarget.entries.firstOrNull { it.id.equals(id.trim(), ignoreCase = true) }
                ?: error("unknown Lua target '${id.trim()}' in luaTargets, expected some of ${LuaTarget.entries.map { it.id }}")
        }?.toSet()

    /** Whether the tests of [target] run. */
    fun selects(target: LuaTarget): Boolean = selection?.contains(target) ?: true

    /** Whether the tests that are not about a target run (see the class comment); a JUnit `@EnabledIf` condition. */
    @JvmStatic
    fun runsTargetFreeTests(): Boolean = selects(LuaTarget.Lua54)

    /** The interpreter of [target], or null when none is installed; a target that `-PluaTargets` selects must have one. */
    fun of(target: LuaTarget): String? = found[target].also {
        check(it != null || selection?.contains(target) != true) { "no interpreter for Lua ${target.id} found, but luaTargets selects it" }
    }

    /** Every installed interpreter of a selected target with its target, one per target. */
    val installed: List<Pair<String, LuaTarget>>
        get() = LuaTarget.entries.filter(::selects).mapNotNull { target -> of(target)?.let { it to target } }
}

/** `@EnabledIf(TARGET_FREE)`: a test (or class) that is not about one Lua target, run when `-PluaTargets` selects 5.4. */
internal const val TARGET_FREE = "dev.k2l.LuaInterpreters#runsTargetFreeTests"

/** Skips the test when its interpreter is missing ([found] false), or fails it when `-PluaTargets` selects that target. */
internal fun assumeInterpreter(found: Boolean, message: String) {
    if (LuaInterpreters.selection != null) check(found) { message } else assumeTrue(found, message)
}

/** Interpreters installed on this machine with their target, one per version, of the targets that `-PluaTargets` selects. */
internal val installedInterpreters: List<Pair<String, LuaTarget>> get() = LuaInterpreters.installed

/** What a Lua run printed and its exit status; [stderr] is empty when it was merged into [stdout]. */
internal data class LuaRun(val status: Int, val stdout: String, val stderr: String = "")

/** Runs [entry] with [lua] in [dir]; with [separateStderr] its stderr is kept apart from stdout. */
internal fun runLua(lua: String, dir: Path, entry: String = "main.lua", separateStderr: Boolean = false): LuaRun {
    val builder = ProcessBuilder(lua, entry).directory(dir.toFile())
    val err = if (separateStderr) Files.createTempFile("k2l-stderr", ".txt") else null
    if (err != null) builder.redirectError(err.toFile()) else builder.redirectErrorStream(true)
    try {
        val process = builder.start()
        val stdout = process.inputStream.readBytes().toString(Charsets.UTF_8)
        check(process.waitFor(LUA_TIMEOUT_SECONDS, TimeUnit.SECONDS)) { "$lua timed out" }
        return LuaRun(process.exitValue(), stdout, err?.let(Files::readString).orEmpty())
    } finally {
        err?.let(Files::deleteIfExists)
    }
}

private const val LUA_TIMEOUT_SECONDS = 30L

/** Writes [outputs] (without source map files) under [dir]. */
internal fun writeOutputs(dir: Path, outputs: List<LuaOutput>) {
    outputs.forEach {
        val path = dir.resolve(it.path)
        Files.createDirectories(path.parent)
        Files.writeString(path, it.code)
    }
}

/** A module for each directory of [root] that has a `main.kt`, by name; [only] limits them to those names. */
internal fun programModules(root: File, only: Collection<String>? = null): List<SourceModule> = root.absoluteFile.listFiles().orEmpty()
    .filter { File(it, "main.kt").isFile && (only == null || it.name in only) }.sortedBy { it.name }
    .map { SourceModule(it.name, listOf(it.toPath())) }

private val IMPORTED_NAME = Regex("""^local (__K2L_\w+) = ____lualib\.\1$""", RegexOption.MULTILINE)
private val EXPORTED_NAME = Regex("""^____lualib\.(__K2L_\w+) = \1$""", RegexOption.MULTILINE)

/**
 * The runtime names a generated file reads from the lualib table (`local __K2L_X = ____lualib.__K2L_X`) that no feature
 * of the runtime exports, as `file: name`: the bundle's features with `luaLibImport=require`, the inlined ones otherwise.
 */
internal fun unexportedLualibNames(outputs: List<LuaOutput>): List<String> {
    val bundle = outputs.firstOrNull { it.path == BUNDLE_FILE }?.code.orEmpty()
    return outputs.filter { it.path != BUNDLE_FILE }.flatMap { file ->
        val exported = EXPORTED_NAME.findAll(bundle + "\n" + file.code).map { it.groupValues[1] }.toSet()
        IMPORTED_NAME.findAll(file.code).map { it.groupValues[1] }.filter { it !in exported }.map { "${file.path}: $it" }.toList()
    }
}
