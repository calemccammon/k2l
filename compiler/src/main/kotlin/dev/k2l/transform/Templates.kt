package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaAnonymousFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*

// String templates and the text of a value (str), as Kotlin's toString() writes it.

internal fun FileTransformer.template(e: KtStringTemplateExpression): LuaExpr = with(session) {
    val parts = mutableListOf<LuaExpr>()
    var lone: Pair<KtExpression, LuaExpr>? = null
    val pending = StringBuilder()
    fun flush() {
        if (pending.isNotEmpty()) parts += LuaString(pending.toString())
        pending.clear()
    }
    // A later entry that needs statements (an expanded inline call) must not run before the earlier entries.
    val exprs = e.entries.mapNotNull { (it as? KtStringTemplateEntryWithExpression)?.expression }
    val texts = if (exprs.size > 1) orderedTexts(exprs) else null
    val values = (texts ?: ordered(exprs, unlessReads = true)).iterator()
    for (entry in e.entries) {
        when (entry) {
            is KtLiteralStringTemplateEntry -> pending.append(entry.text)

            is KtEscapeStringTemplateEntry -> pending.append(entry.unescapedValue)

            is KtStringTemplateEntryWithExpression -> {
                val expr = entry.expression ?: continue
                flush()
                val value = values.next()
                lone = expr to value
                parts += if (texts != null) value else str(value, templateType(expr), forConcat = true)
            }
        }
    }
    flush()
    return templateParts(parts, lone)
}

/**
 * The text of each template entry, ordered like [ordered]; each entry is turned into text in order, so a later entry that
 * is computed first (`"$list ${list.removeLastOrNull()?.x}"`) can't change what an earlier object prints.
 */
private fun FileTransformer.orderedTexts(exprs: List<KtExpression>): List<LuaExpr> = with(session) {
    val results = exprs.map { expr -> withPreceding { str(expression(expr), templateType(expr), forConcat = true) } }
    val last = results.indexOfLast { (_, pre) -> pre.any { !isLocalRead(it) } }
    return results.mapIndexed { i, (text, pre) ->
        emitAll(pre)
        if (i < last) cache(text, "arg") else text
    }
}

/**
 * The type a template prints [expr] by. A platform type may be null, except for a parameter of a lambda converted to a Java
 * interface (`Comparator { a, b -> }`), which the library calls with its own elements.
 */
private fun FileTransformer.templateType(expr: KtExpression): KaType? = with(session) {
    val type = expr.expressionType
    if (type !is KaFlexibleType) return type
    val symbol = (KtPsiUtil.safeDeparenthesize(expr) as? KtNameReferenceExpression)?.mainReference?.resolveToSymbol()
    val lambdaParameter = symbol is KaValueParameterSymbol && symbol.containingDeclaration is KaAnonymousFunctionSymbol
    return if (lambdaParameter) type.lowerBound else type
}

private fun FileTransformer.templateParts(parts: List<LuaExpr>, lone: Pair<KtExpression, LuaExpr>?): LuaExpr = with(session) {
    when (parts.size) {
        0 -> LuaString("")

        // "$x" on its own still has to produce a string.
        1 -> lone?.let { (expr, value) -> str(value, expr.expressionType) } ?: parts[0]

        else -> parts.reduceRight { part, acc -> LuaBinary(LuaBinOp.Concat, part, acc) }
    }
}

/**
 * Converts [value] to a string the way `toString()` does: numbers and booleans as Lua's `tostring` writes them, other values
 * by `__K2L_Str`. With [forConcat], numbers are left alone, as Lua's `..` writes them the same way.
 */
internal fun FileTransformer.str(value: LuaExpr, type: KaType?, forConcat: Boolean = false): LuaExpr = with(session) {
    val t = type?.takeUnless { it.isMarkedNullable || isPlatformNullable(it) } ?: return lualibCall("Str", value)
    return when {
        t.isStringType || t.isCharType -> value
        t.isUnitType && (value is LuaName || value is LuaNil) -> LuaString("kotlin.Unit")
        t.isNumber -> if (forConcat) value else luaCall(LuaName("tostring"), value)
        t.isBooleanType -> luaCall(LuaName("tostring"), value)
        else -> lualibCall("Str", value)
    }
}

/** A platform type from a Java method (a value of a `sortedMapOf` map is `Int!`) may be null; Java strings are taken as non-null. */
private fun FileTransformer.isPlatformNullable(type: KaType): Boolean = with(session) {
    type is KaFlexibleType && type.upperBound.isMarkedNullable && !type.lowerBound.isStringType
}
