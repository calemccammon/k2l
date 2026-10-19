package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.LuaTarget
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.psi.*

/**
 * The function that runs a `try` block: `pcall`, or on Lua 5.1 (which cannot yield across pcall)
 * `__K2L_CoPcall` when the block contains a suspension point, so the enclosing coroutine can still
 * suspend inside it.
 */
internal fun FileTransformer.protectedCall(e: KtTryExpression): LuaExpr {
    if (target != LuaTarget.Lua51) return LuaName("pcall")
    val protected = listOf(e.tryBlock) + e.catchClauses
    return if (protected.any { containsSuspensionPoint(it) }) lualibRef("CoPcall", "__K2L_CoPcall") else LuaName("pcall")
}

/** Whether [element] calls a suspend function (including `yield` in a sequence builder) anywhere inside it. */
internal fun FileTransformer.containsSuspensionPoint(element: KtElement): Boolean = with(session) {
    var found = false
    element.accept(object : KtTreeVisitorVoid() {
        override fun visitElement(element: PsiElement) {
            if (found) return
            if (element is KtCallExpression || element is KtOperationExpression || element is KtArrayAccessExpression) {
                found = isSuspendCall(element)
            }
            if (!found) super.visitElement(element)
        }
    })
    return found
}

/** Lua feature implementing `kotlin.coroutines` on Lua coroutines, see `Coroutines.lua`. */
internal const val COROUTINES_FEATURE = "Coroutines"

/** Lua feature implementing `kotlin.Result`, see `Result.lua`. */
internal const val RESULT_FEATURE = "Result"

/** Library objects used as values: `EmptyCoroutineContext`, `Result` (its companion) and `Unit`. */
internal val LIBRARY_OBJECTS = setOf(
    "kotlin/coroutines/EmptyCoroutineContext",
    "kotlin/Result",
    "kotlin/Result.Companion",
    "kotlin/Unit",
    "kotlin/coroutines/ContinuationInterceptor",
    "kotlin/coroutines/ContinuationInterceptor.Key",
)

/** The Lua value of one of the [LIBRARY_OBJECTS]. */
internal fun FileTransformer.libraryObject(classId: String): LuaExpr = when (classId) {
    "kotlin/coroutines/EmptyCoroutineContext" -> lualibRef(COROUTINES_FEATURE, "__K2L_EmptyCoroutineContext")

    "kotlin/Unit" -> LuaNil

    "kotlin/coroutines/ContinuationInterceptor", "kotlin/coroutines/ContinuationInterceptor.Key" ->
        lualibRef(COROUTINES_FEATURE, "__K2L_ContinuationInterceptor")

    else -> lualibRef(RESULT_FEATURE, "__K2L_Result")
}

/** The `kotlin.coroutines` intrinsics and `kotlin.Result`. */
internal object CoroutineMappings {
    /** Result members and extensions implemented as methods of the same name. */
    private val RESULT_METHODS = setOf(
        "isSuccess", "isFailure", "getOrNull", "exceptionOrNull", "getOrThrow", "getOrDefault", "getOrElse", "onSuccess",
        "onFailure", "fold", "map", "mapCatching", "recover", "recoverCatching",
    )

    fun map(callableId: String?, site: CallSite): LuaExpr? = coroutine(callableId, site) ?: result(callableId, site)

    private fun CallSite.call(feature: String, name: String, vararg args: LuaExpr): LuaExpr = LuaCall(ref(feature, name), args.toList())

    private fun CallSite.resultOf(kind: String, value: LuaExpr): LuaExpr =
        LuaCall(LuaIndex(ref(RESULT_FEATURE, "__K2L_Result"), LuaString(kind)), listOf(value))

    private val CONTEXT_OWNERS = setOf(
        "kotlin/coroutines/CoroutineContext",
        "kotlin/coroutines/CoroutineContext.Element",
        "kotlin/coroutines/EmptyCoroutineContext",
        "kotlin/coroutines/AbstractCoroutineContextElement",
    )

