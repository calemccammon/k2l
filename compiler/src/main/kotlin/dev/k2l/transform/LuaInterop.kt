package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotated
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotationValue
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.analysis.api.symbols.markers.KaNamedSymbol
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Resolves declarations implemented in Lua (`@LuaExternal`, `external`) to the Lua values they live in. */
internal class LuaInterop(private val session: KaSession, private val ctx: TransformContext) {
    /** `@LuaExternal` or `external` on [decl] or an enclosing class (checked on PSI, for declarations being emitted). */
    fun isExternalDeclaration(decl: KtDeclaration): Boolean =
        generateSequence(decl) { it.containingClassOrObject }.any { d ->
            d.hasModifier(KtTokens.EXTERNAL_KEYWORD) || d.annotationEntries.any { it.shortName?.asString() == "LuaExternal" }
        }

    fun isExternal(symbol: KaSymbol?): Boolean = with(session) {
        if (symbol == null) return false
        if ((symbol as? KaAnnotated)?.annotations?.contains(LUA_EXTERNAL) == true) return true
        if (symbol is KaNamedFunctionSymbol && symbol.isExternal) return true
        val container = if (symbol is KaConstructorSymbol) symbol.containingClassId?.let { findClass(it) } else symbol.containingDeclaration
        return container is KaClassSymbol && isExternal(container)
    }

    fun annotationString(symbol: KaSymbol, id: ClassId): String? = with(session) {
        val annotation = (symbol as? KaAnnotated)?.annotations?.get(id)?.firstOrNull() ?: return null
        val value = annotation.arguments.firstOrNull()?.expression as? KaAnnotationValue.ConstantValue
        return value?.value?.value as? String
    }

    fun luaName(symbol: KaSymbol): String =
        annotationString(symbol, LUA_NAME) ?: (symbol as? KaNamedSymbol)?.name?.asString() ?: "_"

    /** A Lua module's table: `local ____socket = require("socket")`. */
    fun moduleRequire(path: String): LuaExpr =
        LuaName(ctx.imports.getOrPut(path) { ctx.temp(LuaNames.of(path.substringAfterLast('.'))) })

    /** `@file:LuaRequire("module")` of the file declaring [psi]. */
    fun fileRequire(psi: PsiElement?): String? {
        val ktFile = psi?.containingFile as? KtFile ?: return null
        val entry = ktFile.fileAnnotationList?.annotationEntries?.firstOrNull { it.shortName?.asString() == "LuaRequire" } ?: return null
        return (entry.valueArguments.firstOrNull()?.getArgumentExpression() as? KtStringTemplateExpression)
            ?.entries?.joinToString("") { it.text }
    }

    /** Where an external class or object lives; null for `_G`, whose members are plain globals. */
    fun externalClassRef(c: KaClassSymbol): LuaExpr? = with(session) {
        annotationString(c, LUA_REQUIRE)?.let { return moduleRequire(it) }
        val name = luaName(c)
        if (name == "_G") return null
        val outer = c.containingDeclaration as? KaClassSymbol
        if (outer != null && isExternal(outer)) return LuaIndex(externalClassRef(outer) ?: LuaName("_G"), LuaString(name))
        return fileRequire(c.psi)?.let { LuaIndex(moduleRequire(it), LuaString(name)) } ?: LuaName(name)
    }
}
