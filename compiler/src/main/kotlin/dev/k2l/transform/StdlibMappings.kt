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

    /** `--long64 emulate` on a target without integers. */
    val emulatesLong: Boolean get() = transformer.emulatesLong

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

    /** The call `f(x, rest)` as the member or extension call `x.name(rest)`, on its first argument. */
    fun onFirstArgument(name: String) = copy(
        name = name,
        receiver = arg(0),
        receiverType = argTypes[0],
        args = args.drop(1),
        argTypes = argTypes.drop(1),
        parameterTypes = emptyList(),
    )

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
private const val STRICT_MATH = "java/lang/StrictMath."

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
        JavaStaticMappings.install(table)
        UnsignedMappings.install(table)
        RandomMappings.install(table)
        ThrowableMappings.install(table)
        RegexMappings.install(table)
        ReflectionMappings.install(table)
        Utf16Mappings.install(table)
        CharacterMappings.install(table)
    }

    private fun io() {
        def("kotlin/io/println") {
            if (args.isEmpty()) return@def lua("print")
            val text = printable(unboxed(arg(0), 0), argTypes[0])
            // Lua 5.1's print stops at a NUL character; io.write writes whole strings
            val isText = text != arg(0) || isTextual(argTypes[0])
            if (target.printStopsAtNul && isText) lua("io.write", output(text), LuaString("\n")) else lua("print", output(text))
        }
        def("kotlin/io/print") { lua("io.write", output(str(unboxed(arg(0), 0), argTypes[0]))) }
        def("kotlin/io/readLine", "kotlin/io/readlnOrNull", "kotlin/io/readln") { lua("io.read") }
    }

    /** Int arithmetic is not wrapped to 32 bits; explicit narrowing is. */
    private fun conversions() {
        for (t in INTEGRAL) {
            def("kotlin/$t.toDouble") { LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0")) }
            def("kotlin/$t.toFloat") {
                if (t == "Int" || t == "Long") transformer.fround(self) else LuaBinary(LuaBinOp.Add, self, LuaNumber("0.0"))
            }
            def("kotlin/$t.toLong") { self }
            def("kotlin/$t.toChar") { if (utf16) u16("char", self) else lua("string.char", self) }
            def("kotlin/$t.toInt") { if (t == "Long") lualib("ToInt32", self) else self }
        }
        for (t in FLOATING) {
            def("kotlin/$t.toDouble") { self }
            def("kotlin/$t.toFloat") { if (t == "Double") transformer.fround(self) else self }
            def("kotlin/$t.toInt") { lualib("DoubleToInt", self) }
            def("kotlin/$t.toLong") { lualib("DoubleToLong", self) }
        }
        // a value typed `Number` may be an Int, a Double or a BigInteger: the conversion is chosen at run time
        for (conversion in listOf("toDouble", "toFloat", "toLong", "toInt", "toShort", "toByte")) {
            def("kotlin/Number.$conversion") { lualib("NumberTo", self, LuaString(conversion)) }
        }
    }

    private fun anyAndEnum() {
        def("kotlin/Any.equals") { lualib("Equals", self, arg(0)) }
        def("kotlin/Throwable.message", *FORMATTER_EXCEPTIONS.map { "java/util/$it.message" }.toTypedArray()) {
            LuaIndex(self, LuaString("message"))
        }
        def("kotlin/Throwable.cause") { LuaIndex(self, LuaString("cause")) }

        def("kotlin/isInitialized") { transformer.lateinitIsInitialized(element) }
        def("kotlin/Lazy.value") { method(self, "getValue") }
        def("kotlin/Lazy.isInitialized") { method(self, "isInitialized") }
        def("kotlin/Enum.name") { LuaIndex(self, LuaString("name")) }
        def("kotlin/Enum.ordinal") { LuaIndex(self, LuaString("ordinal")) }
    }

    /**
     * Bitwise operations. Int results stay in 32-bit range; Long uses Lua's 64-bit integers on 5.3+, and the exact 53-bit
     * helpers of `LongBits.lua` where a Long is a double.
     */
    private fun bitwise() {
        for (t in listOf("Int", "Long")) {
            val isLong = t == "Long"
            def("kotlin/$t.and") {
                ConstantBits.mask(this, isLong)
                    ?: if (isLong && !target.hasIntegers) longBits("LBAnd") else bitwise("BAnd", LuaBinOp.BAnd)
            }
            def("kotlin/$t.or") { if (isLong && !target.hasIntegers) longBits("LBOr") else bitwise("BOr", LuaBinOp.BOr) }
            def("kotlin/$t.xor") { if (isLong && !target.hasIntegers) longBits("LBXor") else bitwise("BXor", LuaBinOp.BXor) }
            def("kotlin/$t.inv") { if (target.hasIntegers) LuaUnary(LuaUnOp.BNot, self) else floatBits(isLong, "BNot") }
        }
        // Boolean's infix xor (both operands are evaluated, as `~=` does) and not()
        def("kotlin/Boolean.xor") { LuaBinary(LuaBinOp.Ne, self, arg(0)) }
        def("kotlin/Boolean.not") { LuaUnary(LuaUnOp.Not, self) }
        shifts()
    }

    private fun shifts() {
        def("kotlin/Int.shl") {
            ConstantBits.integerShift(this, "shl") ?: if (target.hasIntegers) bitCall("__K2L_Shl") else floatBits(false, "Shl")
        }
        def("kotlin/Int.shr") {
            ConstantBits.integerShift(this, "shr") ?: ConstantBits.shift(this, false, false)
                ?: if (target.hasIntegers) bitCall("__K2L_Shr") else floatBits(false, "Shr")
        }
        def("kotlin/Int.ushr") {
            ConstantBits.integerShift(this, "ushr") ?: ConstantBits.shift(this, false, true)
                ?: if (target.hasIntegers) bitCall("__K2L_Ushr") else floatBits(false, "Ushr")
        }
        def("kotlin/Long.shl") { if (target.hasIntegers) LuaBinary(LuaBinOp.Shl, self, arg(0)) else floatBits(true, "Shl") }
        def("kotlin/Long.shr") {
            if (target.hasIntegers) {
                LuaBinary(LuaBinOp.IDiv, self, LuaBinary(LuaBinOp.Shl, LuaNumber("1"), arg(0)))
            } else {
                ConstantBits.shift(this, true, false) ?: floatBits(true, "Shr")
            }
        }
        def("kotlin/Long.ushr") { if (target.hasIntegers) LuaBinary(LuaBinOp.Shr, self, arg(0)) else floatBits(true, "Ushr") }
    }

    /** An operation where numbers are doubles: the 32-bit helper of `Bit.lua`, or for a Long the 53-bit one of `LongBits.lua`. */
    private fun CallSite.floatBits(isLong: Boolean, name: String): LuaExpr =
        if (isLong) longBits(if (name == "BNot") "LBNot" else "L$name") else bitCall("__K2L_$name")

    private fun CallSite.longBits(helper: String): LuaExpr = LuaCall(ref("LongBits", "__K2L_$helper"), listOfNotNull(receiver) + args)

    private fun basicStrings() {
        def("kotlin/String.length") { if (utf16) u16("len", self) else LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/String.plus") { LuaBinary(LuaBinOp.Concat, self, str(arg(0), argTypes[0], forConcat = true)) }
        // uppercase(Locale) and lowercase(Locale): the locale only matters with --strings utf16 (Turkish, Azeri, Lithuanian)
        def("kotlin/text/uppercase") {
            if (args.isNotEmpty() && !isLocale(argTypes.firstOrNull())) {
                null
            } else if (utf16) {
                u16CaseOf("uppercase")
            } else {
                method(self, "upper")
            }
        }
        def("kotlin/text/lowercase") {
            if (args.isNotEmpty() && !isLocale(argTypes.firstOrNull())) {
                null
            } else if (utf16) {
                u16CaseOf("lowercase")
            } else {
                method(self, "lower")
            }
        }
        def("kotlin/text/repeat") {
            val count = (arg(0) as? LuaNumber)?.text?.toLongOrNull()
            if (count != null && count >= 0) {
                method(self, "rep", arg(0))
            } else {
                libMember(TEXT_TABLE, "repeatCount", self, arg(0))
            }
        }
        def("kotlin/CharSequence.length") { if (utf16) u16("len", self) else LuaUnary(LuaUnOp.Len, self) }
        def("kotlin/text/isEmpty") {
            if (isBuilder(receiverType)) method(self, "isEmpty") else LuaBinary(LuaBinOp.Eq, LuaUnary(LuaUnOp.Len, self), LuaNumber("0"))
        }
        def("kotlin/text/isNotEmpty") {
            if (isBuilder(receiverType)) method(self, "isNotEmpty") else LuaBinary(LuaBinOp.Gt, LuaUnary(LuaUnOp.Len, self), LuaNumber("0"))
        }
    }

    /** The JVM writes an unpaired surrogate as `?`; with `--strings utf16` so does print. */
    private fun CallSite.output(text: LuaExpr): LuaExpr = if (utf16) u16("out", text) else text

    private fun CallSite.isBuilder(type: KaType?) = type != null && with(session) { type.collectionKind() } == CollectionKind.StringBuilder

    fun has(callableId: String?) = strictMathAsMath(callableId) in mappings

    /**
     * `StrictMath.f` is `Math.f`, except where the two can differ: those members have mappings of their own, to the fdlibm
     * ports StrictMath specifies (see NumberMappings).
     */
    private fun strictMathAsMath(callableId: String?): String? =
        if (callableId != null && callableId.startsWith(STRICT_MATH) && callableId !in mappings) {
            "java/lang/Math." + callableId.removePrefix(STRICT_MATH)
        } else {
            callableId
        }

    /** and/or/xor: native operators on 5.3+, lualib helpers (bit32, LuaJIT's bit, or plain Lua) elsewhere. */
    private fun CallSite.bitwise(helper: String, op: LuaBinOp): LuaExpr =
        if (target.hasIntegers) LuaBinary(op, self, arg(0)) else bitCall("__K2L_$helper")

    private fun CallSite.bitCall(name: String): LuaExpr = LuaCall(ref("Bit", name), listOfNotNull(receiver) + args)

    fun map(strictCallableId: String?, call: CallSite): LuaExpr? {
        val callableId = strictMathAsMath(strictCallableId)
        val site = Long64Mappings.prepare(callableId, call)
        return POST_PROCESSORS.fold(mapUnrounded(callableId, site)) { result, post -> post(callableId, site, result) }
    }

    /**
     * What wraps the result of [AREAS], in this order (each one sees the result of the one before): float rounding, Int
     * overflow, then unsigned results. [Long64Mappings.prepare] runs before all of them, on the call itself.
     */
    private val POST_PROCESSORS = listOf<MappingPost>(
        { id, site, result -> FloatMappings.post(id, site, result) },
        { id, site, result -> IntOverflowMappings.post(id, site, result) },
        { id, site, result -> UnsignedMappings.post(id, site, result) },
    )

    /**
     * Every area of library mappings, tried in this order until one answers; the order matters where areas overlap. Each area
     * is a lambda so that its mapping object is still initialized on first use.
     */
    private val AREAS = listOf<MappingArea>(
        // toString() and compareTo(x) on any receiver from the kotlin package (and on the JDK's collections)
        { id, site -> special(id, site) },
        // charsets, more of `kotlin.text` and of `kotlin`, `java.util`, `kotlin.time` ...
        { id, site -> CharsetMappings.map(id, site) },
        { id, site -> TextExtrasMappings.map(id, site) },
        { id, site -> JavaUtilMappings.map(id, site) },
        { id, site -> TimeMappings.map(id, site) },
        { id, site -> InstantMappings.map(id, site) },
        { id, site -> CharCategoryMappings.map(id, site) },
        { id, site -> DeepRecursiveMappings.map(id, site) },
        { id, site -> CollectionExtrasMappings.map(id, site) },
        { id, site -> KotlinMiscMappings.map(id, site) },
        { id, site -> HexFormatMappings.map(id, site) },
        // `--long64 emulate` takes precedence over the Double-based mappings
        { id, site -> Long64Mappings.map(id, site) },
        // the table the installers above fill
        { id, site -> id?.let { mappings[it] }?.invoke(site) },
        { id, site -> TypeTestMappings.map(id, site) },
        { id, site -> TypeOfMappings.map(id, site) },
        { id, site -> BigNumberMappings.map(id, site) },
        { id, site -> JdkCollectionsMappings.map(id, site) },
        { id, site -> StreamMappings.map(id, site) },
        { id, site -> SequenceMappings.map(id, site) },
        { id, site -> CoroutineMappings.map(id, site) },
        // the collection, range, comparator and pair factories (listOf, compareBy, ...)
        { id, site -> FactoryMappings.factory(id, site) },
        // members by the receiver's collection kind
        { id, site -> CollectionMappings.byReceiver(id, site) },
        // a receiver of no collection kind: strings, chars and other text
        { id, site -> if (site.receiverKind == null) TextMappings.map(id, site) else null },
    )

    private fun mapUnrounded(callableId: String?, site: CallSite): LuaExpr? = AREAS.firstNotNullOfOrNull { it(callableId, site) }

    private fun special(callableId: String?, site: CallSite): LuaExpr? = when {
        site.receiver == null -> null

        callableId?.startsWith("kotlin/") == true -> universalMethod(site)

        // toString() of the JDK's collections (`java.util.ArrayDeque.toString`)
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
            UnsignedMappings.compareTo(site) ?: LuaCall(site.ref("Compare", "__K2L_Compare"), listOf(site.self, site.arg(0)))

        else -> null
    }

    /**
     * Argument [i] passed to a primitive parameter (`println(message: Int)`): a platform-typed value (`treeMap.higherKey(k)` is
     * `Int!`) is unboxed there, so null throws `NullPointerException` as on the JVM.
     */
    private fun CallSite.unboxed(value: LuaExpr, i: Int): LuaExpr = with(session) {
        val type = argTypes.getOrNull(i) as? KaFlexibleType ?: return value
        val parameter = parameterTypes.getOrNull(i) ?: return value
        val primitive = parameter.isPrimitive && !parameter.isMarkedNullable
        if (primitive && type.upperBound.isMarkedNullable) lualib("NotNull", value) else value
    }

    /** Lua's `print` formats integers, strings and booleans the way Kotlin does. */
    private fun CallSite.printable(value: LuaExpr, type: KaType?): LuaExpr = with(session) {
        val longWithoutIntegers = !target.hasIntegers && type?.withoutFlexibility?.isLongType == true
        if (!longWithoutIntegers && type.printsLikeKotlin()) value else str(value, type)
    }

    context(s: KaSession)
    private fun KaType?.printsLikeKotlin() =
        this != null && with(s) { !isMarkedNullable && (isStringType || isCharType || isIntegral || isBooleanType) && !isULongType }
}
