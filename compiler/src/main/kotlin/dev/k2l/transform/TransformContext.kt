package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.CompilerOptions
import dev.k2l.Diagnostic
import dev.k2l.Origin
import dev.k2l.Severity
import dev.k2l.codegen.LuaExpr
import dev.k2l.codegen.LuaPrinter
import dev.k2l.codegen.LuaStmt
import java.util.IdentityHashMap

/** Per-file state shared by the transformer: diagnostics, lualib usage and generated names. */
class TransformContext(val options: CompilerOptions) {
    val diagnostics = mutableListOf<Diagnostic>()

    /** Lualib features this file needs, and the `__K2L_*` names it references. */
    val lualib = sortedSetOf<String>()
    val lualibNames = sortedSetOf<String>()

    /** `Long` constants beyond 2^53 that are boxes in Lua (--long64 emulate on 5.1/5.2): (hi, lo) halves to the local holding the box. */
    val longLiterals = LinkedHashMap<Pair<Long, Long>, String>()

    /** Other files of the module this file requires: Lua module name -> local name. */
    val imports = LinkedHashMap<String, String>()

    /** Expressions wrapped to 32 bits by `--int-overflow wrap`, by identity, mapped to what they wrap (see IntOverflow.kt). */
    val int32Pending = IdentityHashMap<LuaExpr, LuaExpr>()

    /** Integer products made `x * y + 0` on float targets (never -0), by identity, mapped to the product (see IntOverflow.kt). */
    val zeroPending = IdentityHashMap<LuaExpr, LuaExpr>()
    private val generated = mutableMapOf<String, Int>()

    /** Kotlin position of the statements the transformer emitted; only filled with [CompilerOptions.sourceMap]. */
    val origins = IdentityHashMap<LuaStmt, Origin>()
    private var lineStarts: IntArray? = null

    /** The position where [element] starts, or null when source maps are off. */
    fun originOf(element: PsiElement): Origin? {
        if (!options.sourceMap) return null
        val starts = lineStarts ?: run {
            val text = element.containingFile.text
            val found = mutableListOf(0)
            text.forEachIndexed { i, c -> if (c == '\n') found += i + 1 }
            found.toIntArray().also { lineStarts = it }
        }
        val offset = element.textRange.startOffset
        val index = starts.binarySearch(offset).let { if (it >= 0) it else -it - 2 }
        return Origin(index + 1, offset - starts[index] + 1)
    }

    fun error(element: PsiElement, message: String) {
        diagnostics += Diagnostic.at(element, Severity.Error, message)
    }

    /** A fresh generated name: `____temp`, `____temp_1`, ... (Kotlin code never declares `____` names in practice). */
    fun temp(hint: String): String {
        val n = generated.merge(hint, 1, Int::plus)!! - 1
        return if (n == 0) "____$hint" else "____${hint}_$n"
    }
}

object LuaNames {
    /** Globals the generated code relies on; user declarations must not shadow them. */
    private val RESERVED_GLOBALS = setOf(
        "_G", "_ENV", "assert", "coroutine", "debug", "error", "getmetatable", "io", "ipairs", "load", "math",
        "next", "os", "package", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require",
        "select", "self", "setmetatable", "string", "table", "tonumber", "tostring", "type", "unpack", "utf8", "xpcall",
    )

    /** A method or field name: only Lua keywords need renaming, since it lives in a table. */
    fun member(kotlinName: String): String {
        val safe = of(kotlinName)
        return if (safe.startsWith("____") && kotlinName !in LuaPrinter.KEYWORDS) kotlinName else safe
    }

    fun of(kotlinName: String): String {
        val cleaned = buildString {
            for (c in kotlinName) {
                if ((c.isLetterOrDigit() || c == '_') && c.code < 128) append(c) else append("_").append(c.code.toString(16))
            }
        }
        val safe = if (cleaned.isEmpty() || cleaned[0].isDigit()) "_$cleaned" else cleaned
        return if (safe in LuaPrinter.KEYWORDS || safe in RESERVED_GLOBALS) "____$safe" else safe
    }
}
