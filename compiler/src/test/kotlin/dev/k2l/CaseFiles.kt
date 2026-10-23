package dev.k2l

import java.io.File

/** The options of `options.txt`; the Lua target is chosen by the caller, not by the case. */
private val CASE_OPTIONS = setOf("luaLibImport", "moduleMode", "noImplicitSelf")

/**
 * The compiler options of a test case: its `options.txt`, one `name=value` per line
 * (`luaLibImport=inline`, `moduleMode=global`, `noImplicitSelf=true`), else the defaults.
 */
internal fun caseOptions(dir: File): CompilerOptions {
    val values = File(dir, "options.txt").takeIf { it.isFile }?.readLines().orEmpty().filter { '=' in it }
        .associate { it.substringBefore('=').trim() to it.substringAfter('=').trim() }
    require(values.keys.all { it in CASE_OPTIONS }) { "unknown option in ${dir.name}/options.txt: ${values.keys}" }
    return CompilerOptions(
        luaLibImport = values["luaLibImport"]?.let(::parseLualib) ?: LuaLibImport.Require,
        moduleMode = values["moduleMode"]?.let(::parseModuleMode) ?: ModuleMode.Require,
        noImplicitSelf = values["noImplicitSelf"].toBoolean(),
    )
}

/**
 * A global-mode case's `load-order.txt`: the generated files in the order the host loads them, one path per line. The
 * runtime bundle, if any, is loaded before them.
 */
internal fun loadOrder(dir: File): List<String> =
    File(dir, "load-order.txt").takeIf { it.isFile }?.readLines()?.map { it.trim() }?.filter { it.isNotEmpty() }
        ?: error("${dir.name} has moduleMode=global but no load-order.txt")

/** The expected output of every target but 5.4 whose output differs from 5.4's: `stdout.5.1.txt`, `stdout.JIT.txt`, ... */
private fun targetStdout(dir: File, target: LuaTarget): File = File(dir, "stdout.${target.id}.txt")

/**
 * What a case prints on [target]: `stdout.<target>.txt` where that target's output differs from
 * 5.4's, else `stdout.txt` (5.4's output).
 */
internal fun stdoutFile(dir: File, target: LuaTarget): File =
    targetStdout(dir, target).takeIf { target != LuaTarget.Lua54 && it.isFile } ?: File(dir, "stdout.txt")

/**
 * Records [output] as what the program in [dir] prints on [target] (`-PupdateGolden`): 5.4's output in `stdout.txt`;
 * another target's in `stdout.<target>.txt` when it differs from `stdout.txt`, which is deleted when it no longer does.
 * Record 5.4's output first.
 */
internal fun recordStdout(dir: File, target: LuaTarget, output: String) {
    val golden = File(dir, "stdout.txt")
    if (target == LuaTarget.Lua54) {
        golden.writeText(output)
        return
    }
    val own = targetStdout(dir, target)
    if (golden.isFile && golden.readText() == output) own.delete() else own.writeText(output)
}
