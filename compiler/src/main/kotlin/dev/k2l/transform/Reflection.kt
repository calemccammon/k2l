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
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Builtin types whose runtime class cannot be told from the value (Long and Int, Char and String, ...): their class is static. */
private val STATIC_CLASSES = setOf(
    "kotlin/Int", "kotlin/Long", "kotlin/Short", "kotlin/Byte", "kotlin/Double", "kotlin/Float", "kotlin/Boolean", "kotlin/Char",
    "kotlin/String",
)

private fun FileTransformer.kclass(function: String, vararg args: LuaExpr): LuaExpr =
    LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_KClass$function"), args.toList())

/**
 * With reflection in the module (`::class`, `javaClass`), every class records its package-qualified and JVM binary names
 * after its table is created, see `KClass.lua`. Local classes have no qualified name, object expressions no simple name.
 */
internal fun FileTransformer.classInfo(c: KtClassOrObject, ref: LuaExpr) {
    if (!usesReflection) return
    val local = c.isLocal
    val kind = if (c is KtClass && c.isInterface()) "interface" else "class"
    val qualified = if (local) LuaNil else c.fqName?.asString()?.let(::LuaString) ?: LuaNil
    // an object expression has no simple name (false: not derived from the class name)
    val args = listOf(ref, qualified, LuaString(binaryName(c)), LuaString(kind)) + listOfNotNull(LuaBool(false).takeIf { c.name == null })
    emit(LuaCallStmt(LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_ClassInfo"), args)))
    // A companion without supertypes is the class's table at run time; `companionValue::class` finds its names there
    val companion = (c as? KtClass)?.companionObjects?.firstOrNull()?.takeUnless { hasOwnTable(it) } ?: return
    val names =
        listOf(LuaString(companion.fqName?.asString() ?: ""), LuaString(binaryName(companion)), LuaString(companion.name ?: "Companion"))
    emit(LuaCallStmt(LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_CompanionInfo"), listOf(ref) + names)))
}

/** An enum entry with a body is a subclass named after the entry: `pkg.Color$GREEN`, `pkg.Color.GREEN`. */
internal fun FileTransformer.entryClassInfo(entry: KtEnumEntry, ref: LuaExpr) {
    if (!usesReflection) return
    val name = entry.name ?: return
    val qualified = LuaString(entry.fqName?.asString() ?: name)
    val args = listOf(ref, qualified, LuaString(binaryName(entry)), LuaString("class"), LuaString(name))
    emit(LuaCallStmt(LuaCall(lualibRef(KCLASS_FEATURE, "__K2L_ClassInfo"), args)))
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

internal fun FileTransformer.classOfType(declared: KaType, element: KtElement): LuaExpr = with(session) {
    val type = reifiedType(declared)
    val source = (type.expandedSymbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
    val classId = type.expandedSymbol?.classId
    return when {
        source == null && classId == null -> unsupported(element, "The class of '${type.pretty()}'")

        source == null -> kclass("Named", LuaString(classId!!.asString().replace('/', '.')))

        // A companion without supertypes has no table of its own (it lives on its class)
        source is KtObjectDeclaration && source.isCompanion() && !hasOwnTable(source) ->
            kclass(
                "Named",
                LuaString(source.fqName?.asString() ?: ""),
                LuaString(source.name ?: "Companion"),
                LuaString(binaryName(source)),
            )

        else -> kclass("Of", classRef(source))
    }
}

/** `x::class`: the class of the value, found at run time unless the static type says it. */
private fun FileTransformer.valueClass(receiver: KtExpression): LuaExpr = with(session) {
    val value = expression(receiver)
    staticArrayClass(receiver.expressionType)?.let { array ->
        if (!value.isSimple()) emit(LuaLocal(listOf(ctx.temp("unused")), listOf(value)))
        return array
    }
    val classId = receiver.expressionType?.expandedSymbol?.classId?.asString()
    if (classId !in STATIC_CLASSES) return kclass("OfValue", value)
    if (!value.isSimple()) emit(LuaLocal(listOf(ctx.temp("unused")), listOf(value)))
    return kclass("Named", LuaString(classId!!.replace('/', '.')))
}

private val PROPERTIES = listOf("KProperty", "KProperty0", "KProperty1", "KProperty2")
private val MUTABLE_PROPERTIES = listOf("KMutableProperty", "KMutableProperty0", "KMutableProperty1", "KMutableProperty2")
private const val MAX_ARITY = 22

/** `KFunction1.call`: members of a reference to a function resolve in the interface of its arity. */
private val FUNCTIONS = listOf("KFunction") + (0..MAX_ARITY).flatMap { listOf("KFunction$it", "KSuspendFunction$it") }
private val CALLABLES = listOf("KCallable") + FUNCTIONS + PROPERTIES + MUTABLE_PROPERTIES

/** The members of the reflection interfaces that need kotlin-reflect at run time (`-no-reflect` on the JVM), by declaring interface. */
private val NEEDS_REFLECT = listOf(
    listOf("KClass") to listOf(
        "isData", "isAbstract", "isOpen", "isSealed", "isFinal", "isCompanion", "isInner", "isFun", "isValue", "objectInstance",
        "sealedSubclasses", "supertypes", "members", "constructors", "nestedClasses", "typeParameters", "visibility",
    ),
    listOf("KAnnotatedElement") + CALLABLES to listOf("annotations"),
    CALLABLES to listOf(
        "parameters", "returnType", "typeParameters", "visibility", "isFinal", "isOpen", "isAbstract", "isSuspend", "call", "callBy",
    ),
    FUNCTIONS to listOf("isInline", "isExternal", "isOperator", "isInfix", "isSuspend"),
    PROPERTIES + MUTABLE_PROPERTIES to listOf("isLateinit", "isConst", "getter"),
    MUTABLE_PROPERTIES to listOf("setter"),
    listOf("KProperty0", "KProperty1", "KProperty2") to listOf("getDelegate"),
)

/** `KClass` and `java.lang.Class` members; both kinds of objects have the same fields. */
internal object ReflectionMappings {
    fun install(table: MappingTable) {
        table.def("kotlin/reflect/KClass.simpleName") { LuaIndex(self, LuaString("simpleName")) }
        // `typeOf<T>()` (see TypeOf.kt)
        table.def("kotlin/reflect/KType.isMarkedNullable") { LuaIndex(self, LuaString("isMarkedNullable")) }
        table.def("kotlin/reflect/KType.classifier") { LuaIndex(self, LuaString("classifier")) }
        table.def("kotlin/reflect/KType.arguments") { LuaIndex(self, LuaString("arguments")) }
        table.def("kotlin/reflect/KTypeProjection.type") { LuaIndex(self, LuaString("type")) }
        // the Java name of an anonymous class is "" where Kotlin's is null
        table.def("java/lang/Class.simpleName", "java/lang/Class.getSimpleName") {
            LuaBinary(LuaBinOp.Or, LuaIndex(self, LuaString("simpleName")), LuaString(""))
        }
        table.def("kotlin/reflect/KClass.qualifiedName", "java/lang/Class.canonicalName", "java/lang/Class.getCanonicalName") {
            LuaIndex(self, LuaString("qualifiedName"))
        }
        table.def("java/lang/Class.name", "java/lang/Class.getName") { LuaIndex(self, LuaString("name")) }
        table.def("kotlin/reflect/KClass.isInstance", "java/lang/Class.isInstance") { method(self, "isInstance", arg(0)) }
        table.def(
            "kotlin/reflect/KProperty0.get",
            "kotlin/reflect/KProperty1.get",
            "kotlin/reflect/KProperty0.invoke",
            "kotlin/reflect/KProperty1.invoke",
            "kotlin/reflect/KMutableProperty0.get",
            "kotlin/reflect/KMutableProperty1.get",
        ) { method(self, "get", *args.toTypedArray()) }
        table.def("kotlin/reflect/KMutableProperty0.set", "kotlin/reflect/KMutableProperty1.set") {
            method(self, "set", *args.toTypedArray())
        }
        // References and the KProperty passed to delegates are objects with a `name`
        table.def(*CALLABLES.map { "kotlin/reflect/$it.name" }.toTypedArray()) {
            with(session) { referencedName(element) } ?: LuaIndex(self, LuaString("name"))
        }
        // Needs kotlin-reflect, which the JVM program may lack too: then these throw KotlinReflectionNotSupportedError.
        val needsReflect = NEEDS_REFLECT.flatMap { (owners, members) -> owners.flatMap { o -> members.map { "kotlin/reflect/$o.$it" } } }
        table.def(*needsReflect.toTypedArray()) { LuaCall(ref("NeedsReflect", "__K2L_NeedsReflect"), listOf(self) + args) }
        // A Class is an object of its own (it prints without the KClass suffix), one per KClass
        table.def("kotlin/jvm/javaClass") {
            val array = transformer.staticArrayClass(receiverType)
            if (array != null && !self.isSimple()) transformer.emit(LuaLocal(listOf(transformer.ctx.temp("unused")), listOf(self)))
            val kclass = array ?: LuaCall(ref(KCLASS_FEATURE, "__K2L_KClassOfValue"), listOf(self))
            LuaCall(ref(KCLASS_FEATURE, "__K2L_JavaClass"), listOf(kclass))
        }
        table.def("kotlin/jvm/java") { LuaCall(ref(KCLASS_FEATURE, "__K2L_JavaClass"), listOf(self)) }
        table.def("java/lang/Class.enumConstants", "java/lang/Class.getEnumConstants") {
            LuaCall(ref("EnumConstants", "__K2L_EnumConstants"), listOf(self))
        }
        table.def("kotlin/jvm/declaringJavaClass") { LuaCall(ref("EnumConstants", "__K2L_EnumDeclaringClass"), listOf(self)) }
        table.def("kotlin/jvm/kotlin") { LuaIndex(self, LuaString("____kotlin")) }
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
