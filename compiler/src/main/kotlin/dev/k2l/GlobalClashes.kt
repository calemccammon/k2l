package dev.k2l

import dev.k2l.transform.MODULE_TABLE
import org.jetbrains.kotlin.psi.KtNamedDeclaration

/**
 * With [ModuleMode.Global] all files share one set of globals and one module table: a Lua global or module table field
 * defined by two declarations, or a global named like the runtime table or the module table, is an error at the later
 * declaration.
 */
internal object GlobalClashes {
    fun of(
        globals: List<Pair<String, KtNamedDeclaration>>,
        shared: List<Pair<String, KtNamedDeclaration>>,
        runtime: String,
    ): List<Diagnostic> {
        val reserved = mapOf(runtime to "the k2l runtime", MODULE_TABLE to "the internal declarations that several files use")
        return clashes(globals, "the Lua global", reserved) +
            clashes(shared.map { (name, decl) -> "$MODULE_TABLE.$name" to decl }, "the Lua field", emptyMap())
    }

    /** Two [names] that are the same, or one of the [reserved] names, with what it holds. */
    private fun clashes(names: List<Pair<String, KtNamedDeclaration>>, what: String, reserved: Map<String, String>): List<Diagnostic> {
        val first = HashMap<String, KtNamedDeclaration>()
        return names.mapNotNull { (name, decl) ->
            val earlier = first.putIfAbsent(name, decl)
            val message = when {
                name in reserved -> "'${qualified(decl)}' is $what '$name', which holds ${reserved[name]}"

                earlier != null -> "'${qualified(decl)}' and '${qualified(earlier)}' (${earlier.containingKtFile.name}) are both " +
                    "$what '$name'"

                else -> return@mapNotNull null
            }
            Diagnostic.at(decl.nameIdentifier ?: decl, Severity.Error, message)
        }
    }

    private fun qualified(decl: KtNamedDeclaration) = decl.fqName?.asString() ?: decl.name.orEmpty()
}
