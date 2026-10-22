package dev.k2l.transform

import dev.k2l.LuaTarget
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaFlexibleType
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
    /** The callee's parameter types as declared (`T` for `plus(element: T)`, `Iterable<T>` for `plus(elements)`), when known. */
    val parameterTypes: List<KaType?> = emptyList(),
) {
    val self: LuaExpr get() = receiver ?: error("call has no receiver")
    fun arg(i: Int) = args[i]
    fun str(value: LuaExpr, type: KaType?, forConcat: Boolean = false) = transformer.str(value, type, forConcat)
    fun lualib(feature: String, vararg args: LuaExpr) = transformer.lualibCall(feature, *args)
    fun unsupported(what: String) = transformer.unsupported(element, what)
    fun ref(feature: String, name: String) = transformer.lualibRef(feature, name)

    val target: LuaTarget get() = transformer.target
    val hasIntegers: Boolean get() = target.hasIntegers

    /** The collection kind of [type] (see [collectionKind]), null for other types. */
    fun kindOf(type: KaType?): CollectionKind? = type?.let { with(session) { it.collectionKind() } }

    val receiverKind: CollectionKind? get() = kindOf(receiverType)

    /** The same call with some of its parts replaced. */
    fun copy(
        name: String? = this.name,
        receiver: LuaExpr? = this.receiver,
        receiverType: KaType? = this.receiverType,
        args: List<LuaExpr> = this.args,
        argTypes: List<KaType?> = this.argTypes,
        parameterTypes: List<KaType?> = this.parameterTypes,
    ) = CallSite(session, transformer, element, name, receiver, receiverType, args, argTypes, parameterTypes)

    /** The same call on another receiver, e.g. a map's entries. */
    fun withReceiver(newReceiver: LuaExpr, type: KaType? = null) = copy(receiver = newReceiver, receiverType = type)

    /**
     * The type that tells which overload argument [i] is for: the declared parameter type of the resolved callee (so
     * `lists += listOf(1)` on a `MutableList<List<Int>>` adds one element), else the argument's own type.
     */
    fun overloadType(i: Int): KaType? = parameterTypes.getOrNull(i) ?: argTypes.getOrNull(i)
}

/**
 * Maps Kotlin stdlib callables (by `CallableId`, e.g. `kotlin/io/println` or `kotlin/String.length`)
 * to Lua. A mapping returns null when it doesn't handle that overload.
 */
@Suppress("TooManyFunctions") // one small installer per group of mappings
object StdlibMappings {
    private val table = MappingTable()

