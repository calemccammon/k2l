package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * Whether [this] gets a data class's generated `toString`/`equals`/`hashCode`: a data class, or a value class, which is a
 * table holding its one property in Lua (equal when the values are, printed as `Name(value=...)`).
 */
internal fun KtClass.hasDataMembers(): Boolean = isData() || hasModifier(KtTokens.VALUE_KEYWORD) || hasModifier(KtTokens.INLINE_KEYWORD)

/**
 * `field.hashCode()`: an `Int` (`Short`, `Byte`) is its own hash and a `Boolean` 1231 or 1237; a `Double` that holds an
 * integral value hashes like the JVM's Double where numbers are doubles too.
 */
private fun FileTransformer.fieldHash(p: KtParameter, value: LuaExpr): LuaExpr = with(session) {
    val type = p.returnType.withoutFlexibility
    when {
        type.isMarkedNullable -> lualibCall("Hash", value)

        type.isIntType || type.isShortType || type.isByteType -> value

        type.isBooleanType -> LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, value, LuaNumber("1231")), LuaNumber("1237"))

        type.isDoubleType && !target.hasIntegers -> LuaCall(lualibRef("Hash", "__K2L_DoubleHash"), listOf(value))

        // a data class of the program (final) has its own hashCode
        (type.expandedSymbol?.psi as? KtClass)?.let {
            it.isData() && classes.isSource(it)
        } == true -> LuaMethodCall(value, "hashCode", emptyList())

        else -> lualibCall("Hash", value)
    }
}

/**
 * `result = 31 * result + h` over the field hashes, wrapped to 32 bits: once at the end where integers wrap modulo 2^64
 * (5.3/5.4), else at each step (doubles are exact only below 2^53).
 */
private fun FileTransformer.combinedHash(hashes: List<LuaExpr>): LuaExpr {
    if (hashes.isEmpty()) return LuaNumber("0")
    val step = { acc: LuaExpr, h: LuaExpr -> LuaBinary(LuaBinOp.Add, LuaBinary(LuaBinOp.Mul, LuaNumber("31"), acc), h) }
    if (target.hasIntegers) return if (hashes.size == 1) hashes[0] else wrapInt32(hashes.reduce(step))
    return hashes.reduce { acc, h -> lualibCall("ToInt32", step(acc, h)) }
}

internal fun FileTransformer.dataClassMembers(c: KtClass, ref: LuaExpr): Unit = with(session) {
    val props = c.primaryConstructorParameters.filter { it.hasValOrVar() }
    if (c.declaredFunction("toString") == null) {
        val parts = mutableListOf<LuaExpr>()
        props.forEachIndexed { i, p ->
            parts += LuaString((if (i == 0) "${c.name}(" else ", ") + "${p.name}=")
            parts += str(LuaIndex(selfRef(), LuaString(p.name!!)), p.returnType, forConcat = true)
        }
        parts += LuaString(if (props.isEmpty()) "${c.name}()" else ")")
        val merged = parts.fold(mutableListOf<LuaExpr>()) { acc, part ->
            val last = acc.lastOrNull()
            if (last is LuaString && part is LuaString) acc[acc.lastIndex] = LuaString(last.value + part.value) else acc += part
            acc
        }
        emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(merged.reduceRight { a, b -> LuaBinary(LuaBinOp.Concat, a, b) }))))
    }
    if (c.declaredFunction("hashCode") == null) {
        // result = 31 * result + field.hashCode(), as the Kotlin compiler generates.
        val hash = combinedHash(props.map { p -> fieldHash(p, LuaIndex(selfRef(), LuaString(p.name!!))) })
        emitMethod(ref, "hashCode", emptyList(), listOf(LuaReturn(listOf(hash))))
    }
    if (c.declaredFunction("equals") == null) {
        val other = LuaName("other")
        val checks = listOf<LuaExpr>(LuaBinary(LuaBinOp.Eq, luaCall(LuaName("getmetatable"), other), ref)) +
            props.map { p ->
                val key = LuaString(p.name!!)
                val (mine, theirs) = LuaIndex(selfRef(), key) to LuaIndex(other, key)
                // a Double (Float) property compares with Double.compare (NaN equals NaN, 0.0 and -0.0 differ), not IEEE `==`
                if (with(session) { isFloating(p.returnType) }) {
                    LuaCall(lualibRef("Equals", "__K2L_DoubleEquals"), listOf(mine, theirs))
                } else {
                    equality(mine, p.returnType, theirs, p.returnType, negated = false)
                }
            }
        emitMethod(ref, "equals", listOf("other"), listOf(LuaReturn(listOf(checks.reduce { a, b -> LuaBinary(LuaBinOp.And, a, b) }))))
    }
}

