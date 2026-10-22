package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtNamedFunction
import org.jetbrains.kotlin.psi.KtProperty

/**
 * Kotlin initializes a file's top-level properties when the file is first used, not when the program starts. k2l runs them
 * when the file loads unless somebody could notice: a file without `main` whose plain properties (see [isField]) have an
 * initializer that calls code or reads mutable state is *deferred*. Its plain properties are fields of the exports table,
 * and their initializers run on the first read or write of one of them (`LazyFile.lua`), so an import cycle or state that
 * `main` sets beforehand is seen as in Kotlin.
 */
internal class FileInit(private val session: KaSession, private val lazyInit: LazyInit) {
    private val cache = HashMap<KtFile, Boolean>()
    private val inProgress = HashSet<KtFile>()

    fun isDeferred(file: KtFile): Boolean {
        cache[file]?.let { return it }
        // a file whose initializers read a file that reads it back sees a half-initialized file either way
        if (!inProgress.add(file)) return false
        val result = with(session) { compute(file) }
        inProgress.remove(file)
        cache[file] = result
        return result
    }

    private fun KaSession.compute(file: KtFile): Boolean = with(lazyInit) {
        if (file.declarations.any { it is KtNamedFunction && it.name == "main" && it.receiverTypeReference == null }) return false
        val (fields, others) = file.declarations.filterIsInstance<KtProperty>().partition(::isField)
        // properties kept in locals (accessors, delegates) are set up when the file loads: only pure ones can wait
        if (others.any { !pure(it.initializer, null) || !pure(it.delegateExpression, null) }) return false
        return fields.any { !pure(it.initializer, null) }
    }

    companion object {
        /** A top-level property that is a plain value: no accessor functions, no delegate, not `const`. */
        fun isField(p: KtProperty) =
            p.isTopLevel && !p.hasAccessorFunctions() && p.delegate == null && !p.hasModifier(KtTokens.CONST_KEYWORD)
    }
}
