package dev.k2l.codegen

/** `name = value` */
fun assign(name: String, value: LuaExpr): LuaStmt = assign(LuaName(name), value)

fun assign(target: LuaExpr, value: LuaExpr): LuaStmt = LuaAssign(listOf(target), listOf(value))

/** Index of the last element of a `List`/`Array` mapped to a Lua table. */
fun lastIndex(list: LuaExpr): LuaExpr = LuaBinary(LuaBinOp.Sub, LuaIndex(list, LuaString("size")), LuaNumber("1"))

/** `e + delta`, folded when [e] is an integer literal. */
fun plusConstant(e: LuaExpr, delta: Long): LuaExpr {
    val n = (e as? LuaNumber)?.text?.toLongOrNull()
    return when {
        n != null -> LuaNumber((n + delta).toString())
        delta < 0 -> LuaBinary(LuaBinOp.Sub, e, LuaNumber((-delta).toString()))
        else -> LuaBinary(LuaBinOp.Add, e, LuaNumber(delta.toString()))
    }
}

/** Logical negation of [e], folding `not`, booleans and `==`/`~=`. */
fun negate(e: LuaExpr): LuaExpr = when {
    e is LuaUnary && e.op == LuaUnOp.Not -> e.operand
    e is LuaBool -> LuaBool(!e.value)
    e is LuaBinary && e.op == LuaBinOp.Eq -> LuaBinary(LuaBinOp.Ne, e.left, e.right)
    e is LuaBinary && e.op == LuaBinOp.Ne -> LuaBinary(LuaBinOp.Eq, e.left, e.right)
    else -> LuaUnary(LuaUnOp.Not, e)
}

/** A Lua number for [d], spelling NaN and infinities as expressions. */
fun doubleLiteral(d: Double): LuaExpr = when {
    d.isNaN() -> LuaBinary(LuaBinOp.Div, LuaNumber("0.0"), LuaNumber("0.0"))
    d == Double.POSITIVE_INFINITY -> luaPath("math", "huge")
    d == Double.NEGATIVE_INFINITY -> LuaUnary(LuaUnOp.Neg, luaPath("math", "huge"))
    else -> LuaNumber(d.toString())
}
