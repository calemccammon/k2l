package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * A class whose primary constructor only applies its [defaults] and stores its parameters ([init], the body of its
 * `____init`, is [defaults] and then `self.f = p` for the parameters [params] in order) gets
 * `function C.new(a, b) return setmetatable({a = a, b = b}, C) end`, with the defaults before the `return`, in place of the
 * generic vararg `new` of `__K2L_Class`, which creates the table and then calls `____init` (kept for subclasses, see
 * [isFinalClass]). Returns that function, or null when the class does not qualify. Only for classes whose instances store
 * fields plainly: no library class or interface among their ancestors (those can read and write some fields through
 * `__index`/`__newindex`, see Class.lua), not inner, local or an enum.
 */
internal fun FileTransformer.plainConstructor(
    c: KtClassOrObject,
    ref: LuaExpr,
    params: List<String>,
    defaults: List<LuaStmt>,
    init: List<LuaStmt>,
): LuaStmt? {
    if (c !is KtClass || !isPlainClass(c)) return null
    if (init.size != defaults.size + params.size || init.take(defaults.size) != defaults) return null
    if ("self" in freeNames(LuaFunction(params, defaults))) return null
    val fields = init.drop(defaults.size).mapIndexed { i, stmt ->
        val store = stmt as? LuaAssign ?: return null
        val target = store.targets.singleOrNull() as? LuaIndex ?: return null
        val key = (target.key as? LuaString)?.value ?: return null
        if (target.target != LuaName("self") || store.values.singleOrNull() != LuaName(params[i])) return null
        LuaField.Named(key, LuaName(params[i]))
    }
    val made = luaCall(LuaName("setmetatable"), LuaTable(fields), ref)
    return LuaFunctionDecl(LuaIndex(ref, LuaString("new")), LuaFunction(params, defaults + LuaReturn(listOf(made))), isLocal = false)
}

/** A class no subclass and no secondary constructor initializes through its `____init`. */
internal fun isFinalClass(c: KtClassOrObject): Boolean = c is KtClass && c.secondaryConstructors.isEmpty() &&
    listOf(KtTokens.OPEN_KEYWORD, KtTokens.ABSTRACT_KEYWORD, KtTokens.SEALED_KEYWORD).none { c.hasModifier(it) }

private fun FileTransformer.isPlainClass(c: KtClass) = !c.isEnum() && !c.isInner() && !c.isLocal && !hasLibraryAncestry(c)

/** Whether a library class or interface (lualib collections, exceptions, sequences, SAM mixins, delegations) is a supertype of [c]. */
private fun FileTransformer.hasLibraryAncestry(c: KtClassOrObject): Boolean {
    val info = classes.superInfo(c)
    val library =
        info.libraryBase != null || info.sequenceBase || info.elementBase || info.randomBase || info.sequenceMixin ||
            info.collectionBase != null || info.samMixins.isNotEmpty() || info.libraryDelegations.isNotEmpty() ||
            info.collectionMixin != null || info.unsupported != null
    return library || info.base?.let { hasLibraryAncestry(it) } == true || info.interfaces.any { hasLibraryAncestry(it) }
}
