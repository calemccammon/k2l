package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.*

/**
 * A class whose primary constructor only stores its parameters ([init], the body of its `____init`, is `self.f = p` for the
 * parameters [params] in order) gets `function C.new(a, b) return setmetatable({a = a, b = b}, C) end` in place of the
 * generic vararg `new` of `__K2L_Class`, which creates the table and then calls `____init` (kept for subclasses). Only for
 * classes whose instances store fields plainly: no library class or interface among their ancestors (those can read and
 * write some fields through `__index`/`__newindex`, see Class.lua), not inner, local or an enum.
 */
internal fun FileTransformer.plainConstructor(c: KtClassOrObject, ref: LuaExpr, params: List<String>, init: List<LuaStmt>) {
    if (c !is KtClass || !isPlainClass(c) || init.size != params.size) return
    val fields = init.mapIndexed { i, stmt ->
        val store = stmt as? LuaAssign ?: return
        val target = store.targets.singleOrNull() as? LuaIndex ?: return
        val key = (target.key as? LuaString)?.value ?: return
        if (target.target != LuaName("self") || store.values.singleOrNull() != LuaName(params[i])) return
        LuaField.Named(key, LuaName(params[i]))
    }
    val made = luaCall(LuaName("setmetatable"), LuaTable(fields), ref)
    emit(LuaFunctionDecl(LuaIndex(ref, LuaString("new")), LuaFunction(params, listOf(LuaReturn(listOf(made)))), isLocal = false))
}

private fun FileTransformer.isPlainClass(c: KtClass) = !c.isEnum() && !c.isInner() && !c.isLocal && !hasLibraryAncestry(c)

/** Whether a library class or interface (lualib collections, exceptions, sequences, SAM mixins, delegations) is a supertype of [c]. */
private fun FileTransformer.hasLibraryAncestry(c: KtClassOrObject): Boolean {
    val info = classes.superInfo(c)
    val library = info.libraryBase != null || info.sequenceBase || info.elementBase || info.sequenceMixin || info.collectionBase != null ||
        info.samMixins.isNotEmpty() || info.libraryDelegations.isNotEmpty() || info.collectionMixin != null || info.unsupported != null
    return library || info.base?.let { hasLibraryAncestry(it) } == true || info.interfaces.any { hasLibraryAncestry(it) }
}