    /** `get`, `plus`, `minusKey`, `fold` and `key` of a context or one of its elements. */
    private fun context(callableId: String?, site: CallSite): LuaExpr? = with(site) {
        if (callableId == null || callableId.substringBeforeLast('.') !in CONTEXT_OWNERS) return null
        when (callableId.substringAfterLast('.')) {
            "get" -> call(COROUTINES_FEATURE, "__K2L_ContextGet", self, arg(0))
            "plus" -> call(COROUTINES_FEATURE, "__K2L_ContextPlus", self, arg(0))
            "minusKey" -> call(COROUTINES_FEATURE, "__K2L_ContextMinusKey", self, arg(0))
            "fold" -> call(COROUTINES_FEATURE, "__K2L_ContextFold", self, arg(0), arg(1))
            "key" -> LuaIndex(self, LuaString("key"))
            else -> null
        }
    }

    private fun coroutine(callableId: String?, site: CallSite): LuaExpr? = context(callableId, site) ?: with(site) {
        when (callableId) {
            // block.startCoroutine(completion) / block.startCoroutine(receiver, completion)
            "kotlin/coroutines/startCoroutine", "kotlin/coroutines/createCoroutine" -> {
                val name = if (callableId.endsWith("startCoroutine")) "__K2L_StartCoroutine" else "__K2L_CreateCoroutine"
                call(COROUTINES_FEATURE, name, self, args.last(), *args.dropLast(1).toTypedArray())
            }

            "kotlin/coroutines/suspendCoroutine" -> call(COROUTINES_FEATURE, "__K2L_SuspendCoroutine", arg(0))

            "kotlin/coroutines/intrinsics/suspendCoroutineUninterceptedOrReturn" ->
                call(COROUTINES_FEATURE, "__K2L_SuspendCoroutineUninterceptedOrReturn", arg(0))

            "kotlin/coroutines/intrinsics/COROUTINE_SUSPENDED" -> ref(COROUTINES_FEATURE, "__K2L_COROUTINE_SUSPENDED")

            "kotlin/coroutines/intrinsics/createCoroutineUnintercepted",
            "kotlin/coroutines/intrinsics/startCoroutineUninterceptedOrReturn",
            -> {
                val created = callableId.endsWith("createCoroutineUnintercepted")
                val name = if (created) "CreateCoroutineUnintercepted" else "StartCoroutineUninterceptedOrReturn"
                call(COROUTINES_FEATURE, "__K2L_$name", self, args.last(), *args.dropLast(1).toTypedArray())
            }

            "kotlin/coroutines/intrinsics/intercepted" -> call(COROUTINES_FEATURE, "__K2L_Intercepted", self)

            "kotlin/coroutines/Continuation" -> LuaCall(LuaIndex(ref(COROUTINES_FEATURE, "__K2L_Continuation"), LuaString("new")), args)

            "kotlin/coroutines/Continuation.resumeWith" -> LuaMethodCall(self, "resumeWith", args)

            "kotlin/coroutines/resume" -> LuaMethodCall(self, "resumeWith", listOf(resultOf("success", arg(0))))

            "kotlin/coroutines/resumeWithException" -> LuaMethodCall(self, "resumeWith", listOf(resultOf("failure", arg(0))))

            "kotlin/coroutines/Continuation.context" -> LuaIndex(self, LuaString("context"))

            "kotlin/coroutines/coroutineContext" -> call(COROUTINES_FEATURE, "__K2L_CoroutineContext")

            // suspend { } only gives a lambda its suspend type.
            "kotlin/suspend" -> arg(0)

            else -> null
        }
    }

    private fun result(callableId: String?, site: CallSite): LuaExpr? = with(site) {
        val receiverClass = receiverType?.let { with(session) { it.expandedSymbol?.classId?.asString() } }
        when {
            callableId == "kotlin/Result.Companion.success" -> resultOf("success", arg(0))

            callableId == "kotlin/Result.Companion.failure" -> resultOf("failure", arg(0))

            // runCatching { } and x.runCatching { }
            callableId == "kotlin/runCatching" -> call(
                RESULT_FEATURE,
                "__K2L_RunCatching",
                *(args + listOfNotNull(receiver)).toTypedArray(),
            )

            receiverClass == "kotlin/Result" && name in RESULT_METHODS -> LuaMethodCall(self, name!!, args)

            else -> null
        }
    }
}

private fun FileTransformer.isSuspendCall(e: KtExpression): Boolean = with(session) {
    val call = e.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return false
    val symbol = call.partiallyAppliedSymbol.symbol
    return (symbol as? KaNamedFunctionSymbol)?.isSuspend == true ||
        (call.partiallyAppliedSymbol.dispatchReceiver?.type as? KaFunctionType)?.isSuspend == true
}
