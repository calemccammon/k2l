package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
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
    |      --int-overflow MODE unchecked (default) or wrap: make Int arithmetic wrap to 32 bits like the JVM
    |      --classpath PATHS   extra jars or class directories, e.g. Lua bindings (':'-separated)
    |      --source-map        write main.lua.map files and make Lua errors and tracebacks show Kotlin positions
    |      --watch             rebuild whenever a source file or the project file changes (Ctrl-C to stop)
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
    val intOverflow: IntOverflow = CompilerOptions().intOverflow,
    val sourceMap: Boolean = false,
    val watch: Boolean = false,
    /** The k2l.json the settings came from, if any. */
    val projectFile: Path? = null,
)

fun main(args: Array<String>) {
    val settings = try {
        parseArgs(args)
    } catch (e: IllegalArgumentException) {
        exit(2, "k2l: ${e.message}\n\n$USAGE")
    }
    if (settings.sources.isEmpty()) exit(2, USAGE)
    if (settings.watch) watch(args, settings)

    // The IntelliJ core leaves non-daemon pool threads behind, so exit explicitly, also when the compiler crashes.
    val result = try {
        build(settings)
    } catch (@Suppress("TooGenericExceptionCaught") e: Throwable) {
        // A crash in k2l itself: the stack trace is the bug report.
        @Suppress("PrintStackTrace")
        e.printStackTrace()
        exit(INTERNAL_ERROR, "k2l: internal compiler error")
    }
    exitProcess(if (result.hasErrors) 1 else 0)
}

/** Exit status for a crash in k2l itself (`EX_SOFTWARE`), as opposed to errors in the Kotlin sources. */
private const val INTERNAL_ERROR = 70

/** Compiles the project once, printing diagnostics and writing the output unless there were errors. */
private fun build(settings: Settings): CompileResult {
    val module = SourceModule("main", settings.sources.map { it.toAbsolutePath().normalize() })
    val options = CompilerOptions(
        luaTarget = settings.target,
        luaLibImport = settings.lualib,
        intOverflow = settings.intOverflow,
        sourceMap = settings.sourceMap,
    )
    val result = SourceSession.create(listOf(module), settings.classpath).use { session ->
        K2lCompiler(options).compile(session, module)
    }
    result.diagnostics.forEach { System.err.println(it) }
    if (!result.hasErrors) {
        result.writeTo(settings.out)
        System.err.println("k2l: wrote ${result.outputs.size} file(s) to ${settings.out}")
    }
    return result
}

/** Builds, then rebuilds on every change to the sources or the project file; never returns. */
private fun watch(args: Array<String>, initial: Settings): Nothing {
    // Settings are re-read each time, so edits to k2l.json (including its source directories) take effect.
    var current = initial
    WatchLoop(
        paths = { listOfNotNull(current.projectFile) + current.sources },
        rebuild = {
            try {
                current = parseArgs(args)
                val started = System.nanoTime()
                val result = build(current)
                System.err.println(
                    "k2l: ${if (result.hasErrors) "failed" else "built"} in ${(System.nanoTime() - started) / NANOS_PER_MILLI} ms, watching for changes",
                )
            } catch (e: IllegalArgumentException) {
                System.err.println("k2l: ${e.message}")
            }
        },
    ).run()
}

private const val NANOS_PER_MILLI = 1_000_000

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

            "--int-overflow" -> IntOverflow.parse(value(arg)).let { mode -> overrides += { s -> s.copy(intOverflow = mode) } }

            "--classpath" -> value(arg).split(java.io.File.pathSeparatorChar).filter { p -> p.isNotEmpty() }.map { p -> Paths.get(p) }
                .let { cp -> overrides += { s -> s.copy(classpath = s.classpath + cp) } }

            "--source-map" -> overrides += { s -> s.copy(sourceMap = true) }

            "--watch" -> overrides += { s -> s.copy(watch = true) }

            "-h", "--help" -> exit(0, USAGE)

            "--version" -> exit(0, "k2l $VERSION")

            else -> if (arg.startsWith("-")) throw IllegalArgumentException("unknown option $arg") else sources.add(Paths.get(arg))
        }
    }
    return resolveSettings(project, sources, overrides)
}

private fun resolveSettings(project: Path?, sources: List<Path>, overrides: List<(Settings) -> Settings>): Settings {
    val defaultProject = Paths.get("k2l.json").takeIf { project == null && sources.isEmpty() && Files.isRegularFile(it) }
    val base = (project ?: defaultProject)?.let { readProject(it).copy(projectFile = it.toAbsolutePath().normalize()) } ?: Settings()
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
 * `{"srcDirs": ["src"], "outDir": "out", "luaTarget": "5.4", "luaLibImport": "require", "classpath": [], "intOverflow": "unchecked",
 * "sourceMap": false}`
 */
private fun readProject(file: Path): Settings {
    require(Files.isRegularFile(file)) { "project file $file not found" }
    val json = requireNotNull(Json.parseToJsonElement(Files.readString(file)) as? JsonObject) { "$file must contain a JSON object" }
    val dir = file.toAbsolutePath().parent
    fun string(key: String) = (json[key] as? JsonPrimitive)?.takeIf { it.isString }?.content
    fun paths(key: String) = (json[key] as? JsonArray).orEmpty().map { dir.resolve((it as JsonPrimitive).content) }
    val unknown = json.keys - setOf("srcDirs", "outDir", "luaTarget", "luaLibImport", "classpath", "intOverflow", "sourceMap")
    require(unknown.isEmpty()) { "unknown key(s) in $file: ${unknown.joinToString()}" }
    return Settings(
        sources = paths("srcDirs"),
        out = string("outDir")?.let(dir::resolve) ?: dir.resolve("out"),
        target = string("luaTarget")?.let(LuaTarget::parse) ?: LuaTarget.Lua54,
        lualib = string("luaLibImport")?.let(::parseLualib) ?: LuaLibImport.Require,
        classpath = paths("classpath"),
        intOverflow = string("intOverflow")?.let(IntOverflow::parse) ?: IntOverflow.Unchecked,
        sourceMap = (json["sourceMap"] as? JsonPrimitive)?.booleanOrNull ?: false,
    )
}

private fun exit(code: Int, message: String): Nothing {
    (if (code == 0) System.out else System.err).println(message)
    exitProcess(code)
}
