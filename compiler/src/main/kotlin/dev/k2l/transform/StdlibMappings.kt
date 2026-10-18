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
    fun str(value: LuaExpr, type: KaType?, forConcat: Boolean = false) = with(transformer) { session.str(value, type, forConcat) }
    fun lualib(feature: String, vararg args: LuaExpr) = transformer.lualibCall(feature, *args)
    fun unsupported(what: String) = transformer.unsupported(element, what)
    fun ref(feature: String, name: String) = transformer.lualibRef(feature, name)

    /** The same call on another receiver, e.g. a map's entries. */
    fun withReceiver(newReceiver: LuaExpr, type: KaType? = null) =
        CallSite(session, transformer, element, name, newReceiver, type, args, argTypes)
}

/**
 * Maps Kotlin stdlib callables (by `CallableId`, e.g. `kotlin/io/println` or `kotlin/String.length`)
 * to Lua. A mapping returns null when it doesn't handle that overload.
 */
@Suppress("TooManyFunctions") // one small installer per group of mappings
object StdlibMappings {
    private val table = MappingTable()
    private val mappings get() = table.entries

    private fun def(vararg ids: String, mapping: Mapping) = table.def(*ids, mapping = mapping)

    private val INTEGRAL = listOf("Int", "Long", "Short", "Byte")
    private val FLOATING = listOf("Double", "Float")

    init {
        io()
        conversions()
        anyAndEnum()
        bitwise()
        basicStrings()
        NumberMappings.install(table)
        RandomMappings.install(table)
        ThrowableMappings.install(table)
        RegexMappings.install(table)
    }

    private fun io() {
        def("kotlin/io/println") {
            if (args.isEmpty()) lua("print") else lua("print", printable(arg(0), argTypes[0]))
        }
        def("kotlin/io/print") { lua("io.write", str(arg(0), argTypes[0])) }
        def("kotlin/io/readLine", "kotlin/io/readlnOrNull", "kotlin/io/readln") { lua("io.read") }
    }

