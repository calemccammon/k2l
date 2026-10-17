package dev.k2l.transform

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.*
import com.intellij.psi.PsiElement

internal class SuperInfo(
    val base: KtClassOrObject?,
    val baseCall: KtSuperTypeCallEntry?,
    val interfaces: List<KtClassOrObject>,
    val unsupported: KtSuperTypeListEntry?,
    /** A lualib class extended instead of an in-file one, e.g. `__K2L_Exception`. */
    val libraryBase: String? = null,
)

/** Queries over the classes of the module being compiled: supertypes, initializers and `equals`. */
internal class ClassHierarchy(
    private val session: KaSession,
    private val file: KtFile,
    private val module: ModuleContext,
) {
    /** Whether [psi] is declared in one of the module's source files (not a library). */
    fun isSource(psi: PsiElement?): Boolean =
        (psi?.containingFile as? KtFile)?.let { it in module.files } == true

    /** [c] and its in-file supertypes, supertypes first. */
    fun hierarchy(c: KtClassOrObject): List<KtClassOrObject> {
        val result = LinkedHashSet<KtClassOrObject>()
        fun visit(k: KtClassOrObject) {
            if (k in result) return
            superInfo(k).let { listOfNotNull(it.base) + it.interfaces }.forEach(::visit)
            result += k
        }
        visit(c)
        return result.toList()
    }

    fun classInFile(id: ClassId): KtClassOrObject? {
        var found: KtClassOrObject? = null
        for (f in listOf(file) + module.files.filter { it != file }) {
            if (found != null) break
            f.accept(object : KtTreeVisitorVoid() {
                override fun visitClassOrObject(classOrObject: KtClassOrObject) {
                    if (found == null && classOrObject.getClassId() == id) found = classOrObject
                    if (found == null) super.visitClassOrObject(classOrObject)
                }
            })
        }
        return found
    }

    private val superInfoCache = HashMap<KtClassOrObject, SuperInfo>()

    fun superInfo(c: KtClassOrObject): SuperInfo = superInfoCache.getOrPut(c) {
        with(session) {
            var base: KtClassOrObject? = null
            var baseCall: KtSuperTypeCallEntry? = null
            var bad: KtSuperTypeListEntry? = null
            var libraryBase: String? = null
            val interfaces = mutableListOf<KtClassOrObject>()
            for (entry in c.superTypeListEntries) {
                val symbol = entry.typeReference?.type?.expandedSymbol
                val psi = symbol?.psi as? KtClassOrObject
                when {
                    symbol?.classId?.asString() in MARKER_INTERFACES -> Unit
                    symbol?.classId?.asString() in LIBRARY_CLASSES -> {
                        libraryBase = LIBRARY_CLASSES[symbol?.classId?.asString()]
                        baseCall = entry as? KtSuperTypeCallEntry
                    }
                    psi == null || !isSource(psi) -> bad = bad ?: entry
                    psi is KtClass && psi.isInterface() -> interfaces += psi
                    else -> {
                        base = psi
                        baseCall = entry as? KtSuperTypeCallEntry
                    }
                }
            }
            SuperInfo(base, baseCall, interfaces, bad, libraryBase)
        }
    }

    private val initCache = HashMap<KtClassOrObject, Boolean>()

    /** Whether the primary constructor does anything, i.e. whether `____init` is generated for it. */
    fun initNeeded(c: KtClassOrObject): Boolean = initCache.getOrPut(c) {
        if (c is KtClass && c.isInterface() || !hasPrimary(c)) return@getOrPut false
        val info = superInfo(c)
        val baseCall = info.baseCall
        (c is KtClass && (c.isEnum() || c.primaryConstructorParameters.isNotEmpty())) ||
            c.declarations.any { (it is KtProperty && it.initializer != null) || it is KtAnonymousInitializer } ||
            (baseCall != null && baseCall.valueArguments.isNotEmpty()) ||
            info.libraryBase != null || (info.base != null && (!hasPrimary(info.base) || initNeeded(info.base)))
    }

    fun mayOverrideEquals(t: KaType?): Boolean = with(session) {
        val symbol = t?.expandedSymbol ?: return true
        if (symbol.classId?.asString() in IDENTITY_TYPES) return false
        if (symbol.classKind == KaClassKind.ENUM_CLASS || symbol.classKind.isObject) return false
        val psi = symbol.psi as? KtClassOrObject
        if (psi == null || !isSource(psi)) return true
        return overridesEquals(psi) || psi.hasModifier(KtTokens.OPEN_KEYWORD) || psi.hasModifier(KtTokens.ABSTRACT_KEYWORD) ||
            psi.hasModifier(KtTokens.SEALED_KEYWORD) || (psi is KtClass && psi.isInterface())
    }

    fun knownEquals(t: KaType): Boolean = with(session) {
        val psi = t.expandedSymbol?.psi as? KtClassOrObject ?: return false
        return isSource(psi) && overridesEquals(psi)
    }

    fun overridesEquals(c: KtClassOrObject): Boolean =
        (c is KtClass && c.isData()) ||
            c.declaredFunction("equals")?.hasModifier(KtTokens.OVERRIDE_KEYWORD) == true ||
            superInfo(c).base?.let { overridesEquals(it) } == true
}

internal fun KtClassOrObject.declaredFunction(name: String) =
    declarations.filterIsInstance<KtNamedFunction>().firstOrNull { it.name == name }

internal fun hasPrimary(c: KtClassOrObject) =
    c !is KtClass || c.primaryConstructor != null || c.secondaryConstructors.isEmpty()
