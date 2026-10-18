package dev.k2l.transform

import dev.k2l.lua.*
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.psi.KtExpression

/**
 * `super.toString()`, `super.equals(other)` and `super.hashCode()` where the superclass chain reaches `Any`, and
 * `super.message`/`super.cause`/`super.toString()` into a lualib exception class. They behave like the JVM:
 * `Any.toString()` is `Name@hex(hashCode())`, `equals` is identity and `hashCode` is an identity hash that agrees with
 * what `Hash` gives objects without a `hashCode()`. Other library members (`printStackTrace`, ...) are not supported.
 */
internal fun FileTransformer.librarySuperCall(symbol: KaCallableSymbol, args: List<KtExpression?>): LuaExpr? = with(session) {
    val owner = symbol.callableId?.classId?.asString()
    val name = symbol.callableId?.callableName?.asString()
    // Kotlin resolves Throwable's toString to Any's, so look at what the class extends.
    val isThrowable =
        owner in LIBRARY_CLASSES ||
            currentClass?.let { c -> classes.hierarchy(c).any { classes.superInfo(it).libraryBase != null } } == true
    val self = selfRef()
    when {
        name == "toString" && args.isEmpty() -> when {
            isThrowable -> LuaCall(LuaIndex(lualibRef(EXCEPTIONS_FEATURE, "__K2L_Throwable"), LuaString("toString")), listOf(self))
            owner == "kotlin/Enum" -> LuaIndex(self, LuaString("name"))
            else -> lualibCall("AnyToString", self)
        }

        name == "equals" && args.size == 1 -> LuaBinary(LuaBinOp.Eq, self, arguments(emptyList(), args)[0])

        name == "hashCode" && args.isEmpty() -> lualibCall("IdentityHash", self)

        isThrowable && (name == "message" || name == "cause") -> LuaIndex(self, LuaString(name))

        else -> null
    }
}