    /** Int arithmetic is not wrapped to 32 bits; explicit narrowing is. */
    private fun conversions() {
        for (t in INTEGRAL) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0")) }
            def("kotlin/$t.toLong") { self }
            def("kotlin/$t.toChar") { lua("string.char", self) }
            def("kotlin/$t.toInt") { if (t == "Long") lualib("ToInt32", self) else self }
        }
        for (t in FLOATING) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { self }
            def("kotlin/$t.toInt") { lualib("DoubleToInt", self) }
            def("kotlin/$t.toLong") { lualib("DoubleToLong", self) }
        }
    }

    private fun anyAndEnum() {
        def("kotlin/Any.equals") { lualib("Equals", self, arg(0)) }
        def("kotlin/Throwable.message") { LuaIndex(self, LuaString("message")) }
        def("kotlin/Throwable.cause") { LuaIndex(self, LuaString("cause")) }

        // Lazy values and the KProperty stand-in passed to delegates (a table with a `name`)
        def("kotlin/Lazy.value") { method(self, "getValue") }
        def("kotlin/Lazy.isInitialized") { method(self, "isInitialized") }
        def("kotlin/reflect/KCallable.name", "kotlin/reflect/KProperty.name") { LuaIndex(self, LuaString("name")) }
        def("kotlin/Enum.name") { LuaIndex(self, LuaString("name")) }
        def("kotlin/Enum.ordinal") { LuaIndex(self, LuaString("ordinal")) }
    }

    /** Bitwise operations. Int results stay in 32-bit range; Long uses Lua's 64-bit integers (5.3+ only). */
    private fun bitwise() {
        for (t in listOf("Int", "Long")) {
            val isLong = t == "Long"
            def("kotlin/$t.and") { bitwise("BAnd", LuaBinOp.BAnd) }
            def("kotlin/$t.or") { bitwise("BOr", LuaBinOp.BOr) }
            def("kotlin/$t.xor") { bitwise("BXor", LuaBinOp.BXor) }
            def("kotlin/$t.inv") {
                if (target.hasIntegers) LuaUnary(LuaUnOp.BNot, self) else bitCall("__K2L_BNot")
            }
            def("kotlin/$t.shl") {
                if (target.hasIntegers && isLong) LuaBinary(LuaBinOp.Shl, self, arg(0)) else bitCall("__K2L_Shl")
            }
            def("kotlin/$t.shr") {
                if (target.hasIntegers && isLong) {
                    LuaBinary(LuaBinOp.IDiv, self, LuaBinary(LuaBinOp.Shl, LuaNumber("1"), arg(0)))
                } else {
                    bitCall("__K2L_Shr")
                }
            }
            def("kotlin/$t.ushr") {
                if (target.hasIntegers && isLong) LuaBinary(LuaBinOp.Shr, self, arg(0)) else bitCall("__K2L_Ushr")
            }
        }
    }

    private fun basicStrings() {
        def("kotlin/String.length") { LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/String.plus") { LuaBinary(LuaBinOp.Concat, self, str(arg(0), argTypes[0], forConcat = true)) }
        def("kotlin/text/uppercase") { if (args.isEmpty()) method(self, "upper") else null }
        def("kotlin/text/lowercase") { if (args.isEmpty()) method(self, "lower") else null }
        def("kotlin/text/repeat") { method(self, "rep", arg(0)) }
        def("kotlin/CharSequence.length") { LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/text/isEmpty") {
            if (isBuilder(receiverType)) method(self, "isEmpty") else LuaBinary(LuaBinOp.Eq, LuaUnary(LuaUnOp.Len, self), LuaNumber("0"))
        }
        def("kotlin/text/isNotEmpty") {
            if (isBuilder(receiverType)) method(self, "isNotEmpty") else LuaBinary(LuaBinOp.Gt, LuaUnary(LuaUnOp.Len, self), LuaNumber("0"))
        }
    }

    private fun CallSite.isBuilder(type: KaType?) = type != null && with(session) { type.collectionKind() } == CollectionKind.StringBuilder

    fun has(callableId: String?) = callableId in mappings

    private val CallSite.target get() = transformer.ctx.options.luaTarget

    /** and/or/xor: native operators on 5.3+, lualib helpers (bit32, LuaJIT's bit, or plain Lua) elsewhere. */
    private fun CallSite.bitwise(helper: String, op: LuaBinOp): LuaExpr =
        if (target.hasIntegers) LuaBinary(op, self, arg(0)) else bitCall("__K2L_$helper")

    private fun CallSite.bitCall(name: String): LuaExpr = LuaCall(ref("Bit", name), listOfNotNull(receiver) + args)

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        val special = if (site.receiver != null && callableId?.startsWith("kotlin/") == true) universalMethod(site) else null
        return special
            ?: callableId?.let { mappings[it] }?.invoke(site)
            ?: TypeTestMappings.map(callableId, site)
            ?: SequenceMappings.map(callableId, site)
            ?: CoroutineMappings.map(callableId, site)
            ?: CollectionMappings.map(callableId, site)
    }

    /** toString() and compareTo(x) on anything from the kotlin package. */
    private fun universalMethod(site: CallSite): LuaExpr? = when {
        site.name == "toString" && site.args.isEmpty() -> site.str(site.self, site.receiverType)

        // String.compareTo is the difference of the first differing chars (or of the lengths)
        site.name == "compareTo" && site.args.size == 1 && site.isString(site.receiverType) ->
            LuaCall(LuaIndex(site.ref("Strings", "__K2L_Text"), LuaString("compare")), listOf(site.self, site.arg(0)))

        site.name == "compareTo" && site.args.size == 1 ->
            LuaCall(site.ref("Compare", "__K2L_Compare"), listOf(site.self, site.arg(0)))

        else -> null
    }

    /** Lua's `print` formats integers, strings and booleans the way Kotlin does. */
    private fun CallSite.printable(value: LuaExpr, type: KaType?): LuaExpr = with(session) {
        val longWithoutIntegers = !target.hasIntegers && type?.withoutFlexibility?.isLongType == true
        if (!longWithoutIntegers && type.printsLikeKotlin()) value else str(value, type)
    }

    context(s: KaSession)
    private fun KaType?.printsLikeKotlin() =
        this != null && with(s) { !isMarkedNullable && (isStringType || isCharType || isIntegral || isBooleanType) }
}
