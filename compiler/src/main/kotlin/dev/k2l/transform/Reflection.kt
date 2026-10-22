package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaTypeParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

// There is no reflection at run time: of `KClass`, only `simpleName` of a class literal is supported (`x::class.simpleName`,
// `Foo::class.simpleName`), and of the callable references only `name`, which is known where the reference is written
// (`::greet.name`) or is the `name` of the KProperty a delegate receives.

/** Builtin types whose runtime class cannot be told from the value (Long and Int, Char and String, ...): their name is static. */
private val STATIC_CLASSES = setOf(
    "kotlin/Int", "kotlin/Long", "kotlin/Short", "kotlin/Byte", "kotlin/Double", "kotlin/Float", "kotlin/Boolean", "kotlin/Char",
    "kotlin/String",
)

/** `Foo::class.simpleName` or `x::class.simpleName`: the simple name, known from the type or found at run time. */
internal fun FileTransformer.classLiteral(e: KtClassLiteralExpression): LuaExpr = with(session) {
    val parent = e.parent as? KtDotQualifiedExpression
    val selector = (parent?.selectorExpression as? KtNameReferenceExpression)?.getReferencedName()
    if (parent?.receiverExpression != e || selector != "simpleName") return unsupported(e, "Class literal '${e.text}'")
    val receiver = e.receiverExpression ?: return unsupported(e, "A class literal without a receiver")
    val ref = receiver as? KtNameReferenceExpression
        ?: (receiver as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
    val symbol = ref?.mainReference?.resolveToSymbol()
    if (symbol !is KaClassLikeSymbol && symbol !is KaTypeParameterSymbol) return valueSimpleName(receiver)
    val type = (e.expressionType as? KaClassType)?.typeArguments?.firstOrNull()?.type ?: return unsupported(e, "This class literal")
    return staticSimpleName(type, e)
}

private fun FileTransformer.staticSimpleName(declared: KaType, element: KtElement): LuaExpr = with(session) {
    val type = reifiedType(declared)
    val source = (type.expandedSymbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
    val classId = type.expandedSymbol?.classId
    return when {
        source != null -> (source.name ?: "Companion".takeIf { (source as? KtObjectDeclaration)?.isCompanion() == true })
            ?.let(::LuaString) ?: LuaNil

        classId != null -> LuaString(classId.shortClassName.asString())

        else -> unsupported(element, "The class of '${type.pretty()}'")
    }
}

/** `x::class.simpleName`: the name of the value's class, found at run time unless the static type says it. */
private fun FileTransformer.valueSimpleName(receiver: KtExpression): LuaExpr = with(session) {
    val value = expression(receiver)
    val classId = receiver.expressionType?.expandedSymbol?.classId?.asString()
    if (classId !in STATIC_CLASSES) return lualibCall("SimpleName", value)
    if (!value.isSimple()) emit(LuaLocal(listOf(ctx.temp("unused")), listOf(value)))
    return LuaString(classId!!.substringAfterLast('/'))
}

private val PROPERTIES = listOf("KProperty", "KProperty0", "KProperty1", "KProperty2")
private val MUTABLE_PROPERTIES = listOf("KMutableProperty", "KMutableProperty0", "KMutableProperty1", "KMutableProperty2")
private const val MAX_ARITY = 22

/** `KFunction1.name`: members of a reference to a function resolve in the interface of its arity. */
private val FUNCTIONS = listOf("KFunction") + (0..MAX_ARITY).flatMap { listOf("KFunction$it", "KSuspendFunction$it") }

/**
 * `simpleName` of a class literal (already the name, see [classLiteral]), the `name` of a callable reference, and calls of a
 * property reference.
 */
internal object ReflectionMappings {
    private fun isPropertyObject(site: CallSite): Boolean = with(site.session) {
        val id = site.receiverType?.expandedSymbol?.classId?.asString() ?: return false
        id.startsWith("kotlin/reflect/KProperty") || id.startsWith("kotlin/reflect/KMutableProperty")
    }

    fun install(table: MappingTable) {
        table.def("kotlin/reflect/KClass.simpleName") { self }
        // a property reference, or the property passed to a delegate, is an object with a `name`; a function reference is a
        // plain Lua function, whose name is known only where the reference is written
        val names = (listOf("KCallable") + FUNCTIONS + PROPERTIES + MUTABLE_PROPERTIES).map { "kotlin/reflect/$it.name" }
        table.def(*names.toTypedArray()) {
            with(session) { referencedName(element) } ?: LuaIndex(self, LuaString("name")).takeIf { isPropertyObject(this) }
        }
        // calling a property reference reads the property
        val invokes = listOf("KProperty0", "KProperty1", "KMutableProperty0", "KMutableProperty1").map { "kotlin/reflect/$it.invoke" }
        table.def(*invokes.toTypedArray()) { method(self, "get", *args.toTypedArray()) }
    }
}

/** `::twice.name` and `Person::greet.name`: the name is known where the reference is written, so no object is needed. */
context(s: KaSession)
internal fun referencedName(element: KtElement): LuaExpr? = with(s) {
    val receiver = (element as? KtDotQualifiedExpression)?.receiverExpression ?: return null
    val reference = KtPsiUtil.safeDeparenthesize(receiver) as? KtCallableReferenceExpression ?: return null
    val constructor = reference.callableReference.mainReference.resolveToSymbol() is KaConstructorSymbol
    LuaString(if (constructor) "<init>" else reference.callableReference.getReferencedName())
}