    /** Ids defined twice (see [MappingTable.overwrites]). */
    internal val overwrites: List<String> get() = table.overwrites
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
        BitMappings.install(table)
        RandomMappings.install(table)
        ThrowableMappings.install(table)
        RegexMappings.install(table)
        ReflectionMappings.install(table)
    }

    private fun io() {
        def("kotlin/io/println") {
            if (args.isEmpty()) return@def lua("print")
            val text = printable(unboxed(arg(0), 0), argTypes[0])
            // Lua 5.1's print stops at a NUL character; io.write writes whole strings
            val isText = text != arg(0) || isTextual(argTypes[0])
            if (target.printStopsAtNul && isText) lua("io.write", text, LuaString("\n")) else lua("print", text)
        }
        def("kotlin/io/print") { lua("io.write", str(unboxed(arg(0), 0), argTypes[0])) }
        def("kotlin/io/readLine", "kotlin/io/readlnOrNull", "kotlin/io/readln") { lua("io.read") }
    }

    /**
     * Numbers are Lua numbers: a conversion between integer types is the number itself (nothing narrows), one to `Double` or
     * `Float` makes it a float (`x + 0.0`, which Lua 5.3+ prints with a `.0`), and one from a `Double` or `Float` to an
     * integer type truncates toward zero (`__K2L_Truncate`), so it gives an integer.
     */
    private fun conversions() {
        for (t in INTEGRAL) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0")) }
            def("kotlin/$t.toLong", "kotlin/$t.toInt", "kotlin/$t.toShort", "kotlin/$t.toByte") { self }
            def("kotlin/$t.toChar") { lua("string.char", self) }
        }
        for (t in FLOATING) {
            def("kotlin/$t.toDouble", "kotlin/$t.toFloat") { self }
            def("kotlin/$t.toInt", "kotlin/$t.toLong", "kotlin/$t.toShort", "kotlin/$t.toByte") { lualib("Truncate", self) }
        }
        // a value typed `Number` is a Lua number
        def("kotlin/Number.toDouble", "kotlin/Number.toFloat") { LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0")) }
        def("kotlin/Number.toLong", "kotlin/Number.toInt", "kotlin/Number.toShort", "kotlin/Number.toByte") { lualib("Truncate", self) }
    }

    private fun anyAndEnum() {
        def("kotlin/Any.equals") { lualib("Equals", self, arg(0)) }
        def("kotlin/Throwable.message") { LuaIndex(self, LuaString("message")) }
        def("kotlin/Throwable.cause") { LuaIndex(self, LuaString("cause")) }
        def("kotlin/isInitialized") { transformer.lateinitIsInitialized(element) }
        def("kotlin/Lazy.value") { method(self, "getValue") }
        def("kotlin/Lazy.isInitialized") { method(self, "isInitialized") }
        def("kotlin/Enum.name") { LuaIndex(self, LuaString("name")) }
        def("kotlin/Enum.ordinal") { LuaIndex(self, LuaString("ordinal")) }
    }

    /**
     * Bitwise operations: Lua's operators on 5.3+, where Int and Long are Lua integers; the 32-bit helpers of `Bit.lua`
     * (bit32, LuaJIT's bit, or plain Lua) elsewhere, for a Long too.
     */
    private fun bitwise() {
        for (t in listOf("Int", "Long")) {
            val isLong = t == "Long"
            def("kotlin/$t.and") { ConstantBits.mask(this, isLong) ?: bitwise("BAnd", LuaBinOp.BAnd) }
            def("kotlin/$t.or") { bitwise("BOr", LuaBinOp.BOr) }
            def("kotlin/$t.xor") { bitwise("BXor", LuaBinOp.BXor) }
            def("kotlin/$t.inv") { if (target.hasIntegers) LuaUnary(LuaUnOp.BNot, self) else bitCall("__K2L_BNot") }
        }
        // Boolean's infix xor (both operands are evaluated, as `~=` does) and not(); infix and/or evaluate both operands too
        def("kotlin/Boolean.xor") { LuaBinary(LuaBinOp.Ne, self, arg(0)) }
        def("kotlin/Boolean.and") { LuaCall(ref("Bool", "__K2L_BoolAnd"), listOf(self, arg(0))) }
        def("kotlin/Boolean.or") { LuaCall(ref("Bool", "__K2L_BoolOr"), listOf(self, arg(0))) }
        def("kotlin/Boolean.not") { LuaUnary(LuaUnOp.Not, self) }
        shifts()
    }

    private fun shifts() {
        def("kotlin/Int.shl") { ConstantBits.integerShift(this, "shl") ?: bitCall("__K2L_Shl") }
        def("kotlin/Int.shr") {
            ConstantBits.integerShift(this, "shr") ?: ConstantBits.shift(this, false, false) ?: bitCall("__K2L_Shr")
        }
        def("kotlin/Int.ushr") {
            ConstantBits.integerShift(this, "ushr") ?: ConstantBits.shift(this, false, true) ?: bitCall("__K2L_Ushr")
        }
        // where a Long is a double, its shifts are multiplications and floored divisions by 2^n (exact below 2^53)
        def("kotlin/Long.shl") {
            if (target.hasIntegers) LuaBinary(LuaBinOp.Shl, self, arg(0)) else LuaBinary(LuaBinOp.Mul, self, pow2(arg(0)))
        }
        def("kotlin/Long.shr") {
            if (target.hasIntegers) {
                LuaBinary(LuaBinOp.IDiv, self, LuaBinary(LuaBinOp.Shl, LuaNumber("1"), arg(0)))
            } else {
                ConstantBits.shift(this, true, false) ?: lua("math.floor", LuaBinary(LuaBinOp.Div, self, pow2(arg(0))))
            }
        }
        def("kotlin/Long.ushr") {
            if (target.hasIntegers) {
                LuaBinary(LuaBinOp.Shr, self, arg(0))
            } else {
                lua("math.floor", LuaBinary(LuaBinOp.Div, LuaBinary(LuaBinOp.Mod, self, pow2(LuaNumber("64"))), pow2(arg(0))))
            }
        }
    }

    private fun pow2(n: LuaExpr): LuaExpr = LuaBinary(LuaBinOp.Pow, LuaNumber("2"), n)

    private fun basicStrings() {
        def("kotlin/String.length") { LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/String.plus") { LuaBinary(LuaBinOp.Concat, self, str(arg(0), argTypes[0], forConcat = true)) }
        // string.upper and string.lower; the overloads taking a Locale are not supported
        def("kotlin/text/uppercase") { if (args.isEmpty()) method(self, "upper") else null }
        def("kotlin/text/lowercase") { if (args.isEmpty()) method(self, "lower") else null }
        def("kotlin/text/repeat") {
            val count = (arg(0) as? LuaNumber)?.text?.toLongOrNull()
            if (count != null && count >= 0) {
                method(self, "rep", arg(0))
            } else {
                libMember(TEXT_TABLE, "repeatCount", self, arg(0))
            }
        }
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

    /** and/or/xor: native operators on 5.3+, lualib helpers (bit32, LuaJIT's bit, or plain Lua) elsewhere. */
    private fun CallSite.bitwise(helper: String, op: LuaBinOp): LuaExpr =
        if (target.hasIntegers) LuaBinary(op, self, arg(0)) else bitCall("__K2L_$helper")

    private fun CallSite.bitCall(name: String): LuaExpr = LuaCall(ref("Bit", name), listOfNotNull(receiver) + args)

    fun map(callableId: String?, site: CallSite): LuaExpr? = AREAS.firstNotNullOfOrNull { it(callableId, site) }

    /**
     * Every area of library mappings, tried in this order until one answers; the order matters where areas overlap. Each area
     * is a lambda so that its mapping object is still initialized on first use.
     */
    private val AREAS = listOf<MappingArea>(
        // toString() and compareTo(x) on any receiver from the kotlin package (and on the JDK's collections)
        { id, site -> special(id, site) },
        // charsets, more of `kotlin.text` and of `kotlin` ...
        { id, site -> CharsetMappings.map(id, site) },
        { id, site -> TextExtrasMappings.map(id, site) },
        { id, site -> CollectionExtrasMappings.map(id, site) },
        { id, site -> KotlinMiscMappings.map(id, site) },
        // the table the installers above fill
        { id, site -> id?.let { mappings[it] }?.invoke(site) },
        { id, site -> TypeTestMappings.map(id, site) },
        { id, site -> SequenceMappings.map(id, site) },
        { id, site -> CoroutineMappings.map(id, site) },
        // the collection, range, comparator and pair factories (listOf, compareBy, ...)
        { id, site -> FactoryMappings.factory(id, site) },
        // members by the receiver's collection kind
        { id, site -> CollectionMappings.byReceiver(id, site) },
        // a receiver of no collection kind: strings, chars and other text
        { id, site -> if (site.receiverKind == null) TextMappings.map(id, site) else null },
    )

    private fun special(callableId: String?, site: CallSite): LuaExpr? = when {
        site.receiver == null -> null

        callableId?.startsWith("kotlin/") == true -> universalMethod(site)

        // toString() of the collections that are JDK classes (ArrayList, HashMap, ...)
        callableId?.startsWith("java/util/") == true && site.name == "toString" && site.args.isEmpty() &&
            site.receiverKind != null -> universalMethod(site)

        else -> null
    }

    /** toString() and compareTo(x) on anything from the kotlin package. */
    private fun universalMethod(site: CallSite): LuaExpr? = when {
        site.name == "toString" && site.args.isEmpty() -> site.str(site.self, site.receiverType)

        // String.compareTo is the difference of the first differing chars (or of the lengths)
        site.name == "compareTo" && site.args.size == 1 && site.isString(site.receiverType) ->
            site.libCall(TEXT_TABLE, "compare", listOf(site.self, site.arg(0)))

        site.name == "compareTo" && site.args.size == 1 ->
            LuaCall(site.ref("Compare", "__K2L_Compare"), listOf(site.self, site.arg(0)))

        else -> null
    }

    /**
     * Argument [i] passed to a primitive parameter (`println(message: Int)`): a platform-typed value (a value of the
     * `java.util.SortedMap` of `sortedMapOf` is `Int!`) is checked there, so null throws `NullPointerException`.
     */
    private fun CallSite.unboxed(value: LuaExpr, i: Int): LuaExpr = with(session) {
        val type = argTypes.getOrNull(i) as? KaFlexibleType ?: return value
        val parameter = parameterTypes.getOrNull(i) ?: return value
        val primitive = parameter.isPrimitive && !parameter.isMarkedNullable
        if (primitive && type.upperBound.isMarkedNullable) lualib("NotNull", value) else value
    }

    /** Lua's `print` writes numbers, strings and booleans with `tostring`, as `str` does. */
    private fun CallSite.printable(value: LuaExpr, type: KaType?): LuaExpr = if (printsPlain(type)) value else str(value, type)

    private fun CallSite.printsPlain(type: KaType?) = type != null && with(session) {
        !type.isMarkedNullable && (type.isStringType || type.isCharType || type.isNumber || type.isBooleanType)
    }
}
