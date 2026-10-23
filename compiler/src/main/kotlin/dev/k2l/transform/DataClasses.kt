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
 * `__K2L_DataClass(P, {"x", "y"})`: the runtime gives the class the `toString`, `equals` and `hashCode` of a data class over
 * its primary-constructor properties, where the class does not declare them (see `DataClass.lua`). Calls of `copy` and
 * `componentN` read the fields where they are made; a `componentN` that overrides one of a supertype is also a method.
 */
internal fun FileTransformer.dataClassMembers(c: KtClass, ref: LuaExpr) {
    val props = c.primaryConstructorParameters.filter { it.hasValOrVar() }
    // a property whose value is kept under another key (an override of an interface property, say) is `{name, key}`
    val fields = LuaTable(
        props.map { p ->
            val key = fieldKey(p)
            val field = if (key == p.name) LuaString(key) else LuaTable(listOf(p.name!!, key).map { LuaField.Positional(LuaString(it)) })
            LuaField.Positional(field)
        },
    )
    // toString() prints the simple name, the end of the class's Lua name unless the name itself has a `.` or `$`
    val name = c.name.orEmpty()
    val printed = LuaString(name).takeIf { className(c).substringAfterLast('.').substringAfterLast('$') != name }
    emit(LuaCallStmt(lualibCall("DataClass", *listOfNotNull(ref, fields, printed).toTypedArray())))
    props.forEachIndexed { i, p ->
        val component = "component${i + 1}"
        val overrides = classes.hierarchy(c).any { k -> k != c && k.declarations.any { it is KtNamedFunction && it.name == component } }
        if (c.isData() && overrides) emitMethod(ref, component, emptyList(), listOf(LuaReturn(listOf(propertyRead(selfRef(), p)))))
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

/**
 * `p.copy(y = 2)` is `P.new(p.x, 2)`. The arguments run as written, and before the omitted properties are read when a
 * `var` among those could change.
 */
private fun FileTransformer.dataClassCopy(call: KaCallableMemberCall<*, *>, cls: KtClass, receiver: LuaExpr): LuaExpr = with(session) {
    val source = cache(receiver, "source")
    val params = cls.primaryConstructorParameters
    val mapping = (call as KaFunctionCall<*>).valueArgumentMapping.entries
        .map { it.value.symbol.name.asString() to it.key }.sortedBy { (name, _) -> params.indexOfFirst { it.name == name } }
    val names = mapping.map { it.first }
    val readsVar = params.any { it.name !in names && it.isMutable }
    val values = orderedAsWritten(mapping.map { it.second }).map {
        if (readsVar && !isStable(it) && it !is LuaFunction) cache(it, "arg") else it
    }
    val provided = names.zip(values).toMap()
    val nullable = mapping.filter { it.second.expressionType?.isMarkedNullable == true }.map { it.first }.toSet()
    val args = params.map { p ->
        val value = provided[p.name] ?: return@map propertyRead(source, p)
        // a null for a constructor parameter whose default is not null (see nullArgument)
        if (p.name in nullable && p.hasDefaultValue() && !isNullDefault(p.defaultValue)) nullArgument(value) else value
    }
    return LuaCall(LuaIndex(classRef(cls), LuaString("new")), args)
}
