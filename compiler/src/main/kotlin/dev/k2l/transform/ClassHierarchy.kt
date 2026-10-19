package dev.k2l.transform

import com.intellij.psi.PsiElement
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

internal class SuperInfo(
    val base: KtClassOrObject?,
    val baseCall: KtSuperTypeCallEntry?,
    val interfaces: List<KtClassOrObject>,
    val unsupported: KtSuperTypeListEntry?,
    /** A lualib class extended instead of an in-file one, e.g. `__K2L_Exception`. */
    val libraryBase: String? = null,
    /** The class implements `kotlin.sequences.Sequence` itself (its table extends the lualib `Sequence`). */
    val sequenceBase: Boolean = false,
    /** The class extends `AbstractCoroutineContextElement(key)`, which the lualib implements. */
    val elementBase: Boolean = false,
    /** The class implements `Sequence` next to a base class: the lualib `Sequence` is one of its interfaces. */
    val sequenceMixin: Boolean = false,
)

/** Queries over the classes of the module being compiled: supertypes, initializers and `equals`. */
internal class ClassHierarchy(private val session: KaSession, private val file: KtFile, private val module: ModuleContext) {
    /** Whether [psi] is declared in one of the module's source files (not a library). */
    fun isSource(psi: PsiElement?): Boolean = (psi?.containingFile as? KtFile)?.let { it in module.files } == true

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

    /** Top-level functions of the module's files. */
    fun topLevelFunctions(): List<KtNamedFunction> = module.files.flatMap { it.declarations.filterIsInstance<KtNamedFunction>() }

    fun classInFile(id: ClassId): KtClassOrObject? = module.classInFile(id, file)

    private val superInfoCache = HashMap<KtClassOrObject, SuperInfo>()

    fun superInfo(c: KtClassOrObject): SuperInfo = superInfoCache.getOrPut(c) {
        if (c is KtEnumEntry) {
            // an entry with a body is a subclass of its enum class
            val call = c.initializerList?.initializers?.firstOrNull() as? KtSuperTypeCallEntry
            return@getOrPut SuperInfo(c.containingClassOrObject, call, emptyList(), null)
        }
        with(session) { classifySupertypes(c, ::isSource, ::isSequenceClass) }
    }

    /** Whether [c] or a source class it extends implements `Sequence`. */

    private val initCache = HashMap<KtClassOrObject, Boolean>()

    /** Whether the primary constructor does anything, i.e. whether `____init` is generated for it. */
    fun initNeeded(c: KtClassOrObject): Boolean = initCache.getOrPut(c) {
        if ((c is KtClass && c.isInterface()) || !hasPrimary(c)) return@getOrPut false
        val info = superInfo(c)
        c.hasConstructorState() || c.hasInitializers() || info.baseCall?.valueArguments?.isNotEmpty() == true ||
            info.libraryBase != null || info.elementBase || info.base?.let { !hasPrimary(it) || initNeeded(it) } == true
    }

    private fun KtClassOrObject.hasConstructorState() =
        this is KtClass && (isEnum() || isInner() || primaryConstructorParameters.isNotEmpty())

    private fun KtClassOrObject.hasInitializers() =
        declarations.any { (it is KtProperty && (it.initializer != null || it.delegate != null)) || it is KtAnonymousInitializer }

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

    fun overridesEquals(c: KtClassOrObject): Boolean = (c is KtClass && c.isData()) ||
        c.declaredFunction("equals")?.hasModifier(KtTokens.OVERRIDE_KEYWORD) == true ||
        superInfo(c).base?.let { overridesEquals(it) } == true
}

internal fun KtClassOrObject.declaredFunction(name: String) =
    declarations.filterIsInstance<KtNamedFunction>().firstOrNull { it.name == name }

internal fun hasPrimary(c: KtClassOrObject) = c !is KtClass || c.primaryConstructor != null || c.secondaryConstructors.isEmpty()

/** Whether [c] (or a source superclass) implements `Sequence`. */
internal fun ClassHierarchy.isSequenceClass(c: KtClassOrObject): Boolean = superInfo(c).let {
    it.sequenceBase || it.sequenceMixin ||
        it.base?.let(::isSequenceClass) == true
}
