package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.successfulCallOrNull
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtClass

/**
 * More of the `kotlin` package: `Any()`, `String()`, the entries of `LazyThreadSafetyMode` and `DeprecationLevel`,
 * `Double`/`Float` `inc`/`dec`, the arrays' `clone`, the ranges of `Byte`, `Short`, `Char` and `Long` as values, and
 * `takeHighestOneBit`/`takeLowestOneBit` of the small types.
 */
internal object KotlinMiscMappings {
    private val ENUMS = mapOf(
        "kotlin/LazyThreadSafetyMode" to "__K2L_LazyThreadSafetyMode",
        "kotlin/DeprecationLevel" to "__K2L_DeprecationLevel",
    )
    private val ARRAYS = listOf("", "Boolean", "Byte", "Short", "Char", "Int", "Long", "Float", "Double").map { "kotlin/${it}Array.clone" }
    private val SMALL = listOf("Byte", "Short")
    private const val BYTE_MASK = "255"
    private const val SHORT_MASK = "65535"

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId == null || !callableId.startsWith("kotlin/")) return null
        val owner = callableId.substringBeforeLast('.')
        val name = callableId.substringAfterLast('.')
        return when {
            owner in ENUMS -> enumMember(ENUMS.getValue(owner), name, site)
            callableId in ARRAYS -> LuaMethodCall(site.self, "toTypedArray", emptyList())
            callableId == "kotlin/takeHighestOneBit" || callableId == "kotlin/takeLowestOneBit" -> oneBit(callableId, site)
            else -> misc(callableId, site) ?: numberMember(owner.removePrefix("kotlin/"), name, site)
        }
    }

    /**
     * `AutoCloseable { }`, `assert` (disabled: the condition is evaluated, the message is not),
     * the identity hash of an enum entry, the hash of a Result and of a nullable value, `Char.toChar()`, `lazyOf` and
     * `enumValues`/`enumValueOf`.
     */
    private fun misc(callableId: String, site: CallSite): LuaExpr? = with(site) {
        when (callableId) {
            "kotlin/lazyOf" -> extrasMember("lazyOf", arg(0))

            "kotlin/enumValues", "kotlin/enumValueOf" -> enumOf(callableId, site)

            "kotlin/AutoCloseable" ->
                args.singleOrNull()?.takeIf { receiver == null }?.let { LuaCall(ref(KOTLIN_MISC, "__K2L_AutoCloseableOf"), listOf(it)) }

            "kotlin/assert" -> if (receiver == null) arg(0) else null

            "kotlin/Enum.hashCode" -> receiver?.let { lualib("IdentityHash", it) }

            "kotlin/Result.hashCode", "kotlin/hashCode" -> receiver?.let { lualib("Hash", it) }

            "kotlin/Char.toChar" -> receiver

            // a property reference's getValue/setValue called directly: its get/set, with the receiver of a KProperty1
            "kotlin/getValue", "kotlin/setValue" -> receiver?.let { propertyOperator(callableId == "kotlin/setValue", it) }

            // a library delegate's operators called directly
            "kotlin/properties/ReadOnlyProperty.getValue", "kotlin/properties/ReadWriteProperty.getValue",
            "kotlin/properties/ReadWriteProperty.setValue", "kotlin/properties/PropertyDelegateProvider.provideDelegate",
            -> receiver?.let { LuaMethodCall(it, callableId.substringAfterLast('.'), args) }

            else -> null
        }
    }

    /** `Any()` and `String()`. */
    fun construct(classId: String?, site: CallSite): LuaExpr? = when (classId) {
        "kotlin/Any" -> site.libNew(KOTLIN_MISC, "__K2L_Object", emptyList())
        "kotlin/String" -> if (site.args.isEmpty()) LuaString("") else null
        else -> null
    }

    private fun enumMember(table: String, name: String, site: CallSite): LuaExpr? = with(site) {
        fun cls() = ref(KOTLIN_MISC, table)
        when {
            name == "values" || name == "entries" -> LuaCall(LuaIndex(cls(), LuaString("values")), emptyList())
            name == "valueOf" -> LuaCall(LuaIndex(cls(), LuaString("valueOf")), args)
            receiver == null && name.all { it.isUpperCase() || it == '_' } -> LuaIndex(cls(), LuaString(name))
            else -> null
        }
    }

    /** Types whose `rangeTo` is that of Int and whose `rangeUntil` is `until`: their values are plain numbers. */
    private val INT_RANGES = SMALL

    private fun numberMember(type: String, name: String, site: CallSite): LuaExpr? = with(site) {
        when {
            receiver == null -> null

            (type == "Double" || type == "Float") && (name == "inc" || name == "dec") -> stepped(name)

            type in INT_RANGES && name == "rangeTo" -> StdlibMappings.map("kotlin/Int.rangeTo", this)

            (type in INT_RANGES || type == "Char" || type == "Long") && name == "rangeUntil" ->
                StdlibMappings.map("kotlin/ranges/until", this)

            else -> null
        }
    }

    private fun CallSite.propertyOperator(set: Boolean, reference: LuaExpr): LuaExpr? {
        val classId = receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } }
        val unbound = when (classId) {
            "kotlin/reflect/KProperty0", "kotlin/reflect/KMutableProperty0" -> false
            "kotlin/reflect/KProperty1", "kotlin/reflect/KMutableProperty1" -> true
            else -> return null
        }
        val receiver = if (unbound) listOf(arg(0)) else emptyList()
        return LuaMethodCall(reference, if (set) "set" else "get", if (set) receiver + arg(2) else receiver)
    }

    /** `inc()` and `dec()` of a Double or Float. */
    private fun CallSite.stepped(name: String): LuaExpr = LuaBinary(if (name == "inc") LuaBinOp.Add else LuaBinOp.Sub, self, LuaNumber("1"))

    /** Of a Byte or Short: of its bits as an unsigned Int, narrowed back. */
    private fun oneBit(callableId: String, site: CallSite): LuaExpr? = with(site) {
        val int = session.builtinTypes.int
        val small = SMALL.firstOrNull { isType(receiverType, "kotlin/$it") }
        when {
            receiver == null -> null

            small != null -> {
                val masked = intCall("kotlin/Int.and", self, int, LuaNumber(if (small == "Byte") BYTE_MASK else SHORT_MASK)) ?: return null
                intCall(callableId, masked, int)?.let { intCall("kotlin/Int.to$small", it, int) }
            }

            else -> null
        }
    }

    private fun CallSite.intCall(callableId: String, receiver: LuaExpr, int: KaType, vararg args: LuaExpr): LuaExpr? {
        val name = callableId.substringAfterLast('.').substringAfterLast('/')
        val site = CallSite(session, transformer, element, name, receiver, int, args.toList(), args.map { int })
        return StdlibMappings.map(callableId, site)
    }

    private fun CallSite.isType(type: KaType?, classId: String): Boolean =
        type != null && with(session) { (type.withoutFlexibility as? KaClassType)?.classId?.asString() } == classId
}

/** `enumValues<E>()` and `enumValueOf<E>(name)` of an enum class of the program (a reified `E` included). */
private fun enumOf(callableId: String, site: CallSite): LuaExpr? = with(site.session) {
    val call = site.element.resolveToCall()?.successfulCallOrNull<KaCallableMemberCall<*, *>>() ?: return null
    val declared = call.typeArgumentsMapping.values.firstOrNull() ?: return null
    val enum = site.transformer.reifiedType(declared).expandedSymbol?.psi as? KtClass ?: return null
    if (!enum.isEnum() || !site.transformer.classes.isSource(enum)) return null
    val cls = site.transformer.classRef(enum)
    if (callableId == "kotlin/enumValues") site.lualib("EnumValues", cls) else site.lualib("EnumValueOf", cls, site.arg(0))
}
