package dev.k2l

import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtQualifiedExpression

enum class Severity { Error, Warning }

/**
 * A problem in the Kotlin sources at [file]:[line]:[column] (1-based). [sourceLine] is the text of that line and
 * [length] how much of it, from [column], the problem spans; [hint] is an optional way around it.
 */
data class Diagnostic(
    val severity: Severity,
    val file: String,
    val line: Int,
    val column: Int,
    val message: String,
    val sourceLine: String? = null,
    val length: Int = 1,
    val hint: String? = null,
) {
    /** The one-line form, `file:line:col: error: message`. */
    override fun toString() = "$file:$line:$column: ${severity.name.lowercase()}: $message"

    /**
     * The form the CLI prints, as kotlinc does: the one-line form, then the source line with the span underlined, then
     * the hint (if any).
     */
    fun render(withHint: Boolean = true): String = buildString {
        append(this@Diagnostic.toString())
        val source = sourceLine?.trimEnd()
        if (source != null && source.isNotBlank()) {
            append('\n').append(source).append('\n')
            // Tabs stay tabs, so the carets line up with the code whatever the terminal's tab width.
            source.take(column - 1).forEach { append(if (it == '\t') '\t' else ' ') }
            val visible = (source.length - (column - 1)).coerceAtLeast(1)
            append("^".repeat(length.coerceIn(1, visible)))
        }
        if (hint != null && withHint) append("\n  hint: ").append(hint)
    }

    companion object {
        fun at(element: PsiElement, severity: Severity, message: String, range: TextRange = focus(element)): Diagnostic {
            val file = element.containingFile
            val text = file.text
            val offset = range.startOffset.coerceIn(0, text.length)
            var line = 1
            var lineStart = 0
            for (i in 0 until offset) {
                if (text[i] == '\n') {
                    line++
                    lineStart = i + 1
                }
            }
            val lineEnd = text.indexOf('\n', offset).let { if (it < 0) text.length else it }
            return Diagnostic(
                severity = severity,
                file = file.virtualFile?.path ?: file.name,
                line = line,
                column = offset - lineStart + 1,
                message = message,
                sourceLine = text.substring(lineStart, lineEnd),
                length = (minOf(range.endOffset, lineEnd) - offset).coerceAtLeast(1),
                hint = DiagnosticHints.hintFor(message),
            )
        }

        /**
         * The part of [element] to point at: for `a.b.c()` the selector `c()` from its name on, as kotlinc does, so that
         * problems in one chain get distinct columns.
         */
        private fun focus(element: PsiElement): TextRange {
            val selector = (element as? KtQualifiedExpression)?.selectorExpression ?: return element.textRange
            val name = (selector as? KtCallExpression)?.calleeExpression ?: selector
            return TextRange(name.textRange.startOffset, selector.textRange.endOffset)
        }
    }
}

/** `3 errors, 1 warning`: the count line printed after a build or check. */
fun summarize(diagnostics: List<Diagnostic>): String {
    val errors = diagnostics.count { it.severity == Severity.Error }
    val warnings = diagnostics.size - errors
    fun plural(n: Int, word: String) = "$n $word${if (n == 1) "" else "s"}"
    return "${plural(errors, "error")}, ${plural(warnings, "warning")}"
}
