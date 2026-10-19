package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.containingClassOrObject

/** Field (and constructor parameter) holding the enclosing instance of an inner class. */
internal const val OUTER = "____outer"

internal fun isInner(c: KtClassOrObject?) = c is KtClass && c.isInner()

/**
 * The instances the code being transformed can call members on, innermost first, with their Lua values:
 * `self`, then for inner classes the chain of enclosing instances (`self.____outer`, `self.____outer.____outer`, ...), and for
 * local classes and object expressions the instances around their declaration.
 * An enum entry's body shares `self` with its enum class.
 */
internal fun FileTransformer.enclosingInstances(): List<Pair<KtClassOrObject, LuaExpr>> {
    val result = mutableListOf<Pair<KtClassOrObject, LuaExpr>>()
    var cls = currentClass
    var value: LuaExpr = selfRef()
    while (cls != null) {
        result += cls to value
        if (cls is KtEnumEntry) cls.containingClassOrObject?.let { result += it to value }
        if (!isInner(cls)) {
            lexicalOuters[cls]?.let(result::addAll)
            break
        }
        cls = cls.containingClassOrObject
        value = LuaIndex(value, LuaString(OUTER)).also { stable += it }
    }
    return result
}

/** The instance of the class enclosing the inner class [inner] that its superclass constructor receives as outer. */
internal fun FileTransformer.enclosingInstanceFor(inner: KtClassOrObject, at: KtElement): LuaExpr {
    val wanted = inner.containingClassOrObject
    val found = enclosingInstances().drop(1).firstOrNull { (cls, _) -> wanted != null && wanted in classes.hierarchy(cls) }
    if (found == null) unsupported(at, "Inner class constructor call without an enclosing instance")
    return found?.second ?: LuaNil
}

/** Constructor parameters that come before the declared ones: `name, ordinal` for enums, the outer instance for inner classes. */
internal fun leadingConstructorParams(c: KtClassOrObject): List<String> = when {
    c is KtClass && c.isEnum() -> listOf("name", "ordinal")
    isInner(c) -> listOf(OUTER)
    else -> emptyList()
}

/** The first statement of an inner class's constructors: remember the enclosing instance. */
internal fun FileTransformer.storeOuter(c: KtClassOrObject) {
    if (isInner(c)) emit(assign(LuaIndex(selfRef(), LuaString(OUTER)), LuaName(OUTER)))
}
