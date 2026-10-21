package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaBackingFieldSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassLikeSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaLocalVariableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

// Names as values: locals, parameters, properties, classes and objects.

/** The companion objects of the basic types, whose members are constants (see `isBasicCompanion`). */
private val BASIC_COMPANIONS =
    listOf("Int", "Long", "Short", "Byte", "Double", "Float", "Char", "String", "Boolean", "UInt", "ULong", "UShort", "UByte")
        .map { "kotlin/$it.Companion" }.toSet()

internal fun FileTransformer.reference(e: KtNameReferenceExpression, full: KtExpression = e): LuaExpr = with(session) {
    val symbol = e.mainReference.resolveToSymbol()
    val psi = symbol?.psi
    val bound = (symbol as? KaValueParameterSymbol)?.let { lambdaBinding(it, e) }
    return when {
        interop.isExternal(symbol) && symbol !is KaClassLikeSymbol -> call(e, full)

        bound != null -> bound

        isSourceDelegatedVariable(psi) -> delegatedVariableRead(psi as KtProperty)

        symbol is KaLocalVariableSymbol || symbol is KaValueParameterSymbol -> {
            val name = LuaName(naming.renamed(psi) ?: LuaNames.of(symbol.name.asString()))
            if (symbol is KaValueParameterSymbol || (symbol as KaLocalVariableSymbol).isVal) stable += name
            lateinitRead(psi, name)
        }

        isSourceAccessorProperty(symbol, psi) -> accessorPropertyRead(psi as KtProperty)

        isSourceTopLevelProperty(symbol, psi) -> lateinitRead(psi, topLevelRef(psi as KtProperty))

        symbol is KaBackingFieldSymbol -> backingField(e)

        symbol is KaEnumEntrySymbol && psi is KtEnumEntry && classes.isSource(psi) ->
            LuaIndex(classRef(psi.containingClassOrObject!!), LuaString(psi.name!!))

        symbol is KaClassLikeSymbol -> classValue(e, symbol, psi) ?: call(e, full)

        else -> call(e, full)
    }
}

/** A class or object named as a value; `Foo` is its companion, which is not the class table when it has one of its own. */
private fun FileTransformer.classValue(e: KtNameReferenceExpression, symbol: KaClassLikeSymbol, psi: PsiElement?): LuaExpr? =
    with(session) {
        val companion = (e.expressionType?.expandedSymbol?.psi as? KtObjectDeclaration)?.takeIf { hasOwnTable(it) && classes.isSource(it) }
        val target = companion ?: psi
        val value = classLikeReference(symbol, target) ?: return if (isBasicCompanion(e)) LuaNil else null
        return if (initializesOnUse(e, target)) lualibCall("TouchObject", value) else value
    }

/** `Long` in `Long.parse(s)`, a call of an extension of `Long.Companion`: the companions of the basic types only hold constants. */
private fun FileTransformer.isBasicCompanion(e: KtNameReferenceExpression): Boolean = with(session) {
    (e.expressionType?.withoutFlexibility as? KaClassType)?.classId?.asString() in BASIC_COMPANIONS
}

/** A class or object used as a value: an external Lua table, a library object or a source class. */
private fun FileTransformer.classLikeReference(symbol: KaClassLikeSymbol, psi: PsiElement?): LuaExpr? = with(session) {
    when {
        interop.isExternal(symbol) -> interop.externalClassRef(symbol as KaClassSymbol) ?: LuaName("_G")
        symbol.classId?.asString() in LIBRARY_OBJECTS -> libraryObject(symbol.classId!!.asString())
        psi is KtClassOrObject && classes.isSource(psi) -> classRef(psi)
        else -> null
    }
}

/** An object with observable initialization used as a value (not as the qualifier of a member): that initializes it. */
private fun FileTransformer.initializesOnUse(e: KtNameReferenceExpression, psi: PsiElement?): Boolean {
    // (a companion without a table of its own is its class's table, which is armed for the companion's initialization)
    if (psi !is KtObjectDeclaration || !lazyInit.isObservable(psi)) return false
    val parent = e.parent
    val qualified = if (parent is KtDotQualifiedExpression && parent.selectorExpression == e) parent else e
    val outer = qualified.parent
    return !(outer is KtDotQualifiedExpression && outer.receiverExpression == qualified)
}

private fun FileTransformer.isSourceTopLevelProperty(symbol: KaSymbol?, psi: PsiElement?) =
    symbol is KaPropertySymbol && psi is KtProperty && classes.isSource(psi) && psi.isTopLevel && psi.receiverTypeReference == null

/** A top-level property with custom accessors, read through `getX()`. */
private fun FileTransformer.isSourceAccessorProperty(symbol: KaSymbol?, psi: PsiElement?) =
    isSourceTopLevelProperty(symbol, psi) && (psi as KtProperty).hasAccessorFunctions()

/**
 * The value an inlined lambda's parameter was bound to, if any; for a lambda parameter of an inlined function passed on to
 * a function that is not expanded, the lambda as a closure.
 */
private fun FileTransformer.lambdaBinding(symbol: KaValueParameterSymbol, e: KtNameReferenceExpression): LuaExpr? = with(session) {
    if (lambdaBindings.isNotEmpty()) {
        symbol.containingDeclaration?.psi?.let {
            lambdaBindings[it to symbol.name.asString()]
        }?.let { return it }
    }
    return inlinedLambdaOf(e)?.let { inCallerContext(it) { lambda(it.expr) } }
}
