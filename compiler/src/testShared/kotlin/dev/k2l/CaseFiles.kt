package dev.k2l

import java.io.File

// Compiled into both the tests and the benchmark harness (see compiler/build.gradle.kts).

/** The options of `options.txt`; the Lua target is chosen by the caller, not by the case. */
private val CASE_OPTIONS = setOf("intOverflow", "luaLibImport", "strings", "long64")

/**
 * The compiler options of a test case or benchmark program: its `options.txt`, one `name=value` per line
 * (`intOverflow=wrap`, `luaLibImport=inline`, `strings=utf16`, `long64=emulate`), else the defaults.
 */
internal fun caseOptions(dir: File): CompilerOptions {
    val values = File(dir, "options.txt").takeIf { it.isFile }?.readLines().orEmpty().filter { '=' in it }
        .associate { it.substringBefore('=').trim() to it.substringAfter('=').trim() }
    require(values.keys.all { it in CASE_OPTIONS }) { "unknown option in ${dir.name}/options.txt: ${values.keys}" }
    return CompilerOptions(
        luaLibImport = values["luaLibImport"]?.let { if (it == "inline") LuaLibImport.Inline else LuaLibImport.Require }
            ?: LuaLibImport.Require,
        intOverflow = values["intOverflow"]?.let(IntOverflow::parse) ?: IntOverflow.Unchecked,
        strings = values["strings"]?.let(StringSemantics::parse) ?: StringSemantics.Bytes,
        long64 = values["long64"]?.let(Long64::parse) ?: Long64.AsDouble,
    )
}

/** What `interpreter -v` prints, or null when it isn't installed or fails. */
internal fun luaVersionBanner(interpreter: String): String? = runCatching {
    val p = ProcessBuilder(interpreter, "-v").redirectErrorStream(true).start()
    p.inputStream.readBytes().toString(Charsets.UTF_8).takeIf { p.waitFor() == 0 }
}.getOrNull()
