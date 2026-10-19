package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/**
 * The JVM binary name of [c], which is also its Lua class name (`toString()` prints it, as `Any.toString()` does on the JVM):
 * `pkg.Outer$Inner`; a local class is named after the declarations around it (`pkg.MainKt$main$Local`, `pkg.A$m$L`) and an
 * object expression is numbered within them (`pkg.MainKt$main$g$1` for `val g = object { }`), like the Kotlin/JVM compiler does.
 */
internal fun binaryName(c: KtClassOrObject): String {
    val outer = c.containingClassOrObject
    if (outer != null) return binaryName(outer) + "$" + c.name.orEmpty()
    val anonymous = c is KtObjectDeclaration && c.isObjectLiteral()
    if (!c.isLocal && !anonymous) {
        val pkg = c.containingKtFile.packageFqName.asString()
        return if (pkg.isEmpty()) c.name.orEmpty() else "$pkg.${c.name}"
    }
    val own = if (anonymous) anonymousIndex(c).toString() else c.name.orEmpty()
    return localOwnerName(c) + "$" + own
}

/** `MainKt` for `main.kt`: the class holding a file's top-level functions. */
private fun facadeName(file: KtFile): String {
    val pkg = file.packageFqName.asString()
    val name = file.name.removeSuffix(".kt").replaceFirstChar { it.uppercaseChar() } + "Kt"
    return if (pkg.isEmpty()) name else "$pkg.$name"
}

/** The enclosing class (or file facade) followed by the functions, properties and lambdas around [e]. */
private fun localOwnerName(e: PsiElement): String {
    val segments = ArrayDeque<String>()
    var p = e.parent
    while (p != null) {
        when {
            p is KtClassOrObject -> return binaryName(p) + segments.joinToString("") { "$$it" }
            p is KtFile -> return facadeName(p) + segments.joinToString("") { "$$it" }
            isNumbered(p) -> segments.addFirst(anonymousIndex(p).toString())
            p is KtNamedFunction || p is KtProperty -> (p as KtNamedDeclaration).name?.let(segments::addFirst)
        }
        p = p.parent
    }
    return segments.joinToString("$")
}

/** Lambdas, anonymous functions and object expressions are numbered within their container, in source order. */
private fun isNumbered(e: PsiElement) = e is KtFunctionLiteral || (e is KtNamedFunction && e.name == null) ||
    (e is KtObjectDeclaration && e.isObjectLiteral())

private fun isContainer(e: PsiElement) = isNumbered(e) || e is KtNamedFunction || e is KtProperty || e is KtClassOrObject || e is KtFile

private fun containerOf(e: PsiElement): PsiElement? = generateSequence(e.parent) { it.parent }.firstOrNull(::isContainer)

private fun anonymousIndex(e: PsiElement): Int {
    val container = containerOf(e) ?: return 1
    var count = 0
    var index = 0
    container.accept(object : KtTreeVisitorVoid() {
        override fun visitElement(element: PsiElement) {
            if (index != 0) return
            if (element !== container && isNumbered(element) && containerOf(element) === container) {
                count++
                if (element === e) {
                    index = count
                    return
                }
            }
            super.visitElement(element)
        }
    })
    return index
}
