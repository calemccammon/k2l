package dev.k2l

import com.intellij.psi.PsiElement

enum class Severity { Error, Warning }

data class Diagnostic(
    val severity: Severity,
    val file: String,
    val line: Int,
    val column: Int,
    val message: String,
) {
    override fun toString() = "$file:$line:$column: ${severity.name.lowercase()}: $message"

    companion object {
        fun at(element: PsiElement, severity: Severity, message: String): Diagnostic {
            val file = element.containingFile
            val offset = element.textRange.startOffset
            val text = file.text
            var line = 1
            var lineStart = 0
            for (i in 0 until offset) if (text[i] == '\n') { line++; lineStart = i + 1 }
            return Diagnostic(severity, file.virtualFile?.path ?: file.name, line, offset - lineStart + 1, message)
        }
    }
}
