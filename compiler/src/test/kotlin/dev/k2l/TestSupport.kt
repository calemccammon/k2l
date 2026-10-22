package dev.k2l

import dev.k2l.codegen.Lualib
import dev.k2l.frontend.SourceModule
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.util.concurrent.TimeUnit

/** The shared runtime's file among the outputs. */
internal const val BUNDLE_FILE = "${Lualib.BUNDLE_MODULE}.lua"

/** For each target, the property that overrides its interpreter (`-Plua51=/path/to/lua`) and the names tried after it. */
private val INTERPRETER_NAMES = mapOf(
    LuaTarget.Lua51 to ("lua51" to listOf("lua5.1", "lua51", "lua")),
    LuaTarget.Lua52 to ("lua52" to listOf("lua5.2", "lua52", "lua")),
    LuaTarget.Lua53 to ("lua53" to listOf("lua5.3", "lua53", "lua")),
    LuaTarget.Lua54 to ("lua54" to listOf("lua5.4", "lua54", "lua")),
    LuaTarget.LuaJIT to ("luajit" to listOf("luajit")),
)

/** The Lua interpreters on this machine, one per target, found by name and confirmed by their version banner. */
private val interpreters: Map<LuaTarget, String> by lazy {
    INTERPRETER_NAMES.mapNotNull { (target, candidates) ->
        val (property, defaults) = candidates
        val prefix = if (target == LuaTarget.LuaJIT) "LuaJIT" else "Lua ${target.id}"
        (listOfNotNull(System.getProperty("k2l.$property")) + defaults)
            .firstOrNull { luaVersionBanner(it)?.startsWith(prefix) == true }
            ?.let { target to it }
    }.toMap()
}

/** The interpreter of [target], or null when none is installed. */
internal fun luaInterpreter(target: LuaTarget): String? = interpreters[target]

/** The installed interpreters with their target, one per target. */
internal val installedInterpreters: List<Pair<String, LuaTarget>>
    get() = LuaTarget.entries.mapNotNull { target -> interpreters[target]?.let { it to target } }

/** What `interpreter -v` prints, or null when it isn't installed or fails. */
private fun luaVersionBanner(interpreter: String): String? = runCatching {
    val p = ProcessBuilder(interpreter, "-v").redirectErrorStream(true).start()
    p.inputStream.readBytes().toString(Charsets.UTF_8).takeIf { p.waitFor() == 0 }
}.getOrNull()

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
