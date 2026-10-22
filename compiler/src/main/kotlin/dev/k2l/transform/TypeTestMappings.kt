package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull

/** Library functions that test elements against a type argument, such as `filterIsInstance<T>()`. */
internal object TypeTestMappings {
    private val FILTER_IS_INSTANCE = setOf("kotlin/collections/filterIsInstance", "kotlin/sequences/filterIsInstance")
    private val FILTER_IS_INSTANCE_TO = setOf("kotlin/collections/filterIsInstanceTo", "kotlin/sequences/filterIsInstanceTo")

    fun map(callableId: String?, site: CallSite): LuaExpr? = when {
        callableId in FILTER_IS_INSTANCE && site.args.isEmpty() -> filterIsInstance(site, null)
        callableId in FILTER_IS_INSTANCE_TO && site.args.size == 1 -> filterIsInstance(site, site.arg(0))
        else -> null
    }

    /** `xs.filterIsInstance<T>()` keeps the elements for which `is T` holds; `filterIsInstanceTo(destination)` adds them to it. */
    private fun filterIsInstance(site: CallSite, destination: LuaExpr?): LuaExpr? = with(site.session) {
        val call = site.element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
        val type = call.typeArgumentsMapping.values.firstOrNull() ?: return null
        val element = LuaName("x")
        val test = with(site.transformer) { typeTest(element, type, site.element) }
        val predicate = LuaFunction(listOf("x"), listOf(LuaReturn(listOf(test))))
        if (destination == null) {
            LuaMethodCall(site.self, "filter", listOf(predicate))
        } else {
            LuaMethodCall(site.self, "filterTo", listOf(destination, predicate))
        }
    }
}
