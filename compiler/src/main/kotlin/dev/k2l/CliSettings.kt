package dev.k2l

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

internal val USAGE = """
    |usage: k2l [options] [SOURCE_DIR...]
    |
    |Transpiles the Kotlin sources under SOURCE_DIR (or the project in ./k2l.json) to Lua.
    |
    |options:
    |  -p, --project FILE      read settings from a k2l.json project file
    |  -o, --out DIR           output directory (default: out)
    |  -t, --target VERSION    Lua version: 5.1, 5.2, 5.3, 5.4 (default) or JIT
    |      --lualib MODE       require (default: one shared lualib_bundle.lua) or inline
    |      --classpath PATHS   extra jars or class directories, e.g. Lua bindings ('${java.io.File.pathSeparator}'-separated)
    |      --source-map        write main.lua.map files and make Lua errors and tracebacks show Kotlin positions
    |                          (on by default with --watch)
    |      --no-source-map     no source maps, also with --watch
    |      --check             report errors and unsupported constructs without writing any files
    |      --watch             rebuild whenever a source file or the project file changes (Ctrl-C to stop)
    |  -h, --help              show this help
    |      --version           show the version
    |
    |examples:
    |  k2l                     build the project in ./k2l.json
    |  k2l -t JIT -o build src transpile src/ for LuaJIT into build/
    |  k2l --check             list everything k2l cannot translate, without writing Lua
""".trimMargin()

/** Settings from k2l.json and the command line; command-line options win. */
internal data class Settings(
    val sources: List<Path> = emptyList(),
    val out: Path = Paths.get("out"),
    val target: LuaTarget = CompilerOptions().luaTarget,
    val lualib: LuaLibImport = CompilerOptions().luaLibImport,
    val classpath: List<Path> = emptyList(),
    /** Null when neither k2l.json nor the command line says: then source maps are on exactly in watch mode. */
    val sourceMap: Boolean? = null,
    val watch: Boolean = false,
    val check: Boolean = false,
    /** The k2l.json the settings came from, if any. */
    val projectFile: Path? = null,
) {
    /** `--watch` is the development loop, where Kotlin positions in Lua errors help most; explicit settings win. */
    val sourceMapEnabled get() = sourceMap ?: watch

    fun compilerOptions() = CompilerOptions(
        luaTarget = target,
        luaLibImport = lualib,
        sourceMap = sourceMapEnabled,
    )
}

/** `--help` and `--version`: print [output] and exit with status 0. */
internal class CliExit(val output: String) : RuntimeException(output)

private fun exitWith(output: String): Nothing = throw CliExit(output)

/** A likely typo is at most one edit per this many characters of the intended word (and at most 2 edits for short words). */
private const val CHARS_PER_TYPO = 3

private val OPTIONS = listOf(
    "--project", "--out", "--target", "--lualib", "--classpath", "--source-map",
    "--no-source-map", "--check", "--watch", "--help", "--version",
)

internal fun parseArgs(args: Array<String>): Settings {
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

            "--source-map" -> overrides += { s -> s.copy(sourceMap = true) }

            "--no-source-map" -> overrides += { s -> s.copy(sourceMap = false) }

            "--check" -> overrides += { s -> s.copy(check = true) }

            "--watch" -> overrides += { s -> s.copy(watch = true) }

            "-h", "--help" -> exitWith(USAGE)

            "--version" -> exitWith("k2l $VERSION")

            else -> if (arg.startsWith("-")) throw IllegalArgumentException(unknownOption(arg)) else sources.add(Paths.get(arg))
        }
    }
    return resolveSettings(project, sources, overrides)
}

private fun unknownOption(arg: String): String {
    val name = arg.substringBefore('=')
    val suggestion = closestMatch(name, OPTIONS)
    return when {
        '=' in arg && name in OPTIONS -> "unknown option $arg (write the value after a space: $name ${arg.substringAfter('=')})"
        suggestion != null -> "unknown option $arg (did you mean $suggestion?)"
        else -> "unknown option $arg"
    }
}

private fun resolveSettings(project: Path?, sources: List<Path>, overrides: List<(Settings) -> Settings>): Settings {
    val defaultProject = Paths.get("k2l.json").takeIf { project == null && sources.isEmpty() && Files.isRegularFile(it) }
    val base = (project ?: defaultProject)?.let { readProject(it).copy(projectFile = it.toAbsolutePath().normalize()) } ?: Settings()
    val withSources = if (sources.isEmpty()) base else base.copy(sources = sources)
    return overrides.fold(withSources) { s, override -> override(s) }
}

internal fun parseLualib(mode: String) = when (mode.lowercase()) {
    "require" -> LuaLibImport.Require
    "inline" -> LuaLibImport.Inline
    else -> throw IllegalArgumentException("--lualib must be require or inline, not '$mode'")
}

/** The candidate nearest to [word] by edit distance, if it is close enough to be a likely typo. */
internal fun closestMatch(word: String, candidates: Collection<String>): String? {
    val best = candidates.minByOrNull { editDistance(word.lowercase(), it.lowercase()) } ?: return null
    val distance = editDistance(word.lowercase(), best.lowercase())
    return best.takeIf { distance <= maxOf(2, best.length / CHARS_PER_TYPO) && distance < best.length }
}

private fun editDistance(a: String, b: String): Int {
    var previous = IntArray(b.length + 1) { it }
    for (i in 1..a.length) {
        val current = IntArray(b.length + 1)
        current[0] = i
        for (j in 1..b.length) {
            val substitution = previous[j - 1] + if (a[i - 1] == b[j - 1]) 0 else 1
            current[j] = minOf(previous[j] + 1, current[j - 1] + 1, substitution)
        }
        previous = current
    }
    return previous[b.length]
}
