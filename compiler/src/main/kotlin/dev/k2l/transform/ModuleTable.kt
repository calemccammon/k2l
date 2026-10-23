package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.isPrivate

/**
 * With globals, an internal top-level declaration is a local of its file, unless other files use it: then it is a field of
 * the module table, [MODULE_TABLE]. Files use another file's declarations where they name them, where that file's code
 * runs in them (bodies of inline functions, default values of parameters), and without naming them: operator functions
 * through operators, fun interfaces through lambdas.
 */
object ModuleTable {
    /** The internal top-level declaration that [reference], resolved to [resolved], has another file than [file] use. */
    fun sharedBy(reference: KtElement, resolved: PsiElement, file: KtFile): KtDeclaration? {
        val decl = generateSequence(resolved) { it.parent }.firstOrNull { it.parent is KtFile } as? KtDeclaration ?: return null
        if (!decl.hasModifier(KtTokens.INTERNAL_KEYWORD)) return null
        return decl.takeIf { it.containingFile != file || runsElsewhere(reference) }
    }

    /** The internal operator functions and fun interfaces of [file]. */
    fun usedUnnamed(file: KtFile): List<KtDeclaration> =
        file.declarations.filter { it.hasModifier(KtTokens.INTERNAL_KEYWORD) && isUsedUnnamed(it) }

    private fun isUsedUnnamed(decl: KtDeclaration) = when (decl) {
        is KtNamedFunction -> decl.hasModifier(KtTokens.OPERATOR_KEYWORD)
        is KtClass -> decl.hasModifier(KtTokens.FUN_KEYWORD)
        else -> false
    }

    private fun runsElsewhere(e: KtElement) = generateSequence(e.parent) { it.parent }.any { p ->
        (p is KtNamedFunction && p.hasModifier(KtTokens.INLINE_KEYWORD) && !p.isPrivate()) ||
            (p is KtParameter && p.defaultValue?.textRange?.contains(e.textRange) == true)
    }
}
