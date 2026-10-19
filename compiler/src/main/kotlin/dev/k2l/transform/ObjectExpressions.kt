package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/**
 * `object : I { ... }`: a local object declared where the expression is evaluated, like a named `object` (its table is the
 * instance) but initialized right away and created anew each time. Its methods are closures, so they see (and can assign)
 * the locals around it.
 */
internal fun FileTransformer.objectExpression(e: KtObjectLiteralExpression): LuaExpr {
    val decl = e.objectDeclaration
    val name = ctx.temp("object")
    naming.renames[decl] = name
    classDeclaration(decl, isLocal = true)
    return LuaName(name).also { stable += it }
}

/** The declaration of the object expression [psi] is (or declares), if it is one. */
internal fun objectLiteralOf(psi: PsiElement?): KtObjectDeclaration? = when (psi) {
    is KtObjectLiteralExpression -> psi.objectDeclaration
    is KtObjectDeclaration -> psi.takeIf { it.isObjectLiteral() }
    else -> null
}

/**
 * A local class or object expression declared inside a class's members keeps the enclosing instances in locals, since its
 * own methods rebind `self`: `local ____this = self`.
 */
internal fun FileTransformer.captureOuters(c: KtClassOrObject) {
    if (currentClass == null) return
    lexicalOuters[c] = enclosingInstances().map { (cls, value) ->
        val name = ctx.temp("this")
        emit(LuaLocal(listOf(name), listOf(value)))
        cls to LuaName(name).also { stable += it }
    }
}
