package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaStarTypeProjection
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.analysis.api.types.KaTypeArgumentWithVariance
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtElement
import org.jetbrains.kotlin.types.Variance

/** The JVM names of builtin types in a `KType`'s string (the wrapper classes of the primitives, see [PRIMITIVE_NAMES]). */
private val KTYPE_JVM_NAMES = mapOf(
    "kotlin/Any" to "java.lang.Object", "kotlin/String" to "java.lang.String", "kotlin/CharSequence" to "java.lang.CharSequence",
    "kotlin/Number" to "java.lang.Number", "kotlin/Comparable" to "java.lang.Comparable", "kotlin/Enum" to "java.lang.Enum",
    "kotlin/Throwable" to "java.lang.Throwable", "kotlin/Cloneable" to "java.lang.Cloneable",
    "kotlin/Annotation" to "java.lang.annotation.Annotation", "kotlin/Int" to "java.lang.Integer", "kotlin/Long" to "java.lang.Long",
    "kotlin/Short" to "java.lang.Short", "kotlin/Byte" to "java.lang.Byte", "kotlin/Double" to "java.lang.Double",
    "kotlin/Float" to "java.lang.Float", "kotlin/Char" to "java.lang.Character", "kotlin/Boolean" to "java.lang.Boolean",
    "kotlin/collections/Iterable" to "java.lang.Iterable", "kotlin/collections/MutableIterable" to "java.lang.Iterable",
    "kotlin/collections/Iterator" to "java.util.Iterator", "kotlin/collections/MutableIterator" to "java.util.Iterator",
    "kotlin/collections/ListIterator" to "java.util.ListIterator", "kotlin/collections/MutableListIterator" to "java.util.ListIterator",
    "kotlin/collections/Collection" to "java.util.Collection", "kotlin/collections/MutableCollection" to "java.util.Collection",
    "kotlin/collections/List" to "java.util.List", "kotlin/collections/MutableList" to "java.util.List",
    "kotlin/collections/Set" to "java.util.Set", "kotlin/collections/MutableSet" to "java.util.Set",
    "kotlin/collections/Map" to "java.util.Map", "kotlin/collections/MutableMap" to "java.util.Map",
    "kotlin/collections/Map.Entry" to "java.util.Map\$Entry", "kotlin/collections/MutableMap.MutableEntry" to "java.util.Map\$Entry",
)

/** A non-null primitive on its own is its primitive class (`typeOf<Int>()` is `int`); as a type argument it is the wrapper. */
private val PRIMITIVE_NAMES = mapOf(
    "kotlin/Int" to "int",
    "kotlin/Long" to "long",
    "kotlin/Short" to "short",
    "kotlin/Byte" to "byte",
    "kotlin/Double" to "double",
    "kotlin/Float" to "float",
    "kotlin/Char" to "char",
    "kotlin/Boolean" to "boolean",
)

/** `typeOf<T>()`: a `KType` like the JVM's without kotlin-reflect (see KType.lua), made from the static (or reified) type. */
internal object TypeOfMappings {
    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId != "kotlin/reflect/typeOf") return null
        val call = with(site.session) { site.element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() } ?: return null
        val type = call.typeArgumentsMapping.values.firstOrNull() ?: return null
        return site.transformer.kTypeOf(type, site.element)
    }
}

internal fun FileTransformer.kTypeOf(declared: KaType, element: KtElement): LuaExpr = with(session) {
    val type = reifiedType(declared)
    val arguments = (type as? KaClassType)?.typeArguments.orEmpty().map { p ->
        when (p) {
            is KaStarTypeProjection -> LuaBool(false)

            is KaTypeArgumentWithVariance -> LuaTable(
                listOf(LuaField.Positional(LuaString(variancePrefix(p.variance))), LuaField.Positional(kTypeOf(p.type, element))),
            )
        }
    }
    val args = listOf(
        LuaString(kTypeName(type, false)),
        LuaBool(type.isMarkedNullable),
        classifier(type, element),
        LuaTable(arguments.map { LuaField.Positional(it) }),
    )
    return LuaCall(lualibRef("KType", "__K2L_TypeOf"), args)
}

/**
 * The `classifier`: a mutable collection interface is its read-only one (both are the same Java interface, so `==` holds on the
 * JVM), and an array its array class.
 */
private fun FileTransformer.classifier(type: KaType, element: KtElement): LuaExpr = with(session) {
    val id = type.expandedSymbol?.classId?.asString()
    val readOnly = READ_ONLY_COLLECTIONS[id]
    return when {
        readOnly != null -> LuaCall(lualibRef("KClass", "__K2L_KClassNamed"), listOf(LuaString(readOnly)))
        else -> staticArrayClass(type) ?: classOfType(type, element)
    }
}

private val READ_ONLY_COLLECTIONS = listOf("Iterable", "Iterator", "ListIterator", "Collection", "List", "Set", "Map")
    .associate { "kotlin/collections/Mutable$it" to "kotlin.collections.$it" } +
    ("kotlin/collections/MutableMap.MutableEntry" to "kotlin.collections.Map.Entry")

private fun variancePrefix(v: Variance) = when (v) {
    Variance.IN_VARIANCE -> "in "
    Variance.OUT_VARIANCE -> "out "
    Variance.INVARIANT -> ""
}

/** The type as `TypeReference.toString()` writes it; a [typeArgument] names a primitive by its wrapper class. */
private fun FileTransformer.kTypeName(declared: KaType, typeArgument: Boolean): String = with(session) {
    val type = reifiedType(declared)
    val classId = type.expandedSymbol?.classId
    val id = classId?.asString()
    val source = (type.expandedSymbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
    val base = when {
        type.isNothingType -> "kotlin.Nothing"

        id in PRIMITIVE_NAMES && !type.isMarkedNullable && !typeArgument -> PRIMITIVE_NAMES.getValue(id!!)

        source != null -> binaryName(source)

        id in KTYPE_JVM_NAMES -> KTYPE_JVM_NAMES.getValue(id!!)

        id != null && id.matches(Regex("kotlin/(Suspend)?Function\\d+")) -> "kotlin.jvm.functions." + id.substringAfter('/')

        classId != null -> classId.packageFqName.asString().let { if (it.isEmpty()) "" else "$it." } +
            classId.relativeClassName.asString().replace('.', '$')

        else -> type.pretty()
    }
    val arguments = (type as? KaClassType)?.typeArguments.orEmpty()
    val args = if (arguments.isEmpty()) {
        ""
    } else {
        arguments.joinToString(", ", "<", ">") { p ->
            when (p) {
                is KaStarTypeProjection -> "*"
                is KaTypeArgumentWithVariance -> variancePrefix(p.variance) + kTypeName(p.type, true)
            }
        }
    }
    return base + args + if (type.isMarkedNullable) "?" else ""
}
