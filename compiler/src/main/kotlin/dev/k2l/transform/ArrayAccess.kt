package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.KtClassOrObject

/** The primitive arrays whose elements are never nil or false (not BooleanArray). */
private val PRIMITIVE_ARRAYS = setOf("IntArray", "LongArray", "DoubleArray", "FloatArray", "CharArray", "ShortArray", "ByteArray")
    .map { "kotlin/$it" }.toSet()

/**
 * An array whose elements are never nil or false: a primitive array of [PRIMITIVE_ARRAYS], or an `Array<T>` of a non-null
 * element type that cannot hold a Boolean (a number, Char, String, array, or class of the program).
 */
internal fun FileTransformer.isPrimitiveArray(type: KaType?): Boolean = with(session) {
    if (type == null || type.isMarkedNullable) return false
    val id = type.expandedSymbol?.classId?.asString()
    if (id in PRIMITIVE_ARRAYS) return true
    val element = type.elementType?.takeIf { id == "kotlin/Array" && !it.isMarkedNullable } ?: return false
    val elementId = (element as? KaClassType)?.expandedSymbol?.classId?.asString() ?: return false
    elementId in PLAIN_ELEMENTS || elementId in PRIMITIVE_ARRAYS || elementId == "kotlin/Array" ||
        (element.expandedSymbol?.psi as? KtClassOrObject)?.let { classes.isSource(it) && !it.hasModifier(KtTokens.VALUE_KEYWORD) } == true
}

private val PLAIN_ELEMENTS = setOf("Int", "Long", "Double", "Float", "Char", "Short", "Byte", "String").map { "kotlin/$it" }.toSet()

/**
 * Lua code that reads values without side effects or failing: names, literals, field reads and arithmetic of those, and
 * with [calls] the Int wrapping functions (cheap to evaluate again only where that is rare, e.g. on an error path).
 */
internal fun isPureRead(e: LuaExpr, calls: Boolean = false): Boolean = when (e) {
    is LuaName, is LuaNumber, is LuaString, is LuaBool, LuaNil -> true
    is LuaIndex -> (e.key is LuaString || e.key is LuaNumber) && isPureRead(e.target, calls)
    is LuaBinary -> e.op in PURE_OPERATORS && isPureRead(e.left, calls) && isPureRead(e.right, calls)
    is LuaUnary -> e.op == LuaUnOp.Neg && isPureRead(e.operand, calls)
    is LuaCall -> calls && e.fn in PURE_FUNCTIONS && e.args.all { isPureRead(it, calls) }
    else -> false
}

private val PURE_OPERATORS =
    setOf(LuaBinOp.Add, LuaBinOp.Sub, LuaBinOp.Mul, LuaBinOp.BAnd, LuaBinOp.BOr, LuaBinOp.BXor, LuaBinOp.Shl, LuaBinOp.Shr)

/** Functions without side effects that generated code wraps numbers in. */
private val PURE_FUNCTIONS = setOf(LuaName("__K2L_ToInt32"))

/**
 * `a[i]` of a primitive array: `a[i + 1] or __K2L_IndexError(i, a.size, true)` (any missing element is out of range), as
 * `__K2L_Array:get` checks, when reading the array and index again (on the error path) is harmless; else `a:get(i)`.
 */
internal fun FileTransformer.primitiveArrayRead(array: LuaExpr, index: LuaExpr): LuaExpr {
    if (!isPureRead(array, calls = true) || !isPureRead(index, calls = true)) return LuaMethodCall(array, "get", listOf(index))
    return LuaBinary(LuaBinOp.Or, CollectionMappings.index(array, index), indexError(array, index))
}

private fun FileTransformer.indexError(array: LuaExpr, index: LuaExpr): LuaExpr =
    lualibCall("IndexError", index, LuaIndex(array, LuaString("size")), LuaString("array"))

/** `xs[i]` as an assignment target, bounds-checked: the inline check of [primitiveArrayTarget], else `get`/`set`. */
internal fun FileTransformer.checkedIndexTarget(type: KaType?, receiver: LuaExpr, key: LuaExpr): Target = if (isPrimitiveArray(type)) {
    primitiveArrayTarget(receiver, key)
} else {
    Target(LuaMethodCall(receiver, "get", listOf(key))) { LuaCallStmt(LuaMethodCall(receiver, "set", listOf(key, it))) }
}

/**
 * `a[i] = v`, `a[i] += v` and `a[i]++` on a primitive array (cached [array] and [index]): an assignment checks the index
 * after evaluating the value (as `set` would); an update follows a checked read of the same element, so it just stores.
 */
internal fun FileTransformer.primitiveArrayTarget(array: LuaExpr, index: LuaExpr): Target {
    val slot = CollectionMappings.index(array, index)
    val outOfRange = LuaBinary(
        LuaBinOp.Or,
        LuaBinary(LuaBinOp.Lt, index, LuaNumber("0")),
        LuaBinary(LuaBinOp.Ge, index, LuaIndex(array, LuaString("size"))),
    )
    val write = { v: LuaExpr -> LuaCallStmt(LuaMethodCall(array, "set", listOf(index, v))) }
    return object : Target(primitiveArrayRead(array, index), write) {
        override fun assignAll(value: LuaExpr): List<LuaStmt> {
            val check = LuaIf(outOfRange, listOf(LuaCallStmt(indexError(array, index))))
            if (isPureRead(value)) return listOf(check, assign(slot, value))
            val v = ctx.temp("value")
            return listOf(LuaLocal(listOf(v), listOf(value)), check, assign(slot, LuaName(v)))
        }

        override fun update(value: LuaExpr): LuaStmt = assign(slot, value)
    }
}

/**
 * `s[i]` of a String (bytes): `(i >= 0 and i < #s) and s:sub(i + 1, i + 1) or __K2L_IndexError(i, #s, "string")`, as
 * `__K2L_StringCharAt` checks, when reading `s` and `i` again is harmless; else null.
 */
internal fun FileTransformer.inlineCharAt(text: LuaExpr, index: LuaExpr): LuaExpr? {
    if (!isPureRead(text, calls = true) || !isPureRead(index, calls = true)) return null
    val length = LuaUnary(LuaUnOp.Len, text)
    val inRange = LuaBinary(LuaBinOp.And, LuaBinary(LuaBinOp.Ge, index, LuaNumber("0")), LuaBinary(LuaBinOp.Lt, index, length))
    val at = LuaBinary(LuaBinOp.Add, index, LuaNumber("1"))
    val char = LuaMethodCall(text, "sub", listOf(at, at))
    val fail = lualibCall("IndexError", index, length, LuaString("string"))
    return LuaBinary(LuaBinOp.Or, LuaBinary(LuaBinOp.And, inRange, char), fail)
}
