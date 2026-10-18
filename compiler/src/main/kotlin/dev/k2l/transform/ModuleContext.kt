package dev.k2l.transform

import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtFile
import org.jetbrains.kotlin.psi.KtSimpleNameExpression
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid

/** The files of the module being compiled and how they reference each other. */
class ModuleContext(
    val files: Set<KtFile>,
    /** Lua module name for `require`, e.g. `util.strings`. */
    val modulePath: (KtFile) -> String,
    /** Files that are part of an import cycle; their exports table is registered before anything is required. */
    val cyclic: Set<KtFile> = emptySet(),
    /** Files required by another file; `main()` is only called in files nobody requires. */
    val imported: Set<KtFile> = emptySet(),
) {
    /** Whether some file uses `::class` or `javaClass`: then classes record their qualified names (see Reflection.kt). */
    val usesReflection: Boolean by lazy { files.any(::mentionsReflection) }

    private fun mentionsReflection(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitClassLiteralExpression(expression: KtClassLiteralExpression) {
                found = true
            }

            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() == "javaClass") found = true
            }
        })
        return found
    }

    companion object {
        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}
