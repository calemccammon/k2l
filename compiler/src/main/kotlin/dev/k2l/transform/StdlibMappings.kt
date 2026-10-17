package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtExpression

/** A call to a Kotlin library function or property, with operands already transformed. */
class CallSite(
    val session: KaSession,
    val transformer: FileTransformer,
    val element: KtExpression,
    /** Simple name of the callee, e.g. `toString`. */
    val name: String?,
    val receiver: LuaExpr?,
    val receiverType: KaType?,
    val args: List<LuaExpr>,
    val argTypes: List<KaType?>,
) {
    val self: LuaExpr get() = receiver ?: error("call has no receiver")
    fun arg(i: Int) = args[i]
    fun str(value: LuaExpr, type: KaType?, forConcat: Boolean = false) =
        with(transformer) { session.str(value, type, forConcat) }
    fun lualib(feature: String, vararg args: LuaExpr) = transformer.lualibCall(feature, *args)
    fun unsupported(what: String) = transformer.unsupported(element, what)
}

/**
 * Maps Kotlin stdlib callables (by `CallableId`, e.g. `kotlin/io/println` or `kotlin/String.length`)
 * to Lua. A mapping returns null when it doesn't handle that overload.
 */
object StdlibMappings {
    private val mappings = mutableMapOf<String, CallSite.() -> LuaExpr?>()

    private fun def(vararg ids: String, mapping: CallSite.() -> LuaExpr?) = ids.forEach { mappings[it] = mapping }

    private fun method(target: LuaExpr, name: String, vararg args: LuaExpr) = LuaMethodCall(target, name, args.toList())
    private fun lua(path: String, vararg args: LuaExpr): LuaExpr {
        val parts = path.split('.')
        return LuaCall(luaPath(parts[0], *parts.drop(1).toTypedArray()), args.toList())
    }

    private val INTEGRAL = listOf("Int", "Long", "Short", "Byte")
    private val FLOATING = listOf("Double", "Float")

    init {
        // kotlin.io
        def("kotlin/io/println") {
            if (args.isEmpty()) lua("print") else lua("print", printable(arg(0), argTypes[0]))
        }
        def("kotlin/io/print") { lua("io.write", str(arg(0), argTypes[0])) }

        // Conversions. Int arithmetic is not wrapped to 32 bits; explicit narrowing is.
        for (t in INTEGRAL) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0")) }
            def("kotlin/$t.toLong") { self }
            def("kotlin/$t.toInt") { if (t == "Long") lualib("ToInt32", self) else self }
        }
        for (t in FLOATING) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { self }
            def("kotlin/$t.toInt") { lualib("DoubleToInt", self) }
            def("kotlin/$t.toLong") { lualib("DoubleToLong", self) }
        }

        // Any / Enum
        def("kotlin/Any.equals") { lualib("Equals", self, arg(0)) }
        def("kotlin/Throwable.message") { LuaIndex(self, LuaString("message")) }
        def("kotlin/Throwable.cause") { LuaIndex(self, LuaString("cause")) }
        def("kotlin/Enum.name") { LuaIndex(self, LuaString("name")) }
        def("kotlin/Enum.ordinal") { LuaIndex(self, LuaString("ordinal")) }

        // Strings
        def("kotlin/String.length") { LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/String.plus") { LuaBinary(LuaBinOp.Concat, self, str(arg(0), argTypes[0], forConcat = true)) }
        def("kotlin/text/uppercase") { if (args.isEmpty()) method(self, "upper") else null }
        def("kotlin/text/lowercase") { if (args.isEmpty()) method(self, "lower") else null }
        def("kotlin/text/repeat") { method(self, "rep", arg(0)) }
        def("kotlin/text/isEmpty") { LuaBinary(LuaBinOp.Eq, LuaUnary(LuaUnOp.Len, self), LuaNumber("0")) }
        def("kotlin/text/isNotEmpty") { LuaBinary(LuaBinOp.Gt, LuaUnary(LuaUnOp.Len, self), LuaNumber("0")) }

        // kotlin.comparisons / kotlin.math
        def("kotlin/comparisons/maxOf", "kotlin/math/max") { if (args.size in 2..3) lua("math.max", *args.toTypedArray()) else null }
        def("kotlin/comparisons/minOf", "kotlin/math/min") { if (args.size in 2..3) lua("math.min", *args.toTypedArray()) else null }
        def("kotlin/math/abs") { lua("math.abs", arg(0)) }
        def("kotlin/math/sqrt") { lua("math.sqrt", arg(0)) }
        def("kotlin/math/sin") { lua("math.sin", arg(0)) }
        def("kotlin/math/cos") { lua("math.cos", arg(0)) }
        def("kotlin/math/tan") { lua("math.tan", arg(0)) }
        def("kotlin/math/exp") { lua("math.exp", arg(0)) }
        def("kotlin/math/ln") { lua("math.log", arg(0)) }
        def("kotlin/math/log10") { lua("math.log", arg(0), LuaNumber("10")) }
        // Lua's floor/ceil return integers; Kotlin's return Double.
        def("kotlin/math/floor") { LuaBinary(LuaBinOp.Add, lua("math.floor", arg(0)), LuaNumber("0.0")) }
        def("kotlin/math/ceil") { LuaBinary(LuaBinOp.Add, lua("math.ceil", arg(0)), LuaNumber("0.0")) }
        def("kotlin/math/pow") { LuaBinary(LuaBinOp.Pow, self, arg(0)) }
        def("kotlin/math/PI") { luaPath("math", "pi") }
        def("kotlin/math/E") { lua("math.exp", LuaNumber("1")) }
    }

    fun has(callableId: String?) = callableId in mappings

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        // toString() with no arguments, on anything from the kotlin package.
        if (site.name == "toString" && site.args.isEmpty() && site.receiver != null && callableId?.startsWith("kotlin/") == true) {
            return site.str(site.self, site.receiverType)
        }
        return mappings[callableId ?: return null]?.invoke(site)
    }

    /** Lua's `print` formats integers, strings and booleans the way Kotlin does. */
    private fun CallSite.printable(value: LuaExpr, type: KaType?): LuaExpr = with(session) {
        if (type != null && !type.isMarkedNullable && (type.isStringType || type.isCharType || type.isIntegral || type.isBooleanType)) value
        else str(value, type)
    }
}
