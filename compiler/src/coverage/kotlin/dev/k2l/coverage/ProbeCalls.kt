package dev.k2l.coverage

import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolOrigin
import org.jetbrains.kotlin.analysis.api.symbols.KaValueParameterSymbol
import org.jetbrains.kotlin.analysis.api.types.KaFunctionType
import org.jetbrains.kotlin.analysis.api.types.KaType

// The call syntax of probes: operator conventions, argument lists and lambdas.

private val UNARY = mapOf("unaryMinus" to "-", "unaryPlus" to "+", "not" to "!")
private val BINARY = mapOf(
    "plus" to "+",
    "minus" to "-",
    "times" to "*",
    "div" to "/",
    "rem" to "%",
    "rangeTo" to "..",
    "rangeUntil" to "..<",
)
private val ASSIGN = mapOf("plusAssign" to "+=", "minusAssign" to "-=", "timesAssign" to "*=", "divAssign" to "/=", "remAssign" to "%=")
private val ONE_ARGUMENT = mapOf("contains" to "val v = a0 in r", "equals" to "val v = r == a0", "compareTo" to "val v = r < a0")
private val KEYWORDS = setOf("in", "is", "as", "fun", "val", "var", "object", "typealias", "when", "interface", "package")

/**
 * The body that uses the operator [name] with [arity] arguments on `r` the way a program does: `r + a0`, `r[a0]`,
 * `a0 in r`, `for (x in r)`, `val (_, v) = r`, `val v by r`. Null for an operator called as a function.
 */
internal fun operatorBody(name: String, arity: Int): String? {
    val args = (0 until arity).joinToString { "a$it" }
    val simple = when (arity) {
        0 -> UNARY[name]?.let { "val v = ${it}r" } ?: "for (x in r) { }".takeIf { name == "iterator" } ?: componentBody(name)
        1 -> BINARY[name]?.let { "val v = r $it a0" } ?: ASSIGN[name]?.let { "r $it a0" } ?: ONE_ARGUMENT[name]
        else -> null
    }
    return simple ?: when (name) {
        "get" -> "val v = r[$args]".takeIf { arity >= 1 }

        "set" -> "r[${(0 until arity - 1).joinToString { "a$it" }}] = a${arity - 1}".takeIf { arity >= 2 }

        // the arguments (thisRef, property) come from the delegation
        "getValue" -> "val v by r\nprintln(v)".takeIf { arity == 2 }

        "invoke" -> "val v = r($args)"

        else -> null
    }
}

private fun componentBody(name: String): String? {
    val n = name.removePrefix("component").takeIf { name.startsWith("component") }?.toIntOrNull() ?: return null
    return "val (${(1 until n).joinToString("") { "_, " }}v) = r"
}

/**
 * The argument lists of a call: only the parameters without a default, and (when some have one) all of them; each as
 * (probe parameters, argument text). [type] writes a parameter type.
 */
internal fun KaSession.argumentLists(symbol: KaFunctionSymbol, type: (KaType) -> String): List<Pair<List<String>, String>> {
    val values = symbol.valueParameters
    val variants = mutableListOf(arguments(values, values.map { !it.hasDefaultValue }, type))
    if (values.any { it.hasDefaultValue }) variants += arguments(values, values.map { true }, type)
    return variants
}

private fun KaSession.arguments(
    values: List<KaValueParameterSymbol>,
    passed: List<Boolean>,
    type: (KaType) -> String,
): Pair<List<String>, String> {
    val params = mutableListOf<String>()
    val args = mutableListOf<String>()
    // after a left-out or vararg parameter the arguments are named (a Java method has neither)
    var named = false
    var trailing: String? = null
    values.forEachIndexed { i, p ->
        if (!passed[i]) {
            named = true
            return@forEachIndexed
        }
        val written = argument(p, "a$i", type)
        params += "a$i: ${written.type}"
        if (written.lambda && i == values.lastIndex && !named) {
            trailing = written.text
        } else {
            args += (if (named && !p.isJava()) "${p.name.asString().quoted()} = " else "") + written.text
        }
        if (p.isVararg) named = true
    }
    val text = when {
        trailing == null -> "(${args.joinToString()})"
        args.isEmpty() -> " $trailing"
        else -> "(${args.joinToString()}) $trailing"
    }
    return params to text
}

private class Argument(val type: String, val text: String, val lambda: Boolean)

/** One argument: the parameter itself, or a lambda forwarding to it; a vararg gets one element. */
private fun KaSession.argument(p: KaValueParameterSymbol, name: String, type: (KaType) -> String): Argument {
    val t = if (p.isVararg) p.returnType.arrayElementType ?: p.returnType else p.returnType
    val lambda = lambdaFor(t, name)
    return Argument(type(t), lambda ?: name, lambda != null)
}

private fun KaValueParameterSymbol.isJava() = origin == KaSymbolOrigin.JAVA_SOURCE || origin == KaSymbolOrigin.JAVA_LIBRARY

/** A lambda for a function-typed parameter, forwarding to the probe's parameter [name]. */
private fun KaSession.lambdaFor(type: KaType, name: String): String? {
    val fn = type.lowerBoundIfFlexible() as? KaFunctionType ?: return null
    if (fn.isReflectType) return null
    val ps = fn.parameterTypes.indices.map { "p$it" }
    val forwarded = (if (fn.hasReceiver) listOf("this") else emptyList()) + ps
    val head = if (ps.isEmpty()) "" else ps.joinToString(", ", postfix = " -> ")
    val callee = if (type.isMarkedNullable) "$name!!" else name
    return "{ $head$callee(${forwarded.joinToString()}) }"
}

/** A name as an identifier, back-quoted when it is a keyword. */
internal fun String.quoted() = if (this in KEYWORDS || !all { it.isLetterOrDigit() || it == '_' }) "`$this`" else this
