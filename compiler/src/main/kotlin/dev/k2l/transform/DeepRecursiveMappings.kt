package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType

/**
 * `DeepRecursiveFunction(block)`, `f(value)` and `callRecursive`. The function is its own `DeepRecursiveScope`, so
 * `callRecursive(value)` in the block and `otherFunction.callRecursive(value)` are both a method call on their receiver.
 */
internal object DeepRecursiveMappings {
    private const val CLASS = "kotlin/DeepRecursiveFunction"

    fun construct(classId: String?, site: CallSite): LuaExpr? =
        if (classId == CLASS) site.libNew(DEEP_RECURSIVE, "__K2L_DeepRecursive", site.args) else null

    fun map(callableId: String?, site: CallSite): LuaExpr? = with(site) {
        when (callableId) {
            "kotlin/invoke" -> receiver?.takeIf { isDeepRecursive() }?.let { LuaMethodCall(it, "invoke", args) }
            "kotlin/DeepRecursiveScope.callRecursive" -> receiver?.let { LuaMethodCall(it, "callRecursive", args) }
            else -> null
        }
    }

    private fun CallSite.isDeepRecursive(): Boolean =
        receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } } == CLASS
}
