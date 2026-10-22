package dev.k2l.bench

import dev.k2l.LuaOutput
import dev.k2l.LuaTarget
import dev.k2l.codegen.Lualib
import java.io.File

/** A Lua function in a profile: its chunk (`main.lua`, `lualib_bundle.lua`, `[C]name`) and definition line. */
data class FnKey(val source: String, val lineDefined: Int)

/**
 * Turns Lua positions of a compiled program into readable names: program lines map back to Kotlin through the
 * source map, lines of `lualib_bundle.lua` to the lualib file they come from (`Collections.lua:412`) and the function
 * defined there (`HashMap:get`).
 */
class Attribution(outputs: List<LuaOutput>, private val kotlinSource: File, lualibDir: File, target: LuaTarget) {
    private class Span(val feature: String, val file: String, val startLine: Int, val endLine: Int, val fileOffset: Int)

    private val program = outputs.first { it.path == "main.lua" }
    private val programLines = program.code.lines()
    private val mappings = program.sourceMap?.lines.orEmpty()
    private val kotlinLines = kotlinSource.readLines()
    private val bundleLines = outputs.firstOrNull { it.path == "${Lualib.BUNDLE_MODULE}.lua" }?.code?.lines().orEmpty()
    private val spans: List<Span> = locateFeatures(outputs, lualibDir, target)

    fun isProgram(source: String) = source == program.path

    fun isLualib(source: String) = source == "${Lualib.BUNDLE_MODULE}.lua"

    /** `program`, the lualib feature (file name without `.lua`), or `C`. */
    fun category(source: String, line: Int): String = when {
        isProgram(source) -> "program"
        isLualib(source) -> span(line)?.feature ?: "lualib (unattributed)"
        source.startsWith("[C]") -> "C"
        else -> "load() chunks"
    }

    /** E.g. `Pos:plus (main.kt:12)`, `lualib HashMap:get (Collections.lua:412)`, `C string.format`. */
    fun function(fn: FnKey): String = when {
        fn.source.startsWith("[C]") -> "C ${fn.source.removePrefix("[C]").ifEmpty { "function" }}"
        fn.lineDefined <= 0 -> "${fn.source} main chunk"
        isProgram(fn.source) -> "${nameAt(programLines, fn.lineDefined)} (${kotlinPosition(bodyLine(fn.lineDefined))})"
        isLualib(fn.source) -> "lualib ${nameAt(bundleLines, fn.lineDefined)} (${lualibPosition(fn.lineDefined)})"
        else -> "load() chunk `${fn.source.take(KOTLIN_TEXT)}`"
    }

    /** A function declared on a line of its own maps to the Kotlin line of its first statement, not of the statement before. */
    private fun bodyLine(line: Int): Int {
        val text = programLines.getOrNull(line - 1).orEmpty().trimStart()
        return if (text.startsWith("function ") || text.startsWith("local function ")) line + 1 else line
    }

    /** A source line with its position and text: `main.kt:14 main.lua:52  return Pos.new(...)`. */
    fun line(source: String, line: Int): String = when {
        isProgram(source) -> "${kotlinPosition(line)} main.lua:$line  ${programLines.getOrNull(line - 1)?.trim().orEmpty()}"
        isLualib(source) -> "${lualibPosition(line)}  ${bundleLines.getOrNull(line - 1)?.trim().orEmpty()}"
        else -> "$source:$line"
    }

    /** The Kotlin line a program line came from, with its text: `main.kt:14 \`val d = dist[v]\``. */
    fun kotlinLine(luaLine: Int): String {
        val k = kotlinLineOf(luaLine) ?: return "main.lua:$luaLine"
        return "${kotlinSource.name}:$k `${kotlinLines.getOrNull(k - 1)?.trim().orEmpty().take(KOTLIN_TEXT)}`"
    }

    private fun kotlinLineOf(luaLine: Int): Int? = mappings.lastOrNull { it.luaLine <= luaLine }?.origin?.line

    private fun kotlinPosition(luaLine: Int) = kotlinLineOf(luaLine)?.let { "${kotlinSource.name}:$it" } ?: "main.lua:$luaLine"

    private fun span(line: Int) = spans.firstOrNull { line in it.startLine..it.endLine }

    private fun lualibPosition(line: Int): String =
        span(line)?.let { "${it.file}:${line - it.startLine + it.fileOffset + 1}" } ?: "lualib_bundle.lua:$line"

    private companion object {
        const val KOTLIN_TEXT = 70

        val NAME_PATTERNS = listOf(
            Regex("""^\s*local\s+function\s+([\w.:]+)"""),
            Regex("""^\s*function\s+([\w.:\[\]"']+)"""),
            Regex("""([\w.:\[\]"']+)\s*=\s*function\b"""),
        )
        fun declaredName(text: String) = NAME_PATTERNS.firstNotNullOfOrNull { it.find(text)?.groupValues?.get(1) }

        fun String.indentation() = indexOfFirst { !it.isWhitespace() }.let { if (it < 0) length else it }

        val LAMBDA_ARGUMENT = Regex("""([\w.:]+)\s*\((?:[^()]*,\s*)?function\b""")

        /** The function defined at [line]: its name, the call it is a lambda argument of, or the named function enclosing it. */
        fun nameAt(lines: List<String>, line: Int): String {
            val text = lines.getOrNull(line - 1).orEmpty()
            return declaredName(text)
                ?: LAMBDA_ARGUMENT.find(text)?.let { "lambda passed to ${it.groupValues[1]}" }
                ?: enclosingName(lines, line, text.indentation())?.let { "closure in $it" }
                ?: "function@$line"
        }

        /** The name of the nearest named function around [line], found by walking up to lines of smaller indentation. */
        fun enclosingName(lines: List<String>, line: Int, indent: Int): String? {
            var level = indent
            for (i in line - 2 downTo 0) {
                val outer = lines[i]
                if (outer.isNotBlank() && outer.indentation() < level) {
                    declaredName(outer)?.let { return it }
                    level = outer.indentation()
                }
                if (level == 0) break
            }
            return null
        }

        /** Where each feature's code sits in the bundle; a feature's code appears verbatim, followed by its exports. */
        fun locateFeatures(outputs: List<LuaOutput>, lualibDir: File, target: LuaTarget): List<Span> {
            val bundle = outputs.firstOrNull { it.path == "${Lualib.BUNDLE_MODULE}.lua" }?.code ?: return emptyList()
            val names = lualibDir.listFiles().orEmpty().map { it.name.substringBefore('.') }.distinct()
            return names.mapNotNull { name ->
                val feature = runCatching { Lualib.feature(name, target) }.getOrNull() ?: return@mapNotNull null
                val index = bundle.indexOf("\n" + feature.code + "\n")
                if (index < 0) return@mapNotNull null
                val start = bundle.substring(0, index + 1).count { it == '\n' } + 1
                val fileLines = File(lualibDir, feature.file).readLines()
                val offset = fileLines.indexOfFirst { it.isNotBlank() && !it.startsWith("-- requires:") }.coerceAtLeast(0)
                Span(name, feature.file, start, start + feature.code.count { it == '\n' }, offset)
            }.sortedBy { it.startLine }
        }
    }
}
