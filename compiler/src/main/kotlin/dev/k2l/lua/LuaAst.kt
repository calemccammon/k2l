package dev.k2l.lua

/** Lua syntax tree produced by the transformer and rendered by [LuaPrinter]. */
sealed interface LuaExpr

data object LuaNil : LuaExpr
data class LuaBool(val value: Boolean) : LuaExpr

/** A numeric literal, already formatted as Lua source (`1`, `0.5`, `1.0E10`). */
data class LuaNumber(val text: String) : LuaExpr

data class LuaString(val value: String) : LuaExpr
data class LuaName(val name: String) : LuaExpr
data class LuaIndex(val target: LuaExpr, val key: LuaExpr) : LuaExpr
data class LuaCall(val fn: LuaExpr, val args: List<LuaExpr>) : LuaExpr
data class LuaMethodCall(val target: LuaExpr, val method: String, val args: List<LuaExpr>) : LuaExpr
data class LuaBinary(val op: LuaBinOp, val left: LuaExpr, val right: LuaExpr) : LuaExpr
data class LuaUnary(val op: LuaUnOp, val operand: LuaExpr) : LuaExpr
data class LuaFunction(val params: List<String>, val body: List<LuaStmt>, val isVararg: Boolean = false) : LuaExpr
data class LuaTable(val fields: List<LuaField>) : LuaExpr

sealed interface LuaField {
    data class Positional(val value: LuaExpr) : LuaField
    data class Named(val name: String, val value: LuaExpr) : LuaField
    data class Keyed(val key: LuaExpr, val value: LuaExpr) : LuaField
}

/** Binary operators with Lua 5.4 precedence (higher binds tighter). */
enum class LuaBinOp(val token: String, val precedence: Int, val rightAssoc: Boolean = false) {
    Or("or", 1), And("and", 2),
    Lt("<", 3), Gt(">", 3), Le("<=", 3), Ge(">=", 3), Ne("~=", 3), Eq("==", 3),
    BOr("|", 4), BXor("~", 5), BAnd("&", 6), Shl("<<", 7), Shr(">>", 7),
    Concat("..", 9, rightAssoc = true),
    Add("+", 10), Sub("-", 10),
    Mul("*", 11), Div("/", 11), IDiv("//", 11), Mod("%", 11),
    Pow("^", 13, rightAssoc = true),
}

enum class LuaUnOp(val token: String) { Not("not "), Neg("-"), Len("#"), BNot("~") }

const val UNARY_PRECEDENCE = 12

sealed interface LuaStmt

data class LuaLocal(val names: List<String>, val values: List<LuaExpr> = emptyList()) : LuaStmt
data class LuaAssign(val targets: List<LuaExpr>, val values: List<LuaExpr>) : LuaStmt
data class LuaCallStmt(val call: LuaExpr) : LuaStmt

/** `orElse` holding a single [LuaIf] prints as `elseif`. */
data class LuaIf(val cond: LuaExpr, val then: List<LuaStmt>, val orElse: List<LuaStmt>? = null) : LuaStmt
data class LuaWhile(val cond: LuaExpr, val body: List<LuaStmt>) : LuaStmt
data class LuaRepeat(val body: List<LuaStmt>, val until: LuaExpr) : LuaStmt
data class LuaNumericFor(
    val variable: String,
    val start: LuaExpr,
    val limit: LuaExpr,
    val step: LuaExpr?,
    val body: List<LuaStmt>,
) : LuaStmt
data class LuaGenericFor(val names: List<String>, val exprs: List<LuaExpr>, val body: List<LuaStmt>) : LuaStmt

/** `name` is a [LuaName] or [LuaIndex]; `isLocal` emits `local function`. */
data class LuaFunctionDecl(val name: LuaExpr, val fn: LuaFunction, val isLocal: Boolean) : LuaStmt
data class LuaReturn(val values: List<LuaExpr> = emptyList()) : LuaStmt
data object LuaBreak : LuaStmt
data class LuaGoto(val label: String) : LuaStmt
data class LuaLabel(val label: String) : LuaStmt
data class LuaDo(val body: List<LuaStmt>) : LuaStmt
data class LuaComment(val text: String) : LuaStmt

data class LuaChunk(val body: List<LuaStmt>)

/** `luaPath("math", "max")` is `math.max`. */
fun luaPath(root: String, vararg keys: String): LuaExpr =
    keys.fold(LuaName(root) as LuaExpr) { acc, key -> LuaIndex(acc, LuaString(key)) }

fun luaCall(fn: LuaExpr, vararg args: LuaExpr): LuaCall = LuaCall(fn, args.toList())
