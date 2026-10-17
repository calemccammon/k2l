package dev.k2l.transform

import org.jetbrains.kotlin.psi.KtFile

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
    companion object {
        fun single(file: KtFile) = ModuleContext(setOf(file), { it.name.removeSuffix(".kt") })
    }
}
