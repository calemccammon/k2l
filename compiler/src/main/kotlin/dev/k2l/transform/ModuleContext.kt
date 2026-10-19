package dev.k2l.transform

import org.jetbrains.kotlin.KtNodeTypes
import org.jetbrains.kotlin.psi.KtClassLiteralExpression
import org.jetbrains.kotlin.psi.KtConstantExpression
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

    /**
     * Whether some file mentions `Float`: then the runtime recognizes floats among untyped values, so a statically
     * typed `Double` is printed by `__K2L_DoubleToString` rather than through the untyped printer.
     */
    val usesFloat: Boolean by lazy { files.any(::mentionsFloat) }

    private fun mentionsFloat(file: KtFile): Boolean {
        var found = false
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitConstantExpression(expression: KtConstantExpression) {
                if (expression.node.elementType == KtNodeTypes.FLOAT_CONSTANT && expression.text.last() in "fF") found = true
            }

            override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                if (expression.getReferencedName() in FLOAT_NAMES) found = true
            }
        })
        return found
    }

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
        private val FLOAT_NAMES = setOf("Float", "FloatArray", "floatArrayOf", "toFloat", "toFloatOrNull", "toFloatArray")

        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}