/** `data object`: `toString()` is the object's name and `hashCode()` the hash of its qualified name, as the Kotlin compiler generates. */
internal fun FileTransformer.dataObjectMembers(c: KtObjectDeclaration, ref: LuaExpr) {
    val name = c.name ?: return
    if (c.declaredFunction("toString") == null) emitMethod(ref, "toString", emptyList(), listOf(LuaReturn(listOf(LuaString(name)))))
    if (c.declaredFunction("hashCode") == null) {
        // the hash of the qualified name, a constant the Kotlin compiler computes
        val hash = c.fqName?.asString().orEmpty().fold(0) { h, ch -> 31 * h + ch.code }
        emitMethod(ref, "hashCode", emptyList(), listOf(LuaReturn(listOf(LuaNumber(hash.toString())))))
    }
}

/** Generated members of data classes declared in this file: copy, componentN, toString, equals. */
internal fun FileTransformer.dataClassMember(call: KaCallableMemberCall<*, *>, receiverExpr: KtExpression?, implicit: LuaExpr?): LuaExpr? =
    with(session) {
        val symbol = call.partiallyAppliedSymbol.symbol
        val name = symbol.callableId?.callableName?.asString() ?: return null
        val declaration = symbol.callableId?.classId?.let(classes::classInFile)
        if (declaration is KtObjectDeclaration) return dataObjectMember(call, declaration, name, receiverExpr, implicit)
        val cls = declaration as? KtClass ?: return null
        if (!cls.hasDataMembers() || symbol.psi is KtNamedFunction) return null // user-declared members are ordinary methods
        if (!isGeneratedDataMember(name)) return null
        val props = cls.primaryConstructorParameters
        val receiver = implicit ?: expression(receiverExpr ?: return null)
        if (name == "toString" || name == "equals" || name == "hashCode") {
            val args = (call as KaFunctionCall<*>).valueArgumentMapping.keys.toList()
            return LuaMethodCall(receiver, name, ordered(args))
        }
        if (name != "copy") return propertyRead(receiver, props[name.removePrefix("component").toInt() - 1])
        return dataClassCopy(call, cls, receiver)
    }

/** `toString()` and `hashCode()` of a `data object` are its generated methods; its `equals` is identity, as there is one instance. */
private fun FileTransformer.dataObjectMember(
    call: KaCallableMemberCall<*, *>,
    obj: KtObjectDeclaration,
    name: String,
    receiverExpr: KtExpression?,
    implicit: LuaExpr?,
): LuaExpr? = with(session) {
    if (!obj.hasModifier(KtTokens.DATA_KEYWORD) || call.partiallyAppliedSymbol.symbol.psi is KtNamedFunction) return null
    if (name != "toString" && name != "hashCode" && name != "equals") return null
    val receiver = implicit ?: expression(receiverExpr ?: return null)
    val args = ordered((call as KaFunctionCall<*>).valueArgumentMapping.keys.toList())
    if (name == "equals") LuaBinary(LuaBinOp.Eq, receiver, args.single()) else LuaMethodCall(receiver, name, emptyList())
}

private fun isGeneratedDataMember(name: String) = name in DATA_MEMBER_NAMES || name.matches(COMPONENT_N)

private val DATA_MEMBER_NAMES = setOf("copy", "toString", "equals", "hashCode")
private val COMPONENT_N = Regex("component[0-9]+")

private fun FileTransformer.dataClassCopy(call: KaCallableMemberCall<*, *>, cls: KtClass, receiver: LuaExpr): LuaExpr = with(session) {
    val source = cache(receiver, "source")
    val mapping = (call as KaFunctionCall<*>).valueArgumentMapping.entries.toList()
    val provided = mapping.map { it.value.symbol.name.asString() }.zip(ordered(mapping.map { it.key })).toMap()
    val args = cls.primaryConstructorParameters.map { p -> provided[p.name] ?: propertyRead(source, p) }
    return LuaCall(LuaIndex(classRef(cls), LuaString("new")), args)
}
