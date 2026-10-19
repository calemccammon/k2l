package dev.k2l.transform

import com.intellij.psi.util.PsiTreeUtil
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * An expanded `inline fun` runs in the scope of its caller, so a local of the caller with the name of a top-level
 * declaration of the file that the function uses would hide it. Before the file is translated, such locals (and
 * parameters) of every enclosing declaration of an expanding call get a fresh Lua name instead.
 */
internal fun FileTransformer.renameHidingLocals(): Unit = with(session) {
    val globalsOf = HashMap<KtNamedFunction, Set<String>>()
    file.accept(object : KtTreeVisitorVoid() {
        override fun visitCallExpression(expression: KtCallExpression) {
            super.visitCallExpression(expression)
            val call = expression.resolveToCall()?.successfulCallOrNull<KaFunctionCall<*>>() ?: return
            val fn = call.symbol.psi as? KtNamedFunction ?: return
            if (!isLocalInline(fn) || !expands(fn, expression)) return
            val globals = usedGlobals(fn, globalsOf, HashSet())
            if (globals.isNotEmpty()) renameHiders(expression, globals)
        }
    })
}

private fun FileTransformer.isLocalInline(fn: KtNamedFunction) =
    fn.hasModifier(KtTokens.INLINE_KEYWORD) && fn.containingFile == file && classes.isSource(fn) && fn.bodyExpression != null

/** Whether the call has to be expanded: a `reified` type parameter, or a lambda that returns from the caller or is itself inlined. */
private fun FileTransformer.expands(fn: KtNamedFunction, call: KtCallExpression): Boolean = with(session) {
    if (fn.isReifiedInline()) return true
    call.valueArguments.mapNotNull { it.getArgumentExpression() }.any { arg ->
        val unwrapped = KtPsiUtil.safeDeparenthesize(arg).let { (it as? KtLabeledExpression)?.baseExpression ?: it }
        when (unwrapped) {
            is KtLambdaExpression -> hasNonLocalJump(unwrapped)
            is KtNameReferenceExpression -> (unwrapped.mainReference.resolve() as? KtParameter)?.let { isInlinedParameter(it) } == true
            else -> false
        }
    }
}

/** The names of the file's top-level declarations that [fn], or an inline function it calls, refers to. */
private fun FileTransformer.usedGlobals(
    fn: KtNamedFunction,
    cache: MutableMap<KtNamedFunction, Set<String>>,
    visiting: MutableSet<KtNamedFunction>,
): Set<String> = with(session) {
    cache[fn]?.let { return it }
    if (!visiting.add(fn)) return emptySet()
    val found = HashSet<String>()
    fn.bodyExpression?.accept(object : KtTreeVisitorVoid() {
        override fun visitReferenceExpression(expression: KtReferenceExpression) {
            super.visitReferenceExpression(expression)
            val target = (expression as? KtNameReferenceExpression)?.mainReference?.resolve() as? KtNamedDeclaration ?: return
            if (target.isTopLevel() && target.containingFile == file) {
                val name: String? = target.name
                if (name != null) found += name
            }
            if (target is KtNamedFunction && target !== fn && isLocalInline(target)) found += usedGlobals(target, cache, visiting)
        }
    })
    visiting.remove(fn)
    cache[fn] = found
    return found
}

private fun FileTransformer.renameHiders(site: KtExpression, globals: Set<String>) {
    val enclosing = PsiTreeUtil.getTopmostParentOfType(site, KtDeclaration::class.java) ?: return
    val locals = PsiTreeUtil.collectElements(enclosing) { it is KtProperty || it is KtParameter || it is KtDestructuringDeclarationEntry }
    for (d in locals.filterIsInstance<KtNamedDeclaration>()) {
        val raw: String? = d.name
        if (raw != null && hides(d, raw, globals, site)) naming.renames[d] = ctx.temp(LuaNames.of(raw))
    }
}

private fun FileTransformer.hides(d: KtNamedDeclaration, name: String, globals: Set<String>, site: KtExpression) =
    name in globals && isPlainLocal(d) && naming.renamed(d) == null &&
        d.textRange.startOffset < site.textRange.startOffset && scopeContains(d, site)

private fun isPlainLocal(d: KtNamedDeclaration) = when (d) {
    is KtProperty -> d.isLocal
    is KtParameter -> !d.hasValOrVar() && d.parent?.parent !is KtPrimaryConstructor
    else -> true
}

private fun scopeContains(d: KtNamedDeclaration, site: KtExpression) = PsiTreeUtil.getParentOfType(
    d,
    KtBlockExpression::class.java,
    KtFunction::class.java,
    KtForExpression::class.java,
    KtCatchClause::class.java,
)?.let { PsiTreeUtil.isAncestor(it, site, true) } == true
