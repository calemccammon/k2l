package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull

/** Library functions that test elements against a type argument, such as `filterIsInstance<T>()`. */
internal object TypeTestMappings {
    private val FILTER_IS_INSTANCE = setOf("kotlin/collections/filterIsInstance", "kotlin/sequences/filterIsInstance")

    fun map(callableId: String?, site: CallSite): LuaExpr? =
        if (callableId in FILTER_IS_INSTANCE && site.args.isEmpty()) filterIsInstance(site) else null

    /** `xs.filterIsInstance<T>()` keeps the elements for which `is T` holds. */
    private fun filterIsInstance(site: CallSite): LuaExpr? = with(site.session) {
        val call = site.element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val type = call.typeArgumentsMapping.values.firstOrNull() ?: return null
        val element = LuaName("x")
        val test = with(site.transformer) { typeTest(element, type, site.element) }
        LuaMethodCall(site.self, "filter", listOf(LuaFunction(listOf("x"), listOf(LuaReturn(listOf(test))))))
    }
}
