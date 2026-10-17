package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import kotlin.system.exitProcess

const val VERSION = "0.1.0"

private val USAGE = """
    |usage: k2l [options] [SOURCE_DIR...]
    |
    |Transpiles the Kotlin sources under SOURCE_DIR (or the project in ./k2l.json) to Lua.
    |
    |options:
    |  -p, --project FILE      read settings from a k2l.json project file
    |  -o, --out DIR           output directory (default: out)
    |  -t, --target VERSION    Lua version: 5.1, 5.2, 5.3, 5.4 (default) or JIT
    |      --lualib MODE       require (default: one shared lualib_bundle.lua) or inline
    |      --classpath PATHS   extra jars or class directories, e.g. Lua bindings (':'-separated)
    |  -h, --help              show this help
    |      --version           show the version
""".trimMargin()

/** Settings from k2l.json and the command line; command-line options win. */
private data class Settings(
    val sources: List<Path> = emptyList(),
    val out: Path = Paths.get("out"),
    val target: LuaTarget = CompilerOptions().luaTarget,
    val lualib: LuaLibImport = CompilerOptions().luaLibImport,
    val classpath: List<Path> = emptyList(),
)

fun main(args: Array<String>) {
    val settings = try {
        parseArgs(args)
    } catch (e: IllegalArgumentException) {
        exit(2, "k2l: ${e.message}\n\n$USAGE")
    }
    if (settings.sources.isEmpty()) exit(2, USAGE)

    val module = SourceModule("main", settings.sources.map { it.toAbsolutePath().normalize() })
    val options = CompilerOptions(luaTarget = settings.target, luaLibImport = settings.lualib)
    val result = SourceSession.create(listOf(module), settings.classpath).use { session ->
        K2lCompiler(options).compile(session, module)
    }
    result.diagnostics.forEach { System.err.println(it) }
    if (!result.hasErrors) {
        for (output in result.outputs) {
            val path = settings.out.resolve(output.path)
            Files.createDirectories(path.parent)
            Files.writeString(path, output.code)
        }
        System.err.println("k2l: wrote ${result.outputs.size} file(s) to ${settings.out}")
    }
    // The IntelliJ core leaves non-daemon pool threads behind, so exit explicitly.
    exitProcess(if (result.hasErrors) 1 else 0)
}

private fun parseArgs(args: Array<String>): Settings {
    var project: Path? = null
    val sources = mutableListOf<Path>()
    val overrides = mutableListOf<(Settings) -> Settings>()
    val remaining = args.iterator()
    fun value(option: String) = if (remaining.hasNext()) remaining.next() else throw IllegalArgumentException("$option needs a value")
    while (remaining.hasNext()) {
        when (val arg = remaining.next()) {
            "-p", "--project" -> project = Paths.get(value(arg))

            "-o", "--out" -> Paths.get(value(arg)).let { out -> overrides += { s -> s.copy(out = out) } }

            "-t", "--target" -> LuaTarget.parse(value(arg)).let { target -> overrides += { s -> s.copy(target = target) } }

            "--lualib" -> parseLualib(value(arg)).let { lualib -> overrides += { s -> s.copy(lualib = lualib) } }

            "--classpath" -> value(arg).split(java.io.File.pathSeparatorChar).filter { p -> p.isNotEmpty() }.map { p -> Paths.get(p) }
                .let { cp -> overrides += { s -> s.copy(classpath = s.classpath + cp) } }

            "-h", "--help" -> exit(0, USAGE)

            "--version" -> exit(0, "k2l $VERSION")

            else -> if (arg.startsWith("-")) throw IllegalArgumentException("unknown option $arg") else sources.add(Paths.get(arg))
        }
    }
    return resolveSettings(project, sources, overrides)
}

private fun resolveSettings(project: Path?, sources: List<Path>, overrides: List<(Settings) -> Settings>): Settings {
    val defaultProject = Paths.get("k2l.json").takeIf { project == null && sources.isEmpty() && Files.isRegularFile(it) }
    val base = (project ?: defaultProject)?.let(::readProject) ?: Settings()
    val withSources = if (sources.isEmpty()) base else base.copy(sources = sources)
    return overrides.fold(withSources) { s, override -> override(s) }
}

private fun parseLualib(mode: String) = when (mode.lowercase()) {
    "require" -> LuaLibImport.Require
    "inline" -> LuaLibImport.Inline
    else -> throw IllegalArgumentException("--lualib must be require or inline, not '$mode'")
}

/**
 * k2l.json, with paths relative to its directory:
 * `{"srcDirs": ["src"], "outDir": "out", "luaTarget": "5.4", "luaLibImport": "require", "classpath": []}`
 */
private fun readProject(file: Path): Settings {
    require(Files.isRegularFile(file)) { "project file $file not found" }
    val json = requireNotNull(Json.parseToJsonElement(Files.readString(file)) as? JsonObject) { "$file must contain a JSON object" }
    val dir = file.toAbsolutePath().parent
    fun string(key: String) = (json[key] as? JsonPrimitive)?.takeIf { it.isString }?.content
    fun paths(key: String) = (json[key] as? JsonArray).orEmpty().map { dir.resolve((it as JsonPrimitive).content) }
    val unknown = json.keys - setOf("srcDirs", "outDir", "luaTarget", "luaLibImport", "classpath")
    require(unknown.isEmpty()) { "unknown key(s) in $file: ${unknown.joinToString()}" }
    return Settings(
        sources = paths("srcDirs"),
        out = string("outDir")?.let(dir::resolve) ?: dir.resolve("out"),
        target = string("luaTarget")?.let(LuaTarget::parse) ?: LuaTarget.Lua54,
        lualib = string("luaLibImport")?.let(::parseLualib) ?: LuaLibImport.Require,
        classpath = paths("classpath"),
    )
}

private fun exit(code: Int, message: String): Nothing {
    (if (code == 0) System.out else System.err).println(message)
    exitProcess(code)
}
