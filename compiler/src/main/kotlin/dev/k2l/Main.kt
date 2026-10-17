package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import kotlin.system.exitProcess

private const val USAGE = "usage: k2l [--target 5.1|5.2|5.3|5.4|JIT] [--lualib require|inline] [--out DIR] SOURCE_DIR..."

fun main(args: Array<String>) {
    var target = LuaTarget.Lua54
    var out: Path = Paths.get("out")
    var lualib = LuaLibImport.Require
    val sources = mutableListOf<Path>()
    val it = args.iterator()
    while (it.hasNext()) {
        when (val arg = it.next()) {
            "--target" -> target = LuaTarget.parse(it.nextOr(USAGE))
            "--out" -> out = Paths.get(it.nextOr(USAGE))
            "--lualib" -> lualib = LuaLibImport.valueOf(it.nextOr(USAGE).replaceFirstChar { c -> c.uppercaseChar() })
            "-h", "--help" -> exit(0, USAGE)
            else -> if (arg.startsWith("-")) exit(2, "unknown option $arg\n$USAGE") else sources.add(Paths.get(arg))
        }
    }
    if (sources.isEmpty()) exit(2, USAGE)

    val module = SourceModule("main", sources.map { it.toAbsolutePath().normalize() })
    val result = SourceSession.create(listOf(module)).use { session ->
        K2lCompiler(CompilerOptions(luaTarget = target, luaLibImport = lualib)).compile(session, module)
    }
    result.diagnostics.forEach { System.err.println(it) }
    if (!result.hasErrors) {
        for (output in result.outputs) {
            val path = out.resolve(output.path)
            Files.createDirectories(path.parent)
            Files.writeString(path, output.code)
        }
    }
    // The IntelliJ core leaves non-daemon pool threads behind, so exit explicitly.
    exitProcess(if (result.hasErrors) 1 else 0)
}

private fun Iterator<String>.nextOr(usage: String) = if (hasNext()) next() else exit(2, usage)

private fun exit(code: Int, message: String): Nothing {
    (if (code == 0) System.out else System.err).println(message)
    exitProcess(code)
}
