package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtClassOrObject

/** The JVM descriptors and Java names of the primitive arrays: `IntArray` is `[I`, `int[]`. */
private val PRIMITIVE_ARRAYS = mapOf(
    "kotlin/IntArray" to ("I" to "int"),
    "kotlin/LongArray" to ("J" to "long"),
    "kotlin/DoubleArray" to ("D" to "double"),
    "kotlin/FloatArray" to ("F" to "float"),
    "kotlin/BooleanArray" to ("Z" to "boolean"),
    "kotlin/CharArray" to ("C" to "char"),
    "kotlin/ShortArray" to ("S" to "short"),
    "kotlin/ByteArray" to ("B" to "byte"),
)

/** JVM classes of the builtin types an `Array` holds (`Array<Int>` is `[Ljava.lang.Integer;`). */
private val ELEMENT_CLASSES = mapOf(
    "kotlin/Any" to "java.lang.Object", "kotlin/String" to "java.lang.String", "kotlin/Int" to "java.lang.Integer",
    "kotlin/Long" to "java.lang.Long", "kotlin/Double" to "java.lang.Double", "kotlin/Float" to "java.lang.Float",
    "kotlin/Boolean" to "java.lang.Boolean", "kotlin/Char" to "java.lang.Character", "kotlin/Short" to "java.lang.Short",
    "kotlin/Byte" to "java.lang.Byte", "kotlin/Number" to "java.lang.Number", "kotlin/CharSequence" to "java.lang.CharSequence",
    "kotlin/Comparable" to "java.lang.Comparable", "kotlin/Throwable" to "java.lang.Throwable", "kotlin/Enum" to "java.lang.Enum",
    "kotlin/collections/List" to "java.util.List", "kotlin/collections/MutableList" to "java.util.List",
    "kotlin/collections/Set" to "java.util.Set", "kotlin/collections/MutableSet" to "java.util.Set",
    "kotlin/collections/Map" to "java.util.Map", "kotlin/collections/MutableMap" to "java.util.Map",
    "kotlin/collections/Collection" to "java.util.Collection", "kotlin/collections/MutableCollection" to "java.util.Collection",
    "kotlin/collections/Iterable" to "java.lang.Iterable", "kotlin/collections/MutableIterable" to "java.lang.Iterable",
)

/**
 * `arr::class` and `arr.javaClass` of an array whose static type is known: arrays are lists at run time and do not know
 * their element type, so the class comes from the type, `__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")`
 * (`[Ljava.lang.String;`, `Array`, `String[]` for an `Array<String>`). Null for other types.
 */
internal fun FileTransformer.staticArrayClass(type: KaType?): LuaExpr? = with(session) {
    val id = type?.expandedSymbol?.classId?.asString() ?: return null
    if (id != "kotlin/Array" && id !in PRIMITIVE_ARRAYS) return null
    val (binary, javaSimple) = arrayNames(type) ?: return null
    val simple = id.substringAfter('/')
    val args = listOf(LuaString(binary), LuaString(simple), LuaString(javaSimple), LuaString(id.replace('/', '.')))
    return LuaCall(lualibRef("KClass", "__K2L_KClassOfArray"), args)
}

/** The JVM name and the Java simple name of an array type, or of an array's element type when it is not an array. */
private fun FileTransformer.arrayNames(type: KaType): Pair<String, String>? = with(session) {
    val id = type.expandedSymbol?.classId
    PRIMITIVE_ARRAYS[id?.asString()]?.let { (descriptor, java) -> return "[$descriptor" to "$java[]" }
    if (id?.asString() == "kotlin/Array") {
        val element = (type as? KaClassType)?.typeArguments?.firstOrNull()?.type?.let { reifiedType(it) }
        val elementId = element?.expandedSymbol?.classId?.asString()
        if (element != null && (elementId == "kotlin/Array" || elementId in PRIMITIVE_ARRAYS)) {
            val (binary, java) = arrayNames(element) ?: return null
            return "[$binary" to "$java[]"
        }
        val name = element?.let { elementClass(it) } ?: "java.lang.Object"
        return "[L$name;" to name.substringAfterLast('.').substringAfterLast('$') + "[]"
    }
    return null
}

private fun FileTransformer.elementClass(type: KaType): String? = with(session) {
    val symbol = type.expandedSymbol ?: return null
    val psi = symbol.psi as? KtClassOrObject
    if (psi != null && classes.isSource(psi)) return binaryName(psi)
    val id = symbol.classId ?: return null
    return ELEMENT_CLASSES[id.asString()] ?: (id.packageFqName.asString() + "." + id.relativeClassName.asString().replace('.', '$'))
}
