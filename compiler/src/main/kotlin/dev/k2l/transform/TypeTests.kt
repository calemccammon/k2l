package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolModality
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.*

/**
 * Whether [type] is a final class of the program (not open, abstract, sealed, an interface, an enum or an object): its
 * instances are exactly the tables whose metatable is the class table, so `is` needs no walk up the hierarchy.
 */
private fun FileTransformer.isFinalSourceClass(type: KaType): Boolean = with(session) {
    val symbol = type.expandedSymbol as? KaNamedClassSymbol ?: return false
    val psi = symbol.psi as? KtClass ?: return false
    return symbol.classKind == KaClassKind.CLASS && symbol.modality == KaSymbolModality.FINAL && classes.isSource(psi)
}

/** `value is C` for a final class `C`: `getmetatable(value) == C`, with the subject's metatable read once per `when`. */
private fun FileTransformer.finalClassTest(value: LuaExpr, cls: LuaExpr): LuaExpr =
    LuaBinary(LuaBinOp.Eq, subjectMetatables[value] ?: luaCall(LuaName("getmetatable"), value), cls)

/**
 * Before a `when (subject)` with several `is` branches against final classes: `local ____mt = getmetatable(subject)`, used
 * by [finalClassTest] for those branches (the caller removes it after the `when`).
 */
internal fun FileTransformer.hoistSubjectMetatable(e: KtWhenExpression, subject: LuaExpr?): Unit = with(session) {
    if (subject == null || !isStable(subject)) return
    val finalTests = e.entries.sumOf { entry ->
        entry.conditions.count { c ->
            c is KtWhenConditionIsPattern &&
                c.typeReference?.type?.let { !it.isMarkedNullable && isFinalSourceClass(reifiedType(it)) } == true
        }
    }
    if (finalTests < 2) return
    val name = ctx.temp("mt")
    emit(LuaLocal(listOf(name), listOf(luaCall(LuaName("getmetatable"), subject))))
    subjectMetatables[subject] = LuaName(name).also { stable += it }
}

context(s: KaSession)
private fun KaType.isPrimitiveLike() = with(s) {
    isStringType || isCharType || isBooleanType || isIntegral || isDoubleType ||
        isFloatType
}

/** Whether [typeTest] can test [declaredType] (type parameters and unmapped library types cannot be told at run time). */
internal fun FileTransformer.isTestable(declaredType: KaType): Boolean = with(session) {
    val type = reifiedType(declaredType)
    if (type.isPrimitiveLike()) return true
    val symbol = type.expandedSymbol ?: return false
    val psi = symbol.psi as? KtClassOrObject
    return symbol.classId?.asString() in setOf("kotlin/Any", "kotlin/Unit") ||
        type.collectionKind()?.let(LIBRARY_COLLECTION_CLASSES::get) != null ||
        symbol.classId?.asString() in LIBRARY_CLASSES || symbol.classId?.asString() in SAM_MIXINS ||
        symbol.classId?.asString() in TYPE_CHECKS ||
        (psi != null && classes.isSource(psi))
}

/** `value is declaredType`; a nullable type (`is String?`, `is T` with `T` reified as `Int?`) also holds for null. */
internal fun FileTransformer.typeTest(value: LuaExpr, declaredType: KaType, element: KtElement): LuaExpr = with(session) {
    val type = reifiedType(declaredType)
    if (!type.isMarkedNullable) return nonNullTypeTest(value, type, element)
    val v = cache(value, "value")
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.Eq, v, LuaNil), nonNullTypeTest(v, type.withNullability(false), element))
}

private fun FileTransformer.nonNullTypeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr = with(session) {
    val luaType = when {
        type.isStringType || type.isCharType -> "string"

        type.isBooleanType -> "boolean"

        emulatesLong && type.isLongType -> return l64Member("isLong", value)

        type.isIntegral || type.isDoubleType || type.isFloatType -> {
            val wantInteger = type.isIntegral
            if (target.hasIntegers) {
                return LuaBinary(
                    LuaBinOp.Eq,
                    lua("math.type", value),
                    LuaString(if (wantInteger) "integer" else "float"),
                )
            }
            // Without an integer subtype, an Int is an integral number (so 2.0 is Int and Double).
            val isNumber = LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString("number"))
            return if (wantInteger) {
                LuaBinary(
                    LuaBinOp.And,
                    isNumber,
                    LuaBinary(LuaBinOp.Eq, LuaBinary(LuaBinOp.Mod, value, LuaNumber("1")), LuaNumber("0")),
                )
            } else {
                isNumber
            }
        }

        else -> return classTest(value, type, element)
    }
    return LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString(luaType))
}

/** `is` against a class or interface: of the program, a library collection or a library exception. */
private fun FileTransformer.classTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr = with(session) {
    val symbol = type.expandedSymbol
    val id = symbol?.classId?.asString()
    val psi = (symbol?.psi as? KtClassOrObject)?.takeIf { classes.isSource(it) }
    val collection = SPECIFIC_COLLECTION_CLASSES[id] ?: type.collectionKind()?.let(LIBRARY_COLLECTION_CLASSES::get)
    return when {
        id == "kotlin/Any" -> LuaBinary(LuaBinOp.Ne, value, LuaNil)

        id == "kotlin/Unit" -> LuaBinary(LuaBinOp.Eq, value, unitObject())

        // Lua numbers, emulated Longs and BigInteger/BigDecimal
        psi is KtObjectDeclaration -> LuaBinary(LuaBinOp.Eq, value, classRef(psi))

        psi != null && isFinalSourceClass(type) -> finalClassTest(value, classRef(psi))

        psi != null -> lualibCall("InstanceOf", value, classRef(psi))

        type.collectionKind() == CollectionKind.Array -> arrayTypeTest(value, type)

        collection != null -> {
            val test = lualibCall("InstanceOf", value, lualibRef(featureOf(collection), collection))
            // an Iterable that is not a Collection (a class implementing Iterable, a range) has no size
            val sized = if (id in COLLECTION_INTERFACES) {
                LuaBinary(LuaBinOp.And, test, LuaBinary(LuaBinOp.Ne, LuaIndex(value, LuaString("size")), LuaNil))
            } else {
                test
            }
            // Kotlin's read-only collections (emptyList(), a class implementing List) are not mutable ones, as on the JVM
            if (id in MUTABLE_INTERFACES) LuaBinary(LuaBinOp.And, sized, negate(LuaIndex(value, LuaString("____readOnly")))) else sized
        }

        id in LIBRARY_CLASSES -> lualibCall("InstanceOf", value, lualibRef(EXCEPTIONS_FEATURE, LIBRARY_CLASSES.getValue(id!!)))

        // a lambda, or an object of a class implementing the interface
        id in SAM_MIXINS -> LuaBinary(
            LuaBinOp.Or,
            LuaBinary(LuaBinOp.Eq, luaCall(LuaName("type"), value), LuaString("function")),
            lualibCall("InstanceOf", value, lualibRef(SAM_FEATURE, SAM_MIXINS.getValue(id!!))),
        )

        id in TYPE_CHECKS -> {
            val test = LuaCall(lualibRef("TypeChecks", TYPE_CHECKS.getValue(id!!)), listOf(value))
            if (id == "kotlin/Number" && emulatesLong) LuaBinary(LuaBinOp.Or, test, l64Member("isLong", value)) else test
        }

        else -> unsupported(element, "Type check against '${type.pretty()}'")
    }
}
