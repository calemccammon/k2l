package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaTypeParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

private const val KCLASS_FEATURE = "KClass"

/** Builtin types whose runtime class cannot be told from the value (Long and Int, Char and String, ...): their class is static. */
private val STATIC_CLASSES = setOf(
    "kotlin/Int", "kotlin/Long", "kotlin/Short", "kotlin/Byte", "kotlin/Double", "kotlin/Float", "kotlin/Boolean", "kotlin/Char",
    "kotlin/String",
)

private fun FileTransformer.kclass(function: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_KClass$function"), args.toList())

/**
 * With reflection in the module (`::class`, `javaClass`), every class records its package-qualified and JVM binary names
 * after its table is created, see `KClass.lua`. Local classes have no qualified name.
 */
internal fun FileTransformer.classInfo(c: KtClassOrObject, ref: LuaExpr) {
    if (!usesReflection) return
    val local = c.isLocal
    val kind = if (c is KtClass && c.isInterface()) "interface" else "class"
    val qualified = if (local) LuaNil else c.fqName?.asString()?.let(::LuaString) ?: LuaNil
    val binary = if (local) LuaNil else LuaString(binaryName(c))
    emit(LuaCallStmt(LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_ClassInfo"), listOf(ref, qualified, binary, LuaString(kind)))))
}

/** An enum entry with a body is a subclass named after the entry: `pkg.Color$GREEN`, `pkg.Color.GREEN`. */
internal fun FileTransformer.entryClassInfo(entry: KtEnumEntry, ref: LuaExpr) {
    if (!usesReflection) return
    val name = entry.name ?: return
    val qualified = LuaString(entry.fqName?.asString() ?: name)
    val args = listOf(ref, qualified, LuaString(binaryName(entry)), LuaString("class"), LuaString(name))
    emit(LuaCallStmt(LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_ClassInfo"), args)))
}

/** `pkg.Outer$Inner` */
private fun binaryName(c: KtClassOrObject): String {
    val chain = generateSequence(c) { it.containingClassOrObject }.toList().reversed()
    val pkg = c.containingKtFile.packageFqName.asString()
    val names = chain.joinToString("$") { it.name ?: "" }
    return if (pkg.isEmpty()) names else "$pkg.$names"
}

/** `Foo::class`, `x::class` and `T::class` (for a reified `T`): a [KClass.lua] object, one per class. */
internal fun FileTransformer.classLiteral(e: KtClassLiteralExpression): LuaExpr = with(session) {
    val receiver = e.receiverExpression ?: return unsupported(e, "A class literal without a receiver")
    val ref =
        receiver as? KtNameReferenceExpression ?: (receiver as? KtDotQualifiedExpression)?.selectorExpression as? KtNameReferenceExpression
    val symbol = ref?.mainReference?.resolveToSymbol()
    if (symbol !is KaClassLikeSymbol && symbol !is KaTypeParameterSymbol) return valueClass(receiver)
    val type = (e.expressionType as? KaClassType)?.typeArguments?.firstOrNull()?.type ?: return unsupported(e, "This class literal")
    return classOfType(type, e)
}

private fun FileTransformer.classOfType(declared: KaType, element: KtElement): LuaExpr = with(session) {
    val type = reifiedType(declared)
    val source = (type.expandedSymbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
    val classId = type.expandedSymbol?.classId
    return when {
        source == null && classId == null -> unsupported(element, "The class of '${type.pretty()}'")

        source == null -> kclass("Named", LuaString(classId!!.asString().replace('/', '.')))

        // A companion has no table of its own (it lives on its class)
        source is KtObjectDeclaration && source.isCompanion() ->
            kclass("Named", LuaString(source.fqName?.asString() ?: ""), LuaString(source.name ?: "Companion"))

        else -> kclass("Of", classRef(source))
    }
}

/** `x::class`: the class of the value, found at run time unless the static type says it. */
private fun FileTransformer.valueClass(receiver: KtExpression): LuaExpr = with(session) {
    val value = expression(receiver)
    val classId = receiver.expressionType?.expandedSymbol?.classId?.asString()
    if (classId !in STATIC_CLASSES) return kclass("OfValue", value)
    if (!value.isSimple()) emit(LuaLocal(listOf(ctx.temp("unused")), listOf(value)))
    return kclass("Named", LuaString(classId!!.replace('/', '.')))
}

/** `KClass` and `java.lang.Class` members; both are the same Lua object. */
internal object ReflectionMappings {
    fun install(table: MappingTable) {
        table.def("kotlin/reflect/KClass.simpleName", "java/lang/Class.simpleName", "java/lang/Class.getSimpleName") {
            LuaIndex(self, LuaString("simpleName"))
        }
        table.def("kotlin/reflect/KClass.qualifiedName", "java/lang/Class.canonicalName", "java/lang/Class.getCanonicalName") {
            LuaIndex(self, LuaString("qualifiedName"))
        }
        table.def("java/lang/Class.name", "java/lang/Class.getName") { LuaIndex(self, LuaString("name")) }
        table.def("kotlin/reflect/KClass.isInstance", "java/lang/Class.isInstance") { method(self, "isInstance", arg(0)) }
        table.def("kotlin/jvm/javaClass") { LuaCall(ref(KCLASS_FEATURE, "__K2L_KClassOfValue"), listOf(self)) }
        table.def("kotlin/jvm/java", "kotlin/jvm/kotlin") { self }
    }
}
