package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.*

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
        val hash = props.map { p -> lualibCall("Hash", LuaIndex(selfRef(), LuaString(p.name!!))) }
            .reduceOrNull { acc, h -> lualibCall("ToInt32", LuaBinary(LuaBinOp.Add, LuaBinary(LuaBinOp.Mul, LuaNumber("31"), acc), h)) }
            ?: LuaNumber("0")
        emitMethod(ref, "hashCode", emptyList(), listOf(LuaReturn(listOf(hash))))
    }
    if (c.declaredFunction("equals") == null) {
        val other = LuaName("other")
        val checks = listOf<LuaExpr>(LuaBinary(LuaBinOp.Eq, luaCall(LuaName("getmetatable"), other), ref)) +
            props.map { p ->
                val key = LuaString(p.name!!)
                equality(LuaIndex(selfRef(), key), p.returnType, LuaIndex(other, key), p.returnType, negated = false)
            }
        emitMethod(ref, "equals", listOf("other"), listOf(LuaReturn(listOf(checks.reduce { a, b -> LuaBinary(LuaBinOp.And, a, b) }))))
    }
}

/** Generated members of data classes declared in this file: copy, componentN, toString, equals. */
internal fun FileTransformer.dataClassMember(call: KaCallableMemberCall<*, *>, receiverExpr: KtExpression?, implicit: LuaExpr?): LuaExpr? =
    with(session) {
        val symbol = call.partiallyAppliedSymbol.symbol
        val name = symbol.callableId?.callableName?.asString() ?: return null
        val cls = symbol.callableId?.classId?.let(classes::classInFile) as? KtClass ?: return null
        if (!cls.isData() || symbol.psi is KtNamedFunction) return null // user-declared members are ordinary methods
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
