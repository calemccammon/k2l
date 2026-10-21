package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.psi.KtExpression
import org.jetbrains.kotlin.psi.KtProperty

/**
 * `super.toString()`, `super.equals(other)` and `super.hashCode()` where the superclass chain reaches `Any`, and
 * `super.message`/`super.cause`/`super.toString()` into a lualib exception class. They behave like the JVM:
 * `Any.toString()` is `Name@hex(hashCode())`, `equals` is identity and `hashCode` is an identity hash that agrees with
 * what `Hash` gives objects without a `hashCode()`. Other library members (`printStackTrace`, ...) are not supported.
 * A class that overrides `message` or `cause` with a custom accessor keeps the value the `Throwable` constructor stored
 * in `____message`, which is what `super.message` reads.
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
            isThrowable -> libCall(EXCEPTIONS_FEATURE, "__K2L_Throwable", "toString", listOf(self))
            owner == "kotlin/Enum" -> LuaIndex(self, LuaString("name"))
            else -> lualibCall("AnyToString", self)
        }

        name == "equals" && args.size == 1 -> LuaBinary(LuaBinOp.Eq, self, arguments(emptyList(), args)[0])

        name == "hashCode" && args.isEmpty() -> lualibCall("IdentityHash", self)

        isThrowable -> throwableSuperCall(name, args.isEmpty(), self)

        else -> null
    }
}

/** Whether a class in the hierarchy of the one being transformed replaced the library property [name] by an accessor. */
private fun FileTransformer.overridesWithAccessor(name: String): Boolean = currentClass?.let { c ->
    classes.hierarchy(c).any { k ->
        k.declarations.any { it is KtProperty && it.name == name && props.overridesLibraryWithAccessor(it) }
    }
} == true

/** Members of `Throwable` reached through `super`. */
private fun FileTransformer.throwableSuperCall(name: String?, noArgs: Boolean, self: LuaExpr): LuaExpr? = when {
    name == "printStackTrace" && noArgs ->
        LuaMethodCall(
            luaPath("io", "stderr"),
            "write",
            listOf(LuaBinary(LuaBinOp.Concat, LuaMethodCall(self, "toString", emptyList()), LuaString("\n"))),
        )

    name == "fillInStackTrace" && noArgs -> self

    name == "message" || name == "cause" -> LuaIndex(self, LuaString(if (overridesWithAccessor(name)) "____$name" else name))

    else -> null
}
